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
    import com.giab.games.gcfw.constants.IngameStatus;
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
    import ui.AchievementsInLogicBadge;

    import deathlink.DeathLinkHandler;

    import patch.ModeSelectorInterceptor;
    import patch.ProgressionBlocker;
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
    import patch.EarlyExitOutcome;
    import patch.FrostbornFreeBuildings;
    import patch.GemPouchSuppressor;
    import patch.HollowGemInjector;
    import patch.StartingGemSuppressor;
    import patch.LogicEnforcer;
    import patch.WavePrePatcher;
    import patch.RitualSpawnPatcher;
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
        private var _earlyExitOutcome:EarlyExitOutcome;
        private var _frostbornFreeBuildings:FrostbornFreeBuildings;
        private var _gemPouchSuppressor:GemPouchSuppressor;
        private var _hollowGemInjector:HollowGemInjector;
        private var _startingGemSuppressor:StartingGemSuppressor;
        private var _logicEnforcer:LogicEnforcer;
        private var _wavePrePatcher:WavePrePatcher;
        private var _ritualSpawnPatcher:RitualSpawnPatcher;
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

        // Items sent to AP during the current level session (via PrintJSON onItemSent).
        // Each entry is { name:String, apId:int }. Logged, used to inject AP-relevant
        // drop icons (e.g. shadow cores) onto the ending screen after a short post-level
        // countdown so late-arriving async packets are included, then cleared.
        private var _sessionDrops:Array = [];
        // TalismanFragment objects granted by AP during the current level session.
        // Captured from grantFragment(apId) return values so we can show one drop icon
        // per AP-granted fragment without duplicating monster-drop fragments (which
        // are tracked separately via GV.ingameCore.ocLootTalFrags).
        private var _sessionGrantedFragments:Array = [];
        private var _levelEndCountdown:int = -1; // frames remaining; -1 = inactive

        // Achievements-in-logic badge — small text label that floats above
        // the in-level vanilla btnPnlAchis. Attached lazily to mcIngameFrame
        // per ingame entry, position synced every frame.
        private var _achLogicBadge:AchievementsInLogicBadge;
        private var _achLogicBadgeFrame:* = null; // mcIngameFrame we attached to

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
                _ritualSpawnPatcher = new RitualSpawnPatcher(_logger, MOD_NAME);
                _firstPlayBypass    = new FirstPlayBypass(_logger, MOD_NAME);
                _earlyExitOutcome = new EarlyExitOutcome(_logger, MOD_NAME);
                _frostbornFreeBuildings = new FrostbornFreeBuildings(_logger, MOD_NAME);
                _gemPouchSuppressor = new GemPouchSuppressor(_logger, MOD_NAME);
                _hollowGemInjector = new HollowGemInjector(_logger, MOD_NAME);
                _startingGemSuppressor = new StartingGemSuppressor(_logger, MOD_NAME);

                // In-game tracker (stage light tinting + logic evaluation)
                _fieldLogicEvaluator        = new FieldLogicEvaluator(_logger, MOD_NAME);
                _logicEvaluator             = new LogicEvaluator(_logger, MOD_NAME);
                _achievementLogicEvaluator  = new AchievementLogicEvaluator(_logger, MOD_NAME);

                // WizStashes uses the field evaluator to decide whether to
                // keep the stash locked / show the hover tooltip.
                WizStashes.setEvaluator(_fieldLogicEvaluator);

                _debugOptions  = new ScrDebugOptions(this);
                _slotSettings  = new ScrSlotSettings();

                // Connection manager — AP protocol + WebSocket
                _connectionManager = new ConnectionManager(_logger, MOD_NAME, _systemToast);
                _connectionManager.setReceivedToast(_receivedToast);
                _connectionManager.setMessageLog(_messageLog);
                _connectionManager.onConnected             = onApConnected;
                _connectionManager.onFullSync              = syncWithAP;
                _connectionManager.onItemReceived          = grantItem;
                _connectionManager.onItemSent              = function(itemName:String, apId:int, recipientName:String, isForMe:Boolean):void {
                    _sessionDrops.push({ name: itemName, apId: apId, recipient: recipientName, isForMe: isForMe });
                    _logger.log(MOD_NAME, "sessionDrop+ [" + (_sessionDrops.length - 1) + "] "
                        + itemName + " (apId=" + apId + ") → " + recipientName + (isForMe ? " (self)" : ""));
                };
                _connectionManager.onError                 = onConnectionError;
                _connectionManager.onPanelReset            = onConnectionPanelReset;
                _connectionManager.onUnexpectedDisconnect  = onApUnexpectedlyDisconnected;
                _connectionManager.load();

                // Initialize achievement unlocker
                _achievementUnlocker = new AchievementUnlocker(_logger, MOD_NAME, _connectionManager, _receivedToast);
                _achievementUnlocker.loadData();
                _achievementLogicEvaluator.loadData();

                // ProgressionBlocker: intercepts SAVE_SAVE and reverts game auto-unlocks.
                _progressionBlocker = new ProgressionBlocker(_logger, MOD_NAME);

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

                _progressionBlocker.enable(_bezel);

                addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
                // EXIT_FRAME fires after every ENTER_FRAME handler on the
                // stage has completed, so vanilla's redrawHighBuildings (which
                // can run inside Main.doEnterFrame on level-load frames) is
                // guaranteed to be done before our handler. Used to re-apply
                // the locked-stash overdraw without a single-frame flash of
                // the unmodified stash sprite.
                addEventListener(Event.EXIT_FRAME, onExitFrame, false, 0, true);
                patchWizStashModes();
                _logger.log(MOD_NAME, "ArchipelagoMod loaded!");
            } catch (err:Error) {
                _logger.log(MOD_NAME, "BIND ERROR: " + err.message + "\n" + err.getStackTrace());
            }
        }

        public function unload():void {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            removeEventListener(Event.EXIT_FRAME, onExitFrame);
            if (_bezel != null) _bezel.removeEventListener(EventTypes.SAVE_SAVE, onSaveSave);
            if (_connectionManager != null) {
                _connectionManager.unload();
                _connectionManager = null;
            }
            if (_progressionBlocker != null) {
                _progressionBlocker.disable();
                _progressionBlocker = null;
            }
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

        /**
         * EXIT_FRAME runs after every ENTER_FRAME handler on the display list
         * has completed (and after frame scripts), but BEFORE Flash renders
         * the frame to screen. Vanilla's redrawHighBuildings can fire inside
         * Main.doEnterFrame on level-load frames; if our ENTER_FRAME handler
         * happened to dispatch before Main's, our locked-stash overdraw would
         * be wiped by the subsequent vanilla redraw and the player would see
         * one frame of the unmodified stash. Re-applying the overdraw here
         * closes that race — we are guaranteed to run after every painter
         * but before the frame renders.
         */
        private function onExitFrame(e:Event):void
        {
            try {
                WizStashes.tickEnforceStashLock(_logger, MOD_NAME);
            } catch (err:Error) {
                _logger.log(MOD_NAME, "onExitFrame ERROR: " + err.message);
            }
        }

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

            // Per-stage stash gating: shield-spike locked stashes and overlay
            // a padlock above each one until the unlock item arrives.
            WizStashes.tickEnforceStashLock(_logger, MOD_NAME);

            // Append "Locked — requires Wizard Stash {strId} Key" to the
            // hover tooltip when the player is hovering a locked stash.
            WizStashes.tickStashLockTooltip(_logger, MOD_NAME);

            // Suppress all dropicons mid-battle. When drops are cleared, start a
            // short countdown so late-arriving async PrintJSON packets are included.
            if (_progressionBlocker != null && _progressionBlocker.tickDropIcons()) {
                _levelEndCountdown = 120;
            }

            // After the countdown expires, log session drops and inject AP drop icons.
            if (_levelEndCountdown > 0) {
                _levelEndCountdown--;
                if (_levelEndCountdown == 0) {
                    _logger.log(MOD_NAME, "=== AP items sent this level: " + _sessionDrops.length + " ===");
                    for (var sd:int = 0; sd < _sessionDrops.length; sd++) {
                        var sdEntry:Object = _sessionDrops[sd];
                        _logger.log(MOD_NAME, "  [" + sd + "] " + sdEntry.name + " (apId=" + sdEntry.apId + ")");
                    }
                    _logger.log(MOD_NAME, "=== end ===");
                    _injectApDropIcons();
                    _sessionDrops = [];
                    _sessionGrantedFragments = [];
                    _levelEndCountdown = -1;
                }
            }

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
                _logger.log(MOD_NAME, "Screen transition: " + _lastScreen + " → " + screen);

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
                    _ritualSpawnPatcher.resetForNewStage();
                    _startingGemSuppressor.applyIfReady();
                }

                // Recompute the available-achievements list when entering battle so
                // the panel reflects the player's current loadout for the new field.
                // Also refresh the vanilla achievement panel's logic dots so they're
                // up-to-date the next time the player opens the achievements menu —
                // not stale from before this battle started.
                if (screen == ScreenId.INGAME) {
                    _refreshAchievementPanel();
                }
                // Reset first-play gem patch when leaving ingame so it re-runs on
                // the next ingame entry for the same stage (after initializer resets
                // availableGemTypes to []).
                if (_lastScreen == ScreenId.INGAME) {
                    _firstPlayBypass.resetIngame();
                    _frostbornFreeBuildings.resetIngame();
                    _gemPouchSuppressor.resetIngame();
                    _hollowGemInjector.resetIngame();
                    _startingGemSuppressor.resetForNewStage();
                    _logger.log(MOD_NAME, "LEFT INGAME → transitioning to screen=" + screen);
                    _logger.log(MOD_NAME, "=== AP items received this level: " + _sessionDrops.length + " ===");
                    // sd / sdEntry are already function-scope-declared in the
                    // earlier _sessionDrops loop above; reuse them here.
                    for (sd = 0; sd < _sessionDrops.length; sd++) {
                        sdEntry = _sessionDrops[sd];
                        _logger.log(MOD_NAME, "  [" + sd + "] " + sdEntry.name + " (apId=" + sdEntry.apId + ")");
                    }
                    _logger.log(MOD_NAME, "=== end of AP items list ===");
                    _sessionDrops = [];
                    _sessionGrantedFragments = [];
                    if (_progressionBlocker != null) _progressionBlocker.resetApIconsState();
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
            // GemPouchSuppressor MUST run after FirstPlayBypass — the latter
            // adds skill-unlock gems back, the former wipes them when the
            // current stage's Gempouch is missing.
            if (screen == ScreenId.INGAME) {
                _firstPlayBypass.onIngameFrame();
                _gemPouchSuppressor.onIngameFrame();
                _hollowGemInjector.onIngameFrame();
                _frostbornFreeBuildings.onIngameFrame();
                _earlyExitOutcome.tryAttach();
                _wavePrePatcher.applyIfReady();
                _ritualSpawnPatcher.applyIfReady();
                _updateAchievementsBadge();
            } else if (_achLogicBadgeFrame != null) {
                _detachAchievementsBadge();
            }


            // Apply any sync that was deferred because GV.ppd was null at connect time.
            if (_pendingSyncItems != null && GV.ppd != null) {
                syncWithAP(_pendingSyncItems);
            }

            // Reconcile stage lock state whenever a new ppd is detected
            // (new game or slot change).  syncWithAP only runs once at
            // connect time; if a new ppd is created after that the game
            // pre-unlocks W1 (PlayerProgressData.as:155) and we need to
            // lock it again if W1 isn't the chosen starting stage.
            if (_connectionManager.isConnected
                    && GV.ppd != null
                    && GV.stageCollection != null
                    && GV.ppd !== _lastPpd) {
                _lastPpd = GV.ppd;
                var stageChanges:int = _syncStageLockState();
                if (stageChanges > 0) {
                    _logger.log(MOD_NAME, "stage lock state reconciled on ppd change: "
                        + stageChanges + " changes");
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

            // Refresh achievement-in-logic list before the buttons read it.
            // _recompute is dirty-flag guarded, so this is cheap once stable.
            if (_achievementLogicEvaluator != null) {
                _achievementLogicEvaluator.getInLogicAchApIds();
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

        /**
         * Per-frame upkeep for the in-level achievements-in-logic badge.
         *   - Attach lazily to the current `mcIngameFrame` (vanilla rebuilds
         *     it whenever a new level loads, so re-attach if the frame
         *     reference changed).
         *   - Sync the count from sessionData.achievementNamesInLogic.
         *   - Position above `btnPnlAchis` (right-aligned to its right edge,
         *     a few px above the top edge).
         *   - Visibility tracks btnPnlAchis.
         */
        private function _updateAchievementsBadge():void {
            if (GV.ingameCore == null || GV.ingameCore.cnt == null) return;
            var frame:* = GV.ingameCore.cnt.mcIngameFrame;
            if (frame == null) return;
            var btn:* = frame.btnPnlAchis;
            if (btn == null) return;

            if (_achLogicBadge == null) {
                _achLogicBadge = new AchievementsInLogicBadge();
            }
            if (_achLogicBadgeFrame != frame) {
                if (_achLogicBadge.parent != null)
                    _achLogicBadge.parent.removeChild(_achLogicBadge);
                frame.addChild(_achLogicBadge);
                _achLogicBadgeFrame = frame;
            }

            var achs:Array = AV.sessionData.achievementNamesInLogic;
            _achLogicBadge.update(achs != null ? achs.length : 0);
            // Anchor the badge's top-right corner just outside the button's
            // top-right corner — like a notification dot on an app icon.
            _achLogicBadge.x = btn.x + btn.width - _achLogicBadge.badgeWidth + 4;
            _achLogicBadge.y = btn.y - _achLogicBadge.badgeHeight + 4;
            _achLogicBadge.visible = btn.visible;
        }

        /** Detach the badge when leaving the in-game screen. */
        private function _detachAchievementsBadge():void {
            if (_achLogicBadge != null && _achLogicBadge.parent != null) {
                _achLogicBadge.parent.removeChild(_achLogicBadge);
            }
            _achLogicBadgeFrame = null;
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

            // Populate slot_data maps from the Connected packet (loadServerDataFromJSON
            // resets them to {} and the embedded itemdata.json doesn't fill these).
            AV.serverData.tokenMap           = _connectionManager.tokenMap;
            AV.serverData.shadowCoreMap      = _connectionManager.shadowCoreMap;
            AV.serverData.shadowCoreNameMap  = _connectionManager.shadowCoreNameMap;
            AV.serverData.talismanNameMap    = _connectionManager.talismanNameMap;
            AV.serverData.wizStashTalData    = _connectionManager.wizStashTalData;

            // Reset + configure the in-game tracker from slot_data.  Must happen
            // BEFORE syncWithAP (which will populate session data via onItem).
            AV.sessionData.reset();
            if (p.slot_data != null) {
                AV.sessionData.configure(
                    AV.serverData.tokenMap,
                    p.slot_data.skill_categories
                );
                _fieldLogicEvaluator.configure(
                    AV.serverData.stageSkills,
                    AV.serverData.stageRequirements,
                    AV.serverData.matchingTalismans,
                    AV.serverData.freeStages
                );
                _fieldLogicEvaluator.setStageElements(
                    p.slot_data.stage_elements,
                    p.slot_data.stage_monsters
                );
                _achievementLogicEvaluator.configure(_fieldLogicEvaluator, _logicEvaluator);
                // Diagnostic: AchievementUnlocker uses this to toast on
                // achievement unlocks that AP didn't consider in logic, so
                // the player can spot mis-calibrated requirements.
                _achievementUnlocker.setAchievementLogicEvaluator(_achievementLogicEvaluator);
                _logger.log(MOD_NAME, "  tracker configured — logic_rules_version="
                    + p.slot_data.logic_rules_version);
                _logicEnforcer.configure(_fieldLogicEvaluator, AV.serverData.serverOptions.enforce_logic);
                _ritualSpawnPatcher.configure(_fieldLogicEvaluator);
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

        /**
         * Inject AP-relevant drop icons onto the ending screen, ordered by
         * importance so the most progression-critical items appear leftmost
         * in the icon row (and animate in first):
         *
         *   1.  Field tokens
         *   1b. Map tiles  (direct + per-tile/per-tier field token expansion)
         *   2.  Skill tomes
         *   3.  Battle trait scrolls
         *   4.  XP tomes
         *   4b. Gempouches
         *   5.  Shadow cores  (one combined icon: AP-granted + monster drops)
         *   5b. Skillpoint bundles  (cyan-glow icon, summed per run)
         *   6.  Talisman fragments  (monster drops + AP-granted)
         *   7.  Endurance wave stones  (vanilla loot, endurance only)
         *   8.  Achievements
         *   9.  Remote items  (anything sent to another player — AP icon)
         *
         * Implementation: each priority gets its own pass over _sessionDrops
         * (or its dedicated source like _sessionGrantedFragments). A bit
         * redundant compared to one dispatch loop, but trivial to reorder
         * and easy to read.
         */
        private function _injectApDropIcons():void {
            if (_progressionBlocker == null || _connectionManager == null) return;
            var scMap:Object    = _connectionManager.shadowCoreMap;
            var tokenMap:Object = _connectionManager.tokenMap;
            if (scMap == null) return;

            var i:int;
            var entry:Object;
            var apId:int;

            // 1. Field tokens (self-bound only)
            for (i = 0; i < _sessionDrops.length; i++) {
                entry = _sessionDrops[i];
                if (entry.isForMe !== true) continue;
                apId = int(entry.apId);
                if (apId < 1 || apId > 122) continue;
                var rawStrId:* = (tokenMap != null) ? tokenMap[String(apId)] : null;
                if (rawStrId == null) continue;
                var stageId:int = GV.getFieldId(String(rawStrId));
                if (stageId >= 0) {
                    _progressionBlocker.addFieldTokenDropIcon(stageId);
                }
            }

            // 1b. Map tiles. Three apId ranges contribute:
            //   600-625    direct map tile items (apIdToGameId resolves the gameId)
            //   1562-1587  per-tile field tokens (one tile each, via gemPouchPlayOrder)
            //   1588-1600  per-tier field tokens (one icon per tile in the tier)
            // Deduped: receiving the same tile twice in a run produces one icon.
            var seenTileGameIds:Object = {};
            var tierMap:Object = (AV.serverData != null && AV.serverData.serverOptions != null)
                ? AV.serverData.serverOptions.stageTierByStrId : null;
            for (i = 0; i < _sessionDrops.length; i++) {
                entry = _sessionDrops[i];
                if (entry.isForMe !== true) continue;
                apId = int(entry.apId);

                if (apId >= 600 && apId <= 625) {
                    if (AV.serverData != null && AV.serverData.apIdToGameId != null) {
                        var directGid:int = int(AV.serverData.apIdToGameId[apId]);
                        _emitMapTileIconOnce(directGid, seenTileGameIds);
                    }
                } else if (apId >= 1562 && apId <= 1587) {
                    var tilePrefix:String = _prefixForTileApId(apId, 1562);
                    if (tilePrefix != null && tilePrefix.length > 0) {
                        _emitMapTileIconOnce(_tileGameIdForPrefix(tilePrefix), seenTileGameIds);
                    }
                } else if (apId >= 1588 && apId <= 1600 && tierMap != null) {
                    var tier:int = apId - 1588;
                    for (var tsid:String in tierMap) {
                        if (int(tierMap[tsid]) != tier) continue;
                        if (tsid.length == 0) continue;
                        _emitMapTileIconOnce(_tileGameIdForPrefix(tsid.charAt(0)), seenTileGameIds);
                    }
                }
            }

            // 2. Skill tomes
            for (i = 0; i < _sessionDrops.length; i++) {
                entry = _sessionDrops[i];
                if (entry.isForMe !== true) continue;
                apId = int(entry.apId);
                if (apId < 700 || apId > 723) continue;
                _progressionBlocker.addSkillTomeDropIcon(apId - 700);
            }

            // 3. Battle trait scrolls
            for (i = 0; i < _sessionDrops.length; i++) {
                entry = _sessionDrops[i];
                if (entry.isForMe !== true) continue;
                apId = int(entry.apId);
                if (apId < 800 || apId > 814) continue;
                _progressionBlocker.addBattleTraitScrollDropIcon(apId - 800);
            }

            // 4. XP tomes (Tattered / Worn / Ancient) — pass the actual level
            // count from LevelUnlocker so the tooltip can show "Grants N levels".
            for (i = 0; i < _sessionDrops.length; i++) {
                entry = _sessionDrops[i];
                if (entry.isForMe !== true) continue;
                apId = int(entry.apId);
                if (apId < 1100 || apId > 1199) continue;
                _progressionBlocker.addXpTomeDropIcon(apId, _levelUnlocker.levelsForApId(apId));
            }

            // 4b. Gempouches (distinct 626-651, progressive 652).
            for (i = 0; i < _sessionDrops.length; i++) {
                entry = _sessionDrops[i];
                if (entry.isForMe !== true) continue;
                apId = int(entry.apId);
                if (apId < 626 || apId > 652) continue;
                _progressionBlocker.addGempouchDropIcon(apId);
            }

            // 5. Shadow cores: one combined icon (AP cores routed to us + monster drops).
            // Cores routed to other players are not summed here — they get their own
            // AP icon in the remote-items pass below.
            var apShadowCores:int = 0;
            for (i = 0; i < _sessionDrops.length; i++) {
                entry = _sessionDrops[i];
                if (entry.isForMe !== true) continue;
                var key:String = String(entry.apId);
                if (key in scMap) apShadowCores += int(scMap[key]);
            }
            var monsterShadowCores:int = 0;
            if (GV.ingameCore != null && GV.ingameCore.ocLootShadowCoreNum != null) {
                monsterShadowCores = int(GV.ingameCore.ocLootShadowCoreNum.g());
            }
            var totalShadowCores:int = apShadowCores + monsterShadowCores;
            if (totalShadowCores > 0) {
                _progressionBlocker.addShadowCoreDropIcon(totalShadowCores);
            }

            // 5b. Skillpoint bundles (apId 1700-1709): sum across all bundles
            // received this run into one cyan-glow icon. Each bundle grants
            // (apId - 1699) skill points, i.e. 1700→1 .. 1709→10.
            var totalSkillPoints:int = 0;
            for (i = 0; i < _sessionDrops.length; i++) {
                entry = _sessionDrops[i];
                if (entry.isForMe !== true) continue;
                apId = int(entry.apId);
                if (apId < 1700 || apId > 1709) continue;
                totalSkillPoints += (apId - 1699);
            }
            if (totalSkillPoints > 0) {
                _progressionBlocker.addSkillPointDropIcon(totalSkillPoints);
            }

            // 6. Talisman fragments: one icon per fragment we ended up with.
            // Monster drops + AP-granted fragments are different OBJECTS so iterating
            // both sources without dedup never produces a duplicate icon.
            if (GV.ppd != null && GV.ppd.talismanInventory != null) {
                var inv:Array = GV.ppd.talismanInventory;

                if (GV.ingameCore != null && GV.ingameCore.ocLootTalFrags != null) {
                    var ocLoot:Array = GV.ingameCore.ocLootTalFrags;
                    for (i = 0; i < ocLoot.length; i++) {
                        var monsterFrag:* = ocLoot[i];
                        if (monsterFrag != null && inv.indexOf(monsterFrag) != -1) {
                            _progressionBlocker.addTalismanFragmentDropIcon(monsterFrag);
                        }
                    }
                }

                for (i = 0; i < _sessionGrantedFragments.length; i++) {
                    var apFrag:* = _sessionGrantedFragments[i];
                    if (apFrag != null && inv.indexOf(apFrag) != -1) {
                        _progressionBlocker.addTalismanFragmentDropIcon(apFrag);
                    }
                }
            }

            // 7. Endurance wave stones (vanilla loot, captured by tickDropIcons)
            var ews:int = _progressionBlocker.pendingEnduranceWaveStones;
            if (ews > 0) {
                _progressionBlocker.addEnduranceWaveStoneDropIcon(ews);
            }

            // 8. Achievements
            for (i = 0; i < _sessionDrops.length; i++) {
                entry = _sessionDrops[i];
                if (entry.isForMe !== true) continue;
                apId = int(entry.apId);
                if (apId < 2000 || apId > 2636) continue;
                var achGameId:int = _achievementUnlocker.findGameIdByApId(apId);
                if (achGameId >= 0) {
                    _progressionBlocker.addAchievementDropIcon(achGameId);
                }
            }

            // 9. Remote items: anything routed to another player gets a generic AP
            // icon, regardless of whether the apId is in our game or not.
            for (i = 0; i < _sessionDrops.length; i++) {
                entry = _sessionDrops[i];
                if (entry.isForMe === true) continue;
                _progressionBlocker.addRemoteItemDropIcon(
                    String(entry.name),
                    String(entry.recipient));
            }

            // Kick off the vanilla one-by-one reveal animation. No-op if stats
            // rolling is still in progress (the natural transition will pick it
            // up once stats finish, since dropIcons.length > 0 by then).
            _progressionBlocker.playDropIconsAnimation();
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
                    _levelUnlocker.grantXpFromApId(apId, itemName(apId));
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
                    var grantedFrag:* = _talismanUnlocker.grantFragment(apId);
                    if (grantedFrag != null) _sessionGrantedFragments.push(grantedFrag);
                    _saveManager.saveSlotData();
                    return;
                }
                if ((apId >= 1000 && apId <= 1016) || (apId >= 1300 && apId <= 1351)) {
                    _logger.log(MOD_NAME, "  → Shadow core apId: " + apId);
                    _shadowCoreUnlocker.grantShadowCores(apId);
                    _saveManager.saveSlotData();
                    return;
                }
                if (apId >= 1400 && apId <= 1521) {
                    // Per-stage Wizard Stash key — gates the per-level stash AP check.
                    var stashLocId:int = apId - 1400 + 1;
                    var stashStrId:String = null;
                    var stageLocIdMap:Object = ConnectionManager.stageLocIds;
                    for (var sid:String in stageLocIdMap) {
                        if (int(stageLocIdMap[sid]) == stashLocId) {
                            stashStrId = sid;
                            break;
                        }
                    }
                    if (stashStrId != null) {
                        AV.sessionData.markStashUnlocked(stashStrId);
                        _receivedToast.addItem("Received Wizard Stash " + stashStrId + " Key", 0x55AAFF);
                        _logger.log(MOD_NAME, "  → Wizard stash key for " + stashStrId);
                    } else {
                        _logger.log(MOD_NAME, "  grantItem: stash key apId=" + apId + " — no matching stage");
                    }
                    return;
                }
                if (apId >= 1522 && apId <= 1547) {
                    // Per-tile stash key (one per stage prefix). Unlocks every
                    // stash whose stage starts with the matching prefix.
                    _grantStashKeyByPrefix(apId);
                    return;
                }
                if (apId >= 1548 && apId <= 1560) {
                    // Per-tier stash key. Unlocks every stash whose stage is
                    // in the matching tier.
                    _grantStashKeyByTier(apId - 1548);
                    return;
                }
                if (apId == 1561) {
                    // Master stash key. Unlocks every stash.
                    _grantMasterStashKey();
                    return;
                }
                if (apId >= 1562 && apId <= 1587) {
                    // Per-tile field token. Unlocks every stage whose str_id
                    // starts with the matching prefix.
                    _grantFieldTokenByPrefix(apId);
                    return;
                }
                if (apId >= 1588 && apId <= 1600) {
                    // Per-tier field token. Unlocks every stage in the tier.
                    _grantFieldTokenByTier(apId - 1588);
                    return;
                }
                if (apId >= 1700 && apId <= 1709) {
                    // Skillpoint Bundle: 1700→1 SP, 1709→10 SP.
                    var spAmount:int = apId - 1699;
                    _achievementUnlocker.awardSkillPoints(spAmount);
                    _receivedToast.addItem("Received Skillpoint Bundle (+" + spAmount + ")", 0xFFCC44);
                    _logger.log(MOD_NAME, "  → Skillpoint bundle: +" + spAmount + " SP");
                    return;
                }
                if (apId >= 2000 && apId <= 2636) {
                    // Achievement IDs are now location-only (no items live in this range).
                    // If one ever arrives, it's a stale seed — log and ignore.
                    _logger.log(MOD_NAME, "  grantItem: stale achievement-as-item apId=" + apId
                        + " (achievement items removed; ignoring)");
                    return;
                }
                _logger.log(MOD_NAME, "  grantItem: no handler for AP ID " + apId);
            } catch (err:Error) {
                _logger.log(MOD_NAME, "ERROR in grantItem(" + apId + "): " + err.message);
                _logger.log(MOD_NAME, "  Stack: " + err.getStackTrace());
            }
        }

        /**
         * Reconcile every stage's lock state against the current AP
         * collection (free stages + collected field tokens).  Vanilla PPD
         * construction always pre-unlocks W1 (PlayerProgressData.as:155),
         * so without this we'd leave W1 unlocked even when the player
         * chose a different starting stage.  Called from syncWithAP and
         * from the ppd-change handler — both points where the game might
         * have just pre-unlocked W1 on us.
         *
         * Logic per stage:
         *   - in freeStages OR token collected → unlock (xp=0) if locked
         *   - otherwise                        → lock (xp=-1) if currently
         *                                         unlocked-but-not-completed
         *   - already completed (xp>0)        → leave alone
         */
        // -----------------------------------------------------------------------
        // Coarse-granularity item handlers
        //
        // ID layout (mirrors apworld gating.py):
        //   1522-1547 stash tile keys (one per prefix in gemPouchPlayOrder)
        //   1548-1560 stash tier keys (one per tier 0..12)
        //   1561      stash master key
        //   1562-1587 field tile tokens (one per prefix)
        //   1588-1600 field tier tokens (one per tier 0..12)
        // For tile-keyed items, prefix = playOrder[apId - base]. For tier-keyed
        // items, tier = apId - base. Master keys cover everything.

        // Map a tile prefix letter ("A".."Z") to the integer tile gameId
        // (0..25) used by GV.selectorCore.mapTiles. Tile letters wrap in
        // reverse order per WorldMapBuilder: gameId 0 = "Z", gameId 25 = "A",
        // so gameId = 25 - (letter - 'A').
        private static function _tileGameIdForPrefix(prefix:String):int {
            if (prefix == null || prefix.length == 0) return -1;
            var c:int = prefix.charCodeAt(0);
            if (c < 65 || c > 90) return -1; // not A-Z
            return 25 - (c - 65);
        }

        // Push a MapTileDropIcon for the given gameId, skipping duplicates
        // already added for this drain pass. seen is a transient {gid:true}
        // map maintained by the caller.
        private function _emitMapTileIconOnce(tileGameId:int, seen:Object):void {
            if (tileGameId < 0 || tileGameId >= 26) return;
            var key:String = String(tileGameId);
            if (seen[key] === true) return;
            seen[key] = true;
            _progressionBlocker.addMapTileDropIcon(tileGameId);
        }

        private function _prefixForTileApId(apId:int, base:int):String {
            var order:Array = AV.serverData != null && AV.serverData.serverOptions != null
                ? AV.serverData.serverOptions.gemPouchPlayOrder as Array
                : null;
            if (order == null || order.length == 0) return null;
            var idx:int = apId - base;
            if (idx < 0 || idx >= order.length) return null;
            return String(order[idx]);
        }

        private function _grantStashKeyByPrefix(apId:int):void {
            var prefix:String = _prefixForTileApId(apId, 1522);
            if (prefix == null) {
                _logger.log(MOD_NAME, "  grantItem: tile stash key apId=" + apId + " — no prefix mapping");
                return;
            }
            var count:int = 0;
            var byStrId:Object = AV.serverData.stagesByStrId;
            for (var sid:String in byStrId) {
                if (sid.charAt(0) == prefix) {
                    AV.sessionData.markStashUnlocked(sid);
                    count++;
                }
            }
            _receivedToast.addItem("Received Wizard Stash Tile " + prefix + " Key (" + count + " stashes)", 0x55AAFF);
            _logger.log(MOD_NAME, "  → Tile stash key " + prefix + " unlocked " + count + " stashes");
        }

        private function _grantStashKeyByTier(tier:int):void {
            var tierMap:Object = AV.serverData != null && AV.serverData.serverOptions != null
                ? AV.serverData.serverOptions.stageTierByStrId
                : null;
            if (tierMap == null) {
                _logger.log(MOD_NAME, "  grantItem: tier stash key tier=" + tier + " — no stage->tier map");
                return;
            }
            var count:int = 0;
            for (var sid:String in tierMap) {
                if (int(tierMap[sid]) == tier) {
                    AV.sessionData.markStashUnlocked(sid);
                    count++;
                }
            }
            _receivedToast.addItem("Received Wizard Stash Tier " + tier + " Key (" + count + " stashes)", 0x55AAFF);
            _logger.log(MOD_NAME, "  → Tier " + tier + " stash key unlocked " + count + " stashes");
        }

        private function _grantMasterStashKey():void {
            var byStrId:Object = AV.serverData.stagesByStrId;
            var count:int = 0;
            for (var sid:String in byStrId) {
                AV.sessionData.markStashUnlocked(sid);
                count++;
            }
            _receivedToast.addItem("Received Wizard Stash Master Key (" + count + " stashes)", 0x55AAFF);
            _logger.log(MOD_NAME, "  → Master stash key unlocked " + count + " stashes");
        }

        private function _grantFieldTokenByPrefix(apId:int):void {
            var prefix:String = _prefixForTileApId(apId, 1562);
            if (prefix == null) {
                _logger.log(MOD_NAME, "  grantItem: tile field token apId=" + apId + " — no prefix mapping");
                return;
            }
            var count:int = 0;
            var byStrId:Object = AV.serverData.stagesByStrId;
            for (var sid:String in byStrId) {
                if (sid.charAt(0) == prefix) {
                    _stageUnlocker.unlockStage(sid);
                    count++;
                }
            }
            _receivedToast.addItem("Received " + prefix + " Tile Field Token (" + count + " stages)", 0xFFDD55);
            _logger.log(MOD_NAME, "  → Tile field token " + prefix + " unlocked " + count + " stages");
        }

        private function _grantFieldTokenByTier(tier:int):void {
            var tierMap:Object = AV.serverData != null && AV.serverData.serverOptions != null
                ? AV.serverData.serverOptions.stageTierByStrId
                : null;
            if (tierMap == null) {
                _logger.log(MOD_NAME, "  grantItem: tier field token tier=" + tier + " — no stage->tier map");
                return;
            }
            var count:int = 0;
            for (var sid:String in tierMap) {
                if (int(tierMap[sid]) == tier) {
                    _stageUnlocker.unlockStage(sid);
                    count++;
                }
            }
            _receivedToast.addItem("Received Tier " + tier + " Field Token (" + count + " stages)", 0xFFDD55);
            _logger.log(MOD_NAME, "  → Tier " + tier + " field token unlocked " + count + " stages");
        }

        /** Re-apply stash unlocks from received items. Called from
         *  syncWithAP after sessionData.reset() so the unlocked state is
         *  rebuilt from the full item list at every sync. Handles all four
         *  stash_key_granularity modes:
         *    per_stage  → AP id 1400-1521 (one per stage's loc id)
         *    per_tile   → AP id 1522-1547 (one per prefix in playOrder)
         *    per_tier   → AP id 1548-1560 (one per tier 0..12)
         *    global     → AP id 1561 (master key)
         */
        private function _syncStashLockState():int {
            if (AV.serverData == null) return 0;
            var changes:int = 0;
            var byStrId:Object = AV.serverData.stagesByStrId;
            var opts:* = AV.serverData.serverOptions;

            _logger.log(MOD_NAME, "_syncStashLockState: stashKeyGranularity="
                + (opts != null ? String(opts.stashKeyGranularity) : "?"));

            // Per-stage: walk the stageLocIds map, mark each stash whose
            // matching key item id is held.
            var stageLocIdMap:Object = ConnectionManager.stageLocIds;
            if (stageLocIdMap != null) {
                for (var psid:String in stageLocIdMap) {
                    var keyApId:int = 1400 + int(stageLocIdMap[psid]) - 1;
                    if (AV.sessionData.hasItem(keyApId)) {
                        _logger.log(MOD_NAME, "_syncStashLockState: per-stage match "
                            + psid + " (apId=" + keyApId + ")");
                        if (!AV.sessionData.isStashUnlocked(psid)) {
                            AV.sessionData.markStashUnlocked(psid);
                            changes++;
                        }
                    }
                }
            }
            // Per-tile: AP id 1522 + prefix index
            var order:Array = opts != null ? opts.gemPouchPlayOrder as Array : null;
            if (order != null) {
                for (var pi:int = 0; pi < order.length; pi++) {
                    if (!AV.sessionData.hasItem(1522 + pi)) continue;
                    var prefix:String = String(order[pi]);
                    for (var sid:String in byStrId) {
                        if (sid.charAt(0) == prefix && !AV.sessionData.isStashUnlocked(sid)) {
                            AV.sessionData.markStashUnlocked(sid);
                            changes++;
                        }
                    }
                }
            }
            // Per-tier: AP id 1548 + tier
            var tierMap:Object = opts != null ? opts.stageTierByStrId : null;
            if (tierMap != null) {
                for (var tt:int = 0; tt <= 12; tt++) {
                    if (!AV.sessionData.hasItem(1548 + tt)) continue;
                    for (var tsid:String in tierMap) {
                        if (int(tierMap[tsid]) == tt && !AV.sessionData.isStashUnlocked(tsid)) {
                            AV.sessionData.markStashUnlocked(tsid);
                            changes++;
                        }
                    }
                }
            }
            // Global master key
            if (AV.sessionData.hasItem(1561)) {
                for (var msid:String in byStrId) {
                    if (!AV.sessionData.isStashUnlocked(msid)) {
                        AV.sessionData.markStashUnlocked(msid);
                        changes++;
                    }
                }
            }
            return changes;
        }

        private function _syncStageLockState():int {
            if (GV.ppd == null || GV.stageCollection == null || AV.serverData == null) return 0;

            var freeSet:Object = {};
            var freeArr:Array = AV.serverData.freeStages;
            if (freeArr != null) {
                for each (var fsId:String in freeArr) freeSet[fsId] = true;
            }
            var hasToken:Object = {};
            var tokenMap:Object = AV.serverData.tokenMap;
            if (tokenMap != null) {
                for (var apIdStr:String in tokenMap) {
                    if (AV.sessionData.hasItem(int(apIdStr))) hasToken[tokenMap[apIdStr]] = true;
                }
            }
            // Coarse field-token coverage: per-tile (1562 + prefix index)
            // covers all stages with that prefix; per-tier (1588 + tier)
            // covers all stages in the tier.
            var opts:* = AV.serverData.serverOptions;
            var order:Array = opts != null ? opts.gemPouchPlayOrder as Array : null;
            if (order != null) {
                for (var pi:int = 0; pi < order.length; pi++) {
                    if (AV.sessionData.hasItem(1562 + pi)) {
                        var prefix:String = String(order[pi]);
                        for (var psid:String in AV.serverData.stagesByStrId) {
                            if (psid.charAt(0) == prefix) hasToken[psid] = true;
                        }
                    }
                }
            }
            var tierMap:Object = opts != null ? opts.stageTierByStrId : null;
            if (tierMap != null) {
                for (var tt:int = 0; tt <= 12; tt++) {
                    if (AV.sessionData.hasItem(1588 + tt)) {
                        for (var tsid:String in tierMap) {
                            if (int(tierMap[tsid]) == tt) hasToken[tsid] = true;
                        }
                    }
                }
            }

            var changes:int = 0;
            var metas:Array = GV.stageCollection.stageMetas;
            for (var i:int = 0; i < metas.length; i++) {
                var meta:* = metas[i];
                if (meta == null) continue;
                var sid:String = meta.strId;
                var shouldUnlock:Boolean = (freeSet[sid] == true) || (hasToken[sid] == true);
                var xp:int = GV.ppd.stageHighestXpsJourney[meta.id].g();
                if (shouldUnlock && xp < 0) {
                    _stageUnlocker.unlockStage(sid);
                    changes++;
                } else if (!shouldUnlock && xp == 0) {
                    _stageUnlocker.lockStage(sid);
                    changes++;
                }
            }
            return changes;
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
            var apXpTotal:int   = 0;
            var apTalismans:Array  = [];
            var apShadowCores:Array = [];

            // Rebuild tracker state from the full item list.  Stage tokens
            // are reflected via AV.sessionData.hasItem now (used by
            // _syncStageLockState below); no need to track them separately.
            AV.sessionData.reset();

            // Diagnostic dump: list every AP item id received in the full sync.
            var receivedDump:String = "";
            for each (var dumpItem:Object in items) {
                receivedDump += String(int(dumpItem.item)) + ",";
            }
            _logger.log(MOD_NAME, "syncWithAP: full-sync received items: ["
                + receivedDump + "]  (count=" + items.length + ")");

            for each (var item:Object in items) {
                var apId:int = item.item;
                AV.sessionData.onItem(apId);

                if (apId >= 700 && apId <= 723) {
                    apSkills[apId - 700] = true;
                } else if (apId >= 800 && apId <= 814) {
                    apTraits[apId - 800] = true;
                } else if (apId >= 1100 && apId <= 1199) {
                    apXpTotal += _levelUnlocker.levelsForApId(apId);
                } else if ((apId >= 900 && apId <= 952) || (apId >= 1200 && apId <= 1246)) {
                    apTalismans.push(apId);
                } else if ((apId >= 1000 && apId <= 1016) || (apId >= 1300 && apId <= 1351)) {
                    apShadowCores.push(apId);
                }
                // Stage tokens fall through — they're tracked via AV.sessionData.
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

            // --- Stages --- (unified lock/unlock logic, also handles free stages)
            var stageChanges:int = _syncStageLockState();

            // --- Stashes --- (re-apply unlocks from received key items, all granularities)
            var stashChanges:int = _syncStashLockState();

            // Diagnostic dump: list every stash currently marked unlocked.
            var unlockedDump:String = "";
            for (var dsid:String in AV.sessionData.unlockedStashesByStrId) {
                if (AV.sessionData.unlockedStashesByStrId[dsid] == true)
                    unlockedDump += dsid + ",";
            }
            _logger.log(MOD_NAME, "syncWithAP: unlockedStashesByStrId after sync: ["
                + unlockedDump + "]");

            // --- Wizard levels ---
            _levelUnlocker.bonusWizardLevel = apXpTotal;
            _levelUnlocker.applyBonusLevels();

            // --- Talisman fragments ---
            _talismanUnlocker.syncTalismans(apTalismans);

            // --- Shadow cores ---
            _shadowCoreUnlocker.syncShadowCores(apShadowCores);

            // (Free-stage unlocking is handled by _syncStageLockState above.)
            _saveManager.saveSlotData();

            if (_fieldLogicEvaluator != null) _fieldLogicEvaluator.markDirty();
            if (_achievementLogicEvaluator != null) _achievementLogicEvaluator.markDirty();

            _logger.log(MOD_NAME, "AP sync complete — skills:" + skillChanges +
                " traits:" + traitChanges + " stages:" + stageChanges +
                " stashes:" + stashChanges +
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
