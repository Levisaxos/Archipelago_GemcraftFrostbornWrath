package {
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;

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

        // Test state: cycles skills (300-323) then battle traits (400-414) on each click.
        private var _testApId:int = 300;

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

            if (GV.selectorCore == null) return;

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
            _btn.addEventListener(MouseEvent.CLICK, onArchipelagoClicked, false, 0, true);

            mc.addChild(_btn);
            _logger.log(MOD_NAME, "Archipelago button added at (" + _btn.x + ", " + _btn.y + ")");
        }

        private function onArchipelagoClicked(e:MouseEvent):void {
            _logger.log(MOD_NAME, "Archipelago button clicked! Testing AP ID " + _testApId);
            if (_testApId >= 300 && _testApId <= 323) {
                unlockSkill(_testApId);
            } else if (_testApId >= 400 && _testApId <= 414) {
                unlockBattleTrait(_testApId);
            }
            _testApId++;
            if (_testApId == 324) _testApId = 400; // skip gap between skills and traits
            if (_testApId > 414) _testApId = 300;  // wrap back to start
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
