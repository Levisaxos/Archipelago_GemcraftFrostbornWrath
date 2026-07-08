package ui {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.bmpd.BmpdInfoPanelCornerPaper;
    import com.giab.games.gcfw.bmpd.BmpdInfoPanelFrameBlack;
    import com.giab.games.gcfw.bmpd.BmpdInfoPanelFramePaper;
    import com.giab.games.gcfw.constants.SelectorScreenStatus;

    import data.AV;
    import net.ConnectionManager;
    import tracker.FieldLogicEvaluator;

    /**
     * PREVIEW of the proposed icon-based field tooltip \u2014 the panel intended to
     * eventually replace the vanilla field hover tooltip.
     *
     * Content is LIVE for whichever field token the cursor is over:
     *   - stage name, wave count, first-wave HP  (from GV.stageCollection)
     *   - the real minimap                       (SelectorRenderer.renderFieldMinimap)
     *   - Journey/Stash check orbs               (grey done / green in logic / red blocked)
     * Still placeholders: the headline line and the achievement count ("A:3").
     *
     * The frame is rebuilt from the game's own McInfoPanel paper/black frame
     * assets over the same semi-transparent black plate (0xB7000000) so it
     * matches vanilla. Unlike GV.mcInfoPanel this is a normal live Sprite \u2014
     * its icons are real display children (not baked into one bitmap), which
     * is what a later popup-in-popup (hover an icon -> sub-tooltip) needs.
     *
     * It anchors beside the hovered token (static, not cursor-following) and
     * stays up while the cursor is over the token OR the panel itself, so the
     * user can move onto it and hover its icons. It suppresses the vanilla
     * field tooltip so it effectively replaces it on the world map.
     */
    public class IconTooltipPreview extends Sprite {

        private static const FONT:String        = "Celtic Garamond for GemCraft";
        private static const PLATE_COLOR:uint    = 0xB7000000;
        private static const PANEL_W:int         = 416; // matches vanilla plate (320 * 1.3)
        private static const PANEL_H:int         = 388; // max height; clamps the anchor + sizes the hover hit-test
        // Padding below the hover-detail text before the frame's bottom edge.
        private static const BOTTOM_PAD:int      = 14;

        // Native minimap is 240x152; show it at 0.72 scale.
        private static const MAP_SCALE:Number    = 0.72;
        private static const MAP_DISP_W:int      = 173;
        private static const MAP_DISP_H:int      = 110;

        // Gap between token and panel, and the slack added to the panel's
        // hover rect so the cursor can cross from token to panel without a
        // dead zone that would dismiss it.
        private static const ANCHOR_GAP:int      = 12;
        private static const HOVER_MARGIN:int    = 14;

        private static const COL_TITLE:uint      = 0xFFD766; // gold
        private static const COL_LABEL:uint      = 0xE5AD0A; // amber section labels
        private static const COL_MUTED:uint      = 0x9A8E70; // parchment grey
        private static const COL_STAT:uint       = 0xCCCCCC; // stat lines
        private static const COL_GREEN:uint      = 0x44FF44;
        private static const COL_RED:uint        = 0xFF4444;
        private static const COL_GREY:uint       = 0x888888;

        // Stage index the panel is currently built for (-1 = nothing).
        private var _shownSid:int = -1;
        // Static anchor position (main space) the panel is pinned to.
        private var _anchorX:Number = 80;
        private var _anchorY:Number = 170;
        // True while we're forcing the vanilla info panel hidden.
        private var _suppressed:Boolean = false;
        // Logic source for journey/stash reachability (same one FieldTooltipOverlay uses).
        private var _evaluator:FieldLogicEvaluator;
        // Per-icon hit rects (panel-local) + their detail html, rebuilt per stage.
        private var _hotspots:Array = [];
        // Detail text field below the checks row, updated each frame on hover.
        private var _hoverTf:TextField;
        // Currently displayed hover html, to avoid resetting it every frame.
        private var _hoverShown:String = "";
        // Y where the hover-detail text starts, and the current drawn frame height.
        private var _hoverY:Number = 0;
        private var _curPanelH:int = 0;

        public function IconTooltipPreview(evaluator:FieldLogicEvaluator) {
            super();
            _evaluator = evaluator;
            mouseEnabled  = false;
            mouseChildren = false;
            visible = false;
        }

        // -----------------------------------------------------------------------
        // Public API \u2014 driven from ArchipelagoMod's selector-frame loop.

        public function onSelectorFrame(mc:*):void {
            if (mc == null || GV.selectorCore == null) {
                hide();
                return;
            }

            // Only on the idle map screen. Clicking a level moves to
            // STAGES_TO_SETTINGS / SETTINGS_IDLE, which dismisses the tooltip.
            if (int(GV.selectorCore.screenStatus) != SelectorScreenStatus.STAGES_IDLE) {
                hide();
                return;
            }

            // While the cursor is over our panel, keep it up at the same anchored
            // spot \u2014 this is what lets the user move off the token onto the
            // tooltip and hover its icons. Checked first so a token sitting
            // behind the panel doesn't steal focus.
            if (_shownSid >= 0 && visible && isMouseOverPanel()) {
                ensureAttached();
                suppressVanilla();
                updateHover();
                return;
            }

            var tok:* = findHoveredToken(mc);
            if (tok == null) {
                hide();
                return;
            }

            // Suppress the vanilla tooltip the instant a field is hovered —
            // BEFORE building ours — so it never flashes, even if the build
            // throws or AP data isn't fully loaded yet.
            suppressVanilla();

            var sid:int = int(tok.id);
            if (sid != _shownSid) {
                try { buildFor(sid); } catch (eBuild:Error) {}
                _shownSid = sid;
                anchorNear(tok);   // pin the panel beside this token (static)
            }
            ensureAttached();
            updateHover();
        }

        public function hide():void {
            visible = false;
            _shownSid = -1; // force a fresh build + re-anchor on next hover
            // Restore the shared vanilla panel for every other tooltip
            // (skills, talismans, etc.) the moment we stop suppressing.
            if (_suppressed) {
                try { GV.mcInfoPanel.visible = true; } catch (e:Error) {}
                _suppressed = false;
            }
        }

        // -----------------------------------------------------------------------

        /** Suppress the vanilla field tooltip so ours replaces it. */
        private function suppressVanilla():void {
            _suppressed = true;
            try { GV.mcInfoPanel.visible = false; } catch (e:Error) {}
        }

        /**
         * Attach to main (NOT cntInfoPanel: the game gates the vanilla panel's
         * doEnterFrame on cntInfoPanel.numChildren > 0, so a child of ours there
         * makes it render its own unbuilt panel (w == 0) and crash with Error
         * #2015), keep on top, and place at the stored anchor. main is the
         * unzoomed 1920x1080 space, so scale 1 keeps a constant on-screen size.
         */
        private function ensureAttached():void {
            try {
                var layer:* = GV.main;
                if (layer != null) {
                    if (this.parent != layer) {
                        layer.addChild(this);
                    } else {
                        layer.setChildIndex(this, layer.numChildren - 1);
                    }
                }
                this.scaleX = this.scaleY = 1;
                this.x = _anchorX;
                this.y = _anchorY;
                visible = true;
            } catch (e:Error) {}
        }

        /** Pin the panel beside the given token (in main space), clamped on-screen. */
        private function anchorNear(tok:*):void {
            try {
                var b:Rectangle = tok.getBounds(GV.main);
                var ax:Number = b.right + ANCHOR_GAP;
                if (ax + PANEL_W > 1910) {
                    ax = b.left - ANCHOR_GAP - PANEL_W; // flip to the left side
                }
                ax = Math.max(5, Math.min(ax, 1920 - PANEL_W - 10));

                var ay:Number = b.top + b.height * 0.5 - PANEL_H * 0.5;
                ay = Math.max(10, Math.min(ay, 1080 - PANEL_H - 10));

                _anchorX = ax;
                _anchorY = ay;
            } catch (e:Error) {
                _anchorX = 80;
                _anchorY = 170;
            }
        }

        /** Is the cursor within the panel's rect (plus a small bridging margin)? */
        private function isMouseOverPanel():Boolean {
            try {
                var mx:Number = Number(GV.main.mouseX);
                var my:Number = Number(GV.main.mouseY);
                return mx >= _anchorX - HOVER_MARGIN && mx <= _anchorX + PANEL_W + HOVER_MARGIN
                    && my >= _anchorY - HOVER_MARGIN && my <= _anchorY + PANEL_H + HOVER_MARGIN;
            } catch (e:Error) {}
            return false;
        }

        /** Hit-test the field-token container; return the hovered token or null. */
        private function findHoveredToken(mc:*):* {
            var cnt:* = mc.cntFieldTokens;
            if (cnt == null) return null;
            try {
                var mx:Number = cnt.mouseX;
                var my:Number = cnt.mouseY;
                for (var i:int = 0; i < cnt.numChildren; i++) {
                    var tok:* = cnt.getChildAt(i);
                    if (tok == null) continue;
                    var b:Rectangle = tok.getBounds(cnt);
                    if (b != null && mx >= b.left && mx <= b.right
                            && my >= b.top && my <= b.bottom) {
                        return tok;
                    }
                }
            } catch (e:Error) {}
            return null;
        }

        // -----------------------------------------------------------------------
        // Build content for a specific stage.

        private function buildFor(sid:int):void {
            removeChildren();
            // (Frame is added LAST, at the base height, so it sits behind the
            // content; updateHover() grows it downward to fit the hover text.)

            // Live stage data (Journey mode).
            var strId:String = "";
            var name:String = "Field ?";
            var waves:int = 0;
            var fhp:int = 0;
            try {
                strId = String(GV.stageCollection.stageMetas[sid].strId);
                name = "Field " + strId;
                var sd:* = GV.stageCollection.stageDatasJ[sid];
                waves = int(sd.monsterData.wavesNum);
                fhp   = int(sd.monsterData.hpFirstWave);
            } catch (e:Error) {}

            var cy:Number = 14;

            cy = addLine(name, COL_TITLE, 17, cy, 30);

            // Real minimap for this stage.
            var map:Sprite = makeMinimap(sid);
            map.x = (PANEL_W - MAP_DISP_W) * 0.5;
            map.y = cy;
            addChild(map);
            cy += MAP_DISP_H + 8;

            // Stage stats, vanilla-style.
            var waveWord:String = (waves == 1) ? " wave" : " waves";
            cy = addLine(waves + waveWord + "   \u00B7   first wave " + fhp + " HP",
                         COL_STAT, 12, cy, 26);

            cy = addLine("Checks", COL_LABEL, 12, cy, 24);

            // Journey (J) + Stash (S) state orbs + achievement-count box.
            // Colour: grey = checked, green = in logic, red = blocked.
            // An orb is omitted when that check doesn't exist on this stage.
            // Each icon's detail text shows in the hover area BELOW the row, so
            // showing/hiding it never shifts the icons.
            var items:Array = [];
            var htmls:Array = [];

            var showJ:Boolean = false, showS:Boolean = false;
            var jColor:uint = COL_GREY, sColor:uint = COL_GREY;
            var jHtml:String = "", sHtml:String = "";
            try {
                var base:int = (strId.length > 0) ? int(ConnectionManager.stageLocIds[strId]) : 0;
                if (base > 0) {
                    var missing:Object = AV.saveData.missingLocations;
                    var checked:Object = AV.saveData.checkedLocations;

                    // Journey + Stash orbs ALWAYS show for a real stage (the check
                    // exists). "Done" = checked, or no longer in missingLocations
                    // (beating a level drops it from missing but doesn't add it to
                    // the connect-time checked snapshot — so !missing means done).
                    // grey = done, green = in logic, red = blocked.
                    var jMiss:Boolean = missing[base] == true;
                    var jDone:Boolean = (checked[base] == true) || !jMiss;
                    var jIn:Boolean = jMiss && _evaluator != null
                            && _evaluator.stageHasInLogicMissing(strId, true, false);
                    showJ  = true;
                    jColor = jDone ? COL_GREY : (jIn ? COL_GREEN : COL_RED);
                    jHtml  = entryHtml("Journey", journeyBody(strId, jDone, jIn), jColor);

                    var sLoc:int = base + 399;
                    var sMiss:Boolean = missing[sLoc] == true;
                    var sDone:Boolean = (checked[sLoc] == true) || !sMiss;
                    var sIn:Boolean = sMiss && _evaluator != null
                            && _evaluator.stageHasInLogicMissing(strId, false, true);
                    showS  = true;
                    sColor = sDone ? COL_GREY : (sIn ? COL_GREEN : COL_RED);
                    sHtml  = entryHtml("Stash", stashBody(strId, sDone, sIn), sColor);
                }
            } catch (e:Error) {}

            if (showJ) { items.push(makeOrb(jColor, 30, "J")); htmls.push(jHtml); }
            if (showS) { items.push(makeOrb(sColor, 30, "S")); htmls.push(sHtml); }
            items.push(makeCountBox(COL_LABEL, 48, 30, "A:3"));
            htmls.push(achievementsHtml());

            addRow(items, cy, 24);

            // Record hotspots (panel-local rects) so updateHover() maps the
            // cursor to the right detail html.
            _hotspots = [];
            for (var hi:int = 0; hi < items.length; hi++) {
                var it:* = items[hi];
                _hotspots.push({ x: Number(it.x), y: Number(it.y),
                                 w: Number(it.width), h: Number(it.height),
                                 html: String(htmls[hi]) });
            }
            cy += 40;

            // Hover-detail text BELOW the checks. The frame grows downward to fit
            // it (top stays put), so it never shifts the icons above.
            _hoverY = cy;
            _hoverTf = makeHoverTf();
            _hoverTf.x = 12;
            _hoverTf.y = cy;
            _hoverTf.htmlText = "";
            _hoverShown = "";
            addChild(_hoverTf);

            // Frame last, behind everything, at the base (no-detail) height.
            _curPanelH = int(_hoverY + BOTTOM_PAD);
            addChildAt(buildFrameBitmap(PANEL_W, _curPanelH), 0);
        }

        /** Heading (bold) over a body line, both in the given state colour. */
        private function entryHtml(title:String, body:String, color:uint):String {
            var hex:String = toHex(color);
            return "<font color='" + hex + "'><b>" + esc(title) + "</b></font><br>"
                 + "<font color='" + hex + "'>" + esc(body) + "</font>";
        }

        /** uint colour -> "#rrggbb" for htmlText. */
        private function toHex(c:uint):String {
            var s:String = (c & 0xFFFFFF).toString(16);
            while (s.length < 6) s = "0" + s;
            return "#" + s;
        }

        /** Body line for the Journey check. WL gating: in logic once the
         *  player's wizard level reaches this stage's gate. */
        private function journeyBody(strId:String, done:Boolean, inLogic:Boolean):String {
            if (done) return "Completed";
            if (inLogic) return "In Logic";
            return wlNeededBody(strId);
        }

        /** Body line for the Stash check. Blocked either by the stage's WL/tier
         *  gate or by a missing Wizard Stash Key — distinguish the two so the
         *  line reads "Needs key (…)" rather than a generic "Blocked". */
        private function stashBody(strId:String, done:Boolean, inLogic:Boolean):String {
            if (done) return "Completed";
            if (inLogic) return "In Logic";
            // If the stage itself is clearable, the only remaining blocker is
            // the stash key — show the granularity-aware key label.
            if (_evaluator != null && _evaluator.canCompleteStage(strId))
                return _evaluator.getStashKeyLabel(strId);
            return wlNeededBody(strId);
        }

        /** "Needs Wizard Level N (you are M)" for an out-of-logic stage. */
        private function wlNeededBody(strId:String):String {
            var gate:int = stageGate(strId);
            if (gate <= 0) return "Blocked";
            var cur:int = (_evaluator != null) ? _evaluator.derivedWizardLevel() : 0;
            return "Needs Wizard Level " + gate + " (you are " + cur + ")";
        }

        /** Required wizard level for a stage, from shipped slot_data gates. */
        private function stageGate(strId:String):int {
            try {
                var opts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
                if (opts != null && opts.stageGates != null
                        && opts.stageGates[strId] !== undefined)
                    return int(opts.stageGates[strId]);
            } catch (e:Error) {}
            return 0;
        }

        /** Hardcoded placeholder achievement list (real data later). */
        private function achievementsHtml():String {
            var parts:Array = [
                entryHtml("Gemless Victory", "Beat the field without combining gems", COL_GREEN),
                entryHtml("Swift Conqueror", "Reach wave 10 in under 5 minutes", COL_GREEN),
                entryHtml("Giant Slayer",    "Kill 3 giants with a single beam", COL_GREEN)
            ];
            return parts.join("<br>");
        }

        /** Escape text for use inside htmlText. */
        private function esc(s:String):String {
            if (s == null) return "";
            return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
        }

        /** Per-frame: show the hovered icon's detail html, growing the frame to fit. */
        private function updateHover():void {
            if (_hoverTf == null) return;
            var lx:Number = Number(GV.main.mouseX) - _anchorX;
            var ly:Number = Number(GV.main.mouseY) - _anchorY;
            var html:String = "";
            for each (var h:Object in _hotspots) {
                if (lx >= h.x && lx <= h.x + h.w && ly >= h.y && ly <= h.y + h.h) {
                    html = String(h.html);
                    break;
                }
            }
            if (html == _hoverShown) return;
            _hoverShown = html;
            _hoverTf.htmlText = html;

            // Grow/shrink the frame downward to fit (top fixed).
            var bodyH:Number = (html.length == 0) ? 0 : _hoverTf.height;
            setPanelFrame(int(_hoverY + bodyH + BOTTOM_PAD));
        }

        /** Redraw the background frame at height h (cosmetic; hit-test uses PANEL_H). */
        private function setPanelFrame(h:int):void {
            if (h == _curPanelH || h <= 0) return;
            _curPanelH = h;
            try {
                if (numChildren > 0 && getChildAt(0) is Bitmap) {
                    var old:Bitmap = getChildAt(0) as Bitmap;
                    if (old.bitmapData != null) old.bitmapData.dispose();
                    removeChildAt(0);
                }
            } catch (e:Error) {}
            addChildAt(buildFrameBitmap(PANEL_W, h), 0);
        }

        // -----------------------------------------------------------------------
        // Layout helpers

        /** Add a centered text line at y; return the next y cursor. */
        private function addLine(text:String, color:uint, size:int,
                                 y:Number, advance:Number):Number {
            var tf:TextField = makeTf(size);
            tf.width = PANEL_W;
            tf.x = 0;
            tf.y = y;
            tf.text = text;
            tf.textColor = color;
            addChild(tf);
            return y + advance;
        }

        /** Centre a row of display objects horizontally at vertical pos y.
         *  Uses each item's own width so mixed-size items still center. */
        private function addRow(items:Array, y:Number, gap:Number):void {
            var total:Number = (items.length - 1) * gap;
            for (var k:int = 0; k < items.length; k++) {
                total += Number(items[k].width);
            }
            var cx:Number = (PANEL_W - total) * 0.5;
            for (var i:int = 0; i < items.length; i++) {
                var d:* = items[i];
                d.x = cx;
                d.y = y;
                addChild(d);
                cx += Number(d.width) + gap;
            }
        }

        private function makeTf(size:int):TextField {
            var fmt:TextFormat = new TextFormat(FONT, size);
            fmt.align = TextFormatAlign.CENTER;
            fmt.bold  = true;

            var tf:TextField = new TextField();
            tf.mouseEnabled      = false;
            tf.selectable        = false;
            tf.embedFonts        = false;
            tf.antiAliasType     = AntiAliasType.ADVANCED;
            tf.defaultTextFormat = fmt;
            tf.multiline         = false;
            tf.wordWrap          = false;
            tf.autoSize          = TextFieldAutoSize.NONE;
            return tf;
        }

        /** Multiline centered field for the hover-detail area below the checks. */
        private function makeHoverTf():TextField {
            var fmt:TextFormat = new TextFormat(FONT, 12);
            fmt.align = TextFormatAlign.CENTER;
            fmt.bold  = false;

            var tf:TextField = new TextField();
            tf.mouseEnabled      = false;
            tf.selectable        = false;
            tf.embedFonts        = false;
            tf.antiAliasType     = AntiAliasType.ADVANCED;
            tf.defaultTextFormat = fmt;
            tf.multiline         = true;
            tf.wordWrap          = true;
            tf.width             = PANEL_W - 24;
            tf.autoSize          = TextFieldAutoSize.LEFT; // fixed width, height grows down
            tf.textColor         = COL_STAT;
            return tf;
        }

        /** A coloured circle with a small centered glyph. */
        private function makeOrb(color:uint, size:int, glyph:String):Sprite {
            var s:Sprite = new Sprite();
            var g:Shape = new Shape();
            g.graphics.lineStyle(2, color, 1);
            g.graphics.beginFill(0x000000, 0.35);
            g.graphics.drawCircle(size * 0.5, size * 0.5, size * 0.5 - 1);
            g.graphics.endFill();
            s.addChild(g);

            var tf:TextField = makeTf(15);
            tf.width = size;
            tf.height = size;
            tf.x = 0;
            tf.y = (size - 24) * 0.5;
            tf.text = glyph;
            tf.textColor = color;
            s.addChild(tf);
            return s;
        }

        /** A rounded tag holding a label like "A:3" \u2014 obtainable achievements. */
        private function makeCountBox(color:uint, w:int, h:int, label:String):Sprite {
            var s:Sprite = new Sprite();
            var g:Shape = new Shape();
            g.graphics.lineStyle(2, color, 1);
            g.graphics.beginFill(0x000000, 0.35);
            g.graphics.drawRoundRect(1, 1, w - 2, h - 2, 8, 8);
            g.graphics.endFill();
            s.addChild(g);

            var tf:TextField = makeTf(15);
            tf.width = w;
            tf.height = h;
            tf.x = 0;
            tf.y = (h - 24) * 0.5;
            tf.text = label;
            tf.textColor = color;
            s.addChild(tf);
            return s;
        }

        /** Real stage minimap, scaled; falls back to a framed placeholder. */
        private function makeMinimap(sid:int):Sprite {
            var s:Sprite = new Sprite();
            try {
                var bmp:Bitmap = GV.selectorCore.renderer.renderFieldMinimap(sid) as Bitmap;
                if (bmp != null) {
                    bmp.smoothing = true;
                    bmp.scaleX = bmp.scaleY = MAP_SCALE;
                    bmp.x = 0;
                    bmp.y = 0;
                    s.addChild(bmp);
                    return s;
                }
            } catch (e:Error) {}
            return makeMapPlaceholder(MAP_DISP_W, MAP_DISP_H);
        }

        /** Placeholder minimap thumbnail used if the real render fails. */
        private function makeMapPlaceholder(w:int, h:int):Sprite {
            var s:Sprite = new Sprite();
            var g:Shape = new Shape();
            g.graphics.lineStyle(1, COL_MUTED, 0.8);
            g.graphics.beginFill(0x1A1407, 0.85);
            g.graphics.drawRect(0, 0, w, h);
            g.graphics.endFill();
            s.addChild(g);

            var tf:TextField = makeTf(11);
            tf.width = w;
            tf.height = h;
            tf.x = 0;
            tf.y = (h - 18) * 0.5;
            tf.text = "map";
            tf.textColor = COL_MUTED;
            s.addChild(tf);
            return s;
        }

        // -----------------------------------------------------------------------
        // Vanilla frame reconstruction (mirrors McInfoPanel)

        private function buildFrameBitmap(w:int, h:int):Bitmap {
            var plate:BitmapData = new BitmapData(w, h, true, PLATE_COLOR);
            try {
                var blackTop:BitmapData  = new BmpdInfoPanelFrameBlack(0, 0); // 400x60
                var paperTop:BitmapData  = new BmpdInfoPanelFramePaper(0, 0); // 400x5
                var cornerTL:BitmapData  = new BmpdInfoPanelCornerPaper(0, 0); // 5x5

                var m:Matrix = new Matrix();
                m.translate(-blackTop.width / 2, -blackTop.height / 2);
                m.rotate(Math.PI);
                m.translate(blackTop.width / 2, blackTop.height / 2);
                var blackBottom:BitmapData = new BitmapData(400, 60, true, 0);
                blackBottom.draw(blackTop, m);

                m = new Matrix();
                m.translate(-200, -2.5);
                m.rotate(Math.PI / 2);
                m.translate(2.5, 200);
                var paperRight:BitmapData = new BitmapData(5, 400, true, 0);
                paperRight.draw(paperTop, m);
                m.translate(-2.5, -200);
                m.rotate(Math.PI / 2);
                m.translate(200, 2.5);
                var paperBottom:BitmapData = new BitmapData(400, 5, true, 0);
                paperBottom.draw(paperTop, m);
                m.translate(-200, -2.5);
                m.rotate(Math.PI / 2);
                m.translate(2.5, 200);
                var paperLeft:BitmapData = new BitmapData(5, 400, true, 0);
                paperLeft.draw(paperTop, m);

                m = new Matrix();
                m.translate(-2.5, -2.5);
                m.rotate(Math.PI / 2);
                m.translate(2.5, 2.5);
                var cornerTR:BitmapData = new BitmapData(5, 5, true, 0);
                cornerTR.draw(cornerTL, m);
                m.translate(-2.5, -2.5);
                m.rotate(Math.PI / 2);
                m.translate(2.5, 2.5);
                var cornerBR:BitmapData = new BitmapData(5, 5, true, 0);
                cornerBR.draw(cornerTL, m);
                m.translate(-2.5, -2.5);
                m.rotate(Math.PI / 2);
                m.translate(2.5, 2.5);
                var cornerBL:BitmapData = new BitmapData(5, 5, true, 0);
                cornerBL.draw(cornerTL, m);

                var r40060:Rectangle = new Rectangle(0, 0, 400, 60);
                var r4005:Rectangle  = new Rectangle(0, 0, 400, 5);
                var r5400:Rectangle  = new Rectangle(0, 0, 5, 400);
                var r55:Rectangle    = new Rectangle(0, 0, 5, 5);

                var vPos:int = 0;
                while (vPos < w) {
                    plate.copyPixels(blackTop,    r40060, new Point(vPos, 5),      null, null, true);
                    plate.copyPixels(blackBottom, r40060, new Point(vPos, h - 65), null, null, true);
                    plate.copyPixels(paperTop,    r4005,  new Point(vPos, 0));
                    plate.copyPixels(paperBottom, r4005,  new Point(vPos, h - 5));
                    vPos += 400;
                }
                vPos = 0;
                while (vPos < h) {
                    plate.copyPixels(paperLeft,  r5400, new Point(0,     vPos));
                    plate.copyPixels(paperRight, r5400, new Point(w - 5, vPos));
                    vPos += 400;
                }
                plate.copyPixels(cornerTL, r55, new Point(0,     0));
                plate.copyPixels(cornerTR, r55, new Point(w - 5, 0));
                plate.copyPixels(cornerBL, r55, new Point(0,     h - 5));
                plate.copyPixels(cornerBR, r55, new Point(w - 5, h - 5));
            } catch (e:Error) {
                // If the frame assets aren't reachable, the plain plate still shows.
            }
            return new Bitmap(plate);
        }
    }
}
