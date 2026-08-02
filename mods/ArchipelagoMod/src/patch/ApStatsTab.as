package patch {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;

    import Bezel.Logger;
    import com.giab.games.gcfw.mcDyn.McStatStrip;
    import com.giab.games.gcfw.selector.PnlStats;

    /**
     * Injects a fifth "Archipelago" tab into the vanilla Stats panel
     * (PnlStats / McPnlStats), alongside General / Journey XP / Endurance XP /
     * Trial XP. Selecting it clears the shared scroll viewport and refills it
     * with AP-specific content.
     *
     * Reuse over reinvention (see feedback_reuse_vanilla_widgets):
     *   - The tab BUTTON is a pixel snapshot of the real vanilla Trial tab: for
     *     each plate frame (1=idle, 2=hover, 3=selected, 4=press) we briefly set
     *     the live button to that frame + our label, BitmapData.draw() it, then
     *     restore it. Our button swaps those bitmaps by state — identical native
     *     art AND game-font label, no dependency on a symbol class. Falls back to
     *     a hand-drawn button only if the capture fails.
     *   - Summary lines AND the per-level grid are McStatStrip rows (level in the
     *     left field, a compact stat string in the right), so everything renders
     *     in the game's own embedded font — the mod can't render that font in its
     *     own TextFields, and McStatStrip's fixed-width 2-column art can't be tiled
     *     into narrow columns, so this is the native-consistent layout.
     *   - The panel's own scroll machinery (freeUpMemory / statStrips /
     *     renderViewport) is driven directly, so scrolling behaves natively.
     *
     * Content is supplied by dataProvider — extend it without touching this class:
     *   {
     *     summary: [ { name, value, nameColor?, valueColor? }, ... ],   // stat lines
     *     grid:    { columns: [String,...], rows: [ [cell,...], ... ] } // per-level table
     *   }
     *
     * Lifecycle:
     *   onSelectorFrame(pnlStats) — every selector frame while AP is active.
     *     Idempotent inject; mirrors the vanilla tabs' visibility (IRON hides all);
     *     keeps our selected state in sync (clicking a vanilla tab deselects ours).
     *   unpatch() — remove the injected button (pnlStats.mc is persistent, so it
     *     would otherwise leak into a standalone save). Rows self-heal: the next
     *     vanilla render rebuilds statStrips.
     */
    public class ApStatsTab {

        /** () : { summary:Array, grid:{columns,rows} } — the content to show. */
        public var dataProvider:Function;

        private static const GRID_HEADER_COLOR:uint = 0x999999;

        private static const LABEL:String   = "Archipelago";
        private static const SUBTITLE:uint  = 0xFFCC44;
        private static const VAL_COLOR:uint = 0xFFCC44;

        private var _logger:Logger;
        private var _modName:String;

        private var _pnlStats:PnlStats;
        private var _tabBtn:Sprite;
        private var _injected:Boolean = false;
        private var _selected:Boolean = false;
        private var _native:Boolean   = false;   // true = snapshot of the vanilla button
        private var _stateBmps:Object = null;    // frame(int) -> BitmapData
        private var _curFrame:int     = 1;

        // Fallback (non-native) button styling + geometry — only used if the
        // vanilla symbol can't be cloned.
        private var _hovered:Boolean = false;
        private var _boxX:Number = 0, _boxY:Number = 0, _boxW:Number = 170, _boxH:Number = 48;
        private static const C_FILL_NORMAL:uint  = 0x181818;
        private static const C_FILL_HOVER:uint   = 0x262626;
        private static const C_FILL_SEL:uint     = 0x4A2C00;
        private static const C_EDGE_NORMAL:uint  = 0x3A3A3A;
        private static const C_EDGE_HOVER:uint   = 0x666644;
        private static const C_EDGE_SEL:uint     = 0xE5AD0A;
        private static const C_LABEL_NORMAL:uint = 0xBBBBBB;
        private static const C_LABEL_HOVER:uint  = 0xFFFFFF;
        private static const C_LABEL_SEL:uint    = 0xFFDD88;

        public function ApStatsTab(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        // -----------------------------------------------------------------------

        /** Call every selector frame while AP mode is active. */
        public function onSelectorFrame(pnlStats:PnlStats):void {
            if (pnlStats == null || pnlStats.mc == null) return;
            _pnlStats = pnlStats;
            _tryInject();
            if (_tabBtn == null) return;

            var mc:* = pnlStats.mc;

            // IRON mode hides the whole tab row — mirror that.
            var tabsVisible:Boolean = true;
            try { tabsVisible = (mc.btnGeneralStats.visible == true); } catch (eVis:Error) {}
            _tabBtn.visible = tabsVisible;

            // Keep the button above any rows the panel re-parents into itself.
            try { mc.setChildIndex(_tabBtn, mc.numChildren - 1); } catch (eIdx:Error) {}

            // Selection sync: a vanilla tab being selected (plate frame 3) means
            // ours is not. Covers panel-open (auto-renders General) and clicking a
            // vanilla tab.
            if (_selected && _anyVanillaTabSelected(mc)) {
                _selected = false;
                _applySelectedVisual();
            }
        }

        /** Remove the injected tab button. Rows self-heal on the next vanilla render. */
        public function unpatch():void {
            try {
                if (_tabBtn != null && _tabBtn.parent != null) {
                    _tabBtn.parent.removeChild(_tabBtn);
                }
            } catch (e:Error) {
                _logger.log(_modName, "ApStatsTab.unpatch error: " + e.message);
            }
            _disposeStateBmps();
            _tabBtn   = null;
            _injected = false;
            _selected = false;
            _hovered  = false;
            _native   = false;
            _curFrame = 1;
            _pnlStats = null;
        }

        // -----------------------------------------------------------------------

        private function _anyVanillaTabSelected(mc:*):Boolean {
            return _plateFrame(mc.btnGeneralStats)        == 3
                || _plateFrame(mc.btnJourneyFieldStats)   == 3
                || _plateFrame(mc.btnEnduranceFieldStats) == 3
                || _plateFrame(mc.btnTrialFieldStats)     == 3;
        }

        private function _plateFrame(btn:*):int {
            try { return int(btn.plate.currentFrame); } catch (e:Error) {}
            return 0;
        }

        // -----------------------------------------------------------------------

        private function _tryInject():void {
            if (_injected || _pnlStats == null || _pnlStats.mc == null) return;
            var mc:* = _pnlStats.mc;
            var trial:* = mc.btnTrialFieldStats;
            if (trial == null) return;

            _buildButton(trial);
            if (_tabBtn == null) return;

            // Same horizontal pitch as the existing tab row, one slot past Trial.
            var pitch:Number = 0;
            try { pitch = trial.x - mc.btnEnduranceFieldStats.x; } catch (eP:Error) {}
            if (pitch <= 0 || pitch > 800) pitch = 190;
            _tabBtn.x = trial.x + pitch;
            _tabBtn.y = trial.y;

            try {
                mc.addChild(_tabBtn);
                _injected = true;
                _logger.log(_modName, "ApStatsTab: injected (native=" + _native
                    + " trial x=" + trial.x + " y=" + trial.y + " pitch=" + pitch + ")");
            } catch (eAdd:Error) {
                _logger.log(_modName, "ApStatsTab: addChild failed: " + eAdd.message);
            }
        }

        /**
         * Snapshot the live vanilla Trial tab into four state bitmaps (1 idle,
         * 2 hover, 3 selected, 4 press), each with our "Archipelago" label in the
         * game font, then build our button from them. Mutates the real button's
         * frame + label only momentarily and restores both. Falls back to a
         * hand-drawn button if capture fails.
         */
        private function _buildButton(trial:*):void {
            try {
                var plate:* = trial.plate;
                var tf:* = trial.tf;
                if (plate == null || tf == null) throw new Error("no plate/tf");

                var bounds:Rectangle = trial.getBounds(trial);
                if (bounds == null || bounds.width < 10 || bounds.height < 6) throw new Error("bad bounds");

                var savedFrame:int   = int(plate.currentFrame);
                var savedText:String = String(tf.text);
                tf.text = LABEL;

                var w:int = Math.ceil(bounds.width);
                var h:int = Math.ceil(bounds.height);
                var m:Matrix = new Matrix();
                m.translate(-bounds.left, -bounds.top);

                _stateBmps = {};
                var frames:Array = [1, 2, 3, 4];
                for (var fi:int = 0; fi < frames.length; fi++) {
                    var fr:int = int(frames[fi]);
                    plate.gotoAndStop(fr);
                    var bd:BitmapData = new BitmapData(w, h, true, 0x00000000);
                    bd.draw(trial, m);
                    _stateBmps[fr] = bd;
                }
                tf.text = savedText;          // restore the live button
                plate.gotoAndStop(savedFrame);

                _native = true;
                _tabBtn = new Sprite();
                _tabBtn.buttonMode    = true;
                _tabBtn.useHandCursor = true;
                var bmp:Bitmap = new Bitmap(_stateBmps[1] as BitmapData);
                bmp.name      = "bmp";
                bmp.smoothing = true;
                bmp.x = bounds.left;
                bmp.y = bounds.top;
                _tabBtn.addChild(bmp);
                _curFrame = 1;

                _tabBtn.addEventListener(MouseEvent.ROLL_OVER,  _onRollOver, false, 0, true);
                _tabBtn.addEventListener(MouseEvent.ROLL_OUT,   _onRollOut,  false, 0, true);
                _tabBtn.addEventListener(MouseEvent.MOUSE_DOWN, _onDown,     false, 0, true);
                _tabBtn.addEventListener(MouseEvent.CLICK,      _onClick,    false, 0, true);
                return;
            } catch (e:Error) {
                _logger.log(_modName, "ApStatsTab: native snapshot failed (" + e.message + ") — using fallback");
                _disposeStateBmps();
            }
            _buildFallbackButton(trial);
        }

        private function _setState(frame:int):void {
            if (!_native || _tabBtn == null || _stateBmps == null) return;
            var bmp:Bitmap = _tabBtn.getChildByName("bmp") as Bitmap;
            if (bmp == null) return;
            var bd:BitmapData = _stateBmps[frame] as BitmapData;
            if (bd != null) { bmp.bitmapData = bd; _curFrame = frame; }
        }

        private function _disposeStateBmps():void {
            if (_stateBmps == null) return;
            for each (var bd:BitmapData in _stateBmps) {
                try { if (bd != null) bd.dispose(); } catch (e:Error) {}
            }
            _stateBmps = null;
        }

        // -----------------------------------------------------------------------
        // Interaction (shared; branches on _native)

        private function _onClick(e:MouseEvent):void {
            renderApStats();
        }

        private function _onDown(e:MouseEvent):void {
            if (_native && !_selected) _setState(4); // pressed
        }

        private function _onRollOver(e:MouseEvent):void {
            if (_native) { if (!_selected) _setState(2); }   // hover, unless selected
            else         { _hovered = true;  _redrawFallback(); }
        }

        private function _onRollOut(e:MouseEvent):void {
            if (_native) { if (!_selected) _setState(1); }
            else         { _hovered = false; _redrawFallback(); }
        }

        /** Apply the current _selected state to the button visuals. */
        private function _applySelectedVisual():void {
            if (_native) _setState(_selected ? 3 : 1);
            else         _redrawFallback();
        }

        // -----------------------------------------------------------------------
        // Fallback hand-drawn button (only if the vanilla symbol can't be cloned)

        private function _buildFallbackButton(trial:*):void {
            _native = false;
            try {
                var r:Rectangle = trial.getBounds(trial);
                if (r != null && r.width > 20 && r.width < 500)   { _boxX = r.left; _boxW = r.width; }
                else                                              { _boxW = 170; _boxX = -_boxW / 2; }
                if (r != null && r.height > 10 && r.height < 160) { _boxY = r.top;  _boxH = r.height; }
                else                                              { _boxH = 48;  _boxY = -_boxH / 2; }
            } catch (eB:Error) {
                _boxW = 170; _boxX = -_boxW / 2; _boxH = 48; _boxY = -_boxH / 2;
            }

            _tabBtn = new Sprite();
            _tabBtn.buttonMode    = true;
            _tabBtn.useHandCursor = true;

            var bg:Shape = new Shape();
            bg.name = "bg";
            _tabBtn.addChild(bg);

            var lbl:TextField = new TextField();
            lbl.name          = "lbl";
            lbl.autoSize      = TextFieldAutoSize.CENTER;
            lbl.selectable    = false;
            lbl.mouseEnabled  = false;
            lbl.defaultTextFormat = new TextFormat("_sans", 15, C_LABEL_NORMAL, true);
            lbl.text          = LABEL;
            lbl.x             = _boxX + (_boxW - lbl.width)  / 2;
            lbl.y             = _boxY + (_boxH - lbl.height) / 2;
            _tabBtn.addChild(lbl);

            _tabBtn.addEventListener(MouseEvent.CLICK,     _onClick,    false, 0, true);
            _tabBtn.addEventListener(MouseEvent.ROLL_OVER, _onRollOver, false, 0, true);
            _tabBtn.addEventListener(MouseEvent.ROLL_OUT,  _onRollOut,  false, 0, true);
            _redrawFallback();
        }

        private function _redrawFallback():void {
            if (_tabBtn == null) return;
            var bg:Shape = _tabBtn.getChildByName("bg") as Shape;
            var lbl:TextField = _tabBtn.getChildByName("lbl") as TextField;
            if (bg == null) return;

            var fill:uint  = _selected ? C_FILL_SEL  : (_hovered ? C_FILL_HOVER : C_FILL_NORMAL);
            var edge:uint  = _selected ? C_EDGE_SEL  : (_hovered ? C_EDGE_HOVER : C_EDGE_NORMAL);
            var label:uint = _selected ? C_LABEL_SEL : (_hovered ? C_LABEL_HOVER : C_LABEL_NORMAL);

            bg.graphics.clear();
            bg.graphics.lineStyle(2, edge, 0.95);
            bg.graphics.beginFill(fill, 1.0);
            bg.graphics.drawRoundRect(_boxX, _boxY, _boxW, _boxH, 8, 8);
            bg.graphics.endFill();
            if (lbl != null) lbl.setTextFormat(new TextFormat("_sans", 15, label, true));
        }

        // -----------------------------------------------------------------------

        /**
         * Take over the shared scroll viewport and render the AP content. Mirrors
         * PnlStats.renderGeneralStats(): deselect the vanilla tabs, hide the
         * field-sort buttons, rebuild statStrips (subtitle + McStatStrip summary
         * lines + a McStatStrip per-level grid), then hand back to renderViewport().
         */
        public function renderApStats():void {
            var pnl:PnlStats = _pnlStats;
            if (pnl == null || pnl.mc == null) return;
            var mc:* = pnl.mc;

            try {
                mc.btnGeneralStats.plate.gotoAndStop(1);
                mc.btnJourneyFieldStats.plate.gotoAndStop(1);
                mc.btnEnduranceFieldStats.plate.gotoAndStop(1);
                mc.btnTrialFieldStats.plate.gotoAndStop(1);
                mc.btnSortById.visible = false;
                mc.btnSortByXp.visible = false;
                mc.btnScrollKnob.y = 172;

                pnl.freeUpMemory();

                var data:Object    = (dataProvider != null) ? dataProvider() : null;
                var summary:Array  = (data != null && data.summary is Array) ? (data.summary as Array) : [];
                var grid:Object    = (data != null) ? data.grid : null;
                var gridRows:Array = (grid != null && grid.rows is Array) ? (grid.rows as Array) : [];
                var gridCols:Array = (grid != null && grid.columns is Array) ? (grid.columns as Array) : [];

                var subtitle:* = mc.mcTfSubTitle;
                subtitle.tf.text      = "Archipelago Stats";
                subtitle.tf.textColor = SUBTITLE;

                var yPos:Number = 155;
                pnl.statStrips = new Array();
                subtitle.yAbs      = yPos;
                subtitle.isVisible = false;
                pnl.statStrips.push(subtitle);
                yPos += 50;

                // Summary stat lines (DeathLinks, etc.) as vanilla McStatStrip rows.
                for (var i:int = 0; i < summary.length; i++) {
                    var srow:Object = summary[i];
                    if (srow == null) continue;
                    var strip:McStatStrip = new McStatStrip();
                    strip.tfStatName.text       = String(srow.name);
                    strip.tfStatName.textColor  = (srow.nameColor  !== undefined) ? uint(srow.nameColor)  : 0xFFFFFF;
                    strip.tfStatValue.text      = String(srow.value);
                    strip.tfStatValue.textColor = (srow.valueColor !== undefined) ? uint(srow.valueColor) : VAL_COLOR;
                    strip.yAbs = yPos;
                    yPos += 45;
                    pnl.statStrips.push(strip);
                }

                // Per-level grid: a header + one McStatStrip per stage. Level and
                // the compact stat string share the LEFT field (tfStatName) — the
                // one vanilla proves holds long strings; the right field stays for
                // the highlight number (achievements). Matches the native XP tabs.
                if (gridRows.length > 0) {
                    yPos += 15;
                    var hdr:McStatStrip = new McStatStrip();
                    hdr.tfStatName.text       = (gridCols.length > 0) ? String(gridCols[0]) : "Level";
                    hdr.tfStatName.textColor  = GRID_HEADER_COLOR;
                    hdr.tfStatValue.text      = (gridCols.length > 1) ? String(gridCols[1]) : "";
                    hdr.tfStatValue.textColor = GRID_HEADER_COLOR;
                    hdr.yAbs = yPos;
                    yPos += 45;
                    pnl.statStrips.push(hdr);

                    for (var r:int = 0; r < gridRows.length; r++) {
                        var cells:Array = gridRows[r] as Array;
                        if (cells == null || cells.length < 2) continue;
                        var gs:McStatStrip = new McStatStrip();
                        gs.tfStatName.text       = String(cells[0]);
                        gs.tfStatName.textColor  = 0xFFFFFF;
                        gs.tfStatValue.text      = String(cells[1]);
                        gs.tfStatValue.textColor = VAL_COLOR;
                        gs.yAbs = yPos;
                        yPos += 45;
                        pnl.statStrips.push(gs);
                    }
                }

                if (yPos > 848) {
                    mc.btnScrollKnob.visible = true;
                    mc.mcScrollBar.visible   = true;
                } else {
                    mc.btnScrollKnob.visible = false;
                    mc.mcScrollBar.visible   = false;
                }
                pnl.vpYMin = 0;
                pnl.vpYMax = Math.max(0, yPos - 848);
                pnl.vpY    = 0;
                pnl.renderViewport();

                _selected = true;
                _applySelectedVisual();
            } catch (e:Error) {
                _logger.log(_modName, "ApStatsTab.renderApStats error: " + e.message);
            }
        }
    }
}
