package ui {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.filters.GlowFilter;

    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.DropType;
    import com.giab.games.gcfw.mcDyn.McDropIconOutcome;

    /**
     * Custom drop icon for skillpoint bundles (apId 1700-1709, summed
     * across one ending). Reuses the vanilla shadow-core drop visual with
     * a cyan GlowFilter so it reads as "skill" energy without needing a
     * bespoke art asset.
     *
     * Mimics McDropIconOutcome's public shape (type / data / cntInner /
     * bmpIcon / bmpdIcon) so it slots into ending.dropIcons without
     * breaking the vanilla IngameEnding.removeAllDropIcons cleanup, which
     * does .cntInner.removeChildren(), .bmpIcon=null, and bmpdIcon.dispose().
     */
    public class SkillPointDropIcon extends Sprite {

        public var type:int;
        public var meta:Object;
        // Vanilla IngameEnding.removeAllDropIcons writes `.data = null` on
        // every entry during cleanup; sealed Sprite subclasses reject
        // dynamic property assignment, so the field must exist.
        public var data:*;
        // Mirrors of the inner McDropIconOutcome, exposed at the top level
        // because vanilla's cleanup walks the icon directly (not the inner).
        public var cntInner:Sprite;
        public var bmpIcon:Bitmap;
        public var bmpdIcon:BitmapData;

        public function SkillPointDropIcon(amount:int) {
            super();

            this.type = DropType.SHADOW_CORE; // reuse the shadow-core reveal SFX
            this.meta = { amount: amount };

            var inner:McDropIconOutcome = new McDropIconOutcome(DropType.SHADOW_CORE, amount);
            addChild(inner);

            // Forward references so vanilla cleanup can find them on the
            // outer sprite. cntInner.removeChildren() and bmpdIcon.dispose()
            // operate on the inner's actual instances either way.
            this.cntInner = inner.cntInner;
            this.bmpIcon  = inner.bmpIcon;
            this.bmpdIcon = inner.bmpdIcon;

            this.filters = [new GlowFilter(0x33CCFF, 1, 16, 16, 3, 2)];

            addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver, false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT,  _onMouseOut,  false, 0, true);
        }

        private function _onMouseOver(e:MouseEvent):void {
            try {
                var vIp:* = GV.mcInfoPanel;
                vIp.reset(280);
                vIp.addTextfield(0xFFD700, "Skillpoint Bundle", false, 13);
                vIp.addTextfield(0xCCCCCC, "Skill Points", false, 11);
                vIp.addTextfield(0x99FF99, "+" + String(this.meta.amount) + " skill points.", false, 11);
                GV.main.cntInfoPanel.addChild(vIp);
                vIp.doEnterFrame();
            } catch (err:Error) {}
        }

        private function _onMouseOut(e:MouseEvent):void {
            try { GV.main.cntInfoPanel.removeChild(GV.mcInfoPanel); } catch (err:Error) {}
        }
    }
}
