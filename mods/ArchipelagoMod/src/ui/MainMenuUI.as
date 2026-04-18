package ui {
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;

    import Bezel.Logger;

    import save.FileHandler;
    import update.UpdateChecker;

    /**
     * Owns all main-menu overlay elements:
     *   - "Mod vX.X.X | apworld vX.X.X" version label
     *   - "↑ Update available!" badge (hidden until UpdateChecker fires)
     *   - Changelog button (managed by ModButtons.onMainMenuFrame)
     *   - ScrChangelog panel
     *   - UpdateChecker GitHub fetch (once per session)
     *
     * Lifecycle from ArchipelagoMod's frame loop:
     *   show()   — when entering MAINMENU and not yet showing
     *   onFrame() — every frame while on MAINMENU (drives ModButtons + debug log)
     *   hide()   — when leaving MAINMENU
     *   dispose() — in unload()
     */
    public class MainMenuUI {

        private var _logger:Logger;
        private var _modName:String;
        private var _fileHandler:FileHandler;
        private var _modButtons:ModButtons;
        private var _updateChecker:UpdateChecker;
        private var _scrChangelog:ScrChangelog;

        private var _versionLabel:TextField;
        private var _updateBadge:Sprite;
        private var _isShowing:Boolean       = false;
        private var _fetchDone:Boolean       = false;
        private var _cachedReleases:Array    = null;

        // -----------------------------------------------------------------------

        public function get isShowing():Boolean { return _isShowing; }

        public function MainMenuUI(logger:Logger, modName:String,
                                   fileHandler:FileHandler, modButtons:ModButtons) {
            _logger      = logger;
            _modName     = modName;
            _fileHandler = fileHandler;
            _modButtons  = modButtons;

            _scrChangelog = new ScrChangelog();

            _updateChecker = new UpdateChecker(_logger, _modName);
            _updateChecker.onReleasesLoaded  = _onReleasesLoaded;
            _updateChecker.onUpdateAvailable = _onUpdateAvailable;
            _updateChecker.onFetchFailed     = _onFetchFailed;
        }

        // -----------------------------------------------------------------------
        // Lifecycle

        /**
         * Add the version label and update badge to the stage.
         * Also triggers auto-show changelog and fires the GitHub fetch (once per session).
         */
        public function show(stage:Stage, version:String, apworldVersion:String):void {
            if (_isShowing) return;

            // Read persisted config to decide whether to auto-show the changelog.
            var config:Object = _fileHandler.loadModConfig();
            var lastSeen:String = (config != null && config.lastSeenVersion != null)
                ? String(config.lastSeenVersion) : null;
            var shouldAutoShow:Boolean = (lastSeen == null || lastSeen != version);

            // Load cached releases so the changelog can open instantly.
            if (config != null && config.cachedReleasesJson != null) {
                try {
                    var cached:Array = JSON.parse(String(config.cachedReleasesJson)) as Array;
                    if (cached != null && cached.length > 0) _cachedReleases = cached;
                } catch (e:Error) {
                    _logger.log(_modName, "MainMenuUI.show: failed to parse cached releases — " + e.message);
                }
            }

            // Version label — bottom-left corner.
            var labelFmt:TextFormat = new TextFormat("_sans", 12, 0xBBAADD);
            _versionLabel = new TextField();
            _versionLabel.defaultTextFormat = labelFmt;
            _versionLabel.selectable   = false;
            _versionLabel.mouseEnabled = false;
            _versionLabel.autoSize     = TextFieldAutoSize.LEFT;
            _versionLabel.text         = "Mod v" + version + "  |  apworld v" + apworldVersion;
            _versionLabel.x = 10;
            _versionLabel.y = stage.stageHeight - 48;
            stage.addChild(_versionLabel);

            // Update badge — to the right of the label, hidden until an update is found.
            _updateBadge = _makeUpdateBadge();
            _updateBadge.x = 10 + _versionLabel.textWidth + 12;
            _updateBadge.y = stage.stageHeight - 50;
            _updateBadge.visible = false;
            _updateBadge.addEventListener(MouseEvent.CLICK, _onBadgeClick, false, 0, true);
            stage.addChild(_updateBadge);

            _isShowing = true;

            // Auto-show changelog when the version has changed.
            if (shouldAutoShow) {
                openChangelog();
                _updateLastSeenVersion(version);
            }

            // Fire one GitHub fetch per session.
            if (!_fetchDone && _updateChecker != null) {
                _updateChecker.fetchReleases(version);
                _fetchDone = true;
            }
        }

        /**
         * Remove all main-menu elements from the stage.
         * Safe to call even if show() was never called.
         */
        public function hide():void {
            if (_versionLabel != null && _versionLabel.parent != null) {
                _versionLabel.parent.removeChild(_versionLabel);
            }
            _versionLabel = null;

            if (_updateBadge != null) {
                _updateBadge.removeEventListener(MouseEvent.CLICK, _onBadgeClick);
                if (_updateBadge.parent != null) _updateBadge.parent.removeChild(_updateBadge);
            }
            _updateBadge = null;

            if (_modButtons != null) _modButtons.removeFromMainMenu();
            if (_scrChangelog != null) _scrChangelog.dismiss();

            _isShowing = false;
        }

        /**
         * Call every frame while on the main menu.
         * Drives ModButtons to keep the changelog button positioned correctly,
         * and ticks the changelog panel's scroll animation if it is open.
         */
        public function onFrame():void {
            if (_modButtons != null) _modButtons.onMainMenuFrame();
            if (_scrChangelog != null && _scrChangelog.isShowing) {
                _scrChangelog.doEnterFrame();
            }
        }

        /**
         * Open (or refresh) the changelog panel. Only valid while showing.
         */
        public function openChangelog():void {
            if (_scrChangelog == null) _scrChangelog = new ScrChangelog();
            var releases:Array = (_cachedReleases != null && _cachedReleases.length > 0)
                ? _cachedReleases
                : [{ tag: "", name: "Could not reach GitHub", date: "",
                     body: "Release notes are unavailable.\nPlease check your internet connection." }];
            _scrChangelog.populate(releases);
            _scrChangelog.show();
        }

        /**
         * Dispose of long-lived resources. Call from ArchipelagoMod.unload().
         */
        public function dispose():void {
            hide();
            if (_updateChecker != null) {
                _updateChecker.dispose();
                _updateChecker = null;
            }
            if (_scrChangelog != null) {
                _scrChangelog.dismiss();
                _scrChangelog = null;
            }
        }

        // -----------------------------------------------------------------------
        // UpdateChecker callbacks

        private function _onReleasesLoaded(releases:Array):void {
            _cachedReleases = releases;
            // Persist so it's available without a network request next time.
            var config:Object = _fileHandler.loadModConfig();
            if (config == null) config = {};
            config.cachedReleasesJson = JSON.stringify(releases);
            _fileHandler.saveModConfig(config);
            // Refresh changelog if it's currently open.
            if (_scrChangelog != null && _scrChangelog.isShowing) {
                _scrChangelog.populate(releases);
                _scrChangelog.show();
            }
        }

        private function _onUpdateAvailable(latestTag:String):void {
            _logger.log(_modName, "MainMenuUI: update available — " + latestTag);
            if (_updateBadge != null) _updateBadge.visible = true;
        }

        private function _onFetchFailed():void {
            _logger.log(_modName, "MainMenuUI: GitHub release fetch failed — using cached/fallback data");
        }

        private function _onBadgeClick(e:MouseEvent):void {
            openChangelog();
        }

        // -----------------------------------------------------------------------
        // Private helpers

        private function _updateLastSeenVersion(version:String):void {
            var config:Object = _fileHandler.loadModConfig();
            if (config == null) config = {};
            config.lastSeenVersion = version;
            _fileHandler.saveModConfig(config);
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
    }
}
