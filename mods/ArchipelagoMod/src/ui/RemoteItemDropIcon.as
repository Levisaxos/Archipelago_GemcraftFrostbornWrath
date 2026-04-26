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

    /**
     * Custom drop icon for AP items belonging to OTHER games — i.e. items this
     * player sent out whose AP id falls outside any of our handled ranges
     * (fields, skills, traits, talismans, shadow cores, XP tomes, achievements).
     *
     * Shows the standard Archipelago icon (IconColorSmall.png) and a tooltip
     * "Sent <itemName> to <recipientName>".
     *
     * Mimics McDropIconOutcome's public shape (type / data / cntInner / bmpIcon /
     * bmpdIcon) so it slots into ending.dropIcons without breaking the vanilla
     * animation loop or removeAllDropIcons cleanup.
     *
     * .type = DropType.SKILL_TOME purely so the vanilla reveal animation plays
     * a sound (sndoutcomeskilltome) — there's no DropType for "remote AP item",
     * and silent reveal felt off. We register our own MOUSE_OVER tooltip handler
     * because vanilla's renderDropIconInfoPanel would treat .data as a skill id.
     */
    public class RemoteItemDropIcon extends Sprite {

        public var cntInner:Sprite;
        public var bmpIcon:Bitmap;
        public var bmpdIcon:BitmapData;
        public var type:int;
        public var data:Object;  // { itemName:String, recipientName:String }

        [Embed(source='../images/IconColorSmall.png')]
        private static const IconAsset:Class;

        public function RemoteItemDropIcon(itemName:String, recipientName:String) {
            super();

            this.type = DropType.SKILL_TOME; // for the vanilla reveal sound
            this.data = { itemName: itemName, recipientName: recipientName };

            this.cntInner = new Sprite();
            addChild(this.cntInner);

            this.bmpdIcon = new BitmapData(140, 140, true, 0);
            this.bmpIcon  = new Bitmap(this.bmpdIcon);

            var src:Bitmap = new IconAsset() as Bitmap;
            if (src != null && src.bitmapData != null) {
                var srcW:int = src.bitmapData.width;
                var srcH:int = src.bitmapData.height;
                var maxDim:int = 110; // a bit more padding than the tomes — AP icon is round
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

        private function _onMouseOver(e:MouseEvent):void {
            try {
                var vIp:* = GV.mcInfoPanel;
                vIp.reset(320);
                vIp.addTextfield(0xCC99FF, "Sent " + String(this.data.itemName), false, 13);
                vIp.addTextfield(0xFFFFFF, "to " + String(this.data.recipientName), false, 12);
                GV.main.cntInfoPanel.addChild(vIp);
                vIp.doEnterFrame();
            } catch (err:Error) {
                // Fail silent — tooltip is non-critical.
            }
        }

        private function _onMouseOut(e:MouseEvent):void {
            try { GV.main.cntInfoPanel.removeChild(GV.mcInfoPanel); } catch (err:Error) {}
        }
    }
}
