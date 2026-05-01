package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import flash.display.Bitmap;
    import flash.geom.Rectangle;

    import data.AV;
    import net.ConnectionManager;
    import tracker.FieldLogicEvaluator;

    /**
     * Appends Archipelago check-status lines into the game's field hover tooltip
     * (McInfoPanel) using the same intercept pattern as AchievementTooltipOverlay.
     *
     * Shows per-check status for Journey and Stash locations as
     * one line each:
     *   ✓  grey  — already checked
     *   in logic     green — missing and reachable
     *   not in logic red   — missing and blocked
     * Also lists each element / special-monster spawn on its own colour-coded
     * line (green = in logic, red = not yet reachable), and stage skill /
     * tier prerequisites colour-coded the same way.
     *
     * Also removes the "Available gems" section for levels that are not W1-W4,
     * since those gems reflect the original game state rather than the
     * randomised AP state.
     */
    public class FieldTooltipOverlay {

        private static const ACHIEVEMENTS_IDLE_STAGES:int   = 305;
        private static const ACHIEVEMENTS_IDLE_SETTINGS:int = 306;

        // Gem section extra height added by SelectorRenderer after the gem icons.
        private static const GEMS_EXTRA_HEIGHT:int = 46;

        private var _logger:Logger;
        private var _modName:String;
        private var _evaluator:FieldLogicEvaluator;

        // True after we've appended our lines to the current tooltip.
        // Cleared when isImageRendered goes false (game reset or panel closed),
        // which signals a new tooltip is starting.
        private var _appended:Boolean = false;

        // -----------------------------------------------------------------------

        public function FieldTooltipOverlay(logger:Logger, modName:String,
                                            evaluator:FieldLogicEvaluator) {
            _logger    = logger;
            _modName   = modName;
            _evaluator = evaluator;
        }

        // -----------------------------------------------------------------------

        /**
         * Called every selector frame from ArchipelagoMod.onSelectorFrame().
         * mc is GV.selectorCore.mc.
         */
        public function onSelectorFrame(mc:*):void {
            if (mc == null || GV.mcInfoPanel == null) return;

            // Skip while the achievements panel is open — its own overlay handles that.
            if (GV.selectorCore != null) {
                var status:int = int(GV.selectorCore.screenStatus);
                if (status == ACHIEVEMENTS_IDLE_STAGES ||
                        status == ACHIEVEMENTS_IDLE_SETTINGS) return;
            }

            var vIp:* = GV.mcInfoPanel;

            // When the panel is hidden or the game resets it (isImageRendered=false),
            // clear our flag so we'll re-append for the next tooltip.
            if (vIp.parent == null || !vIp.isImageRendered) {
                _appended = false;
                return;
            }
            if (_appended) return;

            var hoveredTok:* = _findHoveredToken(mc);
            if (hoveredTok == null) return;

            // Resolve strId from the token index.
            var sid:int = int(hoveredTok.id);
            var metas:Array = (GV.stageCollection != null)
                    ? GV.stageCollection.stageMetas : null;
            if (metas == null || sid < 0 || sid >= metas.length) return;
            var meta:* = metas[sid];
            if (meta == null) return;
            var strId:String = String(meta.strId);

            // W1-W4 are the free stages whose gem lists match the AP state.
            // All other levels should have the "Available gems" section hidden.
            var isFreestage:Boolean = (strId == "W1" || strId == "W2" ||
                                       strId == "W3" || strId == "W4");
            var shouldRemoveGems:Boolean = !isFreestage;

            var base:int = int(ConnectionManager.stageLocIds[strId]);
            var shouldAddApOverlay:Boolean = base > 0;

            // Nothing for us to do on this tooltip.
            if (!shouldRemoveGems && !shouldAddApOverlay) {
                _appended = true;
                return;
            }

            // Dispose game's bitmap so doEnterFrame() re-renders.
            try {
                var oldBmp:Bitmap = vIp.bmp as Bitmap;
                if (oldBmp != null && oldBmp.bitmapData != null) {
                    oldBmp.bitmapData.dispose();
                }
                vIp.bmp = null;
                vIp.isImageRendered = false;
            } catch (e:Error) {
                _logger.log(_modName, "FieldTooltipOverlay: bitmap dispose error: " + e.message);
                return;
            }

            // For non-tutorial stages, remove gem icons from the panel.
            // Two complementary approaches — whichever applies to McInfoPanel's internals:
            //   1. Filter the internal render list to remove gem entries (and the "Available
            //      gems:" label). Textfield entries have a "text" property; image/preview
            //      entries have a "bitmapData"/"bitmap"/"image" property. Entries with none
            //      of these are gem icon entries and are removed.
            //   2. Hide any non-Bitmap display children (gem icons added as addChild).
            if (!_evaluator.isFreeStage(strId)) {
                _tryRemoveGemEntries(vIp);
                for (var ci:int = 0; ci < vIp.numChildren; ci++) {
                    var ch:* = vIp.getChildAt(ci);
                    if (ch == null || ch is Bitmap) continue;
                    try { ch.visible = false; } catch (he:Error) {}
                }
            }

            // drawBitmap() multiplied vIp.w by projectorZoom in-place during the first
            // render.  Undo that before addTextfield() so text positions aren't double-zoomed.
            try {
                var zoom:Number = Number(GV.projectorZoom);
                if (zoom > 0) vIp.w = vIp.w / zoom;
            } catch (e2:Error) {}

            // Strip the "Available gems" section from the panel data for non-W1-W4 levels.
            if (shouldRemoveGems) {
                _removeAvailableGems(vIp);
            }

            // Append AP check-status lines.
            if (shouldAddApOverlay) {
                var missing:Object = AV.saveData.missingLocations;
                var checked:Object = AV.saveData.checkedLocations;

                var journeyMissing:Boolean = missing[base]       == true;
                var journeyDone:Boolean    = checked[base]       == true;

                var stashId:int            = base + 399;
                var stashMissing:Boolean   = missing[stashId]    == true;
                var stashDone:Boolean      = checked[stashId]    == true;

                var lines:Array = _buildLines(strId,
                        journeyMissing, journeyDone,
                        stashMissing,   stashDone);

                try {
                    vIp.addExtraHeight(7);
                    vIp.addSeparator(-2);
                    for each (var pair:Array in lines) {
                        vIp.addTextfield(uint(pair[1]), String(pair[0]), false, 10);
                    }
                } catch (e3:Error) {
                    _logger.log(_modName, "FieldTooltipOverlay: addTextfield error: " + e3.message);
                    return;
                }
            }

            _appended = true;
            try {
                vIp.doEnterFrame();
            } catch (e4:Error) {
                _logger.log(_modName, "FieldTooltipOverlay: doEnterFrame error: " + e4.message);
            }
        }

        // -----------------------------------------------------------------------

        /**
         * Removes the "Available gems:" title textfield and gem sprite entries from
         * McInfoPanel's internal arrays, then adjusts nextTfPos / h so the content
         * that followed the gems section closes the gap.
         */
        private function _removeAvailableGems(vIp:*):void {
            try {
                var textfields:Array = vIp.textfields as Array;
                if (textfields == null) return;

                // Locate the "Available gems:" textfield.
                var gemsIdx:int = -1;
                var gemsTf:*    = null;
                for (var i:int = 0; i < textfields.length; i++) {
                    var tf:* = textfields[i];
                    if (tf != null && tf.text == "Available gems:") {
                        gemsIdx = i;
                        gemsTf  = tf;
                        break;
                    }
                }
                if (gemsIdx < 0) return; // not found — nothing to do

                // Height occupied by the gems section:
                //   textfield height + 9 px leading (from addTextfield with pSmallLeading=false)
                //   + 46 px from addExtraHeight(46) that follows the gem icons.
                var removeHeight:Number = gemsTf.height + 9 + GEMS_EXTRA_HEIGHT;

                // Remove the "Available gems:" textfield.
                textfields.splice(gemsIdx, 1);

                // Shift every textfield that came after the gems section upward.
                for (var j:int = gemsIdx; j < textfields.length; j++) {
                    textfields[j].y -= removeHeight;
                }

                // Remove gem sprite entries from attachedMcs.
                // The minimap bitmap is a Bitmap instance; gem MCs are not — filter them out.
                var newMcs:Array = [];
                for each (var mc:* in (vIp.attachedMcs as Array)) {
                    if (mc is Bitmap) newMcs.push(mc);
                }
                vIp.attachedMcs = newMcs;

                // Close the vertical gap.
                vIp.nextTfPos -= removeHeight;
                vIp.h         -= removeHeight;
            } catch (e:Error) {
                _logger.log(_modName, "FieldTooltipOverlay: _removeAvailableGems error: " + e.message);
            }
        }

        // -----------------------------------------------------------------------

        private function _findHoveredToken(mc:*):* {
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

        private function _buildLines(strId:String,
                                     journeyMissing:Boolean, journeyDone:Boolean,
                                     stashMissing:Boolean,   stashDone:Boolean):Array {
            var lines:Array = [["Archipelago", 0xE5AD0A]];

            // One colour-coded line per element / monster on this stage.
            // Per-stage view: green iff THIS stage is completable (tier + WIZLOCK).
            // Monsters additionally require the Ritual Battle Trait.
            var stageReachable:Boolean = _evaluator.canCompleteStage(strId);
            var hasRitual:Boolean = AV.sessionData.hasItem(FieldLogicEvaluator.RITUAL_TRAIT_AP_ID);
            for each (var elem:String in _evaluator.getStageElements(strId)) {
                lines.push(_checkLine(elem, false, stageReachable));
            }
            for each (var mon:String in _evaluator.getStageMonsters(strId)) {
                lines.push(_checkLine(mon, false, stageReachable && hasRitual));
            }

            var journeyExists:Boolean  = journeyMissing || journeyDone;
            var stashExists:Boolean    = stashMissing   || stashDone;

            var journeyInLogic:Boolean = journeyMissing &&
                    _evaluator.stageHasInLogicMissing(strId, true, false);
            var stashUnlocked:Boolean  = AV.sessionData.isStashUnlocked(strId);
            var stashInLogic:Boolean   = stashMissing && stashUnlocked &&
                    _evaluator.stageHasInLogicMissing(strId, false, true);

            // One line per check, each coloured by its state.
            if (journeyExists) lines.push(_checkLine("Journey", journeyDone, journeyInLogic));
            if (stashExists) {
                if (stashDone) {
                    lines.push(["Stash: ✓", 0x888888]);
                } else if (!stashUnlocked) {
                    lines.push(["Stash: locked", 0xFF4444]);
                } else {
                    lines.push(_checkLine("Stash", false, stashInLogic));
                }
            }

            // Stage skill requirements: always shown when present, coloured
            // green when met, red when not. Mirrors apworld _eval_req for
            // the WIZLOCK skill gate on Journey/Stash locations.
            for each (var skillReq:Array in _evaluator.getStageSkillsStatus(strId)) {
                var met:Boolean = skillReq[1] == true;
                lines.push(["Needs: " + String(skillReq[0]),
                            met ? 0x44FF44 : 0xFF4444]);
            }

            // A4-only: "All 24 skills" gate on Journey.
            if (FieldLogicEvaluator.ALL_SKILLS_STAGES[strId] == true) {
                var have24:int = AV.sessionData.totalSkillsCollected;
                lines.push(["All 24 skills (" + have24 + "/24)",
                            have24 >= 24 ? 0x44FF44 : 0xFF4444]);
            }

            // Stage out of logic: show why.
            if (!_evaluator.isStageInLogic(strId)) {
                var req:Object = _evaluator.getBlockingTokenReq(strId);
                if (req != null && req.missingToken == true) {
                    lines.push(["Missing field token", 0xFF4444]);
                }
                // Prereq stage / talisman / skillPoints requirements that aren't met.
                for each (var bl:Array in _evaluator.getBlockingTierSkillLines(strId)) {
                    if (bl != null && bl.length >= 2) {
                        lines.push([String(bl[0]), 0xFF4444]);
                    }
                }
            }

            return lines;
        }

        private function _checkLine(label:String, done:Boolean, inLogic:Boolean):Array {
            if (done)    return [label + ": \u2713",         0x888888];
            if (inLogic) return [label + ": in logic",       0x44FF44];
            return              [label + ": not in logic",   0xFF4444];
        }

        /**
         * Attempt to remove gem icon entries (and the "Available gems:" label) from
         * McInfoPanel's internal render list without touching the map preview or text.
         *
         * McInfoPanel's internal list is a private implementation detail; we probe
         * several likely property names. If none match this is a safe no-op.
         *
         * Identification heuristic:
         *   textfield entries  → have a "text" property
         *   image/preview      → have a "bitmapData", "bitmap", or "image" property
         *   gem icon entries   → have none of the above → removed
         *   "Available gems:"  → textfield whose text contains "gems" → removed
         */
        private function _tryRemoveGemEntries(vIp:*):void {
            var listProps:Array = ["_items", "items", "_textItems", "_renders", "_content", "_tfItems"];
            for each (var pn:String in listProps) {
                try {
                    var lst:* = vIp[pn];
                    if (!(lst is Array) || (lst as Array).length == 0) continue;
                    var filtered:Array = [];
                    for each (var item:* in lst as Array) {
                        if (item == null) continue;
                        var hasText:Boolean = item.hasOwnProperty("text");
                        var hasBmp:Boolean  = item.hasOwnProperty("bitmapData")
                                           || item.hasOwnProperty("bitmap")
                                           || item.hasOwnProperty("image");
                        if (!hasText && !hasBmp) continue; // gem icon entry — skip
                        if (hasText && String(item["text"]).toLowerCase().indexOf("gems") >= 0) continue; // "Available gems:" — skip
                        filtered.push(item);
                    }
                    vIp[pn] = filtered;
                    return;
                } catch (fe:Error) {}
            }
        }
    }
}
