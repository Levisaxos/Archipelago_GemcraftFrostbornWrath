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
     * The icon reflects the sent item's Archipelago classification, so the
     * player can see at a glance whether the check they sent out was
     * progression (arrow), useful (colour) or filler (grey). The tooltip reads
     * "Sent <itemName> to <recipientName>" plus the classification label.
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
        public var data:Object;  // { itemName:String, recipientName:String, flags:int }

        // Progression — colour logo with an up-arrow.
        [Embed(source='../images/IconColorArrowSmall.png')]
        private static const IconProgression:Class;
        // Useful — plain colour logo.
        [Embed(source='../images/IconColorSmall.png')]
        private static const IconUseful:Class;
        // Filler (and traps) — greyed logo.
        [Embed(source='../images/IconGreySmall.png')]
        private static const IconFiller:Class;

        public function RemoteItemDropIcon(itemName:String, recipientName:String, flags:int) {
            super();

            this.type = DropType.SKILL_TOME; // for the vanilla reveal sound
            this.data = { itemName: itemName, recipientName: recipientName, flags: flags };

            this.cntInner = new Sprite();
            addChild(this.cntInner);

            this.bmpdIcon = new BitmapData(140, 140, true, 0);
            this.bmpIcon  = new Bitmap(this.bmpdIcon);

            var src:Bitmap = new (_iconClassFor(flags))() as Bitmap;
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

        /** Pick the embed matching the item's Archipelago classification. */
        private static function _iconClassFor(flags:int):Class {
            switch (ItemColors.iconClassForFlags(flags)) {
                case ItemColors.CLASS_PROGRESSION:
                    return IconProgression;
                case ItemColors.CLASS_USEFUL:
                    return IconUseful;
                default:
                    return IconFiller;
            }
        }

        /** Human-readable classification label for the tooltip. */
        private static function _classLabel(flags:int):String {
            switch (ItemColors.iconClassForFlags(flags)) {
                case ItemColors.CLASS_PROGRESSION:
                    return "Progression";
                case ItemColors.CLASS_USEFUL:
                    return "Useful";
                default:
                    return "Filler";
            }
        }

        private function _onMouseOver(e:MouseEvent):void {
            try {
                var flags:int = int(this.data.flags);
                var col:uint  = ItemColors.forFlags(flags);
                var vIp:* = GV.mcInfoPanel;
                vIp.reset(320);
                vIp.addTextfield(col, "Sent " + String(this.data.itemName), false, 13);
                vIp.addTextfield(0xFFFFFF, "to " + String(this.data.recipientName), false, 12);
                vIp.addTextfield(col, _classLabel(flags), false, 11);
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
