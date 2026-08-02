package update {
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;

    import Bezel.Logger;

    /**
     * Fetches the GitHub releases list for this mod, parses it, compares the
     * latest tag against the running version, and fires callbacks.
     *
     * Usage:
     *   var checker:UpdateChecker = new UpdateChecker(logger, modName);
     *   checker.onReleasesLoaded  = function(releases:Array):void { ... };
     *   checker.onUpdateAvailable = function(latestTag:String):void { ... };
     *   checker.onFetchFailed     = function():void { ... };
     *   checker.fetchReleases("0.0.2");
     */
    public class UpdateChecker {

        private static const RELEASES_URL:String =
            "https://api.github.com/repos/Levisaxos/Archipelago_GemcraftFrostbornWrath/releases";

        private var _logger:Logger;
        private var _modName:String;
        private var _loader:URLLoader;
        private var _currentVersion:String;

        /** Called with a normalized Array of {tag, name, body, date, breaking} Objects on success. */
        public var onReleasesLoaded:Function;
        /**
         * Called when a newer version is detected, as
         *     onUpdateAvailable(latestTag:String, breakingSinceCurrent:Boolean)
         * `breakingSinceCurrent` is true when ANY release newer than the running
         * version is flagged breaking — not just the latest. That's the question
         * a player with a running async actually needs answered: "can I update
         * without breaking my seed?" Skipping a breaking 1.1.0 by jumping
         * straight to 1.2.0 still breaks it, so the whole range is checked.
         */
        public var onUpdateAvailable:Function;
        /** Called when the network request fails. */
        public var onFetchFailed:Function;

        public function UpdateChecker(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        // -----------------------------------------------------------------------
        // Public API

        /**
         * Fire a GET request to the GitHub releases API.
         * Callbacks are invoked asynchronously when the response arrives.
         * @param currentVersion  The running mod version (e.g. "0.0.2") for
         *                        update comparison.
         */
        public function fetchReleases(currentVersion:String):void {
            _currentVersion = currentVersion;

            dispose(); // cancel any previous in-flight request

            _loader = new URLLoader();
            _loader.addEventListener(Event.COMPLETE,                  onComplete,       false, 0, true);
            _loader.addEventListener(IOErrorEvent.IO_ERROR,           onError,          false, 0, true);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);

            try {
                _loader.load(new URLRequest(RELEASES_URL));
                _logger.log(_modName, "UpdateChecker: fetching releases from GitHub…");
            } catch (err:Error) {
                _logger.log(_modName, "UpdateChecker: load() threw — " + err.message);
                if (onFetchFailed != null) onFetchFailed();
            }
        }

        /** Remove event listeners and drop the loader reference. */
        public function dispose():void {
            if (_loader != null) {
                _loader.removeEventListener(Event.COMPLETE,                  onComplete);
                _loader.removeEventListener(IOErrorEvent.IO_ERROR,           onError);
                _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
                try { _loader.close(); } catch (e:Error) {}
                _loader = null;
            }
        }

        // -----------------------------------------------------------------------
        // Event handlers

        private function onComplete(e:Event):void {
            var raw:String = URLLoader(e.target).data as String;
            dispose();

            var parsed:Array;
            try {
                parsed = JSON.parse(raw) as Array;
            } catch (err:Error) {
                _logger.log(_modName, "UpdateChecker: JSON parse failed — " + err.message);
                if (onFetchFailed != null) onFetchFailed();
                return;
            }

            if (parsed == null || parsed.length == 0) {
                _logger.log(_modName, "UpdateChecker: empty releases array");
                if (onFetchFailed != null) onFetchFailed();
                return;
            }

            // Normalize each GitHub release object into {tag,name,body,date,breaking}.
            // NOTE: `breaking` is parsed from the RAW body, before stripMarkdown
            // flattens the headings it looks for.
            var releases:Array = [];
            for each (var item:Object in parsed) {
                var tag:String  = String(item.tag_name  || "");
                var name:String = String(item.name      || tag);
                var rawBody:String = String(item.body || "");
                var body:String = stripMarkdown(rawBody);
                var date:String = String(item.published_at || "");
                if (date.length >= 10) date = date.substr(0, 10); // "YYYY-MM-DD"
                releases.push({ tag: tag, name: name, body: body, date: date,
                                breaking: isBreakingRelease(rawBody) });
            }

            _logger.log(_modName, "UpdateChecker: loaded " + releases.length + " release(s)");

            if (onReleasesLoaded != null) onReleasesLoaded(releases);

            // Compare latest tag with current version.
            if (releases.length > 0) {
                var latestTag:String = releases[0].tag;
                if (compareVersions(latestTag, _currentVersion) > 0) {
                    // Any breaking release in (currentVersion .. latest] means the
                    // player cannot update mid-async without breaking their seed.
                    var breakingSince:Boolean = false;
                    for each (var rel:Object in releases) {
                        if (rel.breaking && compareVersions(String(rel.tag), _currentVersion) > 0) {
                            breakingSince = true;
                            break;
                        }
                    }
                    _logger.log(_modName, "UpdateChecker: update available — " + latestTag
                        + (breakingSince ? " (BREAKING since " + _currentVersion + ")" : ""));
                    if (onUpdateAvailable != null) onUpdateAvailable(latestTag, breakingSince);
                }
            }
        }

        private function onError(e:IOErrorEvent):void {
            dispose();
            _logger.log(_modName, "UpdateChecker: IO error — " + e.text);
            if (onFetchFailed != null) onFetchFailed();
        }

        private function onSecurityError(e:SecurityErrorEvent):void {
            dispose();
            _logger.log(_modName, "UpdateChecker: security error — " + e.text);
            if (onFetchFailed != null) onFetchFailed();
        }

        // -----------------------------------------------------------------------
        // Static helpers

        /**
         * Compare two version strings (with optional leading "v" and optional
         * "-suffix" tag — e.g. "v0.0.5.1-logic-hotfix").
         *
         * Returns  1 if a > b (a is newer),
         *          0 if equal,
         *         -1 if a < b (a is older).
         *
         * Comparison is numeric per dot-segment over the longer of the two
         * versions (shorter is right-padded with zeros), so "0.0.5.1" is
         * correctly newer than "0.0.5". Suffix tags after the first "-" are
         * stripped before splitting, so "v0.0.5-alpha" parses as "0.0.5" and
         * doesn't get poisoned by AS3's int("5-alpha") = 0 behaviour.
         */
        public static function compareVersions(a:String, b:String):int {
            a = _normalizeVersionForCompare(a);
            b = _normalizeVersionForCompare(b);
            var aParts:Array = a.split(".");
            var bParts:Array = b.split(".");
            var len:int = (aParts.length > bParts.length)
                ? aParts.length : bParts.length;
            while (aParts.length < len) aParts.push("0");
            while (bParts.length < len) bParts.push("0");
            for (var i:int = 0; i < len; i++) {
                var av:int = int(aParts[i]);
                var bv:int = int(bParts[i]);
                if (av > bv) return  1;
                if (av < bv) return -1;
            }
            return 0;
        }

        /** Strip leading "v" / "V" and any "-suffix" so "v0.0.5.1-logic-hotfix"
         *  reduces to "0.0.5.1" before dot-splitting. */
        private static function _normalizeVersionForCompare(v:String):String {
            v = v.replace(/^v/i, "");
            var dashIdx:int = v.indexOf("-");
            if (dashIdx >= 0)
                v = v.substr(0, dashIdx);
            return v;
        }

        /**
         * Does this release's notes flag it as a BREAKING change — i.e. updating
         * to it invalidates a seed generated with an older apworld, so a player
         * mid-async must finish first?
         *
         * Authored in the GitHub release body using either form:
         *
         *     ## Breaking change            (a heading — matches the notes template)
         *     ## ⚠️ Breaking changes
         *     [BREAKING]                    (standalone marker, anywhere)
         *
         * Matching is case-insensitive and deliberately narrow: it requires a
         * heading that STARTS with "breaking", or the explicit [BREAKING] token.
         * Prose like "this does not contain breaking changes" must NOT trip it,
         * which is why we don't just search for the word anywhere in the body.
         */
        public static function isBreakingRelease(rawBody:String):Boolean {
            if (rawBody == null || rawBody.length == 0) return false;
            // Explicit token anywhere: [BREAKING] / [breaking change]
            if (/\[\s*breaking[^\]]*\]/i.test(rawBody)) return true;
            // Markdown heading whose text begins with "breaking" (allowing a
            // leading emoji/symbol such as ⚠️ before the word).
            if (/^\s{0,3}#{1,6}\s*[^\w\n]*breaking/im.test(rawBody)) return true;
            return false;
        }

        /**
         * Strip common Markdown syntax so the text reads cleanly in a plain TextField.
         * The transformation is intentionally minimal — keep content, remove formatting.
         */
        public static function stripMarkdown(raw:String):String {
            var s:String = raw;

            // Normalise line endings.
            s = s.replace(/\r\n/g, "\n");
            s = s.replace(/\r/g,   "\n");

            // Fenced code blocks  (``` ... ```)
            s = s.replace(/```[\s\S]*?```/g, "");

            // ATX-style headers (## Heading) — keep the heading text.
            s = s.replace(/^#{1,6}\s+/mg, "");

            // Bold/italic  **x**, *x*, __x__, _x_
            s = s.replace(/\*\*([^*]+)\*\*/g, "$1");
            s = s.replace(/__([^_]+)__/g,     "$1");
            s = s.replace(/\*([^*]+)\*/g,     "$1");
            s = s.replace(/_([^_]+)_/g,       "$1");

            // Inline code  `x`
            s = s.replace(/`([^`]+)`/g, "$1");

            // Unordered list bullets  "- item" or "* item" → "  • item"
            s = s.replace(/^[ \t]*[-*]\s+/mg, "  \u2022 ");

            // Collapse 3+ consecutive blank lines to 2.
            s = s.replace(/\n{3,}/g, "\n\n");

            return s;
        }
    }
}
