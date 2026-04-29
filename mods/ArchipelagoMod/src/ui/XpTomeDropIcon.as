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
     * Custom drop icon for AP "XP Tome" items (apId 1100-1199). Vanilla has no
     * DropType for wizard-XP grants, so we synthesize an icon using one of three
     * embedded PNGs (Tattered Scroll / Worn Tome / Ancient Grimoire) chosen by
     * the AP id range.
     *
     * Mimics McDropIconOutcome's public shape so it can live in ending.dropIcons
     * without breaking the vanilla animation loop or the IngameEnding.removeAllDropIcons
     * cleanup pass:
     *   - .type / .data        — read by the animation loop and cleanup
     *   - .cntInner            — has removeChildren()
     *   - .bmpIcon / .bmpdIcon — bitmap holder + backing data, disposed on cleanup
     *
     * .type is set to DropType.SKILL_TOME so the vanilla reveal animation plays
     * sndoutcomeskilltome — fitting since these are tomes/scrolls/grimoires. We
     * register our OWN MOUSE_OVER/MOUSE_OUT listeners (not ih.ehDropIconOver),
     * because vanilla's renderDropIconInfoPanel would treat .data as a skill id
     * and throw or render a wrong tooltip.
     */
    public class XpTomeDropIcon extends Sprite {

        // Mirror McDropIconOutcome's public fields so external code that walks
        // dropIcons sees a familiar shape.
        public var cntInner:Sprite;
        public var bmpIcon:Bitmap;
        public var bmpdIcon:BitmapData;
        public var type:int;
        public var data:Object;  // { apId:int, label:String }

        // --- Embedded artwork ---
        // Paths are relative to this .as file: src/ui/ → ../../resources/
        [Embed(source='../../resources/TatteredScroll.png')]
        private static const TatteredAsset:Class;
        [Embed(source='../../resources/WornTome.png')]
        private static const WornAsset:Class;
        [Embed(source='../../resources/AncientGrimoire.png')]
        private static const AncientAsset:Class;

        public function XpTomeDropIcon(apId:int, levels:int = 0) {
            super();

            this.type = DropType.SKILL_TOME; // for the vanilla reveal sound
            this.data = { apId: apId, label: _labelForApId(apId), levels: levels };

            this.cntInner = new Sprite();
            addChild(this.cntInner);

            this.bmpdIcon = new BitmapData(140, 140, true, 0);
            this.bmpIcon  = new Bitmap(this.bmpdIcon);

            // Pick the right asset and draw it centered into the 140x140 region.
            var src:Bitmap = _newAssetBitmap(apId);
            if (src != null && src.bitmapData != null) {
                var srcW:int = src.bitmapData.width;
                var srcH:int = src.bitmapData.height;
                var maxDim:int = 120; // leave a little padding inside 140x140
                var scale:Number = Math.min(maxDim / srcW, maxDim / srcH);

                var m:Matrix = new Matrix();
                m.scale(scale, scale);
                m.translate((140 - srcW * scale) / 2, (140 - srcH * scale) / 2);

                this.bmpdIcon.draw(src.bitmapData, m, null, null, null, true);

                // Same drop shadow vanilla applies to its drop icons.
                var dsf:DropShadowFilter = new DropShadowFilter(0, 45, 0, 1, 14, 14, 2, 3);
                this.bmpdIcon.applyFilter(this.bmpdIcon, new Rectangle(0, 0, 140, 140), new Point(0, 0), dsf);
            }

            this.cntInner.addChild(this.bmpIcon);

            addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver, false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT,  _onMouseOut,  false, 0, true);
        }

        private static function _labelForApId(apId:int):String {
            // Per LevelUnlocker.xpLevelsForApId:
            //   1100-1131 + 1140-1199 → Tattered Scroll
            //   1132-1137              → Worn Tome
            //   1138-1139              → Ancient Grimoire
            if (apId >= 1132 && apId <= 1137) return "Worn Tome";
            if (apId >= 1138 && apId <= 1139) return "Ancient Grimoire";
            return "Tattered Scroll";
        }

        private static function _newAssetBitmap(apId:int):Bitmap {
            if (apId >= 1132 && apId <= 1137) return new WornAsset() as Bitmap;
            if (apId >= 1138 && apId <= 1139) return new AncientAsset() as Bitmap;
            return new TatteredAsset() as Bitmap;
        }

        // --- Tooltip ---
        // Use GV.mcInfoPanel directly (same pattern as the FieldTooltipOverlay /
        // ModButtons hover handlers). MOUSE_OUT removeChild is wrapped because
        // the panel may not be a child if the player moves the mouse fast.

        private function _onMouseOver(e:MouseEvent):void {
            try {
                var vIp:* = GV.mcInfoPanel;
                vIp.reset(260);
                vIp.addTextfield(0xFFD700, String(this.data.label), false, 13);
                vIp.addTextfield(0xCCCCCC, "Wizard XP Tome", false, 11);
                var lv:int = int(this.data.levels);
                var grantText:String = (lv > 0)
                    ? ("Grants " + lv + " wizard level" + (lv == 1 ? "" : "s"))
                    : "Grants wizard levels when collected";
                vIp.addTextfield(0x99FF99, grantText, false, 11);
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
