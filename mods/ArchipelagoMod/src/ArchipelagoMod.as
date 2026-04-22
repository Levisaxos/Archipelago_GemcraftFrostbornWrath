package {
    import flash.display.MovieClip;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import Bezel.Bezel;
    import Bezel.BezelMod;
    import Bezel.Logger;
    import Bezel.GCFW.Events.EventTypes;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.ScreenId;

    import data.AV;
    import goals.GoalManager;

    import ui.ModButtons;
    import ui.ScrSlotSettings;
    import ui.SystemToast;
    import ui.ReceivedToast;
    import ui.MessageLog;
    import ui.MessageLogPanel;
    import ui.ScrDebugOptions;
    import ui.ConnectionPanel;
    import ui.DisconnectPanel;

    import ui.MainMenuUI;

    import deathlink.DeathLinkHandler;

    import patch.ModeSelectorInterceptor;
    import patch.ProgressionBlocker;
    import ui.LevelEndScreenBuilder;
    import unlockers.SkillUnlocker;
    import unlockers.TraitUnlocker;
    import unlockers.LevelUnlocker;
    import unlockers.StageUnlocker;
    import unlockers.TalismanUnlocker;
    import unlockers.ShadowCoreUnlocker;
    import unlockers.AchievementUnlocker;

    import net.ConnectionManager;

    import tracker.FieldLogicEvaluator;
    import tracker.LogicEvaluator;
    import tracker.AchievementLogicEvaluator;
    import tracker.StageTinter;
    import tracker.LogicHelper;

    import patch.WizStashes;
    import patch.FirstPlayBypass;
    import patch.LogicEnforcer;
    import patch.WavePrePatcher;
    import patch.AchievementPanelPatcher;
    import patch.FieldTooltipOverlay;

    import save.FileHandler;
    import save.SaveManager;

    
    

    /**
     * Main mod class — orchestrates all subsystems.
     *
     * Subsystems:
     *   ConnectionManager        — AP protocol, WebSocket lifecycle, toasts
     *   ConnectionPanel          — Connection UI overlay (self-managing)
     *   ModeSelectorInterceptor  — Mode button / delete button hooks
     *   ProgressionBlocker       — Reverts auto-unlocks after battles
     *   LevelEndScreenBuilder    — Builds AP drop icons on the ending screen
     *   SkillUnlocker            — Skill unlock logic
     *   TraitUnlocker            — Battle trait unlock logic
     *   StageUnlocker            — Stage / tile unlock logic
     *   LevelUnlocker            — Wizard level / XP bonus logic
     *   DeathLinkHandler         — DeathLink send/receive and punishment application
     *   GoalManager              — Detects goal completion, fires onGoalReached once
     *   SaveManager              — Slot JSON persistence (coordinates FileHandler/ConnectionManager/LevelUnlocker)
     *   FileHandler              — Raw slot file I/O
     *   SystemToast              — On-screen system/sent-item notifications
     *   ReceivedToast            — On-screen received-item notifications
     *   ScrDebugOptions          — Debug panel
     */
    public class ArchipelagoMod extends MovieClip implements BezelMod {

        public function get VERSION():String        { return "0.0.4"; }
        public function get MOD_NAME():String       { return "ArchipelagoMod"; }
        public function get BEZEL_VERSION():String  { return "2.1.1"; }
        public function get APWORLD_VERSION():String { return "0.0.4"; }

        private static const TOAST_OFFSET_X:Number      = 52;
        private static const TOAST_OFFSET_Y:Number      = 10;
        private static const ITEM_TOAST_OFFSET_Y:Number = 18; // game pixels from top edge

        private var _logger:Logger;
        private var _bezel:Bezel;
        private var _modButtons:ModButtons;
        private var _slotSettings:ScrSlotSettings;

        private var _systemToast:SystemToast;
        private var _systemToastOnStage:Boolean = false;

        private var _receivedToast:ReceivedToast;
        private var _receivedToastOnStage:Boolean = false;

        private var _messageLog:MessageLog;
        private var _messageLogPanel:MessageLogPanel;
        private var _messageLogOnStage:Boolean = false;

        private var _debugOptions:ScrDebugOptions;
        private var _progressionBlocker:ProgressionBlocker;
        private var _levelEndScreenBuilder:LevelEndScreenBuilder;
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
        private var _achievementUnlocker:AchievementUnlocker;
        private var _firstPlayBypass:FirstPlayBypass;
        private var _logicEnforcer:LogicEnforcer;
        private var _wavePrePatcher:WavePrePatcher;
        private var _fieldLogicEvaluator:FieldLogicEvaluator;
        private var _logicEvaluator:LogicEvaluator;
        private var _achievementLogicEvaluator:AchievementLogicEvaluator;
        private var _logicHelper:LogicHelper;
        private var _stageTinter:StageTinter;
        private var _achPanelPatcher:AchievementPanelPatcher;
        private var _fieldTooltipOverlay:FieldTooltipOverlay;

        private var _keyListenerAdded:Boolean  = false;
        private var _needsConnection:Boolean   = false;
        private var _lastScreen:int            = -1;
        private var _mapTilesUnlocked:Boolean  = false;
        private var _standalone:Boolean        = false;
        private var _pendingSyncItems:Array    = null; // deferred full-sync when GV.ppd was null
        private var _lastPpd:Object            = null; // tracks ppd identity to detect slot changes
        private var _stagesPopulated:Boolean   = false; // tracks if stage data has been loaded into AV

        private var _mainMenuUI:MainMenuUI;
        private var _dbgFrameCounter:int = 0; // for throttled screen logging

// Debug mode — toggled by Ctrl+Shift+Alt+End.
        private static const DEBUG_MODE_DEFAULT:Boolean = false;
        private var _debugMode:Boolean = DEBUG_MODE_DEFAULT;

        public function ArchipelagoMod() {
            super();
            _logger = Logger.getLogger(MOD_NAME);
        }

        // -----------------------------------------------------------------------
        // Lifecycle

        public function bind(bezel:Bezel, gameObjects:Object):void
        {
            try
            {
                _bezel = bezel;

                // Initialize AV (Archipelago Variables) early so all subsystems have access
                AV.setLogger(_logger);
                AV.initialize();

                // Create subsystems
                _messageLog    = new MessageLog();
                _systemToast   = new SystemToast();
                _receivedToast = new ReceivedToast();
                _systemToast.messageLog = _messageLog;
                _messageLogPanel = new MessageLogPanel(_messageLog);
                _fileHandler   = new FileHandler(_logger, MOD_NAME);
                _skillUnlocker      = new SkillUnlocker(_logger, MOD_NAME, _receivedToast);
                _traitUnlocker      = new TraitUnlocker(_logger, MOD_NAME, _receivedToast);
                _stageUnlocker      = new StageUnlocker(_logger, MOD_NAME);
                _levelUnlocker      = new LevelUnlocker(_logger, MOD_NAME, _receivedToast);
                _talismanUnlocker   = new TalismanUnlocker(_logger, MOD_NAME, _receivedToast);
                _shadowCoreUnlocker = new ShadowCoreUnlocker(_logger, MOD_NAME, _receivedToast);
                // Note: _achievementUnlocker will be initialized after _connectionManager is created
                _logicEnforcer      = new LogicEnforcer(_logger, MOD_NAME);
                _wavePrePatcher     = new WavePrePatcher(_logger, MOD_NAME);
                _firstPlayBypass    = new FirstPlayBypass(_logger, MOD_NAME);

                // In-game tracker (stage light tinting + logic evaluation)
                _fieldLogicEvaluator        = new FieldLogicEvaluator(_logger, MOD_NAME);
                _logicEvaluator             = new LogicEvaluator(_logger, MOD_NAME);
                _achievementLogicEvaluator  = new AchievementLogicEvaluator(_logger, MOD_NAME);

                _debugOptions  = new ScrDebugOptions(this);
                _slotSettings  = new ScrSlotSettings();

                // Level-end screen builder — constructed early; configured once
                // _achievementUnlocker and _connectionManager are both available (below).
                _levelEndScreenBuilder = new LevelEndScreenBuilder(_logger, MOD_NAME);

                // Connection manager — AP protocol + WebSocket
                _connectionManager = new ConnectionManager(_logger, MOD_NAME, _systemToast);
                _connectionManager.setReceivedToast(_receivedToast);
                _connectionManager.setMessageLog(_messageLog);
                _connectionManager.onConnected             = onApConnected;
                _connectionManager.onFullSync              = syncWithAP;
                _connectionManager.onItemReceived          = grantItem;
                _connectionManager.onError                 = onConnectionError;
                _connectionManager.onPanelReset            = onConnectionPanelReset;
                _connectionManager.onUnexpectedDisconnect  = onApUnexpectedlyDisconnected;
                _connectionManager.onItemSentFromLocation  = onItemSentFromLocation;
                _connectionManager.load();

                // Initialize achievement unlocker
                _achievementUnlocker = new AchievementUnlocker(_logger, MOD_NAME, _connectionManager, _receivedToast);
                _achievementUnlocker.loadData();
                _achievementLogicEvaluator.loadData();

                // Wire level-end builder now that both dependencies are available
                _levelEndScreenBuilder.configure(_achievementUnlocker, _connectionManager);

                // ProgressionBlocker: intercepts SAVE_SAVE and reverts game auto-unlocks.
                // Delegates icon construction to LevelEndScreenBuilder.
                _progressionBlocker = new ProgressionBlocker(_logger, MOD_NAME, _levelEndScreenBuilder);

                // Logic helper (thin wrapper for external callers e.g. debug UI)
                _logicHelper = new LogicHelper(_logger, MOD_NAME, _fieldLogicEvaluator);

                _achPanelPatcher = new AchievementPanelPatcher(_logger, MOD_NAME);
                _achPanelPatcher.setAchievementLogicEvaluator(_achievementLogicEvaluator);

                // When an achievement check is sent, immediately refresh the panel so the
                // achievement leaves "In Logic" without waiting for the next item grant.
                _achievementUnlocker.onChecked = _refreshAchievementPanel;

                _stageTinter = new StageTinter(_logger, MOD_NAME, _connectionManager, _fieldLogicEvaluator);
                _fieldTooltipOverlay = new FieldTooltipOverlay(_logger, MOD_NAME, _fieldLogicEvaluator);

                // Button factory — owns all mod buttons on selector + main menu
                _modButtons = new ModButtons(_logger, MOD_NAME, _connectionManager, _fieldLogicEvaluator);
                _modButtons.onSettingsClick  = onSettingsClicked;
                _modButtons.onApDebugClick   = _toggleDebugOptions;
                _modButtons.onChangelogClick = openChangelog;

                // Disconnect banner (shown when AP drops unexpectedly)
                _disconnectPanel = new DisconnectPanel();
                _disconnectPanel.onReconnect = onDisconnectPanelReconnect;

                _saveManager = new SaveManager(_logger, MOD_NAME,
                _fileHandler, _connectionManager, _levelUnlocker);
                _saveManager.shadowCoreUnlocker = _shadowCoreUnlocker;
                _saveManager.talismanUnlocker   = _talismanUnlocker;
                _levelUnlocker.onDataChanged = _saveManager.saveSlotData;

                _deathLinkHandler = new DeathLinkHandler(_logger, MOD_NAME, _systemToast);
                _deathLinkHandler.onPlayerDied         = onPlayerDied;
                _deathLinkHandler.onPunishmentReceived = onPunishmentReceived;
                _connectionManager.onDeathLinkReceived = onDeathLinkReceived;

                _goalManager = new GoalManager(_logger, MOD_NAME, _systemToast);
                _goalManager.onGoalReached = onGoalReached;

                // Main menu UI — version label, update badge, changelog
                _mainMenuUI = new MainMenuUI(_logger, MOD_NAME, _fileHandler, _modButtons);

                // Connection panel (lazy — created on first use)
                _connectionPanel = null;

                // Mode-selector interceptor
                _modeInterceptor = new ModeSelectorInterceptor(_logger, MOD_NAME, _systemToast);
                _modeInterceptor.onModeIntercepted    = onModeIntercepted;
                _modeInterceptor.onSlotDeleteWarning   = onSlotDeleteWarning;
                _modeInterceptor.onSlotDeleteConfirmed = onSlotDeleteConfirmed;

                _bezel.addEventListener(EventTypes.SAVE_SAVE, onSaveSave);

                // Register ProgressionBlocker AFTER our own handler so its SAVE_SAVE fires second.
                // This guarantees checkCompletedLocations() has already run before buildIcons() reads
                // itemsSentThisLevel from ConnectionManager.
                _progressionBlocker.enable(_bezel);

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
            if (_progressionBlocker != null) {
                _progressionBlocker.disable();
                _progressionBlocker = null;
            }
            _levelEndScreenBuilder = null;
            if (_modeInterceptor != null) {
                _modeInterceptor.unhook();
                _modeInterceptor = null;
            }
            if (this.stage != null) {
                this.stage.removeEventListener(Event.RESIZE, onStageResize);
            }
            if (_systemToast != null && _systemToast.parent != null) {
                _systemToast.parent.removeChild(_systemToast);
            }
            _systemToast = null;
            _systemToastOnStage = false;
            if (_receivedToast != null && _receivedToast.parent != null) {
                _receivedToast.parent.removeChild(_receivedToast);
            }
            _receivedToast = null;
            _receivedToastOnStage = false;
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
            if (_modButtons != null) _modButtons.removeFromSelector();
            if (_slotSettings != null) _slotSettings.close();
            if (_mainMenuUI != null) { _mainMenuUI.dispose(); _mainMenuUI = null; }
            _logger.log(MOD_NAME, "ArchipelagoMod unloaded");
        }

        // -----------------------------------------------------------------------
        // Delegating wrappers — used by ScrDebugOptions and external callers.

        public function unlockSkill(apId:int):void { _skillUnlocker.unlockSkill(apId); }
        public function unlockBattleTrait(apId:int):void { _traitUnlocker.unlockBattleTrait(apId); }
        public function unlockStage(stageStrId:String):void { _stageUnlocker.unlockStage(stageStrId); }
        public function lockStage(stageStrId:String):void { _stageUnlocker.lockStage(stageStrId); }
        public function isStageUnlocked(stageStrId:String):Boolean { return _stageUnlocker.isStageUnlocked(stageStrId); }

        public function getDisplayedWizardLevel():int {
            if (_levelUnlocker == null) return 1;
            return _levelUnlocker.getDisplayedWizardLevel();
        }

        /**
         * Debug-only: set total wizard level by adjusting the AP bonus.
         * Clamps so bonus never goes negative (can't reduce natural level).
         * Does NOT persist — intentionally skips onDataChanged.
         */
        public function setDebugWizardLevel(target:int):void {
            if (_levelUnlocker == null) return;
            var natural:int = _levelUnlocker.naturalWizardLevel;
            _levelUnlocker.bonusWizardLevel = Math.max(0, target - natural);
            _levelUnlocker.applyBonusLevels();
        }

        // -----------------------------------------------------------------------
        // Frame loop

        private function onEnterFrame(e:Event):void
        {
            // Populate stage data from GV once stageCollection is ready (one-time init).
            if (!_stagesPopulated && GV.stageCollection != null && GV.stageCollection.stageMetas != null)
            {
                AV.populateStages();
                _stagesPopulated = true;
            }

            // Add toasts to stage once available.
            if (!_systemToastOnStage && _systemToast != null && this.stage != null) {
                this.stage.addChild(_systemToast);
                _systemToastOnStage = true;
                positionSystemToast();
                this.stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);
            }
            if (!_receivedToastOnStage && _receivedToast != null && this.stage != null) {
                this.stage.addChild(_receivedToast);
                _receivedToastOnStage = true;
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
            // Keep received toast horizontally centered as panelWidth may change each item.
            if (_receivedToastOnStage && _receivedToast != null && _receivedToast.alpha > 0) {
                positionReceivedToast();
            }

            // Main menu overlay — show/tick/hide driven by screen state.
            var onMainMenu:Boolean = int(GV.main.currentScreen) == ScreenId.MAINMENU;
            if (!_mainMenuUI.isShowing && onMainMenu && this.stage != null) {
                _mainMenuUI.show(this.stage, VERSION, APWORLD_VERSION);
            }
            if (_mainMenuUI.isShowing) {
                _mainMenuUI.onFrame();
                if (!onMainMenu)
                    _mainMenuUI.hide();
            }
            _dbgFrameCounter++;

            // Register the debug hotkey once the stage exists.
            if (!_keyListenerAdded && this.stage != null) {
                this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
                _keyListenerAdded = true;
            }

            // Sweep opened wizard stashes so gems stop targeting their tile
            // after the AP check is collected. See WizStashes.tickClearOpened.
            WizStashes.tickClearOpened(_logger, MOD_NAME);

            // Poll the goal manager every frame so mid-battle goals (e.g. Swarm
            // Queen kill on K4) fire as soon as the condition is met, not only
            // on the next save event. No-ops once the goal has been sent.
            if (!_standalone && _goalManager != null) _goalManager.check();

            // Detect and report achievements every 30 frames
            if (!_standalone && _dbgFrameCounter % 30 == 0) {
                _achievementUnlocker.detectAndReport();
            }

            // Track screen transitions.
            var screen:int = int(GV.main.currentScreen);
            if (_lastScreen == -1)
                _lastScreen = screen;
            if (screen != _lastScreen) {

                // Entering MAINMENU — disconnect early so the connection doesn't
                // linger while the player is on the main menu.
                if (screen == ScreenId.MAINMENU) {
                    _connectionManager.disconnectAndReset();
                    _needsConnection = false;
                    _standalone      = false;
                    _achievementUnlocker.resetReportedAchievements();
                    if (_connectionPanel != null) _connectionPanel.dismiss();
                    hideDisconnectPanel();
                    _goalManager.reset();
                    if (_systemToast != null) _systemToast.clear();
                    if (_receivedToast != null) _receivedToast.clear();
                    _logger.log(MOD_NAME, "Entered MAINMENU — connection reset, toasts cleared");
                    _mainMenuUI.hide(); // remove any existing set before re-adding next frame
                }

                // Entering LOADGAME — always reset connection so leaving LOADGAME
                // sees _isConnected=false and triggers the overlay when needed.
                if (screen == ScreenId.LOADGAME) {
                    _connectionManager.disconnectAndReset();
                    _needsConnection = false;
                    _standalone      = false;
                    _achievementUnlocker.resetReportedAchievements();
                    if (_modButtons != null) _modButtons.removeFromSelector();
                    if (_connectionPanel != null) _connectionPanel.dismiss();
                    _modeInterceptor.clearPending();
                    _goalManager.reset();
                    _logger.log(MOD_NAME, "Entered LOADGAME — connection reset");
                }

                if (_lastScreen == ScreenId.LOADGAME) {
                    _modeInterceptor.unhook();
                    if (screen != ScreenId.MAINMENU && GV.loaderSaver != null) {
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
                    _wavePrePatcher.resetForNewStage();
                }
                // Reset first-play gem patch when leaving ingame so it re-runs on
                // the next ingame entry for the same stage (after initializer resets
                // availableGemTypes to []).
                if (_lastScreen == ScreenId.INGAME) {
                    _firstPlayBypass.resetIngame();
                }
                // Remove MAINMENU overlays when navigating away from the main menu.
                if (_lastScreen == ScreenId.MAINMENU && screen != ScreenId.MAINMENU) {
                    _mainMenuUI.hide();
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
                _wavePrePatcher.applyIfReady();
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
                var freeStages:Array = AV.serverData.freeStages;
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
                    || GV.selectorCore == null
                    || GV.selectorCore.renderer == null
                    || GV.selectorCore.mapTiles == null) {
                _mapTilesUnlocked = false;
                return;
            }

            // Pre-populate the drop-icon bitmap cache once per session.
            if (!AV.sessionData.iconsCached) {
                LevelEndScreenBuilder.preCacheIcons();
                AV.sessionData.iconsCached = true;
                _logger.log(MOD_NAME, "Drop icon bitmap cache populated");
            }

            _levelUnlocker.renderXpBarIfDirty();

            var mc:* = GV.selectorCore.mc;
            if (mc == null) return;

            // Sync tile visibility once per selector session.
            if (!_mapTilesUnlocked) {
                _stageUnlocker.syncMapTilesWithStages();
                GV.selectorCore.renderer.setMapTilesVisibility();
                _mapTilesUnlocked = true;
            }

            _stageUnlocker.enforceFullWorldScrollLimits();

            if (mc.btnTutorial == null) return;

            if (!_modButtons.selectorAdded) {
                if (mc.btnSkills == null || mc.btnTalisman == null) return;
                _modButtons.showOnSelector(mc);
            }

            try {
                if (_firstPlayBypass != null) _firstPlayBypass.onSelectorFrame(mc);
                if (_logicEnforcer != null) _logicEnforcer.onSelectorFrame(mc);

                // In-game tracker: recolor stage lights based on logic state.
                if (_stageTinter != null) _stageTinter.apply(mc);
                if (_fieldTooltipOverlay != null) _fieldTooltipOverlay.onSelectorFrame(mc);

                // Achievement panel patcher — idempotent once patched.
                if (_achPanelPatcher != null) {
                    var wasPatched:Boolean = _achPanelPatcher.patched;
                    _achPanelPatcher.tryPatch();
                    if (!wasPatched && _achPanelPatcher.patched && _achievementLogicEvaluator != null) {
                        // First successful patch: populate filterFlags before the panel opens.
                        _achPanelPatcher.updateExcluded(_achievementLogicEvaluator.getExcludedAchApIds());
                        _achPanelPatcher.updateEffortExcluded(_achievementLogicEvaluator.getEffortExcludedAchApIds(), _achievementLogicEvaluator.getMaxEffortLabel());
                        _achPanelPatcher.updateLogicFlags(_achievementLogicEvaluator.getInLogicAchApIds());
                        _achPanelPatcher.updateDots(_achievementLogicEvaluator.getRequirementsMetApIds());
                    }
                    if (GV.selectorCore != null) {
                        _achPanelPatcher.patchResetButton(GV.selectorCore.pnlAchievements);
                        _achPanelPatcher.onSelectorFrame(GV.selectorCore.pnlAchievements);
                    }
                }
            } catch (e:Error) {
                _logger.log(MOD_NAME, "selectorFrame error: " + e.message);
            }

            // Buttons: sync X positions, update fields-in-logic label + hover + pan.
            _modButtons.onSelectorFrame(mc);

            if (_debugOptions != null && _debugOptions.isOpen) {
                _debugOptions.doEnterFrame();
            }
            if (_slotSettings != null && _slotSettings.isOpen) {
                _slotSettings.doEnterFrame();
            }
        }

        // -----------------------------------------------------------------------
        // Toast positioning

        private function positionSystemToast():void {
            if (_systemToast == null || this.stage == null) return;
            var gameRoot:* = this.stage.getChildAt(0);
            _systemToast.x = gameRoot.x + TOAST_OFFSET_X * gameRoot.scaleX;
            _systemToast.y = gameRoot.y + TOAST_OFFSET_Y * gameRoot.scaleY;
        }

        private function positionReceivedToast():void {
            if (_receivedToast == null || this.stage == null) return;
            var gameRoot:* = this.stage.getChildAt(0);
            // Use stageWidth for centering — gameRoot.width fluctuates with animated content.
            _receivedToast.x = this.stage.stageWidth * 0.5 - _receivedToast.panelWidth * 0.5;
            _receivedToast.y = gameRoot.y + ITEM_TOAST_OFFSET_Y * gameRoot.scaleY;
        }

        private function onStageResize(e:Event):void {
            positionSystemToast();
            positionReceivedToast();
            if (_messageLogPanel != null && _messageLogPanel.isOpen && this.stage != null) {
                _messageLogPanel.resize(this.stage.stageWidth, this.stage.stageHeight);
            }
            if (_disconnectPanel != null && this.stage != null) {
                _disconnectPanel.positionAtBottom(this.stage.stageWidth, this.stage.stageHeight);
            }
            // SlotSettings panel is attached to GV.main, no resize handling needed.
        }

        /** Open (or refresh) the changelog panel. Only valid on the main menu. */
        private function openChangelog():void {
            if (int(GV.main.currentScreen) != ScreenId.MAINMENU) return;
            _mainMenuUI.openChangelog();
        }


        // -----------------------------------------------------------------------
        // Debug hotkey

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
                if (_modButtons != null) _modButtons.apDebugVisible = _debugMode;
                if (!_debugMode && _debugOptions != null && _debugOptions.isOpen) {
                    _debugOptions.close();
                }
            }
        }

        private function _toggleDebugOptions():void {
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
                if (GV.ppd == null || GV.main == null) return;
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
                _systemToast.addMessage("Reconnect to Archipelago before starting a level", 0xFFFF8844);
                _modeInterceptor.clearPending();
                return;
            }
            startConnectionForSlot();
        }

        private function onSlotDeleteWarning(slotId:int):void {
            // Standalone slots have no Archipelago goal — skip the completion warning.
            if (_saveManager.isSlotStandalone(slotId)) return;
            if (!_saveManager.isSlotCompleted(slotId)) {
                _systemToast.addMessage("Warning: slot " + slotId + " is not yet completed. Deleting will lose most of your progress. Press D to confirm.", 0xFFFF8844);
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
                AV.sessionData.reset();
                _progressionBlocker.disable();
                _logger.log(MOD_NAME, "Standalone slot — skipping AP connection, slot=" + _saveManager.currentSlot);
                _systemToast.addMessage("Solo mode (Slot " + _saveManager.currentSlot + ") — playing without randomizer", 0xFF88CCFF);
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
                _connectionPanel.showWithOverlay(this.stage, _systemToast, _messageLogPanel);
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
            AV.sessionData.reset();
            _progressionBlocker.disable();
            if (_connectionPanel != null) _connectionPanel.dismiss();
            hideDisconnectPanel();
            _logger.log(MOD_NAME, "PLAYER_CHOSE_STANDALONE slot=" + _saveManager.currentSlot);
            _systemToast.addMessage("Solo mode (Slot " + _saveManager.currentSlot + ") — playing without randomizer", 0xFF88CCFF);
            _modeInterceptor.redispatchPendingClick();
        }

        // -----------------------------------------------------------------------
        // ConnectionManager callbacks

        private function onApConnected(p:Object):void
        {
            _needsConnection = false;

            // Load server data from JSON files (itemdata.json for AP ID mappings, logic.json for rules).
            AV.loadServerDataFromJSON();

            // Populate tokenMap from the Connected packet (loadServerDataFromJSON resets it to {}).
            AV.serverData.tokenMap = _connectionManager.tokenMap;

            // Reset + configure the in-game tracker from slot_data.  Must happen
            // BEFORE syncWithAP (which will populate session data via onItem).
            AV.sessionData.reset();
            if (p.slot_data != null) {
                AV.sessionData.configure(
                    AV.serverData.tokenMap,
                    p.slot_data.skill_categories
                );
                _fieldLogicEvaluator.configure(
                    p.slot_data.stage_tier,
                    p.slot_data.stage_skills,
                    p.slot_data.cumulative_skill_reqs,
                    p.slot_data.tier_stage_counts,
                    int(p.slot_data.token_requirement_percent),
                    p.slot_data.free_stages as Array
                );
                _achievementLogicEvaluator.configure(_fieldLogicEvaluator, _logicEvaluator);
                _logger.log(MOD_NAME, "  tracker configured — logic_rules_version="
                    + p.slot_data.logic_rules_version);
                _logicEnforcer.configure(_fieldLogicEvaluator, AV.serverData.serverOptions.enforce_logic);
            }
            _firstPlayBypass.configure(AV.serverData.serverOptions.disable_endurance, AV.serverData.serverOptions.disable_trial, AV.serverData.freeStages);
            _wavePrePatcher.configure(
                AV.serverData.serverOptions.enemyMultipliers.hp,
                AV.serverData.serverOptions.enemyMultipliers.armor,
                AV.serverData.serverOptions.enemyMultipliers.shield,
                AV.serverData.serverOptions.enemyMultipliers.waves,
                AV.serverData.serverOptions.enemyMultipliers.extraWaves
            );

            try {

                _logger.log(MOD_NAME, "onApConnected: saving and loading slot data");
                // Persist credentials before loadSlotData resets them via resetSettings().
                // Without this, first-time connection data is never written to the slot file.
                _saveManager.saveSlotData();
                _saveManager.loadSlotData(_saveManager.currentSlot);
                _levelUnlocker.applyBonusLevels();
            } catch (e:Error) {
                _logger.log(MOD_NAME, "ERROR in loadSlotData: " + e.message);
            }

            _levelUnlocker.configure(
                AV.serverData.serverOptions.tomeXpLevels.tattered,
                AV.serverData.serverOptions.tomeXpLevels.worn,
                AV.serverData.serverOptions.tomeXpLevels.ancient,
                AV.serverData.serverOptions.startingWizardLevel
            );
            _talismanUnlocker.setTalismanMap(AV.serverData.talismanMap);
            _talismanUnlocker.setTalismanNameMap(AV.serverData.talismanNameMap);
            _shadowCoreUnlocker.setShadowCoreMap(AV.serverData.shadowCoreMap);
            _shadowCoreUnlocker.setShadowCoreNameMap(AV.serverData.shadowCoreNameMap);
            if (_progressionBlocker != null) {
                _progressionBlocker.setWizStashTalData(AV.serverData.wizStashTalData);
            }

            _goalManager.configure(
                AV.serverData.serverOptions.goal,
                AV.serverData.serverOptions.talismanMinRarity,
                AV.serverData.serverOptions.fieldsRequired,
                AV.serverData.serverOptions.fieldsRequiredPercentage);

            if (_saveManager.slotCompleted) {
                _goalManager.markAlreadyCompleted();
            }
            // Note: we do NOT call _goalManager.check() here because GV.ppd
            // may still hold data from a previously loaded save slot.
            // The onSaveSave hook will catch a legitimate victory.
            if (_slotSettings != null) _slotSettings.configure(_connectionManager, _deathLinkHandler);
            if (_modButtons != null) _modButtons.settingsVisible = true;

            if (_connectionPanel != null) _connectionPanel.dismiss();
            hideDisconnectPanel();
            _modeInterceptor.redispatchPendingClick();

            if (_achPanelPatcher != null && _achievementLogicEvaluator != null) {
                _achPanelPatcher.updateExcluded(_achievementLogicEvaluator.getExcludedAchApIds());
                _achPanelPatcher.updateEffortExcluded(_achievementLogicEvaluator.getEffortExcludedAchApIds(), _achievementLogicEvaluator.getMaxEffortLabel());
                _achPanelPatcher.updateLogicFlags(_achievementLogicEvaluator.getInLogicAchApIds());
                _achPanelPatcher.updateDots(_achievementLogicEvaluator.getRequirementsMetApIds());
                _achPanelPatcher.refreshIfActive();
            }
        }

        /**
         * Refresh the achievement panel logic state.
         * Called as `_achievementUnlocker.onChecked` after any achievement location
         * check is sent, so collected achievements immediately leave "In Logic".
         */
        private function _refreshAchievementPanel():void {
            if (_achievementLogicEvaluator != null) _achievementLogicEvaluator.markDirty();
            if (_achPanelPatcher != null && _achievementLogicEvaluator != null) {
                _achPanelPatcher.updateLogicFlags(_achievementLogicEvaluator.getInLogicAchApIds());
                _achPanelPatcher.updateDots(_achievementLogicEvaluator.getRequirementsMetApIds());
                _achPanelPatcher.refreshIfActive();
            }
        }

        private function onSettingsClicked():void {
            if (_slotSettings == null) return;
            if (_slotSettings.isOpen) {
                _slotSettings.close();
            } else {
                _slotSettings.open();
            }
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
            if (_modButtons != null) _modButtons.settingsVisible = false;
            if (_slotSettings != null) _slotSettings.close();
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
            try {
                _logger.log(MOD_NAME, "grantItem called with apId=" + apId);

                // Track item for ending screen display
                var itemDisplayName:String = itemName(apId);
                if (_progressionBlocker != null) {
                    _levelEndScreenBuilder.trackReceivedItem(apId, itemDisplayName);
                    // Sent-item icons on the ending screen come from addSentItemToEndingScreen
                    // (triggered by handlePrintJSON) so we don't add received items here.
                }

                // Feed the in-game tracker (idempotent — safe to call before dispatch).
                AV.sessionData.onItem(apId);
                if (_fieldLogicEvaluator != null) _fieldLogicEvaluator.markDirty();
                if (_achievementLogicEvaluator != null) _achievementLogicEvaluator.markDirty();
                if (_achPanelPatcher != null && _achievementLogicEvaluator != null) {
                    _achPanelPatcher.updateExcluded(_achievementLogicEvaluator.getExcludedAchApIds());
                    _achPanelPatcher.updateEffortExcluded(_achievementLogicEvaluator.getEffortExcludedAchApIds(), _achievementLogicEvaluator.getMaxEffortLabel());
                    _achPanelPatcher.updateLogicFlags(_achievementLogicEvaluator.getInLogicAchApIds());
                    _achPanelPatcher.updateDots(_achievementLogicEvaluator.getRequirementsMetApIds());
                    _achPanelPatcher.refreshIfActive();
                }

                var strId:String = AV.serverData.tokenMap[String(apId)];
                if (strId != null) {
                    _logger.log(MOD_NAME, "  → Field token for stage: " + strId);
                    _stageUnlocker.unlockStage(strId);
                    _receivedToast.addItem("Received " + strId + " Field Token", 0xFFDD55);
                    return;
                }
                if (apId >= 700 && apId <= 723) {
                    _logger.log(MOD_NAME, "  → Skill apId: " + apId);
                    if (_progressionBlocker != null) _progressionBlocker.markSkillGranted(apId - 700);
                    _skillUnlocker.unlockSkill(apId);
                    return;
                }
                if (apId >= 800 && apId <= 814) {
                    _logger.log(MOD_NAME, "  → Battle trait apId: " + apId);
                    if (_progressionBlocker != null) _progressionBlocker.markTraitGranted(apId - 800);
                    _traitUnlocker.unlockBattleTrait(apId);
                    return;
                }
                if (apId >= 1100 && apId <= 1199) {
                    _logger.log(MOD_NAME, "  → XP tome apId: " + apId);
                    _levelUnlocker.grantXpFromApId(apId, itemDisplayName);
                    return;
                }
                if (apId >= 600 && apId <= 625) {
                    _logger.log(MOD_NAME, "  → Map tile apId: " + apId);
                    var tileGameId:int = int(AV.serverData.apIdToGameId[apId]);
                    if (GV.ppd != null && tileGameId >= 0 && tileGameId < GV.ppd.gainedMapTiles.length) {
                        GV.ppd.gainedMapTiles[tileGameId] = true;
                        _mapTilesUnlocked = false;
                        _logger.log(MOD_NAME, "  Map tile gameId=" + tileGameId + " unlocked");
                    }
                    return;
                }
                if ((apId >= 900 && apId <= 952) || (apId >= 1200 && apId <= 1246)) {
                    _logger.log(MOD_NAME, "  → Talisman fragment apId: " + apId);
                    var frag:* = _talismanUnlocker.grantFragment(apId);
                    if (frag != null) {
                        _levelEndScreenBuilder.addTalismanDropIconToEndingScreen(frag);
                    }
                    _saveManager.saveSlotData();
                    return;
                }
                if ((apId >= 1000 && apId <= 1016) || (apId >= 1300 && apId <= 1351)) {
                    _logger.log(MOD_NAME, "  → Shadow core apId: " + apId);
                    _shadowCoreUnlocker.grantShadowCores(apId);
                    if (apId >= 1300 && apId <= 1351) {
                        var scAmt:int = int(AV.serverData.shadowCoreMap[String(apId)]);
                        if (scAmt > 0)
                            _levelEndScreenBuilder.addShadowCoreDropIconToEndingScreen(scAmt);
                    }
                    _saveManager.saveSlotData();
                    return;
                }
                if (apId >= 2000 && apId <= 2636) {
                    _logger.log(MOD_NAME, "  → Achievement reward apId: " + apId);
                    var achName:String = _achievementUnlocker.findAchievementNameByApId(apId);
                    _logger.log(MOD_NAME, "     Found achievement name: " + achName);
                    if (achName != null) {
                        _achievementUnlocker.receiveAchievementReward(achName, apId);
                        _receivedToast.addItem("Received " + achName, 0xAA55FF);
                    } else {
                        _receivedToast.addItem("Received Achievement #" + apId, 0xAA55FF);
                        _logger.log(MOD_NAME, "  grantItem: achievement apId=" + apId + " not found in data map");
                    }
                    return;
                }
                _logger.log(MOD_NAME, "  grantItem: no handler for AP ID " + apId);
            } catch (err:Error) {
                _logger.log(MOD_NAME, "ERROR in grantItem(" + apId + "): " + err.message);
                _logger.log(MOD_NAME, "  Stack: " + err.getStackTrace());
            }
        }

        private function syncWithAP(items:Array):void {
            if (GV.ppd == null) {
                _pendingSyncItems = items;
                _logger.log(MOD_NAME, "syncWithAP: GV.ppd null, deferring sync (" + items.length + " items)");
                return;
            }
            _pendingSyncItems = null;

            if (_progressionBlocker != null) _progressionBlocker.resetGrants();

            var apSkills:Object = {};
            var apTraits:Object = {};
            var apTokens:Object = {};
            var apXpTotal:int   = 0;
            var apTalismans:Array  = [];
            var apShadowCores:Array = [];
            var tokenMap:Object    = AV.serverData.tokenMap;
            var tokenStages:Object = AV.serverData.tokenStages;

            // Rebuild tracker state from the full item list.
            AV.sessionData.reset();

            for each (var item:Object in items) {
                var apId:int = item.item;
                AV.sessionData.onItem(apId);

                // Track item for ending screen display
                if (_progressionBlocker != null) {
                    var itemDisplayName:String = itemName(apId);
                    _levelEndScreenBuilder.trackReceivedItem(apId, itemDisplayName);
                }

                if (apId >= 700 && apId <= 723) {
                    apSkills[apId - 700] = true;
                } else if (apId >= 800 && apId <= 814) {
                    apTraits[apId - 800] = true;
                } else if (tokenMap[String(apId)] != null) {
                    apTokens[tokenMap[String(apId)]] = true;
                } else if (apId >= 1100 && apId <= 1199) {
                    apXpTotal += _levelUnlocker.levelsForApId(apId);
                } else if ((apId >= 900 && apId <= 952) || (apId >= 1200 && apId <= 1246)) {
                    apTalismans.push(apId);
                } else if ((apId >= 1000 && apId <= 1016) || (apId >= 1300 && apId <= 1351)) {
                    apShadowCores.push(apId);
                }
            }

            // --- Skills ---
            var skillChanges:int = 0;
            for (var i:int = 0; i < 24; i++) {
                var shouldHaveSkill:Boolean = apSkills[i] == true;
                if (shouldHaveSkill && _progressionBlocker != null)
                    _progressionBlocker.markSkillGranted(i);
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
                if (shouldHaveTrait && _progressionBlocker != null)
                    _progressionBlocker.markTraitGranted(j);
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
            var freeStages:Array = AV.serverData.freeStages;
            if (freeStages != null) {
                for each (var freeStrId:String in freeStages) {
                    if (!_stageUnlocker.isStageUnlocked(freeStrId)) {
                        _stageUnlocker.unlockStage(freeStrId);
                        _logger.log(MOD_NAME, "  free stage unlocked: " + freeStrId);
                    }
                }
            }

            _saveManager.saveSlotData();

            if (_fieldLogicEvaluator != null) _fieldLogicEvaluator.markDirty();
            if (_achievementLogicEvaluator != null) _achievementLogicEvaluator.markDirty();

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

        private function onItemSentFromLocation(locId:int, sentItemName:String, recvName:String):void {
            if (_progressionBlocker == null) return;

            // In solo play every item-send is a self-send.  Talisman fragments are
            // already shown with a native McDropIconOutcome (via grantItem →
            // addTalismanDropIconToEndingScreen), so adding an AP icon here would
            // produce a duplicate.  Skip the sent-item AP icon for talisman self-sends.
            var sentData:Object = _connectionManager.itemsSentThisLevel[locId];
            if (sentData != null
                    && int(sentData.receivingSlot) == _connectionManager.mySlot
                    && sentItemName != null
                    && sentItemName.toLowerCase().indexOf("talisman") >= 0) {
                return;
            }

            _levelEndScreenBuilder.addSentItemToEndingScreen(locId, sentItemName, recvName);
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
            _systemToast.addMessage("DeathLink from " + source + "!", 0xFFFF4444);
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
            _systemToast.addMessage("DeathLink " + (_saveManager.deathLinkEnabled ? "enabled" : "disabled"),
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
            var strId:String = AV.serverData.tokenMap[String(apId)];
            if (strId != null) return strId + " Field Token";
            if ((apId >= 900 && apId <= 952) || (apId >= 1200 && apId <= 1246)) {
                return AV.serverData.talismanNameMap[String(apId)];
            }
            if ((apId >= 1000 && apId <= 1016) || (apId >= 1300 && apId <= 1351)) {
                return AV.serverData.shadowCoreNameMap[String(apId)];
            }
            if (apId >= 2000 && apId <= 2636) {
                var achName:String = _achievementUnlocker.findAchievementNameByApId(apId);
                return achName != null ? achName : ("Achievement #" + apId);
            }
            return null; // let ConnectionManager handle the rest
        }
    }
}
