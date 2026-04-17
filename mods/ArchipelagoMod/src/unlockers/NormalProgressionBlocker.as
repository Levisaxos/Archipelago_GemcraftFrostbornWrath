package unlockers {
    import Bezel.Bezel;
    import Bezel.Logger;
    import Bezel.GCFW.Events.EventTypes;

    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.DropType;
    import com.giab.games.gcfw.entity.TalismanFragment;
    import com.giab.games.gcfw.mcDyn.McDropIconOutcome;
    import flash.events.MouseEvent;
    import data.AV;

    /**
     * Intercepts the SAVE_SAVE event and reverts any automatic field-token,
     * map-tile, skill-tome, battle-trait, shadow-core, and talisman-fragment
     * unlocks that the game wrote to PlayerProgressData.  The save file is
     * immediately overwritten so the reverted state is persisted.
     *
     * Instead of immediately calling unlockers, queues AP rewards to dropIcons
     * via custom drop types (AP_ACHIEVEMENT_*, AP_STASH_*). These are processed
     * together at level end via processApDropIcons().
     */
    public class NormalProgressionBlocker {

        // Custom drop types for AP rewards (to be processed at level end)
        public static const AP_ACHIEVEMENT_COLLECTED:String = "AP_ACHIEVEMENT_COLLECTED";
        public static const AP_ACHIEVEMENT_SKILL:String = "AP_ACHIEVEMENT_SKILL";
        public static const AP_ACHIEVEMENT_TRAIT:String = "AP_ACHIEVEMENT_TRAIT";
        public static const AP_ACHIEVEMENT_TALISMAN:String = "AP_ACHIEVEMENT_TALISMAN";
        public static const AP_ACHIEVEMENT_SHADOWCORE:String = "AP_ACHIEVEMENT_SHADOWCORE";
        public static const AP_STASH_TALISMAN:String = "AP_STASH_TALISMAN";
        public static const AP_STASH_SHADOWCORE:String = "AP_STASH_SHADOWCORE";

        // Items received from AP (to display on ending screen)
        public static const AP_ITEM_FOR_US:String = "AP_ITEM_FOR_US";           // Item sent to us
        public static const AP_ITEM_FOR_OTHER:String = "AP_ITEM_FOR_OTHER";     // Item sent to another player

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
        private var _stashBlockedIds:Object = {}; // stageId (int key) → true

        // References to unlockers for dropIcons processor
        private var _achievementUnlocker:*;
        private var _skillUnlocker:*;
        private var _traitUnlocker:*;
        private var _talismanUnlocker:*;
        private var _shadowCoreUnlocker:*;

        // Reference to ConnectionManager for reading lastCheckedLocations
        private var _connectionManager:*;

        // Track items received during this level (to display on ending screen)
        private var _itemsReceivedThisLevel:Array = [];  // Array of {apId, itemName, sentTo, isForUs}

        public function NormalProgressionBlocker(logger:Logger, modName:String) {
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

        /** Clear the items received in this level (call at level start). */
        public function clearReceivedItems():void {
            _itemsReceivedThisLevel = [];
        }

        /**
         * Add an AP item directly to the ending screen's dropIcons if it is still active.
         * Call from grantItem() for items that arrive after onSaveSave() has already run —
         * the Flash ending object stays live until dismissed, so adding here still renders.
         */
        public function addItemToActiveEndingScreen(apId:int, itemName:String, isForUs:Boolean = true):void {
            try {
                if (GV.ingameController == null || GV.ingameController.core == null) return;
                var ending:* = GV.ingameController.core.ending;
                if (ending == null || ending.dropIcons == null || !ending.isBattleWon) return;

                var tooltip:String = isForUs ? (itemName + " to You") : (itemName + " to Other");
                var icon:ApItemIcon = new ApItemIcon(tooltip);
                icon.y = 789;
                icon.visible = false;
                ending.cnt.mcOutcomePanel.addChild(icon);
                ending.dropIcons.push(icon);
                icon.addEventListener(MouseEvent.MOUSE_OVER, onApIconOver, false, 0, true);
                icon.addEventListener(MouseEvent.MOUSE_OUT, onIconOut, false, 0, true);

                // Reposition ALL icons so centering stays correct for the new total count
                var n:int = ending.dropIcons.length;
                var xOff:Number = n < 13 ? 70 * (13 - n) : 0;
                for (var i:int = 0; i < n; i++) {
                    ending.dropIcons[i].x = 48 + i * 140 + xOff;
                }

                _logger.log(_modName, "addItemToActiveEndingScreen: " + itemName + " (AP ID " + apId + ")");
            } catch (err:Error) {
                _logger.log(_modName, "addItemToActiveEndingScreen ERROR: " + err.message);
            }
        }

        /** Track an item received from AP (to display on ending screen). */
        public function trackReceivedItem(apId:int, itemName:String = "", sentToPlayer:String = "You", isForUs:Boolean = true):void {
            if (itemName == "") {
                itemName = "Item " + apId;  // Fallback name
            }
            _itemsReceivedThisLevel.push({
                apId: apId,
                itemName: itemName,
                sentTo: sentToPlayer,
                isForUs: isForUs
            });
            _logger.log(_modName, "TRACKED ITEM: " + itemName + " (AP ID " + apId + ")");
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

        /**
         * Set references to the unlockers for dropIcons processor.
         * Called from ArchipelagoMod after all unlockers are initialized.
         */
        public function setUnlockers(
            achievementUnlocker:*,
            skillUnlocker:*,
            traitUnlocker:*,
            talismanUnlocker:*,
            shadowCoreUnlocker:*
        ):void {
            _achievementUnlocker = achievementUnlocker;
            _skillUnlocker = skillUnlocker;
            _traitUnlocker = traitUnlocker;
            _talismanUnlocker = talismanUnlocker;
            _shadowCoreUnlocker = shadowCoreUnlocker;
        }

        public function setConnectionManager(cm:*):void {
            _connectionManager = cm;
        }

        // -----------------------------------------------------------------------
        // dropIcons helpers

        /**
         * Add an AP reward drop to the dropIcons array for later processing.
         * Creates a custom drop object with type, data (apId), and metadata.
         */
        public static function addApDropToIcons(ending:Object, dropType:String, apId:int, meta:Object = null):void {
            if (ending == null || ending.dropIcons == null) return;
            var drop:Object = {
                type: dropType,
                data: apId,
                meta: meta || {}
            };
            ending.dropIcons.push(drop);
        }

        // -----------------------------------------------------------------------
        // Save hook

        private function onSaveSave(e:*):void {
            if (_isSaving) return;
            try {
                var reverted:int = 0;

                // --- Battle-victory drops (field tokens, map tiles, in-battle tomes) ---
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
                // If any skill tomes were reverted, suppress the '+' indicator on btnSkills.
                if (skillReverted) removePlusNodeFromSelector("mcPlusNodeSkills");

                // --- Block shadow cores and talisman fragments from wizard stashes ---
                if (GV.ppd != null && GV.stageCollection != null && _wizStashTalData != null) {
                    var metas:Array = GV.stageCollection.stageMetas;
                    for (var m:int = 0; m < metas.length; m++) {
                        var meta:* = metas[m];
                        if (meta == null) continue;
                        var stageId:int    = int(meta.id);
                        var stashStatus:int = int(GV.ppd.stageWizStashStauses[stageId]);
                        // Only process newly-cleared stashes (OPEN=1 or DESTROYED=2).
                        if (stashStatus == 0) continue;
                        if (_stashBlockedIds[stageId]) continue;

                        var strId:String   = String(meta.strId);
                        var stashDrops:String = String(meta.stashDrops);
                        var parts:Array    = stashDrops.split("+");
                        var stashReverted:int = 0;

                        for (var p:int = 0; p < parts.length; p++) {
                            var drop:String = String(parts[p]);

                            // Shadow cores: "SC{amount}"
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

                            // Talisman fragment: "TAL" (actual seed from wizStashTalData)
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

                // Build level-end drop icons from actual checked locations and achievement drops
                if (GV.ingameController != null && GV.ingameController.core != null) {
                    var endingForIcons:* = GV.ingameController.core.ending;
                    if (endingForIcons != null && endingForIcons.isBattleWon)
                        buildLevelEndIcons(endingForIcons);
                }

                if (reverted > 0) {
                    _isSaving = true;
                    GV.loaderSaver.saveGameData();
                    _isSaving = false;
                    _logger.log(_modName, "Blocked " + reverted + " progression item(s), save overwritten");
                }
            } catch (err:Error) {
                _isSaving = false;
                _logger.log(_modName, "NormalProgressionBlocker.onSaveSave ERROR: " + err.message + "\n" + err.getStackTrace());
            }
        }

        // -----------------------------------------------------------------------
        // dropIcons processor

        /**
         * Process all AP reward drops from ending.dropIcons and call the appropriate unlocker.
         * Removes all non-AP drops from dropIcons to prevent them from being saved.
         * Called at the end of onSaveSave() after reverting non-AP drops.
         *
         * Expects unlockerRefs object with:
         *   - achievementUnlocker: AchievementUnlocker
         *   - skillUnlocker: SkillUnlocker
         *   - traitUnlocker: TraitUnlocker
         *   - talismanUnlocker: TalismanUnlocker
         *   - shadowCoreUnlocker: ShadowCoreUnlocker
         */
        public static function processApDropIcons(ending:Object, unlockerRefs:Object):void {
            if (ending == null || ending.dropIcons == null) return;

            var drops:Array = ending.dropIcons;
            var apDropsToKeep:Array = []; // Only keep AP drops

            for (var i:int = 0; i < drops.length; i++) {
                var drop:Object = drops[i];
                if (drop == null) continue;

                var isApDrop:Boolean = false;

                try {
                    switch (drop.type) {
                        case AP_ACHIEVEMENT_COLLECTED:
                            // Mark achievement collected and send location check
                            if (unlockerRefs.achievementUnlocker != null) {
                                unlockerRefs.achievementUnlocker.markCollectedAndSendCheck(drop.data);
                            }
                            isApDrop = true;
                            break;

                        case AP_ACHIEVEMENT_SKILL:
                            // Award skill points and unlock skill
                            if (unlockerRefs.achievementUnlocker != null && unlockerRefs.skillUnlocker != null) {
                                var achName:String = drop.meta.achievementName || "";
                                unlockerRefs.achievementUnlocker.awardSkillPointsPublic(achName, drop.meta.achievementData);
                                unlockerRefs.skillUnlocker.unlockSkill(drop.data);
                            }
                            isApDrop = true;
                            break;

                        case AP_ACHIEVEMENT_TRAIT:
                            // Award skill points and unlock trait
                            if (unlockerRefs.achievementUnlocker != null && unlockerRefs.traitUnlocker != null) {
                                unlockerRefs.achievementUnlocker.awardSkillPointsPublic(drop.meta.achievementName || "", drop.meta.achievementData);
                                unlockerRefs.traitUnlocker.unlockBattleTrait(drop.data);
                            }
                            isApDrop = true;
                            break;

                        case AP_ACHIEVEMENT_TALISMAN:
                            // Award skill points and grant talisman
                            if (unlockerRefs.achievementUnlocker != null && unlockerRefs.talismanUnlocker != null) {
                                unlockerRefs.achievementUnlocker.awardSkillPointsPublic(drop.meta.achievementName || "", drop.meta.achievementData);
                                unlockerRefs.talismanUnlocker.grantFragment(drop.data);
                            }
                            isApDrop = true;
                            break;

                        case AP_ACHIEVEMENT_SHADOWCORE:
                            // Award skill points and grant shadow cores
                            if (unlockerRefs.achievementUnlocker != null && unlockerRefs.shadowCoreUnlocker != null) {
                                unlockerRefs.achievementUnlocker.awardSkillPointsPublic(drop.meta.achievementName || "", drop.meta.achievementData);
                                unlockerRefs.shadowCoreUnlocker.grantShadowCores(drop.data);
                            }
                            isApDrop = true;
                            break;

                        case AP_STASH_TALISMAN:
                            // Grant talisman from stash
                            if (unlockerRefs.talismanUnlocker != null) {
                                unlockerRefs.talismanUnlocker.grantFragment(drop.data);
                            }
                            isApDrop = true;
                            break;

                        case AP_STASH_SHADOWCORE:
                            // Grant shadow cores from stash
                            if (unlockerRefs.shadowCoreUnlocker != null) {
                                unlockerRefs.shadowCoreUnlocker.grantShadowCores(drop.data);
                            }
                            isApDrop = true;
                            break;

                        case AP_ITEM_FOR_US:
                            // Item received for us - keep it for display on ending screen
                            isApDrop = true;
                            break;

                        case AP_ITEM_FOR_OTHER:
                            // Item received but sent to another player - keep it for display on ending screen
                            isApDrop = true;
                            break;

                        default:
                            // Game drop (skill tome, trait, field token, map tile, etc.) - don't keep it
                            isApDrop = false;
                            break;
                    }
                } catch (err:Error) {
                    // Error processing drop - treat as non-AP drop
                    isApDrop = false;
                }

                // Only keep AP drops in the array (game drops will be discarded)
                if (isApDrop) {
                    apDropsToKeep.push(drop);
                }
            }

            // Replace dropIcons array with only AP drops (effectively removing game drops)
            ending.dropIcons = apDropsToKeep;
        }

        // -----------------------------------------------------------------------
        // Helpers

        // -----------------------------------------------------------------------
        // Level-end drop icon construction

        /**
         * Build the ending-screen drop icons from items SENT OUT when we checked locations.
         *
         * Flow:
         * 1. checkCompletedLocations() sends location checks to AP, stores them in lastCheckedLocations
         * 2. AP server responds with ItemSend PrintJSON (what item was at each location, who it goes to)
         * 3. ConnectionManager.handlePrintJSON() tracks these in itemsSentThisLevel[locationId]
         * 4. buildLevelEndIcons() matches checked locations with sent items, builds icons
         *
         * Must run AFTER both:
         * - checkCompletedLocations() populates lastCheckedLocations
         * - ItemSend PrintJSON messages arrive and populate itemsSentThisLevel
         */
        private function buildLevelEndIcons(ending:*):void {
            try {
                // Clear all existing game icons (field-token / map-tile sprites)
                ending.removeAllDropIcons();

                var icons:Array = [];
                var sentItems:Object = _connectionManager != null ? _connectionManager.itemsSentThisLevel : null;

                // Icons for stage locations we checked this level
                if (_connectionManager != null) {
                    var checked:Array = _connectionManager.lastCheckedLocations;

                    for (var c:int = 0; c < checked.length; c++) {
                        var loc:Object = checked[c];
                        var locId:int = getLocationIdFromStrIdAndType(String(loc.strId), String(loc.locType));

                        if (sentItems != null && sentItems[locId] != null) {
                            var itemIcon:* = buildIconForSentItem(sentItems[locId]);
                            if (itemIcon != null)
                                icons.push(itemIcon);
                        } else {
                            _logger.log(_modName, "buildLevelEndIcons: no item data for locId " + locId + " (not yet received from AP)");
                        }
                    }
                }

                // Icons for achievements checked this level
                if (_achievementUnlocker != null) {
                    var pendingAchievements:Array = _achievementUnlocker.pendingLevelAchievements;
                    for (var a:int = 0; a < pendingAchievements.length; a++) {
                        var achEntry:Object = pendingAchievements[a];
                        var achLocId:int = int(achEntry.apId);
                        var achIcon:ApItemIcon;
                        if (sentItems != null && sentItems[achLocId] != null) {
                            achIcon = buildIconForSentItem(sentItems[achLocId]);
                        } else {
                            achIcon = new ApItemIcon("Sent: " + String(achEntry.achievementName) + " \u2192 ?");
                        }
                        achIcon.locationId = achLocId;
                        icons.push(achIcon);
                    }
                    _achievementUnlocker.clearPendingLevelAchievements();
                }

                if (icons.length == 0) return;

                // Position icons using the same centering formula as prepareDropIcons
                var n:int = icons.length;
                var xOffset:Number = n < 13 ? 70 * (13 - n) : 0;

                for (var i:int = 0; i < n; i++) {
                    var icon:* = icons[i];
                    icon.x = 48 + i * 140 + xOffset;
                    icon.y = 789;
                    icon.visible = false;
                    ending.cnt.mcOutcomePanel.addChild(icon);
                    ending.dropIcons.push(icon);

                    if (icon is McDropIconOutcome) {
                        icon.addEventListener(MouseEvent.MOUSE_OVER, onGameIconOver, false, 0, true);
                        icon.addEventListener(MouseEvent.MOUSE_OUT, onIconOut, false, 0, true);
                    } else {
                        icon.addEventListener(MouseEvent.MOUSE_OVER, onApIconOver, false, 0, true);
                        icon.addEventListener(MouseEvent.MOUSE_OUT, onIconOut, false, 0, true);
                    }
                }
                _logger.log(_modName, "buildLevelEndIcons: added " + n + " icons");
            } catch (err:Error) {
                _logger.log(_modName, "buildLevelEndIcons ERROR: " + err.message + "\n" + err.getStackTrace());
            }
        }

        /** Convert strId + locType back to the AP location ID. */
        private function getLocationIdFromStrIdAndType(strId:String, locType:String):int {
            var baseId:int = int(AV.gameData.stageLocIds[strId]);
            if (locType == "journey") return baseId;
            if (locType == "bonus") return baseId + 199;
            if (locType == "stash") return baseId + 399;
            return -1;
        }

        /** Build an icon for a sent item, with recipient info in tooltip. */
        private function buildIconForSentItem(sentData:Object):* {
            var itemName:String = String(sentData.itemName || "Item");
            var receivingName:String = String(sentData.receivingName || "?");
            return new ApItemIcon(itemName + " \u2192 " + receivingName);
        }

        /** Extract the skill-point count from an AP_ACHIEVEMENT_SKILL drop's meta object. */
        private function parseAchievementSkillPoints(meta:Object):int {
            if (meta == null || meta.achievementData == null || meta.achievementName == null)
                return 1;
            var achInfo:Object = meta.achievementData[meta.achievementName];
            if (achInfo == null || achInfo.reward == null) return 1;
            var reward:String = String(achInfo.reward);
            if (reward.indexOf("skillPoints:") == 0)
                return int(reward.substring(12));
            return 1;
        }

        /** Find the integer index of a stage in stageMetas by strId. Returns -1 if not found. */
        private function findStageIndex(strId:String):int {
            if (GV.stageCollection == null) return -1;
            var metas:Array = GV.stageCollection.stageMetas;
            if (metas == null) return -1;
            for (var i:int = 0; i < metas.length; i++) {
                var meta:* = metas[i];
                if (meta != null && String(meta.strId) == strId)
                    return i;
            }
            return -1;
        }

        /** MOUSE_OVER for McDropIconOutcome icons — uses the game's info-panel renderer. */
        private function onGameIconOver(e:MouseEvent):void {
            try {
                var icon:McDropIconOutcome = e.currentTarget as McDropIconOutcome;
                if (icon != null)
                    GV.ingameController.core.infoPanelRenderer2.renderDropIconInfoPanel(icon);
            } catch (err:Error) {
                _logger.log(_modName, "onGameIconOver ERROR: " + err.message);
            }
        }

        /** MOUSE_OVER for ApItemIcon — shows tooltipText in McInfoPanel, with lazy sent-item lookup. */
        private function onApIconOver(e:MouseEvent):void {
            try {
                var icon:ApItemIcon = e.currentTarget as ApItemIcon;
                if (icon == null) return;

                // For achievement icons: check if the AP server has since responded with who got what
                if (icon.locationId > 0 && _connectionManager != null) {
                    var sentItems:Object = _connectionManager.itemsSentThisLevel;
                    if (sentItems != null && sentItems[icon.locationId] != null) {
                        var sentData:Object = sentItems[icon.locationId];
                        var itemName:String = String(sentData.itemName || "Item");
                        var receivingName:String = String(sentData.receivingName || "?");
                        icon.tooltipText = itemName + " \u2192 " + receivingName;
                    }
                }

                var vIp:* = GV.mcInfoPanel;
                vIp.reset(260);
                vIp.addTextfield(0xFFD700, icon.tooltipText, false, 12);
                GV.main.cntInfoPanel.addChild(vIp);
                vIp.doEnterFrame();
            } catch (err:Error) {
                _logger.log(_modName, "onApIconOver ERROR: " + err.message);
            }
        }

        /** MOUSE_OUT for all test icons — hides McInfoPanel. */
        private function onIconOut(e:MouseEvent):void {
            try {
                GV.main.cntInfoPanel.removeChild(GV.mcInfoPanel);
            } catch (err:Error) {}
        }

        // -----------------------------------------------------------------------
        // Helpers (non-test)

        /**
         * Remove a plus-node indicator from the selector mc, if it is currently displayed.
         * nodeName is "mcPlusNodeSkills" or "mcPlusNodeTalisman".
         */
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

        /**
         * Remove the first talisman fragment with the given seed from the inventory.
         * Returns true if a fragment was found and removed.
         */
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
