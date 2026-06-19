package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Stops the game from unlocking achievements on the player's Steam account
     * while an Archipelago session is active.
     *
     * GCFW funnels every Steam achievement unlock through
     * Main.steamworks.setAchievement(...), reached via two paths that are BOTH
     * guarded by GV.main.isSteamworksInitiated:
     *   - IngameEnding.prepareDropIcons (battle end): pushes each earned
     *     achievement onto GV.selectorCore.achisToSendToSteam, later flushed to
     *     Steam in SelectorCore.
     *   - PnlAchievements.setAchiLockStatusesOnLoad: re-syncs every already
     *     gained achievement to Steam whenever a save loads (LoaderSaver).
     *
     * Earning an achievement during an Archipelago run should NOT touch the
     * player's Steam account — AP tracks and grants achievements itself.
     * Forcing isSteamworksInitiated to false makes both guards skip the Steam
     * send. That flag is otherwise only read by Main's shutdown dispose(), so
     * leaving it false for the session is harmless (the OS reclaims the ANE on
     * exit). The Steam overlay is installed unconditionally (Main's
     * addOverlayWorkaround) and is unaffected.
     *
     * suppress() runs from _activateApMode(), which the ModeSelectorInterceptor
     * guarantees fires BEFORE the vanilla slot-load — so the flag is already
     * false when setAchiLockStatusesOnLoad runs for the AP save. restore() puts
     * the original state back on _deactivateApMode() so a standalone/vanilla
     * slot loaded afterwards earns Steam achievements normally.
     */
    public class SteamAchievementSuppressor {

        private var _logger:Logger;
        private var _modName:String;

        // Captured once, the first time suppress() sees a valid GV.main, so
        // restore() can put the game's real init state back. On non-Steam
        // builds (init failed) this stays false and both calls are no-ops.
        private var _captured:Boolean          = false;
        private var _originalInitiated:Boolean = false;
        private var _loggedSuppress:Boolean    = false;

        public function SteamAchievementSuppressor(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        /** Force Steam achievement sends off for the Archipelago session.
         *  Idempotent — safe to call more than once. */
        public function suppress():void {
            try {
                if (GV.main == null)
                    return;
                if (!_captured) {
                    _originalInitiated = GV.main.isSteamworksInitiated;
                    _captured = true;
                }
                if (GV.main.isSteamworksInitiated) {
                    GV.main.isSteamworksInitiated = false;
                    if (!_loggedSuppress) {
                        _logger.log(_modName,
                            "SteamAchievementSuppressor: Steam achievement sends disabled for the Archipelago session");
                        _loggedSuppress = true;
                    }
                }
            } catch (err:Error) {
                _logger.log(_modName,
                    "SteamAchievementSuppressor.suppress ERROR: " + err.message);
            }
        }

        /** Restore the game's original Steam init state so a standalone or
         *  vanilla save loaded later earns Steam achievements normally. */
        public function restore():void {
            try {
                if (GV.main == null || !_captured)
                    return;
                if (GV.main.isSteamworksInitiated != _originalInitiated) {
                    GV.main.isSteamworksInitiated = _originalInitiated;
                    _logger.log(_modName,
                        "SteamAchievementSuppressor: restored Steam init state to " + _originalInitiated);
                }
                _loggedSuppress = false;
            } catch (err:Error) {
                _logger.log(_modName,
                    "SteamAchievementSuppressor.restore ERROR: " + err.message);
            }
        }
    }
}
