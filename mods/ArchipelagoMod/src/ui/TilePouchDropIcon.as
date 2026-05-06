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
    import data.ServerOptions;

    /**
     * Custom drop icon for coarse-granularity field-token items — per_tile,
     * per_tier, and their progressive siblings. Reads as "field tokens for a
     * group of stages" rather than a specific map tile, which is why we use
     * a generic pouch artwork instead of the actual MapTile bitmap.
     *
     * AP id ranges this icon serves:
     *   1562-1587  per-tile field tokens          (one per playOrder prefix)
     *   1588-1600  per-tier field tokens          (one per tier 0..12)
     *   1617       per-tile field token progressive  (single id, 26 copies)
     *   1618       per-tier field token progressive  (single id, 13 copies)
     *
     * Asset: ../../resources/TilePouch.png
     *
     * Mimics McDropIconOutcome's public shape (type / data / cntInner /
     * bmpIcon / bmpdIcon) so the OfflineItemsPanel factory can extract
     * bmpdIcon the same way it does for every other drop icon.
     *
     * .type = DropType.FIELD_TOKEN so the vanilla reveal animation plays
     * the same chime as regular per-stage field tokens (sndoctoken).
     */
    public dynamic class TilePouchDropIcon extends Sprite {

        public var cntInner:Sprite;
        public var bmpIcon:Bitmap;
        public var bmpdIcon:BitmapData;
        public var type:int;
        // Class is `dynamic` so vanilla cleanup can write `.data = null`
        // without us declaring a `data` field that would shadow the
        // imported `data` package.
        // ordinal is the 1-based copy index for progressive variants — needed
        // because multiple copies can drop at the same level-end and reading
        // getItemCount() at hover stamps the same total on every icon. 0 ==
        // "fall back to live count" for callers that don't track per-copy.
        public var meta:Object;  // { apId:int, isProgressive:Boolean, isTierProgressive:Boolean, ordinal:int }

        [Embed(source='../../resources/TilePouch.png')]
        private static const TilePouchAsset:Class;

        public function TilePouchDropIcon(apId:int, ordinal:int = 0) {
            super();

            this.type = DropType.FIELD_TOKEN;
            this.data = { apId: apId };
            this.meta = {
                apId: apId,
                isProgressive: _isPerTileProgressive(apId),
                isTierProgressive: _isPerTierProgressive(apId),
                ordinal: ordinal
            };

            this.cntInner = new Sprite();
            addChild(this.cntInner);

            this.bmpdIcon = new BitmapData(140, 140, true, 0);
            this.bmpIcon  = new Bitmap(this.bmpdIcon);

            var src:Bitmap = new TilePouchAsset() as Bitmap;
            if (src != null && src.bitmapData != null) {
                var srcW:int   = src.bitmapData.width;
                var srcH:int   = src.bitmapData.height;
                var maxDim:int = 120;
                var scale:Number = Math.min(maxDim / srcW, maxDim / srcH);

                var m:Matrix = new Matrix();
                m.scale(scale, scale);
                m.translate((140 - srcW * scale) / 2, (140 - srcH * scale) / 2);

                this.bmpdIcon.draw(src.bitmapData, m, null, null, null, true);

                var dsf:DropShadowFilter = new DropShadowFilter(0, 45, 0, 1, 14, 14, 2, 3);
                this.bmpdIcon.applyFilter(this.bmpdIcon, new Rectangle(0, 0, 140, 140),
                                          new Point(0, 0), dsf);
            }

            this.cntInner.addChild(this.bmpIcon);

            addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver, false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT,  _onMouseOut,  false, 0, true);
        }

        // -----------------------------------------------------------------------
        // Tooltip — branches on apId range. Wording mirrors itemName(apId) in
        // ArchipelagoMod.as so labels are consistent across UI surfaces.

        private function _onMouseOver(e:MouseEvent):void {
            try {
                if (this.meta == null)
                    return;
                var apId:int = int(this.meta.apId);

                var title:String = null;
                var subtitle:String = "Field Token";
                var body:String = null;

                var opts:ServerOptions = AV.serverData != null
                    ? AV.serverData.serverOptions : null;

                if (this.meta.isProgressive == true) {
                    // 1617 — per-tile progressive
                    var ordinalT:int = int(this.meta.ordinal);
                    var copiesT:int = (ordinalT > 0) ? ordinalT
                                                    : AV.sessionData.getItemCount(apId);
                    var prefixT:String = opts != null ? opts.progressiveTilePrefix(copiesT) : "?";
                    title = "Progressive Field Token";
                    body  = "Unlocks fields on tile " + prefixT + ". "
                          + "(" + copiesT + "/" + (opts != null ? opts.progressiveTileOrderLength() : 26)
                          + " worlds unlocked)";
                } else if (this.meta.isTierProgressive == true) {
                    // 1618 — per-tier progressive
                    var ordinalR:int = int(this.meta.ordinal);
                    var copiesR:int = (ordinalR > 0) ? ordinalR
                                                    : AV.sessionData.getItemCount(apId);
                    var tierOrder:Array = (opts != null) ? opts.progressiveTierOrder as Array : null;
                    var tierLabel:String = (tierOrder != null && copiesR >= 1 && copiesR <= tierOrder.length)
                        ? String(tierOrder[copiesR - 1])
                        : "?";
                    var tierTotal:int = (tierOrder != null) ? tierOrder.length : 13;
                    title = "Progressive Field Token (per-tier)";
                    body  = "Unlocks fields in tier " + tierLabel + ". "
                          + "(" + copiesR + "/" + tierTotal + " tiers unlocked)";
                } else if (apId >= 1562 && apId <= 1587) {
                    // Per-tile distinct
                    var idx:int = apId - 1562;
                    var order:Array = (opts != null) ? opts.gemPouchPlayOrder as Array : null;
                    if (order == null || idx < 0 || idx >= order.length)
                        return;
                    var prefix:String = String(order[idx]);
                    title = prefix + " Tile Field Tokens";
                    body  = "Unlocks all field tokens on tile " + prefix + ".";
                } else if (apId >= 1588 && apId <= 1600) {
                    // Per-tier distinct
                    var tier:int = apId - 1588;
                    title = "Tier " + tier + " Field Tokens";
                    body  = "Unlocks all field tokens in tier " + tier + ".";
                } else {
                    return;
                }

                var vIp:* = GV.mcInfoPanel;
                vIp.reset(280);
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
                    var progId:int = int(opts.fieldTokenPerTileProgressiveId);
                    if (progId > 0 && apId == progId)
                        return true;
                }
            } catch (e:Error) {}
            return false;
        }

        private static function _isPerTierProgressive(apId:int):Boolean {
            try {
                var opts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
                if (opts != null) {
                    var progId:int = int(opts.fieldTokenPerTierProgressiveId);
                    if (progId > 0 && apId == progId)
                        return true;
                }
            } catch (e:Error) {}
            return false;
        }

    }
}
