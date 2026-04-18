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
                            achIcon = _buildSentItemIcon(sentItems[achLocId]);
                        } else {
                            achIcon = new ApItemIcon("Sent: " + String(achEntry.achievementName) + " \u2192 ?");
                        }
                        achIcon.locationId = achLocId;
                        icons.push(achIcon);
                    }
                    _achievementUnlocker.clearPendingLevelAchievements();
                }

                if (icons.length == 0 && _preservedBattleIcons.length == 0) return;

                var n:int = icons.length;
                var xOffset:Number = n < 13 ? 70 * (13 - n) : 0;

                for (var k:int = 0; k < n; k++) {
                    var icon:ApItemIcon = icons[k];
                    icon.x = 48 + k * 140 + xOffset;
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
         * Create an ApItemIcon using the cached native game bitmap for the item type,
         * or fall back to the generic AP icon if no cached bitmap is available.
         */
        private function _makeApIcon(label:String, itemName:String):ApItemIcon {
            var gcfwType:int = _detectGcfwDropType(itemName);
            var cachedBmpd:BitmapData = (gcfwType > 0) ? (_iconBitmapCache[gcfwType] as BitmapData) : null;
            return new ApItemIcon(label, cachedBmpd);
        }

        /**
         * Detect which GCFW drop type an item name corresponds to.
         * Returns the DropType int, or -1 if the item is from another game / unrecognised.
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

        /** Centre-align all icons across the ending screen row. */
        private function repositionIcons(icons:Array):void {
            var n:int = icons.length;
            var xOff:Number = n < 13 ? 70 * (13 - n) : 0;
            for (var i:int = 0; i < n; i++) {
                icons[i].x = 48 + i * 140 + xOff;
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
