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
    public dynamic class KeyPouchDropIcon extends Sprite {

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

        [Embed(source='../../resources/KeyPouch.png')]
        private static const KeyPouchAsset:Class;

        public function KeyPouchDropIcon(apId:int, ordinal:int = 0) {
            super();

            this.type = DropType.FIELD_TOKEN; // for the vanilla reveal sound
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
        // Tooltip — branches on apId range. Wording mirrors itemName(apId) in
        // ArchipelagoMod.as so labels are consistent across UI surfaces.

        private function _onMouseOver(e:MouseEvent):void {
            try {
                if (this.meta == null)
                    return;
                var apId:int = int(this.meta.apId);

                var title:String = null;
                var subtitle:String = "Wizard Stash Key";
                var body:String = null;

                var opts:ServerOptions = AV.serverData != null
                    ? AV.serverData.serverOptions : null;

                if (this.meta.isProgressive == true) {
                    // 1620 — per-tile progressive
                    var ordinalT:int = int(this.meta.ordinal);
                    var copiesT:int = (ordinalT > 0) ? ordinalT
                                                    : AV.sessionData.getItemCount(apId);
                    var prefixT:String = opts != null ? opts.progressiveTilePrefix(copiesT) : "?";
                    title = "Progressive Stash Key";
                    body  = "Unlocks Wizard Stashes on tile " + prefixT + ". "
                          + "(" + copiesT + "/" + (opts != null ? opts.progressiveTileOrderLength() : 26)
                          + " worlds unlocked)";
                } else if (this.meta.isTierProgressive == true) {
                    // 1621 — per-tier progressive
                    var ordinalR:int = int(this.meta.ordinal);
                    var copiesR:int = (ordinalR > 0) ? ordinalR
                                                    : AV.sessionData.getItemCount(apId);
                    var tierOrder:Array = (opts != null) ? opts.progressiveTierOrder as Array : null;
                    var tierLabel:String = (tierOrder != null && copiesR >= 1 && copiesR <= tierOrder.length)
                        ? String(tierOrder[copiesR - 1])
                        : "?";
                    var tierTotal:int = (tierOrder != null) ? tierOrder.length : 13;
                    title = "Progressive Stash Tier Key";
                    body  = "Unlocks Wizard Stashes in tier " + tierLabel + ". "
                          + "(" + copiesR + "/" + tierTotal + " tiers unlocked)";
                } else if (apId >= 1522 && apId <= 1547) {
                    // Per-tile distinct
                    var idx:int = apId - 1522;
                    var order:Array = (opts != null) ? opts.gemPouchPlayOrder as Array : null;
                    if (order == null || idx < 0 || idx >= order.length)
                        return;
                    var prefix:String = String(order[idx]);
                    title = "Wizard Stash Tile " + prefix + " Key";
                    body  = "Unlocks every Wizard Stash on tile " + prefix + ".";
                } else if (apId >= 1548 && apId <= 1560) {
                    // Per-tier distinct
                    var tier:int = apId - 1548;
                    title = "Wizard Stash Tier " + tier + " Key";
                    body  = "Unlocks every Wizard Stash in tier " + tier + ".";
                } else if (apId == 1561) {
                    // Master
                    title = "Wizard Stash Master Key";
                    body  = "Unlocks every Wizard Stash.";
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
                    var progId:int = int(opts.stashKeyPerTileProgressiveId);
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
                    var progId:int = int(opts.stashKeyPerTierProgressiveId);
                    if (progId > 0 && apId == progId)
                        return true;
                }
            } catch (e:Error) {}
            return false;
        }

    }
}
