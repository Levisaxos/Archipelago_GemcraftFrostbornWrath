package ui {
    import flash.events.MouseEvent;

    import com.giab.games.gcfw.GV;
    import data.AV;

    /**
     * Selector-screen button showing "Fields in logic: N" — the number of
     * stages that currently have at least one AP check reachable.
     *
     * Extends CustomButton. Extra behaviour:
     *   - Call update(count, strIds) every selector frame to keep the label
     *     current (rebuilds the bitmap only when the count changes).
     *   - Call onFrame() every selector frame to drive the hover info panel
     *     and advance the smooth map pan toward the last clicked field.
     *   - Clicking cycles through in-logic fields and smoothly pans the map.
     */
    public class FieldsInLogicButton extends CustomButton {

        private static const COLOR_TITLE:uint = 0xf3f09c;
        private static const COLOR_ITEM:uint  = 0xFFFFCC;
        private static const COLOR_NONE:uint  = 0xaaaaaa;

        // Easing factor: matches game's TOKEN_APPEARING pan (1/7 per frame).
        private static const PAN_EASE:Number = 1.0 / 7.0;
        // Stop animating when this close to the target (map units).
        private static const PAN_SNAP:Number = 0.5;

        private var _currentFieldCount:int     = -1;
        private var _currentAchCount:int       = -1;
        private var _inLogicStrIds:Array       = [];
        private var _inLogicAchievements:Array = [];
        private var _panelShown:Boolean        = false;

        private var _cycleIndex:int    = 0;
        private var _panTargetX:Number = 0;
        private var _panTargetY:Number = 0;
        private var _isPanning:Boolean = false;

        // Tracks the most recent power so we only re-render the label when it
        // changes by more than a small delta (avoids per-frame string churn).
        private var _currentPower:int = -1;

        public function FieldsInLogicButton(btnTemplate:*) {
            super(btnTemplate, "In Logic F:0 A:0 P:0");
            onClick = _cycleAndPan;
        }

        // -----------------------------------------------------------------------
        // Public API called by ModButtons every selector frame

        /**
         * Rebuild the label only when counts change.
         * Clamps the cycle index if the field list shrank.
         *
         * @param strIds       Field string IDs currently in logic
         * @param achievements Achievement names currently in logic (sorted)
         */
        public function update(strIds:Array, achievements:Array):void {
            _inLogicStrIds       = strIds       || [];
            _inLogicAchievements = achievements || [];
            if (_cycleIndex >= _inLogicStrIds.length) _cycleIndex = 0;
            var fc:int = _inLogicStrIds.length;
            var ac:int = _inLogicAchievements.length;
            var pw:int = int(Math.round(Number(AV.sessionData.playerPower)));
            if (fc == _currentFieldCount && ac == _currentAchCount && pw == _currentPower)
                return;
            _currentFieldCount = fc;
            _currentAchCount   = ac;
            _currentPower      = pw;
            _rebuild("In Logic F:" + fc + " A:" + ac + " P:" + pw);
        }

        /**
         * Drive the hover info panel and advance the smooth map pan.
         * Must be called every selector frame.
         */
        public function onFrame():void {
            // Hover panel is driven by hit-test, not by mouse events, so that
            // it tracks the cursor position in global stage coordinates.
            if (stage == null || !visible) {
                _hidePanel();
            } else {
                if (hitTestPoint(stage.mouseX, stage.mouseY, true)) {
                    if (!_panelShown) _showPanel();
                    else              GV.mcInfoPanel.doEnterFrame();
                } else {
                    _hidePanel();
                }
            }

            // Smooth map pan toward the target field.
            if (!_isPanning || GV.selectorCore == null) return;
            var sc:* = GV.selectorCore;
            var dx:Number = _panTargetX - sc.vpX;
            var dy:Number = _panTargetY - sc.vpY;
            if (Math.abs(dx) < PAN_SNAP && Math.abs(dy) < PAN_SNAP) {
                sc.vpX = _panTargetX;
                sc.vpY = _panTargetY;
                _isPanning = false;
            } else {
                sc.vpX += dx * PAN_EASE;
                sc.vpY += dy * PAN_EASE;
            }
        }

        // -----------------------------------------------------------------------
        // Click handler (wired via onClick in constructor)

        private function _cycleAndPan():void {
            if (_inLogicStrIds == null || _inLogicStrIds.length == 0) return;
            if (GV.selectorCore == null || GV.stageCollection == null) return;

            // Clamp in case list shrank since last click.
            if (_cycleIndex >= _inLogicStrIds.length) _cycleIndex = 0;

            var strId:String = String(_inLogicStrIds[_cycleIndex]);
            _cycleIndex = (_cycleIndex + 1) % _inLogicStrIds.length;

            var stageId:int = GV.getFieldId(strId);
            if (stageId < 0) return;
            var metas:Array = GV.stageCollection.stageMetas;
            if (stageId >= metas.length) return;
            var meta:* = metas[stageId];
            if (meta == null) return;

            var sc:* = GV.selectorCore;
            _panTargetX = Math.max(sc.vpXMin, Math.min(sc.vpXMax, Number(meta.mapX)));
            _panTargetY = Math.max(sc.vpYMin, Math.min(sc.vpYMax, Number(meta.mapY)));
            _isPanning  = true;
        }

        // -----------------------------------------------------------------------
        // Hover info panel

        private function _showPanel():void {
            _panelShown = true;
            GV.mcInfoPanel.reset(400);
            GV.mcInfoPanel.addTextfield(COLOR_TITLE, "In Logic", false, 13);
            GV.mcInfoPanel.addExtraHeight(5);
            GV.mcInfoPanel.addSeparator(-2);

            // Player power section — current score, drives all power gates.
            var pwr:int = int(Math.round(Number(AV.sessionData.playerPower)));
            GV.mcInfoPanel.addTextfield(COLOR_TITLE, "Power: " + pwr, false, 12);
            GV.mcInfoPanel.addExtraHeight(2);
            GV.mcInfoPanel.addTextfield(COLOR_NONE,
                "Talismans, skills and skillpoints add the most power.", false, 10);
            GV.mcInfoPanel.addExtraHeight(8);

            // Fields section
            GV.mcInfoPanel.addTextfield(COLOR_TITLE, "Fields", false, 12);
            GV.mcInfoPanel.addExtraHeight(2);
            if (_inLogicStrIds == null || _inLogicStrIds.length == 0) {
                GV.mcInfoPanel.addTextfield(COLOR_NONE,
                    "No fields currently in logic", false, 11);
            } else {
                var maxFields:int  = 5;
                var shownF:int     = Math.min(_inLogicStrIds.length, maxFields);
                for (var i:int = 0; i < shownF; i++) {
                    GV.mcInfoPanel.addTextfield(COLOR_ITEM,
                        String(_inLogicStrIds[i]), true, 11);
                }
                if (_inLogicStrIds.length > maxFields) {
                    GV.mcInfoPanel.addTextfield(COLOR_NONE,
                        "... and " + (_inLogicStrIds.length - maxFields) + " more", false, 11);
                }
            }

            // Achievements section
            GV.mcInfoPanel.addExtraHeight(8);
            GV.mcInfoPanel.addTextfield(COLOR_TITLE, "Achievements", false, 12);
            GV.mcInfoPanel.addExtraHeight(2);
            if (_inLogicAchievements == null || _inLogicAchievements.length == 0) {
                GV.mcInfoPanel.addTextfield(COLOR_NONE,
                    "No achievements currently in logic", false, 11);
            } else {
                var maxAchs:int = 5;
                var shownA:int  = Math.min(_inLogicAchievements.length, maxAchs);
                for (var j:int = 0; j < shownA; j++) {
                    GV.mcInfoPanel.addTextfield(COLOR_ITEM,
                        String(_inLogicAchievements[j]), true, 11);
                }
                if (_inLogicAchievements.length > maxAchs) {
                    GV.mcInfoPanel.addTextfield(COLOR_NONE,
                        "... and " + (_inLogicAchievements.length - maxAchs) + " more", false, 11);
                }
            }

            GV.main.cntInfoPanel.addChild(GV.mcInfoPanel);
            GV.mcInfoPanel.doEnterFrame();
        }

        private function _hidePanel():void {
            if (!_panelShown) return;
            _panelShown = false;
            try {
                if (GV.main != null
                        && GV.main.cntInfoPanel != null
                        && GV.main.cntInfoPanel.contains(GV.mcInfoPanel)) {
                    GV.main.cntInfoPanel.removeChild(GV.mcInfoPanel);
                }
            } catch (err:Error) {}
        }
    }
}
