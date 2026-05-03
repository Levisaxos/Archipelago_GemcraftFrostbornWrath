package ui {
    import flash.display.Stage;

    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.ScreenId;

    /**
     * Captures items from full-sync (ReceivedItems index=0), filters out
     * apIds the player has already seen via prior offline-grid displays,
     * and shows the OfflineItemsPanel exactly once per connect — when the
     * player first lands on the world map (SELECTOR). Never pops mid-battle
     * or during any transition. After it shows, _pending is drained, so
     * subsequent SELECTOR visits in the same session don't re-pop. Live
     * items received later (index>0) flow through ReceivedToast as usual.
     *
     * "Seen" set is persisted via SaveManager so reconnecting in a future
     * session does not re-show items the player already acknowledged.
     *
     * Wiring: ArchipelagoMod.bind() constructs this; ArchipelagoMod.syncWithAP()
     * captures items and calls onSyncCompleted(); ArchipelagoMod.doEnterFrame
     * calls tick() each frame.
     */
    public class OfflineItemsCollector {

        private var _logger:Logger;
        private var _modName:String;
        private var _panel:OfflineItemsPanel;

        // Pending entries waiting to be displayed: { apId, name, sender }
        private var _pending:Array;

        // Persisted set of apIds the player has already seen via the grid
        // (apId(int) → true). Treated as a Set; load/save via getter/setter.
        private var _seenApIds:Object;

        // Caller hooks
        public var onSeenApIdsChanged:Function;   // ()  → host should persist via SaveManager
        public var onPanelClosed:Function;        // ()  → host clears toast suppression

        public function OfflineItemsCollector(logger:Logger, modName:String,
                                              panel:OfflineItemsPanel) {
            _logger    = logger;
            _modName   = modName;
            _panel     = panel;
            _pending   = [];
            _seenApIds = {};

            _panel.onClosed = handlePanelClosed;
        }

        // -----------------------------------------------------------------------
        // Persisted state

        /** Replace the seen-apId set, e.g. after loading slot data. */
        public function set seenApIds(v:Object):void {
            _seenApIds = (v != null) ? v : {};
        }

        /** Get the seen-apId set as an Array of ints (for SaveManager). */
        public function get seenApIdsAsArray():Array {
            var out:Array = [];
            for (var k:String in _seenApIds) {
                if (_seenApIds[k] === true) out.push(int(k));
            }
            return out;
        }

        /** Wipe pending + seen set. Used when switching slots / disconnecting. */
        public function reset():void {
            _pending   = [];
            _seenApIds = {};
            if (_panel != null && _panel.isShowing) _panel.close();
        }

        /**
         * Mark an apId as already seen — call from grantItem (live receives
         * via index>0) so the same item doesn't get re-evaluated as "new"
         * in the next session's offline-items diff.
         *
         * Without this, only items from the initial sync are tracked. Live
         * items that arrived during a play session would be treated as never
         * seen by the next reconnect's diff and pop in the panel again.
         */
        public function markSeen(apId:int):void {
            var key:String = String(apId);
            if (_seenApIds[key] === true) return;
            _seenApIds[key] = true;
            if (onSeenApIdsChanged != null) onSeenApIdsChanged();
        }

        // -----------------------------------------------------------------------
        // Sync hook

        /**
         * Called by ArchipelagoMod immediately after syncWithAP finishes its
         * bulk-grant. resolver is invoked once per truly-new apId and must
         * return a display name (and optionally a sender name) for the grid.
         *
         * @param items     The full-sync items array (objects with .item and
         *                  optional .player / .location).
         * @param resolver  Function(apId:int, item:Object):Object — returns
         *                  { name:String, sender:String } or null to skip.
         */
        public function onSyncCompleted(items:Array, resolver:Function):void {
            if (items == null || items.length == 0) return;

            var newCount:int     = 0;
            var skippedServer:int = 0;
            var seenSetDirty:Boolean = false;

            for each (var item:Object in items) {
                var apId:int = int(item.item);
                if (_seenApIds[String(apId)] === true) continue;
                _seenApIds[String(apId)] = true;
                seenSetDirty = true;

                // Filter server grants — items where the source player slot is 0
                // (the AP server itself). These are initial/prefill items the
                // apworld seeds the slot with on creation, not items "received
                // from another player while you were away". Mark them seen so
                // re-syncs don't re-evaluate, but don't show them in the grid.
                var srcPlayer:int = (item.player !== undefined) ? int(item.player) : -1;
                if (srcPlayer == 0) {
                    skippedServer++;
                    continue;
                }

                var entry:Object = (resolver != null) ? resolver(apId, item) : null;
                if (entry == null) entry = { name: "Item #" + apId, sender: null };
                entry.apId = apId;
                _pending.push(entry);
                newCount++;
            }

            if (skippedServer > 0) {
                _logger.log(_modName, "OfflineItemsCollector: skipped "
                    + skippedServer + " server-granted starter item(s)");
            }
            if (newCount > 0) {
                _logger.log(_modName, "OfflineItemsCollector: " + newCount
                    + " newly-seen apIds queued for grid display");
            } else {
                _logger.log(_modName, "OfflineItemsCollector: full-sync had 0 new apIds to display");
            }

            // Persist the seen-set whenever we touched it, regardless of whether
            // any items survived the filter. Otherwise filtered apIds would be
            // re-evaluated (and re-skipped) on every reconnect.
            if (seenSetDirty && onSeenApIdsChanged != null) {
                onSeenApIdsChanged();
            }
        }

        // -----------------------------------------------------------------------
        // Per-frame gate

        /**
         * Call every frame from ArchipelagoMod.doEnterFrame. When pending
         * entries exist and the player is on the world map (SELECTOR)
         * — never mid-battle, never on transition screens — pops the panel.
         */
        public function tick(stage:Stage):void {
            if (_pending.length == 0) return;
            if (_panel == null || _panel.isShowing) return;
            if (stage == null) return;
            if (GV.main == null) return;

            // World map only. INGAME, LOADGAME, MAINMENU, and every
            // TRANS_* screen id are rejected here.
            if (int(GV.main.currentScreen) != ScreenId.SELECTOR) return;

            var entries:Array = _pending;
            _pending = [];
            // Group thematically before display: tile-related → gempouches →
            // stash keys → skills/traits → talismans/cores → XP/SP →
            // achievements → other. The priority comes from the entry's
            // sortPriority field set by ArchipelagoMod._resolveOfflineItemEntry.
            // Stable-ish: equal priority falls back to apId, so progressive
            // singletons stay clustered.
            entries.sort(_compareEntries);
            _logger.log(_modName, "OfflineItemsCollector: opening panel with "
                + entries.length + " entries (apIds=" + _summarizeApIds(entries) + ")");
            _panel.show(stage, entries);
        }

        private static function _compareEntries(a:Object, b:Object):int {
            var pa:int = (a != null && a.sortPriority != null) ? int(a.sortPriority) : 99;
            var pb:int = (b != null && b.sortPriority != null) ? int(b.sortPriority) : 99;
            if (pa != pb) return pa - pb;
            // Same priority: fall back to apId for stable, predictable layout.
            var aa:int = (a != null && a.apId != null) ? int(a.apId) : 0;
            var bb:int = (b != null && b.apId != null) ? int(b.apId) : 0;
            return aa - bb;
        }

        private function _summarizeApIds(entries:Array):String {
            var out:String = "";
            for (var i:int = 0; i < entries.length; i++) {
                if (i > 0) out += ",";
                out += int(entries[i].apId);
                if (i >= 25) { out += ",..."; break; }
            }
            return out;
        }

        // -----------------------------------------------------------------------
        // Panel close callback

        private function handlePanelClosed():void {
            _logger.log(_modName, "OfflineItemsCollector: panel closed");
            if (onPanelClosed != null) onPanelClosed();
        }
    }
}
