package ui {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.SB;
    import com.giab.games.gcfw.constants.SelectorScreenStatus;
    import com.giab.games.gcfw.entity.TalismanFragment;
    import com.giab.games.gcfw.utils.TalFragBitmapCreator;
    import com.giab.common.utils.NumberFormatter;

    import unlockers.TalismanUnlocker;

    /**
     * "AP Shop" — a hover popup on the talisman screen that lets the player buy
     * the 25 AP "perfect placement" talisman fragments with shadow cores.
     *
     * A 4th square icon button is injected next to the three existing bottom-row
     * buttons (Sum / Ctrl / Shape Collection). Hovering it opens a popup above
     * the button showing the perfect-placement grid; the popup stays open until
     * the mouse leaves the combined button+popup area. Clicking a talisman buys
     * it — costing exactly what selling it would refund (its sellValue) — and
     * drops it into the talisman inventory for the player to place manually.
     *
     * Design decisions (locked with the user):
     *   - The full 25-slot grid is always shown; slots for fragments not yet
     *     received from AP render as a blank "Locked" jigsaw piece.
     *   - One of each: a received fragment is buyable once (net-zero vs selling,
     *     so no exploit), then shows "Owned" until sold.
     *   - Bought fragments go to the inventory; placement is the player's choice.
     *
     * The talisman panel drives its own hover/click via coordinate math (not
     * display hit-testing), so this class:
     *   - suppresses vanilla hover over the popup by parking pnlTalisman's
     *     lastZone rect over the popup while it's open, and
     *   - blocks vanilla mouse-downs inside the popup with a capture-phase
     *     stage listener (so a click can't grab a fragment / unlock a slot
     *     behind the popup). The cell CLICK still fires normally.
     */
    public class TalismanShop {

        // Fragments are sold/shown at base (no upgrades) — the player upgrades
        // them in-game. The apworld ships each fragment's original upgrade
        // level in tal_data; we ignore it and force level 0 here.
        private static const SHOP_UPGRADE_LEVEL:int = 0;

        // Popup layout
        private static const CELL_W:Number    = 66;
        private static const CELL_H:Number    = 62;
        private static const GRID_PAD:Number  = 16;
        private static const TITLE_H:Number   = 56;   // title + subtext band
        private static const FRAG_W:Number    = 104; // TalFragBitmapCreator.rectInInventory
        private static const FRAG_H:Number    = 90;

        private static const COL_BG:uint      = 0x0E0E10;
        private static const COL_BORDER:uint  = 0x8A7A55;
        private static const COL_TITLE:uint   = 0xDEB349;
        private static const COL_SUB:uint     = 0xB9A88A;
        private static const COL_COST:uint    = 0xE8C86A;
        private static const COL_COST_LOW:uint = 0xC08A5A;
        private static const COL_OWNED:uint   = 0x7CA87C;
        private static const COL_LOCKED:uint      = 0x2A2A30; // blank jigsaw fill
        private static const COL_LOCKED_EDGE:uint = 0x4A4A52; // blank jigsaw outline
        private static const FONT:String      = "Celtic Garamond for GemCraft";

        [Embed(source='../images/IconColorSmall.png')]
        private static const ApIcon:Class;

        private var _logger:Logger;
        private var _modName:String;
        private var _talismanUnlocker:TalismanUnlocker;

        private var _btn:Sprite;
        private var _btnW:Number = 72;
        private var _btnH:Number = 72;
        private var _popup:Sprite;
        private var _open:Boolean = false;

        /** True while the shop popup is open. The fragment-tooltip overlay skips
         *  its work when the shop is up — the shop drives its own fragment
         *  tooltips and parks the vanilla hover zone. */
        public function get isOpen():Boolean { return _open; }

        // Cells of the currently-built popup, for frame-driven positional hover
        // (robust to rebuilds — rollover events get lost when the grid is
        // rebuilt under a stationary pointer). Each: {frag, entry, x, y, w, h}.
        private var _cells:Array = [];
        private var _hoveredKey:String = null;
        // True only while WE have a fragment tooltip attached to the shared
        // GV.mcInfoPanel. Guards _hideTooltip so we never rip out the game's own
        // info panel (e.g. the in-battle gem/wall/monster tooltip) — the selector
        // frame loop runs during battle too, so an unconditional removeChild here
        // stripped every battle tooltip every frame.
        private var _tooltipShown:Boolean = false;

        private var _injectedMc:*;            // the McPnlTalisman we injected into
        private var _captureAdded:Boolean = false;

        public function TalismanShop(logger:Logger, modName:String,
                                     talismanUnlocker:TalismanUnlocker) {
            _logger           = logger;
            _modName          = modName;
            _talismanUnlocker = talismanUnlocker;
        }

        private function log(msg:String):void {
            if (_logger != null) _logger.log(_modName, "[TalismanShop] " + msg);
        }

        // -----------------------------------------------------------------------
        // Per-frame driver (called from ArchipelagoMod.selectorFrame)

        public function onSelectorFrame():void {
            var pnl:* = (GV.selectorCore != null) ? GV.selectorCore.pnlTalisman : null;
            if (pnl == null || pnl.mc == null) {
                _closePopup(null);
                return;
            }
            var status:int = GV.selectorCore.screenStatus;
            var idle:Boolean = status == SelectorScreenStatus.TALISMAN_IDLE_SETTINGS
                            || status == SelectorScreenStatus.TALISMAN_IDLE_STAGES;

            _ensureButton(pnl);

            if (!idle) {
                _closePopup(pnl);
                return;
            }
            _updateHover(pnl);
        }

        /** Tear down fully — remove popup, button and stage listener. Called on
         *  AP-mode deactivation and mod unload so nothing lingers into a
         *  standalone (non-AP) session. */
        public function dispose():void {
            _closePopup(null);
            if (_btn != null && _btn.parent != null) {
                _btn.parent.removeChild(_btn);
            }
            if (_captureAdded && GV.main != null && GV.main.stage != null) {
                GV.main.stage.removeEventListener(MouseEvent.MOUSE_DOWN, _onCaptureDown, true);
            }
            _captureAdded = false;
            _injectedMc   = null;
            _btn = null;
        }

        // -----------------------------------------------------------------------
        // Button injection

        private function _ensureButton(pnl:*):void {
            if (_injectedMc === pnl.mc && _btn != null && _btn.parent != null) return;
            try {
                _buildButton(pnl);
                _injectedMc = pnl.mc;
                if (!_captureAdded && GV.main != null && GV.main.stage != null) {
                    // Capture phase, high priority — runs before pnlTalisman's
                    // own capture-phase MOUSE_DOWN on its mc.
                    GV.main.stage.addEventListener(
                        MouseEvent.MOUSE_DOWN, _onCaptureDown, true, 1000, true);
                    _captureAdded = true;
                }
            } catch (e:Error) {
                log("button build failed: " + e.message);
            }
        }

        private function _buildButton(pnl:*):void {
            var tmpl:*  = pnl.mc.btnShowShapeCollection;
            var ctrl:*  = pnl.mc.btnShowUpgLevsAndRarities;
            if (tmpl == null) return;

            // Snapshot the shape-collection button to reuse its exact frame art,
            // then hide its 3x3 icon so we can lay the AP logo on top. Rather than
            // a flat black box (which reads as a stark inset and — by leaving a
            // gap to the frame — exposes the frame's light inner bevel as an ugly
            // "white border"), we fill with the frame's OWN dark stone-interior
            // tone, sampled from the snapshot. The cover then blends seamlessly:
            // it looks like an empty version of the vanilla frame, matching the
            // sibling buttons. The cover is composited INTO the bitmap because
            // Sprite.graphics always renders beneath child bitmaps. Draw via the
            // button's own bounds so a non-zero symbol origin doesn't clip the
            // snapshot.
            var b:Rectangle = tmpl.getBounds(tmpl);
            _btnW = b.width;
            _btnH = b.height;
            var m:Matrix = new Matrix();
            m.translate(-b.x, -b.y);
            var bd:BitmapData = new BitmapData(Math.max(1, Math.ceil(_btnW)),
                                               Math.max(1, Math.ceil(_btnH)), true, 0);
            bd.draw(tmpl, m);
            var interior:uint = _sampleInteriorFill(bd);
            var cover:Shape = new Shape();
            cover.graphics.beginFill(interior, 1);
            // Reach fully to the frame's inner edge (small inset, generous radius)
            // so no light-bevel ring survives around the cover.
            cover.graphics.drawRoundRect(6, 6, _btnW - 12, _btnH - 12, 12, 12);
            cover.graphics.endFill();
            bd.draw(cover);

            _btn = new Sprite();
            _btn.addChild(new Bitmap(bd, "auto", true));

            var icon:Bitmap = new ApIcon() as Bitmap;
            icon.smoothing = true;
            // Sit the balls in the frame opening at the size the vanilla symbols
            // occupy (previously -24 left them small with a wide empty margin).
            var iSize:Number = Math.min(_btnW, _btnH) - 16;
            icon.width  = iSize;
            icon.height = iSize;
            icon.x = (_btnW - iSize) / 2;
            icon.y = (_btnH - iSize) / 2;
            _btn.addChild(icon);

            // Place one inter-button step to the right of the shape button.
            // b.x/b.y map the snapshot's top-left back onto the button origin so
            // it lines up regardless of where the symbol's registration point is.
            _btn.x = tmpl.x + (tmpl.x - ctrl.x) + b.x;
            _btn.y = tmpl.y + b.y;
            _btn.buttonMode    = true;
            _btn.mouseChildren = false;
            _btn.useHandCursor = true;
            _btn.addEventListener(MouseEvent.MOUSE_OVER, _onBtnOver, false, 0, true);
            _btn.addEventListener(MouseEvent.MOUSE_OUT,  _onBtnOut,  false, 0, true);

            pnl.mc.addChild(_btn);
            log("button injected at x=" + _btn.x + " y=" + _btn.y);
        }

        /**
         * Sample the frame's dark stone-interior tone from the button snapshot so
         * the icon-cover blends with the vanilla frame instead of reading as a
         * flat black box. Scans a grid of points across the interior (skipping the
         * outer frame border) and returns the DARKEST opaque pixel — the icon's
         * line-art is light, so the darkest sample is reliably the background
         * stone shadow we want to match.
         */
        private function _sampleInteriorFill(bd:BitmapData):uint {
            var w:int = bd.width;
            var h:int = bd.height;
            var x0:int = Math.floor(w * 0.28);
            var x1:int = Math.ceil(w * 0.72);
            var y0:int = Math.floor(h * 0.28);
            var y1:int = Math.ceil(h * 0.72);
            var best:uint = 0x141416;   // fallback matches the old flat fill
            var bestLuma:Number = Number.MAX_VALUE;
            for (var y:int = y0; y <= y1; y += 3) {
                for (var x:int = x0; x <= x1; x += 3) {
                    var px:uint = bd.getPixel32(x, y);
                    if ((px >>> 24) < 200) continue; // skip transparent / edge AA
                    var r:int = (px >> 16) & 0xFF;
                    var g:int = (px >> 8) & 0xFF;
                    var bl:int = px & 0xFF;
                    var luma:Number = 0.299 * r + 0.587 * g + 0.114 * bl;
                    if (luma < bestLuma) {
                        bestLuma = luma;
                        best = px & 0xFFFFFF;
                    }
                }
            }
            return best;
        }

        private function _onBtnOver(e:MouseEvent):void {
            _btn.filters = [_brightness(1.4)];
        }

        private function _onBtnOut(e:MouseEvent):void {
            _btn.filters = [];
        }

        private function _brightness(s:Number):ColorMatrixFilter {
            return new ColorMatrixFilter([
                s,0,0,0,0, 0,s,0,0,0, 0,0,s,0,0, 0,0,0,1,0]);
        }

        // -----------------------------------------------------------------------
        // Hover open/close

        private function _updateHover(pnl:*):void {
            if (_btn == null) return;
            var mx:Number = pnl.mc.mouseX;
            var my:Number = pnl.mc.mouseY;
            var overBtn:Boolean = _inRect(mx, my, _btn.x, _btn.y, _btnW, _btnH);

            if (!_open) {
                if (overBtn) _openPopup(pnl);
                return;
            }

            // Open: keep alive while the mouse is within the union bbox of the
            // button and the popup (this naturally bridges the gap between them).
            var minX:Number = Math.min(_btn.x, _popup.x);
            var minY:Number = Math.min(_btn.y, _popup.y);
            var maxX:Number = Math.max(_btn.x + _btnW, _popup.x + _popup.width);
            var maxY:Number = Math.max(_btn.y + _btnH, _popup.y + _popup.height);
            var inUnion:Boolean = _inRect(mx, my, minX, minY, maxX - minX, maxY - minY);

            if (!inUnion) {
                _closePopup(pnl);
                return;
            }
            // Suppress vanilla hover across the whole popup, then drive our own
            // tooltip by hit-testing the mouse against the cell rects.
            _suppressVanillaHover(pnl, minX, minY, maxX, maxY);
            _updateTooltip();
        }

        /**
         * Frame-driven tooltip: figure out which cell the mouse is over (in
         * popup-local coords) and show that fragment's vanilla info panel. Only
         * re-renders when the hovered cell changes. Robust to popup rebuilds
         * because it doesn't depend on rollover events.
         */
        private function _updateTooltip():void {
            if (!_open || _popup == null) return;
            var lx:Number = _popup.mouseX;
            var ly:Number = _popup.mouseY;
            var hit:Object = null;
            for each (var c:Object in _cells) {
                if (lx >= c.x && lx <= c.x + c.w && ly >= c.y && ly <= c.y + c.h) {
                    hit = c;
                    break;
                }
            }
            var key:String = (hit != null) ? String(hit.entry.apId) : null;
            if (key == _hoveredKey) return;
            _hoveredKey = key;
            _hideTooltip();
            if (hit == null) return;
            try {
                if (hit.frag != null) {
                    GV.selectorCore.pnlTalisman.renderInfoPanelFragment(hit.frag);
                } else {
                    // Locked slot — a short "not yet received" note.
                    var vIp:* = GV.mcInfoPanel;
                    vIp.reset(300);
                    vIp.addTextfield(COL_SUB, "Locked", false, 12);
                    vIp.addTextfield(0x9A9A9A,
                        "Not yet received from Archipelago.", false, 11);
                    GV.main.cntInfoPanel.addChild(vIp);
                    vIp.doEnterFrame();
                }
                _tooltipShown = true; // we now own the shared panel
            } catch (e:Error) {}
        }

        /** True if a fragment with this seed is already in the inventory or a
         *  talisman slot — used to enforce one-of-each in the shop. */
        private function _isOwned(seed:int):Boolean {
            if (GV.ppd == null) return false;
            var arrays:Array = [GV.ppd.talismanInventory, GV.ppd.talismanSlots];
            for each (var arr:Array in arrays) {
                if (arr == null) continue;
                for (var i:int = 0; i < arr.length; i++) {
                    var f:* = arr[i];
                    if (f != null && TalismanFragment(f).seed == seed) return true;
                }
            }
            return false;
        }

        private function _inRect(px:Number, py:Number,
                                 x:Number, y:Number, w:Number, h:Number):Boolean {
            return px >= x && px <= x + w && py >= y && py <= y + h;
        }

        /**
         * Park pnlTalisman.lastZone over the popup so its per-frame
         * renderInfoPanel() early-outs instead of drawing slot tooltips behind
         * our popup or wiping our own tooltip.
         *
         * Vanilla compares against mc.root.mouseX/Y — the game's letterboxed &
         * zoomed root space, NOT stage space. So we convert the popup bounds
         * popup-local → stage (localToGlobal) → root-local (globalToLocal) to
         * land in the exact space vanilla tests against.
         */
        private function _suppressVanillaHover(pnl:*, minX:Number, minY:Number,
                                               maxX:Number, maxY:Number):void {
            try {
                var rootObj:* = pnl.mc.root;
                if (rootObj == null) return;
                var tl:Point = rootObj.globalToLocal(pnl.mc.localToGlobal(new Point(minX, minY)));
                var br:Point = rootObj.globalToLocal(pnl.mc.localToGlobal(new Point(maxX, maxY)));
                pnl.lastZoneXMin = tl.x;
                pnl.lastZoneYMin = tl.y;
                pnl.lastZoneXMax = br.x;
                pnl.lastZoneYMax = br.y;
            } catch (e:Error) {}
        }

        // -----------------------------------------------------------------------
        // Popup

        private function _openPopup(pnl:*):void {
            _buildPopup(pnl);
            if (_popup == null) return;

            // Position: horizontally centred on the button, sitting just above it.
            var cx:Number = _btn.x + _btnW / 2;
            var px:Number = cx - _popup.width / 2;
            px = Math.max(8, Math.min(px, 1920 - _popup.width - 8));
            _popup.x = px;
            _popup.y = _btn.y - _popup.height - 8;

            pnl.mc.addChild(_popup); // above the talisman contents
            _open = true;
        }

        private function _closePopup(pnl:*):void {
            _hideTooltip();
            if (_popup != null && _popup.parent != null) {
                _popup.parent.removeChild(_popup);
            }
            _popup = null;
            _cells = [];
            _hoveredKey = null;
            if (_open && pnl != null) {
                // Let vanilla hover resume next frame.
                try { pnl.lastZoneXMin = NaN; } catch (e:Error) {}
            }
            _open = false;
        }

        private function _buildPopup(pnl:*):void {
            // Always the full 25-slot grid; not-yet-received slots render locked.
            var entries:Array = _talismanUnlocker.getCatalogEntries();

            var pw:Number = GRID_PAD * 2 + 5 * CELL_W;
            var ph:Number = TITLE_H + GRID_PAD * 2 + 5 * CELL_H;

            _cells = [];
            _hoveredKey = null;

            _popup = new Sprite();
            _popup.mouseEnabled  = true;   // swallow background clicks
            _popup.graphics.beginFill(COL_BG, 0.96);
            _popup.graphics.lineStyle(2, COL_BORDER, 1);
            _popup.graphics.drawRoundRect(0, 0, pw, ph, 14, 14);
            _popup.graphics.endFill();

            var title:TextField = _makeText("AP Shop", 20, COL_TITLE, true, pw);
            title.x = 0;
            title.y = 6;
            _popup.addChild(title);

            var sub:TextField = _makeText(
                "Buy one of each talisman for the shadow-core cost shown below.",
                12, COL_SUB, false, pw - 20);
            sub.x = 10;
            sub.y = 32;
            _popup.addChild(sub);

            if (entries.length == 0) {
                var empty:TextField = _makeText(
                    "Connect to Archipelago to populate the shop.",
                    13, COL_COST_LOW, false, pw - 20);
                empty.x = 10;
                empty.y = TITLE_H + 10;
                _popup.addChild(empty);
                return;
            }

            for each (var entry:Object in entries) {
                _popup.addChild(_makeCell(pnl, entry, pw, ph));
            }
        }

        /**
         * One grid cell. Three states:
         *   - locked   (not received from AP): blank jigsaw + "Locked"
         *   - buyable  (received, not owned):   fragment + cost, click to buy
         *   - owned    (in inventory / socket): fragment dimmed + "Owned"
         * Own scope keeps `entry` captured for the click closure.
         */
        private function _makeCell(pnl:*, entry:Object, pw:Number, ph:Number):Sprite {
            var slot:int = int(entry.slot);
            var col:int  = slot % 5;
            var row:int  = int(slot / 5);
            var cellX:Number = GRID_PAD + col * CELL_W;
            var cellY:Number = TITLE_H + GRID_PAD + row * CELL_H;
            var received:Boolean = entry.received == true;

            var cell:Sprite = new Sprite();
            cell.x = cellX;
            cell.y = cellY;
            cell.mouseChildren = false;

            // faint cell backing so the whole cell is a hit target
            cell.graphics.beginFill(0xFFFFFF, 0.04);
            cell.graphics.drawRoundRect(0, 0, CELL_W - 4, CELL_H - 4, 6, 6);
            cell.graphics.endFill();

            var labelTf:TextField;
            var frag:TalismanFragment = null;

            if (!received) {
                // Locked slot — generic blank jigsaw so the grid stays visible
                // without revealing which fragment it is.
                _drawJigsaw(cell.graphics, (CELL_W - 4) / 2, (CELL_H - 4) / 2 - 4,
                            Math.min(CELL_W, CELL_H) - 22, COL_LOCKED);
                labelTf = _makeText("Locked", 12, COL_SUB, false, CELL_W - 4);
            } else {
                frag = new TalismanFragment(
                    entry.seed, entry.rarity, entry.type, SHOP_UPGRADE_LEVEL);
                GV.talFragBitmapCreator.giveTalFragBitmaps(frag);
                var cost:int = frag.sellValue.g();
                var owned:Boolean = _isOwned(int(entry.seed));

                var fbd:BitmapData = new BitmapData(FRAG_W, FRAG_H, true, 0);
                fbd.copyPixels(frag.bmpInInventory.bitmapData,
                               TalFragBitmapCreator.rectInInventory,
                               TalFragBitmapCreator.ptZero);
                var img:Bitmap = new Bitmap(fbd, "auto", true);
                var imgScale:Number = (CELL_W - 12) / FRAG_W;
                img.scaleX = img.scaleY = imgScale;
                img.x = (CELL_W - 4 - img.width) / 2;
                img.y = 2;
                img.alpha = owned ? 0.35 : 1;
                cell.addChild(img);

                if (owned) {
                    labelTf = _makeText("Owned", 12, COL_OWNED, true, CELL_W - 4);
                } else {
                    var canAfford:Boolean = (GV.ppd != null) && GV.ppd.shadowCoreAmount.g() >= cost;
                    labelTf = _makeText(NumberFormatter.format(cost), 12,
                                        canAfford ? COL_COST : COL_COST_LOW, true, CELL_W - 4);
                    cell.buttonMode    = true;
                    cell.useHandCursor = true;
                    cell.addEventListener(MouseEvent.CLICK,
                        function(e:MouseEvent):void { _buy(entry); }, false, 0, true);
                }
            }

            labelTf.x = 0;
            labelTf.y = CELL_H - 22;
            cell.addChild(labelTf);

            // Register for frame-driven hover hit-testing (frag null = locked).
            _cells.push({ frag: frag, entry: entry, received: received,
                          x: cellX, y: cellY, w: CELL_W - 4, h: CELL_H - 4 });

            return cell;
        }

        /**
         * Draw a simple, generic jigsaw-piece silhouette centred at (cx, cy):
         * a rounded-square body with a tab bump on the top and right edges.
         * Used for locked (not-yet-received) shop slots.
         */
        private function _drawJigsaw(g:*, cx:Number, cy:Number, s:Number, color:uint):void {
            var b:Number = s * 0.62;   // body side
            var r:Number = s * 0.13;   // tab radius
            var x0:Number = cx - b / 2;
            var y0:Number = cy - b / 2;
            g.lineStyle(1.5, COL_LOCKED_EDGE, 1);
            g.beginFill(color, 1);
            g.drawRoundRect(x0, y0, b, b, 5, 5);
            g.drawCircle(cx, y0, r);          // top tab
            g.drawCircle(x0 + b, cy, r);      // right tab
            g.endFill();
        }

        // -----------------------------------------------------------------------
        // Buying

        private function _buy(entry:Object):void {
            var pnl:* = (GV.selectorCore != null) ? GV.selectorCore.pnlTalisman : null;
            if (pnl == null || GV.ppd == null) return;

            var inv:Array = GV.ppd.talismanInventory;
            if (inv == null) return;

            // One of each: refuse if this talisman is already owned (in the
            // inventory or socketed).
            if (_isOwned(int(entry.seed))) {
                _floatWarn("Already owned");
                SB.playSound("sndalert");
                return;
            }

            var frag:TalismanFragment = new TalismanFragment(
                entry.seed, entry.rarity, entry.type, SHOP_UPGRADE_LEVEL);
            var cost:int = frag.sellValue.g();

            // first empty inventory slot
            var slotIdx:int = -1;
            for (var i:int = 0; i < inv.length; i++) {
                if (inv[i] == null) { slotIdx = i; break; }
            }
            if (slotIdx < 0) {
                _floatWarn("Talisman inventory full");
                SB.playSound("sndalert");
                return;
            }
            if (GV.ppd.shadowCoreAmount.g() < cost) {
                _floatWarn("Not enough shadow cores");
                SB.playSound("sndalert");
                try { GV.selectorCore.mc.mcShadowCoreCounter.xEnergy = 10; } catch (e:Error) {}
                return;
            }

            GV.ppd.shadowCoreAmount.s(GV.ppd.shadowCoreAmount.g() - cost);
            GV.selectorCore.renderer.updateShadowCoreCounter(GV.ppd.shadowCoreAmount.g());

            GV.talFragBitmapCreator.giveTalFragBitmaps(frag);
            inv[slotIdx] = frag;
            frag.showInInventory();
            frag.mc.x = pnl.invXs[slotIdx] + 3;
            frag.mc.y = frag.dropAnimTargetY = pnl.invYs[slotIdx] + 11;
            pnl.mc.cntFragments.addChild(frag.mc);
            pnl.dirtyFlag = true;

            SB.playSound("sndtalismanfragmentinventory");
            GV.vfxEngine.createFloatingText4(
                GV.main.mouseX, GV.main.mouseY - 20,
                "-" + NumberFormatter.format(cost) + " shadow cores",
                0xFF6B6B, 14, "center",
                Math.random() * 2 - 1, -3.5 - Math.random(), 0, 0.2, 34, 0, 1000);

            // refresh cost colours (afford state may have changed)
            _refreshPopup(pnl);
        }

        private function _refreshPopup(pnl:*):void {
            if (!_open) return;
            var oldX:Number = (_popup != null) ? _popup.x : 0;
            var oldY:Number = (_popup != null) ? _popup.y : 0;
            _hideTooltip();
            if (_popup != null && _popup.parent != null) _popup.parent.removeChild(_popup);
            _buildPopup(pnl);
            if (_popup == null) return;
            _popup.x = oldX;
            _popup.y = oldY;
            pnl.mc.addChild(_popup);
        }

        private function _floatWarn(text:String):void {
            GV.vfxEngine.createFloatingText4(
                GV.main.mouseX, GV.main.mouseY - 20, text,
                0xFF9797, 14, "center",
                Math.random() * 2 - 1, -3.5 - Math.random(), 0, 0.2, 34, 0, 1000);
        }

        // -----------------------------------------------------------------------
        // Tooltip (reuses the vanilla fragment info panel; see _updateTooltip)

        private function _hideTooltip():void {
            if (!_tooltipShown) return; // never touch the panel unless WE showed it
            _tooltipShown = false;
            try { GV.main.cntInfoPanel.removeChild(GV.mcInfoPanel); } catch (e:Error) {}
        }

        // -----------------------------------------------------------------------
        // Block vanilla mouse-downs anywhere under the shop window

        /**
         * Capture-phase (fires before pnlTalisman's own capture MOUSE_DOWN on
         * its mc), so while the shop is open we stopImmediatePropagation() for
         * any press within the full button+popup union — nothing behind the
         * window reacts (no fragment grab, no slot unlock). Our cells' CLICK
         * still fires; Flash synthesizes it from the press/release hit-test
         * independently of the swallowed MOUSE_DOWN.
         *
         * Uses pnl.mc-local coords (the exact space _updateHover works in)
         * rather than hitTestPoint/stage coords, and covers the whole union
         * (popup + button + the bridge gap between them) so there are no seams
         * a click can slip through.
         */
        private function _onCaptureDown(e:MouseEvent):void {
            if (!_open || _popup == null || _btn == null) return;
            try {
                var pnl:* = (GV.selectorCore != null) ? GV.selectorCore.pnlTalisman : null;
                if (pnl == null || pnl.mc == null) return;
                // Hard guard: only ever swallow a press while the talisman
                // screen is genuinely the active idle screen. If the shop's
                // _open flag were ever stale (e.g. another panel like the debug
                // menu is up), this ensures we NEVER eat that panel's clicks.
                var status:int = GV.selectorCore.screenStatus;
                if (status != SelectorScreenStatus.TALISMAN_IDLE_SETTINGS
                        && status != SelectorScreenStatus.TALISMAN_IDLE_STAGES) {
                    return;
                }
                var mx:Number = pnl.mc.mouseX;
                var my:Number = pnl.mc.mouseY;
                var minX:Number = Math.min(_btn.x, _popup.x);
                var minY:Number = Math.min(_btn.y, _popup.y);
                var maxX:Number = Math.max(_btn.x + _btnW, _popup.x + _popup.width);
                var maxY:Number = Math.max(_btn.y + _btnH, _popup.y + _popup.height);
                if (_inRect(mx, my, minX, minY, maxX - minX, maxY - minY)) {
                    // stopPropagation (NOT stopImmediatePropagation): this still
                    // blocks pnlTalisman's capture MOUSE_DOWN (it's a descendant
                    // of the stage, so halting descent here prevents it), but it
                    // leaves the game's OWN stage-level input handlers intact.
                    // stopImmediatePropagation would also kill those, which could
                    // desync global input state (e.g. GV.pressedButton) and leave
                    // input dead in a later menu.
                    e.stopPropagation();
                }
            } catch (err:Error) {}
        }

        // -----------------------------------------------------------------------
        // Text helper (device font, matches the mod's other custom UI)

        private function _makeText(text:String, size:int, color:uint,
                                   bold:Boolean, width:Number):TextField {
            var fmt:TextFormat = new TextFormat(FONT, size, color, bold);
            fmt.align = TextFormatAlign.CENTER;
            var tf:TextField = new TextField();
            tf.defaultTextFormat = fmt;
            tf.embedFonts   = false;
            tf.selectable   = false;
            tf.mouseEnabled = false;
            tf.autoSize     = TextFieldAutoSize.NONE;
            tf.width        = width;
            tf.height       = size + 10;
            tf.text         = text;
            return tf;
        }
    }
}
