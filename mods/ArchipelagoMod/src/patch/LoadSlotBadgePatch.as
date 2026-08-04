package patch {
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;

    import com.giab.games.gcfw.GV;

    import Bezel.Logger;

    import save.FileHandler;

    /**
     * Rewrites the LOADGAME slot badges for Archipelago slots so a player
     * running several asyncs can tell them apart at a glance.
     *
     * A vanilla Frostborn slot badge has four stacked text fields:
     *     Frostborn Wizard Level   (tfLblLevel)
     *              8,048           (tfLevel)
     *              122             (tfFields)
     *          Fields explored     (tfLblFields)
     *
     * For a slot that carries AP credentials (host + slot name in slot_N.json)
     * this patch relabels those same four fields, in place, to:
     *     host:port                (tfLblLevel)
     *     slotName                 (tfLevel)
     *     Wizard Level 8,048       (tfFields)
     *     Fields explored: 122     (tfLblFields)
     *
     * Nothing is moved, hidden, or recoloured — only the text changes — so the
     * layout the game designed is preserved. Only AP slots are touched; non-AP
     * slots (vanilla / standalone / Chilling / Iron) are left as the game draws
     * them.
     *
     * LoaderSaver.renderMcLoadGame() repopulates the fields whenever the screen
     * (re)appears, so this runs every frame while on LOADGAME. The transform is
     * applied once per native render, guarded by the ":" marker the Fields line
     * gains once rewritten; a re-render clears the marker and it re-applies.
     * Per-slot server/username are cached on screen entry (refresh()) to avoid
     * reading eight JSON files every frame.
     */
    public class LoadSlotBadgePatch {

        private var _logger:Logger;
        private var _modName:String;
        private var _fileHandler:FileHandler;

        /** Cached "host:port" per slot (index 0..7). null = not an AP slot. */
        private var _server:Vector.<String> = new Vector.<String>(8, true);
        /** Cached AP slot (user) name per slot (index 0..7). */
        private var _user:Vector.<String>   = new Vector.<String>(8, true);

        public function LoadSlotBadgePatch(logger:Logger, modName:String, fileHandler:FileHandler) {
            _logger      = logger;
            _modName     = modName;
            _fileHandler = fileHandler;
        }

        /**
         * Reload the per-slot AP identifiers from disk. Call once when the
         * LOADGAME screen is entered.
         */
        public function refresh():void {
            for (var i:int = 0; i < 8; i++) {
                _server[i] = null;
                _user[i]   = null;

                var data:Object = _fileHandler.loadSlotData(i + 1);
                if (data == null) continue;
                if (data.standalone === true) continue; // router treats as non-AP

                var host:String = (data.host != null) ? String(data.host) : "";
                var slot:String = (data.slot != null) ? String(data.slot) : "";
                if (host.length == 0 || slot.length == 0) continue; // not an AP slot

                var server:String = host;
                if (data.port != null && String(data.port).length > 0) {
                    server += ":" + data.port;
                }
                _server[i] = server;
                _user[i]   = slot;
            }
        }

        /**
         * Re-apply the custom badge labels. Call every frame while on LOADGAME.
         */
        public function onLoadGameFrame():void {
            var lg:* = (GV.main != null && GV.main.cntScreens != null)
                ? GV.main.cntScreens.mcLoadGame : null;
            if (lg == null) return;

            for (var i:int = 0; i < 8; i++) {
                if (_server[i] == null) continue; // non-AP slot — leave native display

                var slotMc:* = lg["mcSlotL" + (i + 1)];
                if (slotMc == null) continue;

                // Empty slot? Native hides the level label — nothing to restyle.
                var tfLblLevel:TextField = slotMc.tfLblLevel as TextField;
                if (tfLblLevel == null || !tfLblLevel.visible) continue;

                _applyToSlot(slotMc, _server[i], _user[i]);
            }
        }

        private function _applyToSlot(slotMc:*, server:String, user:String):void {
            var tfLblLevel:TextField  = slotMc.tfLblLevel  as TextField;
            var tfLevel:TextField     = slotMc.tfLevel     as TextField;
            var tfFields:TextField    = slotMc.tfFields    as TextField;
            var tfLblFields:TextField = slotMc.tfLblFields as TextField;
            if (tfLblLevel == null || tfLevel == null
                || tfFields == null || tfLblFields == null) return;

            // Transform only while the fields are in their native state. Once
            // rewritten, the Fields line carries a ":" that the native labels
            // never contain; a native re-render clears it and we re-apply.
            if (tfLblFields.text.indexOf(":") >= 0) return;

            // Capture the native values before overwriting the fields that hold
            // them (the level number lives in tfLevel, the count in tfFields).
            var levelStr:String  = tfLevel.text;      // e.g. "8,048"
            var countStr:String  = tfFields.text;     // e.g. "122"
            var fieldsLbl:String = tfLblFields.text;  // "Fields explored" / "Field explored"

            // Auto-size (centred) so long text isn't clipped by the box the game
            // sized for the shorter native label.
            tfLblLevel.autoSize  = TextFieldAutoSize.CENTER;
            tfLevel.autoSize     = TextFieldAutoSize.CENTER;
            tfFields.autoSize    = TextFieldAutoSize.CENTER;
            tfLblFields.autoSize = TextFieldAutoSize.CENTER;

            tfLblLevel.text  = server;                    // line 1: host:port
            tfLevel.text     = user;                      // line 2: slot (user) name
            tfFields.text    = "Wizard Level " + levelStr; // line 3: Wizard Level 8,048
            tfLblFields.text = fieldsLbl + ": " + countStr; // line 4: Fields explored: 122
        }
    }
}
