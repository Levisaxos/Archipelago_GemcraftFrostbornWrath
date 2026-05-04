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
     * Custom drop icon for Wizard Stash key pouches — bundled stash keys that
     * unlock multiple stashes at once.
     *
     * AP id ranges this icon serves:
     *   1522-1547  Per-tile  (one pouch per prefix in gemPouchPlayOrder)
     *   1548-1560  Per-tier  (one pouch per tier 0..12)
     *   1561       Master    (single pouch unlocking every stash)
     *   stashKeyPerTileProgressiveId   per-tile progressive (single id, 26 copies)
     *
     * Vanilla has no DropType for stash keys, so we synthesize an icon using
     * an embedded PNG (KeyPouch.png in mods/ArchipelagoMod/resources/).
     *
     * Mimics McDropIconOutcome's public shape (type / data / cntInner / bmpIcon
     * / bmpdIcon) so the icon slots into the same code paths the level-end
     * dropicon system uses, and so the OfflineItemsPanel factory can extract
     * bmpdIcon the same way it does for every other drop icon.
     *
     * .type is set to DropType.FIELD_TOKEN so the vanilla reveal animation
     * picks the "sndoctoken" sound (no dedicated stash-key SFX exists). Same
     * pattern XpTomeDropIcon uses with SKILL_TOME for the chime.
     */
    public class KeyPouchDropIcon extends Sprite {

        public var cntInner:Sprite;
        public var bmpIcon:Bitmap;
        public var bmpdIcon:BitmapData;
        public var type:int;
        public var data:Object;
        // ordinal is the 1-based copy index for progressive variants — needed
        // because multiple copies can drop at the same level-end and reading
        // getItemCount() at hover stamps the same total on every icon. 0 ==
        // "fall back to live count" for callers that don't track per-copy.
        public var meta:Object;  // { apId:int, isProgressive:Boolean, ordinal:int }

        [Embed(source='../../resources/KeyPouch.png')]
        private static const KeyPouchAsset:Class;

        public function KeyPouchDropIcon(apId:int, ordinal:int = 0) {
            super();

            this.type = DropType.FIELD_TOKEN; // for the vanilla reveal sound
            this.data = { apId: apId };
            this.meta = {
                apId: apId,
                isProgressive: _isPerTileProgressive(apId),
                ordinal: ordinal
            };

            this.cntInner = new Sprite();
            addChild(this.cntInner);

            this.bmpdIcon = new BitmapData(140, 140, true, 0);
            this.bmpIcon  = new Bitmap(this.bmpdIcon);

            var src:Bitmap = new KeyPouchAsset() as Bitmap;
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
        // Tooltip — only the per-tile progressive variant renders one for now;
        // the per-tile / per-tier / master variants fall through silently.

        private function _onMouseOver(e:MouseEvent):void {
            try {
                if (this.meta == null || this.meta.isProgressive != true)
                    return;

                var vIp:* = GV.mcInfoPanel;
                vIp.reset(280);

                var apId:int = int(this.meta.apId);
                var ordinal:int = int(this.meta.ordinal);
                var copies:int = (ordinal > 0) ? ordinal
                                               : AV.sessionData.getItemCount(apId);
                var prefix:String = _progressiveTilePrefix(copies);

                var title:String = "Progressive Stash Key";
                var subtitle:String = "Wizard Stash Key";
                var body:String = "Unlocks Wizard Stashes on tile " + prefix + ". "
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
                    var progId:int = int(opts.stashKeyPerTileProgressiveId);
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
