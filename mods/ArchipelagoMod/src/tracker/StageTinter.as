package tracker {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import flash.display.MovieClip;
    import flash.geom.ColorTransform;

    import data.AV;
    import net.ConnectionManager;

    /**
     * Drives the existing McFieldToken completion-light MovieClips
     * (lightJourney / lightEndurance / lightTrial) to indicate Archipelago
     * tracker state.  We force each light onto its "lit" frame and apply a
     * ColorTransform so the in-game art (which already perfectly fits each
     * stage's hex shape and position) is reused.
     *
     * Per-stage state (aggregate across the 3 AP locations on the stage):
     *
     *   all 3 checks done                   → leave to game (don't touch)
     *   1 or 2 checks done (partial)        → yellow on all 3 lights
     *   0 done, at least one in logic       → green
     *   0 done, none in logic               → red
     *
     * Must be called every selector frame because adjustFieldTokens() will
     * gotoAndStop() the lights back to their blank frame, wiping our state.
     */
    public class StageTinter {

        private static const STATE_NONE:int    = 0; // leave to game
        private static const STATE_GREEN:int   = 1;
        private static const STATE_RED:int     = 2;
        private static const STATE_YELLOW:int  = 3;

        // Tints applied to the (forced-lit) light MCs.
        private static const CT_GREEN:ColorTransform =
            new ColorTransform(0.35, 1.20, 0.35, 1.0, 0, 60, 0, 0);
        private static const CT_RED:ColorTransform =
            new ColorTransform(1.20, 0.30, 0.30, 1.0, 60, 0, 0, 0);
        private static const CT_YELLOW:ColorTransform =
            new ColorTransform(0, 0, 0, 1.0, 255, 200, 0, 0);
        private static const CT_IDENTITY:ColorTransform =
            new ColorTransform(1.0, 1.0, 1.0, 1.0, 0, 0, 0, 0);

        private var _logger:Logger;
        private var _modName:String;
        private var _cm:ConnectionManager;
        private var _evaluator:LogicEvaluator;

        private var _enabled:Boolean = true;
        private var _loggedError:Boolean = false;

        public function StageTinter(logger:Logger, modName:String,
                                    cm:ConnectionManager, evaluator:LogicEvaluator) {
            _logger    = logger;
            _modName   = modName;
            _cm        = cm;
            _evaluator = evaluator;
        }

        public function set enabled(v:Boolean):void { _enabled = v; }
        public function get enabled():Boolean { return _enabled; }

        /** Called every selector frame with GV.selectorCore.mc. */
        public function apply(mc:*):void {
            if (!_enabled || mc == null || _cm == null || _evaluator == null) return;

            var cnt:* = mc.cntFieldTokens;

            if (!_cm.isConnected) {
                // Reset any tints left from a previous AP session.
                if (cnt != null) {
                    for (var j:int = 0; j < cnt.numChildren; j++) {
                        var tok2:* = cnt.getChildAt(j);
                        if (tok2 != null) paint(tok2, STATE_NONE);
                    }
                }
                return;
            }
            if (cnt == null) return;

            try {
                var metas:Array = (GV.stageCollection != null)
                    ? GV.stageCollection.stageMetas : null;
                if (metas == null) return;

                var missing:Object = AV.saveData.missingLocations;
                var locIds:Object  = ConnectionManager.stageLocIds;

                for (var i:int = 0; i < cnt.numChildren; i++) {
                    var tok:* = cnt.getChildAt(i);
                    if (tok == null) continue;
                    var sid:int = int(tok.id);
                    if (sid < 0 || sid >= metas.length) continue;
                    var meta:* = metas[sid];
                    if (meta == null) continue;
                    var strId:String = String(meta.strId);

                    var base:int = int(locIds[strId]);
                    if (base <= 0) continue;

                    var journeyMissing:Boolean = missing[base] == true;
                    var bonusMissing:Boolean   = missing[base + 500] == true;
                    var stashMissing:Boolean   = missing[base + 1000] == true;
                    var missingCount:int = 0;
                    if (journeyMissing) missingCount++;
                    if (bonusMissing)   missingCount++;
                    if (stashMissing)   missingCount++;

                    var desired:int;
                    if (missingCount == 0) {
                        // All checks done — let game render its completed lights.
                        desired = STATE_NONE;
                    } else if (missingCount < 3) {
                        // Partial progress — yellow.
                        desired = STATE_YELLOW;
                    } else if (_evaluator.stageHasInLogicMissing(
                                   strId, journeyMissing, bonusMissing, stashMissing)) {
                        desired = STATE_GREEN;
                    } else {
                        desired = STATE_RED;
                    }

                    paint(tok, desired);
                }
            } catch (err:Error) {
                if (!_loggedError) {
                    _logger.log(_modName, "StageTinter.apply error: " + err.message);
                    _loggedError = true;
                }
            }
        }

        private function paint(tok:*, state:int):void {
            var jl:MovieClip = tok.lightJourney   as MovieClip;
            var el:MovieClip = tok.lightEndurance as MovieClip;
            var tl:MovieClip = tok.lightTrial     as MovieClip;

            if (state == STATE_NONE) {
                // Leave to game — but reset any tint we may have applied
                // before, otherwise a previously-tinted light keeps its color.
                resetLight(jl);
                resetLight(el);
                resetLight(tl);
                return;
            }

            var ct:ColorTransform;
            if      (state == STATE_GREEN)  ct = CT_GREEN;
            else if (state == STATE_RED)    ct = CT_RED;
            else                            ct = CT_YELLOW;

            // Lit-frame formula taken from SelectorRenderer.adjustFieldTokens():
            //   journey   = fieldType * 3 + 2
            //   endurance = fieldType * 3 + 3
            //   trial     = fieldType * 3 + 4
            var fieldType:int = int(tok.fieldType);
            litLight(jl, fieldType * 3 + 2, ct);
            // Endurance / Trial aren't AP locations yet — leave them alone.
            resetLight(el);
            resetLight(tl);
        }

        private function litLight(light:MovieClip, frame:int, ct:ColorTransform):void {
            if (light == null) return;
            if (frame < 1) frame = 1;
            if (frame > light.totalFrames) frame = light.totalFrames;
            if (light.currentFrame != frame) {
                light.gotoAndStop(frame);
            }
            light.transform.colorTransform = ct;
        }

        private function resetLight(light:MovieClip):void {
            if (light == null) return;
            light.transform.colorTransform = CT_IDENTITY;
        }
    }
}
