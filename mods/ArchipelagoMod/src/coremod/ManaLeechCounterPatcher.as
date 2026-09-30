package coremod {
    import Bezel.Lattice.Lattice;
    import Bezel.Lattice.LatticePatcher;
    import Bezel.Logger;
    import com.cff.anebe.ir.ASClass;
    import com.cff.anebe.ir.ASInstruction;
    import com.cff.anebe.ir.ASMultiname;
    import com.cff.anebe.ir.ASTrait;
    import com.cff.anebe.ir.multinames.ASQName;
    import com.cff.anebe.ir.namespaces.PackageNamespace;

    /**
     * Coremod fix for a vanilla GCFW bug: mana leeched by beam-enhanced tower gems and by trap gems only counts toward the
     * bleeding / poisoned / whited-out leech achievements (Mana Cult, Red Orange, Stolen Shine, ...) when the gem is grade 1
     * AND has already leeched more than 899 mana. Grade 2+ gems contribute nothing.
     *
     * Vanilla IngameCreator.createBeam and Trap.doEnterFrame nest the three GV.ingameStats.manaLeechedFrom*Monsters counters
     * inside the grade-1 achievement block:
     *
     *     if (gem.grade.g() == 0 && gem.manaLeeched > 899) {
     *         checkAchi(600 / 599 / 598 / 597)
     *         if (target.isBleeding) manaLeechedFromBleedingMonsters += gain;   // only reached for grade 1
     *         ...poisoned / whited out...
     *     }
     *
     * Every other hit path (tower shot, bolt, barrage shell, lantern) credits the counters outside the grade check.
     *
     * The patch retargets the block's single `iffalse` so a failed grade check skips only the achievement if/else chain and
     * lands on the counters. Grade-1 gems still run the achievement checks and fall through into the counters as before.
     * The new target is taken from the `jump` that ends the checkAchi(600) branch, which vanilla already points at the first
     * counter check, so no label number is guessed. The stack is empty at both points.
     *
     * Applied unconditionally, standalone saves included (decided 2026-09-15): it only adds leech that vanilla forgot to
     * count. If the expected instruction shape is not found (game update, another coremod), the method is left untouched
     * and an error is logged.
     */
    public class ManaLeechCounterPatcher implements LatticePatcher {

        private var _logger:Logger;
        private var _modName:String;
        private var _className:String;
        private var _methodName:String;

        /** Register the patcher for both affected vanilla methods. Call from loadCoreMod. */
        public static function submitAll(lattice:Lattice, logger:Logger, modName:String):void {
            submitOne(lattice, logger, modName, "com.giab.games.gcfw.ingame.IngameCreator", "createBeam");
            submitOne(lattice, logger, modName, "com.giab.games.gcfw.entity.Trap", "doEnterFrame");
        }

        private static function submitOne(lattice:Lattice, logger:Logger, modName:String, className:String, methodName:String):void {
            lattice.submitPatcher(new ManaLeechCounterPatcher(logger, modName, className, methodName), className);
        }

        public function ManaLeechCounterPatcher(logger:Logger, modName:String, className:String, methodName:String) {
            _logger     = logger;
            _modName    = modName;
            _className  = className;
            _methodName = methodName;
        }

        public function patchClass(clazz:ASClass):void {
            var where:String = _className + "." + _methodName;
            try {
                var trait:ASTrait = clazz.getInstanceTrait(ASQName(PackageNamespace(""), _methodName));
                if (trait == null || trait.funcOrMethod == null || trait.funcOrMethod.body == null) {
                    fail(where, "method not found");
                    return;
                }
                var code:Vector.<ASInstruction> = trait.funcOrMethod.body.instructions;

                // 1. The grade check's exit jump: `pushshort 899, greaterthan, iffalse <end of block>`. Must be unique.
                var gradeJumpIdx:int = -1;
                for (var i:int = 0; i < code.length; i++) {
                    if (code[i].opcode != "pushshort" || int(code[i].args[0]) != 899)
                        continue;
                    var gtIdx:int = nextCode(code, i + 1);
                    if (gtIdx < 0 || code[gtIdx].opcode != "greaterthan")
                        continue;
                    var jIdx:int = nextCode(code, gtIdx + 1);
                    if (jIdx < 0 || code[jIdx].opcode != "iffalse")
                        continue;
                    if (gradeJumpIdx >= 0) {
                        fail(where, "grade check pattern matched more than once");
                        return;
                    }
                    gradeJumpIdx = jIdx;
                }
                if (gradeJumpIdx < 0) {
                    fail(where, "grade check pattern (pushshort 899 / greaterthan / iffalse) not found");
                    return;
                }
                var gradeJump:ASInstruction = code[gradeJumpIdx];
                var blockEndIdx:int = code.indexOf(gradeJump.args[0] as ASInstruction);

                // 2. The first `jump` inside the block ends the checkAchi(600) branch and targets the first counter check.
                var exitJumpIdx:int = -1;
                for (var k:int = gradeJumpIdx + 1; k < code.length && k < blockEndIdx; k++) {
                    if (code[k].opcode == "jump") {
                        exitJumpIdx = k;
                        break;
                    }
                }
                if (exitJumpIdx < 0) {
                    fail(where, "achievement branch jump not found inside the grade block");
                    return;
                }
                var counterStart:ASInstruction = code[exitJumpIdx].args[0] as ASInstruction;
                var counterIdx:int = code.indexOf(counterStart);
                if (counterIdx <= exitJumpIdx || counterIdx >= blockEndIdx) {
                    fail(where, "branch jump target is not inside the grade block (idx " + counterIdx + ")");
                    return;
                }

                // 3. Sanity: the target must lead straight into the `isBleeding` counter check.
                if (!readsPropertySoon(code, counterIdx, "isBleeding", 10)) {
                    fail(where, "branch jump target does not lead into the isBleeding counter check");
                    return;
                }

                gradeJump.args[0] = counterStart;
                clazz.setInstanceTrait(trait);
                _logger.log(_modName, "ManaLeechCounterPatcher: patched " + where + " (grade check now skips only the achievement checks)");
            } catch (err:Error) {
                fail(where, "exception: " + err.message);
            }
        }

        /** Index of the first non-debug instruction at or after `from`, or -1. */
        private static function nextCode(code:Vector.<ASInstruction>, from:int):int {
            for (var i:int = from; i < code.length; i++) {
                if (!code[i].isDebug())
                    return i;
            }
            return -1;
        }

        /** True if a `getproperty <propName>` appears within the next `window` non-debug instructions from `from`. */
        private static function readsPropertySoon(code:Vector.<ASInstruction>, from:int, propName:String, window:int):Boolean {
            var seen:int = 0;
            for (var i:int = from; i < code.length && seen < window; i++) {
                if (code[i].isDebug())
                    continue;
                seen++;
                if (code[i].opcode == "getproperty") {
                    var mn:ASMultiname = code[i].args[0] as ASMultiname;
                    if (mn != null && mn.name == propName)
                        return true;
                }
            }
            return false;
        }

        private function fail(where:String, reason:String):void {
            _logger.log(_modName, "ManaLeechCounterPatcher ERROR: " + where + " left unpatched: " + reason);
        }
    }
}
