package {
    import flash.display.MovieClip;
    import flash.display.Sprite;
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
    
    import goals.GoalManager;

    import ui.ArchipelagoButton
    import ui.ReportIssuesButton
    import ui.ToastPanel
    import ui.ItemToastPanel
    import ui.MessageLog
    import ui.MessageLogPanel
    import ui.ScrDebugOptions
    import ui.ConnectionPanel
    import ui.DisconnectPanel
    
    import deathlink.DeathLinkHandler
    import deathlink.EnragerOverride

    import unlockers.NormalProgressionBlocker
    import unlockers.SkillUnlocker
    import unlockers.TraitUnlocker
    import unlockers.LevelUnlocker
    import unlockers.StageUnlocker
    import unlockers.TalismanUnlocker
    import unlockers.ShadowCoreUnlocker

    import net.ConnectionManager

    import patch.WizStashes
    import patch.FirstPlayBypass

    import save.FileHandler
    import save.SaveManager

    
    

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
     *   DeathLinkHandler         — DeathLink send/receive and punishment application
     *   GoalManager              — Detects goal completion, fires onGoalReached once
     *   SaveManager              — Slot JSON persistence (coordinates FileHandler/ConnectionManager/LevelUnlocker)
     *   FileHandler              — Raw slot file I/O
     *   ToastPanel               — On-screen notifications
     *   ScrDebugOptions          — Debug panel
     */
    public class ArchipelagoMod extends MovieClip implements BezelMod {

        public function get VERSION():String       { return "0.0.2"; }
        public function get MOD_NAME():String      { return "ArchipelagoMod"; }
        public function get BEZEL_VERSION():String { return "2.1.1"; }

        private static const TOAST_OFFSET_X:Number      = 52;
        private static const TOAST_OFFSET_Y:Number      = 10;
        private static const ITEM_TOAST_OFFSET_Y:Number = 18; // game pixels from top edge

        private var _logger:Logger;
        private var _bezel:Bezel;
        private var _btn:ArchipelagoButton;
        private var _reportBtn:ReportIssuesButton;
        private var _buttonAdded:Boolean = false;

        private var _toast:ToastPanel;
        private var _toastOnStage:Boolean = false;

        private var _itemToast:ItemToastPanel;
        private var _itemToastOnStage:Boolean = false;

        private var _messageLog:MessageLog;
        private var _messageLogPanel:MessageLogPanel;
        private var _messageLogOnStage:Boolean = false;

        private var _debugOptions:ScrDebugOptions;
        private var _normalProgressionBlocker:NormalProgressionBlocker;
        private var _connectionManager:ConnectionManager;
        private var _connectionPanel:ConnectionPanel;
        private var _disconnectPanel:DisconnectPanel;
        private var _disconnectPanelOnStage:Boolean = false;
        private var _modeInterceptor:ModeSelectorInterceptor;
        private var _deathLinkHandler:DeathLinkHandler;
        private var _goalManager:GoalManager;
        private var _fileHandler:FileHandler;
        private var _saveManager:SaveManager;
        private var _skillUnlocker:SkillUnlocker;
        private var _traitUnlocker:TraitUnlocker;
        private var _stageUnlocker:StageUnlocker;
        private var _levelUnlocker:LevelUnlocker;
        private var _talismanUnlocker:TalismanUnlocker;
        private var _shadowCoreUnlocker:ShadowCoreUnlocker;
        private var _firstPlayBypass:FirstPlayBypass;

        private var _keyListenerAdded:Boolean  = false;
        private var _needsConnection:Boolean   = false;
        private var _lastScreen:int            = -1;
        private var _mapTilesUnlocked:Boolean  = false;
        private var _standalone:Boolean        = false;
        private var _pendingSyncItems:Array    = null; // deferred full-sync when GV.ppd was null
        private var _lastPpd:Object            = null; // tracks ppd identity to detect slot changes

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
                _messageLog    = new MessageLog();
                _toast         = new ToastPanel();
                _itemToast     = new ItemToastPanel();
                _toast.messageLog = _messageLog;
                _messageLogPanel = new MessageLogPanel(_messageLog);
                _fileHandler   = new FileHandler(_logger, MOD_NAME);
                _skillUnlocker      = new SkillUnlocker(_logger, MOD_NAME, _itemToast);
                _traitUnlocker      = new TraitUnlocker(_logger, MOD_NAME, _itemToast);
                _stageUnlocker      = new StageUnlocker(_logger, MOD_NAME);
                _levelUnlocker      = new LevelUnlocker(_logger, MOD_NAME, _itemToast);
                _talismanUnlocker   = new TalismanUnlocker(_logger, MOD_NAME, _itemToast);
                _shadowCoreUnlocker = new ShadowCoreUnlocker(_logger, MOD_NAME, _itemToast);
                _firstPlayBypass    = new FirstPlayBypass(_logger, MOD_NAME);

                _debugOptions = new ScrDebugOptions(this);

                _normalProgressionBlocker = new NormalProgressionBlocker(_logger, MOD_NAME);
                _normalProgressionBlocker.enable(_bezel);

                // Connection manager — AP protocol + WebSocket
                _connectionManager = new ConnectionManager(_logger, MOD_NAME, _toast);
                _connectionManager.setItemToast(_itemToast);
                _connectionManager.setMessageLog(_messageLog);
                _connectionManager.onConnected             = onApConnected;
                _connectionManager.onFullSync              = syncWithAP;
                _connectionManager.onItemReceived          = grantItem;
                _connectionManager.onError                 = onConnectionError;
                _connectionManager.onPanelReset            = onConnectionPanelReset;
                _connectionManager.onUnexpectedDisconnect  = onApUnexpectedlyDisconnected;
                _connectionManager.setItemNameResolver(itemName);
                _connectionManager.load();

                // Disconnect banner (shown when AP drops unexpectedly)
                _disconnectPanel = new DisconnectPanel();
                _disconnectPanel.onReconnect = onDisconnectPanelReconnect;

                _saveManager = new SaveManager(_logger, MOD_NAME,
                _fileHandler, _connectionManager, _levelUnlocker);
                _saveManager.shadowCoreUnlocker = _shadowCoreUnlocker;
                _saveManager.talismanUnlocker   = _talismanUnlocker;
                _levelUnlocker.onDataChanged = _saveManager.saveSlotData;

                _deathLinkHandler = new DeathLinkHandler(_logger, MOD_NAME, _toast);
                _deathLinkHandler.onPlayerDied         = onPlayerDied;
                _deathLinkHandler.onPunishmentReceived = onPunishmentReceived;
                _connectionManager.onDeathLinkReceived = onDeathLinkReceived;

                _goalManager = new GoalManager(_logger, MOD_NAME, _itemToast);
                _goalManager.onGoalReached = onGoalReached;

                // Connection panel (lazy — created on first use)
                _connectionPanel = null;

                // Mode-selector interceptor
                _modeInterceptor = new ModeSelectorInterceptor(_logger, MOD_NAME, _toast);
                _modeInterceptor.onModeIntercepted    = onModeIntercepted;
                _modeInterceptor.onSlotDeleteWarning   = onSlotDeleteWarning;
                _modeInterceptor.onSlotDeleteConfirmed = onSlotDeleteConfirmed;

                _bezel.addEventListener(EventTypes.SAVE_SAVE, onSaveSave);
                addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
                patchWizStashModes();
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
            if (_itemToast != null && _itemToast.parent != null) {
                _itemToast.parent.removeChild(_itemToast);
            }
            _itemToast = null;
            _itemToastOnStage = false;
            if (_messageLogPanel != null) {
                if (_messageLogPanel.isOpen) _messageLogPanel.close();
                if (_messageLogPanel.parent != null) _messageLogPanel.parent.removeChild(_messageLogPanel);
            }
            _messageLogPanel = null;
            _messageLog = null;
            _messageLogOnStage = false;
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
            if (_disconnectPanel != null && _disconnectPanel.parent != null) {
                _disconnectPanel.parent.removeChild(_disconnectPanel);
            }
            _disconnectPanel = null;
            _disconnectPanelOnStage = false;
            if (_reportBtn != null && _reportBtn.parent != null) {
                _reportBtn.parent.removeChild(_reportBtn);
                _reportBtn = null;
            }
            if (_btn != null && _btn.parent != null) {
                _btn.parent.removeChild(_btn);
                _btn = null;
            }
            _buttonAdded = false;
            _logger.log(MOD_NAME, "ArchipelagoMod unloaded");
        }

        // -----------------------------------------------------------------------
        // Delegating wrappers — used by ScrDebugOptions and external callers.

        public function unlockSkill(apId:int):void { _skillUnlocker.unlockSkill(apId); }
        public function unlockBattleTrait(apId:int):void { _traitUnlocker.unlockBattleTrait(apId); }
        public function unlockStage(stageStrId:String):void { _stageUnlocker.unlockStage(stageStrId); }
        public function lockStage(stageStrId:String):void { _stageUnlocker.lockStage(stageStrId); }
        public function isStageUnlocked(stageStrId:String):Boolean { return _stageUnlocker.isStageUnlocked(stageStrId); }

        // -----------------------------------------------------------------------
        // Frame loop

        private function onEnterFrame(e:Event):void {
            // Add toasts to stage once available.
            if (!_toastOnStage && _toast != null && this.stage != null) {
                this.stage.addChild(_toast);
                _toastOnStage = true;
                positionToast();
                this.stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);
            }
            if (!_itemToastOnStage && _itemToast != null && this.stage != null) {
                this.stage.addChild(_itemToast);
                _itemToastOnStage = true;
            }
            if (!_messageLogOnStage && _messageLogPanel != null && this.stage != null) {
                this.stage.addChild(_messageLogPanel);
                _messageLogOnStage = true;
            }
            if (!_disconnectPanelOnStage && _disconnectPanel != null && this.stage != null) {
                this.stage.addChild(_disconnectPanel);
                _disconnectPanelOnStage = true;
                _disconnectPanel.visible = false;
                _disconnectPanel.positionAtBottom(this.stage.stageWidth, this.stage.stageHeight);
            }
            // Keep item toast horizontally centered as panelWidth may change each item.
            if (_itemToastOnStage && _itemToast != null && _itemToast.alpha > 0) {
                positionItemToast();
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

                // Entering MAINMENU — disconnect early so the connection doesn't
                // linger while the player is on the main menu.
                if (screen == ScreenId.MAINMENU) {
                    _connectionManager.disconnectAndReset();
                    _needsConnection = false;
                    _standalone      = false;
                    if (_connectionPanel != null) _connectionPanel.dismiss();
                    hideDisconnectPanel();
                    _goalManager.reset();
                    if (_toast != null) _toast.clear();
                    if (_itemToast != null) _itemToast.clear();
                    _logger.log(MOD_NAME, "Entered MAINMENU — connection reset, toasts cleared");
                }

                // Entering LOADGAME — always reset connection so leaving LOADGAME
                // sees _isConnected=false and triggers the overlay when needed.
                if (screen == ScreenId.LOADGAME) {
                    _connectionManager.disconnectAndReset();
                    _needsConnection = false;
                    _standalone      = false;
                    if (_connectionPanel != null) _connectionPanel.dismiss();
                    _modeInterceptor.clearPending();
                    _goalManager.reset();
                    _logger.log(MOD_NAME, "Entered LOADGAME — connection reset");
                }

                if (_lastScreen == ScreenId.LOADGAME) {
                    _modeInterceptor.unhook();
                    if (screen != ScreenId.MAINMENU) {
                        _saveManager.currentSlot = int(GV.loaderSaver.activeSlotId) + 1;
                        if (!_connectionManager.isConnected) {
                            _needsConnection = true;
                            _connectionManager.disconnect();
                            _logger.log(MOD_NAME, "Left LOADGAME not-connected — slot=" + _saveManager.currentSlot
                                + "  needsConnection=true");
                        } else {
                            _logger.log(MOD_NAME, "Left LOADGAME already-connected — slot=" + _saveManager.currentSlot);
                        }
                    }
                }
                if (screen == ScreenId.TRANS_SELECTOR_TO_INGAME1 ||
                    screen == ScreenId.TRANS_SELECTOR_TO_INGAME2 ||
                    screen == ScreenId.INGAME) {
                    skipAllTutorials();
                    _deathLinkHandler.resetForNewStage();
                }
                // Reset first-play gem patch when leaving ingame so it re-runs on
                // the next ingame entry for the same stage (after initializer resets
                // availableGemTypes to []).
                if (_lastScreen == ScreenId.INGAME) {
                    _firstPlayBypass.resetIngame();
                }
                _lastScreen = screen;
            }

            // Hook mode selector buttons while on LOADGAME.
            if (screen == ScreenId.LOADGAME && !_modeInterceptor.isHooked) {
                _modeInterceptor.hook(this.stage);
            }

            // Prevent the game from auto-launching W1 on new game.
            // startNewGame2() sets willStartNewGame=true, which makes
            // LoaderSaver bypass the selector and jump straight into W1.
            // We clear it so the player lands on the selector and can
            // choose their starting level from the unlocked stages.
            if (!_standalone
                    && GV.loaderSaver != null
                    && GV.loaderSaver.willStartNewGame) {
                GV.loaderSaver.willStartNewGame = false;
                if (GV.ingameCore != null) {
                    GV.ingameCore.isFirstStageFirstTime = false;
                }
                _logger.log(MOD_NAME,
                    "Cleared willStartNewGame — player will land on selector");
            }

            // Connection required (e.g. Continue button bypassed our interceptor).
            if (_needsConnection && !_connectionManager.isConnected && this.stage != null) {
                _needsConnection = false;
                startConnectionForSlot();
            }

            // DeathLink: detect player death (send), drain punishment queue (receive),
            // and maintain any active wave-surge.
            if (screen == ScreenId.INGAME && !_standalone) {
                _deathLinkHandler.checkForDeath();
                _deathLinkHandler.checkQueue();
                _deathLinkHandler.checkWaveSurge();
            }

            // Inject skill gems for first-play stages (every frame until done once).
            if (screen == ScreenId.INGAME) {
                _firstPlayBypass.onIngameFrame();
            }


            // Apply any sync that was deferred because GV.ppd was null at connect time.
            if (_pendingSyncItems != null && GV.ppd != null) {
                syncWithAP(_pendingSyncItems);
            }

            // Unlock free stages whenever a new ppd is detected (new game or slot change).
            // syncWithAP only runs once at connect time; if a new ppd is created after that
            // (e.g. connecting while an old slot was still loaded, then loading a new slot),
            // _pendingSyncItems is already null and free stages would never get applied.
            if (_connectionManager.isConnected
                    && GV.ppd != null
                    && GV.stageCollection != null
                    && GV.ppd !== _lastPpd) {
                _lastPpd = GV.ppd;
                var freeStages:Array = _connectionManager.freeStages;
                if (freeStages != null) {
                    for each (var freeStrId:String in freeStages) {
                        if (!_stageUnlocker.isStageUnlocked(freeStrId)) {
                            _stageUnlocker.unlockStage(freeStrId);
                            _logger.log(MOD_NAME, "free stage unlocked on ppd change: " + freeStrId);
                        }
                    }
                }
            }

            // Gate: wait until the selector and its async tile generation are fully ready.
            if (GV.ppd == null
                    || GV.selectorCore.renderer == null
                    || GV.selectorCore.mapTiles == null) {
                _mapTilesUnlocked = false;
                return;
            }

            _levelUnlocker.renderXpBarIfDirty();

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

            _firstPlayBypass.onSelectorFrame(mc);

            if (_reportBtn != null) {
                _reportBtn.x = mc.btnTutorial.x;
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

        private function positionItemToast():void {
            if (_itemToast == null || this.stage == null) return;
            var gameRoot:* = this.stage.getChildAt(0);
            // Use stageWidth for centering — gameRoot.width fluctuates with animated content.
            _itemToast.x = this.stage.stageWidth * 0.5 - _itemToast.panelWidth * 0.5;
            _itemToast.y = gameRoot.y + ITEM_TOAST_OFFSET_Y * gameRoot.scaleY;
        }

        private function onStageResize(e:Event):void {
            positionToast();
            positionItemToast();
            if (_messageLogPanel != null && _messageLogPanel.isOpen && this.stage != null) {
                _messageLogPanel.resize(this.stage.stageWidth, this.stage.stageHeight);
            }
            if (_disconnectPanel != null && this.stage != null) {
                _disconnectPanel.positionAtBottom(this.stage.stageWidth, this.stage.stageHeight);
            }
        }

        // -----------------------------------------------------------------------
        // Archipelago button + debug hotkey

        private function addArchipelagoButton(mc:*):void {
            var stepY:Number = mc.btnTalisman.y - mc.btnSkills.y;

            _reportBtn = new ReportIssuesButton(mc.btnTutorial);
            _reportBtn.x = mc.btnTutorial.x;
            _reportBtn.y = mc.btnTutorial.y + stepY;
            mc.addChild(_reportBtn);
            _logger.log(MOD_NAME, "Report Issues button added at (" + _reportBtn.x + ", " + _reportBtn.y + ")");

            _btn = new ArchipelagoButton(mc.btnTutorial);
            _btn.x = mc.btnTutorial.x;
            _btn.y = mc.btnTutorial.y + stepY * 2;
            _btn.visible = false; // hidden until Ctrl+Alt+Shift+End
            _btn.addEventListener(MouseEvent.CLICK, onArchipelagoClicked, false, 0, true);
            mc.addChild(_btn);
            _logger.log(MOD_NAME, "Archipelago button added at (" + _btn.x + ", " + _btn.y + ") [hidden]");
        }

        private function onKeyDown(e:KeyboardEvent):void {
            // Backtick / tilde (keyCode 192) — toggle message log
            if (e.keyCode == 192 && !e.ctrlKey && !e.shiftKey && !e.altKey) {
                if (_messageLogPanel != null && this.stage != null) {
                    _messageLogPanel.toggle(this.stage.stageWidth, this.stage.stageHeight);
                    if (_messageLogPanel.isOpen && _messageLogPanel.parent == this.stage) {
                        this.stage.setChildIndex(_messageLogPanel, this.stage.numChildren - 1);
                    }
                }
                return;
            }
            if (e.keyCode == Keyboard.END && e.ctrlKey && e.shiftKey && e.altKey) {
                _debugMode = !_debugMode;
                _logger.log(MOD_NAME, "Debug mode " + (_debugMode ? "ON" : "OFF"));
                if (_btn != null) _btn.visible = _debugMode;
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
        // Startup patches

        private function patchWizStashModes():void {
            WizStashes.apply(_logger, MOD_NAME);
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
            _stageUnlocker.logStageEntered(_saveManager.currentSlot);
        }

        // -----------------------------------------------------------------------
        // ModeSelectorInterceptor callbacks

        private function onModeIntercepted(slotId:int, pendingBtn:*, pendingTarget:*):void {
            _saveManager.currentSlot = slotId;
            if (_disconnectPanel != null && _disconnectPanel.isShowing) {
                _toast.addMessage("Reconnect to Archipelago before starting a level", 0xFFFF8844);
                _modeInterceptor.clearPending();
                return;
            }
            startConnectionForSlot();
        }

        private function onSlotDeleteWarning(slotId:int):void {
            // Standalone slots have no Archipelago goal — skip the completion warning.
            if (_saveManager.isSlotStandalone(slotId)) return;
            if (!_saveManager.isSlotCompleted(slotId)) {
                _toast.addMessage("Warning: slot " + slotId + " is not yet completed. Deleting will lose most of your progress. Press D to confirm.", 0xFFFF8844);
            }
        }

        private function onSlotDeleteConfirmed(slotId:int):void {
            _saveManager.deleteSlot(slotId);
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
            _saveManager.loadSlotData(_saveManager.currentSlot);
            _messageLog.init(_fileHandler, _saveManager.currentSlot);

            // Slot file exists and player previously chose standalone — skip popup entirely.
            if (_saveManager.standaloneSet && _saveManager.standalone) {
                _standalone = true;
                _normalProgressionBlocker.disable();
                _logger.log(MOD_NAME, "Standalone slot — skipping AP connection, slot=" + _saveManager.currentSlot);
                _toast.addMessage("Solo mode (Slot " + _saveManager.currentSlot + ") — playing without randomizer", 0xFF88CCFF);
                _modeInterceptor.redispatchPendingClick();
                return;
            }

            if (_connectionManager.apSlot.length > 0) {
                _logger.log(MOD_NAME, "Auto-connecting slot=" + _saveManager.currentSlot
                    + "  host=" + _connectionManager.apHost
                    + "  apSlot=" + _connectionManager.apSlot);
                _connectionManager.saveSlot = _saveManager.currentSlot;
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
            if (_connectionPanel == null) {
                _connectionPanel = new ConnectionPanel();
                _logger.log(MOD_NAME, "ConnectionPanel created");
            }
            _connectionPanel.onConnect    = onConnectionPanelConnect;
            _connectionPanel.onCancel     = onConnectionPanelCancel;
            _connectionPanel.onStandalone = onConnectionPanelStandalone;
            _connectionPanel.prefill(
                _connectionManager.apHost,
                _connectionManager.apPort,
                _connectionManager.apSlot,
                _connectionManager.apPassword
            );
            if (!_connectionPanel.isShowing) {
                _connectionPanel.showWithOverlay(this.stage, _toast, _messageLogPanel);
                _logger.log(MOD_NAME, "Connection overlay shown");
            }
        }

        private function onConnectionPanelConnect(host:String, port:int,
                                                   slot:String, password:String):void {
            _logger.log(MOD_NAME, "PLAYER_SUBMITTED_CONNECTION host=" + host
                + "  port=" + port + "  slot=" + slot
                + "  hasPassword=" + (password.length > 0));
            _connectionManager.saveSlot = _saveManager.currentSlot;
            _connectionManager.connect(host, port, slot, password);
        }

        private function onConnectionPanelCancel():void {
            if (_connectionPanel != null) _connectionPanel.dismiss();
            _modeInterceptor.clearPending();
        }

        private function onConnectionPanelStandalone():void {
            _saveManager.standalone = true;
            _saveManager.saveSlotData();
            _standalone = true;
            _normalProgressionBlocker.disable();
            if (_connectionPanel != null) _connectionPanel.dismiss();
            hideDisconnectPanel();
            _logger.log(MOD_NAME, "PLAYER_CHOSE_STANDALONE slot=" + _saveManager.currentSlot);
            _toast.addMessage("Solo mode (Slot " + _saveManager.currentSlot + ") — playing without randomizer", 0xFF88CCFF);
            _modeInterceptor.redispatchPendingClick();
        }

        // -----------------------------------------------------------------------
        // ConnectionManager callbacks

        private function onApConnected(p:Object):void {
            _needsConnection = false;
            // Persist credentials before loadSlotData resets them via resetSettings().
            // Without this, first-time connection data is never written to the slot file.
            _saveManager.saveSlotData();
            _saveManager.loadSlotData(_saveManager.currentSlot);
            _levelUnlocker.applyBonusLevels();

            // DeathLink: for new slots use the YAML setting; existing slots keep the local override.
            if (!_saveManager.deathLinkEnabledSet && p.slot_data) {
                _saveManager.deathLinkEnabled = p.slot_data.death_link === true;
                _saveManager.saveSlotData();
            }
            _deathLinkHandler.enabled = _saveManager.deathLinkEnabled;
            if (p.slot_data) _deathLinkHandler.configure(p.slot_data);
            if (_saveManager.deathLinkEnabled) {
                _connectionManager.sendConnectUpdate(["DeathLink"]);
            }

            _levelUnlocker.configure(
                _connectionManager.tatteredScrollLevels,
                _connectionManager.wornTomeLevels,
                _connectionManager.ancientGrimoireLevels
            );
            _talismanUnlocker.setTalismanMap(_connectionManager.talismanMap);
            _talismanUnlocker.setTalismanNameMap(_connectionManager.talismanNameMap);
            _shadowCoreUnlocker.setShadowCoreMap(_connectionManager.shadowCoreMap);
            _shadowCoreUnlocker.setShadowCoreNameMap(_connectionManager.shadowCoreNameMap);
            if (_normalProgressionBlocker != null) {
                _normalProgressionBlocker.setWizStashTalData(_connectionManager.wizStashTalData);
            }

            _goalManager.configure(
                _connectionManager.goal,
                _connectionManager.talismanMinRarity);

            if (_saveManager.slotCompleted) {
                _goalManager.markAlreadyCompleted();
            }
            // Note: we do NOT call _goalManager.check() here because GV.ppd
            // may still hold data from a previously loaded save slot.
            // The onSaveSave hook will catch a legitimate victory.
            if (_connectionPanel != null) _connectionPanel.dismiss();
            hideDisconnectPanel();
            _modeInterceptor.redispatchPendingClick();
        }

        private function onConnectionError(msg:String):void {
            // Auto-connect failed — show the overlay so the player can correct settings.
            ensureConnectionOverlay();
            _connectionManager.failConnection();
            if (_connectionPanel != null) _connectionPanel.showError(msg);
        }

        private function onConnectionPanelReset():void {
            if (_connectionPanel != null) _connectionPanel.resetState();
            if (_disconnectPanel != null) _disconnectPanel.resetState();
        }

        private function onApUnexpectedlyDisconnected():void {
            if (_disconnectPanel == null || !_disconnectPanelOnStage) return;
            _disconnectPanel.resetState();
            _disconnectPanel.visible = true;
            // Keep it above other children so it's always readable
            if (this.stage != null) {
                this.stage.setChildIndex(_disconnectPanel, this.stage.numChildren - 1);
            }
            _logger.log(MOD_NAME, "Disconnect panel shown");
        }

        private function hideDisconnectPanel():void {
            if (_disconnectPanel != null) {
                _disconnectPanel.visible = false;
                _disconnectPanel.resetState();
            }
        }

        private function onDisconnectPanelReconnect():void {
            _disconnectPanel.setReconnecting(true);
            startConnectionForSlot();
        }

        // -----------------------------------------------------------------------
        // Item handling

        private function grantItem(apId:int):void {
            var strId:String = _connectionManager.tokenMap[String(apId)];
            if (strId != null) {
                _stageUnlocker.unlockStage(strId);
                _itemToast.addItem("Unlocked: " + strId + " Field Token", 0xFFDD55);
                return;
            }
            if (apId >= 300 && apId <= 323) {
                if (_normalProgressionBlocker != null) _normalProgressionBlocker.markSkillGranted(apId - 300);
                _skillUnlocker.unlockSkill(apId);
                return;
            }
            if (apId >= 400 && apId <= 414) {
                if (_normalProgressionBlocker != null) _normalProgressionBlocker.markTraitGranted(apId - 400);
                _traitUnlocker.unlockBattleTrait(apId);
                return;
            }
            if (apId >= 500 && apId <= 502) { _levelUnlocker.grantXpBonus(apId); return; }
            if (apId >= 700 && apId <= 799) {
                _talismanUnlocker.grantFragment(apId);
                _saveManager.saveSlotData();
                return;
            }
            if (apId >= 800 && apId <= 868) { _shadowCoreUnlocker.grantShadowCores(apId); _saveManager.saveSlotData(); return; }
            _logger.log(MOD_NAME, "  grantItem: no handler for AP ID " + apId);
        }

        private function syncWithAP(items:Array):void {
            if (GV.ppd == null) {
                _pendingSyncItems = items;
                _logger.log(MOD_NAME, "syncWithAP: GV.ppd null, deferring sync (" + items.length + " items)");
                return;
            }
            _pendingSyncItems = null;

            if (_normalProgressionBlocker != null) _normalProgressionBlocker.resetGrants();

            var apSkills:Object = {};
            var apTraits:Object = {};
            var apTokens:Object = {};
            var apXpTotal:int   = 0;
            var apTalismans:Array  = [];
            var apShadowCores:Array = [];
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
                } else if (apId >= 500 && apId <= 502) {
                    apXpTotal += _levelUnlocker.levelsForApId(apId);
                } else if (apId >= 700 && apId <= 799) {
                    apTalismans.push(apId);
                } else if (apId >= 800 && apId <= 868) {
                    apShadowCores.push(apId);
                }
            }

            // --- Skills ---
            var skillChanges:int = 0;
            for (var i:int = 0; i < 24; i++) {
                var shouldHaveSkill:Boolean = apSkills[i] == true;
                if (shouldHaveSkill && _normalProgressionBlocker != null)
                    _normalProgressionBlocker.markSkillGranted(i);
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
                if (shouldHaveTrait && _normalProgressionBlocker != null)
                    _normalProgressionBlocker.markTraitGranted(j);
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
            _levelUnlocker.applyBonusLevels();

            // --- Talisman fragments ---
            _talismanUnlocker.syncTalismans(apTalismans);

            // --- Shadow cores ---
            _shadowCoreUnlocker.syncShadowCores(apShadowCores);

            // --- Free stages (W1, W2, W3, W4) — always unlock on sync ---
            var freeStages:Array = _connectionManager.freeStages;
            if (freeStages != null) {
                for each (var freeStrId:String in freeStages) {
                    if (!_stageUnlocker.isStageUnlocked(freeStrId)) {
                        _stageUnlocker.unlockStage(freeStrId);
                        _logger.log(MOD_NAME, "  free stage unlocked: " + freeStrId);
                    }
                }
            }

            _saveManager.saveSlotData();

            _logger.log(MOD_NAME, "AP sync complete — skills:" + skillChanges +
                " traits:" + traitChanges + " stages:" + stageChanges +
                " apWizardLevel:" + _levelUnlocker.bonusWizardLevel);
        }

        // -----------------------------------------------------------------------
        // Save hook — detects battle victories and sends location checks

        private function onSaveSave(e:*):void {
            if (_standalone) return;
            _logger.log(MOD_NAME, "onSaveSave fired — _isConnected=" + _connectionManager.isConnected);
            _connectionManager.checkCompletedLocations();
            _goalManager.check();
        }

        private function onGoalReached():void {
            _connectionManager.sendGoalComplete();
            _saveManager.markSlotCompleted();
        }

        // -----------------------------------------------------------------------
        // DeathLink callbacks

        private function onPlayerDied():void {
            _connectionManager.sendDeathLink(_connectionManager.apSlot);
        }

        private function onPunishmentReceived(source:String):void {
            _toast.addMessage("DeathLink from " + source + "!", 0xFFFF4444);
        }

        private function onDeathLinkReceived(source:String):void {
            _deathLinkHandler.queuePunishment(source);
        }

        /**
         * Toggle DeathLink on/off for this slot.
         * Persists the preference and sends ConnectUpdate to the server.
         * Expose via ScrDebugOptions or a dedicated UI button.
         */
        public function toggleDeathLink():void {
            _saveManager.deathLinkEnabled = !_saveManager.deathLinkEnabled;
            _saveManager.saveSlotData();
            _deathLinkHandler.enabled = _saveManager.deathLinkEnabled;
            var tags:Array = _saveManager.deathLinkEnabled ? ["DeathLink"] : [];
            _connectionManager.sendConnectUpdate(tags);
            _logger.log(MOD_NAME, "DeathLink toggled: " + (_saveManager.deathLinkEnabled ? "ON" : "OFF"));
            _toast.addMessage("DeathLink " + (_saveManager.deathLinkEnabled ? "enabled" : "disabled"),
                _saveManager.deathLinkEnabled ? 0xFF88FF88 : 0xFFFFAA44);
        }

        public function get deathLinkEnabled():Boolean { return _saveManager.deathLinkEnabled; }

        // -----------------------------------------------------------------------
        // Helpers

        private function itemName(apId:int):String {
            var skillName:String = _skillUnlocker.getSkillName(apId);
            if (skillName != null) return skillName + " Skill";
            var traitName:String = _traitUnlocker.getTraitName(apId);
            if (traitName != null) return traitName + " Battle Trait";
            var strId:String = _connectionManager.tokenMap[String(apId)];
            if (strId != null) return strId + " Field Token";
            if (apId >= 700 && apId <= 799) {
                var talName:String = _connectionManager.talismanNameMap[String(apId)];
                return talName != null ? talName : ("Talisman Fragment #" + apId);
            }
            if (apId >= 800 && apId <= 868) {
                var scName:String = _connectionManager.shadowCoreNameMap[String(apId)];
                return scName != null ? scName : ("Shadow Cores #" + apId);
            }
            return null; // let ConnectionManager handle the rest
        }
    }
}
