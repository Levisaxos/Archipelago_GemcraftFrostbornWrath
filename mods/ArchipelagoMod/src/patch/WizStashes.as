package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.entity.WizardStash;
    import data.AV;
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;

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
     * Per-frame in-level enforcement:
     *   - tickClearOpened()      — clean up matrix cells of opened stashes
     *   - tickEnforceStashLock() — shield-spike locked stashes (AP-side per-stage
     *                              gating) and overlay a padlock bitmap above each
     */
    public class WizStashes {

        // Per-level overlay container: live Sprite added to GV.ingameCore.cnt
        // holding one padlock Bitmap per locked stash. Reset when the stage
        // changes (different stageMeta.id) or when leaving INGAME.
        private static var _lockOverlay:Sprite = null;
        private static var _lockOverlayStageId:int = -1;

        // Original shield value per locked stash, captured the first frame we
        // see it. Restored when the unlock arrives so the stash becomes breakable
        // again. Keyed by WizardStash instance reference (weak-keyed Dictionary).
        private static var _originalShield:Dictionary = new Dictionary(true);

        // Stashes hidden from core.wizardStashes (the gem/tower targeting list),
        // and the stage they belong to. Restored when the unlock arrives.
        private static var _hiddenStashes:Array = [];
        private static var _hiddenStashesStageId:int = -1;

        // Shield value applied each frame to locked stashes. Re-applied every
        // frame so a manual bomb-spell that decrements shield by N per hit can't
        // ever drain it across frames. 1000 is high enough to absorb any plausible
        // burst of bombs in a single frame, and low enough to render sensibly
        // ("Shield: 1000") in the hover tooltip.
        private static const LOCK_SHIELD:Number = 1000;

        // Embedded copper padlock graphic (~64x64). Path is relative to this
        // .as file: src/patch/ → ../../resources/Padlock.png.
        [Embed(source='../../resources/Padlock.png')]
        private static const PadlockAsset:Class;

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

        /**
         * Per-frame: enforce per-stage Wizard Stash unlock gating.
         *
         * If the current stage's "Wizard Stash {strId} Unlock" item is not held:
         *   - Splice every (non-destroyed, non-startedAsOpen) stash out of
         *     core.wizardStashes — the array towers and AOE bomb impacts iterate
         *     to find targets (Tower.as:772, IngameController.as:527). Towers
         *     simply won't see the stash, no wasted shots / gem-targeting.
         *   - Set the stash's shield to 1000 each frame. The targeting-array
         *     removal handles the common case; the shield is belt-and-suspenders
         *     for the one bypass path: a manual gem-bomb spell cast directly on
         *     the stash, which reads buildingAreaMatrix instead of wizardStashes
         *     (IngameSpellCaster.as:627). 1000 is enough to absorb any plausible
         *     burst within a frame, and the per-frame refresh keeps it topped up.
         *   - Maintain a padlock-bitmap overlay above each locked stash so the
         *     player sees a copper padlock on top of it.
         *
         * Once the unlock arrives the overlay is torn down, hidden stashes are
         * pushed back into core.wizardStashes, original shield is restored, and
         * normal stash damage resumes.
         */
        public static function tickEnforceStashLock(logger:Logger, modName:String):void {
            try {
                var core:* = GV.ingameCore;
                if (core == null || core.stageMeta == null) {
                    _disposeLockOverlay();
                    return;
                }

                var strId:String = String(core.stageMeta.strId);
                var stageId:int  = int(core.stageMeta.id);
                var unlocked:Boolean = AV.sessionData != null && AV.sessionData.isStashUnlocked(strId);

                if (unlocked) {
                    // Unlock just arrived (or was already held) — restore any
                    // shields we spiked, push hidden stashes back to the
                    // targeting array, drop the padlock overlay.
                    _restoreSpikedShields(core);
                    _restoreHiddenStashes(core);
                    _disposeLockOverlay();
                    return;
                }

                // Stage changed (entered a new level). Vanilla rebuilt
                // core.wizardStashes from scratch, so our cache is stale —
                // forget it (the new stashes are about to be re-hidden below).
                if (_hiddenStashesStageId != -1 && _hiddenStashesStageId != stageId) {
                    _hiddenStashes.length = 0;
                    _hiddenStashesStageId = -1;
                }

                // Re-mount overlay container if stage changed (entered a new level).
                if (_lockOverlay != null && _lockOverlayStageId != stageId) {
                    _disposeLockOverlay();
                }

                var areaM:* = core.buildingAreaMatrix;
                if (areaM == null) return;

                // Splice locked stashes out of core.wizardStashes so towers and
                // AOE damage skip them. Iterate in reverse to make splicing safe.
                if (core.wizardStashes != null) {
                    var stashes:Array = core.wizardStashes as Array;
                    for (var hi:int = stashes.length - 1; hi >= 0; hi--) {
                        var hs:WizardStash = stashes[hi] as WizardStash;
                        if (hs == null || hs.isDestroyed || hs.startedAsOpen) continue;
                        stashes.splice(hi, 1);
                        _hiddenStashes.push(hs);
                    }
                    if (_hiddenStashes.length > 0) {
                        _hiddenStashesStageId = stageId;
                    }
                }

                // Walk the building matrix once: shield-spike locked stashes and
                // collect their (fieldX, fieldY) so we can overlay padlocks.
                var seen:Object = {};
                var stashCoords:Array = [];
                for (var y:int = 0; y < areaM.length; y++) {
                    var row:* = areaM[y];
                    if (row == null) continue;
                    for (var x:int = 0; x < row.length; x++) {
                        var cell:* = row[x];
                        if (cell == null || !(cell is WizardStash)) continue;
                        var w:WizardStash = cell as WizardStash;
                        if (w.isDestroyed || w.startedAsOpen) continue;

                        var key:String = w.fieldX + "_" + w.fieldY;
                        if (seen[key] == true) continue;
                        seen[key] = true;

                        // Cache original shield once, then spike to ~infinity.
                        // Vanilla damage paths bail when shield > 0, so HP never
                        // gets touched and openWizardStash() is never called.
                        if (_originalShield[w] === undefined) {
                            _originalShield[w] = w.shield.g();
                        }
                        w.shield.s(LOCK_SHIELD);

                        stashCoords.push({fx: w.fieldX, fy: w.fieldY});
                    }
                }

                if (stashCoords.length == 0) {
                    _disposeLockOverlay();
                    return;
                }

                // Lazily build the overlay container once per stage.
                if (_lockOverlay == null) {
                    _lockOverlay = new Sprite();
                    _lockOverlay.mouseEnabled = false;
                    _lockOverlay.mouseChildren = false;
                    // Match bmpOrbTreesBuildings's offset inside cnt (CntIngame
                    // sets this bitmap at x=50, y=8) so our cell-space coords
                    // line up with the rendered buildings layer.
                    _lockOverlay.x = 50;
                    _lockOverlay.y = 8;
                    _lockOverlayStageId = stageId;

                    for (var s:int = 0; s < stashCoords.length; s++) {
                        var c:Object = stashCoords[s];
                        var padlock:Bitmap = new PadlockAsset() as Bitmap;
                        if (padlock == null) continue;
                        padlock.smoothing = true;
                        // Native size, centered over the 3x2 stash footprint
                        // with a small offset (right + down) to land visually
                        // dead-center on the stone-block art.
                        // Stash center pixel: ((fx+1.5)*28, (fy+1)*28).
                        padlock.x = int((int(c.fx) + 1.5) * 28 - padlock.width  * 0.5) + 6;
                        padlock.y = int((int(c.fy) + 1)   * 28 - padlock.height * 0.5) + 6;
                        _lockOverlay.addChild(padlock);
                    }

                    try {
                        if (core.cnt != null) {
                            core.cnt.addChild(_lockOverlay);
                        }
                    } catch (eAttach:Error) {
                        logger.log(modName, "WizStashes.tickEnforceStashLock: addChild failed: " + eAttach.message);
                    }
                    logger.log(modName, "WizStashes: locked stash overlay attached for "
                        + strId + " (" + stashCoords.length + " stash(es))");
                }
            } catch (err:Error) {
                logger.log(modName, "WizStashes.tickEnforceStashLock ERROR: " + err.message);
            }
        }

        /** Remove the lock overlay container and forget which stage it belonged to. */
        private static function _disposeLockOverlay():void {
            if (_lockOverlay == null) return;
            try {
                if (_lockOverlay.parent != null) {
                    _lockOverlay.parent.removeChild(_lockOverlay);
                }
            } catch (e:Error) {}
            _lockOverlay = null;
            _lockOverlayStageId = -1;
        }

        /**
         * Push every cached hidden stash back into core.wizardStashes so towers
         * and AOE damage see them again. Called when the unlock arrives.
         */
        private static function _restoreHiddenStashes(core:*):void {
            if (core == null || core.wizardStashes == null) {
                _hiddenStashes.length = 0;
                _hiddenStashesStageId = -1;
                return;
            }
            for (var i:int = 0; i < _hiddenStashes.length; i++) {
                var hs:WizardStash = _hiddenStashes[i] as WizardStash;
                if (hs == null) continue;
                if ((core.wizardStashes as Array).indexOf(hs) < 0) {
                    (core.wizardStashes as Array).push(hs);
                }
            }
            _hiddenStashes.length = 0;
            _hiddenStashesStageId = -1;
        }

        /**
         * Walk the current level's building matrix and restore each stash's
         * original shield value (cached when we first spiked it). Called when
         * the unlock arrives so the player can break the stash normally.
         * The Dictionary is weak-keyed, so any stashes from previous levels
         * that have already been GC'd silently drop out.
         */
        private static function _restoreSpikedShields(core:*):void {
            if (core == null) return;
            var areaM:* = core.buildingAreaMatrix;
            if (areaM == null) return;
            var seen:Object = {};
            for (var y:int = 0; y < areaM.length; y++) {
                var row:* = areaM[y];
                if (row == null) continue;
                for (var x:int = 0; x < row.length; x++) {
                    var cell:* = row[x];
                    if (cell == null || !(cell is WizardStash)) continue;
                    var w:WizardStash = cell as WizardStash;
                    var key:String = w.fieldX + "_" + w.fieldY;
                    if (seen[key] == true) continue;
                    seen[key] = true;
                    if (_originalShield[w] !== undefined) {
                        w.shield.s(Number(_originalShield[w]));
                        delete _originalShield[w];
                    }
                }
            }
        }
    }
}
