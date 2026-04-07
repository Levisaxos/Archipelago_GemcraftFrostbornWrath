package patch {
    import flash.events.MouseEvent;
    import flash.filters.GlowFilter;
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Bypasses first-play restrictions on journey levels.
     *
     * Vanilla behaviour when a stage has never been beaten in Journey (XP == 0):
     *   1. Clicking the stage token skips the settings screen entirely.
     *   2. Skill-unlocked gem types are not added to availableGemTypes.
     *
     * This patch:
     *   1. Intercepts the stage-token CLICK (capture phase) to force the settings
     *      screen to open normally, so battle traits can be edited.
     *   2. Locks Endurance / Trial buttons while journey XP == 0.  Capture-phase
     *      MOUSE_DOWN/UP listeners (priority 101) block the game's click handlers.
     *      Hover detection is done per-frame via hitTestPoint on stage.mouseX/Y,
     *      avoiding any listener registration timing issues.
     *   3. On the first frame of INGAME for an unbeaten stage, injects skill-unlocked
     *      gem types that the initializer skipped.
     *
     * Not active in Iron mode (GameMode.IRON == 2).
     */
    public class FirstPlayBypass {

        private var _logger:Logger;
        private var _modName:String;

        private var _captureListenerAdded:Boolean  = false;
        private var _blockListenersAdded:Boolean   = false;
        private var _patchedIngameStageId:int      = -1;

        // Which locked button is the tooltip currently showing for ("endurance",
        // "trial", or null = hidden).
        private var _tooltipFor:String = null;

        // -----------------------------------------------------------------------
        // Numeric constants

        private static const STAGES_IDLE:int        = 4;
        private static const STAGES_TO_SETTINGS:int = 5;
        private static const SETTINGS_IDLE:int      = 7;

        private static const GAME_MODE_IRON:int     = 2;
        private static const BATTLE_MODE_JOURNEY:int = 0;

        private static const COLOR_TITLE:uint = 0xC6977F;
        private static const COLOR_WARN:uint  = 0xFF7744;

        // Skill gem mappings: [SkillId, GemComponentType, arrIsSpellBtnVisible index]
        private static const SKILL_GEM_MAP:Array = [
            [6,  0,  6],
            [7,  1,  7],
            [8,  2,  8],
            [9,  3,  9],
            [10, 4, 10],
            [11, 5, 11]
        ];

        // -----------------------------------------------------------------------

        public function FirstPlayBypass(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        // -----------------------------------------------------------------------
        // Selector frame hook

        public function onSelectorFrame(mc:*):void {
            if (mc == null) return;

            // Install stage-token capture interceptor.
            if (!_captureListenerAdded) {
                var cntFT:* = mc.cntFieldTokens;
                if (cntFT != null) {
                    cntFT.addEventListener(MouseEvent.CLICK, _onFieldTokenClick,
                                           true, 100, true);
                    _captureListenerAdded = true;
                }
            }

            // Install capture-phase MOUSE_DOWN/UP blockers on Endurance/Trial buttons.
            // These fire before the game's handlers regardless of mouseChildren state.
            if (!_blockListenersAdded) {
                var ss:* = mc.mcStageSettings;
                if (ss != null && ss.btnEndurance != null && ss.btnTrial != null) {
                    ss.btnEndurance.addEventListener(MouseEvent.MOUSE_DOWN,
                                                    _onLockedBtnBlock, true, 101, true);
                    ss.btnEndurance.addEventListener(MouseEvent.MOUSE_UP,
                                                    _onLockedBtnBlock, true, 101, true);
                    ss.btnTrial.addEventListener(MouseEvent.MOUSE_DOWN,
                                                _onLockedBtnBlock, true, 101, true);
                    ss.btnTrial.addEventListener(MouseEvent.MOUSE_UP,
                                                _onLockedBtnBlock, true, 101, true);
                    _blockListenersAdded = true;
                    _logger.log(_modName, "FirstPlayBypass: block listeners installed");
                }
            }

            // Visual lock state + tooltip every frame while settings panel is open.
            if (GV.ppd == null || GV.selectorCore == null) return;
            if (int(GV.selectorCore.screenStatus) != SETTINGS_IDLE) {
                _hideTooltip();
                return;
            }
            if (GV.ingameCore == null || GV.ingameCore.stageMeta == null) return;

            var stageId:int       = int(GV.ingameCore.stageMeta.id);
            var firstPlay:Boolean = GV.ppd.stageHighestXpsJourney[stageId].g() < 1;
            var stgSt:*           = mc.mcStageSettings;
            if (stgSt == null) return;

            stgSt.btnEndurance.alpha = firstPlay ? 0.35 : 1.0;
            if (stgSt.btnTrial.visible) {
                stgSt.btnTrial.alpha = firstPlay ? 0.35 : 1.0;
            }

            // Per-frame hover detection: use stage.mouseX/Y + hitTestPoint.
            // This avoids listener registration timing issues entirely.
            if (!firstPlay) {
                _hideTooltip();
            } else if (stgSt.stage != null) {
                var mx:Number = stgSt.stage.mouseX;
                var my:Number = stgSt.stage.mouseY;

                var overEndurance:Boolean = stgSt.btnEndurance.hitTestPoint(mx, my, true);
                var overTrial:Boolean =
                    stgSt.btnTrial.visible && stgSt.btnTrial.hitTestPoint(mx, my, true);

                if (overEndurance) {
                    _showTooltip("endurance", "Endurance Mode");
                } else if (overTrial) {
                    _showTooltip("trial", "Wizard Trial Mode");
                } else {
                    _hideTooltip();
                }
            }
        }

        // -----------------------------------------------------------------------
        // Ingame frame hook

        public function onIngameFrame():void {
            try {
                if (GV.ingameCore == null || GV.ppd == null) return;
                if (GV.ppd.gameMode == GAME_MODE_IRON) return;

                var stageMeta:* = GV.ingameCore.stageMeta;
                if (stageMeta == null) return;
                var stageId:int = int(stageMeta.id);

                if (_patchedIngameStageId == stageId) return;

                if (GV.ppd.stageHighestXpsJourney[stageId].g() != 0) {
                    _patchedIngameStageId = stageId;
                    return;
                }

                var availableGemTypes:Array = GV.ingameCore.availableGemTypes;
                var cnt:*                   = GV.ingameCore.cnt;
                if (availableGemTypes == null || cnt == null) return;

                var added:int = 0;
                for each (var entry:Array in SKILL_GEM_MAP) {
                    var skillId:int  = int(entry[0]);
                    var gemType:int  = int(entry[1]);
                    var spellIdx:int = int(entry[2]);
                    if (Boolean(GV.ppd.gainedSkillTomes[skillId]) &&
                            availableGemTypes.indexOf(gemType) == -1) {
                        availableGemTypes.push(gemType);
                        cnt.mcIngameFrame.addChild(cnt.mcIngameFrame.gemCreateButtons[gemType]);
                        GV.ingameCore.arrIsSpellBtnVisible[spellIdx] = true;
                        added++;
                    }
                }

                _patchedIngameStageId = stageId;
                if (added > 0) {
                    _logger.log(_modName, "FirstPlayBypass: injected " + added +
                        " skill gem(s) for first-play stage id=" + stageId);
                }
            } catch (err:Error) {
                _logger.log(_modName,
                    "FirstPlayBypass.onIngameFrame ERROR: " + err.message);
            }
        }

        public function resetIngame():void {
            _patchedIngameStageId = -1;
        }

        // -----------------------------------------------------------------------
        // Tooltip helpers

        private function _showTooltip(btnId:String, title:String):void {
            if (_tooltipFor == btnId) return; // already showing for this button
            _tooltipFor = btnId;
            GV.mcInfoPanel.reset(410);
            GV.mcInfoPanel.addTextfield(COLOR_TITLE, title, false, 13,
                [new GlowFilter(0x979360, 1, 25, 5, 1, 1)]);
            GV.mcInfoPanel.addExtraHeight(5);
            GV.mcInfoPanel.addSeparator(-2);
            GV.mcInfoPanel.addTextfield(COLOR_WARN,
                "Beat this stage in Journey mode to unlock", false, 12, null, 0xFFFFFF);
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

        // -----------------------------------------------------------------------
        // Button click blocker (capture phase)

        private function _onLockedBtnBlock(pE:MouseEvent):void {
            if (!_isFirstPlay()) return;
            pE.stopImmediatePropagation();
        }

        // -----------------------------------------------------------------------
        // Helpers

        private function _isFirstPlay():Boolean {
            if (GV.ppd == null || GV.ingameCore == null ||
                    GV.ingameCore.stageMeta == null) return false;
            return GV.ppd.stageHighestXpsJourney[int(GV.ingameCore.stageMeta.id)].g() < 1;
        }

        // -----------------------------------------------------------------------
        // Stage-token capture click interceptor

        private function _onFieldTokenClick(pE:MouseEvent):void {
            try {
                if (GV.ppd == null || GV.selectorCore == null) return;
                if (GV.ppd.gameMode == GAME_MODE_IRON) return;
                if (int(GV.selectorCore.screenStatus) != STAGES_IDLE) return;

                var cntFT:*      = GV.selectorCore.mc.cntFieldTokens;
                var fieldToken:* = pE.target;
                while (fieldToken != null && fieldToken.parent !== cntFT) {
                    fieldToken = fieldToken.parent;
                }
                if (fieldToken == null) return;

                var stageId:int = int(fieldToken.id);
                if (GV.ppd.stageHighestXpsJourney[stageId].g() >= 1) return;

                GV.ingameCore.stageData  = GV.stageCollection.stageDatasJ[stageId];
                GV.ingameCore.stageMeta  = GV.stageCollection.stageMetas[stageId];
                GV.ingameCore.battleMode = BATTLE_MODE_JOURNEY;

                var ss:* = GV.selectorCore.mc.mcStageSettings;
                ss.tfFieldId.text   = GV.ingameCore.stageMeta.strId;
                ss.btnTrial.visible = (GV.stageCollection.stageDatasT[stageId] != null);

                GV.selectorCore.renderer.renderTraitsPanelForMode();
                GV.selectorCore.screenStatus = STAGES_TO_SETTINGS;
                pE.stopImmediatePropagation();

                _logger.log(_modName,
                    "FirstPlayBypass: settings screen forced for stage id=" + stageId);
            } catch (err:Error) {
                _logger.log(_modName,
                    "FirstPlayBypass._onFieldTokenClick ERROR: " + err.message);
            }
        }
    }
}
