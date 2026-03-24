package {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import flash.utils.getTimer;

    /**
     * Handles DeathLink send and receive for the Archipelago mod.
     *
     * Punishment modes (set from slot_data):
     *   gem_loss    (0) — destroy Math.ceil(occupiedBuildings * gemLossPercent / 100) random
     *                     buildings (tower/trap) that contain a gem, along with their gem.
     *   wave_surge  (1) — inject waveSurgeCount extra waves, temporarily using a gem of
     *                     waveSurgeGemLevel grade in the enraging slot.
     *   instant_fail(2) — fail the current level immediately (TODO: confirm API).
     *
     * Queuing:
     *   - Incoming DeathLinks are queued and applied one at a time.
     *   - Grace period starts when the player first unpauses (currentWave >= 0).
     *   - Cooldown enforced between successive punishments.
     *
     * Call checkForDeath() and checkQueue() each frame while on INGAME screen.
     * Call resetForNewStage() on every stage transition.
     * Call configure(slotData) after AP connects.
     */
    public class DeathLinkHandler {

        public static const PUNISHMENT_GEM_LOSS:int     = 0;
        public static const PUNISHMENT_WAVE_SURGE:int   = 1;
        public static const PUNISHMENT_INSTANT_FAIL:int = 2;

        private var _logger:Logger;
        private var _modName:String;
        private var _toast:ToastPanel;

        // Settings
        private var _enabled:Boolean       = false;
        private var _punishment:int        = PUNISHMENT_GEM_LOSS;
        private var _gemLossPercent:int    = 20;
        private var _waveSurgeCount:int    = 3;
        private var _waveSurgeGemLevel:int = 5;
        private var _gracePeriodMs:int     = 15000;
        private var _cooldownMs:int        = 20000;

        // Queue / timer state
        private var _pendingQueue:Array     = [];
        private var _stageStartTime:int     = -1; // set on first unpause; -1 = not yet
        private var _lastPunishmentTime:int = 0;
        private var _deathProcessed:Boolean = false;

        /** Fired when the player's orb is destroyed. ():void */
        public var onPlayerDied:Function;
        /** Fired when a DeathLink is received and queued. (source:String):void */
        public var onPunishmentReceived:Function;

        public function DeathLinkHandler(logger:Logger, modName:String, toast:ToastPanel) {
            _logger  = logger;
            _modName = modName;
            _toast   = toast;
        }

        public function get enabled():Boolean       { return _enabled; }
        public function set enabled(v:Boolean):void { _enabled = v; }

        public function configure(slotData:Object):void {
            if (slotData.death_link_punishment   !== undefined) _punishment        = int(slotData.death_link_punishment);
            if (slotData.gem_loss_percent        !== undefined) _gemLossPercent    = int(slotData.gem_loss_percent);
            if (slotData.wave_surge_count        !== undefined) _waveSurgeCount    = int(slotData.wave_surge_count);
            if (slotData.wave_surge_gem_level    !== undefined) _waveSurgeGemLevel = int(slotData.wave_surge_gem_level);
            if (slotData.death_link_grace_period !== undefined) _gracePeriodMs     = int(slotData.death_link_grace_period) * 1000;
            if (slotData.death_link_cooldown     !== undefined) _cooldownMs        = int(slotData.death_link_cooldown)     * 1000;
            _logger.log(_modName, "DeathLink configured: enabled=" + _enabled
                + " punishment=" + _punishment
                + " gemLoss=" + _gemLossPercent + "%"
                + " surgeCount=" + _waveSurgeCount + " surgeLevel=" + _waveSurgeGemLevel
                + " gracePeriod=" + (_gracePeriodMs / 1000) + "s"
                + " cooldown=" + (_cooldownMs / 1000) + "s");
        }

        public function resetForNewStage():void {
            _deathProcessed     = false;
            _stageStartTime     = -1;
            _lastPunishmentTime = getTimer();
            _pendingQueue       = [];
        }

        // -----------------------------------------------------------------------
        // Per-frame checks

        public function checkForDeath():void {
            if (!_enabled || _deathProcessed) return;
            try {
                if (GV.ingameController == null || GV.ingameController.core == null) return;
                var ending:* = GV.ingameController.core.ending;
                if (ending == null || ending.isBattleWon) return;
                _deathProcessed = true;
                _logger.log(_modName, "DEATHLINK — orb destroyed, sending death");
                if (onPlayerDied != null) onPlayerDied();
            } catch (err:Error) {
                _logger.log(_modName, "checkForDeath error: " + err.message);
            }
        }

        public function checkQueue():void {
            if (!_enabled || _pendingQueue.length == 0) return;
            try {
                if (GV.ingameController == null || GV.ingameController.core == null) return;
                var core:* = GV.ingameController.core;

                // Grace period starts when the player unpauses: first wave has been activated.
                if (_stageStartTime < 0) {
                    if (core.currentWave.g() < 0) return; // still in pre-start
                    _stageStartTime = getTimer();
                    _logger.log(_modName, "DeathLink grace period started (queue=" + _pendingQueue.length + ")");
                }

                var now:int = getTimer();
                if (now - _stageStartTime  < _gracePeriodMs) return;
                if (now - _lastPunishmentTime < _cooldownMs)  return;

                var source:String = String(_pendingQueue.shift());
                _lastPunishmentTime = now;
                _logger.log(_modName, "Applying DeathLink from " + source
                    + " (remaining: " + _pendingQueue.length + ")");
                applyPunishmentNow(source);
            } catch (err:Error) {
                _logger.log(_modName, "checkQueue error: " + err.message);
            }
        }

        // -----------------------------------------------------------------------
        // Queue incoming DeathLink

        public function queuePunishment(source:String):void {
            if (!_enabled) return;
            if (GV.ingameController == null) {
                _logger.log(_modName, "DeathLink from " + source + " — not in-game, discarded");
                return;
            }
            _pendingQueue.push(source);
            _logger.log(_modName, "DeathLink from " + source + " queued (queue=" + _pendingQueue.length + ")");
            if (onPunishmentReceived != null) onPunishmentReceived(source);
        }

        // -----------------------------------------------------------------------
        // Punishment implementations

        private function applyPunishmentNow(source:String):void {
            try {
                switch (_punishment) {
                    case PUNISHMENT_GEM_LOSS:     applyGemLoss();     break;
                    case PUNISHMENT_WAVE_SURGE:   applyWaveSurge();   break;
                    case PUNISHMENT_INSTANT_FAIL: applyInstantFail(); break;
                }
            } catch (err:Error) {
                _logger.log(_modName, "applyPunishmentNow error: " + err.message);
            }
        }

        private function applyGemLoss():void {
            var core:* = GV.ingameController.core;

            // Collect all occupied buildings (tower + trap that have a gem inserted).
            var occupied:Array = [];
            var towers:Array = core.towers as Array;
            var traps:Array  = core.traps  as Array;
            for each (var t:* in towers) {
                if (t != null && t.insertedGem != null) occupied.push(t);
            }
            for each (var trap:* in traps) {
                if (trap != null && trap.insertedGem != null) occupied.push(trap);
            }

            if (occupied.length == 0) {
                _toast.addMessage("DeathLink: no gems on the field!", 0xFFFF8844);
                return;
            }

            var toDestroy:int = Math.ceil(occupied.length * _gemLossPercent / 100);
            shuffleArray(occupied);

            for (var i:int = 0; i < toDestroy; i++) {
                var building:* = occupied[i];
                // Demolish building and its gem — pIsByEnemy=true mimics Wizard Hunter attack.
                core.destroyer.demolishOwnBuilding(building.x, building.y, false, true, false);
                _logger.log(_modName, "  demolished building at ("
                    + building.x + "," + building.y + ")");
            }

            _toast.addMessage("DeathLink! " + toDestroy + " gem"
                + (toDestroy == 1 ? "" : "s") + " destroyed!", 0xFFFF4444);
        }

        private function applyWaveSurge():void {
            var core:* = GV.ingameController.core;

            // Temporarily place a gem of the configured grade in the enraging slot
            // so the injected waves get the right difficulty multiplier.
            var savedEnrageGem:* = core.gemInEnragingSlot;
            var targetGrade:int  = _waveSurgeGemLevel - 1; // grade is 0-indexed

            // Find any gem of sufficient grade to use as temporary enrager.
            var surgeGem:* = null;
            var gems:Array = core.gems as Array;
            for each (var g:* in gems) {
                if (g != null && g.grade != null && g.grade.g() >= targetGrade) {
                    surgeGem = g;
                    break;
                }
            }
            if (surgeGem != null) {
                core.gemInEnragingSlot = surgeGem;
                _logger.log(_modName, "  waveSurge: using gem grade "
                    + surgeGem.grade.g() + " as temporary enrager");
            } else {
                _logger.log(_modName, "  waveSurge: no gem of grade >=" + targetGrade
                    + " found — injecting without extra enrage");
            }

            // Inject waves, bypassing the normal timer guard.
            var injected:int = 0;
            for (var i:int = 0; i < _waveSurgeCount; i++) {
                if (core.currentWave.g() < core.waves.length - 1) {
                    core.timeUntilNextWave = 0;
                    GV.ingameController.activateNextWave();
                    injected++;
                }
            }

            // Restore original enraging gem.
            core.gemInEnragingSlot = savedEnrageGem;

            if (injected > 0) {
                _toast.addMessage("DeathLink! " + injected + " enraged wave"
                    + (injected == 1 ? "" : "s") + " incoming!", 0xFFFF4444);
            } else {
                _toast.addMessage("DeathLink: no waves left to inject!", 0xFFFF8844);
            }
        }

        private function applyInstantFail():void {
            var core:* = GV.ingameController.core;
            // TODO: confirm the correct fail method via logs.
            _logger.log(_modName, "  instantFail probe — controller type: "
                + Object(GV.ingameController).constructor);
            if      (GV.ingameController.endBattle  != null) GV.ingameController.endBattle(false);
            else if (GV.ingameController.failBattle  != null) GV.ingameController.failBattle();
            else if (core.endBattle                  != null) core.endBattle(false);
            else if (core.failBattle                 != null) core.failBattle();
            else _logger.log(_modName, "  instantFail: no fail method found — check probe log above");
            _toast.addMessage("DeathLink! Level failed!", 0xFFFF4444);
        }

        // -----------------------------------------------------------------------

        private function shuffleArray(arr:Array):void {
            for (var i:int = arr.length - 1; i > 0; i--) {
                var j:int = int(Math.random() * (i + 1));
                var tmp:* = arr[i]; arr[i] = arr[j]; arr[j] = tmp;
            }
        }
    }
}
