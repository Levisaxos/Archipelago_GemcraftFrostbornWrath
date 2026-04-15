package ui {
    import flash.net.URLRequest;
    import flash.net.navigateToURL;

    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    import data.AV;
    import net.ConnectionManager;
    import tracker.LogicEvaluator;

    /**
     * Creates and manages all mod buttons across the selector screen and the
     * main menu. ArchipelagoMod constructs this once in bind(), wires the
     * public callback properties, then calls the appropriate show/remove
     * methods as the player navigates between screens.
     *
     * Callback properties (all no-arg, ():void):
     *   onSettingsClick  — toggle the AP slot-settings panel
     *   onApDebugClick   — toggle the debug-options panel
     *   onChangelogClick — open the changelog panel
     */
    public class ModButtons {

        /** Toggle the AP slot-settings panel. */
        public var onSettingsClick:Function;
        /** Toggle the debug-options panel. */
        public var onApDebugClick:Function;
        /** Open the changelog panel. */
        public var onChangelogClick:Function;

        private var _logger:Logger;
        private var _modName:String;
        private var _connectionManager:ConnectionManager;
        private var _logicEvaluator:LogicEvaluator;

        // Selector-screen buttons
        private var _reportBtn:CustomButton;
        private var _settingsBtn:CustomButton;
        private var _fieldsBtn:FieldsInLogicButton;
        private var _apDebugBtn:CustomButton;

        // Main-menu button
        private var _changelogBtn:CustomButton;
        private var _changelogBtnFrameDelay:Number = 5;
        private var _changelogBtnCreated:Boolean = false;
        private var _startBtnOriginalY:Number = NaN; // saved so we can restore Start Game on remove

        private var _selectorAdded:Boolean = false;
        

        public function ModButtons(logger:Logger, modName:String,
                                   connectionManager:ConnectionManager,
                                   logicEvaluator:LogicEvaluator) {
            _logger            = logger;
            _modName           = modName;
            _connectionManager = connectionManager;
            _logicEvaluator    = logicEvaluator;
        }

        // -----------------------------------------------------------------------
        // Visibility setters (called by ArchipelagoMod on connect / disconnect)

        public function set settingsVisible(v:Boolean):void {
            if (_settingsBtn != null) _settingsBtn.visible = v;
        }

        public function set apDebugVisible(v:Boolean):void {
            if (_apDebugBtn != null) _apDebugBtn.visible = v;
        }

        // -----------------------------------------------------------------------
        // Selector screen

        /**
         * Create the four selector buttons and add them to mc.
         * Idempotent — does nothing if already added.
         * Requires mc.btnTutorial, mc.btnSkills, and mc.btnTalisman to be non-null.
         */
        public function showOnSelector(mc:*):void {
            if (_selectorAdded) return;

            var tmpl:*       = mc.btnTutorial;
            var stepY:Number = mc.btnTalisman.y - mc.btnSkills.y;

            // ---- Report Issues ----
            _reportBtn        = new CustomButton(tmpl, "Report Issues");
            _reportBtn.x      = tmpl.x;
            _reportBtn.y      = tmpl.y + stepY;
            _reportBtn.onClick = _onReportClick;
            mc.addChild(_reportBtn);
            _logger.log(_modName, "Report Issues button added at ("
                + _reportBtn.x + ", " + _reportBtn.y + ")");

            // ---- AP Settings (hidden until AP connects) ----
            _settingsBtn         = new CustomButton(tmpl, "AP Settings");
            _settingsBtn.x       = tmpl.x;
            _settingsBtn.y       = tmpl.y + stepY * 2;
            _settingsBtn.visible = false;
            _settingsBtn.onClick = function():void {
                if (onSettingsClick != null) onSettingsClick();
            };
            mc.addChild(_settingsBtn);
            _logger.log(_modName, "AP Settings button added at ("
                + _settingsBtn.x + ", " + _settingsBtn.y
                + ") [hidden until connected]");

            // ---- Fields in Logic ----
            _fieldsBtn   = new FieldsInLogicButton(tmpl);
            _fieldsBtn.x = tmpl.x;
            _fieldsBtn.y = tmpl.y + stepY * 3;
            mc.addChild(_fieldsBtn);
            _logger.log(_modName, "Fields in Logic button added at ("
                + _fieldsBtn.x + ", " + _fieldsBtn.y + ")");

            // ---- Archipelago debug (hidden until Ctrl+Alt+Shift+End) ----
            _apDebugBtn         = new CustomButton(tmpl, "Archipelago");
            _apDebugBtn.x       = tmpl.x;
            _apDebugBtn.y       = tmpl.y + stepY * 4;
            _apDebugBtn.visible = false;
            _apDebugBtn.onClick = function():void {
                if (onApDebugClick != null) onApDebugClick();
            };
            mc.addChild(_apDebugBtn);
            _logger.log(_modName, "Archipelago button added at ("+ _apDebugBtn.x + ", " + _apDebugBtn.y + ") [hidden]");

            _selectorAdded = true;
        }

        /**
         * Remove all selector buttons and clear references.
         */
        public function removeFromSelector():void {
            _remove(_reportBtn);   _reportBtn   = null;
            _remove(_settingsBtn); _settingsBtn = null;
            _remove(_fieldsBtn);   _fieldsBtn   = null;
            _remove(_apDebugBtn);  _apDebugBtn  = null;
            _selectorAdded = false;
        }

        /**
         * Per-frame update: sync X positions with btnTutorial (handles panel
         * resize) and drive the fields-in-logic button (label + hover + pan).
         */
        public function onSelectorFrame(mc:*):void {
            if (!_selectorAdded) return;

            var bx:Number = mc.btnTutorial.x;
            if (_reportBtn   != null) _reportBtn.x   = bx;
            if (_settingsBtn != null) _settingsBtn.x = bx;
            if (_fieldsBtn   != null) _fieldsBtn.x   = bx;
            if (_apDebugBtn  != null) _apDebugBtn.x  = bx;

            if (_fieldsBtn != null) {
                var inLogicList:Array = _computeInLogicStages();
                _fieldsBtn.update(inLogicList.length, inLogicList);
                _fieldsBtn.onFrame();
            }
        }

        public function get selectorAdded():Boolean { return _selectorAdded; }

        // -----------------------------------------------------------------------
        // Main-menu screen

        /**
         * Create the Changelog button on the main menu.
         * Uses btnStartGame as the visual template so it matches the game's style.
         * The y position is not set here — call onMainMenuFrame() every frame to
         * keep it centred between the Start Game and Exit buttons (needed because
         * ScrMainMenu repositions its buttons after this method runs).
         */
        public function createChangelogButton():void {           
            var mc:*   = GV.main.scrMainMenu.mc;
            var tmpl:* = mc.btnExit;

            _startBtnOriginalY    = tmpl.y;
            _changelogBtn         = new CustomButton(tmpl, "Changelog");
            _changelogBtn.onClick = function():void {
                if (onChangelogClick != null) onChangelogClick();
            };
            mc.addChild(_changelogBtn);            
        }

        /**
         * Call every frame while on the main menu.
         * Keeps the Changelog button centred in the gap between Start Game and Exit,
         * compensating for ScrMainMenu's slide-in animation repositioning.
         */
        public function onMainMenuFrame():void {
             if (_changelogBtnFrameDelay > 0) {             
                _changelogBtnFrameDelay--;
                return;
            }

            if (_changelogBtn == null){
                 createChangelogButton();
                 return;            
            }
            var mc:*       = GV.main.scrMainMenu.mc;
            var startBtn:* = mc.btnStartGame;
            var exitBtn:*  = mc.btnExit;
            var gap:Number = 8;

            // // Exit stays put. Place Changelog just above it, Start Game above that.
             _changelogBtn.x = exitBtn.x;
             _changelogBtn.y = exitBtn.y - _changelogBtn.height - gap;
             startBtn.y      = _changelogBtn.y - startBtn.height - gap;             
        }

        /**
         * Remove the main-menu changelog button and clear its reference.
         */
        public function removeFromMainMenu():void {
            if (!isNaN(_startBtnOriginalY)) {
                GV.main.scrMainMenu.mc.btnStartGame.y = _startBtnOriginalY;
                _startBtnOriginalY = NaN;
            }
            _remove(_changelogBtn);
            _changelogBtn = null;
        }

        // -----------------------------------------------------------------------
        // Private helpers

        private function _onReportClick():void {
            navigateToURL(
                new URLRequest(
                    "https://github.com/Levisaxos/Archipelago_GemcraftFrostbornWrath/issues"),
                "_blank");
        }

        /**
         * Returns a sorted array of strIds for stages that currently have at
         * least one AP location still missing and in logic.
         */
        private function _computeInLogicStages():Array {
            var result:Array = [];
            if (!_connectionManager.isConnected || _logicEvaluator == null) return result;
            var metas:Array = (GV.stageCollection != null) ? GV.stageCollection.stageMetas : null;
            if (metas == null) return result;
            var missing:Object = AV.saveData.missingLocations;
            var locIds:Object  = ConnectionManager.stageLocIds;
            for (var i:int = 0; i < metas.length; i++) {
                var meta:* = metas[i];
                if (meta == null) continue;
                var strId:String = String(meta.strId);
                if (GV.ppd.stageHighestXpsJourney[meta.id].g() < 0) continue;
                var base:int = int(locIds[strId]);
                if (base <= 0) continue;
                var jMiss:Boolean = missing[base]        == true;
                var bMiss:Boolean = missing[base + 500]  == true;
                var sMiss:Boolean = missing[base + 1000] == true;
                if (_logicEvaluator.stageHasInLogicMissing(strId, jMiss, bMiss, sMiss)) {
                    result.push(strId);
                }
            }
            result.sort(Array.CASEINSENSITIVE);
            return result;
        }

        private function _remove(obj:*):void {
            if (obj != null && obj.parent != null) obj.parent.removeChild(obj);
        }
    }
}
