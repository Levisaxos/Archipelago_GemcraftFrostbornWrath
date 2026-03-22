package {
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.ui.Keyboard;

    import Bezel.Bezel;
    import Bezel.BezelMod;
    import Bezel.Logger;
    import Bezel.GCFW.Events.EventTypes;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.ScreenId;

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
        private var _progressionBlocker:ProgressionBlocker;
        private var _ws:WebSocketClient;
        private var _tokenMap:Object = {};       // item AP ID (string) → stage str_id
        private var _tokenStages:Object = {};    // stage str_id → true  (has an AP token)
        private var _configDir:File;             // {game_dir}/Mods/config/ — readable/writable JSON files
        private var _apWizardLevel:int = 0;      // total AP-granted wizard levels this session
        private var _keyListenerAdded:Boolean = false;

        // -----------------------------------------------------------------------
        // Archipelago connection settings — loaded from connection.json, editable via ConnectionPanel.
        private var _apHost:String     = "localhost";
        private var _apPort:int        = 38281;
        private var _apSlot:String     = "";
        private var _apPassword:String = "";
        private static const AP_SECURE:Boolean = false; // local server = plain ws://

        private var _connectionPanel:ConnectionPanel;
        private var _blockingOverlay:Sprite;      // covers the game while not connected
        private var _isConnected:Boolean     = false;
        private var _reconnecting:Boolean    = false; // true while deliberately disconnecting before reconnect
        private var _needsConnection:Boolean = false; // true after leaving LOADGAME toward gameplay
        private var _currentSlot:int         = 0;  // GV.loaderSaver.activeSlotId at game entry
        private var _lastScreen:int          = -1; // previous GV.main.currentScreen value

        // Mode-selector interception — we stop the Chilling/Frostborn click,
        // show the connection panel, and re-dispatch once connected.
        private var _pendingModeButton:* = null; // e.currentTarget at intercept (the button MC)
        private var _pendingModeTarget:* = null; // e.target at intercept (child clicked inside button)
        private var _allowModeClick:Boolean     = false;
        private var _modeSelectorHooked:Boolean = false;
        private var _pendingDeleteSlot:int      = 0; // slot whose delete btn was clicked (pre-confirm)
        // -----------------------------------------------------------------------

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

        // Stage str_id → AP location ID (Journey).  Bonus = locId + 500.
        // Must match game_data.json loc_ap_id values exactly.
        private static const STAGE_LOC_AP_IDS:Object = {
            "W1":1,  "W2":2,  "W3":3,  "W4":4,  "W5":110,
            "S1":5,  "S2":6,  "S3":7,  "S4":8,
            "V1":9,  "V2":10, "V3":11, "V4":12,
            "R1":13, "R2":14, "R3":15, "R4":16, "R5":17, "R6":113,
            "Q1":18, "Q2":19, "Q3":20, "Q4":21, "Q5":22,
            "T1":23, "T2":24, "T3":25, "T4":26, "T5":112,
            "U1":27, "U2":28, "U3":29, "U4":30,
            "Y1":31, "Y2":32, "Y3":33, "Y4":34,
            "X1":35, "X2":36, "X3":37, "X4":38,
            "Z1":39, "Z2":40, "Z3":41, "Z4":42, "Z5":111,
            "O1":43, "O2":44, "O3":45, "O4":46,
            "N1":47, "N2":48, "N3":49, "N4":50, "N5":51,
            "P1":52, "P2":53, "P3":54, "P4":55, "P5":56, "P6":114,
            "L1":57, "L2":58, "L3":59, "L4":60, "L5":61,
            "K1":62, "K2":63, "K3":64, "K4":65, "K5":115,
            "H1":66, "H2":67, "H3":68, "H4":69, "H5":116,
            "G1":70, "G2":71, "G3":72, "G4":73, "G5":117,
            "J1":74, "J2":75, "J3":76, "J4":77,
            "M1":78, "M2":79, "M3":80, "M4":81,
            "F1":82, "F2":83, "F3":84, "F4":85, "F5":118,
            "E1":86, "E2":87, "E3":88, "E4":89, "E5":119,
            "D1":90, "D2":91, "D3":92, "D4":93, "D5":124,
            "B1":94, "B2":95, "B3":96, "B4":97, "B5":120,
            "C1":98, "C2":99, "C3":100,"C4":101,"C5":102,
            "A1":103,"A2":104,"A3":105,"A4":106,"A5":121,"A6":122,
            "I1":123,"I2":107,"I3":108,"I4":109
        };

        // AP location IDs not yet checked according to the server.
        // Populated from handleConnected; updated as checks are sent.
        private var _missingLocations:Object = {};

        public function ArchipelagoMod() {
            super();
            _logger = Logger.getLogger(MOD_NAME);
        }

        public function bind(bezel:Bezel, gameObjects:Object):void {
            try {
                _bezel = bezel;
                _configDir = File.applicationStorageDirectory.resolvePath("archipelago");
                _logger.log(MOD_NAME, "Config dir: " + _configDir.nativePath);
                _toast = new ToastPanel();
                _debugOptions = new ScrDebugOptions(this);
                _progressionBlocker = new ProgressionBlocker(_logger, MOD_NAME);
                _progressionBlocker.enable(_bezel);
                _bezel.addEventListener(EventTypes.SAVE_SAVE, onSaveSave);
                addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
                _logger.log(MOD_NAME, "ArchipelagoMod loaded!");

                _ws = new WebSocketClient(_logger);
                _ws.onOpen    = function():void {
                    _logger.log(MOD_NAME, "WS onOpen — TCP+WS handshake done, waiting for AP Connected packet");
                    // Don't set _isConnected yet — wait for the AP Connected packet.
                    // Show "Authenticating..." in the panel so the button stays disabled.
                    if (_connectionPanel != null) _connectionPanel.showError("Authenticating...");
                };
                _ws.onMessage = onApMessage;
                _ws.onError   = function(msg:String):void {
                    _logger.log(MOD_NAME, "WS onError — _isConnected: " + _isConnected + " → false  msg=" + msg);
                    _isConnected = false;
                    if (_connectionPanel != null) {
                        _connectionPanel.resetState();
                        _connectionPanel.showError("Connection failed: " + msg);
                    }
                    _toast.addMessage("AP error: " + msg, 0xFFFF6666);
                };
                _ws.onClose   = function():void {
                    _logger.log(MOD_NAME, "WS onClose — _isConnected: " + _isConnected + " → false  _reconnecting=" + _reconnecting);
                    _isConnected = false;
                    // Suppress reset when we deliberately disconnected before reconnecting.
                    if (!_reconnecting && _connectionPanel != null) _connectionPanel.resetState();
                    if (!_reconnecting) _toast.addMessage("AP disconnected", 0xFFFFAA44);
                };
                _logger.log(MOD_NAME, "No auto-connect — waiting for slot selection");
            } catch (err:Error) {
                _logger.log(MOD_NAME, "BIND ERROR: " + err.message + "\n" + err.getStackTrace());
            }
        }

        public function unload():void {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            if (_bezel != null) _bezel.removeEventListener(EventTypes.SAVE_SAVE, onSaveSave);
            if (_ws != null) {
                _ws.disconnect();
                _ws = null;
            }
            if (_progressionBlocker != null) {
                _progressionBlocker.disable();
                _progressionBlocker = null;
            }
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
            unhookModeSelector();
            _pendingModeButton = null;
            _pendingModeTarget = null;
            dismissConnectionOverlay();
            if (_connectionPanel != null && _connectionPanel.parent != null) {
                _connectionPanel.parent.removeChild(_connectionPanel);
            }
            _connectionPanel = null;
            _blockingOverlay = null;
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

            // Track screen transitions and detect selector entry.
            var screen:int = int(GV.main.currentScreen);
            if (_lastScreen == -1) {
                _lastScreen = screen;
                _logger.log(MOD_NAME, "Screen init — currentScreen=" + screen);
            }
            if (screen != _lastScreen) {
                _logger.log(MOD_NAME, "Screen change: " + _lastScreen + " → " + screen
                    + "  _isConnected=" + _isConnected + "  _needsConnection=" + _needsConnection);

                if (_lastScreen == ScreenId.LOADGAME) {
                    unhookModeSelector();
                    if (screen != ScreenId.MAINMENU) {
                        // Leaving LOADGAME toward gameplay.
                        // If already connected (re-dispatch just triggered the transition),
                        // leave connection state alone; otherwise force a fresh connect.
                        _currentSlot = int(GV.loaderSaver.activeSlotId) + 1; // activeSlotId is 0-indexed; slots are 1-indexed
                        if (!_isConnected) {
                            _needsConnection = true;
                            if (_ws != null) _ws.disconnect();
                            _logger.log(MOD_NAME, "Left LOADGAME not-connected — slot=" + _currentSlot
                                + "  needsConnection=true");
                        } else {
                            _logger.log(MOD_NAME, "Left LOADGAME already-connected — slot=" + _currentSlot);
                        }
                    }
                }
                _lastScreen = screen;
            }

            // When entering LOADGAME, drop any existing connection — the player
            // must connect fresh for whichever slot they choose.
            if (screen == ScreenId.LOADGAME && _lastScreen != ScreenId.LOADGAME) {
                if (_ws != null) {
                    _reconnecting = false; // ensure onClose side-effects fire
                    _ws.disconnect();
                }
                _isConnected     = false;
                _needsConnection = false;
                dismissConnectionOverlay();
                _pendingModeButton = null;
                _pendingModeTarget = null;
                _logger.log(MOD_NAME, "Entered LOADGAME — connection reset");
            }

            // Hook mode selector buttons while on LOADGAME so we can intercept
            // Chilling/Frostborn clicks before the game transitions.
            if (screen == ScreenId.LOADGAME && !_modeSelectorHooked) {
                tryHookModeSelector();
            }

            // Show connection overlay on any screen while a fresh connection is required.
            if (_needsConnection && !_isConnected && this.stage != null) {
                ensureConnectionOverlay();
            }

            // Gate: wait until the selector and its async tile generation are fully ready.
            // mapTiles is null until WorldMapBuilder.finishCreatingMapTiles() completes;
            // setMapTilesVisibility() accesses mapTiles internals and crashes before that.
            if (GV.ppd == null
                    || GV.selectorCore.renderer == null
                    || GV.selectorCore.mapTiles == null) {
                _mapTilesUnlocked = false;
                return;
            }

            var mc:* = GV.selectorCore.mc;
            if (mc == null) return;

            // Sync tile visibility with stage unlock state once per selector session.
            if (!_mapTilesUnlocked) {
                syncMapTilesWithStages();
                GV.selectorCore.renderer.setMapTilesVisibility();
                _mapTilesUnlocked = true;
                _logger.log(MOD_NAME, "Map tile visibility synced with stage states");
            }

            // Enforce full-world scroll limits every frame so the W4 lock in
            // setVpLimits() can never stick — even after returning from a level.
            enforceFullWorldScrollLimits();

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
            _btn.visible = true;
            _btn.addEventListener(MouseEvent.CLICK, onArchipelagoClicked, false, 0, true);

            mc.addChild(_btn);
            _logger.log(MOD_NAME, "Archipelago button added at (" + _btn.x + ", " + _btn.y + ")");
        }

        private function onKeyDown(e:KeyboardEvent):void {
            if (e.keyCode == Keyboard.END && e.ctrlKey && e.shiftKey && e.altKey) {
                _debugMode = !_debugMode;
                _logger.log(MOD_NAME, "Debug mode " + (_debugMode ? "ON" : "OFF"));
                // If debug mode was just turned off, close the debug panel if it is open.
                if (!_debugMode && _debugOptions != null && _debugOptions.isOpen) {
                    _debugOptions.close();
                }
            }
        }

        private function onArchipelagoClicked(e:MouseEvent):void {
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
        // Mode-selector interception

        private function tryHookModeSelector():void {
            try {
                var lg:*  = GV.main.cntScreens.mcLoadGame;
                var sel:* = lg.mcModeSelector;
                if (sel == null) return;
                sel.btnModeChilling.addEventListener( MouseEvent.MOUSE_UP, onModeBtnUp, true, 100, true);
                sel.btnModeFrostborn.addEventListener(MouseEvent.MOUSE_UP, onModeBtnUp, true, 100, true);
                sel.btnModeIron.addEventListener(     MouseEvent.MOUSE_UP, onIronBtnUp, true, 100, true);
                // Observe delete buttons — record pending slot; actual archive happens on D confirmation.
                for (var n:int = 1; n <= 8; n++) {
                    var btn:* = lg["btnResetSlotL" + n];
                    if (btn != null) btn.addEventListener(MouseEvent.MOUSE_UP, onDeleteBtnUp, false, 0, true);
                }
                // Capture D key before the game processes it so we archive before deletion.
                this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onConfirmDeleteKey, true, 100, true);
                _modeSelectorHooked = true;
                _logger.log(MOD_NAME, "LOADGAME buttons hooked (Chilling + Frostborn + Iron + Delete x8)");
            } catch (err:Error) {
                _logger.log(MOD_NAME, "tryHookModeSelector error: " + err.message);
            }
        }

        private function unhookModeSelector():void {
            if (!_modeSelectorHooked) return;
            try {
                var lg:*  = GV.main.cntScreens.mcLoadGame;
                var sel:* = lg != null ? lg.mcModeSelector : null;
                if (sel != null) {
                    sel.btnModeChilling.removeEventListener( MouseEvent.MOUSE_UP, onModeBtnUp, true);
                    sel.btnModeFrostborn.removeEventListener(MouseEvent.MOUSE_UP, onModeBtnUp, true);
                    sel.btnModeIron.removeEventListener(     MouseEvent.MOUSE_UP, onIronBtnUp, true);
                }
                if (lg != null) {
                    for (var n:int = 1; n <= 8; n++) {
                        var btn:* = lg["btnResetSlotL" + n];
                        if (btn != null) btn.removeEventListener(MouseEvent.MOUSE_UP, onDeleteBtnUp, false);
                    }
                }
                if (this.stage != null) {
                    this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onConfirmDeleteKey, true);
                }
            } catch (err:Error) {
                _logger.log(MOD_NAME, "unhookModeSelector error: " + err.message);
            }
            _pendingDeleteSlot = 0;
            _modeSelectorHooked = false;
            _logger.log(MOD_NAME, "LOADGAME buttons unhooked");
        }

        private function onModeBtnUp(e:MouseEvent):void {
            if (_allowModeClick) return; // our own re-dispatch — let it through
            e.stopImmediatePropagation();
            _currentSlot       = int(GV.loaderSaver.activeSlotId); // capture slot before overlay
            _pendingModeButton = e.currentTarget; // the button MovieClip
            _pendingModeTarget = e.target;        // the child that was actually clicked
            _logger.log(MOD_NAME, "Mode button intercepted — btn=" + _pendingModeButton
                + "  target=" + _pendingModeTarget + "  slot=" + _currentSlot);
            loadSlotData(_currentSlot); // pre-load saved connection + AP state for this slot
            ensureConnectionOverlay();
        }

        private function onIronBtnUp(e:MouseEvent):void {
            e.stopImmediatePropagation();
            _toast.addMessage("Iron is not allowed (yet) for Archipelago", 0xFFFF8844);
            _logger.log(MOD_NAME, "Iron mode blocked — not supported in AP");
        }

        private function onDeleteBtnUp(e:MouseEvent):void {
            // Identify slot by comparing object reference against each known delete button.
            var lg:* = GV.main.cntScreens.mcLoadGame;
            var slotId:int = 0;
            for (var n:int = 1; n <= 8; n++) {
                if (lg["btnResetSlotL" + n] == e.currentTarget) { slotId = n; break; }
            }
            if (slotId <= 0) {
                _logger.log(MOD_NAME, "onDeleteBtnUp: could not identify slot — btn.name=" + e.currentTarget.name);
                return;
            }
            _pendingDeleteSlot = slotId;
            _logger.log(MOD_NAME, "Delete button clicked for slot " + slotId + " — waiting for D confirmation");
        }

        private function onConfirmDeleteKey(e:KeyboardEvent):void {
            if (e.keyCode != Keyboard.D || _pendingDeleteSlot <= 0) return;
            _logger.log(MOD_NAME, "D key confirmed — archiving slot " + _pendingDeleteSlot);
            archiveSlot(_pendingDeleteSlot);
            _pendingDeleteSlot = 0;
        }

        private function archiveSlot(slotId:int):void {
            if (_configDir == null) return;
            var timestamp:String = String(new Date().getTime());
            var deletedDir:File = _configDir.resolvePath("deleted");
            try {
                if (!deletedDir.exists) deletedDir.createDirectory();
            } catch (err:Error) {
                _logger.log(MOD_NAME, "archiveSlot: failed to create deleted/ — " + err.message);
                return;
            }
            // Move our AP slot file into deleted/.
            var apFile:File = _configDir.resolvePath("slot_" + slotId + ".json");
            _logger.log(MOD_NAME, "archiveSlot: checking AP file=" + apFile.nativePath + " exists=" + apFile.exists);
            if (apFile.exists) {
                try {
                    apFile.moveTo(deletedDir.resolvePath("slot_" + slotId + "_" + timestamp + ".json"), true);
                    _logger.log(MOD_NAME, "Archived AP data for slot " + slotId);
                } catch (err:Error) {
                    _logger.log(MOD_NAME, "archiveSlot AP data error: " + err.message);
                }
            }
            // Copy the game's own save file into deleted/.
            var saveFile:File = File.applicationStorageDirectory.resolvePath("saveslot" + slotId + ".dat");
            if (saveFile.exists) {
                try {
                    saveFile.copyTo(deletedDir.resolvePath("saveslot" + slotId + "_" + timestamp + ".dat"), true);
                    _logger.log(MOD_NAME, "Archived game save for slot " + slotId
                        + " (" + saveFile.size + " bytes)");
                } catch (err:Error) {
                    _logger.log(MOD_NAME, "archiveSlot game save error: " + err.message);
                }
            } else {
                _logger.log(MOD_NAME, "archiveSlot: no game save found at " + saveFile.nativePath);
            }
        }

        // -----------------------------------------------------------------------
        // Connection overlay — shown over the game when not connected to AP.

        private function ensureConnectionOverlay():void {
            if (_blockingOverlay != null && _blockingOverlay.parent != null) {
                // Already on stage — nothing to do.
                return;
            }

            _logger.log(MOD_NAME, "ensureConnectionOverlay — building overlay"
                + "  overlayNull=" + (_blockingOverlay == null)
                + "  panelNull=" + (_connectionPanel == null)
                + "  stage=" + this.stage);

            if (_blockingOverlay == null) {
                _blockingOverlay = new Sprite();
                // Full-stage dark fill intercepts all mouse events below.
                _blockingOverlay.graphics.beginFill(0x000000, 0.88);
                _blockingOverlay.graphics.drawRect(-500, -500, 3000, 3000);
                _blockingOverlay.graphics.endFill();
            }

            if (_connectionPanel == null) {
                _connectionPanel = new ConnectionPanel();
                _logger.log(MOD_NAME, "ConnectionPanel created");
            }
            _connectionPanel.onConnect = onConnectionPanelConnect;
            _connectionPanel.onCancel  = dismissConnectionOverlay;
            _connectionPanel.prefill(_apHost, _apPort, _apSlot, _apPassword);

            if (_connectionPanel.parent != null) {
                _connectionPanel.parent.removeChild(_connectionPanel);
            }
            _blockingOverlay.addChild(_connectionPanel);
            _connectionPanel.centerOnStage(this.stage.stageWidth, this.stage.stageHeight);

            this.stage.addChild(_blockingOverlay);
            // Keep the toast above the overlay so messages remain visible.
            if (_toast != null && _toast.parent == this.stage) {
                this.stage.setChildIndex(_toast, this.stage.numChildren - 1);
            }
            _logger.log(MOD_NAME, "Connection overlay shown — stageW=" + this.stage.stageWidth
                + " stageH=" + this.stage.stageHeight
                + " overlayChildren=" + _blockingOverlay.numChildren);
        }

        private function dismissConnectionOverlay():void {
            var wasOnStage:Boolean = _blockingOverlay != null && _blockingOverlay.parent != null;
            if (wasOnStage) {
                _blockingOverlay.parent.removeChild(_blockingOverlay);
            }
            // If user cancelled, clear the pending click so they can retry.
            _pendingModeButton = null;
            _pendingModeTarget = null;
            _logger.log(MOD_NAME, "dismissConnectionOverlay — wasOnStage=" + wasOnStage);
        }

        private function onConnectionPanelConnect(host:String, port:int,
                                                   slot:String, password:String):void {
            _apHost     = host;
            _apPort     = port;
            _apSlot     = slot;
            _apPassword = password;
            saveSlotData();
            if (_ws != null) {
                _reconnecting = true;
                _ws.disconnect();   // fires onClose synchronously — suppressed by _reconnecting
                _reconnecting = false;
                _ws.connect(_apHost, _apPort, AP_SECURE);
                _logger.log(MOD_NAME, "Connecting to " + _apHost + ":" + _apPort
                    + "  slot=" + _apSlot);
            }
            // Overlay stays up until onOpen fires and sets _isConnected = true.
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

        // -----------------------------------------------------------------------
        // Stage / tile unlock API (called by debug panel and later by AP manager)

        /**
         * Reveal the map tile for a given stage letter, and for every stage
         * whose Journey XP is already >= 0.  Called once per selector session.
         */
        private function syncMapTilesWithStages():void {
            if (GV.ppd == null || GV.stageCollection == null) return;
            var metas:Array = GV.stageCollection.stageMetas;
            for (var i:int = 0; i < metas.length; i++) {
                var meta:* = metas[i];
                if (meta == null) continue;
                if (GV.ppd.stageHighestXpsJourney[meta.id].g() >= 0) {
                    var tileIdx:int = 90 - meta.strId.charCodeAt(0);
                    if (tileIdx >= 0 && tileIdx < GV.ppd.gainedMapTiles.length) {
                        GV.ppd.gainedMapTiles[tileIdx] = true;
                    }
                }
            }
        }

        /**
         * Make a stage available (Journey XP = 0) and reveal its map tile.
         * Refreshes the selector display if it is currently open.
         */
        public function unlockStage(stageStrId:String):void {
            if (GV.ppd == null) return;
            var stageId:int = GV.getFieldId(stageStrId);
            if (stageId < 0) {
                _logger.log(MOD_NAME, "unlockStage: unknown stage " + stageStrId);
                return;
            }
            GV.ppd.stageHighestXpsJourney[stageId].s(0);
            var tileIdx:int = 90 - stageStrId.charCodeAt(0);
            if (tileIdx >= 0 && tileIdx < GV.ppd.gainedMapTiles.length) {
                GV.ppd.gainedMapTiles[tileIdx] = true;
            }
            refreshSelectorIfOpen();
            _logger.log(MOD_NAME, "Stage unlocked: " + stageStrId);
        }

        /**
         * Lock a stage (Journey XP = -1).  Hides the map tile if no other
         * stage on the same tile is still unlocked.
         */
        public function lockStage(stageStrId:String):void {
            if (GV.ppd == null) return;
            var stageId:int = GV.getFieldId(stageStrId);
            if (stageId < 0) return;
            GV.ppd.stageHighestXpsJourney[stageId].s(-1);
            // Re-evaluate tile visibility.
            var letter:String = stageStrId.charAt(0);
            var tileIdx:int = 90 - letter.charCodeAt(0);
            if (tileIdx >= 0 && tileIdx < GV.ppd.gainedMapTiles.length) {
                var anyUnlocked:Boolean = false;
                var metas:Array = GV.stageCollection.stageMetas;
                for (var i:int = 0; i < metas.length; i++) {
                    var meta:* = metas[i];
                    if (meta != null && meta.strId.charAt(0) == letter
                            && GV.ppd.stageHighestXpsJourney[meta.id].g() >= 0) {
                        anyUnlocked = true;
                        break;
                    }
                }
                GV.ppd.gainedMapTiles[tileIdx] = anyUnlocked;
            }
            refreshSelectorIfOpen();
            _logger.log(MOD_NAME, "Stage locked: " + stageStrId);
        }

        /** Returns true if the stage's Journey XP >= 0 (available or completed). */
        public function isStageUnlocked(stageStrId:String):Boolean {
            if (GV.ppd == null) return false;
            var stageId:int = GV.getFieldId(stageStrId);
            if (stageId < 0) return false;
            return GV.ppd.stageHighestXpsJourney[stageId].g() >= 0;
        }

        /** Refreshes field-token and tile visibility on the selector if it is open. */
        public function refreshSelectorIfOpen():void {
            if (GV.selectorCore == null || GV.selectorCore.renderer == null) return;
            GV.selectorCore.renderer.setMapTilesVisibility();
            GV.selectorCore.renderer.adjustFieldTokens();
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

        // -----------------------------------------------------------------------
        // XP / wizard level handling

        /**
         * Grant AP wizard levels from a received XP Bonus item.
         * Small=2, Medium=5, Large=10 wizard levels — always additive on top
         * of the player's current wizard level, regardless of what it is.
         */
        public function grantXpBonus(apId:int):void {
            var levels:int = 0;
            var label:String = "";
            if      (apId == 500) { levels = 2;  label = "Small";  }
            else if (apId == 501) { levels = 5;  label = "Medium"; }
            else if (apId == 502) { levels = 10; label = "Large";  }
            else return;

            _apWizardLevel += levels;
            saveSlotData();

            _logger.log(MOD_NAME, label + " XP Bonus → +" + levels
                + " wizard levels (AP total: " + _apWizardLevel + ")");
            _toast.addMessage("+" + levels + " Wizard Levels (total: "
                + _apWizardLevel + ")", 0xFF88CCFF);

            applyApWizardLevels(_apWizardLevel);
        }

        /**
         * Ensure the game's wizard level is at least 'targetLevel', regardless
         * of what the player has earned from playing stages.
         *
         * How it works:
         *   getXp() (on PlayerProgressData) sums stageHighestXpsJourney +
         *   Endurance + Trial for every stage (values clamped to ≥0).
         *   W1 has no endurance mode so stageHighestXpsEndurance[W1] is always
         *   -1 (unused) and contributes 0 to the sum normally.
         *   We store our AP bonus XP there; the game's own sum picks it up and
         *   the wizard level display updates automatically.
         *
         * NOTE: we do NOT call GV.calculator or GV.ppd.getXp()/getWizLevel()
         * because Calculator → Monster → IngameRenderer pulls in mcStat UI
         * classes that are absent from the SWC stub (VerifyError #1014).
         * Instead we replicate the formula and XP sum locally.
         */
        private function applyApWizardLevels(targetLevel:int):void {
            if (GV.ppd == null || GV.stageCollection == null) return;
            if (targetLevel <= 0) return;

            var W1_END_IDX:int = GV.getFieldId("W1");

            // Read any bonus XP we previously stored in the W1 endurance slot.
            var prevBonus:Number = Math.max(0, GV.ppd.stageHighestXpsEndurance[W1_END_IDX].g());

            // Replicate PlayerProgressData.getXp() without calling the method.
            // Excludes our own bonus slot so we don't double-count.
            var normalXp:Number = 0;
            var metas:Array = GV.stageCollection.stageMetas;
            for (var i:int = 0; i < metas.length; i++) {
                var meta:* = metas[i];
                if (meta == null) continue;
                normalXp += Math.max(0, GV.ppd.stageHighestXpsJourney[meta.id].g());
                normalXp += Math.max(0, GV.ppd.stageHighestXpsTrial[meta.id].g());
                if (meta.id != W1_END_IDX) {
                    normalXp += Math.max(0, GV.ppd.stageHighestXpsEndurance[meta.id].g());
                }
            }

            // XP threshold for targetLevel — replicated from Calculator.calculatePlayerLevelXpReq.
            var bonusXp:Number = Math.max(0, apXpForWizLevel(targetLevel) - normalXp);

            GV.ppd.stageHighestXpsEndurance[W1_END_IDX].s(bonusXp > 0 ? bonusXp : -1);
            _logger.log(MOD_NAME, "applyApWizardLevels: target=" + targetLevel
                + " normalXp=" + normalXp + " bonusXp=" + bonusXp);
        }

        /**
         * XP required to reach wizard level pLevel.
         * Copied verbatim from Calculator.calculatePlayerLevelXpReq() to avoid
         * linking Calculator (and its mcStat dependency chain) into our SWF.
         */
        private function apXpForWizLevel(pLevel:int):Number {
            var vDelta2:Number = 30 + (pLevel - 1) * 5;
            var vDelta:Number  = 600 + vDelta2 / 2 * (pLevel - 1);
            return -10 + 10 * Math.round(0.8 * (300 + vDelta / 2 * (pLevel - 1)) / 10);
        }

        // -----------------------------------------------------------------------
        // Archipelago protocol

        /** Dispatch all packets in an incoming AP message (JSON array). */
        private function onApMessage(text:String):void {
            try {
                var packets:Array = JSON.parse(text) as Array;
                for each (var packet:Object in packets) {
                    handlePacket(packet);
                }
            } catch (e:Error) {
                _logger.log(MOD_NAME, "Failed to parse AP message: " + e.message);
                _toast.addMessage("AP parse error: " + e.message, 0xFFFF6666);
            }
        }

        private function handlePacket(p:Object):void {
            var cmd:String = p.cmd;
            _logger.log(MOD_NAME, "AP << " + cmd);

            switch (cmd) {
                case "RoomInfo":
                    _logger.log(MOD_NAME, "  seed=" + p.seed_name + "  server=" +
                        p.version.major + "." + p.version.minor + "." + p.version.build);
                    _toast.addMessage("AP: Have fun and play well!", 0xFF88DDFF);
                    sendConnect();
                    break;

                case "Connected":
                    handleConnected(p);
                    break;

                case "ReceivedItems":
                    handleReceivedItems(p);
                    break;

                case "ConnectionRefused":
                    var errors:Array = p.errors as Array;
                    var errMsg:String = errors && errors.length > 0 ? errors.join(", ") : "unknown reason";
                    _logger.log(MOD_NAME, "  ConnectionRefused: " + errMsg);
                    _isConnected = false;
                    if (_connectionPanel != null) {
                        _connectionPanel.resetState();
                        _connectionPanel.showError("Refused: " + errMsg);
                    }
                    _toast.addMessage("AP refused: " + errMsg, 0xFFFF6666);
                    break;

                case "PrintJSON":
                    // Ignore chat/notifications for now
                    break;

                default:
                    _logger.log(MOD_NAME, "  (unhandled)");
            }
        }

        private function handleReceivedItems(p:Object):void {
            var index:int   = p.index;
            var items:Array = p.items as Array;
            _logger.log(MOD_NAME, "ReceivedItems index=" + index + " count=" + items.length);

            if (index == 0) {
                // Initial sync: diff AP inventory against game state and reconcile.
                syncWithAP(items);
            } else {
                // Incremental: grant only the new items in this packet.
                for each (var networkItem:Object in items) {
                    var apId:int = networkItem.item;
                    _logger.log(MOD_NAME, "  + item=" + apId + " (" + itemName(apId) + ")");
                    grantItem(apId);
                }
            }
        }

        /**
         * Diff the full AP item list against the current game state and reconcile.
         * Only changes what is actually different — preserves skill levels, trait
         * levels and any completed stage XP.
         */
        private function syncWithAP(items:Array):void {
            if (GV.ppd == null) return;

            // Build expected state from the complete AP inventory
            var apSkills:Object = {};   // gameId (0-23) → true
            var apTraits:Object = {};   // gameId (0-14) → true
            var apTokens:Object = {};   // str_id → true
            var apXpTotal:int   = 0;    // wizard-level equivalents from AP

            for each (var item:Object in items) {
                var apId:int = item.item;
                if (apId >= 300 && apId <= 323) {
                    apSkills[apId - 300] = true;
                } else if (apId >= 400 && apId <= 414) {
                    apTraits[apId - 400] = true;
                } else if (_tokenMap[String(apId)] != null) {
                    apTokens[_tokenMap[String(apId)]] = true;
                } else if (apId == 500) apXpTotal += 2;
                  else if (apId == 501) apXpTotal += 5;
                  else if (apId == 502) apXpTotal += 10;
            }

            // --- Skills ---
            var skillChanges:int = 0;
            for (var i:int = 0; i < 24; i++) {
                var shouldHaveSkill:Boolean = apSkills[i] == true;
                if (GV.ppd.gainedSkillTomes[i] != shouldHaveSkill) {
                    GV.ppd.gainedSkillTomes[i] = shouldHaveSkill;
                    if (shouldHaveSkill) {
                        GV.ppd.setSkillLevel(i, Math.max(GV.ppd.getSkillLevel(i), 0));
                    } else {
                        GV.ppd.setSkillLevel(i, -1);
                    }
                    skillChanges++;
                }
            }

            // --- Traits ---
            var traitChanges:int = 0;
            for (var j:int = 0; j < 15; j++) {
                var shouldHaveTrait:Boolean = apTraits[j] == true;
                if (GV.ppd.gainedBattleTraits[j] != shouldHaveTrait) {
                    GV.ppd.gainedBattleTraits[j] = shouldHaveTrait;
                    if (shouldHaveTrait) {
                        GV.ppd.selectedBattleTraitLevels[j].s(
                            Math.max(GV.ppd.selectedBattleTraitLevels[j].g(), 0));
                    }
                    traitChanges++;
                }
            }

            // --- Stages ---
            var stageChanges:int = 0;
            if (GV.stageCollection != null) {
                var metas:Array = GV.stageCollection.stageMetas;
                for (var k:int = 0; k < metas.length; k++) {
                    var meta:* = metas[k];
                    if (meta == null) continue;
                    var xp:int = GV.ppd.stageHighestXpsJourney[meta.id].g();
                    if (xp == 0) {
                        // Only log accessible-but-unplayed stages — these are the interesting ones
                        var inTokenStages:Boolean = _tokenStages[meta.strId] == true;
                        var shouldHaveToken:Boolean = apTokens[meta.strId] == true;
                        _logger.log(MOD_NAME, "  stage=" + meta.strId
                            + " xp=" + xp
                            + " inTokenStages=" + inTokenStages
                            + " shouldHave=" + shouldHaveToken);
                    }
                    if (!_tokenStages[meta.strId]) continue; // no AP token (W1 etc) — always accessible
                    var shouldHave:Boolean = apTokens[meta.strId] == true;
                    if (shouldHave && xp < 0) {
                        unlockStage(meta.strId);
                        stageChanges++;
                    } else if (!shouldHave && xp == 0) {
                        lockStage(meta.strId);
                        stageChanges++;
                    }
                    // xp > 0 → stage completed, leave it alone
                }
            }

            // --- Wizard levels ---
            // Recompute the exact AP wizard level total from the full item list
            // (index=0 sync always gives us the ground truth from the server).
            _apWizardLevel = apXpTotal;
            saveSlotData();
            applyApWizardLevels(_apWizardLevel);

            _logger.log(MOD_NAME, "AP sync complete — skills:" + skillChanges +
                " traits:" + traitChanges + " stages:" + stageChanges +
                " apWizardLevel:" + _apWizardLevel);
        }

        /** Grant an item by its AP item ID. */
        private function grantItem(apId:int):void {
            // Field token
            var strId:String = _tokenMap[String(apId)];
            if (strId != null) {
                unlockStage(strId);
                _toast.addMessage("Unlocked: " + strId + " Field Token", 0xFFFFDD55);
                return;
            }

            // Skill (300–323)
            if (apId >= 300 && apId <= 323) {
                unlockSkill(apId);
                return;
            }

            // Battle trait (400–414)
            if (apId >= 400 && apId <= 414) {
                unlockBattleTrait(apId);
                return;
            }

            // XP Bonus (500–502)
            if (apId >= 500 && apId <= 502) {
                grantXpBonus(apId);
                return;
            }

            _logger.log(MOD_NAME, "  grantItem: no handler for AP ID " + apId);
        }

        private function handleConnected(p:Object):void {
            _isConnected = true;
            _needsConnection = false;
            loadSlotData(_currentSlot);
            // Save pending refs before dismissConnectionOverlay() clears them.
            var pendingBtn:* = _pendingModeButton;
            var pendingTarget:* = _pendingModeTarget;
            dismissConnectionOverlay();
            // If we intercepted a mode-selector click, re-dispatch it now so the
            // game continues with the chosen difficulty.
            if (pendingBtn != null) {
                _logger.log(MOD_NAME, "Re-dispatching mode button MOUSE_UP — btn=" + pendingBtn + "  target=" + pendingTarget);
                GV.pressedButton = pendingBtn;
                _allowModeClick  = true;
                pendingTarget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false));
                _allowModeClick  = false;
                _pendingModeButton = null;
                _pendingModeTarget = null;
            }
            _toast.addMessage("AP connected!", 0xFF88FF88);
            _logger.log(MOD_NAME, "  team=" + p.team + "  slot=" + p.slot);

            // Log all players in this multiworld
            var players:Array = p.players as Array;
            if (players) {
                for each (var player:Object in players) {
                    _logger.log(MOD_NAME, "  player: slot=" + player.slot +
                        "  name=" + player.alias + "  game=" + player.game);
                }
            }

            // Store token map and build inverse (str_id → has token)
            if (p.slot_data && p.slot_data.token_map) {
                _tokenMap = p.slot_data.token_map;
                _tokenStages = {};
                var tokenCount:int = 0;
                for (var apIdStr:String in _tokenMap) {
                    _tokenStages[_tokenMap[apIdStr]] = true;
                    tokenCount++;
                }
                _logger.log(MOD_NAME, "  token_map loaded: " + tokenCount + " entries");
            }
            _logger.log(MOD_NAME, "  goal=" + p.slot_data.goal + "  skill_placement=" + p.slot_data.skill_placement);

            var missing:Array  = p.missing_locations as Array;
            var checked:Array  = p.checked_locations as Array;
            _logger.log(MOD_NAME, "  missing_locations=" + (missing ? missing.length : "?") +
                "  checked_locations=" + (checked ? checked.length : "?"));

            // Build the missing-locations set so onSaveSave can check against it.
            _missingLocations = {};
            if (missing != null) {
                for each (var locId:int in missing) {
                    _missingLocations[locId] = true;
                }
            }

            _toast.addMessage("Slot connected! " + missing.length + " locations remaining", 0xFF88FF88);
        }

        /**
         * Called by the Bezel event bus after every save.
         * Detects battle victories and sends any newly-completed stage locations to AP.
         */
        private function onSaveSave(e:*):void {
            _logger.log(MOD_NAME, "onSaveSave fired — _isConnected=" + _isConnected
                + "  missingCount=" + countKeys(_missingLocations));
            if (!_isConnected) return;
            try {
                var hasController:Boolean = GV.ingameController != null;
                var hasCore:Boolean = hasController && GV.ingameController.core != null;
                _logger.log(MOD_NAME, "  ingameController=" + hasController + "  core=" + hasCore);
                if (!hasController || !hasCore) return;

                var ending:* = GV.ingameController.core.ending;
                _logger.log(MOD_NAME, "  ending=" + ending
                    + "  isBattleWon=" + (ending != null ? ending.isBattleWon : "n/a"));
                if (ending == null || !ending.isBattleWon) return;

                var hasPpd:Boolean       = GV.ppd != null;
                var hasMetas:Boolean     = GV.stageCollection != null && GV.stageCollection.stageMetas != null;
                _logger.log(MOD_NAME, "  ppd=" + hasPpd + "  stageMetas=" + hasMetas);
                if (!hasPpd || !hasMetas) return;

                var metas:Array = GV.stageCollection.stageMetas;
                _logger.log(MOD_NAME, "  metas.length=" + metas.length);

                var toSend:Array = [];
                for (var i:int = 0; i < metas.length; i++) {
                    var meta:* = metas[i];
                    if (meta == null) continue;
                    var xp:int = GV.ppd.stageHighestXpsJourney[meta.id].g();
                    if (xp <= 0) continue;
                    var locId:int = int(STAGE_LOC_AP_IDS[meta.strId]);
                    _logger.log(MOD_NAME, "  stage=" + meta.strId + "  xp=" + xp
                        + "  locId=" + locId
                        + "  journeyMissing=" + (_missingLocations[locId] == true)
                        + "  bonusMissing="   + (_missingLocations[locId + 500] == true));
                    if (locId <= 0) continue;
                    if (_missingLocations[locId])       toSend.push(locId);
                    if (_missingLocations[locId + 500]) toSend.push(locId + 500);
                }
                _logger.log(MOD_NAME, "  toSend=" + toSend.join(",") + "  (" + toSend.length + " checks)");
                if (toSend.length > 0) {
                    for each (var sentId:int in toSend) {
                        delete _missingLocations[sentId];
                    }
                    sendLocationChecks(toSend);
                }
            } catch (err:Error) {
                _logger.log(MOD_NAME, "onSaveSave ERROR: " + err.message + "\n" + err.getStackTrace());
            }
        }

        // -----------------------------------------------------------------------
        // File-based config storage
        // connection.json  — host/port/slot/password (shared across all slots)
        // slot_N.json      — per-save-slot AP state (wizard levels, etc.)

        private function loadSlotData(slotId:int):void {
            // Reset to defaults before loading — ensures clean state for each slot.
            _apHost        = "localhost";
            _apPort        = 38281;
            _apSlot        = "";
            _apPassword    = "";
            _apWizardLevel = 0;
            if (slotId <= 0) return;
            var f:File = _configDir.resolvePath("slot_" + slotId + ".json");
            if (!f.exists) {
                _logger.log(MOD_NAME, "No slot_" + slotId + ".json — fresh slot, using defaults");
                return;
            }
            try {
                var stream:FileStream = new FileStream();
                stream.open(f, FileMode.READ);
                var raw:String = stream.readUTFBytes(stream.bytesAvailable);
                stream.close();
                var data:Object = JSON.parse(raw);
                if (data.host           !== undefined) _apHost        = String(data.host);
                if (data.port           !== undefined) _apPort        = int(data.port);
                if (data.slot           !== undefined) _apSlot        = String(data.slot);
                if (data.password       !== undefined) _apPassword    = String(data.password);
                if (data.apWizardLevels !== undefined) _apWizardLevel = int(data.apWizardLevels);
                _logger.log(MOD_NAME, "Loaded slot_" + slotId + ".json — host=" + _apHost
                    + " port=" + _apPort + " slot='" + _apSlot
                    + "' apWizardLevels=" + _apWizardLevel);
            } catch (err:Error) {
                _logger.log(MOD_NAME, "loadSlotData ERROR: " + err.message);
            }
        }

        private function saveSlotData():void {
            if (_currentSlot <= 0 || _configDir == null) return;
            try {
                if (!_configDir.exists) _configDir.createDirectory();
                var f:File = _configDir.resolvePath("slot_" + _currentSlot + ".json");
                var data:Object = {
                    host:          _apHost,
                    port:          _apPort,
                    slot:          _apSlot,
                    password:      _apPassword,
                    apWizardLevels: _apWizardLevel
                };
                var stream:FileStream = new FileStream();
                stream.open(f, FileMode.WRITE);
                stream.writeUTFBytes(JSON.stringify(data, null, 2));
                stream.close();
                _logger.log(MOD_NAME, "Saved slot_" + _currentSlot + ".json");
            } catch (err:Error) {
                _logger.log(MOD_NAME, "saveSlotData ERROR: " + err.message);
            }
        }

        private function countKeys(obj:Object):int {
            var n:int = 0;
            for (var k:String in obj) n++;
            return n;
        }

        /**
         * Tell the server one or more locations have been checked.
         * For a Journey completion, pass both the Journey ID and Bonus ID (journey + 500).
         */
        public function sendLocationChecks(locationIds:Array):void {
            if (_ws == null || locationIds.length == 0) return;
            var packet:String = '[{"cmd":"LocationChecks","locations":[' + locationIds.join(",") + ']}]';
            _logger.log(MOD_NAME, "AP >> LocationChecks  ids=" + locationIds.join(","));
            _ws.send(packet);
        }

        /**
         * Human-readable name for an AP item ID.
         * Returns the raw ID as a string if not recognised.
         */
        private function itemName(apId:int):String {
            if (apId >= 300 && apId <= 323) return SKILL_NAMES[apId - 300] + " Skill";
            if (apId >= 400 && apId <= 414) return BATTLE_TRAIT_NAMES[apId - 400] + " Battle Trait";
            if (apId >= 1   && apId <= 199) return "Field Token (id=" + apId + ")";
            if (apId == 500) return "Small XP Bonus";
            if (apId == 501) return "Medium XP Bonus";
            if (apId == 502) return "Large XP Bonus";
            return "Item #" + apId;
        }

        /** Send the Connect packet to identify this slot to the server. */
        private function sendConnect():void {
            var packet:String = '[{"cmd":"Connect",' +
                '"game":"GemCraft: Frostborn Wrath",' +
                '"name":"' + _apSlot + '",' +
                '"password":"' + _apPassword + '",' +
                '"version":{"major":0,"minor":6,"build":6,"class":"Version"},' +
                '"items_handling":7,' +
                '"tags":[],' +
                '"uuid":"gcfw-mod"}]';
            _logger.log(MOD_NAME, "AP >> Connect  slot=" + _apSlot);
            _ws.send(packet);
        }
    }
}
