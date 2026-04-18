package ui {
    import flash.events.MouseEvent;

    import Bezel.Logger;

    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.mcDyn.McDropIconOutcome;

    import data.AV;

    /**
     * Builds and manages the AP drop icons on the level-end screen.
     *
     * Handles three kinds of icons:
     *   - Achievement checks sent out this level (built at save time via buildIcons)
     *   - Location checks sent to other players (added live via addSentItemToEndingScreen)
     *   - Items received from AP during this level (added live via addItemToActiveEndingScreen)
     *
     * buildIcons() is called by ProgressionBlocker at the end of the SAVE_SAVE handler,
     * after all progression reversions have run.
     */
    public class LevelEndScreenBuilder {

        private var _logger:Logger;
        private var _modName:String;
        private var _achievementUnlocker:*;
        private var _connectionManager:*;

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
        // Called at save time (by ProgressionBlocker)

        /**
         * Replace the game's automatic drop icons with AP achievement icons for this level.
         * Called from ProgressionBlocker.onSaveSave() after all progression reversions.
         */
        public function buildIcons(ending:*):void {
            try {
                ending.removeAllDropIcons();

                var icons:Array = [];
                var sentItems:Object = _connectionManager != null ? _connectionManager.itemsSentThisLevel : null;

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
                _logger.log(_modName, "LevelEndScreenBuilder.buildIcons: added " + n + " icons");
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

                var icon:ApItemIcon = new ApItemIcon(itemName + " \u2192 " + receivingName);
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
         * Called from ArchipelagoMod.grantItem().
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

        /** Centre-align all icons across the ending screen row. */
        private function repositionIcons(icons:Array):void {
            var n:int = icons.length;
            var xOff:Number = n < 13 ? 70 * (13 - n) : 0;
            for (var i:int = 0; i < n; i++) {
                icons[i].x = 48 + i * 140 + xOff;
            }
        }

        private function buildIconForSentItem(sentData:Object):ApItemIcon {
            var itemName:String = String(sentData.itemName || "Item");
            var receivingName:String = String(sentData.receivingName || "?");
            return new ApItemIcon(itemName + " \u2192 " + receivingName);
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
