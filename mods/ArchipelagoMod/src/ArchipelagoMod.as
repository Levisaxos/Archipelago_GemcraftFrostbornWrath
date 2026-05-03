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
    import com.giab.games.gcfw.constants.DropType;
    import com.giab.games.gcfw.constants.IngameStatus;
    import com.giab.games.gcfw.constants.ScreenId;
    import com.giab.games.gcfw.entity.TalismanFragment;
    import com.giab.games.gcfw.mcDyn.McDropIconOutcome;

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
    import ui.OfflineItemsPanel;
    import ui.OfflineItemsCollector;

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
        private var _offlineItemsPanel:OfflineItemsPanel;
        private var _offlineItemsCollector:OfflineItemsCollector;
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
        // Tracks the prior frame's GV.ingameCore.ingameStatus so we can detect
        // an in-place level restart (outcome panel's Retry button calls
        // initializer.setScene1 without changing currentScreen, so the
        // screen-transition cleanup never fires). -1 = not initialized / not in INGAME.
        private var _lastIngameStatus:int      = -1;
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

                // Offline items grid — popup window of items received while offline.
                _offlineItemsPanel     = new OfflineItemsPanel();
                _offlineItemsPanel.tooltipRenderer = _renderOfflineTooltip;
                _offlineItemsCollector = new OfflineItemsCollector(_logger, MOD_NAME, _offlineItemsPanel);
                _offlineItemsCollector.onSeenApIdsChanged = _persistSeenOfflineApIds;

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

            // Offline items grid — show pending items when player reaches the
            // world map (SELECTOR). Tick the open panel so its scroll +
            // staggered icon reveal animations advance.
            if (_offlineItemsCollector != null) {
                _offlineItemsCollector.tick(this.stage);
            }
            if (_offlineItemsPanel != null && _offlineItemsPanel.isShowing) {
                _offlineItemsPanel.doEnterFrame();
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
                    if (_receivedToast != null) {
                        _receivedToast.clear();
                        _receivedToast.setSuppressed(false);
                    }
                    if (_offlineItemsCollector != null) _offlineItemsCollector.reset();
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
                    _initForNewStage();
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
                    _resetPerLevelState("LEFT INGAME → transitioning to screen=" + screen);
                }
                // Remove MAINMENU overlays when navigating away from the main menu.
                if (_lastScreen == ScreenId.MAINMENU && screen != ScreenId.MAINMENU) {
                    _mainMenuUI.hide();
                }

                _lastScreen = screen;
            }

            // Detect in-place level restart from the outcome panel's Retry button
            // (vanilla IngameInputHandler2.ehOutcomePanelBtnRetryUp calls
            // initializer.setScene1 without changing currentScreen). The screen-
            // transition cleanup above never fires in that case, so stale per-level
            // state (_apIconsInjected, _sessionDrops, _levelEndCountdown) carries
            // into the next end-of-level and suppresses AP drop-icon injection —
            // the player sees vanilla achievement icons instead.
            if (screen == ScreenId.INGAME && GV.ingameCore != null) {
                var status:int = int(GV.ingameCore.ingameStatus);
                if (_lastIngameStatus != -1
                        && status != _lastIngameStatus
                        && status == IngameStatus.PLAYING
                        && _isGameOverPanelStatus(_lastIngameStatus)) {
                    _resetPerLevelState("In-place restart detected (status "
                        + _lastIngameStatus + " → PLAYING)");
                    _initForNewStage();
                }
                _lastIngameStatus = status;
            } else {
                _lastIngameStatus = -1;
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
            _loadSeenOfflineApIdsIntoCollector();
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
                _loadSeenOfflineApIdsIntoCollector();
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
         * Per-stage init that must run when the player begins (or restarts) a level.
         * Fires both on screen-transition into INGAME and on in-place restart from
         * the outcome panel's Retry button.
         */
        private function _initForNewStage():void {
            skipAllTutorials();
            _deathLinkHandler.resetForNewStage();
            _wavePrePatcher.resetForNewStage();
            _ritualSpawnPatcher.resetForNewStage();
            _startingGemSuppressor.applyIfReady();
        }

        /**
         * Per-level cleanup — clears session drops, resets the AP-icon-injection
         * flag, and re-arms the patches that latch on first apply during a level.
         * Fires both on screen-transition out of INGAME and on in-place restart
         * from the outcome panel's Retry button (which keeps currentScreen=INGAME
         * but starts a fresh attempt via initializer.setScene1).
         */
        private function _resetPerLevelState(reason:String):void {
            _firstPlayBypass.resetIngame();
            _frostbornFreeBuildings.resetIngame();
            _gemPouchSuppressor.resetIngame();
            _hollowGemInjector.resetIngame();
            _startingGemSuppressor.resetForNewStage();
            _logger.log(MOD_NAME, reason);
            _logger.log(MOD_NAME, "=== AP items received this level: " + _sessionDrops.length + " ===");
            for (var sd:int = 0; sd < _sessionDrops.length; sd++) {
                var sdEntry:Object = _sessionDrops[sd];
                _logger.log(MOD_NAME, "  [" + sd + "] " + sdEntry.name + " (apId=" + sdEntry.apId + ")");
            }
            _logger.log(MOD_NAME, "=== end of AP items list ===");
            _sessionDrops = [];
            _sessionGrantedFragments = [];
            _levelEndCountdown = -1;
            if (_progressionBlocker != null) _progressionBlocker.resetApIconsState();
        }

        /** True for any of the GAMEOVER_PANEL_* outcome-panel substates. */
        private function _isGameOverPanelStatus(s:int):Boolean {
            return s == IngameStatus.GAMEOVER_PANEL_APPEARING
                || s == IngameStatus.GAMEOVER_PANEL_STATS_ROLLING
                || s == IngameStatus.GAMEOVER_PANEL_DROPS_LISTING
                || s == IngameStatus.GAMEOVER_PANEL_SHOWING_IDLE
                || s == IngameStatus.GAMEOVER_PANEL_DISAPPEARING;
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
        // Offline items collector — persistence + diff sync helpers

        /** Push the persisted seen-set from SaveManager into the collector. */
        private function _loadSeenOfflineApIdsIntoCollector():void {
            if (_offlineItemsCollector == null || _saveManager == null) return;
            var ids:Array = _saveManager.seenOfflineApIds;
            var set:Object = {};
            if (ids != null) {
                for each (var id:* in ids) set[String(int(id))] = true;
            }
            _offlineItemsCollector.seenApIds = set;
        }

        /** Persist the collector's seen-set via SaveManager. */
        private function _persistSeenOfflineApIds():void {
            if (_offlineItemsCollector == null || _saveManager == null) return;
            _saveManager.seenOfflineApIds = _offlineItemsCollector.seenApIdsAsArray;
            _saveManager.saveSlotData();
        }

        /**
         * Resolver invoked by OfflineItemsCollector for each newly-seen apId.
         * Returns { name, sender, iconBmpd? } for the grid cell. iconBmpd is
         * pre-built here only for ranges that need mod-side context the
         * panel's own icon factory doesn't have access to (e.g. achievement
         * gameId lookup, which lives on AchievementUnlocker). For everything
         * else, McOfflineItems builds the icon itself from the apId.
         */
        private function _resolveOfflineItemEntry(apId:int, item:Object):Object {
            var name:String = itemName(apId);
            if (name == null) name = "Item #" + apId;

            var sender:String = null;
            if (item != null && item.player != null) {
                var senderSlot:int = int(item.player);
                if (senderSlot > 0 && AV.archipelagoData != null && AV.archipelagoData.players != null) {
                    var pd:Object = AV.archipelagoData.players[senderSlot];
                    if (pd != null && pd.name != null) sender = String(pd.name);
                }
            }

            var iconBmpd:* = null;
            try {
                // Achievement icons: McDropIconOutcome(ACHIEVEMENT, gameId)
                // needs the game-internal achievement id, which only
                // AchievementUnlocker knows (apId → gameId via game_data.json).
                if (apId >= 2000 && apId <= 2636 && _achievementUnlocker != null
                        && GV.achiCollection != null && GV.achiCollection.achisById != null) {
                    var gid:int = _achievementUnlocker.findGameIdByApId(apId);
                    if (gid >= 0 && GV.achiCollection.achisById[gid] != null) {
                        iconBmpd = (new McDropIconOutcome(DropType.ACHIEVEMENT, gid)).bmpdIcon;
                    }
                }
            } catch (errIcon:Error) {
                _logger.log(MOD_NAME, "_resolveOfflineItemEntry icon error apId="
                    + apId + ": " + errIcon.message);
            }

            return {
                name: name,
                sender: sender,
                iconBmpd: iconBmpd,
                sortPriority: _offlineSortPriority(apId)
            };
        }

        /**
         * Sort priority for the offline-items grid. Lower = earlier in the grid.
         * Categories cluster together so the player sees thematic groups: tile-
         * related items first, then quality-of-life unlocks, then collectables,
         * then filler. Within a priority bucket, OfflineItemsCollector keeps
         * insertion order (which is server-item-array order ≈ chronological).
         */
        private function _offlineSortPriority(apId:int):int {
            // Field tokens — all granularities, including progressive singletons.
            if (apId >= 1 && apId <= 122)         return 1;
            if (apId >= 1562 && apId <= 1600)     return 1;
            var so:* = AV.serverData != null ? AV.serverData.serverOptions : null;
            if (so != null) {
                if (so.fieldTokenPerStageProgressiveId > 0
                        && apId == so.fieldTokenPerStageProgressiveId) return 1;
                if (so.fieldTokenPerTileProgressiveId > 0
                        && apId == so.fieldTokenPerTileProgressiveId)  return 1;
                if (so.fieldTokenPerTierProgressiveId > 0
                        && apId == so.fieldTokenPerTierProgressiveId)  return 1;
            }
            // Map tiles
            if (apId >= 600 && apId <= 625) return 2;
            // Gempouches — distinct + tier + master + both progressives
            if (apId >= 626 && apId <= 652)       return 3;
            if (apId >= 1601 && apId <= 1614)     return 3;
            if (so != null && so.gemPouchPerTierProgressiveId > 0
                    && apId == so.gemPouchPerTierProgressiveId) return 3;
            // Wizard Stash keys — all granularities
            if (apId >= 1400 && apId <= 1561)     return 4;
            if (so != null) {
                if (so.stashKeyPerStageProgressiveId > 0
                        && apId == so.stashKeyPerStageProgressiveId) return 4;
                if (so.stashKeyPerTileProgressiveId > 0
                        && apId == so.stashKeyPerTileProgressiveId)  return 4;
                if (so.stashKeyPerTierProgressiveId > 0
                        && apId == so.stashKeyPerTierProgressiveId)  return 4;
            }
            // Skills
            if (apId >= 700 && apId <= 723) return 5;
            // Battle traits
            if (apId >= 800 && apId <= 814) return 6;
            // Talismans
            if ((apId >= 900 && apId <= 952) || (apId >= 1200 && apId <= 1246)) return 7;
            // Shadow cores
            if ((apId >= 1000 && apId <= 1016) || (apId >= 1300 && apId <= 1351)) return 8;
            // XP tomes
            if (apId >= 1100 && apId <= 1199) return 9;
            // Skill points
            if (apId >= 1700 && apId <= 1709) return 10;
            // Achievements
            if (apId >= 2000 && apId <= 2636) return 11;
            // Other (other-game items, unmapped ranges)
            return 99;
        }

        /**
         * Tooltip renderer for the offline-items grid. Mirrors vanilla
         * IngameInfoPanelRenderer2.renderDropIconInfoPanel exactly for ranges
         * vanilla supports, and uses the existing custom tooltip text from
         * XpTomeDropIcon / GempouchDropIcon / SkillPointDropIcon for ranges
         * vanilla doesn't.
         *
         * Vanilla TALISMAN_FRAGMENT and ACHIEVEMENT delegate to selectorCore
         * panels (renderInfoPanelFragment, renderAchiInfoPanel) — those panels
         * do their own reset() and addChild(vIp), so when this returns true
         * the caller (McOfflineItems._onCellOver) skips the fallback.
         *
         * Returns true on success so the caller knows the title text is
         * populated; false makes McOfflineItems print a generic "<name>"
         * fallback instead.
         */
        private function _renderOfflineTooltip(vIp:*, apId:int):Boolean {
            try {
                // Field tokens (1-122)
                if (apId >= 1 && apId <= 122) {
                    var strId:* = AV.serverData != null ? AV.serverData.tokenMap[String(apId)] : null;
                    if (strId == null) return false;
                    vIp.reset(180);
                    vIp.addTextfield(0xFFFF81, "Token for field " + String(strId), false, 12);
                    vIp.addExtraHeight(-4);
                    return true;
                }
                // Map tiles (600-625)
                if (apId >= 600 && apId <= 625) {
                    if (GV.selectorCore == null || GV.selectorCore.mapTiles == null) return false;
                    if (AV.serverData == null || AV.serverData.apIdToGameId == null) return false;
                    var tileGid:int = int(AV.serverData.apIdToGameId[apId]);
                    var tile:* = GV.selectorCore.mapTiles[tileGid];
                    if (tile == null) return false;
                    vIp.reset(180);
                    vIp.addTextfield(0xFFFF81, "Map tile " + String(tile.strId), false, 12);
                    vIp.addExtraHeight(-4);
                    return true;
                }
                // Skill tomes (700-723)
                if (apId >= 700 && apId <= 723) {
                    if (GV.selectorCore == null || GV.selectorCore.pnlSkills == null) return false;
                    var skillTitle:String = String(GV.selectorCore.pnlSkills.skillTitles[apId - 700]);
                    vIp.reset(290);
                    vIp.addTextfield(0xFFCC00, skillTitle, true, 13);
                    vIp.addTextfield(0xFFFF81, "Skill Tome", false, 11);
                    vIp.addTextfield(0xD2C2A0, "Will be added to the skills panel", false, 11);
                    return true;
                }
                // Battle trait scrolls (800-814)
                if (apId >= 800 && apId <= 814) {
                    if (GV.selectorCore == null || GV.selectorCore.renderer == null) return false;
                    var traitTitle:String = String(GV.selectorCore.renderer.traitTitles[apId - 800]);
                    vIp.reset(360);
                    vIp.addTextfield(0xFFCC00, traitTitle, true, 13);
                    vIp.addTextfield(0xFFFF81, "Battle Trait Scroll", false, 11);
                    vIp.addTextfield(0xD2C2A0, "Will be added to the battle traits panel", false, 11);
                    vIp.addTextfield(0xBBBBBB, "You can add traits to the battle\nafter selecting a field on the map", false, 11);
                    return true;
                }
                // Talisman fragments (900-952, 1200-1246) — delegate to vanilla.
                if ((apId >= 900 && apId <= 952) || (apId >= 1200 && apId <= 1246)) {
                    if (AV.serverData == null || AV.serverData.talismanMap == null) return false;
                    var talData:* = AV.serverData.talismanMap[String(apId)];
                    if (talData == null) return false;
                    var parts:Array = String(talData).split("/");
                    if (parts.length < 4) return false;
                    if (GV.selectorCore == null || GV.selectorCore.pnlTalisman == null) return false;
                    var frag:TalismanFragment = new TalismanFragment(
                        int(parts[0]), int(parts[1]), int(parts[2]), int(parts[3]));
                    // The vanilla renderer reads pFrag.bmpInTalisman / bmpInInventory;
                    // those are populated lazily by talFragBitmapCreator. Without
                    // this call the renderer throws (or shows a blank fragment).
                    if (GV.talFragBitmapCreator != null && frag.bmpInInventory == null) {
                        GV.talFragBitmapCreator.giveTalFragBitmaps(frag);
                    }
                    GV.selectorCore.pnlTalisman.renderInfoPanelFragment(frag);
                    return true;
                }
                // Shadow cores (1000-1016, 1300-1351)
                if ((apId >= 1000 && apId <= 1016) || (apId >= 1300 && apId <= 1351)) {
                    var amount:int = 1;
                    if (AV.serverData != null && AV.serverData.shadowCoreMap != null) {
                        var amt:* = AV.serverData.shadowCoreMap[String(apId)];
                        if (amt != null) amount = int(amt);
                    }
                    if (amount < 1) amount = 1;
                    vIp.reset(360);
                    vIp.addTextfield(0xFFA42F, amount + (amount > 1 ? " shadow cores" : " shadow core"), false, 13);
                    vIp.addExtraHeight(5);
                    vIp.addSeparator(-2);
                    vIp.addTextfield(0xC1C1C1, "Shadow cores can be used to:", false, 11);
                    vIp.addTextfield(0xDEB349, " - Boost talisman fragment drop rarity", true, 11);
                    vIp.addTextfield(0xC0C1C1, " - Unlock talisman slots", true, 11);
                    vIp.addTextfield(0xDEB349, " - Upgrade talisman fragments", true, 11);
                    vIp.addTextfield(0xC0C1C1, " - Change talisman fragment shapes", true, 11);
                    vIp.addTextfield(0xDEB349, " - Get more skill points", false, 11);
                    vIp.addExtraHeight(-4);
                    return true;
                }
                // XP tomes (1100-1199) — same text XpTomeDropIcon shows on level-end.
                if (apId >= 1100 && apId <= 1199) {
                    var label:String = "Tattered Scroll";
                    if (apId >= 1132 && apId <= 1137) label = "Worn Tome";
                    else if (apId >= 1138 && apId <= 1139) label = "Ancient Grimoire";
                    var lv:int = (_levelUnlocker != null) ? _levelUnlocker.levelsForApId(apId) : 0;
                    vIp.reset(260);
                    vIp.addTextfield(0xFFD700, label, false, 13);
                    vIp.addTextfield(0xCCCCCC, "Wizard XP Tome", false, 11);
                    var grantText:String = (lv > 0)
                        ? ("Grants " + lv + " wizard level" + (lv == 1 ? "" : "s"))
                        : "Grants wizard levels when collected";
                    vIp.addTextfield(0x99FF99, grantText, false, 11);
                    return true;
                }
                // Skill point bundles (1700-1709) — same text SkillPointDropIcon shows.
                if (apId >= 1700 && apId <= 1709) {
                    var skp:int = apId - 1699;
                    vIp.reset(280);
                    vIp.addTextfield(0xFFD700, "Skillpoint Bundle", false, 13);
                    vIp.addTextfield(0xCCCCCC, "Skill Points", false, 11);
                    vIp.addTextfield(0x99FF99, "+" + skp + " skill points.", false, 11);
                    return true;
                }
                // Achievements (2000-2636) — delegate to vanilla.
                if (apId >= 2000 && apId <= 2636) {
                    if (_achievementUnlocker == null || GV.selectorCore == null
                            || GV.selectorCore.pnlAchievements == null
                            || GV.achiCollection == null
                            || GV.achiCollection.achisById == null) return false;
                    var gid:int = _achievementUnlocker.findGameIdByApId(apId);
                    if (gid < 0 || GV.achiCollection.achisById[gid] == null) return false;
                    GV.selectorCore.pnlAchievements.renderAchiInfoPanel(GV.achiCollection.achisById[gid]);
                    return true;
                }
                // Stash keys (1400-1561) — name from itemName().
                if (apId >= 1400 && apId <= 1561) {
                    var keyName:String = itemName(apId);
                    if (keyName == null) return false;
                    vIp.reset(280);
                    vIp.addTextfield(0x99CCFF, keyName, false, 13);
                    vIp.addTextfield(0xCCCCCC, "Wizard Stash Key", false, 11);
                    return true;
                }
                // Per-tile / per-tier field tokens (1562-1600).
                if (apId >= 1562 && apId <= 1600) {
                    var tokenName:String = itemName(apId);
                    if (tokenName == null) return false;
                    vIp.reset(280);
                    vIp.addTextfield(0xFFFF81, tokenName, false, 13);
                    vIp.addTextfield(0xCCCCCC, "Field Tokens (bundle)", false, 11);
                    return true;
                }
                // ---------- Progressive variants ----------
                // Each progressive singleton renders a count-aware tooltip:
                // title = item name, body = "Unlocks ... (N/total unlocked)".
                // The renderer reads getItemCount live so the count reflects
                // the player's current progress, not when the cell was built.
                var prgOpts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
                if (prgOpts != null) {
                    // Progressive tooltips use the starter-first orders so the
                    // "Next: <prefix>" line reflects what the next received
                    // copy will actually unlock.
                    var stagOrder:Array = prgOpts.progressiveStageOrder as Array;
                    var tileOrder:Array = prgOpts.progressiveTileOrder as Array;
                    var tierOrder:Array = prgOpts.progressiveTierOrder as Array;
                    var tierTotal:int   = (tierOrder != null) ? tierOrder.length : 13;

                    if (prgOpts.fieldTokenPerStageProgressiveId > 0
                            && apId == prgOpts.fieldTokenPerStageProgressiveId) {
                        return _renderProgressiveTooltip(vIp, apId,
                            "Progressive Field Token", "Field Token",
                            "Unlocks the next stage", stagOrder, true);
                    }
                    if (prgOpts.fieldTokenPerTileProgressiveId > 0
                            && apId == prgOpts.fieldTokenPerTileProgressiveId) {
                        return _renderProgressiveTooltip(vIp, apId,
                            "Progressive Field Token", "Field Token (per tile)",
                            "Unlocks all stages on the next tile", tileOrder, true);
                    }
                    if (prgOpts.fieldTokenPerTierProgressiveId > 0
                            && apId == prgOpts.fieldTokenPerTierProgressiveId) {
                        return _renderProgressiveTooltip(vIp, apId,
                            "Progressive Field Token", "Field Token (per tier)",
                            "Unlocks all stages in the next tier", null, false, tierTotal);
                    }
                    if (prgOpts.stashKeyPerStageProgressiveId > 0
                            && apId == prgOpts.stashKeyPerStageProgressiveId) {
                        return _renderProgressiveTooltip(vIp, apId,
                            "Progressive Stash Key", "Wizard Stash Key (per stage)",
                            "Unlocks the next stash", stagOrder, true);
                    }
                    if (prgOpts.stashKeyPerTileProgressiveId > 0
                            && apId == prgOpts.stashKeyPerTileProgressiveId) {
                        return _renderProgressiveTooltip(vIp, apId,
                            "Progressive Stash Key", "Wizard Stash Key (per tile)",
                            "Unlocks all stashes on the next tile", tileOrder, true);
                    }
                    if (prgOpts.stashKeyPerTierProgressiveId > 0
                            && apId == prgOpts.stashKeyPerTierProgressiveId) {
                        return _renderProgressiveTooltip(vIp, apId,
                            "Progressive Stash Key", "Wizard Stash Key (per tier)",
                            "Unlocks all stashes in the next tier", null, false, tierTotal);
                    }
                    if (prgOpts.gemPouchPerTierProgressiveId > 0
                            && apId == prgOpts.gemPouchPerTierProgressiveId) {
                        return _renderProgressiveTooltip(vIp, apId,
                            "Progressive Gempouch", "Gem Pouch (per tier)",
                            "Unlocks gems for the next tier", null, false, tierTotal);
                    }
                }
                // Gempouches (626-652) — exact match to GempouchDropIcon._onMouseOver.
                if (apId >= 626 && apId <= 652) {
                    var opts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
                    var order:Array = (opts != null) ? opts.gemPouchPlayOrder as Array : null;
                    var progressiveId:int = (opts != null) ? int(opts.gemPouchProgressiveId) : 652;
                    if (progressiveId <= 0) progressiveId = 652;

                    var gpTitle:String;
                    var gpBody:String;
                    if (apId == progressiveId) {
                        var copies:int = (AV.sessionData != null)
                            ? AV.sessionData.getItemCount(apId) : 0;
                        var total:int = (order != null) ? order.length : 26;
                        gpTitle = "Progressive Gempouch";
                        gpBody  = "Unlocks gems on the next world. ("
                            + copies + "/" + total + " worlds unlocked)";
                    } else {
                        var gpIdx:int = apId - 626;
                        var prefix:String = (order != null && gpIdx >= 0 && gpIdx < order.length)
                            ? String(order[gpIdx]) : "?";
                        gpTitle = "Gempouch (" + prefix + ")";
                        gpBody  = "Unlocks gems on stages of world " + prefix + ".";
                    }
                    vIp.reset(280);
                    vIp.addTextfield(0xFFD700, gpTitle, false, 13);
                    vIp.addTextfield(0xCCCCCC, "Gem Pouch", false, 11);
                    vIp.addTextfield(0x99FF99, gpBody, false, 11);
                    return true;
                }
            } catch (err:Error) {
                _logger.log(MOD_NAME, "_renderOfflineTooltip error apId=" + apId + ": " + err.message);
            }
            return false;
        }

        /**
         * Shared tooltip renderer for progressive singleton items. Mirrors the
         * format GempouchDropIcon uses — title (gold), subtitle (grey),
         * count-aware body (green) showing "(N/total unlocked)".
         *
         * @param order    If non-null, drives the body line "Next: <prefix>"
         *                 by reading order[N]. For per-tier variants the
         *                 fixedTotal kwarg is used instead.
         * @param showNext If true and order is non-null, append the next-to-
         *                 unlock prefix/sid to the body.
         * @param fixedTotal Override for `total` when no order list applies
         *                   (per-tier variants pass 13).
         */
        private function _renderProgressiveTooltip(vIp:*, apId:int,
                title:String, subtitle:String, bodyLead:String,
                order:Array, showNext:Boolean, fixedTotal:int = 0):Boolean {
            try {
                var copies:int = (AV.sessionData != null) ? AV.sessionData.getItemCount(apId) : 0;
                var total:int  = (order != null) ? order.length : fixedTotal;
                if (total <= 0) total = (order != null) ? order.length : 1;

                var body:String = bodyLead + ". (" + copies + "/" + total + " unlocked)";
                if (showNext && order != null && copies < order.length) {
                    body += "\nNext: " + String(order[copies]);
                }

                vIp.reset(300);
                vIp.addTextfield(0xFFD700, title, false, 13);
                vIp.addTextfield(0xCCCCCC, subtitle, false, 11);
                vIp.addTextfield(0x99FF99, body, false, 11);
                return true;
            } catch (err:Error) {
                _logger.log(MOD_NAME, "_renderProgressiveTooltip error apId="
                    + apId + ": " + err.message);
                return false;
            }
        }

        // -----------------------------------------------------------------------
        // Item handling

        private function grantItem(apId:int):void {
            try {
                _logger.log(MOD_NAME, "grantItem called with apId=" + apId);

                // Mark this apId as seen so it doesn't reappear in the
                // next session's offline-items diff. Without this, items
                // received live during a play session would be treated as
                // unseen on next reconnect and re-pop in the panel.
                if (_offlineItemsCollector != null) _offlineItemsCollector.markSeen(apId);

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
                // ---------- Progressive variants (singleton apIds, count-based) ----------
                // Each is a single item id added to the pool N times. The Nth
                // received copy unlocks the Nth entry in the relevant order.
                // The corresponding *ProgressiveId fields come from slot_data
                // (set in net.ApReceiver.handleConnected). 0 means the slot
                // never used this granularity, so we fall through.
                var so:* = (AV.serverData != null) ? AV.serverData.serverOptions : null;
                if (so != null) {
                    if (so.fieldTokenPerStageProgressiveId > 0
                            && apId == so.fieldTokenPerStageProgressiveId) {
                        _grantFieldTokenProgressivePerStage(apId);
                        return;
                    }
                    if (so.fieldTokenPerTileProgressiveId > 0
                            && apId == so.fieldTokenPerTileProgressiveId) {
                        _grantFieldTokenProgressivePerTile(apId);
                        return;
                    }
                    if (so.fieldTokenPerTierProgressiveId > 0
                            && apId == so.fieldTokenPerTierProgressiveId) {
                        _grantFieldTokenProgressivePerTier(apId);
                        return;
                    }
                    if (so.stashKeyPerStageProgressiveId > 0
                            && apId == so.stashKeyPerStageProgressiveId) {
                        _grantStashKeyProgressivePerStage(apId);
                        return;
                    }
                    if (so.stashKeyPerTileProgressiveId > 0
                            && apId == so.stashKeyPerTileProgressiveId) {
                        _grantStashKeyProgressivePerTile(apId);
                        return;
                    }
                    if (so.stashKeyPerTierProgressiveId > 0
                            && apId == so.stashKeyPerTierProgressiveId) {
                        _grantStashKeyProgressivePerTier(apId);
                        return;
                    }
                    if ((so.gemPouchProgressiveId > 0 && apId == so.gemPouchProgressiveId)
                            || (so.gemPouchPerTierProgressiveId > 0
                                && apId == so.gemPouchPerTierProgressiveId)) {
                        // Gempouches don't change in-game state — gating is
                        // handled by SessionData.getItemCount on the mod side
                        // and is read live by HollowGemInjector etc. Just toast.
                        _receivedToast.addItem("Received Progressive Gempouch", 0xFF99FF);
                        _logger.log(MOD_NAME, "  → Progressive Gempouch (count="
                            + AV.sessionData.getItemCount(apId) + ")");
                        return;
                    }
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

        // ---------- Progressive grant helpers ----------
        // Each handler reads the live count of the singleton apId via
        // AV.sessionData.getItemCount, finds the (count-1)-th entry in the
        // appropriate order (stage / tile / tier), and unlocks just that one
        // group. Earlier copies were already processed on previous calls.

        /** Starter-first tier order — prefers progressiveTierOrder from
         *  slot_data (starter's tier at position 0, rest ascending with
         *  starter removed). Falls back to plain ascending if slot_data
         *  didn't supply the list (older mod build / non-progressive seed). */
        private function _progressiveTiersOrAsc():Array {
            var so:* = AV.serverData != null ? AV.serverData.serverOptions : null;
            if (so != null) {
                var list:Array = so.progressiveTierOrder as Array;
                if (list != null && list.length > 0) return list;
            }
            return _activeTiersAsc();
        }

        /** Returns the unique tier ints in ascending order, derived live from
         *  stageTierByStrId. Cached per call but cheap; alternative would be
         *  to send active_tiers via slot_data. */
        private function _activeTiersAsc():Array {
            var tierMap:Object = AV.serverData != null && AV.serverData.serverOptions != null
                ? AV.serverData.serverOptions.stageTierByStrId : null;
            var seen:Object = {};
            var out:Array = [];
            if (tierMap != null) {
                for (var sid:String in tierMap) {
                    var t:int = int(tierMap[sid]);
                    if (t >= 0 && !seen[String(t)]) {
                        seen[String(t)] = true;
                        out.push(t);
                    }
                }
            }
            out.sort(Array.NUMERIC);
            return out;
        }

        private function _grantFieldTokenProgressivePerStage(apId:int):void {
            var order:Array = AV.serverData != null && AV.serverData.serverOptions != null
                ? AV.serverData.serverOptions.progressiveStageOrder as Array : null;
            if (order == null || order.length == 0) {
                _logger.log(MOD_NAME, "  grantItem: per-stage progressive field token — no order");
                return;
            }
            var n:int = AV.sessionData.getItemCount(apId);
            if (n <= 0 || n > order.length) {
                _logger.log(MOD_NAME, "  grantItem: per-stage progressive field token count " + n + " out of range");
                return;
            }
            var sid:String = String(order[n - 1]);
            _stageUnlocker.unlockStage(sid);
            _receivedToast.addItem("Received Progressive Field Token — unlocks " + sid, 0xFFDD55);
            _logger.log(MOD_NAME, "  → Progressive field token (per-stage) #" + n + " unlocks " + sid);
        }

        private function _grantFieldTokenProgressivePerTile(apId:int):void {
            var order:Array = AV.serverData != null && AV.serverData.serverOptions != null
                ? AV.serverData.serverOptions.progressiveTileOrder as Array : null;
            if (order == null || order.length == 0) {
                _logger.log(MOD_NAME, "  grantItem: per-tile progressive field token — no order");
                return;
            }
            var n:int = AV.sessionData.getItemCount(apId);
            if (n <= 0 || n > order.length) {
                _logger.log(MOD_NAME, "  grantItem: per-tile progressive field token count " + n + " out of range");
                return;
            }
            var prefix:String = String(order[n - 1]);
            var count:int = 0;
            var byStrId:Object = AV.serverData.stagesByStrId;
            for (var sid:String in byStrId) {
                if (sid.charAt(0) == prefix) {
                    _stageUnlocker.unlockStage(sid);
                    count++;
                }
            }
            _receivedToast.addItem("Received Progressive Field Token — tile " + prefix
                + " (" + count + " stages)", 0xFFDD55);
            _logger.log(MOD_NAME, "  → Progressive field token (per-tile) #" + n
                + " unlocks tile " + prefix + " (" + count + " stages)");
        }

        private function _grantFieldTokenProgressivePerTier(apId:int):void {
            var tiers:Array = _progressiveTiersOrAsc();
            var n:int = AV.sessionData.getItemCount(apId);
            if (n <= 0 || n > tiers.length) {
                _logger.log(MOD_NAME, "  grantItem: per-tier progressive field token count " + n + " out of range");
                return;
            }
            var tier:int = int(tiers[n - 1]);
            _grantFieldTokenByTier(tier);
            _logger.log(MOD_NAME, "  → Progressive field token (per-tier) #" + n + " = tier " + tier);
        }

        private function _grantStashKeyProgressivePerStage(apId:int):void {
            var order:Array = AV.serverData != null && AV.serverData.serverOptions != null
                ? AV.serverData.serverOptions.progressiveStageOrder as Array : null;
            if (order == null || order.length == 0) {
                _logger.log(MOD_NAME, "  grantItem: per-stage progressive stash key — no order");
                return;
            }
            var n:int = AV.sessionData.getItemCount(apId);
            if (n <= 0 || n > order.length) {
                _logger.log(MOD_NAME, "  grantItem: per-stage progressive stash key count " + n + " out of range");
                return;
            }
            var sid:String = String(order[n - 1]);
            AV.sessionData.markStashUnlocked(sid);
            _receivedToast.addItem("Received Progressive Stash Key — unlocks " + sid, 0x55AAFF);
            _logger.log(MOD_NAME, "  → Progressive stash key (per-stage) #" + n + " unlocks " + sid);
        }

        private function _grantStashKeyProgressivePerTile(apId:int):void {
            var order:Array = AV.serverData != null && AV.serverData.serverOptions != null
                ? AV.serverData.serverOptions.progressiveTileOrder as Array : null;
            if (order == null || order.length == 0) {
                _logger.log(MOD_NAME, "  grantItem: per-tile progressive stash key — no order");
                return;
            }
            var n:int = AV.sessionData.getItemCount(apId);
            if (n <= 0 || n > order.length) {
                _logger.log(MOD_NAME, "  grantItem: per-tile progressive stash key count " + n + " out of range");
                return;
            }
            var prefix:String = String(order[n - 1]);
            var count:int = 0;
            var byStrId:Object = AV.serverData.stagesByStrId;
            for (var sid:String in byStrId) {
                if (sid.charAt(0) == prefix) {
                    AV.sessionData.markStashUnlocked(sid);
                    count++;
                }
            }
            _receivedToast.addItem("Received Progressive Stash Key — tile " + prefix
                + " (" + count + " stashes)", 0x55AAFF);
            _logger.log(MOD_NAME, "  → Progressive stash key (per-tile) #" + n
                + " unlocks tile " + prefix + " (" + count + " stashes)");
        }

        private function _grantStashKeyProgressivePerTier(apId:int):void {
            var tiers:Array = _progressiveTiersOrAsc();
            var n:int = AV.sessionData.getItemCount(apId);
            if (n <= 0 || n > tiers.length) {
                _logger.log(MOD_NAME, "  grantItem: per-tier progressive stash key count " + n + " out of range");
                return;
            }
            var tier:int = int(tiers[n - 1]);
            _grantStashKeyByTier(tier);
            _logger.log(MOD_NAME, "  → Progressive stash key (per-tier) #" + n + " = tier " + tier);
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

            // -------- Progressive variants (singleton apIds, count-based) --------
            // Nth received copy unlocks the Nth entry in the starter-first
            // order (progressive*Order in ServerOptions). Build the cumulative
            // unlock set on every sync from getItemCount.
            if (opts != null) {
                var stagOrder:Array = opts.progressiveStageOrder as Array;
                var tileOrder:Array = opts.progressiveTileOrder as Array;
                var tierOrder:Array = opts.progressiveTierOrder as Array;

                // Per-stage progressive
                var spProgId:int = int(opts.stashKeyPerStageProgressiveId);
                if (spProgId > 0 && stagOrder != null) {
                    var spN:int = AV.sessionData.getItemCount(spProgId);
                    var spLimit:int = (spN < stagOrder.length) ? spN : stagOrder.length;
                    for (var spi:int = 0; spi < spLimit; spi++) {
                        var ssid:String = String(stagOrder[spi]);
                        if (!AV.sessionData.isStashUnlocked(ssid)) {
                            AV.sessionData.markStashUnlocked(ssid);
                            changes++;
                        }
                    }
                }
                // Per-tile progressive
                var tpProgId:int = int(opts.stashKeyPerTileProgressiveId);
                if (tpProgId > 0 && tileOrder != null) {
                    var tpN:int = AV.sessionData.getItemCount(tpProgId);
                    var tpLimit:int = (tpN < tileOrder.length) ? tpN : tileOrder.length;
                    for (var tpi:int = 0; tpi < tpLimit; tpi++) {
                        var tpfx:String = String(tileOrder[tpi]);
                        for (var stsid:String in byStrId) {
                            if (stsid.charAt(0) == tpfx && !AV.sessionData.isStashUnlocked(stsid)) {
                                AV.sessionData.markStashUnlocked(stsid);
                                changes++;
                            }
                        }
                    }
                }
                // Per-tier progressive
                var ttProgId:int = int(opts.stashKeyPerTierProgressiveId);
                if (ttProgId > 0 && tierMap != null) {
                    var ttTiers:Array = (tierOrder != null && tierOrder.length > 0)
                                            ? tierOrder : _activeTiersAsc();
                    var ttN:int = AV.sessionData.getItemCount(ttProgId);
                    var ttLimit:int = (ttN < ttTiers.length) ? ttN : ttTiers.length;
                    for (var tti:int = 0; tti < ttLimit; tti++) {
                        var ttTier:int = int(ttTiers[tti]);
                        for (var tttsid:String in tierMap) {
                            if (int(tierMap[tttsid]) == ttTier && !AV.sessionData.isStashUnlocked(tttsid)) {
                                AV.sessionData.markStashUnlocked(tttsid);
                                changes++;
                            }
                        }
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

            // -------- Progressive variants (singleton apIds, count-based) --------
            // Nth received copy unlocks the Nth entry in the starter-first
            // order (progressive*Order in ServerOptions).
            if (opts != null) {
                var stagOrderFs:Array = opts.progressiveStageOrder as Array;
                var tileOrderFs:Array = opts.progressiveTileOrder as Array;
                var tierOrderFs:Array = opts.progressiveTierOrder as Array;

                var fsProgId:int = int(opts.fieldTokenPerStageProgressiveId);
                if (fsProgId > 0 && stagOrderFs != null) {
                    var fsN:int = AV.sessionData.getItemCount(fsProgId);
                    var fsLimit:int = (fsN < stagOrderFs.length) ? fsN : stagOrderFs.length;
                    for (var fsi:int = 0; fsi < fsLimit; fsi++) {
                        hasToken[String(stagOrderFs[fsi])] = true;
                    }
                }
                var ftProgId:int = int(opts.fieldTokenPerTileProgressiveId);
                if (ftProgId > 0 && tileOrderFs != null) {
                    var ftN:int = AV.sessionData.getItemCount(ftProgId);
                    var ftLimit:int = (ftN < tileOrderFs.length) ? ftN : tileOrderFs.length;
                    for (var fti:int = 0; fti < ftLimit; fti++) {
                        var ftPfx:String = String(tileOrderFs[fti]);
                        for (var ftSid:String in AV.serverData.stagesByStrId) {
                            if (ftSid.charAt(0) == ftPfx) hasToken[ftSid] = true;
                        }
                    }
                }
                var ftTierProgId:int = int(opts.fieldTokenPerTierProgressiveId);
                if (ftTierProgId > 0 && tierMap != null) {
                    var ftTiers:Array = (tierOrderFs != null && tierOrderFs.length > 0)
                                            ? tierOrderFs : _activeTiersAsc();
                    var fttN:int = AV.sessionData.getItemCount(ftTierProgId);
                    var fttLimit:int = (fttN < ftTiers.length) ? fttN : ftTiers.length;
                    for (var ftti:int = 0; ftti < fttLimit; ftti++) {
                        var fttTier:int = int(ftTiers[ftti]);
                        for (var ftTsid:String in tierMap) {
                            if (int(tierMap[ftTsid]) == fttTier) hasToken[ftTsid] = true;
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

            // Suppress per-item toasts during the bulk-grant — the OfflineItemsPanel
            // will display the newly-granted set instead.
            if (_receivedToast != null) _receivedToast.setSuppressed(true);

            try {

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

            // Hand the full-sync items to the offline-items collector so the grid
            // popup will surface anything new the next time the player is on
            // MAINMENU / SELECTOR. The collector diffs against the persisted
            // seen-set, so re-syncs in future sessions don't re-show old items.
            if (_offlineItemsCollector != null) {
                _offlineItemsCollector.onSyncCompleted(items, _resolveOfflineItemEntry);
            }

            } finally {
                // Resume normal toast behavior for any live (index>0) items received later.
                if (_receivedToast != null) _receivedToast.setSuppressed(false);
            }
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
            // Map tiles
            if (apId >= 600 && apId <= 625) {
                return "Map Tile #" + (apId - 600);
            }
            // Gempouches: distinct mode = 626 + index in gemPouchPlayOrder;
            // progressive mode = gemPouchProgressiveId (default 652).
            if (apId >= 626 && apId <= 652) {
                var gpOpts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
                var gpProgId:int = (gpOpts != null) ? int(gpOpts.gemPouchProgressiveId) : 652;
                if (gpProgId <= 0) gpProgId = 652;
                if (apId == gpProgId) return "Progressive Gempouch";
                var gpOrder:Array = (gpOpts != null) ? gpOpts.gemPouchPlayOrder as Array : null;
                var gpIdx2:int = apId - 626;
                if (gpOrder != null && gpIdx2 >= 0 && gpIdx2 < gpOrder.length) {
                    return "Gempouch (" + String(gpOrder[gpIdx2]) + ")";
                }
                return "Gempouch";
            }
            // XP tomes — ranges chosen by the apworld; LevelUnlocker knows the count.
            if (apId >= 1100 && apId <= 1199) {
                if (apId >= 1100 && apId <= 1131) return "Tattered Scroll";
                if (apId >= 1132 && apId <= 1137) return "Worn Tome";
                if (apId >= 1138 && apId <= 1139) return "Ancient Grimoire";
                return "XP Tome";
            }
            // Per-stage Wizard Stash keys (1400-1521 = 122 stages).
            if (apId >= 1400 && apId <= 1521) {
                return "Wizard Stash Key #" + (apId - 1400 + 1);
            }
            // Per-tile Wizard Stash keys (1522-1547 = one per prefix in playOrder).
            if (apId >= 1522 && apId <= 1547) {
                var stashTilePrefix:String = _prefixForTileApId(apId, 1522);
                if (stashTilePrefix != null && stashTilePrefix.length > 0) {
                    return "Wizard Stash Tile " + stashTilePrefix + " Key";
                }
                return "Wizard Stash Tile Key (#" + (apId - 1522) + ")";
            }
            // Per-tier Wizard Stash keys (1548-1560 = tiers 0..12).
            if (apId >= 1548 && apId <= 1560) {
                return "Wizard Stash Tier " + (apId - 1548) + " Key";
            }
            // Master Wizard Stash key (1561).
            if (apId == 1561) {
                return "Wizard Stash Master Key";
            }
            // Per-tile field tokens (1562-1587 = one per gemPouchPlayOrder prefix).
            if (apId >= 1562 && apId <= 1587) {
                var tileIdx:int = apId - 1562;
                if (AV.serverData != null && AV.serverData.serverOptions != null) {
                    var order:Array = AV.serverData.serverOptions.gemPouchPlayOrder as Array;
                    if (order != null && tileIdx < order.length) {
                        return String(order[tileIdx]) + " Tile Field Tokens";
                    }
                }
                return "Tile Field Tokens (#" + tileIdx + ")";
            }
            // Per-tier field tokens (1588-1600 = one per tier).
            if (apId >= 1588 && apId <= 1600) {
                return "Tier " + (apId - 1588) + " Field Tokens";
            }
            // Skill point bundles (1700-1709 — bundle size = apId - 1699).
            if (apId >= 1700 && apId <= 1709) {
                return "Skill Point Bundle (+" + (apId - 1699) + ")";
            }
            // Progressive variants — singleton ids from slot_data.
            var prgOpts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
            if (prgOpts != null) {
                if (prgOpts.fieldTokenPerStageProgressiveId > 0
                        && apId == prgOpts.fieldTokenPerStageProgressiveId)
                    return "Progressive Field Token (per-stage)";
                if (prgOpts.fieldTokenPerTileProgressiveId > 0
                        && apId == prgOpts.fieldTokenPerTileProgressiveId)
                    return "Progressive Field Token (per-tile)";
                if (prgOpts.fieldTokenPerTierProgressiveId > 0
                        && apId == prgOpts.fieldTokenPerTierProgressiveId)
                    return "Progressive Field Token (per-tier)";
                if (prgOpts.stashKeyPerStageProgressiveId > 0
                        && apId == prgOpts.stashKeyPerStageProgressiveId)
                    return "Progressive Stash Stage Key";
                if (prgOpts.stashKeyPerTileProgressiveId > 0
                        && apId == prgOpts.stashKeyPerTileProgressiveId)
                    return "Progressive Stash Tile Key";
                if (prgOpts.stashKeyPerTierProgressiveId > 0
                        && apId == prgOpts.stashKeyPerTierProgressiveId)
                    return "Progressive Stash Tier Key";
                if (prgOpts.gemPouchPerTierProgressiveId > 0
                        && apId == prgOpts.gemPouchPerTierProgressiveId)
                    return "Progressive Gempouch (per-tier)";
            }
            return null; // let ConnectionManager handle the rest
        }
    }
}
