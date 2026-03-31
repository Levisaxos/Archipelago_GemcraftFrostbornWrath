package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Startup patch: moves all wizard stashes from Endurance mode to Journey mode.
     *
     * In the vanilla game, roughly half of the wizard stashes are placed in Endurance
     * mode data (stageDatasE).  This patch moves every such stash into the Journey
     * data (stageDatasJ) and updates GV.wizStashesInModes so the selector shows the
     * correct mode icon.
     *
     * Call apply() once from ArchipelagoMod.bind(), after GV.stageCollection is ready.
     *
     * Future: stash-restriction logic (require specific gem type / battle trait / spell
     * to damage a stash) will also live in this file.
     */
    public class WizStashes {

        public static function apply(logger:Logger, modName:String):void {
            try {
                if (GV.stageCollection == null) {
                    logger.log(modName, "WizStashes.apply: stageCollection not ready");
                    return;
                }
                var moved:int = 0;
                var n:int = GV.stageCollection.stageMetas.length;
                for (var i:int = 0; i < n; i++) {
                    var jData:* = GV.stageCollection.stageDatasJ[i];
                    var eData:* = GV.stageCollection.stageDatasE[i];
                    if (jData == null || eData == null) continue;

                    var wizIdx:int = -1;
                    for (var j:int = 0; j < eData.buildings.length; j++) {
                        if (String(eData.buildings[j]).indexOf("WIZSTASH") != -1) {
                            wizIdx = j;
                            break;
                        }
                    }
                    if (wizIdx == -1) continue;

                    var entry:String = eData.buildings.splice(wizIdx, 1)[0];
                    jData.buildings.push(entry);
                    if (GV.wizStashesInModes != null && i < GV.wizStashesInModes.length) {
                        GV.wizStashesInModes[i] = 0; // BattleMode.JOURNEY
                    }
                    moved++;
                }
                logger.log(modName, "WizStashes.apply: moved " + moved + " wizard stashes to Journey mode");
            } catch (err:Error) {
                logger.log(modName, "WizStashes.apply ERROR: " + err.message + "\n" + err.getStackTrace());
            }
        }
    }
}
