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

    import net.ConnectionManager;

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
    public dynamic class WizStashKeyDropIcon extends Sprite {

        public var cntInner:Sprite;
        public var bmpIcon:Bitmap;
        public var bmpdIcon:BitmapData;
        public var type:int;
        // Class is `dynamic` so vanilla cleanup can write `.data = null`
        // without us declaring a `data` field that would shadow anything.
        public var meta:Object;  // { apId:int }

        [Embed(source='../../resources/WizStashKey.png')]
        private static const WizStashKeyAsset:Class;

        public function WizStashKeyDropIcon(apId:int) {
            super();

            this.type = DropType.FIELD_TOKEN; // for the vanilla reveal sound
            this.data = { apId: apId };
            this.meta = { apId: apId };

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

            addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver, false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT,  _onMouseOut,  false, 0, true);
        }

        // -----------------------------------------------------------------------
        // Tooltip — reverse-resolves the unlocked stage strId from
        // ConnectionManager.stageLocIds so the user sees which stage this key
        // is for. Falls back to the raw "#N" form if the map isn't populated
        // (e.g. running offline / before slot data has loaded).

        private function _onMouseOver(e:MouseEvent):void {
            try {
                if (this.meta == null)
                    return;
                var apId:int = int(this.meta.apId);
                var stashLocId:int = apId - 1400 + 1;

                var stageStrId:String = null;
                var map:Object = ConnectionManager.stageLocIds;
                if (map != null) {
                    for (var sid:String in map) {
                        if (int(map[sid]) == stashLocId) {
                            stageStrId = sid;
                            break;
                        }
                    }
                }

                var subtitle:String = (stageStrId != null)
                    ? "Stage " + stageStrId
                    : "Wizard Stash Key #" + stashLocId;

                var vIp:* = GV.mcInfoPanel;
                vIp.reset(280);
                vIp.addTextfield(0xFFD700, "Wizard Stash Key", false, 13);
                vIp.addTextfield(0xCCCCCC, subtitle, false, 11);
                vIp.addTextfield(0x99FF99, "Unlocks the Wizard Stash on this stage.", false, 11);
                GV.main.cntInfoPanel.addChild(vIp);
                vIp.doEnterFrame();
            } catch (err:Error) {}
        }

        private function _onMouseOut(e:MouseEvent):void {
            try { GV.main.cntInfoPanel.removeChild(GV.mcInfoPanel); } catch (err:Error) {}
        }
    }
}
