package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.entity.WizardStash;
    import flash.geom.Rectangle;

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

        /**
         * Per-frame sweep: fully clear any wizard stash that was opened during the
         * current run. Vanilla's IngameDestroyer.openWizardStash only nulls out the
         * building matrices when the stash *started* opened (i.e. a second run in
         * Endurance). In our Journey-mode flow the player only ever opens each
         * stash once, so the opened chest lingers in buildingAreaMatrix /
         * buildingRegPtMatrix and gems continue targeting it. This replicates the
         * startedAsOpen branch's matrix cleanup for such stashes.
         */
        public static function tickClearOpened(logger:Logger, modName:String):void {
            try {
                var core:* = GV.ingameCore;
                if (core == null) return;
                if (core.hasOpenedWizardStash != true) return;

                var areaM:* = core.buildingAreaMatrix;
                var regM:*  = core.buildingRegPtMatrix;
                if (areaM == null || regM == null) return;

                var cleaned:int = 0;
                var seen:Object = {};
                for (var y:int = 0; y < areaM.length; y++) {
                    var row:* = areaM[y];
                    if (row == null) continue;
                    for (var x:int = 0; x < row.length; x++) {
                        var cell:* = row[x];
                        if (cell == null) continue;
                        if (!(cell is WizardStash)) continue;
                        var w:WizardStash = cell as WizardStash;
                        if (w.isDestroyed != true) continue;

                        var key:String = w.fieldX + "_" + w.fieldY;
                        if (seen[key] == true) continue;
                        seen[key] = true;

                        var fx:int = w.fieldX;
                        var fy:int = w.fieldY;

                        if (regM[fy] != null) regM[fy][fx] = null;
                        // Stash footprint is 3x2.
                        if (areaM[fy] != null) {
                            areaM[fy][fx]     = null;
                            areaM[fy][fx + 1] = null;
                            areaM[fy][fx + 2] = null;
                        }
                        if (areaM[fy + 1] != null) {
                            areaM[fy + 1][fx]     = null;
                            areaM[fy + 1][fx + 1] = null;
                            areaM[fy + 1][fx + 2] = null;
                        }

                        try {
                            if (core.cnt != null) {
                                if (core.cnt.bmpdTowerPlaceAvailMap != null) {
                                    core.cnt.bmpdTowerPlaceAvailMap.fillRect(new Rectangle(fx, fy, 3, 2), 0);
                                }
                                if (core.cnt.bmpdWallPlaceAvailMap != null) {
                                    core.cnt.bmpdWallPlaceAvailMap.fillRect(new Rectangle(fx, fy, 3, 2), 0);
                                }
                            }
                        } catch (e1:Error) {}

                        cleaned++;
                    }
                }

                if (cleaned > 0) {
                    try { core.renderer2.redrawHighBuildings(); } catch (e2:Error) {}
                    // Leave core.hasOpenedWizardStash alone — vanilla may read it
                    // for stats/achievements. After clearing the matrix cells, the
                    // next sweep will be a cheap no-op (nothing isDestroyed left).
                    logger.log(modName, "WizStashes.tickClearOpened: cleared " + cleaned + " opened stash tile(s)");
                }
            } catch (err:Error) {
                logger.log(modName, "WizStashes.tickClearOpened ERROR: " + err.message);
            }
        }
    }
}
