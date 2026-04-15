package {
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
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
    import ui.ScrChangelog;
    import ui.ScrSlotSettings;
    import ui.ToastPanel;
    import ui.ItemToastPanel;
    import ui.MessageLog;
    import ui.MessageLogPanel;
    import ui.ScrDebugOptions;
    import ui.ConnectionPanel;
    import ui.DisconnectPanel;

    import update.UpdateChecker;

    import deathlink.DeathLinkHandler;
    import deathlink.EnragerOverride;

    import unlockers.NormalProgressionBlocker;
    import unlockers.SkillUnlocker;
    import unlockers.TraitUnlocker;
    import unlockers.LevelUnlocker;
    import unlockers.StageUnlocker;
    import unlockers.TalismanUnlocker;
    import unlockers.ShadowCoreUnlocker;
    import unlockers.AchievementUnlocker;

    import net.ConnectionManager;

    import AchievementMap;

    import tracker.CollectedState;
    import tracker.LogicEvaluator;
    import tracker.StageTinter;
    import tracker.LogicHelper;

    import patch.WizStashes;
    import patch.FirstPlayBypass;
    import patch.LogicEnforcer;
    import patch.WavePrePatcher;
    import patch.AchievementPanelPatcher;

    import save.FileHandler;
    import save.SaveManager;

    
    

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
        private var _achievementUnlocker:AchievementUnlocker;
        private var _achievementData:Object = {};         // achievement name -> apId, reward, required_effort, etc.
        private var _elementStages:Object = {};           // element name -> Array of stage strIds
        private var _reportedAchievements:Object = {};    // achievement name -> true (already reported)
        private var _pendingAchievements:Object  = {};    // achievement name -> true (status=2 already logged)
        private var _firstPlayBypass:FirstPlayBypass;
        private var _logicEnforcer:LogicEnforcer;
        private var _wavePrePatcher:WavePrePatcher;
        private var _collectedState:CollectedState;
        private var _logicEvaluator:LogicEvaluator;
        private var _logicHelper:LogicHelper;
        private var _stageTinter:StageTinter;
        private var _achPanelPatcher:AchievementPanelPatcher;
        private var _achPanelLogicDirty:Boolean = false; // set when logic changes, cleared after update

        // Cache for in-logic achievements (recomputed only when dirty)
        private var _inLogicAchievementsCache:Array = [];
        private var _inLogicAchievementsDirty:Boolean = false; // set when items arrive or windows open

        private var _keyListenerAdded:Boolean  = false;
        private var _needsConnection:Boolean   = false;
        private var _lastScreen:int            = -1;
        private var _lastAchievementWindowStatus:int = -1; // detect when achievement window opens (305/306)
        private var _mapTilesUnlocked:Boolean  = false;
        private var _standalone:Boolean        = false;
        private var _pendingSyncItems:Array    = null; // deferred full-sync when GV.ppd was null
        private var _lastPpd:Object            = null; // tracks ppd identity to detect slot changes
        private var _stagesPopulated:Boolean   = false; // tracks if stage data has been loaded into AV

        // Changelog / version / update-check state
        private var _updateChecker:UpdateChecker;
        private var _scrChangelog:ScrChangelog;
        private var _versionLabel:TextField;            // "Archipelago Mod vX.X.X" on MAINMENU
        // Changelog button is owned by _modButtons (ModButtons.showOnMainMenu)
        private var _updateBadge:Sprite;                // hidden until a newer version is found
        private var _mainMenuElementsOnStage:Boolean  = false;
        private var _mainMenuFetchDone:Boolean        = false; // fetch once per session
        private var _dbgFrameCounter:int             = 0;     // for throttled screen logging
        private var _cachedReleases:Array             = null;
        private var _shouldAutoShowChangelog:Boolean  = false;

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
                // Note: _achievementUnlocker will be initialized after _connectionManager is created
                _logicEnforcer      = new LogicEnforcer(_logger, MOD_NAME);
                _wavePrePatcher     = new WavePrePatcher(_logger, MOD_NAME);
                _firstPlayBypass    = new FirstPlayBypass(_logger, MOD_NAME);

                // In-game tracker (stage light tinting)
                _collectedState  = new CollectedState(_logger, MOD_NAME);
                _logicEvaluator  = new LogicEvaluator(_logger, MOD_NAME, _collectedState);

                _debugOptions  = new ScrDebugOptions(this);
                _slotSettings  = new ScrSlotSettings();

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

                // Initialize achievement unlocker
                _achievementUnlocker = new AchievementUnlocker(_logger, MOD_NAME, _connectionManager, _collectedState);

                // Set unlocker references in NormalProgressionBlocker for dropIcons processor
                _normalProgressionBlocker.setUnlockers(
                    _achievementUnlocker,
                    _skillUnlocker,
                    _traitUnlocker,
                    _talismanUnlocker,
                    _shadowCoreUnlocker
                );

                // Initialize logic helper (for achievement and field access checks)
                _logicHelper = new LogicHelper(_logger, MOD_NAME, _collectedState, _logicEvaluator, _connectionManager);

                // Load achievement map for achievement tracking
                loadAchievementMap();

                _achPanelPatcher = new AchievementPanelPatcher(_logger, MOD_NAME);

                _stageTinter = new StageTinter(_logger, MOD_NAME, _connectionManager, _logicEvaluator);

                // Button factory — owns all mod buttons on selector + main menu
                _modButtons = new ModButtons(_logger, MOD_NAME, _connectionManager, _logicEvaluator);
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

                _deathLinkHandler = new DeathLinkHandler(_logger, MOD_NAME, _toast);
                _deathLinkHandler.onPlayerDied         = onPlayerDied;
                _deathLinkHandler.onPunishmentReceived = onPunishmentReceived;
                _connectionManager.onDeathLinkReceived = onDeathLinkReceived;

                _goalManager = new GoalManager(_logger, MOD_NAME, _itemToast);
                _goalManager.onGoalReached = onGoalReached;

                // Changelog / update checker
                _updateChecker = new UpdateChecker(_logger, MOD_NAME);
                _updateChecker.onReleasesLoaded  = onReleasesLoaded;
                _updateChecker.onUpdateAvailable = onUpdateAvailable;
                _updateChecker.onFetchFailed     = onFetchFailed;
                _scrChangelog = new ScrChangelog();

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
            if (_modButtons != null) _modButtons.removeFromSelector();
            if (_slotSettings != null) _slotSettings.close();
            removeMainMenuElements();
            if (_updateChecker != null) { _updateChecker.dispose(); _updateChecker = null; }
            if (_scrChangelog != null) { _scrChangelog.dismiss(); _scrChangelog = null; }
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
                _logger.log(MOD_NAME, "Stage data populated into AV");
            }

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

            // Add MAINMENU version label and changelog button once stage is available.
            if (!_mainMenuElementsOnStage
                    && int(GV.main.currentScreen) == ScreenId.MAINMENU
                    && this.stage != null) {
                _logger.log(MOD_NAME, "[MainMenuUI] Adding — screen=" + int(GV.main.currentScreen)
                    + " MAINMENU=" + ScreenId.MAINMENU);
                addMainMenuElements();
                _mainMenuElementsOnStage = true;
            }
            // Keep changelog button aligned between Start Game and Exit every frame.
            if (_mainMenuElementsOnStage && _modButtons != null) {
                _modButtons.onMainMenuFrame();
            }

            // Remove them the moment we leave MAINMENU, regardless of transition path.
            if (_mainMenuElementsOnStage
                    && int(GV.main.currentScreen) != ScreenId.MAINMENU) {
                _logger.log(MOD_NAME, "[MainMenuUI] Removing — screen=" + int(GV.main.currentScreen)
                    + " MAINMENU=" + ScreenId.MAINMENU);
                removeMainMenuElements();
            }
            // Throttled log: every 120 frames, report screen + flag so we can see if
            // elements persist on a screen they shouldn't.
            _dbgFrameCounter++;
            if (_dbgFrameCounter % 120 == 0 && _mainMenuElementsOnStage) {
                _logger.log(MOD_NAME, "[MainMenuUI] Still on stage — screen="
                    + int(GV.main.currentScreen) + " MAINMENU=" + ScreenId.MAINMENU);
            }

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
                detectAndReportAchievements();
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
                    _reportedAchievements = {};
                    _pendingAchievements  = {};
                    if (_modButtons != null) _modButtons.removeFromMainMenu();
                    if (_connectionPanel != null) _connectionPanel.dismiss();
                    hideDisconnectPanel();
                    _goalManager.reset();
                    if (_toast != null) _toast.clear();
                    if (_itemToast != null) _itemToast.clear();
                    _logger.log(MOD_NAME, "Entered MAINMENU — connection reset, toasts cleared");
                    removeMainMenuElements(); // remove any existing set before re-adding next frame
                }

                // Entering LOADGAME — always reset connection so leaving LOADGAME
                // sees _isConnected=false and triggers the overlay when needed.
                if (screen == ScreenId.LOADGAME) {
                    _connectionManager.disconnectAndReset();
                    _needsConnection = false;
                    _standalone      = false;
                    _reportedAchievements = {};
                    _pendingAchievements  = {};
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
                    removeMainMenuElements();
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
                _lastAchievementWindowStatus = -1;  // Reset achievement window status tracking
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
                _inLogicAchievementsDirty = true;  // Recompute when map tiles loaded
                _logger.log(MOD_NAME, "Map tile visibility synced with stage states");
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
            if (_scrChangelog != null && _scrChangelog.isShowing) {
                _scrChangelog.doEnterFrame();
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
            // SlotSettings panel is attached to GV.main, no resize handling needed.
        }

        // -----------------------------------------------------------------------
        // MAINMENU version label + changelog button

        /**
         * Create and add the version label, changelog button, and update badge
         * to the stage. Also triggers the auto-show changelog logic if the player
         * has updated (or is running for the first time), and fires the GitHub
         * release fetch if it has not been done this session.
         */
        private function addMainMenuElements():void {
            var stg:Stage = this.stage;
            if (stg == null) return;

            // Read persisted config to decide if we should auto-show the changelog.
            var config:Object = _fileHandler.loadModConfig();
            var lastSeen:String = (config != null && config.lastSeenVersion != null)
                ? String(config.lastSeenVersion) : null;
            _shouldAutoShowChangelog = (lastSeen == null || lastSeen != VERSION);

            // Load cached releases if available.
            if (config != null && config.cachedReleasesJson != null) {
                try {
                    var cached:Array = JSON.parse(String(config.cachedReleasesJson)) as Array;
                    if (cached != null && cached.length > 0) _cachedReleases = cached;
                } catch (e:Error) {
                    _logger.log(MOD_NAME, "addMainMenuElements: failed to parse cached releases — " + e.message);
                }
            }

            // Version label — bottom-left corner.
            var labelFmt:TextFormat = new TextFormat("_sans", 12, 0xBBAADD);
            _versionLabel = new TextField();
            _versionLabel.defaultTextFormat = labelFmt;
            _versionLabel.selectable   = false;
            _versionLabel.mouseEnabled = false;
            _versionLabel.autoSize     = TextFieldAutoSize.LEFT;
            _versionLabel.text         = "Mod v" + VERSION + "  |  apworld v" + APWORLD_VERSION;
            _versionLabel.x = 10;
            _versionLabel.y = stg.stageHeight - 48;
            stg.addChild(_versionLabel);

            // Update badge — to the right of the version label, hidden until needed.
            _updateBadge = _makeUpdateBadge();
            _updateBadge.x = 10 + _versionLabel.textWidth + 12;
            _updateBadge.y = stg.stageHeight - 50;
            _updateBadge.visible = false;
            _updateBadge.addEventListener(MouseEvent.CLICK, onChangelogBtnClicked, false, 0, true);
            stg.addChild(_updateBadge);

            // Auto-show changelog when version has changed (first run or after update).
            if (_shouldAutoShowChangelog) {
                openChangelog();
                updateLastSeenVersion();
            }

            // Fire one GitHub fetch per session.
            if (!_mainMenuFetchDone && _updateChecker != null) {
                _updateChecker.fetchReleases(VERSION);
                _mainMenuFetchDone = true;
            }
        }

        /**
         * Remove all MAINMENU-only elements from the stage.
         * Safe to call even if elements were never added.
         */
        private function removeMainMenuElements():void {
            _logger.log(MOD_NAME, "[MainMenuUI] removeMainMenuElements called — screen="
                + int(GV.main.currentScreen));
            if (_versionLabel != null && _versionLabel.parent != null) {
                _versionLabel.parent.removeChild(_versionLabel);
            }
            _versionLabel = null;

            if (_modButtons != null) _modButtons.removeFromMainMenu();

            if (_updateBadge != null) {
                _updateBadge.removeEventListener(MouseEvent.CLICK, onChangelogBtnClicked);
                if (_updateBadge.parent != null) _updateBadge.parent.removeChild(_updateBadge);
            }
            _updateBadge = null;

            _mainMenuElementsOnStage = false;

            if (_scrChangelog != null) _scrChangelog.dismiss();
        }

        /** Open (or refresh) the changelog panel. Only valid on the main menu. */
        private function openChangelog():void {
            if (int(GV.main.currentScreen) != ScreenId.MAINMENU) return;
            if (_scrChangelog == null) _scrChangelog = new ScrChangelog();
            var releases:Array = (_cachedReleases != null && _cachedReleases.length > 0)
                ? _cachedReleases
                : [{ tag: "", name: "Could not reach GitHub", date: "",
                     body: "Release notes are unavailable.\nPlease check your internet connection." }];
            _scrChangelog.populate(releases);
            _scrChangelog.show();
        }

        /** Persist the current VERSION as the last-seen version. */
        private function updateLastSeenVersion():void {
            var config:Object = _fileHandler.loadModConfig();
            if (config == null) config = {};
            config.lastSeenVersion = VERSION;
            _fileHandler.saveModConfig(config);
            _shouldAutoShowChangelog = false;
        }

        // Callbacks from UpdateChecker

        private function onReleasesLoaded(releases:Array):void {
            _cachedReleases = releases;
            // Persist to cache so it is available without a network request next time.
            var config:Object = _fileHandler.loadModConfig();
            if (config == null)
                config = {};
            config.cachedReleasesJson = JSON.stringify(releases);
            _fileHandler.saveModConfig(config);
            // If the changelog is open on the main menu, refresh it with the freshly-loaded data.
            if (_scrChangelog != null && _scrChangelog.isShowing
                    && int(GV.main.currentScreen) == ScreenId.MAINMENU) {
                _scrChangelog.populate(releases);
                _scrChangelog.show();
            }
        }

        private function onUpdateAvailable(latestTag:String):void {
            _logger.log(MOD_NAME, "Update available: " + latestTag);
            if (_updateBadge != null) _updateBadge.visible = true;
        }

        private function onFetchFailed():void {
            _logger.log(MOD_NAME, "GitHub release fetch failed — using cached/fallback data");
        }

        private function onChangelogBtnClicked(e:MouseEvent):void {
            openChangelog();
        }

        private function _makeUpdateBadge():Sprite {
            var badge:Sprite = new Sprite();
            var label:String = "\u2191 Update available!";

            var fmt:TextFormat = new TextFormat("_sans", 11, 0xFFEE66, true);
            var tf:TextField = new TextField();
            tf.defaultTextFormat = fmt;
            tf.selectable   = false;
            tf.mouseEnabled = false;
            tf.autoSize     = TextFieldAutoSize.LEFT;
            tf.text         = label;

            var bw:Number = tf.textWidth + 16;
            var bh:Number = 18;

            badge.graphics.beginFill(0x2A1000, 0.9);
            badge.graphics.lineStyle(1, 0xCC8800);
            badge.graphics.drawRoundRect(0, 0, bw, bh, 5, 5);
            badge.graphics.endFill();

            tf.x = 8;
            tf.y = 0;
            badge.addChild(tf);

            badge.buttonMode    = true;
            badge.useHandCursor = true;
            return badge;
        }


        // -----------------------------------------------------------------------
        // Debug hotkey

        /**
         * Returns a sorted array of achievement names that haven't been collected yet
         * (i.e., location checks still missing from AP server).
         * Only shows achievements that are actually in the AP world (based on YAML config).
         */
        private function _computeInLogicAchievements():Array {
            var result:Array = [];
            if (!_connectionManager.isConnected || !_collectedState || !_achievementData) {
                return result;
            }
            var missing:Object = AV.saveData.missingLocations;
            var requiredEffort:int = AV.serverData.serverOptions.achievementRequiredEffort;

            // Effort hierarchy for filtering
            var effortHierarchy:Array = ["Trivial", "Minor", "Major", "Extreme"];
            var maxEffortStr:String = requiredEffort > 0 && requiredEffort <= 4
                ? effortHierarchy[requiredEffort - 1]
                : "Trivial";

            // Check each achievement in alphabetical order
            var achNames:Array = [];
            for (var name:String in _achievementData) {
                achNames.push(name);
            }
            achNames.sort(Array.CASEINSENSITIVE);

            for (var i:int = 0; i < achNames.length; i++) {
                var achName:String = achNames[i];
                var achData:Object = _achievementData[achName];
                if (!achData || !achData.apId) continue;

                var apId:int = int(achData.apId);

                // Filter by mode: only include achievements playable in journey mode
                var modes:Array = achData.modes as Array;
                if (modes != null && modes.indexOf("journey") < 0) {
                    continue; // Not available in journey mode, skip entirely
                }

                // Filter by required effort level
                var achEffort:String = achData.required_effort || "Trivial";
                if (effortHierarchy.indexOf(achEffort) > effortHierarchy.indexOf(maxEffortStr)) {
                    continue;
                }
                

                // Include if location check is still missing (AP server included it in world but not yet collected)
                if (missing[apId] == true) {                    
                    // Validate access requirements
                    var achHasRequirements:Boolean = _checkAchievementAccessible(achName, achData);
                    if (achHasRequirements) {                        
                        result.push(achName);
                    }
                }                            
            }            

            return result;
        }

        /**
         * Check if an achievement's requirements are met (skills, battle traits, stage elements).
         * Returns true if all AP-gated requirements have been collected or no special requirements exist.
         */
        private function _checkAchievementAccessible(achName:String, achData:Object):Boolean {
            if (!achData || !achData.requirements) return false;

            var requirements:Array = achData.requirements as Array;
            if (!requirements || requirements.length == 0) return true;

            // Debug logging for specific achievement
            var isDebugAch:Boolean = (achName == "Shattered Waves");
            if (isDebugAch) {
                _logger.log(MOD_NAME, "=== CHECKING ACHIEVEMENT: " + achName + " ===");
                _logger.log(MOD_NAME, "  Total requirements: " + requirements.length);
            }

            // Battle trait names indexed by game_id (must match TraitUnlocker.BATTLE_TRAIT_NAMES order)
            var TRAIT_NAMES:Array = [
                "Adaptive Carapace", "Dark Masonry", "Swarmling Domination", "Overcrowd",
                "Corrupted Banishment", "Awakening", "Insulation", "Hatred",
                "Swarmling Parasites", "Haste", "Thick Air", "Vital Link",
                "Giant Domination", "Strength in Numbers", "Ritual"
            ];

            for (var i:int = 0; i < requirements.length; i++) {
                // Trim whitespace and newlines from each requirement string
                var req:String = _trimString(String(requirements[i]));
                var reqLower:String = req.toLowerCase();

                // --- Skill requirement: "X skill" ---
                // Also handles pipe-separated OR: "Freeze skill|Whiteout skill|Ice Shards skill"
                // meaning the achievement can be done with ANY one of the listed skills.
                if (reqLower.indexOf(" skill") >= 0) {
                    if (isDebugAch) _logger.log(MOD_NAME, "  Checking requirement: " + req);
                    if (req.indexOf("|") >= 0) {
                        // OR: need at least one of the piped skills
                        var skillOptions:Array = req.split("|");
                        var anySkillFound:Boolean = false;
                        for each (var skillOpt:String in skillOptions) {
                            skillOpt = _trimString(skillOpt);
                            var optLower:String = skillOpt.toLowerCase();
                            if (optLower.indexOf(" skill") >= 0) {
                                var optSkillName:String = _trimString(skillOpt.substring(0, optLower.indexOf(" skill")));
                                var optSkillIdx:int = CollectedState.SKILL_NAMES.indexOf(optSkillName);
                                if (isDebugAch) _logger.log(MOD_NAME, "    Option: '" + optSkillName + "' (idx=" + optSkillIdx + ", hasItem=" + (_collectedState && _collectedState.hasItem(700 + optSkillIdx)) + ")");
                                if (optSkillIdx >= 0 && _collectedState && _collectedState.hasItem(700 + optSkillIdx)) {
                                    anySkillFound = true;
                                    break;
                                }
                            }
                        }
                        if (!anySkillFound) {
                            if (isDebugAch) _logger.log(MOD_NAME, "    -> FAILED: no skills matched");
                            return false;
                        }
                        if (isDebugAch) _logger.log(MOD_NAME, "    -> PASSED: at least one skill found");
                    } else {
                        var skillEndIdx:int = reqLower.indexOf(" skill");
                        var skillName:String = _trimString(req.substring(0, skillEndIdx));
                        var skillIdx:int = CollectedState.SKILL_NAMES.indexOf(skillName);
                        if (isDebugAch) _logger.log(MOD_NAME, "    Skill: '" + skillName + "' (idx=" + skillIdx + ", hasItem=" + (_collectedState && _collectedState.hasItem(700 + skillIdx)) + ")");
                        // If skill not found or not collected, block the achievement
                        if (skillIdx < 0) {
                            // Unknown skill name — log and block
                            _logger.log(MOD_NAME, "Warning: unknown skill in achievement '" + achName + "': " + skillName);
                            if (isDebugAch) _logger.log(MOD_NAME, "    -> FAILED: unknown skill");
                            return false;
                        }
                        if (!_collectedState || !_collectedState.hasItem(700 + skillIdx)) {
                            if (isDebugAch) _logger.log(MOD_NAME, "    -> FAILED: skill not collected");
                            return false;
                        }
                        if (isDebugAch) _logger.log(MOD_NAME, "    -> PASSED: skill collected");
                    }
                }

                // --- Element requirement: "X element" ---
                // Check via _elementStages map: is any stage with this element currently in logic?
                else if (reqLower.indexOf(" element") >= 0) {
                    if (isDebugAch) _logger.log(MOD_NAME, "  Checking requirement: " + req);
                    var elemEndIdx:int = reqLower.indexOf(" element");
                    var elemName:String = _trimString(req.substring(0, elemEndIdx));
                    if (_elementStages != null) {
                        var stages:Array = _elementStages[elemName] as Array;
                        if (isDebugAch) _logger.log(MOD_NAME, "    Element: '" + elemName + "' (stages=" + (stages ? stages.length : 0) + ")");
                        if (stages != null && stages.length > 0) {
                            var elemAccessible:Boolean = false;
                            for (var s:int = 0; s < stages.length; s++) {
                                var stageInLogic:Boolean = _logicEvaluator != null && _logicEvaluator.isStageInLogic(stages[s]);
                                if (isDebugAch) _logger.log(MOD_NAME, "      Stage " + stages[s] + ": " + (stageInLogic ? "IN" : "OUT"));
                                if (stageInLogic) {
                                    elemAccessible = true;
                                    break;
                                }
                            }
                            if (!elemAccessible) {
                                if (isDebugAch) _logger.log(MOD_NAME, "    -> FAILED: no stages in logic");
                                return false;
                            }
                            if (isDebugAch) _logger.log(MOD_NAME, "    -> PASSED: at least one stage in logic");
                        } else {
                            if (isDebugAch) _logger.log(MOD_NAME, "    -> No stage mapping found, assuming accessible");
                        }
                        // If no stage mapping for this element, assume accessible (don't block)
                    } else {
                        if (isDebugAch) _logger.log(MOD_NAME, "    -> _elementStages is null");
                    }
                }

                // --- Trait requirement: "X trait" ---
                // Format in logic_rules.json is "Ritual trait" (not "battle trait")
                else if (reqLower.indexOf(" trait") >= 0) {
                    var traitEndIdx:int = reqLower.indexOf(" trait");
                    var traitName:String = _trimString(req.substring(0, traitEndIdx));

                    if (traitName.toLowerCase() == "any battle") {
                        // Special case: need at least one battle trait (AP IDs 400–414)
                        var hasTrait:Boolean = false;
                        for (var t:int = 0; t < 15; t++) {
                            if (_collectedState && _collectedState.hasItem(400 + t)) { hasTrait = true; break; }
                        }
                        if (!hasTrait) return false;
                    } else {
                        var traitId:int = TRAIT_NAMES.indexOf(traitName);
                        if (traitId >= 0 && _collectedState && !_collectedState.hasItem(400 + traitId)) {
                            return false;
                        }
                    }
                }

                // --- Field requirement: "Field A4" or "Field N1, U1 or R5" (OR) ---
                else if (reqLower.indexOf("field ") == 0) {
                    var fieldPart:String = _trimString(req.substring(6));
                    // Split on ", " or " or " to get individual stage strIds
                    var stageTokens:Array = fieldPart.split(/,\s*|\s+or\s+/i);
                    var fieldAccessible:Boolean = false;
                    for (var f:int = 0; f < stageTokens.length; f++) {
                        var stageId:String = _trimString(String(stageTokens[f]));
                        if (stageId.length > 0 && _logicEvaluator != null
                                && _logicEvaluator.isStageInLogic(stageId)) {
                            fieldAccessible = true;
                            break;
                        }
                    }
                    if (!fieldAccessible) return false;
                }

                // --- Game mode requirements ---
                // Mod is journey-only; any requirement for endurance or trial blocks the achievement.
                else if (reqLower == "trial") {
                    return false;
                }
                else if (reqLower == "endurance") {
                    return false;
                }
                else if (reqLower == "endurance and trial") {
                    return false;
                }

                // --- Skill group counters: "strikeSpells: N", "enhancementSpells: N", "gemSkills: N" ---
                // strikeSpells  = {Freeze, Whiteout, Ice Shards} — need at least N
                // enhancementSpells = {Bolt, Beam, Barrage} — need at least N
                // gemSkills = {Critical Hit, Mana Leech, Bleeding, Armor Tearing, Poison, Slowing} — need at least N
                else if (reqLower.indexOf("strikespells") == 0) {
                    var strikeNeeded:int = int(_trimString(reqLower.substring(reqLower.indexOf(":") + 1)));
                    if (!_logicHelper.hasStrikeSpells(strikeNeeded)) return false;
                }
                else if (reqLower.indexOf("enhancementspells") == 0) {
                    var enhanceNeeded:int = int(_trimString(reqLower.substring(reqLower.indexOf(":") + 1)));
                    if (!_logicHelper.hasEnhancementSpells(enhanceNeeded)) return false;
                }
                else if (reqLower.indexOf("gemskills") == 0) {
                    var gemNeeded:int = int(_trimString(reqLower.substring(reqLower.indexOf(":") + 1)));
                    if (!_logicHelper.hasGemSkills(gemNeeded)) return false;
                }

                // --- Wave requirement: "minWave: N" ---
                // Delegates to LogicHelper which checks both journey tier accessibility
                // and endurance/trial availability for waves > 96.
                else if (reqLower.indexOf("minwave") == 0) {
                    var waveColonIdx:int = reqLower.indexOf(":");
                    var waveNeeded:int = int(_trimString(reqLower.substring(waveColonIdx + 1)));
                    if (!_logicHelper.HasFieldWithMinWaveCount(waveNeeded)) return false;
                }

                // --- Field token requirement: "fieldToken: N" ---
                // Checks that at least N field tokens (AP IDs 1-199) have been received.
                else if (reqLower.indexOf("fieldtoken") == 0) {
                    var ftColonIdx:int = reqLower.indexOf(":");
                    var ftNeeded:int = int(_trimString(reqLower.substring(ftColonIdx + 1)));
                    var ftCount:int = 0;
                    for (var ftId:int = 1; ftId <= 199; ftId++) {
                        if (_collectedState && _collectedState.hasItem(ftId)) ftCount++;
                    }
                    if (ftCount < ftNeeded) return false;
                }

                // Stat, wave, and other in-game requirements are not AP-gated; skip them.
            }

            if (isDebugAch) {
                _logger.log(MOD_NAME, "=== RESULT: " + achName + " IS IN LOGIC ===");
            }
            return true;
        }

        /** Trim whitespace from both ends of a string (ActionScript 3 doesn't have String.trim()). */
        private function _trimString(str:String):String {
            return str.replace(/^\s+|\s+$/g, "");
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
                if (_collectedState != null) _collectedState.reset();
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
            if (_collectedState != null) _collectedState.reset();
            _normalProgressionBlocker.disable();
            if (_connectionPanel != null) _connectionPanel.dismiss();
            hideDisconnectPanel();
            _logger.log(MOD_NAME, "PLAYER_CHOSE_STANDALONE slot=" + _saveManager.currentSlot);
            _toast.addMessage("Solo mode (Slot " + _saveManager.currentSlot + ") — playing without randomizer", 0xFF88CCFF);
            _modeInterceptor.redispatchPendingClick();
        }

        // -----------------------------------------------------------------------
        // ConnectionManager callbacks

        private function onApConnected(p:Object):void
        {
            _needsConnection = false;

            // Load server data from JSON files (itemdata.json for AP ID mappings, logic.json for rules).
            AV.loadServerDataFromJSON();

            // Reset + configure the in-game tracker from slot_data.  Must happen
            // BEFORE syncWithAP (which will populate collected state via onItem).
            if (_collectedState != null) _collectedState.reset();
            if (p.slot_data != null) {
                _collectedState.configure(
                    AV.serverData.tokenMap,
                    p.slot_data.skill_categories
                );
                _logicEvaluator.configure(
                    p.slot_data.stage_tier,
                    p.slot_data.stage_skills,
                    p.slot_data.cumulative_skill_reqs,
                    p.slot_data.tier_stage_counts,
                    int(p.slot_data.token_requirement_percent),
                    p.slot_data.free_stages as Array
                );
                _logger.log(MOD_NAME, "  tracker configured — logic_rules_version="
                    + p.slot_data.logic_rules_version);
                _logicEnforcer.configure(_logicEvaluator, AV.serverData.serverOptions.enforce_logic);
            }
            _firstPlayBypass.configure(AV.serverData.serverOptions.disable_endurance, AV.serverData.serverOptions.disable_trial);
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
            if (_normalProgressionBlocker != null) {
                _normalProgressionBlocker.setWizStashTalData(AV.serverData.wizStashTalData);
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

                // Track item for ending screen display, and push it live if ending is still active
                if (_normalProgressionBlocker != null) {
                    var itemDisplayName:String = itemName(apId);
                    _normalProgressionBlocker.trackReceivedItem(apId, itemDisplayName);
                    _normalProgressionBlocker.addItemToActiveEndingScreen(apId, itemDisplayName);
                }

                // Feed the in-game tracker (idempotent — safe to call before dispatch).
                if (_collectedState != null) _collectedState.onItem(apId);
                if (_logicEvaluator != null) _logicEvaluator.markDirty();
                _achPanelLogicDirty = true;
                _inLogicAchievementsDirty = true;  // Recompute achievements cache when items arrive

                var strId:String = AV.serverData.tokenMap[String(apId)];
                if (strId != null) {
                    _logger.log(MOD_NAME, "  → Field token for stage: " + strId);
                    _stageUnlocker.unlockStage(strId);
                    _itemToast.addItem("Unlocked: " + strId + " Field Token", 0xFFDD55);
                    return;
                }
                if (apId >= 700 && apId <= 723) {
                    _logger.log(MOD_NAME, "  → Skill apId: " + apId);
                    if (_normalProgressionBlocker != null) _normalProgressionBlocker.markSkillGranted(apId - 700);
                    _skillUnlocker.unlockSkill(apId);
                    return;
                }
                if (apId >= 800 && apId <= 814) {
                    _logger.log(MOD_NAME, "  → Battle trait apId: " + apId);
                    if (_normalProgressionBlocker != null) _normalProgressionBlocker.markTraitGranted(apId - 800);
                    _traitUnlocker.unlockBattleTrait(apId);
                    return;
                }
                if (apId >= 500 && apId <= 502) {
                    _logger.log(MOD_NAME, "  → XP bonus apId: " + apId);
                    _levelUnlocker.grantXpBonus(apId);
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
                    _talismanUnlocker.grantFragment(apId);
                    _saveManager.saveSlotData();
                    return;
                }
                if ((apId >= 1000 && apId <= 1016) || (apId >= 1300 && apId <= 1351)) {
                    _logger.log(MOD_NAME, "  → Shadow core apId: " + apId);
                    _shadowCoreUnlocker.grantShadowCores(apId);
                    _saveManager.saveSlotData();
                    return;
                }
                if (apId >= 2000 && apId <= 2636) {
                    _logger.log(MOD_NAME, "  → Achievement reward apId: " + apId);
                    // Achievement reward from another player (only award skill points, don't mark as collected)
                    var achName:String = _findAchievementNameByApId(apId);
                    _logger.log(MOD_NAME, "     Found achievement name: " + achName);
                    if (achName != null && _achievementUnlocker != null) {
                        _achievementUnlocker.receiveAchievementReward(achName, apId, _achievementData);
                        _itemToast.addItem("Achievement Reward: " + achName, 0xAA55FF);
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

            if (_normalProgressionBlocker != null) _normalProgressionBlocker.resetGrants();

            var apSkills:Object = {};
            var apTraits:Object = {};
            var apTokens:Object = {};
            var apXpTotal:int   = 0;
            var apTalismans:Array  = [];
            var apShadowCores:Array = [];
            var tokenMap:Object    = AV.serverData.tokenMap;
            var tokenStages:Object = AV.serverData.tokenStages;

            // Rebuild tracker state from the full item list.
            if (_collectedState != null) _collectedState.reset();

            for each (var item:Object in items) {
                var apId:int = item.item;
                if (_collectedState != null) _collectedState.onItem(apId);

                // Track item for ending screen display
                if (_normalProgressionBlocker != null) {
                    var itemDisplayName:String = itemName(apId);
                    _normalProgressionBlocker.trackReceivedItem(apId, itemDisplayName);
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

            if (_logicEvaluator != null) _logicEvaluator.markDirty();

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
        // Achievement Helpers

        /**
         * Reverse-lookup: find achievement name by AP ID.
         * Returns null if not found.
         */
        private function _findAchievementNameByApId(apId:int):String {
            for (var name:String in _achievementData) {
                var achEntry:Object = _achievementData[name];
                if (achEntry && achEntry.apId == apId) {
                    return name;
                }
            }
            return null;
        }

        /**
         * Detect achievements collected in-game and submit them to AP.
         * Called periodically from onEnterFrame.
         */
        private function detectAndReportAchievements():void {
            if (!GV.achiCollection || !_connectionManager.isConnected || !_achievementUnlocker || !_achievementData) {
                if (_dbgFrameCounter % 600 == 0) {
                    _logger.log(MOD_NAME, "detectAndReportAchievements: guard blocked"
                        + "  achiCollection=" + (GV.achiCollection != null)
                        + "  connected=" + _connectionManager.isConnected
                        + "  unlocker=" + (_achievementUnlocker != null)
                        + "  data=" + (_achievementData != null));
                }
                return;
            }

            try {
                // Access achievements from the game's AchiCollection
                var achisByOrder:Array = GV.achiCollection.achisByOrder;
                if (!achisByOrder) {
                    _logger.log(MOD_NAME, "detectAndReportAchievements: GV.achiCollection.achisByOrder not found");
                    return;
                }

                // Iterate through all achievements
                for (var i:int = 0; i < achisByOrder.length; i++) {
                    var ach:* = achisByOrder[i];
                    if (!ach) continue;

                    // Check if achievement is permanently earned (status 3 only).
                    // Status 2 = UNLOCKED_BUT_HAVE_TO_WIN means the condition was
                    // met during a live battle but the player hasn't won yet — we
                    // must NOT report it until it becomes permanently unlocked (3),
                    // otherwise losing/exiting the stage would cause a false check.
                    var status:int = int(ach.status);
                    var achTitle:String = String(ach.title);
                    if (status == 2 && !_pendingAchievements[achTitle]) {
                        _pendingAchievements[achTitle] = true;
                        _logger.log(MOD_NAME, "Pending: " + achTitle + " (achievement, awaiting win)");
                    }
                    var isCollected:Boolean = (status == 3);
                    if (!isCollected) {
                        continue;
                    }

                    // achTitle already set above when checking status
                    if (!achTitle) {
                        continue;
                    }

                    // Check if we've already reported this one
                    if (_reportedAchievements[achTitle]) {
                        continue; // Already reported
                    }

                    // Look up AP ID for this achievement by title
                    var achData:Object = _achievementData[achTitle];
                    if (!achData) {
                        _logger.log(MOD_NAME, "  Achievement '" + achTitle + "' not found in achievement map");
                        continue; // Not in our map
                    }

                    var apId:int = int(achData.apId);
                    if (apId < 2000 || apId > 2636) {
                        _logger.log(MOD_NAME, "  Achievement '" + achTitle + "' has invalid apId=" + apId + " (expected 2000-2636), skipping");
                        continue;
                    }

                    // Mark as reported and submit
                    _reportedAchievements[achTitle] = true;
                    _logger.log(MOD_NAME, "Pending: " + achTitle + " (achievement)  apId=" + apId);
                    _achievementUnlocker.unlockAchievement(achTitle, apId, _achievementData);
                }
            } catch (err:Error) {
                _logger.log(MOD_NAME, "detectAndReportAchievements error: " + err.message);
                return;
            }
        }

        /**
         * Load achievement map from embedded AchievementMap class.
         * This contains achievement name → AP ID, reward, required effort, and requirements.
         */
        private function loadAchievementMap():void {
            try {
                // Ensure _achievementData is initialized
                if (!_achievementData) {
                    _achievementData = {};
                }

                var jsonString:String = AchievementMap.getData();
                if (!jsonString || jsonString.length == 0) {
                    _logger.log(MOD_NAME, "Warning: achievement_map data is empty");
                    return;
                }

                var jsonData:Object = JSON.parse(jsonString);
                if (jsonData) {
                    // New format: { "achievements": {...}, "element_stages": {...} }
                    // Old format (flat): { achievementName: {...}, ... }
                    if (jsonData.achievements) {
                        _achievementData = jsonData.achievements;
                        _elementStages   = jsonData.element_stages || {};
                        var elemCount:int = 0;
                        for (var e:String in _elementStages) elemCount++;
                        _logger.log(MOD_NAME, "Loaded element_stages: " + elemCount + " elements");
                    } else {
                        _achievementData = jsonData;
                        _elementStages   = {};
                    }
                    var count:int = 0;
                    for (var k:String in _achievementData) count++;
                    _logger.log(MOD_NAME, "Loaded achievement map: " + count + " achievements");
                } else {
                    _logger.log(MOD_NAME, "Warning: JSON parsed but returned null/empty");
                }
            } catch (e:Error) {
                _logger.log(MOD_NAME, "Error loading achievement_map: " + e.message + " (will continue with empty map)");
                _achievementData = {};
            }
        }

        // -----------------------------------------------------------------------
        // Helpers

        /**
         * Build a set of AP location IDs for achievements that are currently in-logic.
         * Delegates to _computeInLogicAchievements() and converts names -> AP IDs.
         */
        private function _getInLogicAchApIds():Object {
            var result:Object = {};
            var names:Array = _computeInLogicAchievements();
            for (var i:int = 0; i < names.length; i++) {
                var achData:Object = _achievementData[names[i]];
                if (achData && achData.apId) {
                    result[int(achData.apId)] = true;
                }
            }
            return result;
        }

        private function itemName(apId:int):String {
            var skillName:String = _skillUnlocker.getSkillName(apId);
            if (skillName != null) return skillName + " Skill";
            var traitName:String = _traitUnlocker.getTraitName(apId);
            if (traitName != null) return traitName + " Battle Trait";
            var strId:String = AV.serverData.tokenMap[String(apId)];
            if (strId != null) return strId + " Field Token";
            if (apId >= 700 && apId <= 799) {
                var talName:String = AV.serverData.talismanNameMap[String(apId)];
                return talName != null ? talName : ("Talisman Fragment #" + apId);
            }
            if (apId >= 800 && apId <= 868) {
                var scName:String = AV.serverData.shadowCoreNameMap[String(apId)];
                return scName != null ? scName : ("Shadow Cores #" + apId);
            }
            return null; // let ConnectionManager handle the rest
        }
    }
}
