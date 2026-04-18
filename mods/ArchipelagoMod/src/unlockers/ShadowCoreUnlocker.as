package unlockers {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import flash.utils.getDefinitionByName;
    import ui.ItemToastPanel;
    import utils.ApIdMapper;

    /**
     * Grants Archipelago shadow core items to the player.
     *
     * AP item IDs 1000–1016: location-specific shadow core drops, each named "{str_id} Shadow Cores".
     * AP item ID 503:        generic "Shadow Core" (fixed amount, used as filler).
     *
     * The shadow_core_map (AP ID string → amount) is loaded from slot_data on connect.
     * Shadow cores accumulate additively.  To avoid double-granting on reconnect/full-sync,
     * the total already granted is tracked in totalGranted (persisted via SaveManager).
     *
     * NOTE: Wizard stashes currently still grant their shadow core rewards normally (they are
     * not yet blocked by NormalProgressionBlocker).  This means the player will receive
     * shadow cores twice — once from the stash and once from AP — until blocking is added.
     */
    public class ShadowCoreUnlocker extends BaseUnlocker {

        private var _shadowCoreMapper:ApIdMapper;  // AP ID → int amount
        private var _shadowCoreNameMap:Object;     // AP ID string → display name
        private var _totalGranted:int = 0;         // total AP-granted shadow cores; persisted via SaveManager

        public function ShadowCoreUnlocker(logger:Logger, modName:String, itemToast:ItemToastPanel) {
            super(logger, modName, itemToast);
            _shadowCoreMapper = null;
        }

        /** Called by SaveManager on load to restore persisted total. */
        public function get totalGranted():int { return _totalGranted; }
        public function set totalGranted(v:int):void { _totalGranted = v; }

        /** Called with slot_data.shadow_core_map on AP connect. */
        public function setShadowCoreMap(map:Object):void { _shadowCoreMapper = new ApIdMapper(map); }

        /** Called with slot_data.shadow_core_name_map on AP connect. */
        public function setShadowCoreNameMap(map:Object):void { _shadowCoreNameMap = map; }

        // -----------------------------------------------------------------------
        // Incremental grant (ReceivedItems index > 0)

        /**
         * Grant shadow cores for a single received AP item.
         * Adds the mapped amount to GV.ppd.shadowCoreAmount and updates totalGranted.
         */
        public function grantShadowCores(apId:int):void {
            var amount:int = _shadowCoreMapper != null ? int(_shadowCoreMapper.getValue(apId, 0)) : 0;
            if (amount <= 0) return;
            if (!ensurePpdExists("grantShadowCores")) {
                return;
            }
            var oldAmount:Number = GV.ppd.shadowCoreAmount.g();
            GV.ppd.shadowCoreAmount.s(oldAmount + amount);
            _totalGranted += amount;
            var label:String = (_shadowCoreNameMap != null && _shadowCoreNameMap[String(apId)] != null)
                ? String(_shadowCoreNameMap[String(apId)])
                : "Shadow Cores";
            showToast("Found " + label + " (+" + amount + ")", 0x88AAFF);
            logAction("Granted shadow cores apId=" + apId
                + " amount=" + amount + " totalGranted=" + _totalGranted);
            pushSelectorEvent(5, [oldAmount, oldAmount + amount]); // 5 = SC_INCREASING
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
                newTotal += _shadowCoreMapper != null ? int(_shadowCoreMapper.getValue(apId, 0)) : 0;
            }
            var delta:int = newTotal - _totalGranted;
            if (delta > 0) {
                if (GV.ppd != null) {
                    GV.ppd.shadowCoreAmount.s(GV.ppd.shadowCoreAmount.g() + delta);
                }
                logAction("syncShadowCores: delta=" + delta
                    + " newTotal=" + newTotal + " prevGranted=" + _totalGranted);
            }
            _totalGranted = newTotal;
        }

        // -----------------------------------------------------------------------
        // Helpers

        /**
         * Push a SelectorEvent to GV.selectorCore.eventQueue, triggering UPDATING_STAGES
         * if the selector is currently idle so the animation plays immediately.
         */
        private function pushSelectorEvent(type:int, args:Array):void {
            try {
                var core:* = GV.selectorCore;
                if (core == null) return;
                var SelectorEventClass:Class = getDefinitionByName("com.giab.games.gcfw.struct.SelectorEvent") as Class;
                core.eventQueue.push(new SelectorEventClass(type, args));
                if (core.screenStatus == 4) core.screenStatus = 3; // STAGES_IDLE → UPDATING_STAGES
            } catch (err:Error) {
                _logger.log(_modName, "pushSelectorEvent error: " + err.message);
            }
        }
    }
}
