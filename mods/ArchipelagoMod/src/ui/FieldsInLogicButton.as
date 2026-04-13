package ui {

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Matrix;
    import flash.text.TextField;

    import com.giab.games.gcfw.GV;

    /**
     * Main-menu button showing "Fields in logic: N" — the number of stages
     * that currently have at least one AP check reachable.
     *
     * Call update(count, strIds) every selector frame to keep the label current.
     * Call onFrame() every selector frame to drive the hover info panel and map pan.
     *
     * Clicking cycles through in-logic fields and smoothly pans the map to each.
     */
    public class FieldsInLogicButton extends Sprite {

        private static const COLOR_TITLE:uint = 0xf3f09c;
        private static const COLOR_ITEM:uint  = 0xFFFFCC;
        private static const COLOR_NONE:uint  = 0xaaaaaa;

        // Easing factor: matches game's TOKEN_APPEARING pan (1/7 per frame).
        private static const PAN_EASE:Number = 1.0 / 7.0;
        // Stop animating when this close to target (in map units).
        private static const PAN_SNAP:Number = 0.5;

        private var _template:*;
        private var _currentCount:int = -1;
        private var _inLogicStrIds:Array = [];
        private var _inLogicAchievements:Array = [];
        private var _panelShown:Boolean = false;

        private var _cycleIndex:int = 0;
        private var _panTargetX:Number = 0;
        private var _panTargetY:Number = 0;
        private var _isPanning:Boolean = false;

        public function FieldsInLogicButton(btnTemplate:*) {
            super();
            _template = btnTemplate;
            _build(0);
            buttonMode    = true;
            useHandCursor = true;
            addEventListener(MouseEvent.MOUSE_OVER, onOver,  false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT,  onOut,   false, 0, true);
            addEventListener(MouseEvent.CLICK,      onClick, false, 0, true);
        }

        /**
         * Called every selector frame by ArchipelagoMod.
         * Rebuilds the bitmap label only when total count changes.
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
            if (totalCount == _currentCount) return;
            _currentCount = totalCount;
            while (numChildren > 0) removeChildAt(0);
            _build(totalCount);
        }

        /**
         * Called every selector frame to:
         *   - drive the hover info panel, and
         *   - advance the smooth map pan toward the target field.
         */
        public function onFrame():void {
            // --- hover panel ---
            if (stage == null || !visible) {
                _hidePanel();
            } else {
                var mx:Number = stage.mouseX;
                var my:Number = stage.mouseY;
                if (hitTestPoint(mx, my, true)) {
                    if (!_panelShown) {
                        _showPanel();
                    } else {
                        GV.mcInfoPanel.doEnterFrame();
                    }
                } else {
                    _hidePanel();
                }
            }

            // --- smooth pan ---
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

        private function onClick(e:MouseEvent):void {
            if (_inLogicStrIds == null || _inLogicStrIds.length == 0) return;
            if (GV.selectorCore == null || GV.stageCollection == null) return;

            // Clamp in case list shrank since last click.
            if (_cycleIndex >= _inLogicStrIds.length) _cycleIndex = 0;

            var strId:String = String(_inLogicStrIds[_cycleIndex]);
            _cycleIndex = (_cycleIndex + 1) % _inLogicStrIds.length;

            // Look up map position from stage metadata.
            var stageId:int = GV.getFieldId(strId);
            if (stageId < 0) return;
            var metas:Array = GV.stageCollection.stageMetas;
            if (stageId >= metas.length) return;
            var meta:* = metas[stageId];
            if (meta == null) return;

            // Clamp target to the scroll bounds enforced by the mod.
            var sc:* = GV.selectorCore;
            _panTargetX = Math.max(sc.vpXMin, Math.min(sc.vpXMax, Number(meta.mapX)));
            _panTargetY = Math.max(sc.vpYMin, Math.min(sc.vpYMax, Number(meta.mapY)));
            _isPanning  = true;
        }

        private function _build(count:int):void {
            if (_template == null || _template.parent == null) return;

            var bw:Number = _template.width;
            var bh:Number = _template.height;

            // Safety check: only proceed if dimensions are valid
            if (bw <= 0 || bh <= 0) return;

            var nativeLabel:TextField = _findTextField(_template);
            var originalText:String   = null;
            if (nativeLabel != null) {
                originalText     = nativeLabel.text;
                nativeLabel.text = "in logic: " + count;
            }

            var bd:BitmapData = new BitmapData(Math.ceil(bw), Math.ceil(bh), true, 0x00000000);
            var m:Matrix = new Matrix();
            m.tx = -_template.x;
            m.ty = -_template.y;
            bd.draw(_template.parent, m);
            addChild(new Bitmap(bd));

            if (nativeLabel != null) nativeLabel.text = originalText;
        }

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

        /**
         * Reset button state when transitioning screens.
         * Fixes bug where hover panel persists across screen changes.
         * Called by ArchipelagoMod when screen transitions.
         */
        public function resetOnScreenChange():void {
            _panelShown = false;
            _hidePanel();
            _cycleIndex = 0;
        }

        private function onOver(e:MouseEvent):void {
            filters = [_makeBrightnessFilter(1.35)];
        }

        private function onOut(e:MouseEvent):void {
            filters = [];
        }

        private function _findTextField(obj:DisplayObject):TextField {
            if (obj is TextField) return obj as TextField;
            if (obj is DisplayObjectContainer) {
                var doc:DisplayObjectContainer = obj as DisplayObjectContainer;
                for (var i:int = 0; i < doc.numChildren; i++) {
                    var result:TextField = _findTextField(doc.getChildAt(i));
                    if (result != null) return result;
                }
            }
            return null;
        }

        private function _makeBrightnessFilter(scale:Number):ColorMatrixFilter {
            return new ColorMatrixFilter([
                scale, 0,     0,     0, 0,
                0,     scale, 0,     0, 0,
                0,     0,     scale, 0, 0,
                0,     0,     0,     1, 0
            ]);
        }
    }
}
