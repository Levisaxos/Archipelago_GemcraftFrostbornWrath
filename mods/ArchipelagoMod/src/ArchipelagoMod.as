package {
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;

    import Bezel.Bezel;
    import Bezel.BezelMod;
    import Bezel.Logger;
    import Bezel.GCFW.Events.EventTypes;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.ScreenId;

    /**
     * Main mod class — orchestrates all subsystems.
     *
     * Subsystems:
     *   ConnectionManager        — AP protocol, WebSocket lifecycle, toasts
     *   ConnectionPanel          — Connection UI overlay (self-managing)
     *   ModeSelectorInterceptor  — Mode button / delete button hooks
     *   NormalProgressionBlocker — Reverts auto-unlocks after battles
     *   SkillUnlocker            — Skill unlock logic
     *   TraitUnlocker            — Battle trait unlock logic
     *   StageUnlocker            — Stage / tile unlock logic
     *   LevelUnlocker            — Wizard level / XP bonus logic
     *   FileHandler              — Slot JSON persistence
     *   ToastPanel               — On-screen notifications
     *   ScrDebugOptions          — Debug panel
     */
    public class ArchipelagoMod extends MovieClip implements BezelMod {

        public function get VERSION():String       { return "0.0.1"; }
        public function get MOD_NAME():String      { return "ArchipelagoMod"; }
        public function get BEZEL_VERSION():String { return "2.1.1"; }

        private static const TOAST_OFFSET_X:Number = 52;
        private static const TOAST_OFFSET_Y:Number = 10;

        private var _logger:Logger;
        private var _bezel:Bezel;
        private var _btn:ArchipelagoButton;
        private var _buttonAdded:Boolean = false;

        private var _toast:ToastPanel;
        private var _toastOnStage:Boolean = false;

        private var _debugOptions:ScrDebugOptions;
        private var _normalProgressionBlocker:NormalProgressionBlocker;
        private var _connectionManager:ConnectionManager;
        private var _connectionPanel:ConnectionPanel;
        private var _modeInterceptor:ModeSelectorInterceptor;
        private var _fileHandler:FileHandler;
        private var _skillUnlocker:SkillUnlocker;
        private var _traitUnlocker:TraitUnlocker;
        private var _stageUnlocker:StageUnlocker;
        private var _levelUnlocker:LevelUnlocker;

        private var _keyListenerAdded:Boolean  = false;
        private var _needsConnection:Boolean   = false;
        private var _currentSlot:int           = 0;
        private var _lastScreen:int            = -1;
        private var _mapTilesUnlocked:Boolean  = false;
        private var _slotCompleted:Boolean     = false;

        // Debug mode — toggled by Ctrl+Shift+Alt+End.
        private static const DEBUG_MODE_DEFAULT:Boolean = false;
        private var _debugMode:Boolean = DEBUG_MODE_DEFAULT;

        public function ArchipelagoMod() {
            super();
            _logger = Logger.getLogger(MOD_NAME);
        }

        // -----------------------------------------------------------------------
        // Lifecycle

        public function bind(bezel:Bezel, gameObjects:Object):void {
            try {
                _bezel = bezel;

                // Create subsystems
                _toast         = new ToastPanel();
                _fileHandler   = new FileHandler(_logger, MOD_NAME);
                _skillUnlocker = new SkillUnlocker(_logger, MOD_NAME, _toast);
                _traitUnlocker = new TraitUnlocker(_logger, MOD_NAME, _toast);
                _stageUnlocker = new StageUnlocker(_logger, MOD_NAME);
                _levelUnlocker = new LevelUnlocker(_logger, MOD_NAME, _toast);
                _levelUnlocker.onDataChanged = saveSlotData;

                _debugOptions = new ScrDebugOptions(this);

                _normalProgressionBlocker = new NormalProgressionBlocker(_logger, MOD_NAME);
                _normalProgressionBlocker.enable(_bezel);

                // Connection manager — AP protocol + WebSocket
                _connectionManager = new ConnectionManager(_logger, MOD_NAME, _toast);
                _connectionManager.onConnected            = onApConnected;
                _connectionManager.onFullSync             = syncWithAP;
                _connectionManager.onItemReceived         = grantItem;
                _connectionManager.onError                = onConnectionError;
                _connectionManager.onPanelReset           = onConnectionPanelReset;
                _connectionManager.setItemNameResolver(itemName);
                _connectionManager.load();

                // Connection panel (lazy — created on first use)
                _connectionPanel = null;

                // Mode-selector interceptor
                _modeInterceptor = new ModeSelectorInterceptor(_logger, MOD_NAME, _toast);
                _modeInterceptor.onModeIntercepted    = onModeIntercepted;
                _modeInterceptor.onSlotDeleteWarning   = onSlotDeleteWarning;
                _modeInterceptor.onSlotDeleteConfirmed = onSlotDeleteConfirmed;

                _bezel.addEventListener(EventTypes.SAVE_SAVE, onSaveSave);
                addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
                _logger.log(MOD_NAME, "ArchipelagoMod loaded!");
            } catch (err:Error) {
                _logger.log(MOD_NAME, "BIND ERROR: " + err.message + "\n" + err.getStackTrace());
            }
        }

        public function unload():void {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            if (_bezel != null) _bezel.removeEventListener(EventTypes.SAVE_SAVE, onSaveSave);
            if (_connectionManager != null) {
                _connectionManager.unload();
                _connectionManager = null;
            }
            if (_normalProgressionBlocker != null) {
                _normalProgressionBlocker.disable();
                _normalProgressionBlocker = null;
            }
            if (_modeInterceptor != null) {
                _modeInterceptor.unhook();
                _modeInterceptor = null;
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
            if (_connectionPanel != null) {
                _connectionPanel.dismiss();
            }
            _connectionPanel = null;
            if (_btn != null && _btn.parent != null) {
                _btn.parent.removeChild(_btn);
                _btn = null;
            }
            _buttonAdded = false;
            _logger.log(MOD_NAME, "ArchipelagoMod unloaded");
        }

        // -----------------------------------------------------------------------
        // Delegating wrappers — used by ScrDebugOptions.

        public function unlockSkill(apId:int):void { _skillUnlocker.unlockSkill(apId); }
        public function unlockBattleTrait(apId:int):void { _traitUnlocker.unlockBattleTrait(apId); }
        public function unlockStage(stageStrId:String):void { _stageUnlocker.unlockStage(stageStrId); }
        public function lockStage(stageStrId:String):void { _stageUnlocker.lockStage(stageStrId); }
        public function isStageUnlocked(stageStrId:String):Boolean { return _stageUnlocker.isStageUnlocked(stageStrId); }

        // -----------------------------------------------------------------------
        // Frame loop

        private function onEnterFrame(e:Event):void {
            // Add toast to stage once available.
            if (!_toastOnStage && _toast != null && this.stage != null) {
                this.stage.addChild(_toast);
                _toastOnStage = true;
                positionToast();
                this.stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);
            }

            // Register the debug hotkey once the stage exists.
            if (!_keyListenerAdded && this.stage != null) {
                this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
                _keyListenerAdded = true;
            }

            // Track screen transitions.
            var screen:int = int(GV.main.currentScreen);
            if (_lastScreen == -1) {
                _lastScreen = screen;
                _logger.log(MOD_NAME, "Screen init — currentScreen=" + screen);
            }
            if (screen != _lastScreen) {
                _logger.log(MOD_NAME, "Screen change: " + _lastScreen + " → " + screen
                    + "  _isConnected=" + _connectionManager.isConnected
                    + "  _needsConnection=" + _needsConnection);

                // Entering LOADGAME — always reset connection so leaving LOADGAME
                // sees _isConnected=false and triggers the overlay when needed.
                if (screen == ScreenId.LOADGAME) {
                    _connectionManager.disconnectAndReset();
                    _needsConnection = false;
                    if (_connectionPanel != null) _connectionPanel.dismiss();
                    _modeInterceptor.clearPending();
                    _logger.log(MOD_NAME, "Entered LOADGAME — connection reset");
                }

                if (_lastScreen == ScreenId.LOADGAME) {
                    _modeInterceptor.unhook();
                    if (screen != ScreenId.MAINMENU) {
                        _currentSlot = int(GV.loaderSaver.activeSlotId) + 1;
                        if (!_connectionManager.isConnected) {
                            _needsConnection = true;
                            _connectionManager.disconnect();
                            _logger.log(MOD_NAME, "Left LOADGAME not-connected — slot=" + _currentSlot
                                + "  needsConnection=true");
                        } else {
                            _logger.log(MOD_NAME, "Left LOADGAME already-connected — slot=" + _currentSlot);
                        }
                    }
                }
                if (screen == ScreenId.TRANS_SELECTOR_TO_INGAME1 ||
                    screen == ScreenId.TRANS_SELECTOR_TO_INGAME2 ||
                    screen == ScreenId.INGAME) {
                    skipAllTutorials();
                }
                _lastScreen = screen;
            }

            // Hook mode selector buttons while on LOADGAME.
            if (screen == ScreenId.LOADGAME && !_modeInterceptor.isHooked) {
                _modeInterceptor.hook(this.stage);
            }

            // Connection required (e.g. Continue button bypassed our interceptor).
            if (_needsConnection && !_connectionManager.isConnected && this.stage != null) {
                _needsConnection = false;
                startConnectionForSlot();
            }

            // Gate: wait until the selector and its async tile generation are fully ready.
            if (GV.ppd == null
                    || GV.selectorCore.renderer == null
                    || GV.selectorCore.mapTiles == null) {
                _mapTilesUnlocked = false;
                return;
            }

            var mc:* = GV.selectorCore.mc;
            if (mc == null) return;

            // Sync tile visibility once per selector session.
            if (!_mapTilesUnlocked) {
                _stageUnlocker.syncMapTilesWithStages();
                GV.selectorCore.renderer.setMapTilesVisibility();
                _mapTilesUnlocked = true;
                _logger.log(MOD_NAME, "Map tile visibility synced with stage states");
            }

            _stageUnlocker.enforceFullWorldScrollLimits();

            if (mc.btnTutorial == null) return;

            if (!_buttonAdded) {
                if (mc.btnSkills == null || mc.btnTalisman == null) return;
                addArchipelagoButton(mc);
                _buttonAdded = true;
            }

            if (_btn != null) {
                _btn.x = mc.btnTutorial.x;
            }

            if (_debugOptions != null && _debugOptions.isOpen) {
                _debugOptions.doEnterFrame();
            }
        }

        // -----------------------------------------------------------------------
        // Toast positioning

        private function positionToast():void {
            if (_toast == null || this.stage == null) return;
            var gameRoot:* = this.stage.getChildAt(0);
            _toast.x = gameRoot.x + TOAST_OFFSET_X * gameRoot.scaleX;
            _toast.y = gameRoot.y + TOAST_OFFSET_Y * gameRoot.scaleY;
        }

        private function onStageResize(e:Event):void {
            positionToast();
        }

        // -----------------------------------------------------------------------
        // Archipelago button + debug hotkey

        private function addArchipelagoButton(mc:*):void {
            var stepY:Number = mc.btnTalisman.y - mc.btnSkills.y;
            _btn = new ArchipelagoButton(mc.btnTutorial);
            _btn.x = mc.btnTutorial.x;
            _btn.y = mc.btnTutorial.y + stepY;
            _btn.visible = true;
            _btn.addEventListener(MouseEvent.CLICK, onArchipelagoClicked, false, 0, true);
            mc.addChild(_btn);
            _logger.log(MOD_NAME, "Archipelago button added at (" + _btn.x + ", " + _btn.y + ")");
        }

        private function onKeyDown(e:KeyboardEvent):void {
            if (e.keyCode == Keyboard.END && e.ctrlKey && e.shiftKey && e.altKey) {
                _debugMode = !_debugMode;
                _logger.log(MOD_NAME, "Debug mode " + (_debugMode ? "ON" : "OFF"));
                if (!_debugMode && _debugOptions != null && _debugOptions.isOpen) {
                    _debugOptions.close();
                }
            }
        }

        private function onArchipelagoClicked(e:MouseEvent):void {
            if (_debugOptions == null) return;
            if (_debugOptions.isOpen) {
                _debugOptions.close();
            } else {
                _debugOptions.open();
            }
        }

        // -----------------------------------------------------------------------
        // Tutorials

        private function skipAllTutorials():void {
            try {
                var pages:Array = GV.ppd.gainedTutorialPages;
                for (var i:int = 0; i < pages.length; i++) {
                    pages[i] = true;
                }
                GV.main.ctrlTutorPanels.dismissAllTutorsInQueue();
                if (GV.ingameCore != null) {
                    GV.ingameCore.isFirstStageFirstTime      = false;
                    GV.ingameCore.isFirstStageTutorialRunning = false;
                }
                _logger.log(MOD_NAME, "Tutorials skipped");
            } catch (err:Error) {
                _logger.log(MOD_NAME, "skipAllTutorials error: " + err.message);
            }
            _stageUnlocker.logStageEntered(_currentSlot);
        }

        // -----------------------------------------------------------------------
        // ModeSelectorInterceptor callbacks

        private function onModeIntercepted(slotId:int, pendingBtn:*, pendingTarget:*):void {
            _currentSlot = slotId;
            startConnectionForSlot();
        }

        private function onSlotDeleteWarning(slotId:int):void {
            if (!_fileHandler.isSlotCompleted(slotId)) {
                _toast.addMessage(
                    "Warning: slot " + slotId + " is not yet completed.\n"
                    + "Deleting will lose most of your progress.\n"
                    + "Press D to confirm.",
                    0xFFFF8844);
            }
        }

        private function onSlotDeleteConfirmed(slotId:int):void {
            _fileHandler.deleteSlot(slotId);
        }

        // -----------------------------------------------------------------------
        // Connection

        /**
         * Load saved credentials for the current slot and either auto-connect
         * (if a slot name is on file) or show the connection overlay.
         * Called whenever we need a connection — on mode/continue intercept
         * and as a fallback when leaving LOADGAME undetected.
         */
        private function startConnectionForSlot():void {
            loadSlotData(_currentSlot);
            if (_connectionManager.apSlot.length > 0) {
                _logger.log(MOD_NAME, "Auto-connecting slot=" + _currentSlot
                    + "  host=" + _connectionManager.apHost
                    + "  apSlot=" + _connectionManager.apSlot);
                _connectionManager.connect(
                    _connectionManager.apHost,
                    _connectionManager.apPort,
                    _connectionManager.apSlot,
                    _connectionManager.apPassword);
            } else {
                ensureConnectionOverlay();
            }
        }

        private function ensureConnectionOverlay():void {
            if (_connectionPanel != null && _connectionPanel.isShowing) return;

            if (_connectionPanel == null) {
                _connectionPanel = new ConnectionPanel();
                _logger.log(MOD_NAME, "ConnectionPanel created");
            }
            _connectionPanel.onConnect = onConnectionPanelConnect;
            _connectionPanel.onCancel  = onConnectionPanelCancel;
            _connectionPanel.prefill(
                _connectionManager.apHost,
                _connectionManager.apPort,
                _connectionManager.apSlot,
                _connectionManager.apPassword
            );
            _connectionPanel.showWithOverlay(this.stage, _toast);
            _logger.log(MOD_NAME, "Connection overlay shown");
        }

        private function onConnectionPanelConnect(host:String, port:int,
                                                   slot:String, password:String):void {
            _logger.log(MOD_NAME, "PLAYER_SUBMITTED_CONNECTION host=" + host
                + "  port=" + port + "  slot=" + slot
                + "  hasPassword=" + (password.length > 0));
            _connectionManager.connect(host, port, slot, password);
            saveSlotData();
        }

        private function onConnectionPanelCancel():void {
            if (_connectionPanel != null) _connectionPanel.dismiss();
            _modeInterceptor.clearPending();
        }

        // -----------------------------------------------------------------------
        // ConnectionManager callbacks

        private function onApConnected(p:Object):void {
            _needsConnection = false;
            loadSlotData(_currentSlot);
            if (_connectionPanel != null) _connectionPanel.dismiss();
            _modeInterceptor.redispatchPendingClick();
        }

        private function onConnectionError(msg:String):void {
            // Auto-connect failed — show the overlay so the player can correct settings.
            ensureConnectionOverlay();
            if (_connectionPanel != null) _connectionPanel.showError(msg);
        }

        private function onConnectionPanelReset():void {
            if (_connectionPanel != null) _connectionPanel.resetState();
        }

        // -----------------------------------------------------------------------
        // Slot data

        private function loadSlotData(slotId:int):void {
            _connectionManager.resetSettings();
            _levelUnlocker.bonusWizardLevel = 0;
            _slotCompleted = false;
            var data:Object = _fileHandler.loadSlotData(slotId);
            if (data != null) {
                if (data.host             !== undefined) _connectionManager.apHost       = String(data.host);
                if (data.port             !== undefined) _connectionManager.apPort       = int(data.port);
                if (data.slot             !== undefined) _connectionManager.apSlot       = String(data.slot);
                if (data.password         !== undefined) _connectionManager.apPassword   = String(data.password);
                if (data.bonusWizardLevel !== undefined) _levelUnlocker.bonusWizardLevel = int(data.bonusWizardLevel);
                if (data.completed        !== undefined) _slotCompleted                  = data.completed === true;
            }
        }

        private function saveSlotData():void {
            if (_currentSlot <= 0) return;
            var data:Object = {
                host:             _connectionManager.apHost,
                port:             _connectionManager.apPort,
                slot:             _connectionManager.apSlot,
                password:         _connectionManager.apPassword,
                bonusWizardLevel: _levelUnlocker.bonusWizardLevel,
                completed:        _slotCompleted
            };
            _fileHandler.saveSlotData(_currentSlot, data);
        }

        /** Call this when the player reaches the Archipelago goal. */
        public function markSlotCompleted():void {
            _slotCompleted = true;
            saveSlotData();
            _logger.log(MOD_NAME, "Slot " + _currentSlot + " marked as completed");
        }

        // -----------------------------------------------------------------------
        // Item handling

        private function grantItem(apId:int):void {
            var strId:String = _connectionManager.tokenMap[String(apId)];
            if (strId != null) {
                _stageUnlocker.unlockStage(strId);
                _toast.addMessage("Unlocked: " + strId + " Field Token", 0xFFFFDD55);
                return;
            }
            if (apId >= 300 && apId <= 323) { _skillUnlocker.unlockSkill(apId); return; }
            if (apId >= 400 && apId <= 414) { _traitUnlocker.unlockBattleTrait(apId); return; }
            if (apId >= 500 && apId <= 502) { _levelUnlocker.grantXpBonus(apId); return; }
            _logger.log(MOD_NAME, "  grantItem: no handler for AP ID " + apId);
        }

        private function syncWithAP(items:Array):void {
            if (GV.ppd == null) return;

            var apSkills:Object = {};
            var apTraits:Object = {};
            var apTokens:Object = {};
            var apXpTotal:int   = 0;
            var tokenMap:Object    = _connectionManager.tokenMap;
            var tokenStages:Object = _connectionManager.tokenStages;

            for each (var item:Object in items) {
                var apId:int = item.item;
                if (apId >= 300 && apId <= 323) {
                    apSkills[apId - 300] = true;
                } else if (apId >= 400 && apId <= 414) {
                    apTraits[apId - 400] = true;
                } else if (tokenMap[String(apId)] != null) {
                    apTokens[tokenMap[String(apId)]] = true;
                } else if (apId == 500) apXpTotal += 1;
                  else if (apId == 501) apXpTotal += 3;
                  else if (apId == 502) apXpTotal += 9;
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
                        _logger.log(MOD_NAME, "  stage=" + meta.strId
                            + " xp=" + xp
                            + " inTokenStages=" + (tokenStages[meta.strId] == true)
                            + " shouldHave=" + (apTokens[meta.strId] == true));
                    }
                    if (!tokenStages[meta.strId]) continue;
                    var shouldHave:Boolean = apTokens[meta.strId] == true;
                    if (shouldHave && xp < 0) {
                        _stageUnlocker.unlockStage(meta.strId);
                        stageChanges++;
                    } else if (!shouldHave && xp == 0) {
                        _stageUnlocker.lockStage(meta.strId);
                        stageChanges++;
                    }
                }
            }

            // --- Wizard levels ---
            _levelUnlocker.bonusWizardLevel = apXpTotal;
            saveSlotData();

            _logger.log(MOD_NAME, "AP sync complete — skills:" + skillChanges +
                " traits:" + traitChanges + " stages:" + stageChanges +
                " apWizardLevel:" + _levelUnlocker.bonusWizardLevel);
        }

        // -----------------------------------------------------------------------
        // Save hook — detects battle victories and sends location checks

        private function onSaveSave(e:*):void {
            _logger.log(MOD_NAME, "onSaveSave fired — _isConnected=" + _connectionManager.isConnected);
            _connectionManager.checkCompletedLocations();
        }

        // -----------------------------------------------------------------------
        // Helpers

        private function itemName(apId:int):String {
            var skillName:String = _skillUnlocker.getSkillName(apId);
            if (skillName != null) return skillName + " Skill";
            var traitName:String = _traitUnlocker.getTraitName(apId);
            if (traitName != null) return traitName + " Battle Trait";
            return null; // let ConnectionManager handle the rest
        }
    }
}
