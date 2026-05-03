package ui {
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.DropType;
    import com.giab.games.gcfw.entity.TalismanFragment;
    import com.giab.games.gcfw.mcDyn.McDropIconOutcome;
    import com.giab.games.gcfw.mcDyn.McOptNote;
    import com.giab.games.gcfw.mcDyn.McOptPanel;
    import com.giab.games.gcfw.mcDyn.McOptTitle;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.filters.DropShadowFilter;
    import flash.filters.GlowFilter;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.StaticText;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.getDefinitionByName;

    import data.AV;

    import ui.GempouchDropIcon;
    import ui.MapTileDropIcon;
    import ui.SkillPointDropIcon;
    import ui.XpTomeDropIcon;

    /**
     * Offline-items grid panel — same chrome as the rest of the mod's
     * panels (see McDebugOptions / McSlotSettings).
     *
     * McOptions is not in the SWC stub, so we instantiate it at runtime via
     * getDefinitionByName and embed it inside this MovieClip. The McOptions
     * chrome supplies the title strip, scrollbar, and Close button — we strip
     * out the vanilla Options content and inject our icon grid.
     *
     * Cells are added to _inner.arrCntContents so ScrollablePanel can manage
     * vertical scrolling and visibility clipping.
     */
    public class McOfflineItems extends MovieClip {

        // Layout
        private static const TITLE_X:Number       = 536;
        private static const CONTENT_TOP:Number   = 140;
        private static const COLUMNS:int          = 8;
        // Drop icons (McDropIconOutcome and our custom siblings) all render at 140x140.
        private static const CELL_SIZE:Number     = 140;
        private static const CELL_GAP:Number      = 12;
        private static const ROW_PITCH:Number     = CELL_SIZE + CELL_GAP;
        private static const GRID_LEFT:Number     = 180;

        [Embed(source='../images/IconColorSmall.png')]
        private static const IconAsset:Class;

        // -- Inner McOptions instance (typed * because McOptions extends Sprite, not MovieClip) --
        private var _inner:*;

        // Replaceable title text (overlay over the vanilla "Options" StaticText).
        private var _titleTf:TextField;

        // Cells we built, in display order.
        public var cells:Array;

        /**
         * Optional callback that renders the rich vanilla-style title text
         * for the hovered cell. See OfflineItemsPanel.tooltipRenderer for
         * the contract. Set by OfflineItemsPanel.show before populate.
         */
        public var tooltipRenderer:Function;

        // Pass-throughs that ScrollablePanel.attach reads.
        public function get arrCntContents():Array       { return _inner.arrCntContents; }
        public function set arrCntContents(v:Array):void { _inner.arrCntContents = v; }
        public function get cnt():*                      { return _inner.cnt; }
        public function get btnClose():*                 { return _inner.btnClose; }
        public function get btnScrollKnob():MovieClip    { return _inner.btnScrollKnob; }
        public function get mcScrollBar():*              { return _inner.mcScrollBar; }

        public function McOfflineItems() {
            super();

            // Instantiate the real McOptions from the game SWF at runtime.
            var McOptionsClass:Class =
                getDefinitionByName("com.giab.games.gcfw.mcStat.McOptions") as Class;
            _inner = new McOptionsClass();
            addChild(_inner);

            // Hide all the battle/menu buttons that don't apply to us.
            _safeHide("btnConfirmRetry");
            _safeHide("btnConfirmReturn");
            _safeHide("btnConfirmEndBattle");
            _safeHide("btnEndBattle");
            _safeHide("btnReturn");
            _safeHide("btnRetry");
            _safeHide("btnMainMenu");
            _showClose();

            // Wipe the vanilla Options content; we'll fill cnt with our grid.
            while (_inner.cnt.numChildren > 0) _inner.cnt.removeChildAt(0);
            _inner.arrCntContents = new Array();
            cells = [];

            // Defensive sweep: McOptions is a Flash-authored symbol whose FLA
            // timeline can carry placeholder McOptPanel / McOptTitle / McOptNote
            // instances at the _inner root level. The vanilla AS3 constructor
            // re-creates panels via `new` and pushes them into cnt — but the
            // FLA-placed originals remain children of _inner, just orphaned
            // from the public vars. Hide any we find so they don't appear as
            // phantom items in our grid.
            _hidePhantomChrome();

            _overlayTitle("");
        }

        // -----------------------------------------------------------------------
        // Public API

        /** Update the title text shown over the chrome. */
        public function setTitle(text:String):void {
            if (_titleTf != null) _titleTf.text = text;
        }

        /**
         * Build the icon grid for the given entries.
         * @param entries  Array of { apId, name, sender }.
         * Returns the cells (also stored on this.cells).
         */
        public function populate(entries:Array):Array {
            // Clear any prior grid.
            while (_inner.cnt.numChildren > 0) _inner.cnt.removeChildAt(0);
            _inner.arrCntContents = new Array();
            cells = [];

            for (var i:int = 0; i < entries.length; i++) {
                var entry:Object = entries[i];
                var cell:OfflineItemCell = _buildCell(
                    int(entry.apId),
                    String(entry.name != null ? entry.name : "Item #" + entry.apId),
                    entry.sender != null ? String(entry.sender) : null,
                    entry.iconBmpd as BitmapData);

                var col:int = i % COLUMNS;
                var row:int = i / COLUMNS;
                cell.xReal = GRID_LEFT + col * ROW_PITCH;
                cell.yReal = CONTENT_TOP + row * ROW_PITCH;
                cell.x     = cell.xReal;
                cell.y     = cell.yReal;
                // Pre-reveal: invisible AND not hit-testable. Reveal flips both.
                // mouseEnabled=false here is what prevents the tooltip from
                // firing on cells that haven't yet popped in.
                cell.alpha        = 0;
                cell.mouseEnabled = false;

                _inner.cnt.addChild(cell);
                _inner.arrCntContents.push(cell);
                cells.push(cell);
            }
            return cells;
        }

        // -----------------------------------------------------------------------
        // Cell factory

        private function _buildCell(apId:int, itemName:String, sender:String,
                                    overrideBmpd:BitmapData = null):OfflineItemCell {
            var cell:OfflineItemCell = new OfflineItemCell();
            cell.apId     = apId;
            cell.itemName = itemName;
            cell.sender   = (sender != null && sender.length > 0) ? sender : null;

            // Pull the rendered bitmap out of the proper drop-icon class for this
            // apId range. We extract just `bmpdIcon` rather than adding the full
            // icon Sprite as a child — that way the cell's tooltip handler is the
            // only MOUSE_OVER listener, with no double-fire from icons that wire
            // their own (XpTomeDropIcon, GempouchDropIcon, etc).
            //
            // The caller may supply an `overrideBmpd` for cases that need
            // mod-side context our factory doesn't have (e.g. achievement
            // icons need _achievementUnlocker.findGameIdByApId). When provided,
            // we use it directly and skip our own factory.
            var bmpd:BitmapData = overrideBmpd;
            if (bmpd == null) bmpd = _bmpdataForApId(apId);
            if (bmpd == null) bmpd = _renderApFallbackBitmap();
            cell.addChild(new Bitmap(bmpd));

            // Skill point bundles get the same cyan GlowFilter SkillPointDropIcon
            // applies to its Sprite at level-end. The filter lives on the Sprite,
            // not in bmpdIcon, so extracting bitmap loses it — re-apply here.
            if (apId >= 1700 && apId <= 1709) {
                cell.filters = [new GlowFilter(0x33CCFF, 1, 16, 16, 3, 2)];
            }

            cell.addEventListener(MouseEvent.MOUSE_OVER, _onCellOver, false, 0, true);
            cell.addEventListener(MouseEvent.MOUSE_OUT,  _onCellOut,  false, 0, true);
            return cell;
        }

        /**
         * Construct the matching drop-icon class for apId and return its rendered
         * BitmapData. Returns null if the apId range isn't recognized OR if the
         * required GV / AV state isn't ready yet (e.g. demo run before the
         * selector loads). Caller falls back to the generic AP icon in that case.
         */
        private function _bmpdataForApId(apId:int):BitmapData {
            try {
                if (apId >= 1 && apId <= 122) {
                    if (AV.serverData != null && AV.serverData.tokenMap != null && GV.stageCollection != null) {
                        var strId:* = AV.serverData.tokenMap[String(apId)];
                        if (strId != null) {
                            var stageId:int = GV.getFieldId(String(strId));
                            if (stageId >= 0) {
                                return McDropIconOutcome(new McDropIconOutcome(DropType.FIELD_TOKEN, stageId)).bmpdIcon;
                            }
                        }
                    }
                } else if (apId >= 600 && apId <= 625) {
                    if (AV.serverData != null && AV.serverData.apIdToGameId != null
                            && GV.selectorCore != null && GV.selectorCore.mapTiles != null) {
                        var tileGid:int = int(AV.serverData.apIdToGameId[apId]);
                        if (tileGid >= 0 && tileGid < 26) {
                            return new MapTileDropIcon(tileGid).bmpdIcon;
                        }
                    }
                } else if (apId >= 700 && apId <= 723) {
                    return McDropIconOutcome(new McDropIconOutcome(DropType.SKILL_TOME, apId - 700)).bmpdIcon;
                } else if (apId >= 800 && apId <= 814) {
                    return McDropIconOutcome(new McDropIconOutcome(DropType.BATTLETRAIT_SCROLL, apId - 800)).bmpdIcon;
                } else if (apId >= 626 && apId <= 652) {
                    return new GempouchDropIcon(apId).bmpdIcon;
                } else if ((apId >= 900 && apId <= 952) || (apId >= 1200 && apId <= 1246)) {
                    // Talisman fragments — construct a TalismanFragment from the
                    // server-provided "seed/rarity/type/upgradeLevel" string and
                    // let McDropIconOutcome render its bitmap.
                    if (AV.serverData != null && AV.serverData.talismanMap != null) {
                        var talData:* = AV.serverData.talismanMap[String(apId)];
                        if (talData != null) {
                            var parts:Array = String(talData).split("/");
                            if (parts.length >= 4) {
                                var frag:TalismanFragment = new TalismanFragment(
                                    int(parts[0]), int(parts[1]),
                                    int(parts[2]), int(parts[3]));
                                return McDropIconOutcome(new McDropIconOutcome(
                                    DropType.TALISMAN_FRAGMENT, frag)).bmpdIcon;
                            }
                        }
                    }
                } else if ((apId >= 1000 && apId <= 1016) || (apId >= 1300 && apId <= 1351)) {
                    // Shadow cores: amount affects pile rendering. We don't know the
                    // actual amount per-apId here; render a small pile (1) for the visual.
                    return McDropIconOutcome(new McDropIconOutcome(DropType.SHADOW_CORE, 1)).bmpdIcon;
                } else if (apId >= 1100 && apId <= 1199) {
                    return new XpTomeDropIcon(apId, 0).bmpdIcon;
                } else if (apId >= 1400 && apId <= 1521) {
                    // Per-stage Wizard Stash keys — one per stage.
                    return new WizStashKeyDropIcon(apId).bmpdIcon;
                } else if (apId >= 1522 && apId <= 1561) {
                    // Stash key pouches: per-tile (1522-1547),
                    // per-tier (1548-1560), and master (1561).
                    return new KeyPouchDropIcon(apId).bmpdIcon;
                } else if (apId >= 1562 && apId <= 1600) {
                    // Coarse field tokens — per-tile (1562-1587) and per-tier
                    // (1588-1600). Both render as the generic TilePouch artwork
                    // since the player's getting "tokens for a group of stages",
                    // not a specific map tile.
                    return new TilePouchDropIcon(apId).bmpdIcon;
                } else if (apId >= 1700 && apId <= 1709) {
                    return new SkillPointDropIcon(apId - 1699).bmpdIcon;
                }
                // ---------- Progressive variants (singleton apIds) ----------
                // Each progressive's apId comes from slot_data, so we route
                // via ServerOptions rather than hardcoded ranges.
                if (AV.serverData != null && AV.serverData.serverOptions != null) {
                    var so:* = AV.serverData.serverOptions;
                    if (so.fieldTokenPerStageProgressiveId > 0
                            && apId == so.fieldTokenPerStageProgressiveId) {
                        // Per-stage progressive: render as a generic field-token
                        // plate. Each instance unlocks one specific stage but
                        // we don't know which from apId alone — could compute
                        // from count + order, but that varies between instances
                        // in the offline panel. Use TilePouch as a neutral icon.
                        return new TilePouchDropIcon(apId).bmpdIcon;
                    }
                    if ((so.fieldTokenPerTileProgressiveId > 0
                                && apId == so.fieldTokenPerTileProgressiveId)
                            || (so.fieldTokenPerTierProgressiveId > 0
                                && apId == so.fieldTokenPerTierProgressiveId)) {
                        return new TilePouchDropIcon(apId).bmpdIcon;
                    }
                    if ((so.stashKeyPerStageProgressiveId > 0
                                && apId == so.stashKeyPerStageProgressiveId)
                            || (so.stashKeyPerTileProgressiveId > 0
                                && apId == so.stashKeyPerTileProgressiveId)
                            || (so.stashKeyPerTierProgressiveId > 0
                                && apId == so.stashKeyPerTierProgressiveId)) {
                        return new KeyPouchDropIcon(apId).bmpdIcon;
                    }
                    if (so.gemPouchPerTierProgressiveId > 0
                            && apId == so.gemPouchPerTierProgressiveId) {
                        return new GempouchDropIcon(apId).bmpdIcon;
                    }
                }
                // Achievements (2000-2636) need _achievementUnlocker.findGameIdByApId
                // which lives on the mod side, not in this view. ArchipelagoMod's
                // resolver pre-builds the BitmapData and passes it via entry.iconBmpd
                // (overrideBmpd), so we don't need to handle them here.
            } catch (err:Error) {
                // Any construction failure (missing GV state, etc.) falls back.
            }
            return null;
        }

        /**
         * Render the generic AP icon (IconColorSmall.png) into a 140x140 BitmapData
         * for use as the fallback when we don't have a type-specific renderer.
         * Cached statically so we draw once and reuse for every fallback cell.
         */
        private static var _apFallbackBmpd:BitmapData = null;
        private static function _renderApFallbackBitmap():BitmapData {
            if (_apFallbackBmpd != null) return _apFallbackBmpd;
            var bmpd:BitmapData = new BitmapData(CELL_SIZE, CELL_SIZE, true, 0);
            var src:Bitmap      = new IconAsset() as Bitmap;
            if (src != null && src.bitmapData != null) {
                var srcW:int     = src.bitmapData.width;
                var srcH:int     = src.bitmapData.height;
                var maxDim:int   = CELL_SIZE - 30;
                var scale:Number = Math.min(maxDim / srcW, maxDim / srcH);
                var m:Matrix = new Matrix();
                m.scale(scale, scale);
                m.translate((CELL_SIZE - srcW * scale) * 0.5,
                            (CELL_SIZE - srcH * scale) * 0.5);
                bmpd.draw(src.bitmapData, m, null, null, null, true);
                var dsf:DropShadowFilter = new DropShadowFilter(0, 45, 0, 1, 14, 14, 2, 3);
                bmpd.applyFilter(bmpd, new Rectangle(0, 0, CELL_SIZE, CELL_SIZE),
                                 new Point(0, 0), dsf);
            }
            _apFallbackBmpd = bmpd;
            return bmpd;
        }

        private function _onCellOver(e:MouseEvent):void {
            try {
                var cell:OfflineItemCell = e.currentTarget as OfflineItemCell;
                if (cell == null) return;
                var vIp:* = GV.mcInfoPanel;
                if (vIp == null) return;

                // Let the host (ArchipelagoMod) render the rich, vanilla-style
                // title text. Vanilla renderers (renderInfoPanelFragment,
                // renderAchiInfoPanel) do their own reset/add/addChild, so we
                // shouldn't pre-reset here — the renderer handles that.
                var renderedMain:Boolean = false;
                if (tooltipRenderer != null) {
                    renderedMain = Boolean(tooltipRenderer(vIp, cell.apId));
                }
                if (!renderedMain) {
                    // Fallback for unknown ranges / missing context.
                    vIp.reset(280);
                    vIp.addTextfield(0xCC99FF, cell.itemName, false, 13);
                }

                // "Received from <player>" always appended at the end if known.
                if (cell.sender != null) {
                    vIp.addTextfield(0xFFFFFF, "Received from " + cell.sender, false, 11);
                }

                // Some renderers (the simple ones with reset()) don't re-add
                // the panel to cntInfoPanel; ensure it's on stage either way.
                if (GV.main != null && GV.main.cntInfoPanel != null
                        && !GV.main.cntInfoPanel.contains(vIp)) {
                    GV.main.cntInfoPanel.addChild(vIp);
                }
                vIp.doEnterFrame();
            } catch (err:Error) {
                // Fail silent — tooltip is non-critical.
            }
        }

        private function _onCellOut(e:MouseEvent):void {
            try { GV.main.cntInfoPanel.removeChild(GV.mcInfoPanel); } catch (err:Error) {}
        }

        // -----------------------------------------------------------------------
        // Chrome helpers — same approach as McDebugOptions

        private function _safeHide(name:String):void {
            try { _inner[name].visible = false; } catch (err:Error) {}
        }

        /**
         * Walk the McOptions root children and hide any leftover McOptPanel /
         * McOptTitle / McOptNote instances. These are FLA-timeline placeholders
         * that the vanilla constructor doesn't clean up — invisible in the
         * vanilla flow but visible to us because we strip cnt and don't push
         * replacement panels into the same slots.
         */
        private function _hidePhantomChrome():void {
            var hidden:int = 0;
            for (var i:int = 0; i < _inner.numChildren; i++) {
                var ch:DisplayObject = _inner.getChildAt(i) as DisplayObject;
                if (ch == null) continue;
                if (ch is McOptPanel || ch is McOptTitle || ch is McOptNote) {
                    ch.visible = false;
                    hidden++;
                }
            }
            // Also defensively walk cnt in case any phantoms slipped in there
            // even though we just cleared it.
            var cntC:DisplayObjectContainer = _inner.cnt as DisplayObjectContainer;
            if (cntC != null) {
                for (var j:int = 0; j < cntC.numChildren; j++) {
                    var c2:DisplayObject = cntC.getChildAt(j) as DisplayObject;
                    if (c2 == null) continue;
                    if (c2 is McOptPanel || c2 is McOptTitle || c2 is McOptNote) {
                        c2.visible = false;
                        hidden++;
                    }
                }
            }
        }

        private function _showClose():void {
            try { _inner.btnClose.visible = true; } catch (err:Error) {}
        }

        /** Replace the vanilla "Options" label with our own dynamic TextField. */
        private function _overlayTitle(initial:String):void {
            var original:StaticText = _findStaticText(_inner, "Options");
            if (original == null) return;
            original.visible = false;
            var bounds:Rectangle = original.getBounds(original.parent);
            _titleTf = new TextField();
            var fmt:TextFormat = new TextFormat("Palatino Linotype", 28, 0xFFFFFF, true);
            fmt.align = "center";
            _titleTf.defaultTextFormat = fmt;
            _titleTf.selectable   = false;
            _titleTf.mouseEnabled = false;
            var tfWidth:Number = 600;
            _titleTf.x      = bounds.x + bounds.width / 2 - tfWidth / 2;
            _titleTf.y      = bounds.y;
            _titleTf.width  = tfWidth;
            _titleTf.height = bounds.height + 8;
            _titleTf.text   = initial;
            original.parent.addChild(_titleTf);
        }

        private function _findStaticText(obj:DisplayObjectContainer, search:String):StaticText {
            for (var i:int = 0; i < obj.numChildren; i++) {
                var child:* = obj.getChildAt(i);
                if (child is StaticText && StaticText(child).text == search) return StaticText(child);
                if (child is DisplayObjectContainer) {
                    var found:StaticText = _findStaticText(DisplayObjectContainer(child), search);
                    if (found != null) return found;
                }
            }
            return null;
        }
    }
}
