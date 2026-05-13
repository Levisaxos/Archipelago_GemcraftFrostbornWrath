package patch {
    import flash.filesystem.File;
    import com.giab.games.gcfw.GV;
    import Bezel.Logger;

    /**
     * Fixes a vanilla GCFW bug: deleting a save slot in-game truncates only
     * the primary file at applicationStorageDirectory. The game also keeps
     * two backup copies under Documents\GCFW-backup1 and
     * Documents\GCFW-backup2\folder<N>. On startup, LoaderSaver.createSaveDataFiles
     * sees the empty primary and copies backup1 over it — the deleted slot
     * comes back.
     *
     * This patch watches GV.loaderSaver.slotsLocal while the LOADGAME screen
     * is active. When a slot transitions populated → null (player just
     * confirmed delete with D), it RENAMES the corresponding backup files to
     * saveslotN.dat.deleted-<timestamp>. Vanilla's startup restore checks for
     * the exact filename so it won't find them, but the data is still on
     * disk if the user wants to recover (just rename back while game is closed).
     */
    public class SaveSlotDeleteFix {

        private var _logger:Logger;
        private var _modName:String;
        private var _prevPopulated:Vector.<Boolean> = new Vector.<Boolean>(8, true);
        private var _initialized:Boolean = false;

        public function SaveSlotDeleteFix(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        public function onLoadGameFrame():void {
            if (GV.loaderSaver == null || GV.loaderSaver.slotsLocal == null)
                return;

            // First time we see slotsLocal, snapshot it without acting —
            // pre-existing nulls aren't "just-deleted".
            if (!_initialized) {
                for (var k:int = 0; k < 8; k++) {
                    _prevPopulated[k] = GV.loaderSaver.slotsLocal[k] != null;
                }
                _initialized = true;
                return;
            }

            for (var i:int = 0; i < 8; i++) {
                var nowPopulated:Boolean = GV.loaderSaver.slotsLocal[i] != null;
                if (_prevPopulated[i] && !nowPopulated) {
                    _quarantineBackups(i + 1);
                }
                _prevPopulated[i] = nowPopulated;
            }
        }

        private function _quarantineBackups(slotNum:int):void {
            var stamp:String   = String(new Date().getTime());
            var name:String    = "saveslot" + slotNum + ".dat";
            var newName:String = name + ".deleted-" + stamp;

            _renameIfExists(
                File.documentsDirectory.resolvePath("GCFW-backup1/" + name),
                newName);

            var b2:File = File.documentsDirectory.resolvePath("GCFW-backup2");
            if (b2.exists && b2.isDirectory) {
                for each (var sub:File in b2.getDirectoryListing()) {
                    if (sub.isDirectory) {
                        _renameIfExists(sub.resolvePath(name), newName);
                    }
                }
            }
        }

        private function _renameIfExists(src:File, newName:String):void {
            try {
                if (!src.exists)
                    return;
                var dst:File = src.parent.resolvePath(newName);
                src.moveTo(dst, true);
                _logger.log(_modName, "SaveSlotDeleteFix: quarantined "
                    + src.nativePath + " -> " + dst.name);
            } catch (e:Error) {
                _logger.log(_modName,
                    "SaveSlotDeleteFix: rename failed for "
                    + src.nativePath + ": " + e.message);
            }
        }
    }
}
