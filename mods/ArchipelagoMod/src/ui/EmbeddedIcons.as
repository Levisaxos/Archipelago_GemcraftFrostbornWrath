package ui {
    import flash.display.Bitmap;
    import flash.display.DisplayObject;
    import flash.display.Sprite;

    /**
     * Element/structure icons compiled from extracted game art (build-menu icons
     * + shadow layers). These are raw SWF bitmaps with no runtime AS3 class, so
     * they can't be resolved via getDefinitionByName - they're embedded here.
     *
     * Embedded straight from the extracted game images under
     * `do not commit/gcfw/images/` (git-ignored, present for any local build) so
     * there's no duplicate copy to maintain. The SWF carries them after build.
     */
    public class EmbeddedIcons {

        [Embed(source='../../../../do not commit/gcfw/images/3516.png')] private static const Trap:Class;
        [Embed(source='../../../../do not commit/gcfw/images/3518.jpg')] private static const Lantern:Class;
        [Embed(source='../../../../do not commit/gcfw/images/3520.jpg')] private static const Pylon:Class;
        [Embed(source='../../../../do not commit/gcfw/images/3514.png')] private static const Amp:Class;
        [Embed(source='../../../../do not commit/gcfw/images/660.png')]  private static const Barricade:Class;
        [Embed(source='../../../../do not commit/gcfw/images/1801.png')] private static const Nest:Class;
        [Embed(source='../../../../do not commit/gcfw/images/284.png')]  private static const Shadow0:Class;
        [Embed(source='../../../../do not commit/gcfw/images/286.png')]  private static const Shadow1:Class;

        private static const SINGLE:Object = {
            "Trap":         Trap,
            "Lantern":      Lantern,
            "Pylon":        Pylon,
            "Amplifier":    Amp,
            "Barricade":    Barricade,
            "Monster Nest": Nest
        };

        public static function has(name:String):Boolean {
            return name == "Shadow" || SINGLE[name] != null;
        }

        /** A fresh DisplayObject for `name`, or null if not embedded here. */
        public static function make(name:String):DisplayObject {
            if (name == "Shadow")
                return _shadow();
            var c:Class = SINGLE[name] as Class;
            if (c == null)
                return null;
            return new c() as Bitmap;
        }

        // Shadow = dark body (284) with the white highlight layer (286) on top,
        // so the silhouette reads on the dark plate.
        private static function _shadow():DisplayObject {
            var s:Sprite = new Sprite();
            s.addChild(new Shadow0() as Bitmap);
            s.addChild(new Shadow1() as Bitmap);
            return s;
        }
    }
}
