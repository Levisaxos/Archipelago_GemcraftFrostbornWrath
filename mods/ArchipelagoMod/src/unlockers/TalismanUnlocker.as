package unlockers {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.entity.TalismanFragment;
    import ui.ReceivedToast;
    import ui.ItemColors;
    import utils.ApIdMapper;
    import data.AV;

    /**
     * Grants Archipelago talisman fragment items to the player's talisman inventory.
     *
     * AP item IDs 900–952: location-specific fragments, each named "{str_id} Talisman Fragment".
     * AP item ID 953:      generic "Talisman Fragment" (default stats, used as filler).
     *
     * The talisman_map (AP ID string → "seed/rarity/type/upgradeLevel") is loaded from
     * slot_data on connect.  Specific fragments are deduplicated by seed on full sync so
     * reconnecting never adds duplicates.  Generic fragments are tracked by count via
     * genericTalismansGranted (persisted in the slot file via SaveManager).
     *
     * NOTE: Wizard stashes currently still grant their talisman rewards normally (they are
     * not yet blocked by ProgressionBlocker).  This means the player will receive
     * the fragment twice — once from the stash and once from AP — until blocking is added.
     */
    public class TalismanUnlocker extends BaseUnlocker {

        private var _talDataMapper:ApIdMapper;     // AP ID → "seed/rarity/type/upgradeLevel"
        private var _talNameMap:Object;            // AP ID string → display name
        private var _grantedApIds:Object = {};     // String(apId) → true; persisted via SaveManager

        // Static talisman: apId(str) → progression-set entry {slot, tal_data, ap_id}.
        // The 25 progression fragment ITEMS each map to one synthetic slot (paired
        // in the apworld). Finding the item unlocks that slot + sockets the
        // synthetic fragment; slots for unfound items stay locked.
        private var _slotEntryByApId:Object = {};
        private var _slotMapBuilt:Boolean = false;

        public function TalismanUnlocker(logger:Logger, modName:String, itemToast:ReceivedToast) {
            super(logger, modName, itemToast);
            _talDataMapper = null;
        }

        /** Called with slot_data.talisman_map on AP connect. */
        public function setTalismanMap(map:Object):void { _talDataMapper = new ApIdMapper(map); }

        /** Called with slot_data.talisman_name_map on AP connect. */
        public function setTalismanNameMap(map:Object):void { _talNameMap = map; }

        /** Called by SaveManager on load to restore persisted granted set. */
        public function get grantedApIds():Object { return _grantedApIds; }
        public function set grantedApIds(v:Object):void { _grantedApIds = (v != null) ? v : {}; }

        // -----------------------------------------------------------------------
        // Incremental grant (ReceivedItems index > 0)

        /** Grant a single talisman fragment by AP ID (900–999).
         *  A mapped (static-talisman) fragment unlocks+sockets its slot; any
         *  other (useful) fragment goes to the inventory as before.
         *  Returns the created TalismanFragment for inventory grants, else null. */
        public function grantFragment(apId:int):* {
            if (isMappedFragment(apId)) {
                _grantMapped(apId);
                return null;
            }
            var talData:String = _talDataMapper != null ? String(_talDataMapper.getValue(apId, null)) : null;
            return addFragmentFromTalData(talData, apId);
        }

        // -----------------------------------------------------------------------
        // Full sync (ReceivedItems index == 0)

        /**
         * Ensure all talisman fragments in the received AP item list are in inventory.
         * Deduplicates by seed — every ID 900–952 and 1200–1246 has a unique seed so this is always safe.
         * Call after resetGrants().
         */
        public function syncTalismans(apIds:Array):void {
            _ensureSlotMap();
            for each (var apId:int in apIds) {
                // Only 900–952 are talisman-fragment AP items now. The extra
                // range (1200–1246) was retired; those items no longer exist.
                if (!(apId >= 900 && apId <= 952)) continue;
                // Mapped (static-talisman) fragment: drop one free copy into
                // the inventory the first time it's received (see
                // _depositMappedFree). Guarded by _grantedApIds so a reconnect
                // full-sync never re-grants — and selling it doesn't earn
                // another. The AP Shop stays available to re-buy it if sold.
                if (isMappedFragment(apId)) {
                    if (_grantedApIds[String(apId)] != true) {
                        _depositMappedFree(apId);
                    }
                    _grantedApIds[String(apId)] = true;
                    continue;
                }
                if (_grantedApIds[String(apId)] == true) continue; // already granted; persisted check
                var talData:String = _talDataMapper != null ? String(_talDataMapper.getValue(apId, null)) : null;
                if (talData == null) continue;
                var seed:int = int(talData.split("/")[0]);
                if (!hasFragmentWithSeed(seed)) {
                    addFragmentFromTalData(talData, apId);
                }
            }
        }

        // -----------------------------------------------------------------------
        // Progression talisman set (slot_data.progression_talisman_set)

        /**
         * AP Shop model: progression fragments are NO LONGER auto-socketed.
         * Receiving one just records it as available; the player buys and
         * places it manually from the AP Shop (see ui/TalismanShop). Slot
         * unlocking stays vanilla (shadow cores). This method now only ensures
         * the slot map is built so getCatalogEntries() can resolve positions.
         * The `set` param is ignored — the map is read from
         * AV.serverData.progressionTalismanSet.
         */
        public function applyProgressionSet(set:Array):void {
            _ensureSlotMap();
        }

        // -----------------------------------------------------------------------
        // AP Shop catalog

        /**
         * Return the full shop catalog — always all 25 progression fragments so
         * the grid layout is always shown. Each entry is
         * `{slot, seed, rarity, type, upgradeLevel, apId, name, received}`;
         * `received` is true once the fragment has been received from AP (a
         * not-received entry renders as a locked slot in the shop).
         */
        public function getCatalogEntries():Array {
            _ensureSlotMap();
            var out:Array = [];
            var set:Array = (AV.serverData != null) ? AV.serverData.progressionTalismanSet : null;
            if (set == null) return out;
            for each (var entry:Object in set) {
                if (entry == null || entry.ap_id === undefined) continue;
                var apId:int = int(entry.ap_id);
                var parts:Array = String(entry.tal_data).split("/");
                if (parts.length < 4) continue;
                var name:String = (_talNameMap != null && _talNameMap[String(apId)] != null)
                    ? String(_talNameMap[String(apId)])
                    : ("Talisman Fragment #" + apId);
                out.push({
                    slot:         int(entry.slot),
                    seed:         int(parts[0]),
                    rarity:       int(parts[1]),
                    type:         int(parts[2]),
                    upgradeLevel: int(parts[3]),
                    apId:         apId,
                    name:         name,
                    received:     (_grantedApIds[String(apId)] == true)
                });
            }
            return out;
        }

        /** Build apId(str) → progression-set entry from the shipped set (each
         *  entry tagged with ap_id by the apworld). Lazy; safe to re-call. */
        private function _ensureSlotMap():void {
            if (_slotMapBuilt) return;
            var set:Array = (AV.serverData != null) ? AV.serverData.progressionTalismanSet : null;
            if (set == null || set.length == 0) return; // not shipped yet
            _slotEntryByApId = {};
            for each (var entry:Object in set) {
                if (entry == null || entry.ap_id === undefined) continue;
                _slotEntryByApId[String(int(entry.ap_id))] = entry;
            }
            _slotMapBuilt = true;
        }

        /** True iff apId is one of the 25 static-talisman fragment items. */
        private function isMappedFragment(apId:int):Boolean {
            _ensureSlotMap();
            return _slotEntryByApId[String(apId)] != null;
        }

        /** Unlock the slot for a mapped fragment and socket its synthetic
         *  fragment. Idempotent — re-sockets on every call (no removal). */
        private function _socketMappedFragment(apId:int):Boolean {
            _ensureSlotMap();
            var entry:Object = _slotEntryByApId[String(apId)];
            if (entry == null) return false;
            if (!ensurePpdExists("socketMappedFragment")) return false;
            var slots:Array = GV.ppd.talismanSlots;
            var unlocks:Array = GV.ppd.talSlotUnlockStatuses;
            if (slots == null || unlocks == null) return false;
            var slot:int = int(entry.slot);
            if (slot < 0 || slot >= GV.TALISMAN_ACTIVESLOT_NUM) return false;
            var parts:Array = String(entry.tal_data).split("/");
            if (parts.length < 4) return false;
            unlocks[slot] = true;
            slots[slot] = new TalismanFragment(int(parts[0]), int(parts[1]),
                                               int(parts[2]), int(parts[3]));
            return true;
        }

        /** Grant a mapped (static-talisman) fragment: drop one free copy into
         *  the inventory (first receipt only), mark it received, and toast. The
         *  player can place, upgrade, or sell it freely; the AP Shop stays
         *  available to re-buy it (net-zero) if sold. */
        private function _grantMapped(apId:int):void {
            // First receipt only — _grantedApIds is persisted, so this never
            // re-grants on reconnect or after the player sells the fragment.
            if (_grantedApIds[String(apId)] != true) {
                _depositMappedFree(apId);
            }
            _grantedApIds[String(apId)] = true;
            var label:String = (_talNameMap != null && _talNameMap[String(apId)] != null)
                ? String(_talNameMap[String(apId)])
                : ("Talisman Fragment #" + apId);
            showToast("Received " + label, ItemColors.forApId(apId));
            showPlusNodeOnSelector("mcPlusNodeTalisman");
        }

        /**
         * Deposit one free copy of a mapped (AP) fragment into the talisman
         * inventory at base upgrade level (0 — the player upgrades it in-game,
         * matching the AP Shop). Deduped by seed so a fragment already held
         * (e.g. from a wiz stash) is never doubled. Returns true if a fragment
         * was actually added.
         */
        private function _depositMappedFree(apId:int):Boolean {
            _ensureSlotMap();
            var entry:Object = _slotEntryByApId[String(apId)];
            if (entry == null) return false;
            var parts:Array = String(entry.tal_data).split("/");
            if (parts.length < 4) return false;
            var seed:int = int(parts[0]);
            if (hasFragmentWithSeed(seed)) return false; // already held — don't double
            if (!ensurePpdExists("depositMappedFree")) return false;
            var inv:Array = GV.ppd.talismanInventory;
            if (inv == null) {
                logAction("depositMappedFree: talismanInventory null");
                return false;
            }
            var slotIdx:int = -1;
            for (var i:int = 0; i < inv.length; i++) {
                if (inv[i] == null) { slotIdx = i; break; }
            }
            if (slotIdx < 0) {
                logAction("depositMappedFree: inventory full, cannot grant apId=" + apId);
                return false;
            }
            inv[slotIdx] = new TalismanFragment(seed, int(parts[1]), int(parts[2]), 0);
            logAction("Free talisman granted apId=" + apId + " seed=" + seed + " slot=" + slotIdx);
            return true;
        }

        // -----------------------------------------------------------------------
        // AP-origin seed lookup (for the fragment-tooltip "Archipelago item" mark)

        // seed(int) → true for every mapped AP fragment. Lazily built from the
        // shipped progression set; null until it can be built (serverData ready).
        private var _apSeedSet:Object = null;

        /** True iff `seed` belongs to one of the AP talisman fragments (the 25
         *  mapped/progression fragments). Used by the fragment-tooltip overlay
         *  to mark AP-sourced fragments in their hover panel. */
        public function isApFragmentSeed(seed:int):Boolean {
            _ensureApSeedSet();
            return _apSeedSet != null && _apSeedSet[seed] === true;
        }

        private function _ensureApSeedSet():void {
            if (_apSeedSet != null) return;
            var set:Array = (AV.serverData != null) ? AV.serverData.progressionTalismanSet : null;
            if (set == null || set.length == 0) return; // not shipped yet — retry next call
            var built:Object = {};
            for each (var entry:Object in set) {
                if (entry == null || entry.tal_data == null) continue;
                var parts:Array = String(entry.tal_data).split("/");
                if (parts.length < 1) continue;
                built[int(parts[0])] = true;
            }
            _apSeedSet = built;
        }

        // -----------------------------------------------------------------------
        // Helpers

        private function addFragmentFromTalData(talData:String, apId:int):* {
            if (!ensurePpdExists("grantFragment")) {
                return null;
            }
            var inv:Array = GV.ppd.talismanInventory;
            if (inv == null) {
                logAction("grantFragment: talismanInventory null");
                return null;
            }
            var slotIdx:int = -1;
            for (var i:int = 0; i < inv.length; i++) {
                if (inv[i] == null) { slotIdx = i; break; }
            }
            if (slotIdx < 0) {
                logAction("grantFragment: talisman inventory full, cannot grant apId=" + apId);
                return null;
            }

            var parts:Array = talData.split("/");
            if (parts.length < 4) {
                logAction("grantFragment: invalid talData '" + talData + "' for apId=" + apId);
                return null;
            }
            var seed:int         = int(parts[0]);
            var rarity:int       = int(parts[1]);
            var type:int         = int(parts[2]);
            var upgradeLevel:int = int(parts[3]);

            var frag:TalismanFragment = new TalismanFragment(seed, rarity, type, upgradeLevel);
            inv[slotIdx] = frag;
            _grantedApIds[String(apId)] = true;

            var label:String = (_talNameMap != null && _talNameMap[String(apId)] != null)
                ? String(_talNameMap[String(apId)])
                : ("Talisman Fragment #" + apId);
            showToast("Received " + label, ItemColors.forApId(apId));
            logAction("Granted talisman apId=" + apId
                + " seed=" + seed + " rarity=" + rarity
                + " type=" + type + " slot=" + slotIdx);
            showPlusNodeOnSelector("mcPlusNodeTalisman");
            return frag;
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
