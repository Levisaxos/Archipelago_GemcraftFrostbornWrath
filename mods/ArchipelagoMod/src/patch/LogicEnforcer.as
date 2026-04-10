package patch {
    import flash.events.MouseEvent;
    import flash.filters.GlowFilter;
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import tracker.LogicEvaluator;

    /**
     * When enforce_logic is enabled in the YAML, prevents starting out-of-logic
     * stages in Journey mode by blocking the "Start the battle" button (btnStartStage).
     *
     * Journey mode hosts all Archipelago check locations, so blocking it forces
     * the player to follow the randomizer's intended progression order.
     * Endurance and Trial modes are unaffected (they have no AP checks).
     *
     * Mirrors the FirstPlayBypass pattern: capture-phase listeners block the
     * start button, and per-frame hover detection drives a tooltip.
     */
    public class LogicEnforcer {

        private var _logger:Logger;
        private var _modName:String;
        private var _logicEval:LogicEvaluator;
        private var _enforceLogic:Boolean        = false;
        private var _blockListenersAdded:Boolean = false;
        private var _tooltipFor:String           = null; // "start" or null

        private static const SETTINGS_IDLE:int = 7;
        private static const COLOR_TITLE:uint  = 0xC6977F;
        private static const COLOR_WARN:uint   = 0xFFAA44;

        // -----------------------------------------------------------------------

        public function LogicEnforcer(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        /**
         * Feed the logic evaluator and the enforce_logic flag from slot_data.
         * Call once after the Connected packet is received.
         */
        public function configure(logicEval:LogicEvaluator, enforceLogic:Boolean):void {
            _logicEval    = logicEval;
            _enforceLogic = enforceLogic;
            _logger.log(_modName, "LogicEnforcer configured — enforceLogic=" + enforceLogic);
        }

        // -----------------------------------------------------------------------
        // Selector frame hook — call every frame while on the selector screen

        public function onSelectorFrame(mc:*):void {
            if (!_enforceLogic || _logicEval == null || mc == null) return;

            // Install capture-phase blockers on btnStartStage once.
            if (!_blockListenersAdded) {
                var ss:* = mc.mcStageSettings;
                if (ss != null) {
                    if (ss.btnStartStage != null) {
                        ss.btnStartStage.addEventListener(MouseEvent.MOUSE_DOWN,
                                                     _onBlock, true, 101, true);
                        ss.btnStartStage.addEventListener(MouseEvent.MOUSE_UP,
                                                     _onBlock, true, 101, true);
                        _blockListenersAdded = true;
                        _logger.log(_modName, "LogicEnforcer: btnStartStage block listeners installed");
                    } else {
                        // Enumerate children once to help diagnose the correct button name.
                        _logger.log(_modName, "LogicEnforcer: WARNING — btnStartStage not found; children of mcStageSettings:");
                        for (var i:int = 0; i < ss.numChildren; i++) {
                            _logger.log(_modName, "  [" + i + "] " + ss.getChildAt(i).name);
                        }
                        _blockListenersAdded = true; // prevent repeated spam
                    }
                }
            }

            // Only apply visual state while the settings panel is open and idle.
            if (int(GV.selectorCore.screenStatus) != SETTINGS_IDLE) {
                _hideTooltip();
                return;
            }
            if (GV.ingameCore == null || GV.ingameCore.stageMeta == null) return;

            var strId:String       = String(GV.ingameCore.stageMeta.strId);
            var outOfLogic:Boolean = !_logicEval.isStageInLogic(strId);
            var stgSt:*            = mc.mcStageSettings;
            if (stgSt == null) return;

            // Dim / restore btnStartStage alpha.
            if (stgSt.btnStartStage != null) {
                stgSt.btnStartStage.alpha = outOfLogic ? 0.35 : 1.0;
            }

            if (!outOfLogic) {
                _hideTooltip();
                return;
            }

            // Show tooltip when hovering the dimmed button.
            if (stgSt.btnStartStage != null && stgSt.stage != null) {
                var mx:Number = stgSt.stage.mouseX;
                var my:Number = stgSt.stage.mouseY;
                if (stgSt.btnStartStage.hitTestPoint(mx, my, true)) {
                    _showTooltip("start", "Start the Battle");
                } else {
                    _hideTooltip();
                }
            }
        }

        // -----------------------------------------------------------------------
        // Capture-phase click blocker

        private function _onBlock(e:MouseEvent):void {
            if (!_isOutOfLogic()) return;
            e.stopImmediatePropagation();
        }

        private function _isOutOfLogic():Boolean {
            if (_logicEval == null || GV.ingameCore == null ||
                    GV.ingameCore.stageMeta == null) return false;
            return !_logicEval.isStageInLogic(String(GV.ingameCore.stageMeta.strId));
        }

        // -----------------------------------------------------------------------
        // Tooltip helpers — reuse GV.mcInfoPanel, same as FirstPlayBypass

        private function _showTooltip(btnId:String, title:String):void {
            if (_tooltipFor == btnId) return;
            _tooltipFor = btnId;
            GV.mcInfoPanel.reset(410);
            GV.mcInfoPanel.addTextfield(COLOR_TITLE, title, false, 13,
                [new GlowFilter(0x979360, 1, 25, 5, 1, 1)]);
            GV.mcInfoPanel.addExtraHeight(5);
            GV.mcInfoPanel.addSeparator(-2);
            GV.mcInfoPanel.addTextfield(COLOR_WARN,
                "Beat more stages in previous tiers to unlock this stage", false, 12, null, 0xFFFFFF);
            GV.main.cntInfoPanel.addChild(GV.mcInfoPanel);
            GV.mcInfoPanel.doEnterFrame();
        }

        private function _hideTooltip():void {
            if (_tooltipFor == null) return;
            _tooltipFor = null;
            try {
                if (GV.main.cntInfoPanel.contains(GV.mcInfoPanel)) {
                    GV.main.cntInfoPanel.removeChild(GV.mcInfoPanel);
                }
            } catch (err:Error) {}
        }
    }
}
