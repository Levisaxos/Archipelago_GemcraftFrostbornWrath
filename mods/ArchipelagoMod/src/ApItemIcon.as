package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.filters.DropShadowFilter;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    /**
     * A custom drop icon Sprite for Archipelago items shown on the ending screen.
     *
     * Displays the mod's IconColorSmall.png image scaled to fit inside the
     * standard 140×140 icon area.  The tooltipText property is read by the
     * MOUSE_OVER handler in LevelEndScreenBuilder to populate McInfoPanel.
     *
     * The type property (set to 999) allows this icon to coexist in ending.dropIcons
     * with McDropIconOutcome objects; the game's animation loop will read .type
     * and silently skip it (no matching DropType, no sound), then reveal the icon.
     */
    public class ApItemIcon extends Sprite {

        [Embed(source="images/IconColorSmall.png")]
        private static const IconAsset:Class;

        /** Type constant; doesn't match any DropType so animation plays no sound. */
        public var type:int = 999;

        /** Tooltip text shown on MOUSE_OVER. */
        public var tooltipText:String;

        /** AP location ID (2000-2636 for achievements); used to look up sent-item data on hover. */
        public var locationId:int = 0;

        /** Properties required by IngameEnding.removeAllDropIcons() for cleanup. */
        public var data:Object;
        public var cntInner:Sprite;
        public var bmpIcon:Bitmap;
        public var bmpdIcon:BitmapData;

        public function ApItemIcon(tooltip:String) {
            super();
            this.tooltipText = tooltip;
            this.data = {};

            // Create the inner container and icon bitmap (matching McDropIconOutcome structure)
            this.cntInner = new Sprite();
            addChild(this.cntInner);

            this.bmpdIcon = new BitmapData(140, 140, true, 0);

            // Scale the embedded image to fit within 100×100, centred in 140×140
            var src:Bitmap = new IconAsset() as Bitmap;
            var srcBmpd:BitmapData = src.bitmapData;
            var scale:Number = Math.min(100.0 / srcBmpd.width, 100.0 / srcBmpd.height);
            var m:Matrix = new Matrix();
            m.scale(scale, scale);
            m.translate(
                (140 - srcBmpd.width * scale) * 0.5,
                (140 - srcBmpd.height * scale) * 0.5
            );
            this.bmpdIcon.draw(srcBmpd, m, null, null, null, true);

            var dsf:DropShadowFilter = new DropShadowFilter(0, 45, 0, 1, 14, 14, 2, 3);
            this.bmpdIcon.applyFilter(this.bmpdIcon, new Rectangle(0, 0, 140, 140), new Point(0, 0), dsf);

            this.bmpIcon = new Bitmap(this.bmpdIcon);
            this.cntInner.addChild(this.bmpIcon);
        }
    }
}
