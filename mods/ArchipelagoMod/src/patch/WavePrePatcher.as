package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Pre-spawn wave patcher.  Runs ONCE on the first INGAME frame, before the
     * first wave spawns (currentWave == -1), and mutates the already-built
     * core.waves[] array directly.
     *
     * This replaces the old post-spawn WaveMultiplier approach, fixing two issues:
     *   1. The wave bar tooltip reads from monsterProto — patching the proto means
     *      "Hit points" / "Armor level" in the tooltip show correct values.
     *   2. numOfMonsters cannot be reduced after monsters have spawned, so an
     *      EnemiesPerWaveMultiplier option requires pre-spawn access.
     *
     * All multipliers are percentages: 100 = no change, 150 = 1.5×, 50 = 0.5×.
     *
     * ExtraWaveCount works by mutating stageData.monsterData.wavesNum then
     * re-calling populator.buildMonsterWaveDescs(), which rebuilds core.waves[]
     * with the extended count using the same deterministic seeds for the
     * original waves.  renderWaveStones() is called afterward to refresh the bar.
     */
    public class WavePrePatcher {

        private var _logger:Logger;
        private var _modName:String;

        private var _hpMult:int             = 100;
        private var _armorMult:int          = 100;
        private var _shieldMult:int         = 100;
        private var _enemiesPerWaveMult:int = 100;
        private var _extraWaveCount:int     = 0;

        private var _hasApplied:Boolean     = false;

        // -----------------------------------------------------------------------

        public function WavePrePatcher(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        /**
         * Apply slot_data values.  Call once after AP connects.
         * All multiplier values are percentages (default 100 = no change).
         */
        public function configure(hpMult:int, armorMult:int, shieldMult:int,
                                   enemiesPerWaveMult:int, extraWaveCount:int):void {
            _hpMult             = hpMult;
            _armorMult          = armorMult;
            _shieldMult         = shieldMult;
            _enemiesPerWaveMult = enemiesPerWaveMult;
            _extraWaveCount     = extraWaveCount;
        }

        /**
         * Reset the applied flag so the patcher fires again on the next stage.
         * Call whenever a new battle begins (screen transition to ingame).
         */
        public function resetForNewStage():void {
            _hasApplied = false;
        }

        // -----------------------------------------------------------------------
        // Ingame frame hook

        /**
         * Call every INGAME frame.  Applies pre-spawn patches exactly once,
         * before currentWave reaches 0.  No-ops thereafter.
         */
        public function applyIfReady():void {
            if (_hasApplied) return;

            // Skip entirely when all settings are at their defaults.
            if (_hpMult == 100 && _armorMult == 100 && _shieldMult == 100
                    && _enemiesPerWaveMult == 100 && _extraWaveCount == 0) {
                _hasApplied = true;
                return;
            }

            try {
                var core:* = GV.ingameCore;
                if (core == null) return;
                if (core.currentWave.g() >= 0) {
                    // First wave already started — too late to pre-patch cleanly.
                    _logger.log(_modName, "WavePrePatcher: first wave already started, skipping");
                    _hasApplied = true;
                    return;
                }
                if (core.waves == null || core.waves.length == 0) return;

                _apply(core);
                _hasApplied = true;
            } catch (err:Error) {
                _logger.log(_modName, "WavePrePatcher.applyIfReady ERROR: " + err.message);
            }
        }

        // -----------------------------------------------------------------------

        private function _apply(core:*):void {
            // Step 1: rebuild wave array with extra waves if requested.
            // stageData.monsterData is a shared object that persists across retries,
            // so we must restore wavesNum after the call to avoid accumulating extra
            // waves on each retry.
            if (_extraWaveCount > 0) {
                var origWavesNum:Number = core.stageData.monsterData.wavesNum;
                core.stageData.monsterData.wavesNum = origWavesNum + _extraWaveCount;
                core.populator.buildMonsterWaveDescs();
                core.stageData.monsterData.wavesNum = origWavesNum;  // restore
                // core.waves is now a fresh array containing the original waves
                // plus _extraWaveCount additional waves continuing the scaling curve.
            }

            // Step 2: patch numOfMonsters and monsterProto stats on every wave.
            var waves:Array = core.waves as Array;
            for each (var wave:* in waves) {
                if (wave == null) continue;

                if (_enemiesPerWaveMult != 100) {
                    var newCount:int = Math.max(1,
                        Math.round(wave.numOfMonsters.g() * _enemiesPerWaveMult / 100));
                    wave.numOfMonsters.s(newCount);
                }

                var proto:* = wave.monsterProto;
                if (proto == null) continue;

                if (_hpMult != 100) {
                    var newHp:Number = Math.max(1,
                        Math.round(proto.hp.g() * _hpMult / 100));
                    proto.hp.s(newHp);
                    proto.hpMax.s(newHp);
                }

                if (_armorMult != 100) {
                    proto.armorLevel.s(Math.max(0,
                        Math.round(proto.armorLevel.g() * _armorMult / 100)));
                }

                // shield is a plain int on Monster (not an ENumber).
                if (_shieldMult != 100 && proto.shield > 0) {
                    proto.shield = int(Math.max(0,
                        Math.round(proto.shield * _shieldMult / 100)));
                }
            }

            // Step 3: refresh the wave bar so stone icons reflect any rebuilt waves.
            // The hover tooltip already reads live from monsterProto, so no re-render
            // is needed for HP/armor accuracy — but the stone icons (monster type,
            // attributes, count) need renderWaveStones after a buildMonsterWaveDescs call.
            if (core.renderer2 != null) {
                core.renderer2.renderWaveStones(true, true);
            }

            _logger.log(_modName, "WavePrePatcher: applied to " + waves.length + " waves"
                + "  hp=" + _hpMult + "%"
                + "  armor=" + _armorMult + "%"
                + "  shield=" + _shieldMult + "%"
                + "  enemies=" + _enemiesPerWaveMult + "%"
                + "  extra=" + _extraWaveCount);
        }
    }
}
