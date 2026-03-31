package unlockers {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import ui.ItemToastPanel;

    /**
     * Grants Archipelago shadow core items to the player.
     *
     * AP item IDs 754–770: location-specific shadow core drops, each named "{str_id} Shadow Cores".
     * AP item ID 503:      generic "Shadow Core" (fixed amount, used as filler).
     *
     * The shadow_core_map (AP ID string → amount) is loaded from slot_data on connect.
     * Shadow cores accumulate additively.  To avoid double-granting on reconnect/full-sync,
     * the total already granted is tracked in totalGranted (persisted via SaveManager).
     *
     * NOTE: Wizard stashes currently still grant their shadow core rewards normally (they are
     * not yet blocked by NormalProgressionBlocker).  This means the player will receive
     * shadow cores twice — once from the stash and once from AP — until blocking is added.
     */
    public class ShadowCoreUnlocker {

        private var _logger:Logger;
        private var _modName:String;
        private var _itemToast:ItemToastPanel;
        private var _shadowCoreMap:Object;     // AP ID string → int amount
        private var _shadowCoreNameMap:Object; // AP ID string → display name
        private var _totalGranted:int = 0;     // total AP-granted shadow cores; persisted via SaveManager

        public function ShadowCoreUnlocker(logger:Logger, modName:String, itemToast:ItemToastPanel) {
            _logger    = logger;
            _modName   = modName;
            _itemToast = itemToast;
        }

        /** Called by SaveManager on load to restore persisted total. */
        public function get totalGranted():int { return _totalGranted; }
        public function set totalGranted(v:int):void { _totalGranted = v; }

        /** Called with slot_data.shadow_core_map on AP connect. */
        public function setShadowCoreMap(map:Object):void { _shadowCoreMap = map; }

        /** Called with slot_data.shadow_core_name_map on AP connect. */
        public function setShadowCoreNameMap(map:Object):void { _shadowCoreNameMap = map; }

        // -----------------------------------------------------------------------
        // Incremental grant (ReceivedItems index > 0)

        /**
         * Grant shadow cores for a single received AP item.
         * Adds the mapped amount to GV.ppd.shadowCoreAmount and updates totalGranted.
         */
        public function grantShadowCores(apId:int):void {
            var amount:int = amountForApId(apId);
            if (amount <= 0) return;
            if (GV.ppd == null) {
                _logger.log(_modName, "grantShadowCores: GV.ppd null, cannot grant apId=" + apId);
                return;
            }
            GV.ppd.shadowCoreAmount.s(GV.ppd.shadowCoreAmount.g() + amount);
            _totalGranted += amount;
            var label:String = (_shadowCoreNameMap != null && _shadowCoreNameMap[String(apId)] != null)
                ? String(_shadowCoreNameMap[String(apId)])
                : "Shadow Cores";
            _itemToast.addItem("Found " + label + " (+" + amount + ")", 0x88AAFF);
            _logger.log(_modName, "Granted shadow cores apId=" + apId
                + " amount=" + amount + " totalGranted=" + _totalGranted);
        }

        // -----------------------------------------------------------------------
        // Full sync (ReceivedItems index == 0)

        /**
         * Recalculate the correct total shadow cores from the full AP item list
         * and grant only the delta since last save.
         * Call after resetGrants().
         */
        public function syncShadowCores(apIds:Array):void {
            var newTotal:int = 0;
            for each (var apId:int in apIds) {
                newTotal += amountForApId(apId);
            }
            var delta:int = newTotal - _totalGranted;
            if (delta > 0) {
                if (GV.ppd != null) {
                    GV.ppd.shadowCoreAmount.s(GV.ppd.shadowCoreAmount.g() + delta);
                }
                _logger.log(_modName, "syncShadowCores: delta=" + delta
                    + " newTotal=" + newTotal + " prevGranted=" + _totalGranted);
            }
            _totalGranted = newTotal;
        }

        // -----------------------------------------------------------------------
        // Helpers

        private function amountForApId(apId:int):int {
            if (_shadowCoreMap != null) {
                var mapped:* = _shadowCoreMap[String(apId)];
                if (mapped != null) return int(mapped);
            }
            return 0;
        }
    }
}
