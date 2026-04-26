package patch {
    import Bezel.Bezel;
    import Bezel.Logger;
    import Bezel.GCFW.Events.EventTypes;

    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.DropType;
    import com.giab.games.gcfw.constants.IngameStatus;
    import com.giab.games.gcfw.entity.TalismanFragment;
    import com.giab.games.gcfw.mcDyn.McDropIconOutcome;

    import flash.display.Sprite;
    import flash.events.MouseEvent;

    import ui.XpTomeDropIcon;
    import ui.RemoteItemDropIcon;

    /**
     * Intercepts SAVE_SAVE and reverts any automatic field-token, map-tile,
     * skill-tome, battle-trait, shadow-core, and talisman-fragment unlocks
     * that the game wrote to PlayerProgressData. The save file is immediately
     * overwritten so the reverted state is persisted.
     */
    public class ProgressionBlocker {

        // Drop-type constants used to identify AP rewards queued during a battle.
        // Referenced externally by AchievementUnlocker.
        public static const AP_ACHIEVEMENT_COLLECTED:String  = "AP_ACHIEVEMENT_COLLECTED";
        public static const AP_ACHIEVEMENT_SKILL:String      = "AP_ACHIEVEMENT_SKILL";
        public static const AP_ACHIEVEMENT_TRAIT:String      = "AP_ACHIEVEMENT_TRAIT";
        public static const AP_ACHIEVEMENT_TALISMAN:String   = "AP_ACHIEVEMENT_TALISMAN";
        public static const AP_ACHIEVEMENT_SHADOWCORE:String = "AP_ACHIEVEMENT_SHADOWCORE";
        public static const AP_STASH_TALISMAN:String         = "AP_STASH_TALISMAN";
        public static const AP_STASH_SHADOWCORE:String       = "AP_STASH_SHADOWCORE";
        public static const AP_ITEM_FOR_US:String            = "AP_ITEM_FOR_US";
        public static const AP_ITEM_FOR_OTHER:String         = "AP_ITEM_FOR_OTHER";

        private var _logger:Logger;
        private var _modName:String;
        private var _bezel:Bezel;
        private var _isSaving:Boolean = false;

        // Tracks which skills / traits AP has granted (by game index).
        private var _apGrantedSkills:Array; // Boolean[24]
        private var _apGrantedTraits:Array; // Boolean[15]

        // Wiz stash blocking: str_id → "seed/rarity/type/upgradeLevel"
        // Set once on AP connect via setWizStashTalData().
        private var _wizStashTalData:Object = null;

        // Tracks which stage IDs have had their stash rewards blocked already
        // so we don't double-subtract on subsequent saves.
        private var _stashBlockedIds:Object = {};

        // Set true once AP-specific drop icons have been injected for the current
        // ending screen. Prevents tickDropIcons() from clearing them on the next
        // frame. Reset by resetApIconsState() when the player leaves the level.
        private var _apIconsInjected:Boolean = false;

        // Captured from the vanilla ENDURANCE_WAVE_STONE icon during tickDropIcons,
        // before that icon is wiped. updatePpdWithDrops has already applied the
        // amount to GV.ppd.gainedEnduranceWaveStones, so we just need the value
        // to re-inject a visual icon. Reset by resetApIconsState().
        private var _pendingEnduranceWaveStones:int = 0;

        public function ProgressionBlocker(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
            _apGrantedSkills = new Array(24);
            _apGrantedTraits = new Array(15);
            for (var i:int = 0; i < 24; i++) _apGrantedSkills[i] = false;
            for (var j:int = 0; j < 15; j++) _apGrantedTraits[j] = false;
        }

        // -----------------------------------------------------------------------
        // Lifecycle

        /** Attach to the Bezel event bus. Call from ArchipelagoMod.bind(). */
        public function enable(bezel:Bezel):void {
            _bezel = bezel;
            _bezel.addEventListener(EventTypes.SAVE_SAVE, onSaveSave);
        }

        /** Detach from the Bezel event bus. Call from ArchipelagoMod.unload(). */
        public function disable():void {
            if (_bezel != null) {
                _bezel.removeEventListener(EventTypes.SAVE_SAVE, onSaveSave);
                _bezel = null;
            }
        }

        // -----------------------------------------------------------------------
        // AP grant tracking

        /** Call at the start of a full AP sync to clear the previous grant state. */
        public function resetGrants():void {
            for (var i:int = 0; i < 24; i++) _apGrantedSkills[i] = false;
            for (var j:int = 0; j < 15; j++) _apGrantedTraits[j] = false;
        }

        /** Mark a skill as AP-granted so it will not be reverted on saves. */
        public function markSkillGranted(gameId:int):void {
            if (gameId >= 0 && gameId < 24) _apGrantedSkills[gameId] = true;
        }

        /** Mark a battle trait as AP-granted so it will not be reverted on saves. */
        public function markTraitGranted(gameId:int):void {
            if (gameId >= 0 && gameId < 15) _apGrantedTraits[gameId] = true;
        }

        /**
         * Provide the wiz stash talisman data map (str_id → "seed/rarity/type/upgradeLevel")
         * from slot_data so the blocker knows which fragment seed to remove per stage.
         * Also resets _stashBlockedIds so prior blocks are re-evaluated for the new slot.
         */
        public function setWizStashTalData(map:Object):void {
            _wizStashTalData = map;
            _stashBlockedIds = {};
        }

        // -----------------------------------------------------------------------
        // Per-frame drop suppression

        /**
         * Call every frame. Clears ending.dropIcons as items are collected so the
         * victory screen finds an empty array and displays nothing. Data effects
         * for known drop types are reverted immediately; unknown types are logged.
         */
        /** Returns true if any drops were cleared this tick (caller can start a log countdown). */
        public function tickDropIcons():Boolean {
            if (_apIconsInjected) return false;
            if (GV.ingameController == null || GV.ingameController.core == null) return false;
            var ending:* = GV.ingameController.core.ending;
            if (ending == null) return false;
            var drops:Array = ending.dropIcons;
            if (drops == null || drops.length == 0) return false;

            for (var i:int = 0; i < drops.length; i++) {
                var di:* = drops[i];
                if (di == null) continue;
                switch (di.type) {
                    case DropType.FIELD_TOKEN:
                        if (GV.ppd != null)
                            GV.ppd.stageHighestXpsJourney[Number(di.data)].s(-1);
                        _logger.log(_modName, "tickDropIcons: blocked FIELD_TOKEN id=" + di.data);
                        break;
                    case DropType.MAP_TILE:
                        if (GV.ppd != null)
                            GV.ppd.gainedMapTiles[Number(di.data)] = false;
                        _logger.log(_modName, "tickDropIcons: blocked MAP_TILE id=" + di.data);
                        break;
                    case DropType.ENDURANCE_WAVE_STONE:
                        // Vanilla updatePpdWithDrops already applied the amount to ppd —
                        // just remember it so we can re-inject the visual icon later.
                        _pendingEnduranceWaveStones += int(Number(di.data));
                        _logger.log(_modName, "tickDropIcons: captured ENDURANCE_WAVE_STONE amount=" + di.data);
                        break;
                    default:
                        _logger.log(_modName, "tickDropIcons: suppressed drop type=" + di.type + " data=" + di.data);
                        break;
                }
            }
            drops.splice(0, drops.length);
            return true;
        }

        // -----------------------------------------------------------------------
        // AP drop icon injection

        /**
         * Reset the AP-injection flag so tickDropIcons resumes clearing.
         * Call when the player leaves the ending screen (transitions away from INGAME).
         */
        public function resetApIconsState():void {
            _apIconsInjected = false;
            _pendingEnduranceWaveStones = 0;
        }

        /** Amount captured from the vanilla ENDURANCE_WAVE_STONE icon this level (0 if none). */
        public function get pendingEnduranceWaveStones():int { return _pendingEnduranceWaveStones; }

        /**
         * Inject a single SHADOW_CORE drop icon onto the ending screen using the
         * vanilla McDropIconOutcome. Mirrors what IngameEnding.prepareDropIcons does
         * for shadow cores: positions the icon in the dropIcons row, adds it to
         * mcOutcomePanel, and wires the standard tooltip mouse listeners.
         *
         * Sets _apIconsInjected so subsequent tickDropIcons calls leave it alone.
         */
        public function addShadowCoreDropIcon(amount:int):void {
            if (amount <= 0) return;
            _addDropIcon(new McDropIconOutcome(DropType.SHADOW_CORE, amount),
                "SHADOW_CORE amount=" + amount);
        }

        /**
         * Inject a single TALISMAN_FRAGMENT drop icon for the given fragment.
         * Caller is responsible for ensuring no duplicates (typically by checking
         * inventory presence before calling).
         */
        public function addTalismanFragmentDropIcon(frag:TalismanFragment):void {
            if (frag == null) return;
            _addDropIcon(new McDropIconOutcome(DropType.TALISMAN_FRAGMENT, frag),
                "TALISMAN_FRAGMENT seed=" + frag.seed);
        }

        /**
         * Inject a FIELD_TOKEN drop icon for the given stage. stageId is the index
         * into GV.stageCollection.stageMetas (NOT the AP id). The icon shows the
         * field-specific plate; tooltip reads "Token for field <strId>".
         */
        public function addFieldTokenDropIcon(stageId:int):void {
            if (stageId < 0) return;
            _addDropIcon(new McDropIconOutcome(DropType.FIELD_TOKEN, stageId),
                "FIELD_TOKEN stageId=" + stageId);
        }

        /**
         * Inject a SKILL_TOME drop icon. skillGameId is 0-23. The icon is the
         * generic tome bitmap (vanilla doesn't render skill-specific art); tooltip
         * reads the skill name from selectorCore.pnlSkills.skillTitles[gameId].
         */
        public function addSkillTomeDropIcon(skillGameId:int):void {
            if (skillGameId < 0 || skillGameId >= 24) return;
            _addDropIcon(new McDropIconOutcome(DropType.SKILL_TOME, skillGameId),
                "SKILL_TOME gameId=" + skillGameId);
        }

        /**
         * Inject a BATTLETRAIT_SCROLL drop icon. traitGameId is 0-14. Generic scroll
         * bitmap; tooltip reads the trait name from selectorCore.renderer.traitTitles[gameId].
         */
        public function addBattleTraitScrollDropIcon(traitGameId:int):void {
            if (traitGameId < 0 || traitGameId >= 15) return;
            _addDropIcon(new McDropIconOutcome(DropType.BATTLETRAIT_SCROLL, traitGameId),
                "BATTLETRAIT_SCROLL gameId=" + traitGameId);
        }

        /**
         * Inject an ENDURANCE_WAVE_STONE drop icon. amount is how many waves the
         * stone(s) extend the endurance limit by. Vanilla picks a randomized
         * variant (1-4 stones) inside the McDropIconOutcome constructor; tooltip
         * just reads "Endurance Wave Stone +N waves".
         */
        public function addEnduranceWaveStoneDropIcon(amount:int):void {
            if (amount <= 0) return;
            _addDropIcon(new McDropIconOutcome(DropType.ENDURANCE_WAVE_STONE, amount),
                "ENDURANCE_WAVE_STONE amount=" + amount);
        }

        /**
         * Inject an ACHIEVEMENT drop icon. achievementGameId is the internal id from
         * GV.achiCollection.achisById. Vanilla draws the achievement-specific 86×86
         * bitmap (Achievement.drawBitmap86) and the tooltip delegates to
         * pnlAchievements.renderAchiInfoPanel for the full description.
         */
        public function addAchievementDropIcon(achievementGameId:int):void {
            if (achievementGameId < 0) return;
            // Defensive: vanilla constructor will throw if achisById[gameId] is null.
            if (GV.achiCollection == null || GV.achiCollection.achisById == null) return;
            if (GV.achiCollection.achisById[achievementGameId] == null) {
                _logger.log(_modName, "addAchievementDropIcon: unknown gameId=" + achievementGameId);
                return;
            }
            _addDropIcon(new McDropIconOutcome(DropType.ACHIEVEMENT, achievementGameId),
                "ACHIEVEMENT gameId=" + achievementGameId);
        }

        /**
         * Inject a custom XP-tome drop icon (Tattered Scroll / Worn Tome /
         * Ancient Grimoire). The variant is chosen inside XpTomeDropIcon based
         * on the AP id range. Uses its own MOUSE_OVER tooltip handler — the
         * vanilla renderDropIconInfoPanel doesn't know our type, so we opt out
         * of the standard hover wiring.
         */
        public function addXpTomeDropIcon(apId:int):void {
            if (apId < 1100 || apId > 1199) return;
            _addDropIcon(new XpTomeDropIcon(apId),
                "XP_TOME apId=" + apId,
                false /* useVanillaHover */);
        }

        /**
         * Inject a generic AP icon for an item this player sent out that belongs
         * to ANOTHER game (apId outside any of our handled ranges). Tooltip
         * reads "Sent <itemName> to <recipientName>".
         */
        public function addRemoteItemDropIcon(itemName:String, recipientName:String):void {
            if (itemName == null) itemName = "Unknown item";
            if (recipientName == null) recipientName = "another player";
            _addDropIcon(new RemoteItemDropIcon(itemName, recipientName),
                "REMOTE_ITEM '" + itemName + "' → " + recipientName,
                false /* useVanillaHover */);
        }

        private function _addDropIcon(icon:Sprite, label:String, useVanillaHover:Boolean = true):void {
            if (GV.ingameController == null || GV.ingameController.core == null) return;
            var ending:* = GV.ingameController.core.ending;
            if (ending == null || ending.cnt == null || ending.cnt.mcOutcomePanel == null) return;

            try {
                if (ending.dropIcons == null) ending.dropIcons = new Array();
                ending.dropIcons.push(icon);

                // Re-position all icons using the same formula as prepareDropIcons.
                var n:int = ending.dropIcons.length;
                for (var i:int = 0; i < n; i++) {
                    var di:* = ending.dropIcons[i];
                    di.x = 48 + i * 140 + (n < 13 ? 70 * (13 - n) : 0);
                    di.y = 789;
                }

                // Hidden by default — playDropIconsAnimation() makes them appear one-by-one
                // via the vanilla doEnterFrameOutcomePanelDropsListing loop. If the caller
                // forgets to start the animation, the icons stay invisible (acceptable
                // failure mode — better than popping in all at once).
                icon.visible = false;
                ending.cnt.mcOutcomePanel.addChild(icon);

                // Vanilla hover: ehDropIconOver dispatches by .type into
                // renderDropIconInfoPanel, which throws on unknown types. Custom
                // icon classes (e.g. XpTomeDropIcon) wire their own listeners in
                // their constructor and pass useVanillaHover=false here.
                if (useVanillaHover) {
                    var ih:* = GV.ingameController.core.inputHandler2;
                    if (ih != null) {
                        icon.addEventListener(MouseEvent.MOUSE_OVER, ih.ehDropIconOver, false, 0, true);
                        icon.addEventListener(MouseEvent.MOUSE_OUT,  ih.ehDropIconOut,  false, 0, true);
                    }
                }

                _apIconsInjected = true;
                _logger.log(_modName, "Injected drop icon: " + label);
            } catch (err:Error) {
                _logger.log(_modName, "_addDropIcon ERROR: " + err.message);
            }
        }

        /**
         * Trigger the vanilla per-frame drops-listing animation
         * (doEnterFrameOutcomePanelDropsListing) so injected icons appear one at a
         * time with sounds and the appearing-glow VFX.
         *
         * Safe to call only when the ending screen is past stats rolling. If stats
         * are still rolling, the natural transition at IngameCore.as:1992 will
         * detect dropIcons.length > 0 and start the animation on its own — calling
         * this is a no-op in that case (we only switch from SHOWING_IDLE).
         */
        public function playDropIconsAnimation():void {
            if (GV.ingameController == null || GV.ingameController.core == null) return;
            var core:* = GV.ingameController.core;
            if (core.ingameStatus != IngameStatus.GAMEOVER_PANEL_SHOWING_IDLE) return;
            if (core.ending == null || core.ending.dropIcons == null) return;
            if (core.ending.dropIcons.length == 0) return;

            core.timer = 0;
            core.ingameStatus = IngameStatus.GAMEOVER_PANEL_DROPS_LISTING;
            _logger.log(_modName, "Restarted drops-listing animation for "
                + core.ending.dropIcons.length + " injected icon(s)");
        }

        // -----------------------------------------------------------------------
        // Save hook

        private function onSaveSave(e:*):void {
            if (_isSaving) return;
            try {
                var reverted:int = 0;

                // --- Battle-victory drops (field tokens, map tiles) ---
                if (GV.ingameController != null && GV.ingameController.core != null) {
                    var ending:* = GV.ingameController.core.ending;
                    if (ending != null && ending.isBattleWon) {
                        var drops:Array = ending.dropIcons;
                        if (drops != null) {
                            for (var i:int = 0; i < drops.length; i++) {
                                var di:* = drops[i];
                                if (di == null) continue;
                                switch (di.type) {
                                    case DropType.FIELD_TOKEN:
                                        GV.ppd.stageHighestXpsJourney[Number(di.data)].s(-1);
                                        reverted++;
                                        _logger.log(_modName, "Blocked stage unlock id=" + di.data);
                                        break;
                                    case DropType.MAP_TILE:
                                        GV.ppd.gainedMapTiles[Number(di.data)] = false;
                                        reverted++;
                                        _logger.log(_modName, "Blocked map tile id=" + di.data);
                                        break;
                                }
                            }
                        }

                        if (reverted > 0) {
                            // Strip pending TOKEN_APPEARING (0) and MAP_TILE_APPEARING (1)
                            // events from the selector queue so no unlock animation plays on return.
                            var queue:Array = GV.selectorCore.eventQueue;
                            for (var j:int = queue.length - 1; j >= 0; j--) {
                                var evt:* = queue[j];
                                if (evt != null && (evt.type == 0 || evt.type == 1)) {
                                    queue.splice(j, 1);
                                }
                            }
                        }
                    }
                }

                // --- Enforce AP authority over skills and traits on every save ---
                var skillReverted:Boolean = false;
                if (GV.ppd != null) {
                    for (var s:int = 0; s < 24; s++) {
                        if (GV.ppd.gainedSkillTomes[s] && !_apGrantedSkills[s]) {
                            GV.ppd.gainedSkillTomes[s] = false;
                            GV.ppd.setSkillLevel(s, -1);
                            reverted++;
                            skillReverted = true;
                            _logger.log(_modName, "Blocked non-AP skill tome gameId=" + s);
                        }
                    }
                    for (var t:int = 0; t < 15; t++) {
                        if (GV.ppd.gainedBattleTraits[t] && !_apGrantedTraits[t]) {
                            GV.ppd.gainedBattleTraits[t] = false;
                            reverted++;
                            _logger.log(_modName, "Blocked non-AP battle trait gameId=" + t);
                        }
                    }
                }
                if (skillReverted) removePlusNodeFromSelector("mcPlusNodeSkills");

                // --- Block shadow cores and talisman fragments from wizard stashes ---
                if (GV.ppd != null && GV.stageCollection != null && _wizStashTalData != null) {
                    var metas:Array = GV.stageCollection.stageMetas;
                    for (var m:int = 0; m < metas.length; m++) {
                        var meta:* = metas[m];
                        if (meta == null) continue;
                        var stageId:int     = int(meta.id);
                        var stashStatus:int = int(GV.ppd.stageWizStashStauses[stageId]);
                        if (stashStatus == 0) continue;
                        if (_stashBlockedIds[stageId]) continue;

                        var strId:String      = String(meta.strId);
                        var stashDrops:String = String(meta.stashDrops);
                        var parts:Array       = stashDrops.split("+");
                        var stashReverted:int = 0;

                        for (var p:int = 0; p < parts.length; p++) {
                            var drop:String = String(parts[p]);

                            if (drop.indexOf("SC") == 0) {
                                var scAmount:int = int(drop.substring(2));
                                if (scAmount > 0) {
                                    var currentSC:Number = GV.ppd.shadowCoreAmount.g();
                                    GV.ppd.shadowCoreAmount.s(Math.max(0, currentSC - scAmount));
                                    reverted++;
                                    stashReverted++;
                                    _logger.log(_modName, "Blocked stash SC grant stage=" + strId
                                        + " amount=" + scAmount);
                                }
                            }

                            if (drop == "TAL") {
                                var talData:* = _wizStashTalData[strId];
                                if (talData != null) {
                                    var talParts:Array = String(talData).split("/");
                                    if (talParts.length >= 1) {
                                        var seed:int = int(talParts[0]);
                                        if (removeTalismanBySeed(seed)) {
                                            reverted++;
                                            stashReverted++;
                                            _logger.log(_modName, "Blocked stash TAL grant stage=" + strId
                                                + " seed=" + seed);
                                        }
                                    }
                                }
                            }
                        }

                        if (stashReverted > 0) {
                            _stashBlockedIds[stageId] = true;
                            removePlusNodeFromSelector("mcPlusNodeTalisman");
                        }
                    }
                }

                if (reverted > 0) {
                    _isSaving = true;
                    GV.loaderSaver.saveGameData();
                    _isSaving = false;
                    _logger.log(_modName, "Blocked " + reverted + " progression item(s), save overwritten");
                }
            } catch (err:Error) {
                _isSaving = false;
                _logger.log(_modName, "ProgressionBlocker.onSaveSave ERROR: " + err.message + "\n" + err.getStackTrace());
            }
        }

        // -----------------------------------------------------------------------
        // Private helpers

        private function removePlusNodeFromSelector(nodeName:String):void {
            try {
                var mc:* = GV.selectorCore != null ? GV.selectorCore.mc : null;
                if (mc == null) return;
                var node:* = mc[nodeName];
                if (node != null && mc.contains(node)) {
                    mc.removeChild(node);
                    _logger.log(_modName, "Removed " + nodeName + " (suppressed non-AP gain)");
                }
            } catch (err:Error) {
                _logger.log(_modName, "removePlusNodeFromSelector " + nodeName + " error: " + err.message);
            }
        }

        private function removeTalismanBySeed(seed:int):Boolean {
            if (GV.ppd == null) return false;
            var inv:Array = GV.ppd.talismanInventory;
            if (inv == null) return false;
            for (var i:int = 0; i < inv.length; i++) {
                var frag:* = inv[i];
                if (frag != null && TalismanFragment(frag).seed == seed) {
                    inv[i] = null;
                    return true;
                }
            }
            return false;
        }
    }
}
