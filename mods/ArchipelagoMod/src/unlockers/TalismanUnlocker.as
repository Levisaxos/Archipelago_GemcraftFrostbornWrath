package unlockers {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.entity.TalismanFragment;
    import ui.ItemToastPanel;

    /**
     * Grants Archipelago talisman fragment items to the player's talisman inventory.
     *
     * AP item IDs 700–752: location-specific fragments, each named "{str_id} Talisman Fragment".
     * AP item ID 753:      generic "Talisman Fragment" (default stats, used as filler).
     *
     * The talisman_map (AP ID string → "seed/rarity/type/upgradeLevel") is loaded from
     * slot_data on connect.  Specific fragments are deduplicated by seed on full sync so
     * reconnecting never adds duplicates.  Generic fragments are tracked by count via
     * genericTalismansGranted (persisted in the slot file via SaveManager).
     *
     * NOTE: Wizard stashes currently still grant their talisman rewards normally (they are
     * not yet blocked by NormalProgressionBlocker).  This means the player will receive
     * the fragment twice — once from the stash and once from AP — until blocking is added.
     */
    public class TalismanUnlocker {

        private var _logger:Logger;
        private var _modName:String;
        private var _itemToast:ItemToastPanel;
        private var _talMap:Object;      // AP ID string → "seed/rarity/type/upgradeLevel"
        private var _talNameMap:Object;  // AP ID string → display name

        public function TalismanUnlocker(logger:Logger, modName:String, itemToast:ItemToastPanel) {
            _logger    = logger;
            _modName   = modName;
            _itemToast = itemToast;
        }

        /** Called with slot_data.talisman_map on AP connect. */
        public function setTalismanMap(map:Object):void { _talMap = map; }

        /** Called with slot_data.talisman_name_map on AP connect. */
        public function setTalismanNameMap(map:Object):void { _talNameMap = map; }

        // -----------------------------------------------------------------------
        // Incremental grant (ReceivedItems index > 0)

        /** Grant a single talisman fragment by AP ID (700–799). */
        public function grantFragment(apId:int):void {
            var talData:String = talDataForApId(apId);
            addFragmentFromTalData(talData, apId);
        }

        // -----------------------------------------------------------------------
        // Full sync (ReceivedItems index == 0)

        /**
         * Ensure all talisman fragments in the received AP item list are in inventory.
         * Deduplicates by seed — every ID 700–799 has a unique seed so this is always safe.
         * Call after resetGrants().
         */
        public function syncTalismans(apIds:Array):void {
            for each (var apId:int in apIds) {
                if (apId < 700 || apId > 799) continue;
                var talData:String = talDataForApId(apId);
                if (talData == null) continue;
                var seed:int = int(talData.split("/")[0]);
                if (!hasFragmentWithSeed(seed)) {
                    addFragmentFromTalData(talData, apId);
                }
            }
        }

        // -----------------------------------------------------------------------
        // Helpers

        private function talDataForApId(apId:int):String {
            if (_talMap != null) {
                var mapped:* = _talMap[String(apId)];
                if (mapped != null) return String(mapped);
            }
            return null;
        }

        private function addFragmentFromTalData(talData:String, apId:int):void {
            if (GV.ppd == null) {
                _logger.log(_modName, "grantFragment: GV.ppd null, cannot grant apId=" + apId);
                return;
            }
            var inv:Array = GV.ppd.talismanInventory;
            if (inv == null) {
                _logger.log(_modName, "grantFragment: talismanInventory null");
                return;
            }
            var slotIdx:int = -1;
            for (var i:int = 0; i < inv.length; i++) {
                if (inv[i] == null) { slotIdx = i; break; }
            }
            if (slotIdx < 0) {
                _logger.log(_modName, "grantFragment: talisman inventory full, cannot grant apId=" + apId);
                return;
            }

            var parts:Array = talData.split("/");
            if (parts.length < 4) {
                _logger.log(_modName, "grantFragment: invalid talData '" + talData + "' for apId=" + apId);
                return;
            }
            var seed:int        = int(parts[0]);
            var rarity:int      = int(parts[1]);
            var type:int        = int(parts[2]);
            var upgradeLevel:int = int(parts[3]);

            var frag:TalismanFragment = new TalismanFragment(seed, rarity, type, upgradeLevel);
            inv[slotIdx] = frag;

            var label:String = (_talNameMap != null && _talNameMap[String(apId)] != null)
                ? String(_talNameMap[String(apId)])
                : ("Talisman Fragment #" + apId);
            _itemToast.addItem("Found " + label, 0xFFCC44);
            _logger.log(_modName, "Granted talisman apId=" + apId
                + " seed=" + seed + " rarity=" + rarity
                + " type=" + type + " slot=" + slotIdx);
        }

        private function hasFragmentWithSeed(seed:int):Boolean {
            if (GV.ppd == null) return false;
            var inv:Array = GV.ppd.talismanInventory;
            if (inv == null) return false;
            for (var i:int = 0; i < inv.length; i++) {
                var frag:* = inv[i];
                if (frag != null && TalismanFragment(frag).seed == seed) return true;
            }
            return false;
        }
    }
}
