package {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.SB;
    import com.giab.games.gcfw.constants.BattleMode;
    import flash.utils.getTimer;

    /**
     * Handles DeathLink send and receive for the Archipelago mod.
     *
     * Punishment modes (set from slot_data):
     *   gem_loss    (0) — destroy Math.ceil(occupiedBuildings * gemLossPercent / 100) random
     *                     buildings (tower/trap) that contain a gem, along with their gem.
     *   wave_surge  (1) — boost the enrage slot gem's grade by waveSurgeGemLevel for
     *                     waveSurgeCount wave activations, then restore.
     *                     If the slot is empty, no gem is created; instead the enrage formulas
     *                     are applied directly to each monster as it spawns (monster-patch mode).
     *   instant_fail(2) — fail the current level immediately (TODO: confirm API).
     *
     * Queuing:
     *   - Incoming DeathLinks are queued and applied one at a time.
     *   - Grace period starts when the player first unpauses (currentWave >= 0).
     *   - Cooldown enforced between successive punishments.
     *
     * Call checkForDeath(), checkQueue(), and checkWaveSurge() each frame while on INGAME screen.
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

        // Wave-surge state
        // Two modes, mutually exclusive:
        //   Boost mode  (_surgeGem != null, _savedGrade >= 0):
        //       Player had a gem in the slot; its grade is raised in-place and restored on end.
        //   Monster-patch mode (_surgeActive == true, _surgeGem == null):
        //       Slot was empty; enrage formulas are applied directly to each monster as it
        //       spawns (via isFromEnragedWave flag). No gem object is created.
        private var _surgeGem:*         = null;
        private var _savedEnrageGem:*   = null; // player's gem that was in the slot (boost mode)
        private var _savedGrade:int     = -1;   // original grade (boost mode only)
        private var _surgeStartWave:int = -1;   // core.currentWave value when surge began
        private var _surgeActive:Boolean = false; // true while monster-patch mode is running

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
            endWaveSurge();
            _deathProcessed     = false;
            _stageStartTime     = -1;
            _lastPunishmentTime = getTimer();
            _pendingQueue       = [];
            _savedGrade         = -1;
            _surgeActive        = false;
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

        /**
         * Called every frame while on INGAME screen.
         *
         * Boost mode:       ends the surge if the player sold/moved their gem, or after N waves.
         * Monster-patch mode: applies the enrage formulas to any monster that has just spawned
         *                     (isFromEnragedWave == false).  Once flagged, a monster is never
         *                     touched again, so the per-frame cost is minimal.
         *                     Ends after N waves.
         *
         * TODO: pre-boost Wave.numOfMonsters for the count portion of enrage.
         */
        public function checkWaveSurge():void {
            if (_surgeGem == null && !_surgeActive) return;
            try {
                if (GV.ingameController == null || GV.ingameController.core == null) {
                    endWaveSurge();
                    return;
                }
                var core:* = GV.ingameController.core;

                // ── Boost mode: detect if player sold/moved their gem ────────────
                if (_surgeGem != null && core.gemInEnragingSlot != _surgeGem) {
                    _logger.log(_modName, "  waveSurge: gem removed from slot — ending surge early");
                    _toast.addMessage("Wave surge ended (gem removed)", 0xFFFF8844);
                    _surgeGem       = null;
                    _savedEnrageGem = null;
                    _surgeStartWave = -1;
                    _savedGrade     = -1;
                    return;
                }

                // ── Wave-count limit (both modes) ────────────────────────────────
                var wavesSinceStart:int = core.currentWave.g() - _surgeStartWave;
                if (wavesSinceStart >= _waveSurgeCount) {
                    _logger.log(_modName, "  waveSurge: " + _waveSurgeCount + " waves completed — ending");
                    _toast.addMessage("Wave surge ended", 0xFFFF8844);
                    endWaveSurge();
                    return;
                }

                // ── Monster-patch mode: boost newly spawned monsters ─────────────
                if (_surgeActive) {
                    var monsters:Array = core.monstersOnScene as Array;
                    if (monsters == null) return;
                    var grade:int = _waveSurgeGemLevel - 1;
                    var hpFactor:Number  = Math.pow(1.8, grade + 1) - 1;
                    var armFactor:Number = Math.pow(1.5, grade + 1) - 1;
                    var xpFactor:Number  = Math.pow(1.2, grade + 1) - 1;
                    for each (var m:* in monsters) {
                        if (m == null || m.isFromEnragedWave) continue;
                        m.hp.s(Math.floor(m.hp.g() * (1 + hpFactor)));
                        m.hpMax.s(m.hp.g());
                        m.armorLevel.s(Math.floor(m.armorLevel.g() * (1 + armFactor)));
                        m.xpBase.s(m.xpBase.g() * (1 + xpFactor));
                        m.isFromEnragedWave = true;
                    }
                }
            } catch (err:Error) {
                _logger.log(_modName, "checkWaveSurge error: " + err.message);
                _surgeGem    = null;
                _surgeActive = false;
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
        // Test helpers — call directly from debug overlay, bypasses queue/timer.

        public function testGemLoss():void    { applyGemLoss(); }
        public function testWaveSurge():void  { applyWaveSurge(); }
        public function testInstantFail():void { applyInstantFail(); }

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
            endWaveSurge();

            _savedEnrageGem = core.gemInEnragingSlot;
            _surgeStartWave = core.currentWave.g();

            if (_savedEnrageGem != null) {
                // ── Boost mode ──────────────────────────────────────────────────
                // The player already has a gem in the slot.  Raise its grade in-place;
                // display is completely unchanged.
                _savedGrade = int(_savedEnrageGem.grade.g());
                _savedEnrageGem.grade.s(_savedGrade + _waveSurgeGemLevel);
                _surgeGem = _savedEnrageGem;
                _logger.log(_modName, "  waveSurge boost: grade-" + (_savedGrade + 1)
                    + " → grade-" + (_savedGrade + 1 + _waveSurgeGemLevel)
                    + " for " + _waveSurgeCount + " waves");
            } else {
                // ── Monster-patch mode ───────────────────────────────────────────
                // Slot is empty.  No gem is created.  Instead, checkWaveSurge() applies
                // the enrage formulas directly to each monster as it spawns.
                _surgeActive = true;
                _savedGrade  = -1;
                _logger.log(_modName, "  waveSurge patch: monster-patch mode, grade="
                    + _waveSurgeGemLevel + " for " + _waveSurgeCount + " waves");
            }

            _toast.addMessage("DeathLink! Wave enrage +" + _waveSurgeGemLevel
                + " for " + _waveSurgeCount + " wave" + (_waveSurgeCount == 1 ? "" : "s") + "!",
                0xFFFF4444);
        }

        private function applyInstantFail():void {
            var core:* = GV.ingameController.core;
            try {
                 SB.playSound("sndorbdestroyed");                  
                GV.vfxEngine.createOrbDestroy(core.orb.x, core.orb.y);
                core.isScreenShaking=true;
                core.screenShakingEnergy = Math.max(core.screenShakingEnergy,12);
                  if(GV.ingameCore.battleMode == BattleMode.ENDURANCE)
                  {
                     core.ending.endGameWithVictory();
                  }
                  else
                  {
                     core.ending.endGameWithDefeat();
                  }
            } catch (e:Error) { /* VFX is cosmetic — ignore if unavailable */ }
            
            _toast.addMessage("DeathLink! Level failed!", 0xFFFF4444);
            _logger.log(_modName, "  instantFail: endGameWithDefeat called");
        }

        // -----------------------------------------------------------------------
        // Wave-surge cleanup

        /**
         * End the active wave surge.
         * Boost mode: restores the original grade on the player's gem.
         * Ghost mode: removes the hidden gem from the slot and its display container.
         * Safe to call even if no surge is active.
         */
        public function endWaveSurge():void {
            if (_surgeGem == null && !_surgeActive) return;
            try {
                if (_savedGrade >= 0 && _savedEnrageGem != null) {
                    // Boost mode: restore the player's gem grade.
                    _savedEnrageGem.grade.s(_savedGrade);
                    _logger.log(_modName, "  waveSurge ended: restored grade to " + (_savedGrade + 1));
                } else if (_surgeActive) {
                    // Monster-patch mode: boosted monsters keep their stats (nothing to undo).
                    _logger.log(_modName, "  waveSurge ended: monster-patch mode complete");
                }
            } catch (err:Error) {
                _logger.log(_modName, "endWaveSurge cleanup error: " + err.message);
            }
            _surgeGem       = null;
            _savedEnrageGem = null;
            _surgeStartWave = -1;
            _savedGrade     = -1;
            _surgeActive    = false;
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
