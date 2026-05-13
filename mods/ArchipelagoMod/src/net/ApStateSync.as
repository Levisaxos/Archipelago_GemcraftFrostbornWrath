package net {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Persists per-slot game state in AP DataStorage so it survives the
     * player losing their local save file. On a fresh local slot, the mod
     * requests the stored snapshot at connection time; the
     * applyRetrievedState path writes it back into GV.ppd before the
     * achievement panel reads the values.
     *
     * What's stored (per AP slot, in the team-private namespace):
     *   - stage_xp_journey:   Array<int>   stage best XP, journey mode
     *   - stage_xp_endurance: Array<int>   stage best XP, endurance mode
     *   - stage_xp_trial:     Array<int>   stage best XP, trial mode
     *
     * Why only XP arrays:
     *   - Achievements are restored from AP's own checked_locations list —
     *     no DataStorage round-trip needed.
     *   - Wizard level is derived from the XP arrays at panel-open time,
     *     so restoring the arrays auto-restores the visible level.
     *   - Skill points are reconciled from bundles + gained achievements;
     *     once those two restore, SP follows.
     *
     * Conflict policy: per-stage max. If the AP server says a stage has
     * XP=5000 but the local file says 3000, take 5000 (player did better
     * on the lost run). If local has -1 (locked) we DO NOT overwrite — a
     * lock from the current slot's gating outranks an old XP value.
     *
     * Push trigger: pushIfChanged() is called after every saveSlotData().
     * Internal hash dedup avoids spamming AP with unchanged snapshots.
     */
    public class ApStateSync {

        private static const KEY_PREFIX:String = "gcfw_state";

        private var _logger:Logger;
        private var _modName:String;
        private var _connectionManager:ConnectionManager;

        // Cached key for the active slot — assembled once per connection.
        private var _stateKey:String = null;

        // Last-pushed snapshot hash so we don't re-send unchanged state.
        private var _lastPushedHash:String = "";

        // Pending state from a Retrieved that arrived before syncWithAP ran.
        // syncWithAP drains this after the full item sync so XP restoration
        // doesn't get clobbered by sessionData.reset() side effects.
        private var _pendingState:Object = null;
        public function get pendingState():Object { return _pendingState; }
        public function clearPendingState():void { _pendingState = null; }

        // True once we have a confirmed Retrieved response. Lets the mod
        // distinguish "nothing stored yet" from "still waiting".
        private var _retrieveDone:Boolean = false;
        public function get retrieveDone():Boolean { return _retrieveDone; }

        // -----------------------------------------------------------------------

        public function ApStateSync(logger:Logger, modName:String,
                                    connectionManager:ConnectionManager) {
            _logger            = logger;
            _modName           = modName;
            _connectionManager = connectionManager;
        }

        /** Build the team-scoped key and request the snapshot. Call once,
         *  right after the Connected packet is fully processed. */
        public function requestState():void {
            _stateKey = _buildKey();
            _retrieveDone = false;
            _lastPushedHash = "";
            _connectionManager.sendDataStorageGet([_stateKey]);
            _logger.log(_modName, "ApStateSync: requested " + _stateKey);
        }

        /** Reset internal state on disconnect / slot change so the next
         *  connect starts clean. */
        public function reset():void {
            _stateKey = null;
            _retrieveDone = false;
            _lastPushedHash = "";
            _pendingState = null;
        }

        /**
         * Handle the Retrieved packet. AP returns the requested key with its
         * value (or null if unset). We stash it; syncWithAP / a late apply
         * actually writes it into GV.ppd.
         */
        public function onRetrieved(keys:Object):void {
            _retrieveDone = true;
            if (_stateKey == null) {
                _logger.log(_modName, "ApStateSync.onRetrieved: no state key set, ignoring");
                return;
            }
            var raw:* = keys[_stateKey];
            if (raw == null) {
                _logger.log(_modName, "ApStateSync: no stored state for " + _stateKey + " (first session)");
                _pendingState = null;
                return;
            }
            _pendingState = raw;
            _logger.log(_modName, "ApStateSync: retrieved state for " + _stateKey
                + "  journey=" + _arrLen(raw.stage_xp_journey)
                + "  endurance=" + _arrLen(raw.stage_xp_endurance)
                + "  trial=" + _arrLen(raw.stage_xp_trial));
        }

        /**
         * Write pendingState into GV.ppd.stageHighestXps* using the max-merge
         * policy. Returns the number of stages actually modified. Safe to call
         * when pendingState is null — no-op.
         */
        public function applyPendingState():int {
            if (_pendingState == null || GV.ppd == null) return 0;
            var changes:int = 0;
            changes += _mergeMaxInto(_pendingState.stage_xp_journey,   GV.ppd.stageHighestXpsJourney,   "journey");
            changes += _mergeMaxInto(_pendingState.stage_xp_endurance, GV.ppd.stageHighestXpsEndurance, "endurance");
            changes += _mergeMaxInto(_pendingState.stage_xp_trial,     GV.ppd.stageHighestXpsTrial,     "trial");
            _pendingState = null;
            _logger.log(_modName, "ApStateSync.applyPendingState: " + changes + " stages updated");
            return changes;
        }

        /**
         * Capture the current GV.ppd XP arrays, hash them, and send to AP
         * only if the hash differs from the last push. Cheap when called
         * frequently — the hash compare is O(N) over the array contents.
         */
        public function pushIfChanged():void {
            if (_stateKey == null || GV.ppd == null) return;
            if (!_connectionManager.isConnected) return;

            var snapshot:Object = {
                stage_xp_journey:   _readGcArray(GV.ppd.stageHighestXpsJourney),
                stage_xp_endurance: _readGcArray(GV.ppd.stageHighestXpsEndurance),
                stage_xp_trial:     _readGcArray(GV.ppd.stageHighestXpsTrial)
            };
            var json:String = _encodeSnapshot(snapshot);

            if (json == _lastPushedHash) return;
            _lastPushedHash = json;

            _connectionManager.sendDataStorageSet(_stateKey, json);
        }

        // -----------------------------------------------------------------------

        /** Read a GC wrapped-int array (each cell has .g()) into a plain Array<int>. */
        private function _readGcArray(arr:Array):Array {
            var out:Array = [];
            if (arr == null) return out;
            for (var i:int = 0; i < arr.length; i++) {
                var cell:* = arr[i];
                out.push((cell != null) ? int(cell.g()) : 0);
            }
            return out;
        }

        /**
         * Merge source (plain ints from AP) into target (GC wrapped cells) using
         * per-stage max. Leaves `-1` cells (locked stages) alone — AP-stored XP
         * can't unlock a stage the current slot has gated.
         */
        private function _mergeMaxInto(source:*, target:Array, label:String):int {
            if (!(source is Array) || target == null) return 0;
            var src:Array = source as Array;
            var changes:int = 0;
            var lim:int = Math.min(src.length, target.length);
            for (var i:int = 0; i < lim; i++) {
                var apVal:int = int(src[i]);
                if (apVal <= 0) continue;  // no AP data for this stage
                var cell:* = target[i];
                if (cell == null) continue;
                var cur:int = int(cell.g());
                if (cur < 0) continue;  // locked — don't unlock via XP restore
                if (apVal > cur) {
                    cell.s(apVal);
                    changes++;
                }
            }
            return changes;
        }

        /** Compact JSON encoder for the snapshot shape. Hand-rolled so we
         *  control the output format (which doubles as our diff hash). */
        private function _encodeSnapshot(s:Object):String {
            return "{"
                + '"stage_xp_journey":'   + _encodeIntArray(s.stage_xp_journey)   + ","
                + '"stage_xp_endurance":' + _encodeIntArray(s.stage_xp_endurance) + ","
                + '"stage_xp_trial":'     + _encodeIntArray(s.stage_xp_trial)
                + "}";
        }

        private function _encodeIntArray(arr:Array):String {
            if (arr == null || arr.length == 0) return "[]";
            return "[" + arr.join(",") + "]";
        }

        /** Build the slot+team-scoped storage key. Format chosen so it can't
         *  collide with another player's slot or another GCFW slot on the same
         *  team. */
        private function _buildKey():String {
            var slot:int = _connectionManager.mySlot;
            var team:int = _connectionManager.myTeam;
            return KEY_PREFIX + "_T" + team + "_P" + slot;
        }

        private function _arrLen(o:*):int {
            return (o is Array) ? (o as Array).length : 0;
        }
    }
}
