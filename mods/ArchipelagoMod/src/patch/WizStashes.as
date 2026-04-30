package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import com.giab.common.utils.ColorToolbox;
    import com.giab.games.gcfw.entity.WizardStash;
    import data.AV;
    import tracker.FieldLogicEvaluator;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.geom.Point;
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
     *   - tickClearOpened()         — clean up matrix cells of opened stashes
     *   - tickEnforceStashLock()    — shield-spike locked stashes (AP-side per-stage
     *                                 gating) and overdraw the locked-stash sprite
     *                                 directly into core.cnt.bmpdBuildings so the
     *                                 chained-chest art replaces the vanilla stash
     *   - tickStashLockTooltip()    — append a "Locked - requires key" line to the
     *                                 hover tooltip when the player hovers a locked stash
     */
    public class WizStashes {

        // True while we have our locked-stash artwork stamped into bmpdBuildings.
        // Used so the unlock transition triggers exactly one redrawHighBuildings()
        // call (which repaints the vanilla stash sprite over our overdraw).
        private static var _hasLockedDrawn:Boolean = false;

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

        // Set once at bind time by ArchipelagoMod so the locked-stash tooltip
        // can read per-stage power thresholds + current player power.
        private static var _evaluator:FieldLogicEvaluator = null;
        public static function setEvaluator(evaluator:FieldLogicEvaluator):void {
            _evaluator = evaluator;
        }

        // Embedded chained-chest art used to replace the vanilla stash sprite
        // while the stash is locked. Path is relative to this .as file:
        // src/patch/ → ../../resources/WizStashLocked.png.
        [Embed(source='../../resources/WizStashLocked.png')]
        private static const LockedStashAsset:Class;

        // Stash collision footprint is 3 cells × 2 cells = 84×56 px, but the
        // vanilla stash sprite bleeds beyond that with shadow/depth. We render
        // larger than the footprint and center on the visual anchor at
        // ((fx+1.5)·28, (fy+1)·28) so the chained-chest covers the full vanilla
        // silhouette. Adjust these two consts (keeping ~3:2 ratio) if the art
        // needs to grow/shrink.
        private static const LOCKED_W:int = 96;
        private static const LOCKED_H:int = 64;
        private static var _lockedStashBmd:BitmapData = null;

        // Cached per-stage tinted variant. Vanilla applies a level-specific
        // HSBC color transform to every building (ColorToolbox.adjustHsbc in
        // IngameRenderer2.as:807); we replicate it here so the chained chest
        // matches the stage's palette instead of staying gold-yellow on a
        // bluish level. Keyed by hsbc fingerprint — rebuilt only when the
        // tint actually changes (stage transitions, mostly).
        private static var _tintedLockedBmd:BitmapData = null;
        private static var _tintedLockedKey:String = null;

        private static function _getLockedStashBmd():BitmapData {
            if (_lockedStashBmd != null) return _lockedStashBmd;
            try {
                var src:Bitmap = new LockedStashAsset() as Bitmap;
                if (src == null || src.bitmapData == null) return null;

                // Trim transparent padding so a generously-bordered PNG still
                // fills the stash footprint. getColorBoundsRect with mask
                // 0xFF000000 finds the tight bbox of non-transparent pixels.
                var srcBmd:BitmapData = src.bitmapData;
                var trim:Rectangle = srcBmd.getColorBoundsRect(0xFF000000, 0x00000000, false);
                if (trim == null || trim.width <= 0 || trim.height <= 0) {
                    trim = new Rectangle(0, 0, srcBmd.width, srcBmd.height);
                }

                var bmd:BitmapData = new BitmapData(LOCKED_W, LOCKED_H, true, 0);
                var m:Matrix = new Matrix();
                m.translate(-trim.x, -trim.y);
                m.scale(LOCKED_W / trim.width, LOCKED_H / trim.height);
                bmd.draw(srcBmd, m, null, null, new Rectangle(0, 0, LOCKED_W, LOCKED_H), true);
                _lockedStashBmd = bmd;
            } catch (e:Error) {}
            return _lockedStashBmd;
        }

        private static function _getTintedLockedBmd(hsbc:Array):BitmapData {
            var key:String = hsbc != null ? hsbc.join(",") : "";
            if (_tintedLockedBmd != null && _tintedLockedKey == key)
                return _tintedLockedBmd;

            var base:BitmapData = _getLockedStashBmd();
            if (base == null)
                return null;

            if (_tintedLockedBmd != null) {
                try { _tintedLockedBmd.dispose(); } catch (eDisp:Error) {}
                _tintedLockedBmd = null;
            }

            var tinted:BitmapData = base.clone();
            if (hsbc != null) {
                try {
                    var arr:Array = ColorToolbox.calculateColorMatrixFilter(hsbc);
                    if (arr != null && arr.length > 0 && arr[0] != null) {
                        tinted.applyFilter(tinted,
                            new Rectangle(0, 0, tinted.width, tinted.height),
                            new Point(0, 0),
                            arr[0]);
                    }
                } catch (eFilter:Error) {}
            }

            _tintedLockedBmd = tinted;
            _tintedLockedKey = key;
            return _tintedLockedBmd;
        }

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
         *   - Overdraw the locked-stash sprite into core.cnt.bmpdBuildings so
         *     the chained-chest art visually replaces the vanilla stash. The
         *     overdraw is reapplied each frame: cheap (one copyPixels per
         *     stash), and robust to any vanilla call to redrawHighBuildings()
         *     (input handler clicks, destroyer events, etc.) that would
         *     otherwise wipe it.
         *
         * Once the unlock arrives, hidden stashes are pushed back into
         * core.wizardStashes, original shield is restored, and a single
         * redrawHighBuildings() call repaints the vanilla stash over our
         * overdraw.
         */
        public static function tickEnforceStashLock(logger:Logger, modName:String):void {
            try {
                var core:* = GV.ingameCore;
                if (core == null || core.stageMeta == null) {
                    return;
                }

                // Run regardless of ingameStatus. Vanilla doesn't flip to
                // PLAYING until well after setScene2 paints buildings into
                // bmpdBuildings (DISABLED → PLAYING happens in
                // IngameInitializer.as:1655, well after :1518's
                // redrawHighBuildings). Gating on PLAYING here would let the
                // vanilla stash flash visibly while the engine is still in
                // DISABLED. Locked stashes stay locked through the ending too
                // (their shield is pinned, so vanilla won't try to open them),
                // so it's safe to keep overdrawing during GAMEOVER_PANEL_*.
                var strId:String = String(core.stageMeta.strId);
                var stageId:int  = int(core.stageMeta.id);

                // Stash is "unlocked" only when both gates pass: key collected
                // AND the same per-stage logic gate that governs the stage's
                // Journey location (prereq stages + WIZLOCK skills + talisman
                // counter requirements). isStashGateMet() rolls these up.
                var unlocked:Boolean = false;
                if (AV.sessionData != null && AV.sessionData.isStashUnlocked(strId)) {
                    if (_evaluator == null) {
                        unlocked = true;
                    } else {
                        unlocked = _evaluator.isStashGateMet(strId);
                    }
                }

                if (unlocked) {
                    // Both gates pass — restore any shields we spiked, push
                    // hidden stashes back to the targeting array. If we had
                    // overdrawn locked sprites, trigger one redrawHighBuildings
                    // so vanilla repaints the unlocked stash sprite.
                    _restoreSpikedShields(core);
                    _restoreHiddenStashes(core);
                    if (_hasLockedDrawn) {
                        _hasLockedDrawn = false;
                        try { core.renderer2.redrawHighBuildings(); } catch (eRedraw:Error) {}
                    }
                    return;
                }

                // Stage changed (entered a new level). Vanilla rebuilt
                // core.wizardStashes and bmpdBuildings from scratch, so our
                // hidden-stash cache and locked-overdraw flag are stale.
                if (_hiddenStashesStageId != -1 && _hiddenStashesStageId != stageId) {
                    _hiddenStashes.length = 0;
                    _hiddenStashesStageId = -1;
                    _hasLockedDrawn = false;
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
                // collect their (fieldX, fieldY) so we can overdraw the locked
                // chest sprite at each position. Also capture the first stash's
                // hsbc tint array — used to apply the same per-stage color
                // transform vanilla applies to the building sprites.
                var seen:Object = {};
                var stashCoords:Array = [];
                var stashHsbc:Array = null;
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

                        if (stashHsbc == null) stashHsbc = w.hsbc;
                        stashCoords.push({fx: w.fieldX, fy: w.fieldY});
                    }
                }

                if (stashCoords.length == 0) return;

                // Overdraw: stamp the chained-chest art directly into
                // bmpdBuildings at each stash's footprint. We clear the
                // footprint first (fillRect → transparent) so vanilla stash
                // pixels don't bleed through any transparent edges of our PNG.
                var bmd:BitmapData = _getTintedLockedBmd(stashHsbc);
                if (bmd != null && core.cnt != null && core.cnt.bmpdBuildings != null) {
                    var dest:BitmapData = core.cnt.bmpdBuildings;
                    var srcRect:Rectangle = new Rectangle(0, 0, bmd.width, bmd.height);
                    var dstPt:Point = new Point();
                    var clearRect:Rectangle = new Rectangle(0, 0, bmd.width, bmd.height);
                    var wasFirstDraw:Boolean = !_hasLockedDrawn;
                    for (var s:int = 0; s < stashCoords.length; s++) {
                        var c:Object = stashCoords[s];
                        // Center the locked sprite on the stash visual anchor:
                        // ((fx+1.5)·28, (fy+1)·28). Footprint is 84×56 cells,
                        // bitmap is LOCKED_W×LOCKED_H, so the offset is
                        // (footprint − bitmap)/2 from the cell origin.
                        dstPt.x = int(c.fx) * 28 + ((84 - LOCKED_W) >> 1);
                        dstPt.y = int(c.fy) * 28 + ((56 - LOCKED_H) >> 1);
                        clearRect.x = dstPt.x;
                        clearRect.y = dstPt.y;
                        dest.fillRect(clearRect, 0);
                        dest.copyPixels(bmd, srcRect, dstPt, null, null, true);
                    }
                    _hasLockedDrawn = true;
                    if (wasFirstDraw) {
                        logger.log(modName, "WizStashes: locked stash overdraw applied for "
                            + strId + " (" + stashCoords.length + " stash(es))");
                    }
                }
            } catch (err:Error) {
                logger.log(modName, "WizStashes.tickEnforceStashLock ERROR: " + err.message);
            }
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
         * Per-frame: append "Locked — requires Wizard Stash {strId} Key" to the
         * in-level hover tooltip when the player is hovering a locked stash.
         *
         * Pattern matches FieldTooltipOverlay: detect a freshly-rendered panel
         * (vIp.isImageRendered), append textfields, dispose the bitmap, and let
         * vanilla's doEnterFrame re-render. A marker text guards against
         * appending twice for the same hovered cell.
         */
        public static function tickStashLockTooltip(logger:Logger, modName:String):void {
            try {
                var core:* = GV.ingameCore;
                if (core == null || core.stageMeta == null)
                    return;
                if (AV.sessionData == null)
                    return;

                var strId:String = String(core.stageMeta.strId);

                // Fire when EITHER the key is missing OR the stage's logic
                // gate is unmet (prereq stages, WIZLOCK skills, or talisman
                // requirements). Same gate as the apworld stash access rule.
                var keyHeld:Boolean   = AV.sessionData.isStashUnlocked(strId);
                var stageInLogic:Boolean = (_evaluator == null)
                    || _evaluator.canCompleteStage(strId);
                if (keyHeld && stageInLogic)
                    return;  // unlocked — no tooltip line

                var vIp:* = GV.mcInfoPanel;
                if (vIp == null || vIp.parent == null || !vIp.isImageRendered)
                    return;

                // Identify the hovered cell — same math vanilla uses in
                // IngameInfoPanelRenderer (mouseX-50, mouseY-8, /28).
                var rt:* = (core.cnt != null) ? core.cnt.root : null;
                if (rt == null)
                    return;
                var vX:int = Math.floor((rt.mouseX - 50) / 28);
                var vY:int = Math.floor((rt.mouseY - 8) / 28);

                var areaM:* = core.buildingAreaMatrix;
                if (areaM == null)
                    return;
                if (vY < 0 || vY >= areaM.length)
                    return;
                var row:* = areaM[vY];
                if (row == null || vX < 0 || vX >= row.length)
                    return;

                var cell:* = row[vX];
                if (!(cell is WizardStash))
                    return;
                var w:WizardStash = cell as WizardStash;
                if (w.isDestroyed || w.startedAsOpen)
                    return;

                // Build the lines we want to show.
                var lines:Array = [];
                lines.push(["Locked", 0xFF6666]);
                if (!keyHeld) {
                    lines.push(["Requires Wizard Stash " + strId + " Key", 0xCCCCCC]);
                }
                if (!stageInLogic && _evaluator != null) {
                    var blockingLines:Array = _evaluator.getBlockingTierSkillLines(strId);
                    for each (var bl:Array in blockingLines) {
                        if (bl != null && bl.length >= 2) lines.push(bl);
                    }
                }

                // Marker text used for idempotency — first non-title line.
                var marker:String = String(lines[1][0]);

                var tfs:Array = vIp.textfields as Array;
                if (tfs == null)
                    return;
                for (var i:int = 0; i < tfs.length; i++) {
                    var tf:* = tfs[i];
                    if (tf == null)
                        continue;
                    var txt:String = null;
                    try {
                        txt = String(tf.text);
                    } catch (eText:Error) {
                        continue;
                    }
                    if (txt == marker)
                        return;
                }

                try {
                    vIp.addExtraHeight(5);
                    vIp.addSeparator(-2);
                    for (var li:int = 0; li < lines.length; li++) {
                        var pair:Array = lines[li] as Array;
                        var bold:Boolean = (li == 0);
                        var size:int  = bold ? 12 : 11;
                        vIp.addTextfield(uint(pair[1]), String(pair[0]), bold, size);
                    }
                } catch (eAdd:Error) {
                    logger.log(modName, "WizStashes.tickStashLockTooltip addTextfield error: " + eAdd.message);
                    return;
                }

                try {
                    var oldBmp:Bitmap = vIp.bmp as Bitmap;
                    if (oldBmp != null && oldBmp.bitmapData != null)
                        oldBmp.bitmapData.dispose();
                    vIp.bmp = null;
                    vIp.isImageRendered = false;
                } catch (eRender:Error) {}

                // Re-render in the SAME frame so the panel doesn't render
                // blank/stale for one frame between dispose and vanilla's next
                // doEnterFrame. Without this the panel flickers periodically
                // every time vanilla re-runs renderInfoPanel() and we need to
                // re-append our lines.
                try {
                    vIp.doEnterFrame();
                } catch (eDef:Error) {}
            } catch (err:Error) {
                logger.log(modName, "WizStashes.tickStashLockTooltip ERROR: " + err.message);
            }
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
