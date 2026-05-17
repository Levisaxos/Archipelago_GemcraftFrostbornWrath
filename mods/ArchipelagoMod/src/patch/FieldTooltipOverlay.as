package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.GemComponentType;
    import com.giab.games.gcfw.entity.Gem;
    import flash.display.Bitmap;
    import flash.display.DisplayObject;
    import flash.filters.ColorMatrixFilter;
    import flash.filters.GlowFilter;
    import flash.geom.Rectangle;

    import data.AV;
    import net.ConnectionManager;
    import tracker.FieldLogicEvaluator;

    /**
     * Appends Archipelago check-status lines into the game's field hover tooltip
     * (McInfoPanel) using the same intercept pattern as AchievementTooltipOverlay.
     *
     * Shows per-check status for Journey and Stash locations as one line
     * each: grey "✓" if already checked, green when in logic, red when
     * blocked. Live lines carry a granularity-aware "Got/Needs pouch (X)"
     * or "Got/Needs key (X)" suffix when the gate involves a gempouch or
     * wizard stash key. Each element / special-monster spawn on the
     * stage is listed as "<Name>: <count>" coloured the same way (count
     * drops to just the name when stats aren't loaded).
     *
     * Adjusts the "Available gems" section based on Gempouch ownership:
     *   - Pouch held (or pouch gating off) → vanilla gem list shown as-is.
     *   - No pouch on a free starter stage → vanilla gems removed and a
     *     single colorless mana-leech gem injected, matching the in-game
     *     HollowGemInjector button.
     *   - No pouch on a non-free stage → gems hidden entirely.
     */
    public class FieldTooltipOverlay {

        private static const ACHIEVEMENTS_IDLE_STAGES:int   = 305;
        private static const ACHIEVEMENTS_IDLE_SETTINGS:int = 306;

        // Gem section extra height added by SelectorRenderer after the gem icons.
        private static const GEMS_EXTRA_HEIGHT:int = 46;

        // L5 prerequisite skills with display names + AP item ids.
        // Mirrors L5_SKILL_AP_IDS in ArchipelagoMod (kept separate so the
        // overlay isn't coupled to the orchestrator).
        private static const L5_SKILLS:Array = [
            {name: "Bolt",    apId: 715},
            {name: "Beam",    apId: 716},
            {name: "Barrage", apId: 717},
            {name: "Freeze",  apId: 712}
        ];

        // Luminance-preserving desaturation matrix; mirrors HollowGemInjector
        // so the tooltip's hollow gem icon matches the in-game button.
        private static const _DESAT_FILTER:ColorMatrixFilter = new ColorMatrixFilter([
            0.299, 0.587, 0.114, 0, 60,
            0.299, 0.587, 0.114, 0, 60,
            0.299, 0.587, 0.114, 0, 60,
            0,     0,     0,     1, 0
        ]);

        private var _logger:Logger;
        private var _modName:String;
        private var _evaluator:FieldLogicEvaluator;
        private var _cm:ConnectionManager;  // for scout-cache reverse lookup on L5

        // True after we've appended our lines to the current tooltip.
        // Cleared when isImageRendered goes false (game reset or panel closed),
        // which signals a new tooltip is starting.
        private var _appended:Boolean = false;

        // -----------------------------------------------------------------------

        public function FieldTooltipOverlay(logger:Logger, modName:String,
                                            evaluator:FieldLogicEvaluator,
                                            cm:ConnectionManager) {
            _logger    = logger;
            _modName   = modName;
            _evaluator = evaluator;
            _cm        = cm;
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

            // Decide gem display from real state instead of hardcoded stages:
            //   pouch_off (mode 0):     vanilla list is correct → keep
            //   has pouch for stage:    vanilla list reflects what player can create → keep
            //   free stage, no pouch:   replace with single hollow gem icon
            //   non-free, no pouch:     hide (vanilla list would mislead)
            var pouchMode:int = (AV.serverData != null && AV.serverData.serverOptions != null)
                    ? int(AV.serverData.serverOptions.gemPouchGranularity) : 0;
            var hasPouch:Boolean = (pouchMode == 0)
                    || AV.sessionData.hasPouchForStage(strId);
            var isFree:Boolean = _evaluator.isFreeStage(strId);

            var shouldRemoveGems:Boolean = !hasPouch;
            var shouldInjectHollowGem:Boolean = !hasPouch && isFree;

            var base:int = int(ConnectionManager.stageLocIds[strId]);
            var shouldAddApOverlay:Boolean = base > 0;

            // L5 vanilla tooltip hard-codes "Get the Bolt skill tome first on
            // field Q1!" etc. — wrong in any randomized seed. We strip those
            // lines and append AP-derived ones showing the actual scouted
            // skill locations.
            var isL5:Boolean = (strId == "L5");

            // Nothing for us to do on this tooltip.
            if (!shouldRemoveGems && !shouldInjectHollowGem && !shouldAddApOverlay && !isL5) {
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

            // When hiding gems, take two complementary cleanup paths:
            //   1. Filter the internal render list to remove gem entries (and the "Available
            //      gems:" label). Textfield entries have a "text" property; image/preview
            //      entries have a "bitmapData"/"bitmap"/"image" property. Entries with none
            //      of these are gem icon entries and are removed.
            //   2. Hide any non-Bitmap display children (gem icons added as addChild).
            if (shouldRemoveGems) {
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

            // Strip the "Available gems" section from the panel data when no pouch.
            if (shouldRemoveGems) {
                _removeAvailableGems(vIp);
            }

            // On L5, drop the four hard-coded vanilla "Get the X skill tome
            // first on field Y!" textfields. Their field IDs are vanilla
            // (Q1/X4/M3/Y3) and don't reflect where the skill actually lives
            // in this seed. The replacement lines go in below alongside AP
            // overlay content.
            if (isL5) {
                _removeVanillaL5SkillWarnings(vIp);
            }

            // Free starter stage without pouch: add a single hollow gem icon
            // back so the player sees what they can actually create on this
            // stage (matches the in-game HollowGemInjector button).
            if (shouldInjectHollowGem) {
                _injectHollowGem(vIp);
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

            // L5 prereq-skill hint lines — one per missing skill, drawn from
            // the AP scout cache. Skips skills the player has already
            // collected and skips entries the scout cache hasn't resolved yet
            // (the player will see them once LocationInfo arrives).
            if (isL5) {
                _appendL5SkillHintLines(vIp);
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

        /**
         * Add an "Available gems:" section containing a single colorless
         * mana-leech gem to the tooltip. Mirrors SelectorRenderer's vanilla
         * gem-rendering pattern (build Gem entity, call giveGemBitmaps, push
         * mc into attachedMcs) so the hollow icon flows through doEnterFrame
         * just like the game's own gem icons.
         */
        private function _injectHollowGem(vIp:*):void {
            try {
                vIp.addTextfield(0xFFE63B, "Available gems:", false, 11,
                        [new GlowFilter(0, 1, 3, 3)]);

                var gem:Gem = new Gem();
                gem.elderComponents = [GemComponentType.MANA_LEECHING];
                gem.manaValuesByComponent[GemComponentType.MANA_LEECHING].s(1);
                GV.gemBitmapCreator.giveGemBitmaps(gem, false);
                gem.hasColor = false;
                gem.hueMain  = 0;

                _applyDesatToGemMc(gem.mc);

                var panelW:Number = Number(vIp.w);
                if (!(panelW > 0))
                    panelW = 400;
                gem.mc.x = Math.round((panelW - Number(gem.mc.width)) * 0.5);
                gem.mc.y = vIp.nextTfPos + 10;

                if (vIp.attachedMcs == null)
                    vIp.attachedMcs = [];
                (vIp.attachedMcs as Array).push(gem.mc);

                vIp.addExtraHeight(GEMS_EXTRA_HEIGHT);
            } catch (e:Error) {
                _logger.log(_modName,
                        "FieldTooltipOverlay: _injectHollowGem error: " + e.message);
            }
        }

        /** Apply the desaturate filter to every Bitmap descendant of the Gem MC. */
        private function _applyDesatToGemMc(mc:*):void {
            if (mc == null) return;
            try {
                var n:int = int(mc.numChildren);
                for (var i:int = 0; i < n; i++) {
                    var child:DisplayObject = mc.getChildAt(i) as DisplayObject;
                    if (child is Bitmap) {
                        (child as Bitmap).filters = [_DESAT_FILTER];
                    }
                }
            } catch (e:Error) {}
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
            // Wizard Tower additionally requires the stash key — it's the
            // visual structure of the wizard stash and can only be unlocked
            // by opening the stash.
            // Drop Holder additionally requires the Bolt Skill — it's only
            // opened by Bolt shots.
            var stageReachable:Boolean = _evaluator.canCompleteStage(strId);
            var hasRitual:Boolean = AV.sessionData.hasItem(FieldLogicEvaluator.RITUAL_TRAIT_AP_ID);
            var stashUnlockedForElems:Boolean = AV.sessionData.isStashUnlocked(strId);
            var hasBolt:Boolean = _evaluator.hasBoltSkill();
            for each (var elem:String in _evaluator.getStageElements(strId)) {
                // Tower and Wall appear on nearly every stage with no useful
                // gating signal — hide them so the tooltip stays focused on
                // elements the player actually cares about.
                if (elem == "Tower" || elem == "Wall") continue;
                var elemInLogic:Boolean = stageReachable;
                if (elem == "Wizard Tower") {
                    elemInLogic = elemInLogic && stashUnlockedForElems;
                } else if (elem == "Drop Holder") {
                    elemInLogic = elemInLogic && hasBolt;
                }
                lines.push(_countLine(elem, _evaluator.getStageElementCount(strId, elem), elemInLogic));
            }
            for each (var mon:String in _evaluator.getStageMonsters(strId)) {
                lines.push(_countLine(mon, _evaluator.getStageElementCount(strId, mon),
                                      stageReachable && hasRitual));
            }

            var journeyExists:Boolean  = journeyMissing || journeyDone;
            var stashExists:Boolean    = stashMissing   || stashDone;

            var journeyInLogic:Boolean = journeyMissing &&
                    _evaluator.stageHasInLogicMissing(strId, true, false);
            var stashInLogic:Boolean   = stashMissing &&
                    _evaluator.stageHasInLogicMissing(strId, false, true);

            // One line per check, each coloured by its state. When the
            // gate involves a granularity-aware item (gempouch / stash
            // key), append a "Got …" / "Needs …" suffix so the player can
            // see exactly which item it refers to. Suffix is skipped for
            // the done (grey ✓) state since the check is already complete.
            if (journeyExists) {
                var pouchSuffix:String = journeyDone ? null : _evaluator.getPouchLabel(strId);
                lines.push(_checkLine("Journey", journeyDone, journeyInLogic, pouchSuffix));
            }
            if (stashExists) {
                var keySuffix:String = stashDone ? null : _evaluator.getStashKeyLabel(strId);
                lines.push(_checkLine("Stash", stashDone, stashInLogic, keySuffix));
            }

            // Stage out of logic: show why.
            if (!_evaluator.isStageInLogic(strId)) {
                var req:Object = _evaluator.getBlockingTokenReq(strId);
                if (req != null && req.missingToken == true) {
                    lines.push([_evaluator.getMissingTokenLabel(strId), 0xFF4444]);
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

        private function _checkLine(label:String, done:Boolean, inLogic:Boolean,
                                    suffix:String = null):Array {
            if (done) return [label + ": \u2713", 0x888888];
            var text:String = (suffix != null && suffix.length > 0)
                    ? (label + ": " + suffix) : label;
            return [text, inLogic ? 0x44FF44 : 0xFF4444];
        }

        private function _countLine(label:String, count:int, inLogic:Boolean):Array {
            var text:String = count > 0 ? (label + ": " + count) : label;
            return [text, inLogic ? 0x44FF44 : 0xFF4444];
        }

        /**
         * Remove the four vanilla L5 skill-warning textfields. SelectorRenderer
         * adds them with text like "Get the Bolt skill tome first on field Q1!"
         * (see do not commit/gcfw/scripts/com/giab/games/gcfw/selector/SelectorRenderer.as
         * around lines 960–986). We match on the leading "Get the " and the
         * "skill tome first on field " substring so locale changes in the
         * suffix don't break detection.
         *
         * Also rolls back the addExtraHeight(12) the vanilla branch tacks on
         * when at least one of the four warnings fires, by subtracting the
         * removed lines' total height from nextTfPos / h.
         */
        private function _removeVanillaL5SkillWarnings(vIp:*):void {
            try {
                var textfields:Array = vIp.textfields as Array;
                if (textfields == null) return;

                var removedCount:int = 0;
                var firstRemovedY:Number = Number.MAX_VALUE;
                var bottomY:Number       = -1;  // y of bottom edge of furthest-down warning

                // Walk backwards so splice() doesn't disturb the iteration.
                for (var i:int = textfields.length - 1; i >= 0; i--) {
                    var tf:* = textfields[i];
                    var txt:String = (tf != null && tf.text != null) ? String(tf.text) : "";
                    if (txt.indexOf("Get the ") != 0) continue;
                    if (txt.indexOf("skill tome first on field ") < 0) continue;

                    if (tf.y < firstRemovedY) firstRemovedY = tf.y;
                    var thisBottom:Number = tf.y + tf.height;
                    if (thisBottom > bottomY) bottomY = thisBottom;
                    removedCount++;
                    textfields.splice(i, 1);
                }
                if (removedCount == 0) return;

                // Shift any textfields that originally sat below the warning
                // block upward to close the gap. (Vanilla L5 puts warnings at
                // the bottom, so this is almost always a no-op — guards
                // against future re-orderings.)
                var shift:Number = bottomY - firstRemovedY;
                for (var j:int = 0; j < textfields.length; j++) {
                    if (textfields[j].y >= bottomY)
                        textfields[j].y -= shift;
                }

                // Set the panel's content cursor back to where the first
                // removed warning began. doEnterFrame uses nextTfPos as the
                // y-coordinate of the next addTextfield, so this ensures our
                // replacement lines start exactly where the vanilla warnings
                // did — no gap, no overlap regardless of font/leading math.
                vIp.nextTfPos = firstRemovedY;
                vIp.h         = firstRemovedY;
            } catch (e:Error) {
                _logger.log(_modName, "FieldTooltipOverlay: _removeVanillaL5SkillWarnings error: " + e.message);
            }
        }

        /**
         * For each L5-prereq skill the player doesn't yet own, append a single
         * tooltip line showing where the skill is in the seed (Player's
         * LocName, plus game name if it's not GCFW). Skills with no scout-cache
         * entry are silently skipped so the tooltip doesn't lie about an
         * "unknown" location.
         *
         * Colours: muted yellow header, warning red per skill line. Matches
         * the existing AP-overlay text styling.
         */
        private function _appendL5SkillHintLines(vIp:*):void {
            if (_cm == null || AV.archipelagoData == null) return;

            var lines:Array = [];
            for each (var sk:Object in L5_SKILLS) {
                var apId:int = int(sk.apId);
                if (AV.sessionData != null && AV.sessionData.hasItem(apId)) continue;
                var locId:int = _cm.findLocationForItem(apId);
                if (locId <= 0) continue;
                var entry:Object = _cm.getScoutEntry(locId);
                if (entry == null) continue;

                var playerLabel:String = (entry.playerName != null && String(entry.playerName).length > 0)
                        ? String(entry.playerName) : "another player";
                // entry.name is the ITEM name from the DataPackage (e.g.
                // "Bolt Skill"). For the LOCATION name we look up AP's
                // DataPackage via ConnectionManager — the owning game is
                // entry.game (the game that holds this location).
                var gameLabel:String = (entry.game != null) ? String(entry.game) : null;
                var locLabel:String = _cm.resolveLocationName(locId, gameLabel);

                var text:String = String(sk.name) + " Skill — " + playerLabel + " · " + locLabel;
                if (gameLabel != null && gameLabel != "GemCraft: Frostborn Wrath") {
                    text += " (" + gameLabel + ")";
                }
                lines.push(text);
            }
            if (lines.length == 0) return;

            try {
                vIp.addExtraHeight(7);
                vIp.addSeparator(-2);
                vIp.addTextfield(0xE5AD0A, "Skills to unlock L5:", false, 10);
                for each (var line:String in lines) {
                    vIp.addTextfield(0xFFB060, line, false, 10);
                }
            } catch (e:Error) {
                _logger.log(_modName, "FieldTooltipOverlay: _appendL5SkillHintLines error: " + e.message);
            }
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
