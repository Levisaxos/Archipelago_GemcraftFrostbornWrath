package ui {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.SB;

    /**
     * Lifecycle wrapper around the McOfflineItems chrome — same shape as
     * ScrDebugOptions / ScrSlotSettings:
     *
     *   open  → addChild to GV.main, ScrollablePanel.attach + addWheelListener
     *   close → removeChild, removeWheelListener
     *   doEnterFrame → ScrollablePanel.doEnterFrame + reveal stagger
     *
     * Adds the offline-items-specific behavior on top:
     *   - populate(entries) builds the icon grid via McOfflineItems
     *   - 7-frame staggered reveal (alpha 0→1 + glow halo) so icons "pop"
     *     into view in the same rhythm as the level-end spoils screen
     *   - autoscroll to keep the most-recently-revealed row in view
     */
    public class OfflineItemsPanel {

        private static const REVEAL_TICK_FRAMES:int = 7;
        // Vanilla VfxGlowingMc lifetime for createDropIconAppearingGlow is 6
        // frames. Match that here so the flash feels identical.
        private static const GLOW_LIFE_FRAMES:int   = 6;
        private static const CELL_SIZE:Number       = 140;

        private var _mc:McOfflineItems;
        private var _scroll:ScrollablePanel;
        private var _stage:Stage;
        private var _isOpen:Boolean = false;

        // Reveal state
        private var _revealedCount:int = 0;
        private var _revealTimer:int   = 0;
        private var _glows:Array;

        /** Called once the panel is removed from stage. */
        public var onClosed:Function;

        /**
         * Optional callback invoked from each cell's MOUSE_OVER. Signature:
         *   function(vIp:*, apId:int):Boolean
         * Should populate vIp via reset/addTextfield (or call a vanilla
         * renderer like pnlTalisman.renderInfoPanelFragment) and return
         * true to indicate the title text was rendered. Returning false
         * (or leaving this null) makes McOfflineItems fall back to a
         * generic "Received <name>" title using the cell's stored fields.
         *
         * The "Received from <player>" line is always appended afterwards
         * by McOfflineItems if cell.sender is non-null, regardless of
         * whether this callback fired.
         */
        public var tooltipRenderer:Function;

        public function OfflineItemsPanel() {
            _scroll = new ScrollablePanel();
            _glows  = [];
        }

        public function get isShowing():Boolean { return _isOpen; }

        // -----------------------------------------------------------------------
        // Public API

        /**
         * Open the panel populated with the given entries.
         * @param stg     The stage (kept so we can attach the keyboard listener).
         * @param entries Array of { apId, name, sender }.
         */
        public function show(stg:Stage, entries:Array):void {
            if (_isOpen) return;
            if (entries == null || entries.length == 0) return;
            if (GV.main == null) return;

            _stage = stg;
            if (_mc == null) _mc = new McOfflineItems();

            // Forward the tooltip renderer to the view so each cell can dispatch
            // to ArchipelagoMod-owned rendering on hover.
            _mc.tooltipRenderer = tooltipRenderer;

            _mc.setTitle("Items received while away (" + entries.length + ")");
            _mc.populate(entries);

            // Wire scrollbar / close after populate so arrCntContents is correct.
            _scroll.attach(_mc, close);

            GV.main.addChildAt(_mc, GV.main.numChildren);

            // Keep the tooltip layer (cntInfoPanel) above our panel so that
            // GV.mcInfoPanel — added to cntInfoPanel by hover handlers —
            // renders ON TOP of the grid instead of being hidden behind it.
            try {
                var infoLayer:* = GV.main.cntInfoPanel;
                if (infoLayer != null && infoLayer.parent == GV.main) {
                    GV.main.setChildIndex(infoLayer, GV.main.numChildren - 1);
                }
            } catch (eIp:Error) { /* layer not present yet — fine */ }

            _scroll.addWheelListener();
            _scroll.renderViewport();

            // ESC closes the panel.
            if (_stage != null) {
                _stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown, false, 0, true);
            }

            // Reset reveal state.
            _revealedCount = 0;
            _revealTimer   = 0;
            _glows.length  = 0;

            _isOpen = true;
        }

        public function close():void {
            if (!_isOpen) return;
            _isOpen = false;

            if (_stage != null) {
                _stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
            }

            _scroll.removeWheelListener();
            if (_mc != null && _mc.parent != null) _mc.parent.removeChild(_mc);

            // Drop any lingering glow sprites (their parent was inside _mc).
            _glows.length = 0;

            if (onClosed != null) onClosed();
        }

        /** Call every frame from ArchipelagoMod.onEnterFrame while isShowing. */
        public function doEnterFrame():void {
            if (!_isOpen || _mc == null) return;

            _scroll.doEnterFrame();

            // Staggered reveal of the icons.
            if (_mc.cells != null && _revealedCount < _mc.cells.length) {
                if (_revealTimer % REVEAL_TICK_FRAMES == 0) {
                    _revealNext();
                }
                _revealTimer++;
            }

            _tickGlows();
        }

        // -----------------------------------------------------------------------
        // Reveal animation

        private function _revealNext():void {
            var cells:Array = _mc.cells;
            if (cells == null || _revealedCount >= cells.length) return;

            var cell:OfflineItemCell = cells[_revealedCount] as OfflineItemCell;
            if (cell != null) {
                cell.alpha        = 1;
                cell.mouseEnabled = true;  // un-gate the tooltip
                _spawnGlow(cell);
                _playRevealSound(cell.apId);
                _scrollIntoView(cell);
            }
            _revealedCount++;
        }

        /**
         * Mirror vanilla IngameCore.doEnterFrameOutcomePanelDropsListing —
         * play a type-specific SFX as each cell pops in. Falls back to the
         * skill-tome chime for ranges vanilla doesn't have a sound for, same
         * pattern RemoteItemDropIcon uses (DropType.SKILL_TOME chosen for the
         * reveal sound).
         */
        private function _playRevealSound(apId:int):void {
            var snd:String = "sndoutcomeskilltome";
            if (apId >= 1 && apId <= 122) snd = "sndoctoken";
            else if (apId >= 600 && apId <= 625) snd = "sndocmaptile";
            else if (apId >= 700 && apId <= 723) snd = "sndoutcomeskilltome";
            else if (apId >= 800 && apId <= 814) snd = "sndoutcomebattletrait";
            else if ((apId >= 900 && apId <= 952) || (apId >= 1200 && apId <= 1246))
                snd = "sndtalismanfragmentinventory";
            else if ((apId >= 1000 && apId <= 1016) || (apId >= 1300 && apId <= 1351))
                snd = "sndoutcomeshadow";
            else if (apId >= 1100 && apId <= 1199) snd = "sndoutcomeskilltome";
            else if (apId >= 1400 && apId <= 1521) snd = "sndoctoken";
            else if (apId >= 1562 && apId <= 1600) snd = "sndoctoken";
            else if (apId >= 1700 && apId <= 1709) snd = "sndoctoken";
            else if (apId >= 2000 && apId <= 2636) snd = "sndoutcomeachievement";

            try { SB.playSound(snd); } catch (err:Error) { /* SB not ready */ }
        }

        /**
         * Vanilla createDropIconAppearingGlow effect: capture the icon's bitmap
         * into an additive-blend overlay parented to the cell itself, so the
         * cell briefly "flashes white" as it appears. Fades over GLOW_LIFE_FRAMES
         * and is removed. Parenting the glow to the cell means it scrolls with
         * the cell automatically — no separate position bookkeeping needed.
         */
        private function _spawnGlow(cell:OfflineItemCell):void {
            var bmpd:BitmapData = new BitmapData(CELL_SIZE, CELL_SIZE, true, 0);
            try {
                bmpd.draw(cell);
            } catch (err:Error) {
                // If draw fails (e.g. cross-domain bitmap), bail without glow.
                return;
            }
            var glow:Sprite = new Sprite();
            glow.addChild(new Bitmap(bmpd));
            glow.blendMode    = "add";
            glow.mouseEnabled = false;
            glow.mouseChildren = false;
            cell.addChild(glow);
            _glows.push({ sprite: glow, life: GLOW_LIFE_FRAMES });
        }

        private function _tickGlows():void {
            for (var i:int = _glows.length - 1; i >= 0; i--) {
                var g:Object = _glows[i];
                g.life--;
                var t:Number = g.life / Number(GLOW_LIFE_FRAMES);
                if (t < 0) t = 0;
                var sp:Sprite = g.sprite as Sprite;
                sp.alpha = t;
                if (g.life <= 0) {
                    if (sp.parent != null) sp.parent.removeChild(sp);
                    _glows.splice(i, 1);
                }
            }
        }

        /**
         * If the freshly-revealed cell sits below the visible viewport, scroll
         * the panel down so it stays in view. Mirrors the behavior of vanilla
         * IngameCore.doEnterFrameOutcomePanelDropsListing, which pans the
         * outcome panel left to keep newly-revealed icons on screen.
         */
        private function _scrollIntoView(cell:OfflineItemCell):void {
            var visibleBottom:Number = _scroll.vpY + _scroll.viewportHeight;
            var cellBottom:Number    = cell.yReal + CELL_SIZE;
            if (cellBottom > visibleBottom) {
                _scroll.scrollToY(cellBottom - _scroll.viewportHeight);
            }
        }

        // -----------------------------------------------------------------------
        // Keyboard

        private function _onKeyDown(e:KeyboardEvent):void {
            if (e.keyCode == Keyboard.ESCAPE) close();
        }
    }
}

