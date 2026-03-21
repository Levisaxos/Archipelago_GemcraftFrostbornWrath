package {
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;

    import Bezel.Bezel;
    import Bezel.BezelMod;
    import Bezel.Logger;

    import com.giab.games.gcfw.GV;

    public class ArchipelagoMod extends MovieClip implements BezelMod {

        public function get VERSION():String       { return "0.0.1"; }
        public function get MOD_NAME():String      { return "ArchipelagoMod"; }
        public function get BEZEL_VERSION():String { return "2.1.1"; }

        // Offset from the top-left of the game content (inside the letterbox).
        private static const TOAST_OFFSET_X:Number = 52;
        private static const TOAST_OFFSET_Y:Number = 10;

        private var _logger:Logger;
        private var _bezel:Bezel;
        private var _btn:ArchipelagoButton;
        private var _buttonAdded:Boolean = false;

        private var _toast:ToastPanel;
        private var _toastOnStage:Boolean = false;

        private var _debugOptions:ScrDebugOptions;
        private var _keyListenerAdded:Boolean = false;

        // Set to false whenever the selector closes so unlockAllMapTiles() re-runs on next open.
        private var _mapTilesUnlocked:Boolean = false;

        // -----------------------------------------------------------------------
        // Debug mode — toggled at runtime by Ctrl+Shift+Alt+End.
        // Set DEBUG_MODE_DEFAULT = true to start with debug mode already on,
        // useful during development so you don't need the hotkey every session.
        // For a public release, leave it false.
        private static const DEBUG_MODE_DEFAULT:Boolean = false;
        private var _debugMode:Boolean = DEBUG_MODE_DEFAULT;
        // -----------------------------------------------------------------------

        // Skill names indexed by game_id (matches SkillId constants).
        private static const SKILL_NAMES:Array = [
            "Mana Stream", "True Colors", "Fusion", "Orb of Presence",
            "Resonance", "Demolition", "Critical Hit", "Mana Leech",
            "Bleeding", "Armor Tearing", "Poison", "Slowing",
            "Freeze", "Whiteout", "Ice Shards", "Bolt",
            "Beam", "Barrage", "Fury", "Amplifiers",
            "Pylons", "Lanterns", "Traps", "Seeker Sense"
        ];

        // Battle trait names indexed by game_id (matches BattleTraitId constants).
        private static const BATTLE_TRAIT_NAMES:Array = [
            "Adaptive Carapace", "Dark Masonry", "Swarmling Domination", "Overcrowd",
            "Corrupted Banishment", "Awakening", "Insulation", "Hatred",
            "Swarmling Parasites", "Haste", "Thick Air", "Vital Link",
            "Giant Domination", "Strength in Numbers", "Ritual"
        ];

        public function ArchipelagoMod() {
            super();
            _logger = Logger.getLogger(MOD_NAME);
        }

        public function bind(bezel:Bezel, gameObjects:Object):void {
            _bezel = bezel;
            _logger.log(MOD_NAME, "ArchipelagoMod loaded!");

            _toast = new ToastPanel();
            _debugOptions = new ScrDebugOptions(this);

            addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
        }

        public function unload():void {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            if (this.stage != null) {
                this.stage.removeEventListener(Event.RESIZE, onStageResize);
            }
            if (_toast != null && _toast.parent != null) {
                _toast.parent.removeChild(_toast);
            }
            _toast = null;
            _toastOnStage = false;
            if (_keyListenerAdded && this.stage != null) {
                this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
                _keyListenerAdded = false;
            }
            if (_debugOptions != null && _debugOptions.isOpen) {
                _debugOptions.close();
            }
            _debugOptions = null;
            if (_btn != null && _btn.parent != null) {
                _btn.parent.removeChild(_btn);
                _btn = null;
            }
            _buttonAdded = false;
            _logger.log(MOD_NAME, "ArchipelagoMod unloaded");
        }

        // -----------------------------------------------------------------------

        private function onEnterFrame(e:Event):void {
            // Add toast to stage using the mod's own stage reference — available on any screen.
            if (!_toastOnStage && _toast != null && this.stage != null) {
                this.stage.addChild(_toast);
                _toastOnStage = true;
                positionToast();
                this.stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);
            }

            // Register the debug hotkey (Ctrl+Shift+Alt+End) once the stage exists.
            if (!_keyListenerAdded && this.stage != null) {
                this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
                _keyListenerAdded = true;
            }

            if (GV.selectorCore == null) {
                // Selector closed — reset so tile visibility is re-applied next time it opens.
                _mapTilesUnlocked = false;
                return;
            }

            if (GV.ppd == null || GV.selectorCore.renderer == null) return;

            // Show all tile bitmaps once per selector session.
            if (!_mapTilesUnlocked) {
                for (var ti:int = 0; ti < GV.ppd.gainedMapTiles.length; ti++) {
                    GV.ppd.gainedMapTiles[ti] = true;
                }
                GV.selectorCore.renderer.setMapTilesVisibility();
                _mapTilesUnlocked = true;
                _logger.log(MOD_NAME, "All map tiles unlocked (" + GV.ppd.gainedMapTiles.length + " tiles)");
            }

            // Enforce full-world scroll limits every frame so the W4 lock in
            // setVpLimits() can never stick — even after returning from a level.
            enforceFullWorldScrollLimits();

            var mc:* = GV.selectorCore.mc;
            if (mc == null) return;

            if (mc.btnTutorial == null) return;

            if (!_buttonAdded) {
                if (mc.btnSkills == null || mc.btnTalisman == null) return;
                addArchipelagoButton(mc);
                _buttonAdded = true;
            }

            // Sync x every frame so the button rides the slide-in animation.
            if (_btn != null) {
                _btn.x = mc.btnTutorial.x;
            }

            // Drive scroll-knob drag in the debug options panel.
            if (_debugOptions != null && _debugOptions.isOpen) {
                _debugOptions.doEnterFrame();
            }
        }

        private function positionToast():void {
            if (_toast == null || this.stage == null) return;
            // stage[0] is [object Main] — the game's content root.
            // Multiply offsets by Main's scale so they stay in game units at any window size.
            var gameRoot:* = this.stage.getChildAt(0);
            _toast.x = gameRoot.x + TOAST_OFFSET_X * gameRoot.scaleX;
            _toast.y = gameRoot.y + TOAST_OFFSET_Y * gameRoot.scaleY;
        }

        private function onStageResize(e:Event):void {
            positionToast();
        }

        private function addArchipelagoButton(mc:*):void {
            var btnSkills:*   = mc.btnSkills;
            var btnTalisman:* = mc.btnTalisman;
            var btnTutorial:* = mc.btnTutorial;

            var stepY:Number = btnTalisman.y - btnSkills.y;

            _btn = new ArchipelagoButton(btnTutorial);
            _btn.x = btnTutorial.x;
            _btn.y = btnTutorial.y + stepY;
            _btn.visible = _debugMode;
            _btn.addEventListener(MouseEvent.CLICK, onArchipelagoClicked, false, 0, true);

            mc.addChild(_btn);
            _logger.log(MOD_NAME, "Archipelago button added at (" + _btn.x + ", " + _btn.y + ")");
        }

        private function onKeyDown(e:KeyboardEvent):void {
            if (e.keyCode == Keyboard.END && e.ctrlKey && e.shiftKey && e.altKey) {
                _debugMode = !_debugMode;
                _logger.log(MOD_NAME, "Debug mode " + (_debugMode ? "ON" : "OFF"));
                if (_btn != null) _btn.visible = _debugMode;
                // If debug mode was just turned off, close the panel if it is open.
                if (!_debugMode && _debugOptions != null && _debugOptions.isOpen) {
                    _debugOptions.close();
                }
            }
        }

        private function onArchipelagoClicked(e:MouseEvent):void {
            if (!_debugMode) return;
            if (_debugOptions == null) return;
            if (_debugOptions.isOpen) {
                _logger.log(MOD_NAME, "Closing debug options panel");
                _debugOptions.close();
            } else {
                _logger.log(MOD_NAME, "Opening debug options panel");
                _debugOptions.open();
            }
        }

        // -----------------------------------------------------------------------
        // Archipelago item handling

        /**
         * Unlock a skill by its Archipelago item ID (300-323).
         * Sets the skill tome flag and initialises the level to 0 if not yet available.
         */
        public function unlockSkill(apId:int):void {
            var gameId:int = apId - 300;
            if (gameId < 0 || gameId > 23) {
                _logger.log(MOD_NAME, "unlockSkill: invalid AP ID " + apId);
                return;
            }
            if (GV.ppd == null) {
                _logger.log(MOD_NAME, "unlockSkill: GV.ppd is null, cannot unlock skill " + apId);
                return;
            }
            GV.ppd.gainedSkillTomes[gameId] = true;
            GV.ppd.setSkillLevel(gameId, Math.max(GV.ppd.getSkillLevel(gameId), 0));
            var skillName:String = SKILL_NAMES[gameId];
            _logger.log(MOD_NAME, "Unlocked skill game_id=" + gameId + " (AP ID=" + apId + ")");
            _toast.addMessage("Skill Unlocked: " + skillName, 0xFFDDA0FF);
        }

        /**
         * Override the scroll limits to the full world extent every frame.
         *
         * setVpLimits() in SelectorCore has a hard-coded override that collapses
         * the scroll area to just the W tile whenever W4 Journey hasn't been
         * completed.  It is called both on selector open and whenever the event
         * queue processes a level-return, so a one-shot fix is not enough.
         *
         * The constants are the global-clamp values from setVpLimits() lines 1030-1033,
         * which represent the widest bounds the game ever allows:
         *   vpXMin = 264, vpXMax = 1864, vpYMin = 330, vpYMax = 3712
         */
        private function enforceFullWorldScrollLimits():void {
            GV.selectorCore.vpXMin = 200 + 104 - 40 - 544 + 960 - 416;  // 264
            GV.selectorCore.vpXMax = 1400 - 408 + 40 - 544 + 960 + 416; // 1864
            GV.selectorCore.vpYMin = 0 + 61 - 40 + 115 - 40 - 306 + 540; // 330
            GV.selectorCore.vpYMax = 3300 - 306 + 540 + 178;              // 3712
        }

        /**
         * Unlock a battle trait by its Archipelago item ID (400-414).
         * Sets the gained flag and initialises the selected level to 0.
         */
        public function unlockBattleTrait(apId:int):void {
            var gameId:int = apId - 400;
            if (gameId < 0 || gameId > 14) {
                _logger.log(MOD_NAME, "unlockBattleTrait: invalid AP ID " + apId);
                return;
            }
            if (GV.ppd == null) {
                _logger.log(MOD_NAME, "unlockBattleTrait: GV.ppd is null, cannot unlock trait " + apId);
                return;
            }
            GV.ppd.gainedBattleTraits[gameId] = true;
            GV.ppd.selectedBattleTraitLevels[gameId].s(Math.max(GV.ppd.selectedBattleTraitLevels[gameId].g(), 0));
            var traitName:String = BATTLE_TRAIT_NAMES[gameId];
            _logger.log(MOD_NAME, "Unlocked battle trait game_id=" + gameId + " (AP ID=" + apId + ")");
            _toast.addMessage("Trait Unlocked: " + traitName, 0xFFFFAA44);
        }
    }
}
