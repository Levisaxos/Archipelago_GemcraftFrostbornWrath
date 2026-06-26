package ui {
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;

    import com.giab.games.gcfw.GV;

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
        private var _scrCredits:ScrCredits;

        private static const FONT:String           = "Celtic Garamond for GemCraft";
        private static const COL_VERSION:uint      = 0xD0D0D0;
        private static const COL_DISCLAIMER:uint   = 0xA0A0A0;
        private static const COL_FAN_PROJECT:uint  = 0xFFFFFF;
        // Game logical resolution — GV.main is letterbox-scaled to fit the window.
        private static const STAGE_W:Number        = 1920;
        private static const STAGE_H:Number        = 1080;
        private static const DISCLAIMER_URL:String =
            "https://github.com/Levisaxos/Archipelago_GemcraftFrostbornWrath/blob/main/docs/disclaimer.md";

        private var _versionLabel:TextField;
        private var _disclaimerLabel:TextField;
        private var _fanProjectLabel:TextField;
        private var _updateBadge:Sprite;
        private var _isShowing:Boolean       = false;
        private var _fetchDone:Boolean       = false;
        private var _cachedReleases:Array    = null;
        private var _latestUpdateTag:String  = null;

        private static const RELEASE_TAG_URL_PREFIX:String =
            "https://github.com/Levisaxos/Archipelago_GemcraftFrostbornWrath/releases/tag/";

        // -----------------------------------------------------------------------

        public function get isShowing():Boolean { return _isShowing; }

        public function MainMenuUI(logger:Logger, modName:String,
                                   fileHandler:FileHandler, modButtons:ModButtons) {
            _logger      = logger;
            _modName     = modName;
            _fileHandler = fileHandler;
            _modButtons  = modButtons;

            _scrChangelog = new ScrChangelog();
            _scrCredits   = new ScrCredits();

            _updateChecker = new UpdateChecker(_logger, _modName);
            _updateChecker.onReleasesLoaded  = _onReleasesLoaded;
            _updateChecker.onUpdateAvailable = _onUpdateAvailable;
            _updateChecker.onFetchFailed     = _onFetchFailed;
        }

        // -----------------------------------------------------------------------
        // Lifecycle

        /**
         * Add the version label, disclaimer, and update badge to GV.main.
         * Also triggers auto-show changelog and fires the GitHub fetch (once per session).
         */
        public function show(version:String, apworldVersion:String, releaseChannel:String):void {
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

            // Version label — bottom-center, styled like the in-game credits.
            // Parented to GV.main (game content root) so it sits on the same
            // layer as the GiaB / BezelMod copyright text. Anything added later
            // to GV.main (e.g. the changelog panel) will cover these labels.
            // Coordinates are in GV.main's 1920x1080 logical space.
            var labelFmt:TextFormat = new TextFormat(FONT, 14, COL_VERSION);
            _versionLabel = new TextField();
            _versionLabel.defaultTextFormat = labelFmt;
            _versionLabel.embedFonts   = false;
            _versionLabel.selectable   = false;
            _versionLabel.mouseEnabled = false;
            _versionLabel.autoSize     = TextFieldAutoSize.LEFT;
            var label:String = "Archipelago mod v" + version + " | apworld v" + apworldVersion;
            if (releaseChannel != null && releaseChannel.length > 0) {
                label += " | " + releaseChannel;
            }
            _versionLabel.text = label + " ";
            _versionLabel.y = STAGE_H - 48;

            var disclaimerFmt:TextFormat = new TextFormat(FONT, 14, COL_DISCLAIMER, false, true, true);
            _disclaimerLabel = new TextField();
            _disclaimerLabel.defaultTextFormat = disclaimerFmt;
            _disclaimerLabel.embedFonts   = false;
            _disclaimerLabel.selectable   = false;
            _disclaimerLabel.mouseEnabled = true;
            _disclaimerLabel.autoSize     = TextFieldAutoSize.LEFT;
            _disclaimerLabel.text         = "(disclaimer)";
            _disclaimerLabel.y = STAGE_H - 48;
            _disclaimerLabel.addEventListener(MouseEvent.CLICK, _onDisclaimerClick, false, 0, true);

            // Center the version + (disclaimer) pair as one combined block.
            var combinedWidth:Number = _versionLabel.width + _disclaimerLabel.width;
            var startX:Number = (STAGE_W - combinedWidth) * 0.5;
            _versionLabel.x    = startX;
            _disclaimerLabel.x = startX + _versionLabel.width;
            GV.main.addChild(_versionLabel);
            GV.main.addChild(_disclaimerLabel);

            // Update badge — to the right of the (disclaimer) link, hidden until an update is found.
            _updateBadge = _makeUpdateBadge();
            _updateBadge.x = _disclaimerLabel.x + _disclaimerLabel.width + 12;
            _updateBadge.y = STAGE_H - 50;
            _updateBadge.visible = false;
            _updateBadge.addEventListener(MouseEvent.CLICK, _onBadgeClick, false, 0, true);
            GV.main.addChild(_updateBadge);

            // Fan-project disclaimer — line below, white, non-interactive.
            var fanFmt:TextFormat = new TextFormat(FONT, 12, COL_FAN_PROJECT);
            _fanProjectLabel = new TextField();
            _fanProjectLabel.defaultTextFormat = fanFmt;
            _fanProjectLabel.embedFonts   = false;
            _fanProjectLabel.selectable   = false;
            _fanProjectLabel.mouseEnabled = false;
            _fanProjectLabel.autoSize     = TextFieldAutoSize.LEFT;
            _fanProjectLabel.text         = "fan project, not affiliated with Game in a Bottle";
            _fanProjectLabel.x = (STAGE_W - _fanProjectLabel.width) * 0.5;
            _fanProjectLabel.y = STAGE_H - 28;
            GV.main.addChild(_fanProjectLabel);

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

            if (_disclaimerLabel != null) {
                _disclaimerLabel.removeEventListener(MouseEvent.CLICK, _onDisclaimerClick);
                if (_disclaimerLabel.parent != null) {
                    _disclaimerLabel.parent.removeChild(_disclaimerLabel);
                }
            }
            _disclaimerLabel = null;

            if (_fanProjectLabel != null && _fanProjectLabel.parent != null) {
                _fanProjectLabel.parent.removeChild(_fanProjectLabel);
            }
            _fanProjectLabel = null;

            if (_updateBadge != null) {
                _updateBadge.removeEventListener(MouseEvent.CLICK, _onBadgeClick);
                if (_updateBadge.parent != null) _updateBadge.parent.removeChild(_updateBadge);
            }
            _updateBadge = null;

            if (_modButtons != null) _modButtons.removeFromMainMenu();
            if (_scrChangelog != null) _scrChangelog.dismiss();
            if (_scrCredits != null) _scrCredits.dismiss();

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
            if (_scrCredits != null && _scrCredits.isShowing) {
                _scrCredits.doEnterFrame();
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
            var updateUrl:String = null;
            if (_latestUpdateTag != null && _latestUpdateTag.length > 0) {
                updateUrl = RELEASE_TAG_URL_PREFIX + _latestUpdateTag;
            }
            _scrChangelog.populate(releases, updateUrl);
            _scrChangelog.show();
        }

        /**
         * Open (or refresh) the credits panel. Only valid while showing.
         */
        public function openCredits():void {
            if (_scrCredits == null) _scrCredits = new ScrCredits();
            _scrCredits.populate(CreditsData.getSections());
            _scrCredits.show();
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
            if (_scrCredits != null) {
                _scrCredits.dismiss();
                _scrCredits = null;
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
                openChangelog();
            }
        }

        private function _onUpdateAvailable(latestTag:String):void {
            _logger.log(_modName, "MainMenuUI: update available — " + latestTag);
            _latestUpdateTag = latestTag;
            if (_updateBadge != null) _updateBadge.visible = true;
            // Refresh the changelog if it's already open so the download button shows up.
            if (_scrChangelog != null && _scrChangelog.isShowing) {
                openChangelog();
            }
        }

        private function _onFetchFailed():void {
            _logger.log(_modName, "MainMenuUI: GitHub release fetch failed — using cached/fallback data");
        }

        private function _onBadgeClick(e:MouseEvent):void {
            openChangelog();
        }

        private function _onDisclaimerClick(e:MouseEvent):void {
            navigateToURL(new URLRequest(DISCLAIMER_URL), "_blank");
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
