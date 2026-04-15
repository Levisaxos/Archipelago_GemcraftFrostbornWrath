package ui {
    import flash.events.MouseEvent;

    import com.giab.games.gcfw.GV;

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

        private var _currentCount:int  = -1;
        private var _inLogicStrIds:Array = [];
        private var _panelShown:Boolean  = false;

        private var _cycleIndex:int    = 0;
        private var _panTargetX:Number = 0;
        private var _panTargetY:Number = 0;
        private var _isPanning:Boolean = false;

        public function FieldsInLogicButton(btnTemplate:*) {
            super(btnTemplate, "Fields in logic: 0");
            onClick = _cycleAndPan;
        }

        // -----------------------------------------------------------------------
        // Public API called by ModButtons every selector frame

        /**
         * Rebuild the label only when count changes.
         * Clamps the cycle index if the list shrank.
         *
         * @param totalCount Total checks in logic (fields + achievements)
         * @param strIds Array of field string IDs that are in logic
         * @param achievements Array of achievement names that are in logic
         */
        public function update(totalCount:int, strIds:Array, achievements:Array = null):void {
            _inLogicStrIds = strIds;
            _inLogicAchievements = achievements || [];
            if (_cycleIndex >= _inLogicStrIds.length) _cycleIndex = 0;
            if (count == _currentCount) return;
            _currentCount = count;
            _rebuild("Fields in logic: " + count);
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
            GV.mcInfoPanel.addTextfield(COLOR_TITLE,
                "In Logic (" + _currentCount + " total)", false, 13);
            GV.mcInfoPanel.addExtraHeight(5);
            GV.mcInfoPanel.addSeparator(-2);

            // Fields in logic
            if (_inLogicStrIds == null || _inLogicStrIds.length == 0) {
                GV.mcInfoPanel.addTextfield(COLOR_NONE,
                    "No fields currently in logic", false, 11);
            } else {
                for (var i:int = 0; i < _inLogicStrIds.length; i++) {
                    GV.mcInfoPanel.addTextfield(COLOR_ITEM,
                        String(_inLogicStrIds[i]), true, 11);
                }
            }

            // Achievements in logic section
            if (_inLogicAchievements != null && _inLogicAchievements.length > 0) {
                GV.mcInfoPanel.addExtraHeight(8);
                GV.mcInfoPanel.addTextfield(COLOR_TITLE,
                    "Achievements in logic", false, 13);
                GV.mcInfoPanel.addExtraHeight(3);

                var maxShow:int = 5;
                var shown:int = Math.min(_inLogicAchievements.length, maxShow);
                for (var j:int = 0; j < shown; j++) {
                    GV.mcInfoPanel.addTextfield(COLOR_ITEM,
                        String(_inLogicAchievements[j]), true, 11);
                }

                if (_inLogicAchievements.length > maxShow) {
                    var moreCount:int = _inLogicAchievements.length - maxShow;
                    GV.mcInfoPanel.addTextfield(COLOR_ITEM,
                        "... and " + moreCount + " more", true, 11);
                }

                GV.mcInfoPanel.addExtraHeight(3);
                GV.mcInfoPanel.addTextfield(COLOR_NONE,
                    "See achievements for full info", false, 10);
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
