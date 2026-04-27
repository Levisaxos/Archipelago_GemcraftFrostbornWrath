package ui {

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    import com.giab.games.gcfw.GV;

    import Bezel.Logger;

    /**
     * In-battle HUD that lists achievements still missing AND realistically
     * earnable on the current field, given the player's current loadout.
     *
     * Two visible states:
     *   - Collapsed: a small button (top-right of the play area).
     *   - Expanded: header + 5×4 icon grid (scrollable when > 20 items).
     *
     * The list is populated externally via setAchievements() — the panel
     * has no knowledge of the logic evaluator.
     */
    public class AvailableAchievementsPanel extends Sprite {

        // Geometry
        private static const COLS:int          = 5;
        private static const VISIBLE_ROWS:int  = 4;
        private static const CELL_SIZE:int     = 48;
        private static const CELL_PAD:int      = 4;
        private static const HEADER_H:int      = 28;
        private static const PAD_X:int         = 8;
        private static const PAD_Y:int         = 8;
        private static const COLLAPSED_SIZE:int = 32;

        // Visual style
        private static const BG_COLOR:uint     = 0x0C0818;
        private static const BG_ALPHA:Number   = 0.92;
        private static const BORDER_COLOR:uint = 0x9966CC;
        private static const HEADER_COLOR:uint = 0xCC99FF;
        private static const COUNT_COLOR:uint  = 0xFFE066;
        private static const PLACEHOLDER_BG:uint = 0x332244;
        private static const PLACEHOLDER_TXT:uint = 0xCCBBEE;
        private static const FONT:String       = "Celtic Garamond for GemCraft";

        // Scroll
        private static const SCROLL_STEP:int   = 1;

        private var _logger:Logger;
        private var _modName:String;

        private var _collapsed:Sprite;
        private var _expanded:Sprite;
        private var _bg:Shape;
        private var _header:TextField;
        private var _closeBtn:Sprite;
        private var _grid:Sprite;
        private var _gridMask:Shape;
        private var _emptyLabel:TextField;
        private var _tooltip:TextField;

        private var _entries:Array = []; // [{apId, gameId, name, description}]
        private var _scrollRow:int = 0;
        private var _isExpanded:Boolean = false;

        private var _iconCache:Object = {}; // gameId -> BitmapData

        private var _panelW:int;
        private var _panelH:int;

        /** Optional callback invoked just before the grid is shown so the host
         *  can recompute the achievement list against fresh in-level state. */
        public var onExpandRequested:Function = null;

        public function AvailableAchievementsPanel(logger:Logger, modName:String) {
            super();
            _logger = logger;
            _modName = modName;

            mouseEnabled = true;
            mouseChildren = true;

            _panelW = PAD_X * 2 + COLS * (CELL_SIZE + CELL_PAD) - CELL_PAD;
            _panelH = HEADER_H + PAD_Y * 2 + VISIBLE_ROWS * (CELL_SIZE + CELL_PAD) - CELL_PAD;

            _buildCollapsed();
            _buildExpanded();
            collapse();
        }

        // -----------------------------------------------------------------------
        // Public API

        public function get panelWidth():int  { return _panelW; }
        public function get panelHeight():int { return _panelH; }
        public function get isExpanded():Boolean { return _isExpanded; }

        /** Replace the list of entries shown in the grid. Resets scroll. */
        public function setAchievements(entries:Array):void {
            _entries = entries != null ? entries : [];
            _scrollRow = 0;
            _refreshHeader();
            _redrawGrid();
            _refreshCollapsedBadge();
        }

        /** Show the small button only. */
        public function collapse():void {
            _isExpanded = false;
            _expanded.visible = false;
            _collapsed.visible = true;
        }

        /** Show the full grid panel. */
        public function expand():void {
            _isExpanded = true;
            _collapsed.visible = false;
            _expanded.visible = true;
            _refreshHeader();
            _redrawGrid();
        }

        public function toggleExpanded():void {
            if (_isExpanded) collapse();
            else expand();
        }

        // -----------------------------------------------------------------------
        // Layout: collapsed (small button)

        private function _buildCollapsed():void {
            _collapsed = new Sprite();
            _collapsed.buttonMode = true;
            _collapsed.useHandCursor = true;
            _collapsed.mouseChildren = false;

            var s:Shape = new Shape();
            s.graphics.beginFill(BG_COLOR, BG_ALPHA);
            s.graphics.lineStyle(1.5, BORDER_COLOR, 0.85);
            s.graphics.drawRoundRect(0, 0, COLLAPSED_SIZE, COLLAPSED_SIZE, 6, 6);
            s.graphics.endFill();
            _collapsed.addChild(s);

            var fmt:TextFormat = new TextFormat(FONT, 14);
            fmt.bold = true;
            fmt.align = TextFormatAlign.CENTER;
            var label:TextField = new TextField();
            label.mouseEnabled = false;
            label.selectable = false;
            label.embedFonts = false;
            label.antiAliasType = AntiAliasType.ADVANCED;
            label.defaultTextFormat = fmt;
            label.autoSize = TextFieldAutoSize.CENTER;
            label.textColor = HEADER_COLOR;
            label.text = "?";
            label.x = (COLLAPSED_SIZE - label.width) * 0.5;
            label.y = (COLLAPSED_SIZE - label.height) * 0.5;
            label.name = "lbl";
            _collapsed.addChild(label);

            _collapsed.addEventListener(MouseEvent.CLICK, _onCollapsedClick, false, 0, true);

            addChild(_collapsed);
        }

        private function _onCollapsedClick(e:MouseEvent):void {
            if (onExpandRequested != null) {
                try { onExpandRequested(); } catch (err:Error) {}
            }
            expand();
        }

        private function _refreshCollapsedBadge():void {
            try {
                var lbl:TextField = _collapsed.getChildByName("lbl") as TextField;
                if (lbl != null) {
                    lbl.text = _entries.length > 0 ? String(_entries.length) : "?";
                    lbl.x = (COLLAPSED_SIZE - lbl.width) * 0.5;
                    lbl.y = (COLLAPSED_SIZE - lbl.height) * 0.5;
                }
            } catch (err:Error) {}
        }

        // -----------------------------------------------------------------------
        // Layout: expanded (grid panel)

        private function _buildExpanded():void {
            _expanded = new Sprite();
            _expanded.mouseEnabled = true;
            _expanded.mouseChildren = true;

            _bg = new Shape();
            _expanded.addChild(_bg);

            // Header text
            var fmt:TextFormat = new TextFormat(FONT, 14);
            fmt.bold = true;
            fmt.align = TextFormatAlign.LEFT;
            _header = new TextField();
            _header.mouseEnabled = false;
            _header.selectable = false;
            _header.embedFonts = false;
            _header.antiAliasType = AntiAliasType.ADVANCED;
            _header.defaultTextFormat = fmt;
            _header.autoSize = TextFieldAutoSize.LEFT;
            _header.textColor = HEADER_COLOR;
            _header.text = "Available achievements";
            _header.x = PAD_X;
            _header.y = 6;
            _expanded.addChild(_header);

            // Close (collapse) button — small ✕ in top-right
            _closeBtn = new Sprite();
            _closeBtn.buttonMode = true;
            _closeBtn.useHandCursor = true;
            _closeBtn.mouseChildren = false;
            var close:Shape = new Shape();
            close.graphics.beginFill(0x000000, 0);
            close.graphics.drawRect(0, 0, 22, 22);
            close.graphics.endFill();
            close.graphics.lineStyle(2, HEADER_COLOR, 0.9);
            close.graphics.moveTo(5, 5);  close.graphics.lineTo(17, 17);
            close.graphics.moveTo(17, 5); close.graphics.lineTo(5, 17);
            _closeBtn.addChild(close);
            _closeBtn.x = _panelW - 22 - 4;
            _closeBtn.y = 3;
            _closeBtn.addEventListener(MouseEvent.CLICK, _onCloseClick, false, 0, true);
            _expanded.addChild(_closeBtn);

            // Grid container
            _grid = new Sprite();
            _grid.x = PAD_X;
            _grid.y = HEADER_H + PAD_Y;
            _expanded.addChild(_grid);

            _gridMask = new Shape();
            _expanded.addChild(_gridMask);
            _grid.mask = _gridMask;

            // Empty-state label
            var emptyFmt:TextFormat = new TextFormat(FONT, 12);
            emptyFmt.italic = true;
            emptyFmt.align = TextFormatAlign.CENTER;
            _emptyLabel = new TextField();
            _emptyLabel.mouseEnabled = false;
            _emptyLabel.selectable = false;
            _emptyLabel.embedFonts = false;
            _emptyLabel.antiAliasType = AntiAliasType.ADVANCED;
            _emptyLabel.defaultTextFormat = emptyFmt;
            _emptyLabel.autoSize = TextFieldAutoSize.CENTER;
            _emptyLabel.textColor = 0x887799;
            _emptyLabel.text = "No achievements available with current loadout.";
            _emptyLabel.width = _panelW - PAD_X * 2;
            _emptyLabel.x = PAD_X;
            _emptyLabel.y = HEADER_H + (_panelH - HEADER_H) * 0.5 - 8;
            _emptyLabel.visible = false;
            _expanded.addChild(_emptyLabel);

            // Tooltip (single shared TextField shown on hover)
            var tipFmt:TextFormat = new TextFormat(FONT, 11);
            tipFmt.bold = true;
            tipFmt.align = TextFormatAlign.LEFT;
            _tooltip = new TextField();
            _tooltip.mouseEnabled = false;
            _tooltip.selectable = false;
            _tooltip.embedFonts = false;
            _tooltip.antiAliasType = AntiAliasType.ADVANCED;
            _tooltip.defaultTextFormat = tipFmt;
            _tooltip.autoSize = TextFieldAutoSize.LEFT;
            _tooltip.background = true;
            _tooltip.backgroundColor = 0x000000;
            _tooltip.border = true;
            _tooltip.borderColor = BORDER_COLOR;
            _tooltip.textColor = 0xFFE0FF;
            _tooltip.visible = false;
            _expanded.addChild(_tooltip);

            _expanded.addEventListener(MouseEvent.MOUSE_WHEEL, _onWheel, false, 0, true);

            addChild(_expanded);

            _drawBackground();
            _drawGridMask();
        }

        private function _onCloseClick(e:MouseEvent):void {
            collapse();
        }

        private function _drawBackground():void {
            _bg.graphics.clear();
            _bg.graphics.beginFill(BG_COLOR, BG_ALPHA);
            _bg.graphics.lineStyle(1.5, BORDER_COLOR, 0.85);
            _bg.graphics.drawRoundRect(0, 0, _panelW, _panelH, 8, 8);
            _bg.graphics.endFill();
            // Header divider
            _bg.graphics.lineStyle(1, BORDER_COLOR, 0.5);
            _bg.graphics.moveTo(PAD_X, HEADER_H);
            _bg.graphics.lineTo(_panelW - PAD_X, HEADER_H);
        }

        private function _drawGridMask():void {
            _gridMask.graphics.clear();
            _gridMask.graphics.beginFill(0xFF0000);
            _gridMask.graphics.drawRect(PAD_X, HEADER_H + PAD_Y,
                _panelW - PAD_X * 2,
                VISIBLE_ROWS * (CELL_SIZE + CELL_PAD) - CELL_PAD);
            _gridMask.graphics.endFill();
        }

        private function _refreshHeader():void {
            var rows:int = Math.ceil(_entries.length / Number(COLS));
            var maxRow:int = Math.max(0, rows - VISIBLE_ROWS);
            if (_scrollRow > maxRow) _scrollRow = maxRow;

            var label:String = "Available  [" + _entries.length + "]";
            if (rows > VISIBLE_ROWS) {
                label += "  scroll ↕";
            }
            _header.text = label;
            // Re-anchor close button after width may have changed (safe to leave fixed though)
            _closeBtn.x = _panelW - 22 - 4;
        }

        // -----------------------------------------------------------------------
        // Grid rendering

        private function _redrawGrid():void {
            // Clear cells
            while (_grid.numChildren > 0) _grid.removeChildAt(0);

            _emptyLabel.visible = (_entries.length == 0);
            if (_entries.length == 0) return;

            var startIdx:int = _scrollRow * COLS;
            var maxCells:int = VISIBLE_ROWS * COLS;
            var endIdx:int = Math.min(_entries.length, startIdx + maxCells);

            // Render one extra row if available so partial scroll looks smooth
            var renderEnd:int = Math.min(_entries.length, endIdx + COLS);

            for (var i:int = startIdx; i < renderEnd; i++) {
                var entry:Object = _entries[i];
                var col:int = (i - startIdx) % COLS;
                var row:int = (i - startIdx) / COLS;
                var cell:Sprite = _buildCell(entry);
                cell.x = col * (CELL_SIZE + CELL_PAD);
                cell.y = row * (CELL_SIZE + CELL_PAD);
                _grid.addChild(cell);
            }
        }

        private function _buildCell(entry:Object):Sprite {
            var cell:Sprite = new Sprite();
            cell.mouseEnabled = true;
            cell.mouseChildren = false;
            cell.buttonMode = false;

            // Cell background
            var bg:Shape = new Shape();
            bg.graphics.beginFill(0x1A1230, 0.85);
            bg.graphics.lineStyle(1, BORDER_COLOR, 0.4);
            bg.graphics.drawRoundRect(0, 0, CELL_SIZE, CELL_SIZE, 4, 4);
            bg.graphics.endFill();
            cell.addChild(bg);

            // Icon (snapshot of game's achievement MovieClip, or placeholder)
            var icon:DisplayObject = _getIconFor(entry);
            if (icon != null) {
                cell.addChild(icon);
            }

            // Hover handlers — use entry data captured via closure
            var capName:String = entry.name;
            var capDesc:String = entry.description;
            cell.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
                _showTooltip(capName, capDesc, cell.x, cell.y);
            }, false, 0, true);
            cell.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
                _hideTooltip();
            }, false, 0, true);

            return cell;
        }

        private function _getIconFor(entry:Object):DisplayObject {
            var gameId:int = int(entry.gameId);
            if (gameId < 0) return _placeholderFor(entry.name);

            var bd:BitmapData = _iconCache[gameId] as BitmapData;
            if (bd == null) bd = _snapshotIcon(gameId);
            if (bd == null) return _placeholderFor(entry.name);

            var bm:Bitmap = new Bitmap(bd);
            bm.smoothing = true;
            // Fit inside cell minus a small margin
            var margin:int = 4;
            var avail:Number = CELL_SIZE - margin * 2;
            var scale:Number = Math.min(avail / bd.width, avail / bd.height);
            if (scale > 1) scale = 1;
            bm.scaleX = bm.scaleY = scale;
            bm.x = (CELL_SIZE - bm.width) * 0.5;
            bm.y = (CELL_SIZE - bm.height) * 0.5;
            return bm;
        }

        private function _snapshotIcon(gameId:int):BitmapData {
            try {
                if (GV.achiCollection == null) return null;
                var ach:* = null;
                if (GV.achiCollection.achisById != null) {
                    ach = GV.achiCollection.achisById[gameId];
                }
                if (ach == null && GV.achiCollection.achisByOrder != null) {
                    var arr:Array = GV.achiCollection.achisByOrder;
                    for (var i:int = 0; i < arr.length; i++) {
                        if (arr[i] != null && int(arr[i].id) == gameId) {
                            ach = arr[i];
                            break;
                        }
                    }
                }
                if (ach == null) return null;

                var src:DisplayObject = null;
                if (ach.hasOwnProperty("mc")     && ach["mc"]     != null) src = ach["mc"]     as DisplayObject;
                if (src == null && ach.hasOwnProperty("mcAchi") && ach["mcAchi"] != null) src = ach["mcAchi"] as DisplayObject;
                if (src == null && ach.hasOwnProperty("icon")   && ach["icon"]   != null) src = ach["icon"]   as DisplayObject;
                if (src == null) return null;

                var b:Rectangle = src.getBounds(src);
                var w:int = Math.max(1, Math.ceil(b.width));
                var h:int = Math.max(1, Math.ceil(b.height));
                if (w > 256) w = 256;
                if (h > 256) h = 256;

                var bd:BitmapData = new BitmapData(w, h, true, 0x00000000);
                var m:Matrix = new Matrix();
                m.translate(-b.x, -b.y);
                bd.draw(src, m);
                _iconCache[gameId] = bd;
                return bd;
            } catch (e:Error) {
                if (_logger != null) _logger.log(_modName, "Achievement icon snapshot failed for gameId=" + gameId + ": " + e.message);
            }
            return null;
        }

        private function _placeholderFor(name:String):DisplayObject {
            var s:Sprite = new Sprite();
            s.mouseEnabled = false;
            s.mouseChildren = false;
            var bg:Shape = new Shape();
            bg.graphics.beginFill(PLACEHOLDER_BG, 0.9);
            bg.graphics.drawRoundRect(4, 4, CELL_SIZE - 8, CELL_SIZE - 8, 4, 4);
            bg.graphics.endFill();
            s.addChild(bg);

            var fmt:TextFormat = new TextFormat(FONT, 16);
            fmt.bold = true;
            fmt.align = TextFormatAlign.CENTER;
            var tf:TextField = new TextField();
            tf.mouseEnabled = false;
            tf.selectable = false;
            tf.embedFonts = false;
            tf.antiAliasType = AntiAliasType.ADVANCED;
            tf.defaultTextFormat = fmt;
            tf.autoSize = TextFieldAutoSize.CENTER;
            tf.textColor = PLACEHOLDER_TXT;
            tf.text = _initials(name);
            tf.x = (CELL_SIZE - tf.width) * 0.5;
            tf.y = (CELL_SIZE - tf.height) * 0.5;
            s.addChild(tf);
            return s;
        }

        private function _initials(name:String):String {
            if (name == null || name.length == 0) return "?";
            var words:Array = name.split(/\s+/);
            if (words.length >= 2 && String(words[1]).length > 0) {
                return String(words[0]).charAt(0).toUpperCase() + String(words[1]).charAt(0).toUpperCase();
            }
            return name.charAt(0).toUpperCase();
        }

        // -----------------------------------------------------------------------
        // Tooltip + scroll

        private function _showTooltip(name:String, description:String, gridX:Number, gridY:Number):void {
            var text:String = name;
            if (description != null && description.length > 0) {
                text += "\n" + description;
            }
            _tooltip.text = text;
            // Anchor below the hovered cell, clamped inside the panel
            var px:Number = _grid.x + gridX;
            var py:Number = _grid.y + gridY + CELL_SIZE + 2;
            if (px + _tooltip.width > _panelW - 4) px = _panelW - _tooltip.width - 4;
            if (px < 4) px = 4;
            if (py + _tooltip.height > _panelH - 2) {
                // Flip above the cell
                py = _grid.y + gridY - _tooltip.height - 2;
            }
            _tooltip.x = px;
            _tooltip.y = py;
            _tooltip.visible = true;
        }

        private function _hideTooltip():void {
            _tooltip.visible = false;
        }

        private function _onWheel(e:MouseEvent):void {
            var rows:int = Math.ceil(_entries.length / Number(COLS));
            var maxRow:int = Math.max(0, rows - VISIBLE_ROWS);
            if (maxRow == 0) return;
            _scrollRow += e.delta > 0 ? -SCROLL_STEP : SCROLL_STEP;
            if (_scrollRow < 0) _scrollRow = 0;
            if (_scrollRow > maxRow) _scrollRow = maxRow;
            _hideTooltip();
            _refreshHeader();
            _redrawGrid();
        }
    }
}
