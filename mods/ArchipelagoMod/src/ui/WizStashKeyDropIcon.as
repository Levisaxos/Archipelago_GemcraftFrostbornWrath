package ui {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.filters.DropShadowFilter;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import com.giab.games.gcfw.constants.DropType;

    /**
     * Custom drop icon for individual Wizard Stash keys (apId 1400-1521 — one
     * per stage). The bundled-key sibling for tile / tier / master pouches
     * (1522-1561) is KeyPouchDropIcon.
     *
     * Vanilla has no DropType for stash keys, so we synthesize an icon using
     * an embedded PNG (WizStashKey.png in mods/ArchipelagoMod/resources/).
     *
     * Mimics McDropIconOutcome's public shape (type / data / cntInner / bmpIcon
     * / bmpdIcon) so the icon slots into the same code paths the level-end
     * dropicon system uses, and so OfflineItemsPanel's factory can extract
     * bmpdIcon the same way it does for every other drop icon.
     *
     * .type is set to DropType.FIELD_TOKEN so the vanilla reveal animation
     * picks the "sndoctoken" sound (no dedicated stash-key SFX exists).
     */
    public class WizStashKeyDropIcon extends Sprite {

        public var cntInner:Sprite;
        public var bmpIcon:Bitmap;
        public var bmpdIcon:BitmapData;
        public var type:int;
        public var data:Object;

        [Embed(source='../../resources/WizStashKey.png')]
        private static const WizStashKeyAsset:Class;

        public function WizStashKeyDropIcon(apId:int) {
            super();

            this.type = DropType.FIELD_TOKEN; // for the vanilla reveal sound
            this.data = { apId: apId };

            this.cntInner = new Sprite();
            addChild(this.cntInner);

            this.bmpdIcon = new BitmapData(140, 140, true, 0);
            this.bmpIcon  = new Bitmap(this.bmpdIcon);

            var src:Bitmap = new WizStashKeyAsset() as Bitmap;
            if (src != null && src.bitmapData != null) {
                var srcW:int   = src.bitmapData.width;
                var srcH:int   = src.bitmapData.height;
                var maxDim:int = 120; // leave a little padding inside 140x140
                var scale:Number = Math.min(maxDim / srcW, maxDim / srcH);

                var m:Matrix = new Matrix();
                m.scale(scale, scale);
                m.translate((140 - srcW * scale) / 2, (140 - srcH * scale) / 2);

                this.bmpdIcon.draw(src.bitmapData, m, null, null, null, true);

                // Same drop shadow vanilla applies to its drop icons.
                var dsf:DropShadowFilter = new DropShadowFilter(0, 45, 0, 1, 14, 14, 2, 3);
                this.bmpdIcon.applyFilter(this.bmpdIcon, new Rectangle(0, 0, 140, 140),
                                          new Point(0, 0), dsf);
            }

            this.cntInner.addChild(this.bmpIcon);
        }
    }
}
