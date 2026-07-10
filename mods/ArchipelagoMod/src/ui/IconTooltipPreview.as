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

    import flash.filters.ColorMatrixFilter;

    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.bmpd.BmpdInfoPanelCornerPaper;
    import com.giab.games.gcfw.bmpd.BmpdInfoPanelFrameBlack;
    import com.giab.games.gcfw.bmpd.BmpdInfoPanelFramePaper;
    import com.giab.games.gcfw.constants.SelectorScreenStatus;
    import com.giab.games.gcfw.constants.GemComponentType;
    import com.giab.games.gcfw.entity.Gem;

    import data.AV;
    import net.ConnectionManager;
    import tracker.FieldLogicEvaluator;
    import tracker.AchievementLogicEvaluator;

    /**
     * PREVIEW of the proposed icon-based field tooltip \u2014 the panel intended to
     * eventually replace the vanilla field hover tooltip.
     *
     * Content is LIVE for whichever field token the cursor is over:
     *   - stage name, wave count, first-wave HP  (from GV.stageCollection)
     *   - the real minimap                       (SelectorRenderer.renderFieldMinimap)
     *   - Journey/Stash check orbs               (grey done / green in logic / red blocked)
     *   - the achievement count + list           (AchievementLogicEvaluator.getFieldAchievements)
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
        // The McFieldToken the panel is showing for. Kept force-highlighted while
        // the panel is up (moving the cursor onto the panel fires the token's
        // MOUSE_OUT, so the game would otherwise drop the highlight), and
        // restored to its base frame on hide / when switching to another field.
        private var _shownTok:* = null;
        // Static anchor position (main space) the panel is pinned to.
        private var _anchorX:Number = 80;
        private var _anchorY:Number = 170;
        // True while we're forcing the vanilla info panel hidden.
        private var _suppressed:Boolean = false;
        // Logic source for journey/stash reachability (same one FieldTooltipOverlay uses).
        private var _evaluator:FieldLogicEvaluator;
        // Achievement logic — supplies the per-field "doable here" achievement
        // block (specific + global split). May be null before AP connect.
        private var _achEval:AchievementLogicEvaluator;
        // Per-icon hit rects (panel-local) + their detail html, rebuilt per stage.
        private var _hotspots:Array = [];
        // Detail text field below the checks row, updated each frame on hover.
        private var _hoverTf:TextField;
        // Currently displayed hover html, to avoid resetting it every frame.
        private var _hoverShown:String = "";
        // Y where the hover-detail text starts, and the current drawn frame height.
        private var _hoverY:Number = 0;
        private var _curPanelH:int = 0;

        public function IconTooltipPreview(evaluator:FieldLogicEvaluator,
                                           achEval:AchievementLogicEvaluator) {
            super();
            _evaluator = evaluator;
            _achEval   = achEval;
            // Block mouse events over the panel so they DON'T pass through to the
            // field tokens underneath. A mouse-transparent panel lets the token
            // beneath the cursor fire its MOUSE_OVER, lighting up the wrong field
            // (e.g. S1) while the cursor is actually on the W4 tooltip.
            // mouseChildren stays false — icon hover is position-based
            // (updateHover), not event-driven, so children never need events.
            mouseEnabled  = true;
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

            // Only on the map screen. STAGES_IDLE is the resting map;
            // UPDATING_STAGES is the post-battle XP tally / token-appear
            // animation, during which the map is still shown and its fields
            // are hoverable — without it here the tooltip would hide for the
            // whole tally and the player would see the vanilla ("old")
            // tooltip until the animation finished. Every OTHER non-idle
            // status is a transition off the map (STAGES_TO_SETTINGS,
            // SETTINGS_IDLE, skills/talisman/etc.) and must still dismiss it.
            var ss:int = int(GV.selectorCore.screenStatus);
            var onMap:Boolean = (ss == SelectorScreenStatus.STAGES_IDLE
                    || ss == SelectorScreenStatus.UPDATING_STAGES);

            // What the cursor is over (panel checked first so a token sitting
            // behind it doesn't steal focus). Both are cheap geometry hit-tests,
            // valid in any selector state.
            var overPanel:Boolean = (_shownSid >= 0 && visible && isMouseOverPanel());
            var tok:* = overPanel ? _shownTok : findHoveredToken(mc);
            var overField:Boolean = (tok != null);

            // HARD BLOCK on the vanilla field hover tooltip: it must never be
            // seen, our panel replaces it. We can't drop the game's field
            // MOUSE_OVER listener because that render also sets
            // hasMetReqsToEnterField (the click-to-enter gate in
            // SelectorInputHandler.ehStageIconClicked), so instead we force
            // GV.mcInfoPanel hidden every frame the cursor is over a field token
            // or our panel, in ANY selector state (so a field hovered mid-
            // transition can't flash it either). When over neither, release it
            // so the other tooltips sharing mcInfoPanel (shadow-core counter,
            // skills, talismans) can still show.
            if (overField || overPanel) {
                suppressVanilla();
            } else if (_suppressed) {
                try { GV.mcInfoPanel.visible = true; } catch (eV:Error) {}
                _suppressed = false;
            }

            // Our replacement panel only builds on the map, over a field/panel.
            if (!onMap || !overField) {
                hidePanelOnly();
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
                highlightToken(_shownTok, true); // keep the tooltip's field lit
                return;
            }

            // Suppress the vanilla tooltip the instant a field is hovered —
            // BEFORE building ours — so it never flashes, even if the build
            // throws or AP data isn't fully loaded yet.
            suppressVanilla();

            var sid:int = int(tok.id);
            if (sid != _shownSid) {
                highlightToken(_shownTok, false); // release the previous field
                _shownTok = tok;
                try { buildFor(sid); } catch (eBuild:Error) {}
                _shownSid = sid;
                anchorNear(tok);   // pin the panel beside this token (static)
            }
            ensureAttached();
            updateHover();
            highlightToken(_shownTok, true); // keep the hovered field lit
        }

        /** Hide our replacement panel and drop the field highlight, WITHOUT
         *  touching the vanilla panel's visibility. onSelectorFrame manages that
         *  centrally so the vanilla field tooltip stays blocked even in states
         *  where we don't show our own panel. */
        private function hidePanelOnly():void {
            visible = false;
            _shownSid = -1; // force a fresh build + re-anchor on next hover
            highlightToken(_shownTok, false); // let the field drop its highlight
            _shownTok = null;
        }

        public function hide():void {
            hidePanelOnly();
            // Restore the shared vanilla panel for every other tooltip
            // (skills, talismans, etc.) the moment we stop suppressing.
            if (_suppressed) {
                try { GV.mcInfoPanel.visible = true; } catch (e:Error) {}
                _suppressed = false;
            }
        }

        /** Force a field token's plate to its highlighted (on) or base (off)
         *  frame — mirrors the game's own ehStageIconOver / ehStageIconOut
         *  (SelectorInputHandler), which set plate frame plateFrame+1 / plateFrame.
         *  We drive it ourselves so the tooltip's field stays lit while the cursor
         *  is on the panel (the token's own MOUSE_OUT would otherwise clear it). */
        private function highlightToken(tok:*, on:Boolean):void {
            if (tok == null) return;
            try { tok.plate.gotoAndStop(int(tok.plateFrame) + (on ? 1 : 0)); }
            catch (e:Error) {}
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

                var ph:Number = (_curPanelH > 0) ? _curPanelH : PANEL_H;
                var ay:Number = b.top + b.height * 0.5 - ph * 0.5;
                ay = Math.max(10, Math.min(ay, 1080 - ph - 10));

                _anchorX = ax;
                _anchorY = ay;
            } catch (e:Error) {
                _anchorX = 80;
                _anchorY = 170;
            }
        }

        /** Is the cursor within the panel's rect (plus a small bridging margin)?
         *  Uses the ACTUAL drawn height (_curPanelH), not the PANEL_H maximum, so
         *  fields just below a short panel aren't wrongly treated as "over panel"
         *  (which kept the tooltip stuck on the previous field). */
        private function isMouseOverPanel():Boolean {
            try {
                var ph:Number = (_curPanelH > 0) ? _curPanelH : PANEL_H;
                var mx:Number = Number(GV.main.mouseX);
                var my:Number = Number(GV.main.mouseY);
                return mx >= _anchorX - HOVER_MARGIN && mx <= _anchorX + PANEL_W + HOVER_MARGIN
                    && my >= _anchorY - HOVER_MARGIN && my <= _anchorY + ph + HOVER_MARGIN;
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

            // XP / WL debug (tester slots only): the field's expected eff-XP
            // (what it feeds the WL derivation), the XP actually collected on it
            // in Journey + the current trait multiplier, and derived-WL vs gate.
            if (_isTesterSlot()) {
                var opts:* = (AV.serverData != null) ? AV.serverData.serverOptions : null;
                var effXp:* = (opts != null && opts.wlEffXp != null) ? opts.wlEffXp[strId] : null;
                var collected:int = 0;
                try { collected = int(GV.ppd.stageHighestXpsJourney[sid].g()); } catch (eXp:Error) {}
                var wl:int = (_evaluator != null) ? _evaluator.derivedWizardLevel() : 0;
                var gate:int = stageGate(strId);
                cy = addLine("Field XP: " + (effXp != null ? String(int(effXp)) : "?")
                           + "   \u00B7   WL " + wl + " / gate " + gate,
                           COL_MUTED, 11, cy, 20);
                cy = addLine("Journey XP: " + collected + " (x" + _fmtMult(_xpTraitMult()) + ")",
                           COL_MUTED, 11, cy, 24);
            }

            // Available gems on this field (pouch-aware; hollow gem on a
            // free starter without a pouch).
            cy = addGems(sid, strId, cy);

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

            // Achievement count box ("A:N") + its hover list. N = achievements
            // obtainable by playing THIS field (specific + globals). Colour:
            // grey when none, green when the field is clearable, red when it
            // isn't (globals still listed, but you can't earn them here yet).
            var fa:Object = (_achEval != null) ? _achEval.getFieldAchievements(strId) : null;
            var spec:Array = (fa != null) ? (fa.specific as Array) : [];
            var glob:Array = (fa != null) ? (fa.global as Array) : [];
            var achTotal:int = spec.length + glob.length;
            var clearable:Boolean = (_evaluator != null) && _evaluator.canCompleteStage(strId);
            var aColor:uint = (achTotal == 0) ? COL_GREY : (clearable ? COL_GREEN : COL_RED);
            var aLabel:String = "A:" + achTotal;
            items.push(makeCountBox(aColor, 24 + aLabel.length * 8, 30, aLabel));
            htmls.push(achievementsHtml(spec, glob, clearable, achTotal));

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

        /** Out-of-logic field: tell the player to raise XP/WL, without a
         *  number. The derived-WL gate is not the same as the wizard level
         *  the player sees in-game (derived WL is a function of fields cleared,
         *  not real earned XP), so "Needs Wizard Level N" reads as wrong to the
         *  player — a vague "get more XP" is the honest cue. A hovered field
         *  always holds its own token (you can't hover a field without its
         *  tile), so the only remaining blocker here is the WL soft-gate.
         *  (Testers still see the exact gate in the XP/WL debug lines.) */
        private function wlNeededBody(strId:String):String {
            var gate:int = stageGate(strId);
            if (gate <= 0)
                return "Blocked";
            return "Requires higher XP/WL";
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

        /** Tester-only gate for the XP/WL debug lines (mirrors the old
         *  FieldTooltipOverlay._debugWlLines gate). */
        private function _isTesterSlot():Boolean {
            return AV.currentSlot != null
                && AV.currentSlot.toLowerCase().indexOf("levisaxos") == 0;
        }

        /** The battle-XP multiplier the game actually applies to earned XP:
         *  difficulty base + Σ(0.1 × selected trait level), as maintained by
         *  DifficultyXpScaler on GV.selectorCore.traitsXpMult. Reading it here
         *  keeps the tooltip in lockstep with the outcome screen. */
        private function _xpTraitMult():Number {
            try {
                if (GV.selectorCore != null && GV.selectorCore.traitsXpMult != null)
                    return Number(GV.selectorCore.traitsXpMult.g());
            } catch (e:Error) {}
            return 1.0;
        }

        /** Format a multiplier like 1.2 / 1.44 (trim to <=3 decimals, no trailing zeros). */
        private function _fmtMult(m:Number):String {
            var r:Number = Math.round(m * 1000) / 1000;
            var s:String = String(r);
            return s;
        }

        /** "Available gems" section. Shows the stage's gem colours when the
         *  player can create them (a pouch is held, or pouch gating is off), a
         *  single desaturated hollow gem on a free starter with no pouch yet, or
         *  nothing on a non-free stage without a pouch. Mirrors SelectorRenderer's
         *  gem rendering + the old FieldTooltipOverlay hollow-gem behaviour. */
        private function addGems(sid:int, strId:String, y:Number):Number {
            var pouchMode:int = 0;
            try {
                var opts:* = (AV.serverData != null) ? AV.serverData.serverOptions : null;
                if (opts != null) pouchMode = int(opts.gemPouchGranularity);
            } catch (eP:Error) {}
            var hasPouch:Boolean = (pouchMode == 0)
                    || (AV.sessionData != null && AV.sessionData.hasPouchForStage(strId));
            var isFree:Boolean = (_evaluator != null) && _evaluator.isFreeStage(strId);

            var types:Array = null;
            var desat:Boolean = false;
            if (hasPouch) {
                try { types = GV.stageCollection.stageDatasJ[sid].getAvailableGemTypes(); }
                catch (eG:Error) { types = null; }
            } else if (isFree) {
                types = [GemComponentType.MANA_LEECHING]; // colourless Hollow Gem
                desat = true;
            }
            if (types == null || types.length == 0)
                return y; // non-free stage with no pouch → nothing to build with

            y = addLine("Available gems:", COL_LABEL, 11, y, 20);

            // Build the gem icons, then lay them out in a centred row.
            var mcs:Array = [];
            var totalW:Number = 0;
            var gap:Number = 6;
            for each (var t:* in types) {
                var gem:Gem = new Gem();
                gem.elderComponents = [t];
                gem.manaValuesByComponent[t].s(1);
                GV.gemBitmapCreator.giveGemBitmaps(gem, false);
                if (desat) {
                    gem.hasColor = false;
                    gem.hueMain  = 0;
                    _desatGem(gem.mc);
                }
                mcs.push(gem.mc);
                totalW += Number(gem.mc.width) + gap;
            }
            if (mcs.length > 0) totalW -= gap;

            // giveGemBitmaps centres the icon on its origin, so offset by each
            // gem's own bounds to place its visual top-left where we want (below
            // the label, not overlapping it).
            var cx:Number = (PANEL_W - totalW) * 0.5;
            var maxH:Number = 0;
            for each (var mc:* in mcs) {
                var gb:Rectangle = mc.getBounds(mc);
                mc.x = cx - gb.left;
                mc.y = y - gb.top;
                addChild(mc);
                cx += Number(mc.width) + gap;
                if (gb.height > maxH) maxH = gb.height;
            }
            return y + maxH + 8;
        }

        /** Luminance-preserving desaturate of a Gem MC's bitmap children (the
         *  colourless Hollow-Gem look), matching HollowGemInjector. */
        private function _desatGem(mc:*):void {
            try {
                var f:ColorMatrixFilter = new ColorMatrixFilter([
                    0.299, 0.587, 0.114, 0, 60,
                    0.299, 0.587, 0.114, 0, 60,
                    0.299, 0.587, 0.114, 0, 60,
                    0,     0,     0,     1, 0]);
                var n:int = int(mc.numChildren);
                for (var i:int = 0; i < n; i++) {
                    var ch:* = mc.getChildAt(i);
                    if (ch is Bitmap) (ch as Bitmap).filters = [f];
                }
            } catch (e:Error) {}
        }

        /**
         * Hover list for the "A:N" box. Shows up to 3 achievements doable on
         * this field (name heading + description body), then an "And x more"
         * line covering the overflow and every global. Field-specific
         * achievements lead; only when there are none do we fall back to
         * showing globals. Entry colour is green on a clearable field, red on
         * one that isn't yet (you can't earn them here). Completed achievements
         * are already excluded upstream, so never appear.
         */
        private function achievementsHtml(spec:Array, glob:Array,
                                          clearable:Boolean, total:int):String {
            if (total <= 0)
                return "<font color='" + toHex(COL_MUTED) + "'>No achievements available here</font>";
            var entryColor:uint = clearable ? COL_GREEN : COL_RED;
            var shown:Array = (spec.length > 0) ? spec : glob;
            var shownCount:int = Math.min(3, shown.length);
            var parts:Array = [];
            for (var i:int = 0; i < shownCount; i++) {
                var a:Object = shown[i];
                var desc:String = (a.description != null) ? String(a.description) : "";
                parts.push(entryHtml(String(a.name), desc, entryColor));
            }
            var more:int = total - shownCount;
            if (more > 0)
                parts.push("<font color='" + toHex(COL_MUTED) + "'>And " + more + " more</font>");
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
