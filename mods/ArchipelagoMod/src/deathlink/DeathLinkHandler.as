package deathlink {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.SB;
    import com.giab.games.gcfw.constants.BattleMode;
    import com.giab.games.gcfw.entity.Monster;
    import flash.utils.getTimer;

    import ui.SystemToast;

    /**
     * Handles DeathLink send and receive for the Archipelago mod.
     *
     * Punishment modes (set from slot_data):
     *   gem_loss    (0) — destroy Math.ceil(occupiedBuildings * gemLossPercent / 100) random
     *                     buildings (tower/trap) that contain a gem, along with their gem.
     *   wave_surge  (1) — queue waveSurgeCount extra batches of the current wave's
     *                     monsterProto, each batch enraged as if the enrage slot held
     *                     a grade-waveSurgeGemLevel gem. Batches drip in over ~15s; the
     *                     wave bar stays put and future waves are untouched.
     *   instant_fail(2) — fail the current level immediately (Endurance ends with victory
     *                     since it has no proper defeat path).
     *   spawn_horde (3) — queue spawnHordeCount copies of the current wave's monsterProto
     *                     all at once with no enrage. A flood of vanilla-strength enemies.
     *   spawn_special(4) — spawn spawnSpecialCount specials picked at random from the
     *                      enabled element list, HP scaled as if it were currentWave + 10.
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

        public static const PUNISHMENT_GEM_LOSS:int      = 0;
        public static const PUNISHMENT_WAVE_SURGE:int    = 1;
        public static const PUNISHMENT_INSTANT_FAIL:int  = 2;
        public static const PUNISHMENT_SPAWN_HORDE:int   = 3;
        public static const PUNISHMENT_SPAWN_SPECIAL:int = 4;

        // Per-type HP / armor multipliers applied to the current wave's
        // monsterProto stats. Scaling off the proto (instead of letting
        // vanilla's createXxx formulas compute from waveNum) keeps specials
        // proportionate to whatever the player is currently fighting —
        // vanilla bakes in flat baselines (e.g. +5000 hp on Wizard Hunter)
        // that turn into boss-tier values even at small wave numbers.
        // Index order matches _SPECIAL_TYPE_NAMES.
        private static const _SPECIAL_TYPE_NAMES:Array = [
            "Apparition", "Wraith", "Specter", "Spire", "Wizard Hunter"
        ];
        private static const _SPECIAL_HP_MULTS:Array    = [1.5, 2.0, 2.5, 3.0, 3.0];
        private static const _SPECIAL_ARMOR_MULTS:Array = [1.0, 1.0, 1.0, 1.0, 2.0];

        private var _logger:Logger;
        private var _modName:String;
        private var _toast:SystemToast;

        // Settings
        private var _enabled:Boolean              = false;
        private var _punishment:int               = PUNISHMENT_GEM_LOSS;
        private var _gemLossPercent:int           = 20;
        private var _waveSurgeCount:int           = 3;
        private var _waveSurgeGemLevel:int        = 3;
        private var _spawnHordeCount:int          = 100;
        private var _spawnSpecialElements:Array   = ["Apparition", "Specter", "Wraith", "Spire", "Wizard Hunter"];
        private var _spawnSpecialCount:int        = 3;
        private var _gracePeriodMs:int            = 15000;
        private var _cooldownMs:int               = 20000;

        // Queue / timer state
        private var _pendingQueue:Array          = [];
        private var _stageStartTime:int          = -1; // set on first unpause; -1 = not yet
        private var _lastPunishmentTime:int      = 0;
        private var _deathProcessed:Boolean      = false;
        // Set when an inbound DeathLink directly destroys our orb (instant_fail).
        // Tells checkForDeath to suppress the outbound send so we don't bounce the
        // very death we just received back to the killer.
        private var _suppressNextDeathSend:Boolean = false;

        /** Fired when the player's orb is destroyed. ():void */
        public var onPlayerDied:Function;
        /** Fired when a DeathLink is received and queued. (source:String):void */
        public var onPunishmentReceived:Function;

        public function DeathLinkHandler(logger:Logger, modName:String, toast:SystemToast) {
            _logger  = logger;
            _modName = modName;
            _toast   = toast;
        }

        public function get enabled():Boolean        { return _enabled; }
        public function set enabled(v:Boolean):void  { _enabled = v; }
        public function get punishment():int             { return _punishment; }
        public function get gemLossPercent():int         { return _gemLossPercent; }
        public function get waveSurgeCount():int         { return _waveSurgeCount; }
        public function get waveSurgeGemLevel():int      { return _waveSurgeGemLevel; }
        public function get spawnHordeCount():int        { return _spawnHordeCount; }
        public function get spawnSpecialElements():Array { return _spawnSpecialElements; }
        public function get spawnSpecialCount():int      { return _spawnSpecialCount; }
        public function get gracePeriodSec():int         { return _gracePeriodMs / 1000; }
        public function get cooldownSec():int            { return _cooldownMs / 1000; }

        public function configure(slotData:Object):void {
            if (slotData.death_link_punishment   !== undefined) _punishment        = int(slotData.death_link_punishment);
            if (slotData.gem_loss_percent        !== undefined) _gemLossPercent    = int(slotData.gem_loss_percent);
            if (slotData.wave_surge_count        !== undefined) _waveSurgeCount    = int(slotData.wave_surge_count);
            if (slotData.wave_surge_gem_level    !== undefined) _waveSurgeGemLevel = int(slotData.wave_surge_gem_level);
            if (slotData.spawn_horde_count       !== undefined) _spawnHordeCount   = int(slotData.spawn_horde_count);
            if (slotData.spawn_special_elements  !== undefined && slotData.spawn_special_elements is Array) {
                _spawnSpecialElements = (slotData.spawn_special_elements as Array).concat();
            }
            if (slotData.spawn_special_count     !== undefined) _spawnSpecialCount = int(slotData.spawn_special_count);
            if (slotData.death_link_grace_period !== undefined) _gracePeriodMs     = int(slotData.death_link_grace_period) * 1000;
            if (slotData.death_link_cooldown     !== undefined) _cooldownMs        = int(slotData.death_link_cooldown)     * 1000;
            _logger.log(_modName, "DeathLink configured: enabled=" + _enabled
                + " punishment=" + _punishment
                + " gemLoss=" + _gemLossPercent + "%"
                + " surgeCount=" + _waveSurgeCount + " surgeLevel=" + _waveSurgeGemLevel
                + " hordeCount=" + _spawnHordeCount
                + " specials=[" + _spawnSpecialElements.join(",") + "] x" + _spawnSpecialCount
                + " gracePeriod=" + (_gracePeriodMs / 1000) + "s"
                + " cooldown=" + (_cooldownMs / 1000) + "s");
        }

        public function resetForNewStage():void {
            _deathProcessed       = false;
            _stageStartTime       = -1;
            _lastPunishmentTime   = getTimer();
            _pendingQueue         = [];
            _suppressNextDeathSend = false;
        }

        // -----------------------------------------------------------------------
        // Per-frame checks

        public function checkForDeath():void {
            if (!_enabled || _deathProcessed) return;
            try {
                if (GV.ingameController == null || GV.ingameController.core == null) return;
                var core:* = GV.ingameController.core;
                // Skip pre-start: a non-null `ending` left over from the previous
                // defeat's outcome panel would otherwise re-fire the death the
                // moment DeathLink is enabled (e.g. on connect). Real deaths only
                // happen once monsters can damage the orb — i.e. after wave 0
                // has been activated.
                if (core.currentWave.g() < 0) return;
                var ending:* = core.ending;
                if (ending == null || ending.isBattleWon) return;
                _deathProcessed = true;
                if (_suppressNextDeathSend) {
                    _suppressNextDeathSend = false;
                    _logger.log(_modName, "DEATHLINK — orb destroyed by inbound DL (instant_fail); not bouncing");
                    return;
                }
                _logger.log(_modName, "DEATHLINK — orb destroyed, sending death");
                if (onPlayerDied != null) onPlayerDied();
            } catch (err:Error) {
                _logger.log(_modName, "checkForDeath error: " + err.message);
            }
        }

        public function checkQueue():void {
            if (!_enabled) return;
            try {
                if (GV.ingameController == null || GV.ingameController.core == null) return;
                var core:* = GV.ingameController.core;

                // Track the stage-start time as soon as the player unpauses,
                // even with nothing queued — that way the grace period
                // counts down during normal play instead of restarting the
                // moment a DeathLink shows up mid-stage.
                if (_stageStartTime < 0 && core.currentWave.g() >= 0) {
                    _stageStartTime = getTimer();
                    _logger.log(_modName, "DeathLink grace period started");
                }

                if (_pendingQueue.length == 0) return;
                if (_stageStartTime < 0) return; // still in pre-start

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
         * Milliseconds until the head of the queue could actually apply,
         * given the larger of (grace remaining since stage start) and
         * (cooldown remaining since last punishment). Returns 0 if nothing
         * is gating the next apply.
         */
        public function get nextApplyDelayMs():int {
            var now:int = getTimer();
            var graceLeft:int = (_stageStartTime < 0)
                ? _gracePeriodMs
                : Math.max(0, _gracePeriodMs - (now - _stageStartTime));
            var cooldownLeft:int = Math.max(0, _cooldownMs - (now - _lastPunishmentTime));
            return Math.max(graceLeft, cooldownLeft);
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

        public function testGemLoss():void      { applyGemLoss(); }
        public function testWaveSurge():void    { applyWaveSurge(); }
        public function testInstantFail():void  { applyInstantFail(); }
        public function testSpawnHorde():void   { applySpawnHorde(); }
        public function testSpawnSpecial():void { applySpawnSpecial(); }

        // -----------------------------------------------------------------------
        // Punishment implementations

        private function applyPunishmentNow(source:String):void {
            try {
                switch (_punishment) {
                    case PUNISHMENT_GEM_LOSS:      applyGemLoss();      break;
                    case PUNISHMENT_WAVE_SURGE:    applyWaveSurge();    break;
                    case PUNISHMENT_INSTANT_FAIL:  applyInstantFail();  break;
                    case PUNISHMENT_SPAWN_HORDE:   applySpawnHorde();   break;
                    case PUNISHMENT_SPAWN_SPECIAL: applySpawnSpecial(); break;
                }
            } catch (err:Error) {
                _logger.log(_modName, "applyPunishmentNow error: " + err.message);
            }
        }

        private function applyGemLoss():void {
            var core:* = GV.ingameController.core;

            // Collect all occupied buildings (tower / trap / lantern with a gem).
            var occupied:Array = [];
            var towers:Array   = core.towers   as Array;
            var traps:Array    = core.traps    as Array;
            var lanterns:Array = core.lanterns as Array;
            for each (var t:*    in towers)   { if (t    != null && t.insertedGem    != null) occupied.push(t); }
            for each (var trap:* in traps)    { if (trap != null && trap.insertedGem != null) occupied.push(trap); }
            for each (var l:*    in lanterns) { if (l    != null && l.insertedGem    != null) occupied.push(l); }

            if (occupied.length == 0) {
                _toast.addMessage("DeathLink: no gems on the field!", 0xFFFF8844);
                return;
            }

            var toDestroy:int = Math.ceil(occupied.length * _gemLossPercent / 100);
            shuffleArray(occupied);

            for (var i:int = 0; i < toDestroy; i++) {
                var building:* = occupied[i];
                // demolishOwnBuilding expects tile coords (fieldX/fieldY), not pixel coords.
                // pIsByPlayer=false: don't consume a demolition charge.
                // pIsByEnemy=false:  don't skip traps/walls.
                //
                // Trap special case: the Trap branch in demolishOwnBuilding only fires when
                // insertedGem == null (no !pIsByPlayer bypass exists for traps). Strip the
                // gem first so the demolish path can proceed normally.
                if (traps != null && traps.indexOf(building) >= 0) {
                    stripGemFromBuilding(core, building);
                }
                core.destroyer.demolishOwnBuilding(
                    building.fieldX, building.fieldY, false, false, false);
                _logger.log(_modName, "  demolished building at tile ("
                    + building.fieldX + "," + building.fieldY + ")");
            }

            _toast.addMessage("DeathLink! " + toDestroy + " gem"
                + (toDestroy == 1 ? "" : "s") + " destroyed!", 0xFFFF4444);
        }

        /**
         * Removes a gem from a building's display containers and game arrays without
         * demolishing the building. Used before demolishOwnBuilding for building types
         * (Trap) that don't handle the occupied case natively.
         */
        private function stripGemFromBuilding(core:*, building:*):void {
            var gem:* = building.insertedGem;
            if (gem == null) return;
            var cnt:* = core.cnt;
            try { cnt.cntDraggedGem.removeChild(gem.mc); }        catch (e:Error) {}
            try { cnt.cntGemsInInventory.removeChild(gem.mc); }   catch (e:Error) {}
            try { cnt.cntGemsInTowers.removeChild(gem.mc); }      catch (e:Error) {}
            try { cnt.cntGemInEnragingSlot.removeChild(gem.mc); } catch (e:Error) {}
            var idx:int = (core.gems as Array).indexOf(gem);
            if (idx >= 0) (core.gems as Array).splice(idx, 1);
            gem.removeData();
            building.insertedGem = null;
        }

        /**
         * Queue _waveSurgeCount extra batches of the current wave's monsters,
         * each batch enraged as if the enrage slot held a grade-_waveSurgeGemLevel
         * gem. Batches drip in over ~15s; the wave bar stays put and future
         * waves remain untouched.
         */
        private function applyWaveSurge():void {
            var core:* = GV.ingameController.core;
            if (core == null || core.waves == null) return;
            var w:* = core.waves[core.currentWave.g()];
            if (w == null || w.monsterProto == null) {
                _toast.addMessage("DeathLink! No wave to surge!", 0xFFFF8844);
                return;
            }

            var perBatch:int = int(w.numOfMonsters.g());
            // Per-batch spawn window is roughly the same shape vanilla uses
            // (NORMAL formation, ~1.4s end-to-end). Then we gap by ~5s so a
            // 3-batch surge drips across ~15s.
            var perMonsterMs:Number = (perBatch > 0) ? (1400.0 / perBatch) : 1400.0;
            var batchGapMs:Number   = 5000.0;
            var spawned:int = 0;

            for (var k:int = 0; k < _waveSurgeCount; k++) {
                var batchOffset:Number = k * batchGapMs;
                for (var i:int = 0; i < perBatch; i++) {
                    if (_spawnMonsterFromProto(core, w.monsterProto,
                            _waveSurgeGemLevel, batchOffset + i * perMonsterMs))
                        spawned++;
                }
            }

            _logger.log(_modName, "  waveSurge: queued " + spawned + " enraged monsters across "
                + _waveSurgeCount + " batches (grade " + _waveSurgeGemLevel + ")");
            _toast.addMessage("DeathLink! " + spawned + " enraged monsters incoming!",
                0xFFFF4444);
        }

        /**
         * Queue spawnHordeCount copies of the current wave's monsterProto with
         * no enrage. All spawns are staggered over ~1.4s so they enter the
         * scene in a tight cluster like an oversized normal wave.
         */
        private function applySpawnHorde():void {
            var core:* = GV.ingameController.core;
            if (core == null || core.waves == null) return;
            var w:* = core.waves[core.currentWave.g()];
            if (w == null || w.monsterProto == null) {
                _toast.addMessage("DeathLink! No wave to horde!", 0xFFFF8844);
                return;
            }

            var count:int = _spawnHordeCount;
            // Same ~1.4s window vanilla uses for a wave so the horde feels
            // dense rather than dribbling out.
            var perMonsterMs:Number = (count > 0) ? (1400.0 / count) : 1400.0;
            var spawned:int = 0;
            for (var i:int = 0; i < count; i++) {
                if (_spawnMonsterFromProto(core, w.monsterProto, 0, i * perMonsterMs))
                    spawned++;
            }

            _logger.log(_modName, "  spawnHorde: queued " + spawned + " monsters from wave "
                + (core.currentWave.g() + 1));
            _toast.addMessage("DeathLink! Horde of " + spawned + " incoming!",
                0xFFFF4444);
        }

        /**
         * Spawn spawnSpecialCount specials picked at random from the configured
         * element list. HP and armor are scaled off the current wave's
         * monsterProto so specials track normal-wave difficulty instead of
         * exploding via vanilla's flat-baseline formulas.
         */
        private function applySpawnSpecial():void {
            var core:* = GV.ingameController.core;
            if (core == null || core.creator == null) return;
            if (_spawnSpecialElements == null || _spawnSpecialElements.length == 0) {
                _toast.addMessage("DeathLink! No specials enabled!", 0xFFFF8844);
                return;
            }

            var w:* = (core.waves != null) ? core.waves[core.currentWave.g()] : null;
            if (w == null || w.monsterProto == null) {
                _toast.addMessage("DeathLink! No wave to scale from!", 0xFFFF8844);
                return;
            }
            var baseHp:Number    = Number(w.monsterProto.hp.g());
            var baseArmor:Number = Number(w.monsterProto.armorLevel.g());

            var spawned:int = 0;
            for (var i:int = 0; i < _spawnSpecialCount; i++) {
                var pick:String = String(_spawnSpecialElements[
                    int(Math.random() * _spawnSpecialElements.length)]);
                if (_spawnSpecialOfType(core, pick, baseHp, baseArmor))
                    spawned++;
            }

            _logger.log(_modName, "  spawnSpecial: spawned " + spawned + " specials (baseHp="
                + baseHp + " baseArmor=" + baseArmor + ")");
            _toast.addMessage("DeathLink! " + spawned + " specials incoming!", 0xFFFF4444);
        }

        /**
         * Dispatch to the matching IngameCreator factory with explicit HP /
         * armor values (scaled off the current wave's monsterProto via the
         * per-type multipliers above). Vanilla's pHp/pArmor != -1 path
         * overrides its built-in formulas so specials don't pick up the
         * flat boss-tier baselines. Returns true if a special was created.
         */
        private function _spawnSpecialOfType(core:*, kind:String,
                                             baseHp:Number, baseArmor:Number):Boolean {
            var typeIdx:int = _SPECIAL_TYPE_NAMES.indexOf(kind);
            if (typeIdx < 0) return false;
            var hp:Number    = Math.max(1, Math.round(baseHp    * Number(_SPECIAL_HP_MULTS[typeIdx])));
            var armor:Number = Math.max(0, Math.round(baseArmor * Number(_SPECIAL_ARMOR_MULTS[typeIdx])));
            try {
                switch (kind) {
                    case "Apparition":
                        core.creator.createApparition(0, hp, armor);
                        return true;
                    case "Wraith":
                        core.creator.createWraith(0, hp, armor);
                        return true;
                    case "Specter":
                        core.creator.createSpecter(0, hp, armor);
                        return true;
                    case "Spire":
                        core.creator.createSpire(0, hp, armor);
                        return true;
                    case "Wizard Hunter":
                        core.creator.createWizardHunter(0, hp, armor);
                        return true;
                }
            } catch (err:Error) {
                _logger.log(_modName, "_spawnSpecialOfType(" + kind + ") error: " + err.message);
            }
            return false;
        }

        /**
         * Build one monster from a wave's monsterProto and queue it into
         * monstersWaitingInWave with the given spawn delay. If gemGrade > 0,
         * the same enrage formulas vanilla uses for the enrage slot are
         * applied; gemGrade <= 0 skips enrage entirely (vanilla-strength).
         * Returns true on success.
         *
         * Reusable: anything that wants to inject a current-wave-style
         * monster can call this with its own grade and delay.
         */
        private function _spawnMonsterFromProto(core:*, proto:*,
                                                gemGrade:int,
                                                delayMs:Number):Boolean {
            if (proto == null) return false;

            var spawnArr:Array = core.pathEntryNodes as Array;
            if (spawnArr == null || spawnArr.length == 0)
                spawnArr = core.monsterNests as Array;
            if (spawnArr == null || spawnArr.length == 0) return false;
            var pathSrc:* = spawnArr[int(Math.random() * spawnArr.length)];

            var doEnrage:Boolean = gemGrade > 0;
            var grade:int = gemGrade - 1;
            var hpFactor:Number  = doEnrage ? (Math.pow(1.8, grade + 1) - 1) : 0;
            var armFactor:Number = doEnrage ? (Math.pow(1.5, grade + 1) - 1) : 0;
            var xpFactor:Number  = doEnrage ? (Math.pow(1.2, grade + 1) - 1) : 0;

            var m:Monster = new Monster(proto.isGiant, proto.isSwarmling,
                proto.manaBase.g(), proto.hp.g(), proto.speedMax, proto.armorLevel.g(),
                pathSrc, proto.attributes, proto.buffPower,
                proto.costToBanishMultiplier, proto.xpBase.g(), proto.xpMult);
            m.timeUntilEnterScene = delayMs;
            m.waveNum = proto.waveNum;
            m.manaBase.s(proto.manaBase.g() * core.stageData.monsterData.manaOnKillMult);
            m.xpBase.s(proto.xpBase.g());
            m.costToBanishMultiplier /= 2;

            // Cosmetic body parts — same copy block vanilla uses in
            // IngamePopulator.buildNextWave so rendering matches a real wave.
            m.idMbpSwarmlingBody       = proto.idMbpSwarmlingBody;
            m.idMbpReaverBody          = proto.idMbpReaverBody;
            m.idMbpReaverHead          = proto.idMbpReaverHead;
            m.idMbpReaverArmLowerLeft  = proto.idMbpReaverArmLowerLeft;
            m.idMbpReaverArmLowerRight = proto.idMbpReaverArmLowerRight;
            m.idMbpReaverArmUpperLeft  = proto.idMbpReaverArmUpperLeft;
            m.idMbpReaverArmUpperRight = proto.idMbpReaverArmUpperRight;
            m.idMbpGiantBodyLower      = proto.idMbpGiantBodyLower;
            m.idMbpGiantBodyUpper      = proto.idMbpGiantBodyUpper;
            m.idMbpGiantHead           = proto.idMbpGiantHead;
            m.idMbpGiantArmUpper1      = proto.idMbpGiantArmUpper1;
            m.idMbpGiantArmUpper2      = proto.idMbpGiantArmUpper2;
            m.idMbpGiantArmLower1      = proto.idMbpGiantArmLower1;
            m.idMbpGiantArmLower2      = proto.idMbpGiantArmLower2;
            if (!proto.isSwarmling) {
                m.elbowBasePosX0 = m.elbowBasePosX1 = proto.elbowBasePosX0;
                m.elbowBasePosY0 = proto.elbowBasePosY0;
                m.elbowBasePosY1 = proto.elbowBasePosY1;
                m.elbowBasePosX2 = m.elbowBasePosX3 = proto.elbowBasePosX2;
                m.elbowBasePosY2 = proto.elbowBasePosY2;
                m.elbowBasePosY3 = proto.elbowBasePosY3;
                m.longBodyDist   = proto.longBodyDist;
            }
            m.shield                       = proto.shield;
            m.armorLevel.s(proto.armorLevel.g());
            m.whenKilledSpawnHp            = proto.whenKilledSpawnHp;
            m.whenKilledHealOthersHp       = proto.whenKilledHealOthersHp;
            m.whenKilledResocketTowersRange = proto.whenKilledResocketTowersRange;
            m.whenKilledBeaconSummonHp     = proto.whenKilledBeaconSummonHp;
            m.banishmentManaBurnRatio      = proto.banishmentManaBurnRatio;
            m.extraArmorBuffAmount         = proto.extraArmorBuffAmount;
            m.extraHpBuffAmount            = proto.extraHpBuffAmount;
            m.extraSpeedBuffMult           = proto.extraSpeedBuffMult;

            // Manual enrage — mirrors IngamePopulator.buildNextWave's enrage
            // block, but driven by gemGrade rather than the enrage-slot gem.
            // Skipped when gemGrade <= 0 (used by spawn_horde).
            if (doEnrage) {
                m.hp.s(Math.floor(m.hp.g() * (1 + hpFactor)));
                m.hpMax.s(m.hp.g());
                m.armorLevel.s(Math.floor(m.armorLevel.g() * (1 + armFactor)));
                m.xpBase.s(m.xpBase.g() * (1 + xpFactor));
                m.isFromEnragedWave = true;
            }

            (core.monstersWaitingInWave as Array).push(m);
            return true;
        }

        private function applyInstantFail():void {
            var core:* = GV.ingameController.core;
            // The next checkForDeath will see the orb destroyed by *us* and
            // would otherwise bounce a DeathLink back to the killer. Flag the
            // upcoming death as a side-effect of this punishment and have
            // checkForDeath swallow the outbound send exactly once.
            _suppressNextDeathSend = true;
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

        private function shuffleArray(arr:Array):void {
            for (var i:int = arr.length - 1; i > 0; i--) {
                var j:int = int(Math.random() * (i + 1));
                var tmp:* = arr[i]; arr[i] = arr[j]; arr[j] = tmp;
            }
        }
    }
}
