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
     * Custom drop icon for AP "Gempouch" items.
     *
     * Supported apIds:
     *   626-651  per-tile distinct  (Gempouch (X))
     *   652      per-tile progressive
     *   1601-1613 per-tier distinct  (Tier N Gempouch)
     *   1614     master              (Master Gempouch)
     *   1615     per-tier progressive
     *
     * Mirrors XpTomeDropIcon's public shape so it lives in ending.dropIcons
     * without breaking the vanilla animation loop or cleanup. Uses our own
     * MOUSE_OVER/MOUSE_OUT — vanilla renderDropIconInfoPanel doesn't know
     * our type.
     */
    public class GempouchDropIcon extends Sprite {

        public var cntInner:Sprite;
        public var bmpIcon:Bitmap;
        public var bmpdIcon:BitmapData;
        public var type:int;
        // Variant: "tile" / "tile_progressive" / "tier" / "master" / "tier_progressive".
        // ordinal is the 1-based copy index for progressive variants — needed
        // because multiple progressive copies can drop at the same level-end,
        // and reading getItemCount() at hover would stamp the same total on
        // every icon. ordinal == 0 means "fall back to live count" (icons
        // built outside the per-session emission path keep the old behaviour).
        public var meta:Object;  // { apId:int, prefix:String, variant:String, ordinal:int }
        // Vanilla IngameEnding.removeAllDropIcons writes `.data = null` on
        // every entry in core.ending.dropIcons during cleanup. Sealed Sprite
        // subclasses reject dynamic property assignment, so the field must
        // exist or the cleanup throws. Unread by us — mirrors XpTomeDropIcon.
        public var data:*;

        // Single shared artwork for all pouch variants. Path is relative to
        // this .as file: src/ui/ → ../../resources/
        [Embed(source='../../resources/GemPouch.png')]
        private static const PouchAsset:Class;

        public function GempouchDropIcon(apId:int, ordinal:int = 0) {
            super();

            var variant:String = _variantForApId(apId);
            var prefix:String = (variant == "tile") ? _prefixForApId(apId) : "";

            this.type = DropType.SKILL_TOME; // reuse the tome reveal SFX
            this.meta = {
                apId: apId,
                prefix: prefix,
                variant: variant,
                ordinal: ordinal
            };

            this.cntInner = new Sprite();
            addChild(this.cntInner);

            this.bmpdIcon = new BitmapData(140, 140, true, 0);
            this.bmpIcon  = new Bitmap(this.bmpdIcon);

            var src:Bitmap = new PouchAsset() as Bitmap;
            if (src != null && src.bitmapData != null) {
                var srcW:int = src.bitmapData.width;
                var srcH:int = src.bitmapData.height;
                var maxDim:int = 120; // padding inside 140x140
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

        // -----------------------------------------------------------------------

        private static function _variantForApId(apId:int):String {
            try {
                var opts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
                if (opts != null) {
                    var tileProg:int = int(opts.gemPouchProgressiveId);
                    if (tileProg > 0 && apId == tileProg) return "tile_progressive";
                    var tierProg:int = int(opts.gemPouchPerTierProgressiveId);
                    if (tierProg > 0 && apId == tierProg) return "tier_progressive";
                }
            } catch (e:Error) {}
            // Apworld-allocated defaults / fixed ranges.
            if (apId == 652)  return "tile_progressive";
            if (apId == 1615) return "tier_progressive";
            if (apId == 1614) return "master";
            if (apId >= 1601 && apId <= 1613) return "tier";
            return "tile";
        }

        private static function _prefixForApId(apId:int):String {
            try {
                var opts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
                if (opts != null) {
                    var order:Array = opts.gemPouchPlayOrder as Array;
                    var idx:int = apId - 626;
                    if (order != null && idx >= 0 && idx < order.length) {
                        return String(order[idx]);
                    }
                }
            } catch (e:Error) {}
            return "?";
        }

        // -----------------------------------------------------------------------
        // Tooltip

        private function _onMouseOver(e:MouseEvent):void {
            try {
                var vIp:* = GV.mcInfoPanel;
                vIp.reset(280);

                var title:String;
                var subtitle:String = "Gem Pouch";
                var body:String;
                var variant:String = String(this.meta.variant);
                var apId:int = int(this.meta.apId);
                var ordinal:int = int(this.meta.ordinal);
                if (variant == "tile_progressive") {
                    title = "Progressive Gempouch";
                    var copiesT:int = (ordinal > 0) ? ordinal
                                                    : AV.sessionData.getItemCount(apId);
                    var prefixT:String = _progressiveTilePrefix(copiesT);
                    body = "Unlocks gems on tile " + prefixT + ". "
                         + "(" + copiesT + "/" + _orderLength() + " worlds unlocked)";
                } else if (variant == "tier_progressive") {
                    title = "Progressive Gempouch (per-tier)";
                    var copiesTier:int = AV.sessionData.getItemCount(apId);
                    body = "Unlocks gems on the next tier. "
                         + "(" + copiesTier + "/" + _tierLength() + " tiers unlocked)";
                } else if (variant == "tier") {
                    var tier:int = apId - 1601;
                    title = "Tier " + tier + " Gempouch";
                    body = "Unlocks gems on stages of tier " + tier + ".";
                } else if (variant == "master") {
                    title = "Master Gempouch";
                    body = "Unlocks gems on every stage.";
                } else {
                    title = "Gempouch (" + String(this.meta.prefix) + ")";
                    body = "Unlocks gems on stages of world " + String(this.meta.prefix) + ".";
                }

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

        private static function _tierLength():int {
            try {
                var opts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
                if (opts != null) {
                    var tm:Object = opts.stageTierByStrId;
                    if (tm != null) {
                        var seen:Object = {};
                        var n:int = 0;
                        for (var k:String in tm) {
                            var t:int = int(tm[k]);
                            if (seen[t] !== true) { seen[t] = true; n++; }
                        }
                        if (n > 0) return n;
                    }
                }
            } catch (e:Error) {}
            return 13;
        }
    }
}
