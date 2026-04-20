package ui {
    import flash.display.BitmapData;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import Bezel.Logger;

    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.DropType;
    import com.giab.games.gcfw.entity.TalismanFragment;
    import com.giab.games.gcfw.mcDyn.McDropIconOutcome;

    import data.AV;

    /**
     * Builds and manages the AP drop icons on the level-end screen.
     *
     * Handles three kinds of icons:
     *   - Achievement checks sent out this level (built at save time via buildIcons)
     *   - Location checks sent to other players (added live via addSentItemToEndingScreen)
     *   - In-battle talisman and shadow-core drops (preserved and re-added)
     *
     * buildIcons() is called by ProgressionBlocker at the end of the SAVE_SAVE handler,
     * after all progression reversions have run.
     *
     * Static bitmap cache: keyed by DropType int, persists for the entire game session.
     * Pre-populated at selector time via preCacheIcons().
     */
    public class LevelEndScreenBuilder {

        private var _logger:Logger;
        private var _modName:String;
        private var _achievementUnlocker:*;
        private var _connectionManager:*;

        // DropType int → cloned BitmapData. Static so it survives across battles.
        private static var _iconBitmapCache:Object = {};

        // McDropIconOutcome icons saved from the game's ending.dropIcons to re-add at the end.
        private var _preservedBattleIcons:Array = [];

        public function LevelEndScreenBuilder(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        /**
         * Wire in subsystems that become available after construction.
         * Call from ArchipelagoMod once both are initialised.
         */
        public function configure(achievementUnlocker:*, connectionManager:*):void {
            _achievementUnlocker = achievementUnlocker;
            _connectionManager   = connectionManager;
        }

        // -----------------------------------------------------------------------
        // Pre-caching

        /**
         * Pre-populate the static bitmap cache by constructing one McDropIconOutcome
         * per known GCFW drop type. Call once from ArchipelagoMod when the selector
         * is ready (GV.stageCollection and GV.ppd are non-null).
         *
         * SKILL_TOME and BATTLETRAIT_SCROLL need no data — always cached.
         * SHADOW_CORE needs an amount — always cached (uses amount=1).
         * FIELD_TOKEN needs a stage meta id — cached from first available stage meta.
         * TALISMAN_FRAGMENT needs a TalismanFragment — cached only if inventory is non-empty.
         */
        public static function preCacheIcons():void {
            try {
                if (_iconBitmapCache[DropType.SKILL_TOME] == null) {
                    var sk:McDropIconOutcome = new McDropIconOutcome(DropType.SKILL_TOME, null);
                    _iconBitmapCache[DropType.SKILL_TOME] = sk.bmpdIcon.clone();
                }

                if (_iconBitmapCache[DropType.BATTLETRAIT_SCROLL] == null) {
                    var bt:McDropIconOutcome = new McDropIconOutcome(DropType.BATTLETRAIT_SCROLL, null);
                    _iconBitmapCache[DropType.BATTLETRAIT_SCROLL] = bt.bmpdIcon.clone();
                }

                if (_iconBitmapCache[DropType.SHADOW_CORE] == null) {
                    var sc:McDropIconOutcome = new McDropIconOutcome(DropType.SHADOW_CORE, 1);
                    _iconBitmapCache[DropType.SHADOW_CORE] = sc.bmpdIcon.clone();
                }

                if (_iconBitmapCache[DropType.FIELD_TOKEN] == null && GV.stageCollection != null) {
                    var metas:Array = GV.stageCollection.stageMetas;
                    for (var i:int = 0; i < metas.length; i++) {
                        if (metas[i] != null) {
                            var ft:McDropIconOutcome = new McDropIconOutcome(DropType.FIELD_TOKEN, int(metas[i].id));
                            _iconBitmapCache[DropType.FIELD_TOKEN] = ft.bmpdIcon.clone();
                            break;
                        }
                    }
                }

                if (_iconBitmapCache[DropType.TALISMAN_FRAGMENT] == null && GV.ppd != null) {
                    var inv:Array = GV.ppd.talismanInventory;
                    for (var j:int = 0; j < inv.length; j++) {
                        if (inv[j] != null) {
                            var tal:McDropIconOutcome = new McDropIconOutcome(DropType.TALISMAN_FRAGMENT, inv[j]);
                            _iconBitmapCache[DropType.TALISMAN_FRAGMENT] = tal.bmpdIcon.clone();
                            break;
                        }
                    }
                }
            } catch (err:Error) {
                // Logged externally; don't crash the mod if pre-caching fails.
            }
        }

        // -----------------------------------------------------------------------
        // Called at save time (by ProgressionBlocker)

        /**
         * Replace the game's automatic drop icons with AP icons for this level.
         * Called from ProgressionBlocker.onSaveSave() after all progression reversions.
         *
         * Flow:
         *  1. Scan existing icons — opportunistically fill cache, preserve in-battle
         *     talisman/shadow-core icons, dispose the rest.
         *  2. Clear ending.dropIcons.
         *  3. Build AP achievement / sent-item icons.
         *  4. Re-add preserved in-battle icons at the end.
         */
        public function buildIcons(ending:*):void {
            try {
                _preservedBattleIcons = [];

                // --- Step 1: scan and categorise existing icons ---
                var existingIcons:Array = ending.dropIcons;
                for (var i:int = 0; i < existingIcons.length; i++) {
                    var di:* = existingIcons[i];
                    if (di == null) continue;

                    // Opportunistically cache the bitmap for this drop type.
                    if (di.bmpdIcon != null && _iconBitmapCache[di.type] == null) {
                        try { _iconBitmapCache[di.type] = BitmapData(di.bmpdIcon).clone(); } catch (ce:Error) {}
                    }

                    if (di.type == DropType.TALISMAN_FRAGMENT) {
                        if (_isTalismanInInventory(di.data)) {
                            // In-battle talisman — preserve it.
                            ending.cnt.mcOutcomePanel.removeChild(di);
                            _preservedBattleIcons.push(di);
                        } else {
                            // Stash talisman already blocked from inventory — dispose.
                            _disposeIcon(di, ending);
                        }
                    } else if (di.type == DropType.SHADOW_CORE) {
                        // Keep all shadow-core icons; can't distinguish stash vs battle.
                        ending.cnt.mcOutcomePanel.removeChild(di);
                        _preservedBattleIcons.push(di);
                    } else {
                        // Field tokens, map tiles, skills, traits, previous AP icons — dispose.
                        _disposeIcon(di, ending);
                    }
                }

                // --- Step 2: clear the array ---
                ending.dropIcons = new Array();

                // --- Step 3: build AP icons ---
                var icons:Array = [];
                var sentItems:Object = _connectionManager != null ? _connectionManager.itemsSentThisLevel : null;

                if (_achievementUnlocker != null) {
                    var pendingAchievements:Array = _achievementUnlocker.pendingLevelAchievements;
                    for (var a:int = 0; a < pendingAchievements.length; a++) {
                        var achEntry:Object = pendingAchievements[a];
                        var achLocId:int = int(achEntry.apId);
                        var achIcon:ApItemIcon;
                        if (sentItems != null && sentItems[achLocId] != null) {
                            // Server already told us what item was sent — show that item's icon.
                            var achSentData:Object = sentItems[achLocId];
                            achIcon = _buildSentItemIcon(achSentData);
                            achIcon.sortOrder = _sortOrderForSentItem(achSentData);
                        } else {
                            // Still waiting for the server — use the achievement's icon as a placeholder.
                            var achBmpd:BitmapData = _getAchievementBitmapByGameId(int(achEntry.gameId));
                            achIcon = new ApItemIcon("Sent: " + String(achEntry.achievementName) + " \u2192 ?", achBmpd);
                            achIcon.sortOrder = 6;
                        }
                        achIcon.locationId = achLocId;
                        icons.push(achIcon);
                    }
                    _achievementUnlocker.clearPendingLevelAchievements();
                }

                if (icons.length == 0 && _preservedBattleIcons.length == 0) return;

                // Add AP achievement icons to the display list.
                for (var k:int = 0; k < icons.length; k++) {
                    var icon:ApItemIcon = icons[k];
                    icon.y = 789;
                    icon.visible = false;
                    ending.cnt.mcOutcomePanel.addChild(icon);
                    ending.dropIcons.push(icon);
                    icon.addEventListener(MouseEvent.MOUSE_OVER, onApIconOver, false, 0, true);
                    icon.addEventListener(MouseEvent.MOUSE_OUT, onIconOut, false, 0, true);
                }

                // --- Step 4: re-add preserved in-battle icons ---
                var preservedCount:int = _preservedBattleIcons.length;
                for (var p:int = 0; p < preservedCount; p++) {
                    var preserved:* = _preservedBattleIcons[p];
                    preserved.y = 789;
                    preserved.visible = false;
                    ending.cnt.mcOutcomePanel.addChild(preserved);
                    ending.dropIcons.push(preserved);
                    preserved.addEventListener(MouseEvent.MOUSE_OVER, onGameIconOver, false, 0, true);
                    preserved.addEventListener(MouseEvent.MOUSE_OUT, onIconOut, false, 0, true);
                }
                _preservedBattleIcons = [];

                // Sort by priority and lay out all icons.
                repositionIcons(ending.dropIcons);

                _logger.log(_modName, "LevelEndScreenBuilder.buildIcons: "
                    + icons.length + " AP icons, "
                    + preservedCount + " preserved game icons");
            } catch (err:Error) {
                _logger.log(_modName, "LevelEndScreenBuilder.buildIcons ERROR: " + err.message + "\n" + err.getStackTrace());
            }
        }

        // -----------------------------------------------------------------------
        // Called live (by ArchipelagoMod) as the AP server responds

        /**
         * Add a sent-item icon to the ending screen when AP tells us who received the item.
         * Called from ArchipelagoMod.onItemSentFromLocation.
         */
        public function addSentItemToEndingScreen(locId:int, itemName:String, receivingName:String):void {
            try {
                if (GV.ingameController == null || GV.ingameController.core == null) return;
                var ending:* = GV.ingameController.core.ending;
                if (ending == null || ending.dropIcons == null || !ending.isBattleWon) return;

                var icon:ApItemIcon = _makeApIcon(itemName + " \u2192 " + receivingName, itemName);
                icon.locationId = locId;
                var sentData:Object = (_connectionManager != null) ? _connectionManager.itemsSentThisLevel[locId] : null;
                icon.sortOrder = (sentData != null) ? _sortOrderForSentItem(sentData) : 10;
                icon.y = 789;
                icon.visible = false;
                ending.cnt.mcOutcomePanel.addChild(icon);
                ending.dropIcons.push(icon);
                icon.addEventListener(MouseEvent.MOUSE_OVER, onApIconOver, false, 0, true);
                icon.addEventListener(MouseEvent.MOUSE_OUT, onIconOut, false, 0, true);

                repositionIcons(ending.dropIcons);
                _logger.log(_modName, "addSentItemToEndingScreen: " + itemName + " \u2192 " + receivingName + " (locId=" + locId + ")");
            } catch (err:Error) {
                _logger.log(_modName, "addSentItemToEndingScreen ERROR: " + err.message);
            }
        }

        /**
         * Add an AP item icon to the still-open ending screen.
         * Used for items that arrive from the server after onSaveSave() has already run.
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

                repositionIcons(ending.dropIcons);
                _logger.log(_modName, "addItemToActiveEndingScreen: " + itemName + " (AP ID " + apId + ")");
            } catch (err:Error) {
                _logger.log(_modName, "addItemToActiveEndingScreen ERROR: " + err.message);
            }
        }

        /** Track an item received from AP during this level (for display on the ending screen). */
        public function trackReceivedItem(apId:int, itemName:String = "", sentToPlayer:String = "You", isForUs:Boolean = true):void {
            if (itemName == "") itemName = "Item " + apId;
            _logger.log(_modName, "TRACKED ITEM: " + itemName + " (AP ID " + apId + ")");
        }

        // -----------------------------------------------------------------------
        // Private helpers

        /**
         * Build an ApItemIcon for a sent item, using the cached native bitmap when available.
         */
        private function _buildSentItemIcon(sentData:Object):ApItemIcon {
            var itemName:String = String(sentData.itemName || "Item");
            var receivingName:String = String(sentData.receivingName || "?");
            return _makeApIcon(itemName + " \u2192 " + receivingName, itemName);
        }

        /**
         * Create an ApItemIcon using the native game bitmap for the item type.
         * Achievements are constructed on-demand (each has a unique icon).
         * Other GCFW types use the static pre-populated cache.
         * Falls back to the generic AP icon if no bitmap is available.
         */
        private function _makeApIcon(label:String, itemName:String):ApItemIcon {
            var gcfwType:int = _detectGcfwDropType(itemName);
            var bmpd:BitmapData = (gcfwType > 0) ? (_iconBitmapCache[gcfwType] as BitmapData) : null;
            return new ApItemIcon(label, bmpd);
        }

        /**
         * Detect which GCFW drop type an item name corresponds to.
         * Returns the DropType int, or -1 if the item is from another game / unrecognised.
         *
         * Note: achievements are intentionally excluded here. Achievement icons are
         * applied directly in buildIcons() where we have the exact achievement name.
         * Doing a name lookup here causes false positives (achievement titles like "H5"
         * or "V4" accidentally match AP item names).
         */
        private function _detectGcfwDropType(itemName:String):int {
            if (itemName == null) return -1;
            var lower:String = itemName.toLowerCase();
            if (_endsWith(lower, " field token"))    return DropType.FIELD_TOKEN;
            if (lower.indexOf("talisman") >= 0)      return DropType.TALISMAN_FRAGMENT;
            if (lower.indexOf("shadow core") >= 0)   return DropType.SHADOW_CORE;
            if (_endsWith(lower, " skill"))           return DropType.SKILL_TOME;
            if (_endsWith(lower, " battle trait"))    return DropType.BATTLETRAIT_SCROLL;
            return -1;
        }

        private function _endsWith(str:String, suffix:String):Boolean {
            if (str.length < suffix.length) return false;
            return str.substr(str.length - suffix.length) == suffix;
        }

        /**
         * Construct the native achievement drop icon bitmap for a given game achievement ID.
         * The ID comes directly from ach.id in GV.achiCollection.achisByOrder — no name lookup needed.
         * Returns null if gameId is invalid (≤0) or McDropIconOutcome throws.
         */
        private function _getAchievementBitmapByGameId(gameId:int):BitmapData {
            if (gameId <= 0) return null;
            try {
                var icon:McDropIconOutcome = new McDropIconOutcome(DropType.ACHIEVEMENT, gameId);
                return icon.bmpdIcon.clone();
            } catch (err:Error) {
                return null;
            }
        }

        /**
         * Check whether a talisman (icon.data) is still present in GV.ppd.talismanInventory.
         * Stash talismans are removed from inventory by ProgressionBlocker before buildIcons runs.
         */
        private function _isTalismanInInventory(data:Object):Boolean {
            if (GV.ppd == null || data == null) return false;
            return GV.ppd.talismanInventory.indexOf(data) >= 0;
        }

        /**
         * Dispose an icon the same way ending.removeAllDropIcons() would.
         * Does NOT remove from ending.dropIcons (caller clears the array separately).
         */
        private function _disposeIcon(icon:*, ending:*):void {
            try {
                icon.data = null;
                icon.cntInner.removeChildren();
                icon.bmpIcon = null;
                BitmapData(icon.bmpdIcon).dispose();
                ending.cnt.mcOutcomePanel.removeChild(icon);
            } catch (err:Error) {}
        }

        /**
         * Sort by sortOrder then centre-align across the ending-screen row.
         * Mutates the icons array in place (game code holds a reference to the same array).
         */
        private function repositionIcons(icons:Array):void {
            icons.sort(_compareIconOrder);
            var n:int = icons.length;
            var xOff:Number = n < 13 ? 70 * (13 - n) : 0;
            for (var i:int = 0; i < n; i++) {
                icons[i].x = 48 + i * 140 + xOff;
            }
        }

        private function _compareIconOrder(a:*, b:*):int {
            return _iconSortOrder(a) - _iconSortOrder(b);
        }

        /**
         * Return the sort priority for any icon in ending.dropIcons.
         * ApItemIcon carries a typed sortOrder property.
         * McDropIconOutcome (preserved battle icons) are identified by their DropType.
         */
        private function _iconSortOrder(icon:*):int {
            if (icon == null) return 10;
            if (icon is ApItemIcon) return int((icon as ApItemIcon).sortOrder);
            // Preserved game icon — derive order from DropType (always our in-battle item).
            var t:int = int(icon.type);
            if (t == DropType.TALISMAN_FRAGMENT) return 4;
            if (t == DropType.SHADOW_CORE)        return 5;
            return 10;
        }

        /**
         * Determine the sort order for an item in itemsSentThisLevel.
         * Items going to us are sorted by type (1-5); items going to others get 10.
         */
        private function _sortOrderForSentItem(sentData:Object):int {
            if (sentData == null) return 10;
            var isOurs:Boolean = (_connectionManager != null)
                && (int(sentData.receivingSlot) == _connectionManager.mySlot);
            if (!isOurs) return 10;
            return _gcfwTypeToSortOrder(_detectGcfwDropType(String(sentData.itemName || "")));
        }

        /**
         * Map a DropType constant to a sort-order slot for "our" items.
         * Returns 9 for unrecognised GCFW items (XP tomes, etc.) that still belong to us.
         */
        private function _gcfwTypeToSortOrder(gcfwType:int):int {
            switch (gcfwType) {
                case DropType.FIELD_TOKEN:        return 1;
                case DropType.SKILL_TOME:         return 2;
                case DropType.BATTLETRAIT_SCROLL: return 3;
                case DropType.TALISMAN_FRAGMENT:  return 4;
                case DropType.SHADOW_CORE:        return 5;
                default:                          return 9; // our item, unknown type
            }
        }

        private function onGameIconOver(e:MouseEvent):void {
            try {
                var icon:McDropIconOutcome = e.currentTarget as McDropIconOutcome;
                if (icon != null)
                    GV.ingameController.core.infoPanelRenderer2.renderDropIconInfoPanel(icon);
            } catch (err:Error) {
                _logger.log(_modName, "onGameIconOver ERROR: " + err.message);
            }
        }

        private function onApIconOver(e:MouseEvent):void {
            try {
                var icon:ApItemIcon = e.currentTarget as ApItemIcon;
                if (icon == null) return;

                if (icon.locationId > 0) {
                    var checkName:String = AV.archipelagoData.getCheckName(icon.locationId, null);
                    if (checkName != null) icon.tooltipText = checkName;
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

        private function onIconOut(e:MouseEvent):void {
            try {
                GV.main.cntInfoPanel.removeChild(GV.mcInfoPanel);
            } catch (err:Error) {}
        }
    }
}
