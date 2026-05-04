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
     * Custom drop icon for coarse-granularity field-token items — per_tile,
     * per_tier, and their progressive siblings. Reads as "field tokens for a
     * group of stages" rather than a specific map tile, which is why we use
     * a generic pouch artwork instead of the actual MapTile bitmap.
     *
     * AP id ranges this icon serves:
     *   1562-1587  per-tile field tokens          (one per playOrder prefix)
     *   1588-1600  per-tier field tokens          (one per tier 0..12)
     *   1617       per-tile field token progressive  (single id, 26 copies)
     *   1618       per-tier field token progressive  (single id, 13 copies)
     *
     * Asset: ../../resources/TilePouch.png
     *
     * Mimics McDropIconOutcome's public shape (type / data / cntInner /
     * bmpIcon / bmpdIcon) so the OfflineItemsPanel factory can extract
     * bmpdIcon the same way it does for every other drop icon.
     *
     * .type = DropType.FIELD_TOKEN so the vanilla reveal animation plays
     * the same chime as regular per-stage field tokens (sndoctoken).
     */
    public class TilePouchDropIcon extends Sprite {

        public var cntInner:Sprite;
        public var bmpIcon:Bitmap;
        public var bmpdIcon:BitmapData;
        public var type:int;
        public var data:Object;
        public var meta:Object;  // { apId:int, isProgressive:Boolean }

        [Embed(source='../../resources/TilePouch.png')]
        private static const TilePouchAsset:Class;

        public function TilePouchDropIcon(apId:int) {
            super();

            this.type = DropType.FIELD_TOKEN;
            this.data = { apId: apId };
            this.meta = {
                apId: apId,
                isProgressive: _isPerTileProgressive(apId)
            };

            this.cntInner = new Sprite();
            addChild(this.cntInner);

            this.bmpdIcon = new BitmapData(140, 140, true, 0);
            this.bmpIcon  = new Bitmap(this.bmpdIcon);

            var src:Bitmap = new TilePouchAsset() as Bitmap;
            if (src != null && src.bitmapData != null) {
                var srcW:int   = src.bitmapData.width;
                var srcH:int   = src.bitmapData.height;
                var maxDim:int = 120;
                var scale:Number = Math.min(maxDim / srcW, maxDim / srcH);

                var m:Matrix = new Matrix();
                m.scale(scale, scale);
                m.translate((140 - srcW * scale) / 2, (140 - srcH * scale) / 2);

                this.bmpdIcon.draw(src.bitmapData, m, null, null, null, true);

                var dsf:DropShadowFilter = new DropShadowFilter(0, 45, 0, 1, 14, 14, 2, 3);
                this.bmpdIcon.applyFilter(this.bmpdIcon, new Rectangle(0, 0, 140, 140),
                                          new Point(0, 0), dsf);
            }

            this.cntInner.addChild(this.bmpIcon);

            addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver, false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT,  _onMouseOut,  false, 0, true);
        }

        // -----------------------------------------------------------------------
        // Tooltip — only the per-tile progressive variant renders one for now;
        // the per-tile / per-tier distinct variants and per-tier progressive
        // fall through silently.

        private function _onMouseOver(e:MouseEvent):void {
            try {
                if (this.meta == null || this.meta.isProgressive != true)
                    return;

                var vIp:* = GV.mcInfoPanel;
                vIp.reset(280);

                var apId:int = int(this.meta.apId);
                var copies:int = AV.sessionData.getItemCount(apId);
                var prefix:String = _progressiveTilePrefix(copies);

                var title:String = "Progressive Field Token";
                var subtitle:String = "Field Token";
                var body:String = "Unlocks fields on tile " + prefix + ". "
                                + "(" + copies + "/" + _orderLength() + " worlds unlocked)";

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

        private static function _isPerTileProgressive(apId:int):Boolean {
            try {
                var opts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
                if (opts != null) {
                    var progId:int = int(opts.fieldTokenPerTileProgressiveId);
                    if (progId > 0 && apId == progId)
                        return true;
                }
            } catch (e:Error) {}
            return false;
        }

        private static function _orderLength():int {
            try {
                var opts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
                if (opts != null) {
                    var order:Array = opts.progressiveTileOrder as Array;
                    if (order != null) return order.length;
                }
            } catch (e:Error) {}
            return 26;
        }

        private static function _progressiveTilePrefix(copies:int):String {
            try {
                var opts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
                if (opts != null) {
                    var order:Array = opts.progressiveTileOrder as Array;
                    if (order != null && copies >= 1 && copies <= order.length) {
                        return String(order[copies - 1]);
                    }
                }
            } catch (e:Error) {}
            return "?";
        }
    }
}
