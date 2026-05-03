package patch {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.utils.Dictionary;

    import Bezel.Logger;
    import com.giab.common.utils.NumberFormatter;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.SB;
    import com.giab.games.gcfw.constants.GemComponentType;
    import com.giab.games.gcfw.constants.IngameStatus;
    import com.giab.games.gcfw.entity.Gem;

    import data.AV;

    /**
     * Hollow Gem injector — overlays a custom "Create Hollow Gem" button at
     * the mana-leech slot when the player is on the seed's starter stage and
     * does not yet own its Gempouch.
     *
     * Design:
     *   - GemPouchSuppressor wipes availableGemTypes + hides the 6 vanilla
     *     gem-create buttons on stages without a pouch. We add ours on top.
     *   - Click bypasses initiateCastCreateGem (which checks availableGemTypes)
     *     and calls IngameSpellCaster.castCreateGem(slot, MANA_LEECHING)
     *     directly. The resulting gem is post-processed:
     *       * sd1_Raw.manaGainPerHit  → 0 (kills the leech effect)
     *       * hasColor                → false (renders as colorless / white)
     *       * hueMain                 → 0
     *       * elderComponents         → [] (removes "Pure Mana Leech" labelling)
     *       * sd1_Raw damage stays 4-8 from the MANA_LEECHING branch — the
     *         lowest min and lowest max across all 6 component types.
     *     Then recalculateSds() propagates to sd2..sd5 and giveGemBitmaps()
     *     regenerates the colorless visuals.
     *   - Combine/duplicate preserve hasColor=false (IngameSpellCaster.combineGems
     *     line 1020-1023) and zero out manaGainPerHit (line 1001-1003), so
     *     merged hollow gems stay hollow.
     *   - The "spent on mana-leech" stat increment from castCreateGem is undone
     *     so achievement gates (e.g. "only mana leech gems") aren't polluted.
     *
     * Activation: AV.serverData.freeStages holds the starter stage str_id(s).
     * Under per_stage granularity that's a single str_id; under per_tile or
     * per_tier the entire covered set is included — Hollow Gem activates on
     * any stage in the set when no covering pouch is held.
     * (e.g. "S2"). Active only on that exact stage and only when its prefix
     * letter has no Gempouch. Auto-deactivates once the pouch arrives.
     */
    public class HollowGemInjector {

        // Position offset to identify our button vs. vanilla create-buttons
        // (we attach at the same .x/.y as btnCastCreateGem2).
        private static const HOLLOW_TYPE:int = GemComponentType.MANA_LEECHING;

        // Visible click-area dimensions of a gem-create button. The MovieClip
        // template's bounds include child overlays (frameRollover /
        // frameSelected) that extend past the visible button — using
        // template.width/height for hit-testing makes the click zone too
        // large. Mirrors the vanilla mouseX/mouseY range at
        // IngameInfoPanelRenderer.as:2378 (1797..1854 × 635..693).
        private static const _BTN_HIT_W:int = 57;
        private static const _BTN_HIT_H:int = 58;

        private var _logger:Logger;
        private var _modName:String;

        private var _button:Sprite = null;
        private var _hostFrame:* = null;       // mcIngameFrame we attached to
        private var _wasHovered:Boolean = false;

        // Per-stage decision lock: -1 = not yet decided, 0 = inactive, 1 = active.
        // Snapshot the "is this the starter stage with no pouch?" answer on
        // the first frame with valid state, then carry it for the rest of
        // the level. Reset on stage exit. Without this, an AP-granted
        // Gempouch arriving mid-level would flip _isActiveStage to false,
        // detach the button, stop reapplying filters, and any hollow gems
        // produced by combine/duplicate after that would render as orange
        // mana-leech gems.
        private var _lockedActive:int = -1;

        // Tracks gems we've already filtered. Re-checked per-frame because
        // combineGems / castCloneGem create fresh Bitmap objects (without
        // our filter) and assign them to the new gem.
        private var _filteredBitmaps:Dictionary = new Dictionary(true);

        // Snapshot of `core.stats.spentManaOnManaLeechingGem` at first frame
        // of an active hollow stage. Restored every subsequent frame so
        // hollow gems can't pollute the "win using only mana-leech gems"
        // achievements (game_id 30, 33 — IngameAchiChecker0.as:245-286)
        // via combineGems:908 / castCloneGem:1770 / createGem:599.
        // -1 = not yet snapshotted; reset on stage exit.
        private var _leechStatBaseline:Number = -1;
        private static const _DESAT_FILTER:ColorMatrixFilter = _buildDesatFilter();

        private static function _buildDesatFilter():ColorMatrixFilter {
            // Luminance-preserving desaturation + slight brighten so the
            // orange leech base reads as pale white rather than mid-grey.
            return new ColorMatrixFilter([
                0.299, 0.587, 0.114, 0, 60,
                0.299, 0.587, 0.114, 0, 60,
                0.299, 0.587, 0.114, 0, 60,
                0,     0,     0,     1, 0
            ]);
        }

        public function HollowGemInjector(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        /** Per-frame check while screen == INGAME. Idempotent. */
        public function onIngameFrame():void {
            try {
                if (!_isActiveStage()) {
                    _detach();
                    return;
                }
                _ensureAttached();
                _reapplyHollowFilters();
                _restoreLeechStat();
                _updateTooltip();
            } catch (err:Error) {
                _logger.log(_modName,
                    "HollowGemInjector.onIngameFrame ERROR: " + err.message);
            }
        }

        /** Snapshot the leech stat on first active frame, then pin it to
         *  that value every subsequent frame. While hollow mode is active,
         *  GemPouchSuppressor wipes availableGemTypes so no other gem
         *  types are creatable — the only thing that can move this stat
         *  is hollow-gem create / combine / clone, all of which we want
         *  to suppress. The pin runs every frame because combineGems and
         *  castCloneGem don't fire any signal we can hook directly. */
        private function _restoreLeechStat():void {
            if (GV.ingameCore == null || GV.ingameCore.stats == null) return;
            var stats:* = GV.ingameCore.stats;
            if (_leechStatBaseline < 0) {
                _leechStatBaseline = Number(stats.spentManaOnManaLeechingGem);
            } else if (Number(stats.spentManaOnManaLeechingGem) != _leechStatBaseline) {
                stats.spentManaOnManaLeechingGem = _leechStatBaseline;
            }
        }

        /** Reset on stage exit so the next ingame entry re-runs setup. */
        public function resetIngame():void {
            _detach();
            _filteredBitmaps = new Dictionary(true);
            _wasHovered = false;
            _lockedActive = -1;
            _leechStatBaseline = -1;
        }

        // -----------------------------------------------------------------------
        // Activation logic

        /** True when current stage is the seed's starter stage AND the player
         *  did not own the Gempouch at the start of this stage. Decision is
         *  snapshotted on the first frame with valid state — see _lockedActive. */
        private function _isActiveStage():Boolean {
            if (_lockedActive == 1) return true;
            if (_lockedActive == 0) return false;

            // Lock-eligible only when we have full state to evaluate; until
            // then return false but DON'T lock, so the next frame can decide.
            if (AV.serverData == null || AV.serverData.serverOptions == null)
                return false;
            if (GV.ingameCore == null || GV.ingameCore.stageMeta == null)
                return false;

            var stageStrId:String = String(GV.ingameCore.stageMeta.strId);
            if (stageStrId == null || stageStrId.length == 0)
                return false;

            var freeStages:Array = AV.serverData.freeStages as Array;
            if (freeStages == null || freeStages.length == 0) {
                _lockedActive = 0; // freeStages is stable post-connect — safe to lock.
                return false;
            }

            var opts:* = AV.serverData.serverOptions;
            var mode:int = int(opts.gemPouchGranularity);
            if (mode == 0) {
                _lockedActive = 0; // gating disabled for the seed — stable, lock.
                return false;
            }

            // Starter set may be a single stage (per_stage granularity) or an
            // entire tile / tier worth of stages (per_tile / per_tier).
            // Activate Hollow Gem bootstrap on any stage in the set.
            var inStarterSet:Boolean = false;
            for (var fi:int = 0; fi < freeStages.length; fi++) {
                if (String(freeStages[fi]) == stageStrId) {
                    inStarterSet = true;
                    break;
                }
            }
            if (!inStarterSet) {
                _lockedActive = 0; // not in starter set — won't change mid-level.
                return false;
            }

            var active:Boolean = !_hasPouchFor(stageStrId, opts);
            _lockedActive = active ? 1 : 0;
            return active;
        }

        private function _hasPouchFor(stageStrId:String, opts:*):Boolean {
            var mode:int = int(opts.gemPouchGranularity);
            var prefix:String = stageStrId.charAt(0);

            if (mode == 1) {
                var orderD:Array = opts.gemPouchPlayOrder as Array;
                if (orderD == null || orderD.length == 0) return true;
                var idxD:int = orderD.indexOf(prefix);
                if (idxD < 0) return true;
                return AV.sessionData.hasItem(626 + idxD);
            }
            if (mode == 2) {
                // per_tile_progressive: starter-first count threshold.
                var orderP:Array = opts.progressiveTileOrder as Array;
                if (orderP == null || orderP.length == 0)
                    orderP = opts.gemPouchPlayOrder as Array;
                if (orderP == null || orderP.length == 0) return true;
                var idxP:int = orderP.indexOf(prefix);
                if (idxP < 0) return true;
                var progId:int = int(opts.gemPouchProgressiveId);
                if (progId <= 0) progId = 652;
                return AV.sessionData.getItemCount(progId) >= idxP + 1;
            }
            if (mode == 3) {
                // per_tier: AP id 1601 + tier (gating.py POUCH_TIER_BASE).
                var tierMap:Object = opts.stageTierByStrId;
                if (tierMap == null || tierMap[stageStrId] == null)
                    return true;
                return AV.sessionData.hasItem(1601 + int(tierMap[stageStrId]));
            }
            if (mode == 4) {
                // per_tier_progressive: starter-first count threshold.
                var tierMap4:Object = opts.stageTierByStrId;
                if (tierMap4 == null || tierMap4[stageStrId] == null)
                    return true;
                var tier4:int = int(tierMap4[stageStrId]);
                var tierProgId:int = int(opts.gemPouchPerTierProgressiveId);
                if (tierProgId <= 0) return true;
                var tierOrd:Array = opts.progressiveTierOrder as Array;
                if (tierOrd != null && tierOrd.length > 0) {
                    var posT:int = tierOrd.indexOf(tier4);
                    if (posT < 0) return true;
                    return AV.sessionData.getItemCount(tierProgId) >= posT + 1;
                }
                return AV.sessionData.getItemCount(tierProgId) >= tier4 + 1;
            }
            if (mode == 5) {
                return AV.sessionData.hasItem(1614); // POUCH_MASTER_ID
            }
            return true;
        }

        // -----------------------------------------------------------------------
        // Button attach / detach

        private function _ensureAttached():void {
            var cnt:* = GV.ingameCore != null ? GV.ingameCore.cnt : null;
            if (cnt == null)
                return;
            var frame:* = cnt.mcIngameFrame;
            if (frame == null)
                return;

            // If already attached to this exact frame, nothing to do.
            if (_button != null && _hostFrame === frame && _button.parent === frame)
                return;

            // Stale attachment (frame was rebuilt) — clean up first.
            if (_button != null)
                _detach();

            var template:* = frame.btnCastCreateGem2;
            if (template == null)
                return;

            _button = _buildButton(template);
            _button.x = template.x;
            _button.y = template.y;
            frame.addChild(_button);
            _hostFrame = frame;

            _logger.log(_modName,
                "HollowGemInjector: button attached at (" + template.x + "," + template.y + ")");
        }

        private function _detach():void {
            if (_button == null)
                return;
            try {
                if (_button.parent != null)
                    _button.parent.removeChild(_button);
            } catch (e:Error) {}
            _button = null;
            _hostFrame = null;
        }

        /** Build a desaturated bitmap clone of the mana-leech button + click hook. */
        private function _buildButton(template:*):Sprite {
            var btn:Sprite = new Sprite();

            // Snapshot the button into a BitmapData sized to the *visible*
            // click rect (57x58). The MovieClip template includes
            // frameRollover/frameSelected child overlays that extend past the
            // visible button, so using template.width/height here would make
            // both the visual and the hit area too large. Anything drawn
            // outside our 57x58 bounds gets clipped naturally — the button
            // graphic itself sits at the template's (0,0).
            var bd:BitmapData = new BitmapData(_BTN_HIT_W, _BTN_HIT_H, true, 0x00000000);
            try {
                bd.draw(template);
            } catch (e:Error) {}

            var bmp:Bitmap = new Bitmap(bd);
            // Desaturate (luminance-preserving) so the mana-leech icon reads
            // as a colorless / white gem.
            bmp.filters = [_desaturateFilter()];
            btn.addChild(bmp);

            btn.buttonMode    = true;
            btn.useHandCursor = true;
            btn.mouseChildren = false;
            btn.addEventListener(MouseEvent.CLICK, _onClick, false, 0, true);

            return btn;
        }

        // -----------------------------------------------------------------------
        // Tooltip — rendered per-frame from onIngameFrame while the mouse is
        // inside the button's hit rect.
        //
        // Why per-frame instead of MOUSE_OVER/MOUSE_OUT events: vanilla
        // IngameInfoPanelRenderer.renderInfoPanel runs every frame and at the
        // leech zone (1797..1854 × 635..693) it does NOT add panel content
        // (arrIsSpellBtnVisible[7] is false in our setup) but it sets
        // lastZoneXMin/Max to the *crit* zone (1740..1797) — see
        // IngameInfoPanelRenderer.as:2382. Next frame the mouse-outside-
        // lastZone check at line 241 fires, vanilla calls vIp.reset() and
        // cntInfoPanel.removeChild(vIp), wiping any tooltip we added on
        // MOUSE_OVER. Re-adding every frame keeps the panel visible.

        private function _updateTooltip():void {
            if (_button == null || _button.stage == null) {
                if (_wasHovered) _hideTooltip();
                return;
            }
            var mx:Number = _button.mouseX;
            var my:Number = _button.mouseY;
            var hovered:Boolean = mx >= 0 && mx < _BTN_HIT_W
                               && my >= 0 && my < _BTN_HIT_H;
            if (hovered) {
                if (GV.ingameCore != null
                        && GV.ingameCore.ingameStatus == IngameStatus.PLAYING) {
                    _renderTooltip();
                    _wasHovered = true;
                }
            } else if (_wasHovered) {
                _hideTooltip();
                _wasHovered = false;
            }
        }

        private function _renderTooltip():void {
            try {
                var vIp:* = GV.mcInfoPanel;
                if (vIp == null)
                    return;
                vIp.reset(360);
                vIp.addTextfield(0xFFFFFF, "Create Hollow Gem", false, 13);
                vIp.addExtraHeight(5);
                vIp.addSeparator(-2);
                vIp.addTextfield(0xFFFFFF, "A pure crystal with no special effect", false);
                _addCostLine(vIp);
                GV.main.cntInfoPanel.addChild(vIp);
                vIp.doEnterFrame();
            } catch (err:Error) {}
        }

        private function _hideTooltip():void {
            try { GV.main.cntInfoPanel.removeChild(GV.mcInfoPanel); } catch (err:Error) {}
        }

        /** Replicate IngameInfoPanelRenderer.addGemCostInfo so the tooltip
         *  shows the same coloured "Grade N gem mana cost" line / "Not enough
         *  mana" warning the vanilla create-gem buttons use. */
        private function _addCostLine(vIp:*):void {
            if (GV.ingameCore == null)
                return;
            var core:* = GV.ingameCore;
            var costs:Array = core.gemCreatingBaseManaCosts as Array;
            if (costs == null || costs.length == 0)
                return;
            var grade:int = int(core.gemGradeToCreate);
            if (grade == -1) {
                vIp.addTextfield(0xFD3E3E,
                    "Grade 1 gem mana cost: "
                    + NumberFormatter.format(Math.round(Number(costs[0])))
                    + "\n\nNot enough mana");
                return;
            }
            if (grade < 0 || grade >= costs.length)
                grade = 0;
            var cost:Number = Number(costs[grade]);
            if (cost > core.getMana()) {
                vIp.addTextfield(0xFD3E3E,
                    "Grade " + (grade + 1) + " gem mana cost: "
                    + NumberFormatter.format(Math.round(cost))
                    + "\n\nNot enough mana");
            } else {
                vIp.addTextfield(0x8BDFEB,
                    "Grade " + (grade + 1) + " gem mana cost: "
                    + NumberFormatter.format(Math.max(0, Math.round(cost))));
            }
        }

        private function _desaturateFilter():ColorMatrixFilter {
            // Standard luminance-preserving desaturation matrix.
            return new ColorMatrixFilter([
                0.299, 0.587, 0.114, 0, 0,
                0.299, 0.587, 0.114, 0, 0,
                0.299, 0.587, 0.114, 0, 0,
                0,     0,     0,     1, 0
            ]);
        }

        // -----------------------------------------------------------------------
        // Click — create + white-ify

        private function _onClick(e:MouseEvent):void {
            try {
                if (GV.ingameCore == null)
                    return;
                if (GV.ingameCore.ingameStatus != IngameStatus.PLAYING)
                    return;
                if (!_isActiveStage())
                    return; // pouch arrived between attach and click

                var core:* = GV.ingameCore;
                var costs:Array = core.gemCreatingBaseManaCosts as Array;
                if (costs == null || costs.length == 0)
                    return;
                // Match what vanilla castCreateGem will deduct — uses
                // gemGradeToCreate, not always 0 (the Fusion skill / Pure
                // talisman raise the default created grade).
                var gradeIdx:int = int(core.gemGradeToCreate);
                if (gradeIdx < 0 || gradeIdx >= costs.length)
                    gradeIdx = 0;
                var manaCost:Number = Math.round(Number(costs[gradeIdx]));
                if (core.getMana() < manaCost)
                    return; // vanilla castCreateGem will play the alert sfx

                var slot:int = _firstEmptyInvSlot(core);
                if (slot < 0)
                    return; // inventory full

                var beforeCount:int = (core.gems as Array).length;
                // Snapshot the leech-stat counter so we can restore it
                // after castCreateGem.  IngameCreator.createGem adds
                // gemCreatingBaseManaCosts[0] to spentManaOnManaLeechingGem
                // for the base gem, and combineGems adds further increments
                // for grade>0 (Fusion / Pure talisman) — neither matches
                // the player-paid mana cost, so a fixed subtraction would
                // miss.  Restoring the pre-cast value zeroes every path.
                var leechSnapshot:Number = (core.stats != null)
                    ? Number(core.stats.spentManaOnManaLeechingGem) : 0;
                var ok:Boolean = core.spellCaster.castCreateGem(slot, HOLLOW_TYPE);
                if (!ok)
                    return;

                // Reverse the "mana spent on leech" stat increments so the
                // "win using only mana-leech gems" achievements and the
                // end-of-level mana-spent breakdown aren't polluted.
                if (core.stats != null) {
                    core.stats.spentManaOnManaLeechingGem = leechSnapshot;
                }

                var newGem:Gem = _findNewGem(core, beforeCount);
                if (newGem != null)
                    _whiteify(newGem);

                SB.playSound("sndgemcreated");
            } catch (err:Error) {
                _logger.log(_modName,
                    "HollowGemInjector._onClick ERROR: " + err.message);
            }
        }

        private function _firstEmptyInvSlot(core:*):int {
            var slots:Array = core.inventorySlots as Array;
            if (slots == null)
                return -1;
            for (var i:int = 0; i < 9 && i < slots.length; i++) {
                if (slots[i] == null)
                    return i;
            }
            return -1;
        }

        private function _findNewGem(core:*, beforeCount:int):Gem {
            var gems:Array = core.gems as Array;
            if (gems == null || gems.length <= beforeCount)
                return null;
            return gems[gems.length - 1] as Gem;
        }

        /** Strip the mana-leech identity from a freshly-created gem so it
         *  reads as a colorless "Hollow Gem" with no special component. */
        private function _whiteify(gem:Gem):void {
            if (gem == null)
                return;

            // Kill the leech effect on the raw shot data — recalculateSds
            // rebuilds sd2..sd5 from sd1_Raw, so this propagates everywhere.
            if (gem.sd1_Raw != null)
                gem.sd1_Raw.manaGainPerHit.s(0);

            // hasColor/hueMain only affect the glow filter color in
            // giveGemBitmaps. The gem body is built from manaValuesByComponent
            // (the pie chart at GemBitmapCreator.as:203-210), so the bitmap
            // stays orange even with hasColor=false. We desaturate the
            // resulting Bitmap objects below to get the white look.
            gem.hasColor = false;
            gem.hueMain  = 0;

            // Empty elderComponents: vanilla info panel (line 296-298) shows
            // "0 color components" instead of "Pure mana leech". Combine of
            // two empty elderComponents arrays stays empty so this propagates.
            gem.elderComponents = [];

            // NOTE: do NOT touch manaValuesByComponent[MANA_LEECHING].
            // The pie chart in GemBitmapCreator.giveGemBitmaps requires at
            // least one non-zero slice across all 6 components — for hollow
            // gems, MANA_LEECHING is the only set slot. Zeroing it crashes
            // castCloneGem with "Pie chart: no slices given".
            //
            // Combine / duplicate stat pollution is instead handled per-frame
            // by _restoreLeechStat() — see comment there.

            try { gem.recalculateSds(); } catch (e:Error) {}

            _applyDesatToGem(gem);

            // Refresh the displayed bitmap in gem.mc — placeGemIntoSlot
            // already called showInInv() with the unfiltered bitmap reference,
            // and Bitmap.filters is sticky on the same object, so reapplying
            // showInInv after we've set the filter ensures the displayed
            // child carries the filter at next render.
            try { gem.showInInv(); } catch (e:Error) {}
        }

        /** Per-frame: catch hollow-gem descendants from combine/duplicate.
         *  combineGems and castCloneGem call giveGemBitmaps fresh on the new
         *  gem, replacing every Bitmap object — our filter is lost. We
         *  reapply on any colorless gem we haven't already filtered. The
         *  Dictionary is weak-keyed so destroyed gems are GC'd. */
        private function _reapplyHollowFilters():void {
            if (GV.ingameCore == null)
                return;
            var gems:Array = GV.ingameCore.gems as Array;
            if (gems == null)
                return;
            var iLim:int = gems.length;
            for (var i:int = 0; i < iLim; i++) {
                var g:Gem = gems[i] as Gem;
                if (g == null || g.hasColor)
                    continue;
                // Use bmpInTower as the marker — every gem has it, and any
                // bitmap-replacement (combineGems → giveGemBitmaps) creates
                // a new Bitmap object with a different identity.
                if (g.bmpInTower != null && _filteredBitmaps[g.bmpInTower])
                    continue;
                _applyDesatToGem(g);
                if (g.bmpInTower != null)
                    _filteredBitmaps[g.bmpInTower] = true;
                // Also kill any lingering leech effect that combine math
                // could have re-introduced (shouldn't happen with both
                // inputs at 0, but cheap safety).
                if (g.sd1_Raw != null && g.sd1_Raw.manaGainPerHit.g() > 0) {
                    g.sd1_Raw.manaGainPerHit.s(0);
                    try { g.recalculateSds(); } catch (e:Error) {}
                }
            }
        }

        /** Apply the desaturate filter to every Bitmap variant the gem owns. */
        private function _applyDesatToGem(g:Gem):void {
            var f:Array = [_DESAT_FILTER];
            if (g.bmpInInventory         != null) g.bmpInInventory.filters         = f;
            if (g.bmpInInventoryBolt     != null) g.bmpInInventoryBolt.filters     = f;
            if (g.bmpInInventoryBeam     != null) g.bmpInInventoryBeam.filters     = f;
            if (g.bmpInInventoryBarrage  != null) g.bmpInInventoryBarrage.filters  = f;
            if (g.bmpInTower             != null) g.bmpInTower.filters             = f;
            if (g.bmpInTowerBolt         != null) g.bmpInTowerBolt.filters         = f;
            if (g.bmpInTowerBeam         != null) g.bmpInTowerBeam.filters         = f;
            if (g.bmpInTowerBarrage      != null) g.bmpInTowerBarrage.filters      = f;
            if (g.bmpInTrap              != null) g.bmpInTrap.filters              = f;
            if (g.bmpInAmp               != null) g.bmpInAmp.filters               = f;
            if (g.bmpDragged             != null) g.bmpDragged.filters             = f;
        }
    }
}
