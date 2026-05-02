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
    import com.giab.games.gcfw.entity.MapTile;

    /**
     * Custom drop icon for map tile unlocks. Pulls the live tile bitmap
     * from GV.selectorCore.mapTiles so the icon shows the actual tile
     * artwork the player sees on the world map.
     *
     * tileGameId is the integer 0..25; the displayed letter is
     * "ZYXWVUTSRQPONMLKJIHGFEDCBA".charAt(tileGameId), matching
     * WorldMapBuilder's tile-letter convention.
     *
     * Mirrors GempouchDropIcon's public shape (type, data, meta) so it
     * lives in ending.dropIcons without breaking vanilla cleanup.
     */
    public class MapTileDropIcon extends Sprite {
        private static const TILE_LETTERS:String = "ZYXWVUTSRQPONMLKJIHGFEDCBA";

        public var cntInner:Sprite;
        public var bmpIcon:Bitmap;
        public var bmpdIcon:BitmapData;
        public var type:int;
        public var meta:Object;
        // Vanilla IngameEnding.removeAllDropIcons writes `.data = null` on
        // every entry during cleanup; sealed Sprite subclasses reject
        // dynamic property assignment, so the field must exist.
        public var data:*;

        public function MapTileDropIcon(tileGameId:int) {
            super();

            var letter:String = (tileGameId >= 0 && tileGameId < TILE_LETTERS.length)
                ? TILE_LETTERS.charAt(tileGameId)
                : "?";

            this.type = DropType.MAP_TILE;
            this.meta = { tileGameId: tileGameId, letter: letter };

            this.cntInner = new Sprite();
            addChild(this.cntInner);

            this.bmpdIcon = new BitmapData(140, 140, true, 0);
            this.bmpIcon  = new Bitmap(this.bmpdIcon);

            var srcBmpd:BitmapData = _resolveTileBmpd(tileGameId);
            if (srcBmpd != null) {
                var srcW:int = srcBmpd.width;
                var srcH:int = srcBmpd.height;
                var maxDim:int = 120;
                var scale:Number = Math.min(maxDim / srcW, maxDim / srcH);

                var m:Matrix = new Matrix();
                m.scale(scale, scale);
                m.translate((140 - srcW * scale) / 2, (140 - srcH * scale) / 2);

                this.bmpdIcon.draw(srcBmpd, m, null, null, null, true);

                var dsf:DropShadowFilter = new DropShadowFilter(0, 45, 0, 1, 14, 14, 2, 3);
                this.bmpdIcon.applyFilter(this.bmpdIcon, new Rectangle(0, 0, 140, 140), new Point(0, 0), dsf);
            } else {
                // selectorCore not built yet — fall back to a flat plate so the
                // ending screen still renders.
                this.bmpdIcon.fillRect(new Rectangle(10, 10, 120, 120), 0xFF333333);
            }

            this.cntInner.addChild(this.bmpIcon);

            addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver, false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT,  _onMouseOut,  false, 0, true);
        }

        private static function _resolveTileBmpd(tileGameId:int):BitmapData {
            try {
                if (GV.selectorCore == null) return null;
                var tiles:Array = GV.selectorCore.mapTiles as Array;
                if (tiles == null || tileGameId < 0 || tileGameId >= tiles.length) return null;
                var tile:MapTile = tiles[tileGameId] as MapTile;
                return tile != null ? tile.bmpd : null;
            } catch (e:Error) {}
            return null;
        }

        private function _onMouseOver(e:MouseEvent):void {
            try {
                var vIp:* = GV.mcInfoPanel;
                vIp.reset(280);
                vIp.addTextfield(0xFFD700, "Map Tile " + String(this.meta.letter), false, 13);
                vIp.addTextfield(0xCCCCCC, "World Map", false, 11);
                vIp.addTextfield(0x99FF99, "Reveals tile " + String(this.meta.letter) + " on the world map.", false, 11);
                GV.main.cntInfoPanel.addChild(vIp);
                vIp.doEnterFrame();
            } catch (err:Error) {}
        }

        private function _onMouseOut(e:MouseEvent):void {
            try { GV.main.cntInfoPanel.removeChild(GV.mcInfoPanel); } catch (err:Error) {}
        }
    }
}
