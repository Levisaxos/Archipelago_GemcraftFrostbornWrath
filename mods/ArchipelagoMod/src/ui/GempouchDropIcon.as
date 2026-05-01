package ui {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.filters.DropShadowFilter;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.DropType;

    import data.AV;

    /**
     * Custom drop icon for AP "Gempouch" items (apIds 626-652).
     *
     * Distinct mode: ap id = 626 + index in gemPouchPlayOrder; the icon
     * displays "Gempouch (X)" where X is the prefix letter.
     * Progressive mode: ap id = 652 (gemPouchProgressiveId); the icon
     * displays "Progressive Gempouch" with a copy-count subtitle pulled
     * live from SessionData at render time.
     *
     * Mirrors XpTomeDropIcon's public shape so it lives in ending.dropIcons
     * without breaking the vanilla animation loop or cleanup. Uses our own
     * MOUSE_OVER/MOUSE_OUT — vanilla renderDropIconInfoPanel doesn't know
     * our type.
     */
    public class GempouchDropIcon extends Sprite {

        public var cntInner:Sprite;
        public var bmpIcon:Bitmap;
        public var bmpdIcon:BitmapData;
        public var type:int;
        public var meta:Object;  // { apId:int, prefix:String, isProgressive:Boolean }

        // Single shared artwork for all pouch variants. Path is relative to
        // this .as file: src/ui/ → ../../resources/
        [Embed(source='../../resources/GemPouch.png')]
        private static const PouchAsset:Class;

        public function GempouchDropIcon(apId:int) {
            super();

            var isProgressive:Boolean = _isProgressiveId(apId);
            var prefix:String = isProgressive ? "" : _prefixForApId(apId);

            this.type = DropType.SKILL_TOME; // reuse the tome reveal SFX
            this.meta = {
                apId: apId,
                prefix: prefix,
                isProgressive: isProgressive
            };

            this.cntInner = new Sprite();
            addChild(this.cntInner);

            this.bmpdIcon = new BitmapData(140, 140, true, 0);
            this.bmpIcon  = new Bitmap(this.bmpdIcon);

            var src:Bitmap = new PouchAsset() as Bitmap;
            if (src != null && src.bitmapData != null) {
                var srcW:int = src.bitmapData.width;
                var srcH:int = src.bitmapData.height;
                var maxDim:int = 120; // padding inside 140x140
                var scale:Number = Math.min(maxDim / srcW, maxDim / srcH);

                var m:Matrix = new Matrix();
                m.scale(scale, scale);
                m.translate((140 - srcW * scale) / 2, (140 - srcH * scale) / 2);

                this.bmpdIcon.draw(src.bitmapData, m, null, null, null, true);

                var dsf:DropShadowFilter = new DropShadowFilter(0, 45, 0, 1, 14, 14, 2, 3);
                this.bmpdIcon.applyFilter(this.bmpdIcon, new Rectangle(0, 0, 140, 140), new Point(0, 0), dsf);
            }

            this.cntInner.addChild(this.bmpIcon);

            addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver, false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT,  _onMouseOut,  false, 0, true);
        }

        // -----------------------------------------------------------------------

        private static function _isProgressiveId(apId:int):Boolean {
            try {
                var opts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
                if (opts != null) {
                    var progId:int = int(opts.gemPouchProgressiveId);
                    if (progId > 0 && apId == progId) return true;
                }
            } catch (e:Error) {}
            // Fallback to the apworld-allocated default.
            return apId == 652;
        }

        private static function _prefixForApId(apId:int):String {
            try {
                var opts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
                if (opts != null) {
                    var order:Array = opts.gemPouchPlayOrder as Array;
                    var idx:int = apId - 626;
                    if (order != null && idx >= 0 && idx < order.length) {
                        return String(order[idx]);
                    }
                }
            } catch (e:Error) {}
            return "?";
        }

        // -----------------------------------------------------------------------
        // Tooltip

        private function _onMouseOver(e:MouseEvent):void {
            try {
                var vIp:* = GV.mcInfoPanel;
                vIp.reset(280);

                var title:String;
                var subtitle:String = "Gem Pouch";
                var body:String;
                if (this.meta.isProgressive == true) {
                    title = "Progressive Gempouch";
                    var copies:int = AV.sessionData.getItemCount(int(this.meta.apId));
                    var unlocked:int = copies; // includes precollected copy
                    var total:int = _orderLength();
                    body = "Unlocks gems on the next world. "
                         + "(" + unlocked + "/" + total + " worlds unlocked)";
                } else {
                    title = "Gempouch (" + String(this.meta.prefix) + ")";
                    body = "Unlocks gems on stages of world " + String(this.meta.prefix) + ".";
                }

                vIp.addTextfield(0xFFD700, title, false, 13);
                vIp.addTextfield(0xCCCCCC, subtitle, false, 11);
                vIp.addTextfield(0x99FF99, body, false, 11);
                GV.main.cntInfoPanel.addChild(vIp);
                vIp.doEnterFrame();
            } catch (err:Error) {}
        }

        private function _onMouseOut(e:MouseEvent):void {
            try { GV.main.cntInfoPanel.removeChild(GV.mcInfoPanel); } catch (err:Error) {}
        }

        private static function _orderLength():int {
            try {
                var opts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
                if (opts != null) {
                    var order:Array = opts.gemPouchPlayOrder as Array;
                    if (order != null) return order.length;
                }
            } catch (e:Error) {}
            return 26;
        }
    }
}
