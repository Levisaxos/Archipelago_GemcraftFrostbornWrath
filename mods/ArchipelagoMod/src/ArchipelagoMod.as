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

        private var _logger:Logger;
        private var _bezel:Bezel;
        private var _btn:ArchipelagoButton;
        private var _buttonAdded:Boolean = false;

        public function ArchipelagoMod() {
            super();
            _logger = Logger.getLogger(MOD_NAME);
        }

        public function bind(bezel:Bezel, gameObjects:Object):void {
            _bezel = bezel;
            _logger.log(MOD_NAME, "ArchipelagoMod loaded!");
            addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
        }

        public function unload():void {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            if (_btn != null && _btn.parent != null) {
                _btn.parent.removeChild(_btn);
                _btn = null;
            }
            _buttonAdded = false;
            _logger.log(MOD_NAME, "ArchipelagoMod unloaded");
        }

        // -----------------------------------------------------------------------

        private function onEnterFrame(e:Event):void {
            if (GV.selectorCore == null) return;

            var mc:* = GV.selectorCore.mc;
            if (mc == null || mc.stage == null) return;
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
            _logger.log(MOD_NAME, "Archipelago button clicked!");
        }
    }
}
