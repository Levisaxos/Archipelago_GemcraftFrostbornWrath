package ui {
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.mcDyn.McOptPanel;
    import com.giab.games.gcfw.mcDyn.McOptTitle;
    import data.AV;
    import data.SessionData;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.geom.Rectangle;
    import flash.text.StaticText;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.getDefinitionByName;
    import unlockers.TraitUnlocker;

    /**
     * Tabbed debug options panel.
     *
     * Wraps the game's McOptions chrome (instantiated at runtime — see notes
     * in the original implementation about why we extend MovieClip and not
     * McOptions directly).
     *
     * Tabs:
     *   0 Disclaimer — usage / cheating notice
     *   1 Levels     — level preset toggles + XP tomes
     *   2 Skills     — 24 skill toggles
     *   3 Traits     — 15 battle-trait toggles
     *   4 Stages     — YAML-aware: per-stage / per-tile toggles
     *   5 Pouches    — granularity-aware Gempouch grants
     *   6 Keys       — granularity-aware Wizard Stash key grants
     *   7 Talismans  — the 25 AP "perfect placement" fragment one-shot grants
     *   8 Cores      — base shadow-core stash (1000–1016) one-shot grants
     *   9 Achievements — click-to-send location checks
     *
     * Each tab owns an Array of display objects (each with `yReal`). On tab
     * switch the active array is assigned to `_inner.arrCntContents` and its
     * children are re-parented into `_inner.cnt`; ScrollablePanel.refreshContents()
     * recomputes the scroll range.
     */
    public class McDebugOptions extends MovieClip {

        // ── Tab indices ─────────────────────────────────────────────────────────
        public static const TAB_DISCLAIMER:int   = 0; // Usage / cheating notice
        public static const TAB_LEVELS:int       = 1; // Wizard slider + XP tomes
        public static const TAB_SKILLS:int       = 2;
        public static const TAB_TRAITS:int       = 3;
        public static const TAB_STAGES:int       = 4;
        public static const TAB_POUCHES:int      = 5; // Gempouch gating items
        public static const TAB_KEYS:int         = 6; // Wizard Stash key gating items
        public static const TAB_TALISMANS:int    = 7;
        public static const TAB_CORES:int        = 8;
        public static const TAB_ACHIEVEMENTS:int = 9;

        // ── Public state for ScrDebugOptions handlers ───────────────────────────
        public var levelPanels:Array;       // Array of { panel:McOptPanel, level:int }
        public var levelTitle:McOptTitle;   // live "Wizard Level: N" heading
        public var skillPanels:Array;        // McOptPanel[24]
        public var traitPanels:Array;        // McOptPanel[15]
        public var stageIdToPanel:Object;    // strId -> McOptPanel (per-stage mode)
        public var tilePanels:Object;        // letter -> McOptPanel (per-tile mode)
        public var tilesByLetter:Object;     // letter -> Array<strId>
        // Coarse-gating registries. Entries are
        // { panel:McOptPanel, apId:int, progressive:Boolean, baseLabel:String, order:Array }
        // — `progressive` marks the fungible singleton items (one apId added to
        // the pool N times), which must be grantable repeatedly and render an
        // "N/total" readout instead of a checkbox.
        public var pouchPanels:Array;
        public var keyPanels:Array;
        public var talismanPanels:Array;     // Array of { panel:McOptPanel, apId:int }
        public var corePanels:Array;         // Array of { panel:McOptPanel, apId:int }
        public var xpPanels:Array;           // Array of { panel:McOptPanel, apId:int }
        public var achievementPanels:Array;  // Array of { panel:McOptPanel, apId:int }
        public var achievementModeBtn:McOptPanel; // toggles the achievements view mode
        public var debugCoresBtn:McOptPanel;      // repeatable flat shadow-core grant
        /** Flat amount the Cores tab's repeatable debug button grants per click. */
        public static const DEBUG_SHADOW_CORE_AMOUNT:int = 10000;
        public var stageMode:String = "stage"; // "stage" | "tile"

        public var tabStrip:DebugTabStrip;

        // ── Inner McOptions instance (typed * because McOptions extends Sprite, not MovieClip) ──
        private var _inner:*;

        // Per-tab content arrays
        private var _tabContents:Array;
        // Stages tab has 3 alternates indexed by mode
        private var _stagesByMode:Object;

        // Public proxies into _inner
        public function get arrCntContents():Array           { return _inner.arrCntContents; }
        public function set arrCntContents(v:Array):void     { _inner.arrCntContents = v; }
        public function get cnt():*                          { return _inner.cnt; }
        public function get btnClose():*                     { return _inner.btnClose; }
        public function get btnScrollKnob():MovieClip        { return _inner.btnScrollKnob; }
        public function get mcScrollBar():*                  { return _inner.mcScrollBar; }
        public function get btnConfirmRetry():*              { return _inner.btnConfirmRetry; }
        public function get btnConfirmReturn():*             { return _inner.btnConfirmReturn; }
        public function get btnConfirmEndBattle():*          { return _inner.btnConfirmEndBattle; }
        public function get btnEndBattle():*                 { return _inner.btnEndBattle; }
        public function get btnReturn():*                    { return _inner.btnReturn; }
        public function get btnRetry():*                     { return _inner.btnRetry; }
        public function get btnMainMenu():*                  { return _inner.btnMainMenu; }

        // ── Layout constants ────────────────────────────────────────────────────
        // ROW_HEIGHT_NORM must be >= the rendered McOptPanel height (~46-48px) or
        // adjacent rows visually overlap and the topmost panel intercepts clicks.
        private static const TAB_STRIP_X:Number      = 168;
        private static const TAB_STRIP_Y:Number      = 92;
        private static const TAB_STRIP_W:Number      = 980;
        private static const CONTENT_START_Y:Number  = 152;
        private static const ROW_HEIGHT_NORM:Number  = 52;
        private static const ROW_HEIGHT_STAGE:Number = 44;
        private static const SECTION_GAP:Number      = 64;
        private static const TITLE_X:Number          = 536;
        private static const COL_LEFT_X:Number       = 280;
        private static const COL_RIGHT_X:Number      = 900;

        private static function get SKILL_NAMES():Array        { return SessionData.SKILL_NAMES; }
        private static function get BATTLE_TRAIT_NAMES():Array { return TraitUnlocker.BATTLE_TRAIT_NAMES; }

        private static const TILE_LETTERS:Array = [
            "A","B","C","D","E","F","G","H","I","J","K","L","M",
            "N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
        ];

        public function McDebugOptions() {
            super();

            var McOptionsClass:Class =
                getDefinitionByName("com.giab.games.gcfw.mcStat.McOptions") as Class;
            _inner = new McOptionsClass();
            addChild(_inner);

            overlayTitle("AP Debug Menu");

            // Clear normal options content.
            while (_inner.cnt.numChildren > 0) _inner.cnt.removeChildAt(0);
            _inner.arrCntContents = [];

            // Build all tab contents up-front (lists are small, easier to reason about).
            _tabContents = [];
            _tabContents[TAB_DISCLAIMER] = _buildDisclaimerTab();
            _tabContents[TAB_LEVELS]    = _buildLevelsTab();
            _tabContents[TAB_SKILLS]    = _buildSkillsTab();
            _tabContents[TAB_TRAITS]    = _buildTraitsTab();
            _stagesByMode = {
                stage: _buildStagesPerStage(),
                tile:  _buildStagesPerTile()
            };
            _tabContents[TAB_STAGES]    = _stagesByMode.stage;
            // Pouches / Keys depend on slot_data that may not have landed yet;
            // built here so the arrays exist and rebuilt on every open().
            _tabContents[TAB_POUCHES]   = _buildPouchesTab();
            _tabContents[TAB_KEYS]      = _buildKeysTab();
            _tabContents[TAB_TALISMANS] = _buildTalismansTab();
            _tabContents[TAB_CORES]     = _buildCoresTab();
            // Achievements pool depends on AP connection state; built empty here
            // and repopulated on open() via rebuildAchievementsContents().
            _tabContents[TAB_ACHIEVEMENTS] = _buildAchievementsTab(null);

            // Tab strip (sits on _inner above the scrollable cnt area)
            tabStrip = new DebugTabStrip(
                ["Disclaimer","Levels","Skills","Traits","Stages","Pouches","Keys","Talismans","Cores","Achievements"],
                TAB_STRIP_X, TAB_STRIP_Y, TAB_STRIP_W);
            _inner.addChild(tabStrip);

            // Show first tab
            _showTab(TAB_DISCLAIMER);
        }

        // -----------------------------------------------------------------------
        // Tab management

        public function showTab(idx:int):void { _showTab(idx); }

        private function _showTab(idx:int):void {
            if (idx < 0 || idx >= _tabContents.length) return;
            var contents:Array = _tabContents[idx] as Array;
            if (contents == null) contents = [];

            // Detach existing children
            while (_inner.cnt.numChildren > 0) _inner.cnt.removeChildAt(0);

            // Swap content array and re-attach
            _inner.arrCntContents = contents;
            for (var i:int = 0; i < contents.length; i++) {
                _inner.cnt.addChild(contents[i] as DisplayObject);
            }
        }

        /**
         * Switch the Stages tab between "stage" / "tile" mode.
         * If the Stages tab is currently visible, swaps the displayed contents.
         * Returns true if the mode changed.
         */
        public function setStageMode(mode:String):Boolean {
            if (mode != "stage" && mode != "tile") return false;
            if (mode == stageMode) return false;
            stageMode = mode;
            _tabContents[TAB_STAGES] = _stagesByMode[mode] as Array;
            if (tabStrip != null && tabStrip.activeIndex == TAB_STAGES) {
                _showTab(TAB_STAGES);
            }
            return true;
        }

        /**
         * Rebuild all three Stages mode contents from current AV state. Call
         * this when AP data may have arrived since the menu was constructed
         * (e.g. on open()). Returns true if the contents were rebuilt.
         */
        public function rebuildStagesContents():void {
            _stagesByMode = {
                stage: _buildStagesPerStage(),
                tile:  _buildStagesPerTile()
            };
            _tabContents[TAB_STAGES] = _stagesByMode[stageMode] as Array;
            if (tabStrip != null && tabStrip.activeIndex == TAB_STAGES) {
                _showTab(TAB_STAGES);
            }
        }

        /**
         * Rebuild the Achievements tab from the supplied trackable pool
         * (Array of { apId, name }). Call on open() — the pool depends on AP
         * state (missing locations, server options) that isn't available when
         * the menu is first constructed. Caller is responsible for (re)wiring
         * the freshly-built achievementPanels.
         */
        /**
         * Rebuild the Pouches / Keys tabs from current AP state. Both are
         * driven entirely by slot_data (granularity mode + tile order), which
         * isn't available when the menu is first constructed — so call this on
         * every open(). Caller is responsible for (re)wiring the fresh panels.
         */
        public function rebuildGatingContents():void {
            _tabContents[TAB_POUCHES] = _buildPouchesTab();
            _tabContents[TAB_KEYS]    = _buildKeysTab();
            if (tabStrip == null) return;
            if (tabStrip.activeIndex == TAB_POUCHES || tabStrip.activeIndex == TAB_KEYS)
                _showTab(tabStrip.activeIndex);
        }

        public function rebuildAchievementsContents(pool:Array, onlyInLogic:Boolean = true):void {
            _tabContents[TAB_ACHIEVEMENTS] = _buildAchievementsTab(pool, onlyInLogic);
            if (tabStrip != null && tabStrip.activeIndex == TAB_ACHIEVEMENTS) {
                _showTab(TAB_ACHIEVEMENTS);
            }
        }

        // -----------------------------------------------------------------------
        // Tab builders

        private function _buildDisclaimerTab():Array {
            // Multiple stacked blocks (not one tall TextField) so the shared
            // viewport can scroll them — see DebugDisclaimerView.
            return DebugDisclaimerView.build(200, CONTENT_START_Y, 760);
        }

        private function _buildLevelsTab():Array {
            var arr:Array = [];
            xpPanels = [];
            levelPanels = [];

            // ── Wizard level presets (native toggles, radio behaviour) ──────────
            // The heading doubles as a live readout of the current level; the
            // toggle whose level matches shows checked (see ScrDebugOptions).
            var vY:Number = CONTENT_START_Y;
            levelTitle = new McOptTitle("Wizard Level", TITLE_X, vY);
            arr.push(levelTitle);
            vY += ROW_HEIGHT_NORM;

            var levels:Array = [1, 10, 25, 50, 100, 250, 500, 1000];
            for (var li:int = 0; li < levels.length; li++) {
                var lpx:Number = (li % 2 == 0) ? COL_LEFT_X : COL_RIGHT_X;
                var lv:int = int(levels[li]);
                var lpnl:McOptPanel = new McOptPanel("Level " + lv, lpx, vY, false);
                levelPanels.push({ panel: lpnl, level: lv });
                arr.push(lpnl);
                if (li % 2 == 1) vY += ROW_HEIGHT_NORM;
            }
            if (levels.length % 2 != 0) vY += ROW_HEIGHT_NORM;

            // ── XP tomes (below the presets, separated by a section gap) ────────
            vY += SECTION_GAP;
            arr.push(new McOptTitle("XP Tomes", TITLE_X, vY));
            vY += ROW_HEIGHT_NORM;

            var entries:Array = [
                { label: "Tattered Scroll",   apId: 1100 },
                { label: "Worn Tome",         apId: 1132 },
                { label: "Ancient Grimoire",  apId: 1138 },
                { label: "Filler XP Item",    apId: 1140 }
            ];
            for (var i:int = 0; i < entries.length; i++) {
                var px:Number = (i % 2 == 0) ? COL_LEFT_X : COL_RIGHT_X;
                var pnl:McOptPanel = new McOptPanel(String(entries[i].label), px, vY, false);
                xpPanels.push({ panel: pnl, apId: int(entries[i].apId) });
                arr.push(pnl);
                if (i % 2 == 1) vY += ROW_HEIGHT_NORM;
            }
            return arr;
        }

        private function _buildSkillsTab():Array {
            var arr:Array = [];
            skillPanels = [];
            var vY:Number = CONTENT_START_Y;
            arr.push(new McOptTitle("Skills", TITLE_X, vY));
            vY += ROW_HEIGHT_NORM;
            for (var i:int = 0; i < 24; i++) {
                var px:Number = (i % 2 == 0) ? COL_LEFT_X : COL_RIGHT_X;
                var pnl:McOptPanel = new McOptPanel(SKILL_NAMES[i], px, vY, false);
                skillPanels.push(pnl);
                arr.push(pnl);
                if (i % 2 == 1) vY += ROW_HEIGHT_NORM;
            }
            return arr;
        }

        private function _buildTraitsTab():Array {
            var arr:Array = [];
            traitPanels = [];
            var vY:Number = CONTENT_START_Y;
            arr.push(new McOptTitle("Battle Traits", TITLE_X, vY));
            vY += ROW_HEIGHT_NORM;
            for (var i:int = 0; i < 15; i++) {
                var px:Number = (i % 2 == 0) ? COL_LEFT_X : COL_RIGHT_X;
                var pnl:McOptPanel = new McOptPanel(BATTLE_TRAIT_NAMES[i], px, vY, false);
                traitPanels.push(pnl);
                arr.push(pnl);
                if (i % 2 == 1) vY += ROW_HEIGHT_NORM;
            }
            return arr;
        }

        private function _buildStagesPerStage():Array {
            var arr:Array = [];
            stageIdToPanel = {};
            if (GV.stageCollection == null) return arr;

            var tileStages:Object = {};
            var metas:Array = GV.stageCollection.stageMetas;
            for (var j:int = 0; j < metas.length; j++) {
                if (metas[j] == null) continue;
                var ltr:String = String(metas[j].strId).charAt(0).toUpperCase();
                if (tileStages[ltr] == null) tileStages[ltr] = [];
                (tileStages[ltr] as Array).push(metas[j].strId);
            }
            for (var l:String in tileStages) {
                (tileStages[l] as Array).sort();
            }

            var vY:Number = CONTENT_START_Y;
            for (var li:int = 0; li < TILE_LETTERS.length; li++) {
                var letter:String = TILE_LETTERS[li];
                var stages:Array = tileStages[letter] as Array;
                if (stages == null) continue;

                arr.push(new McOptTitle(letter, TITLE_X, vY));
                vY += ROW_HEIGHT_STAGE;

                for (var si:int = 0; si < stages.length; si++) {
                    var sId:String = String(stages[si]);
                    var sX:Number  = (si % 2 == 0) ? COL_LEFT_X : COL_RIGHT_X;
                    var sPnl:McOptPanel = new McOptPanel(sId, sX, vY, false);
                    stageIdToPanel[sId] = sPnl;
                    arr.push(sPnl);
                    if (si % 2 == 1) vY += ROW_HEIGHT_STAGE;
                }
                if (stages.length % 2 != 0) vY += ROW_HEIGHT_STAGE;
                vY += SECTION_GAP * 0.5;
            }
            return arr;
        }

        private function _buildStagesPerTile():Array {
            var arr:Array = [];
            tilePanels   = {};
            tilesByLetter = {};
            if (GV.stageCollection == null) return arr;

            var metas:Array = GV.stageCollection.stageMetas;
            for (var j:int = 0; j < metas.length; j++) {
                if (metas[j] == null) continue;
                var ltr:String = String(metas[j].strId).charAt(0).toUpperCase();
                if (tilesByLetter[ltr] == null) tilesByLetter[ltr] = [];
                (tilesByLetter[ltr] as Array).push(metas[j].strId);
            }

            var vY:Number = CONTENT_START_Y;
            arr.push(new McOptTitle("Map Tiles", TITLE_X, vY));
            vY += ROW_HEIGHT_NORM;

            var idx:int = 0;
            for (var li:int = 0; li < TILE_LETTERS.length; li++) {
                var letter:String = TILE_LETTERS[li];
                if (tilesByLetter[letter] == null) continue;
                var px:Number = (idx % 2 == 0) ? COL_LEFT_X : COL_RIGHT_X;
                var label:String = "Tile " + letter + "  (" + (tilesByLetter[letter] as Array).length + " stages)";
                var pnl:McOptPanel = new McOptPanel(label, px, vY, false);
                tilePanels[letter] = pnl;
                arr.push(pnl);
                if (idx % 2 == 1) vY += ROW_HEIGHT_NORM;
                idx++;
            }
            return arr;
        }

        /**
         * Gem Pouches tab. Gempouches don't mutate game state — they gate gem
         * availability purely through SessionData item counts — so granting one
         * here is exactly equivalent to receiving it from AP.
         */
        private function _buildPouchesTab():Array {
            var arr:Array = [];
            pouchPanels = [];
            var opts:* = (AV.serverData != null) ? AV.serverData.serverOptions : null;
            var progId:int = (opts != null && int(opts.gemPouchProgressiveId) > 0)
                ? int(opts.gemPouchProgressiveId) : 652;
            _appendCoarseGatingSection(arr, pouchPanels, "Gem Pouches", opts,
                (opts != null) ? int(opts.gemPouchGranularity) : -1,
                626, "Gempouch (", ")",
                progId, "Progressive Gempouch",
                1614, "Master Gempouch");
            return arr;
        }

        /**
         * Wizard Stash Keys tab. Note stash keys have no per-stage granularity
         * any more (retired apworld-side), so the per-stage 1400-1521 ids never
         * appear here — only per-tile / per-tile-progressive / global.
         */
        private function _buildKeysTab():Array {
            var arr:Array = [];
            keyPanels = [];
            var opts:* = (AV.serverData != null) ? AV.serverData.serverOptions : null;
            var progId:int = (opts != null && int(opts.stashKeyPerTileProgressiveId) > 0)
                ? int(opts.stashKeyPerTileProgressiveId) : 1620;
            _appendCoarseGatingSection(arr, keyPanels, "Wizard Stash Keys", opts,
                (opts != null) ? int(opts.stashKeyGranularity) : -1,
                1522, "Wizard Stash Tile ", " Key",
                progId, "Progressive Stash Tile Key",
                1561, "Wizard Stash Master Key");
            return arr;
        }

        /**
         * Build one coarse-gating section. Gem pouches and stash keys share the
         * granularity encoding AND the per-tile id layout (base + index into
         * gemPouchPlayOrder), so a single builder covers both:
         *
         *   -1 no serverOptions yet  → "connect to AP" placeholder
         *    0 off                   → nothing to grant for this slot
         *    1 per_tile              → one panel per prefix, apId = tileBase + index
         *    2 per_tile_progressive  → one repeatable panel for the fungible id
         *    5 global                → the single master item
         *
         * Distinct per-tile ids are assigned from gemPouchPlayOrder (canonical
         * order), while the progressive readout counts against
         * progressiveTileOrder (starter-first) — the same split the grant paths
         * in ArchipelagoMod use, so the "next: X" line matches what a click
         * actually unlocks.
         */
        private function _appendCoarseGatingSection(arr:Array, registry:Array,
                title:String, opts:*, mode:int,
                tileBase:int, tilePre:String, tilePost:String,
                progId:int, progLabel:String,
                masterId:int, masterLabel:String):void {
            var vY:Number = CONTENT_START_Y;
            arr.push(new McOptTitle(title, TITLE_X, vY));
            vY += ROW_HEIGHT_NORM;

            if (mode < 0) {
                arr.push(new McOptTitle("(connect to AP to list these)", TITLE_X, vY));
                return;
            }
            if (mode == 0) {
                arr.push(new McOptTitle("(disabled for this slot — nothing to grant)", TITLE_X, vY));
                return;
            }
            if (mode == 5) {
                var mPnl:McOptPanel = new McOptPanel(masterLabel, COL_LEFT_X, vY, false);
                registry.push({ panel: mPnl, apId: masterId, progressive: false });
                arr.push(mPnl);
                return;
            }

            var playOrder:Array = (opts != null) ? opts.gemPouchPlayOrder as Array : null;
            if (playOrder == null || playOrder.length == 0) {
                arr.push(new McOptTitle("(no tile order in slot data)", TITLE_X, vY));
                return;
            }

            if (mode == 2) {
                var order:Array = (opts != null) ? opts.progressiveTileOrder as Array : null;
                if (order == null || order.length == 0)
                    order = playOrder;
                var pPnl:McOptPanel = new McOptPanel(progLabel, COL_LEFT_X, vY, false);
                registry.push({ panel: pPnl, apId: progId, progressive: true,
                                baseLabel: progLabel, order: order });
                arr.push(pPnl);
                return;
            }

            for (var i:int = 0; i < playOrder.length; i++) {
                var prefix:String = String(playOrder[i]);
                var px:Number = (i % 2 == 0) ? COL_LEFT_X : COL_RIGHT_X;
                var pnl:McOptPanel = new McOptPanel(tilePre + prefix + tilePost, px, vY, false);
                registry.push({ panel: pnl, apId: tileBase + i, progressive: false });
                arr.push(pnl);
                if (i % 2 == 1) vY += ROW_HEIGHT_NORM;
            }
        }

        private function _buildTalismansTab():Array {
            var arr:Array = [];
            talismanPanels = [];
            var nameMap:Object = (AV.serverData != null) ? AV.serverData.talismanNameMap : null;

            // Only the 25 AP "perfect placement" fragments are AP items now
            // (they resolve via the name map); the other 900–952 ids and the
            // retired extras (1200–1246) are no longer granted here.
            var vY:Number = CONTENT_START_Y;
            _appendGrantSection(arr, talismanPanels, "AP Talismans (900-952)",
                900, 952, nameMap, "Talisman Fragment", vY);
            return arr;
        }

        private function _buildCoresTab():Array {
            var arr:Array = [];
            corePanels = [];
            var nameMap:Object = (AV.serverData != null) ? AV.serverData.shadowCoreNameMap : null;

            // Repeatable flat grant, above the AP items. Not an AP item at all —
            // no id, nothing recorded in SessionData — so it never shows a
            // collected check and can be clicked as often as needed.
            var vY:Number = CONTENT_START_Y;
            arr.push(new McOptTitle("Debug Grant", TITLE_X, vY));
            vY += ROW_HEIGHT_NORM;
            debugCoresBtn = new McOptPanel("+" + DEBUG_SHADOW_CORE_AMOUNT + " Shadow Cores",
                COL_LEFT_X, vY, false);
            arr.push(debugCoresBtn);
            vY += ROW_HEIGHT_NORM + SECTION_GAP;

            // Only the base per-field stashes (1000–1016) are AP items now; the
            // extra shadow cores (1300–1351) were retired.
            _appendGrantSection(arr, corePanels, "Base Shadow Cores (1000-1016)",
                1000, 1016, nameMap, "Shadow Cores", vY);
            return arr;
        }

        /**
         * Achievements tab: one click-to-send panel per achievement in the
         * trackable pool. Clicking a panel sends the AP location check (releases
         * the item behind it) without unlocking the achievement in-game — see
         * ScrDebugOptions._onAchievementClick. `pool` is Array of { apId, name };
         * null/empty renders a placeholder prompting the player to connect.
         */
        private function _buildAchievementsTab(pool:Array, onlyInLogic:Boolean = true):Array {
            var arr:Array = [];
            achievementPanels = [];

            var vY:Number = CONTENT_START_Y;
            arr.push(new McOptTitle("Send Achievement Checks", TITLE_X, vY));
            vY += ROW_HEIGHT_NORM;

            // "Only in logic" checkbox toggle. Checked (frame 2) = hide
            // out-of-logic achievements (default); unchecked = show them all.
            // ScrDebugOptions keeps the frame in sync each render tick; set it
            // here too so it's correct on first paint.
            achievementModeBtn = new McOptPanel("Only in logic", TITLE_X, vY, false);
            achievementModeBtn.btn.gotoAndStop(onlyInLogic ? 2 : 1);
            arr.push(achievementModeBtn);
            vY += ROW_HEIGHT_NORM;

            if (pool == null || pool.length == 0) {
                var emptyMsg:String = onlyInLogic
                    ? "(no in-logic achievements — connect to AP, or toggle off)"
                    : "(connect to AP to list achievements)";
                arr.push(new McOptTitle(emptyMsg, TITLE_X, vY));
                return arr;
            }

            for (var i:int = 0; i < pool.length; i++) {
                var apId:int = int(pool[i].apId);
                var label:String = String(pool[i].name);
                var px:Number = (i % 2 == 0) ? COL_LEFT_X : COL_RIGHT_X;
                var pnl:McOptPanel = new McOptPanel(label, px, vY, false);
                achievementPanels.push({ panel: pnl, apId: apId });
                arr.push(pnl);
                if (i % 2 == 1) vY += ROW_HEIGHT_NORM;
            }
            return arr;
        }

        /**
         * Append a labelled section of one-shot grant panels (talisman/core
         * fragments). Returns the new content Y after the section.
         */
        private function _appendGrantSection(arr:Array, registry:Array, title:String,
                                              apIdMin:int, apIdMax:int,
                                              nameMap:Object, fallbackSuffix:String,
                                              vY:Number):Number {
            arr.push(new McOptTitle(title, TITLE_X, vY));
            vY += ROW_HEIGHT_NORM;

            // Only include apIds the server actually mapped (when nameMap is present).
            // Fallback: include the full numeric range so the menu still works offline.
            var ids:Array = [];
            if (nameMap != null) {
                for (var key:String in nameMap) {
                    var id:int = int(key);
                    if (id >= apIdMin && id <= apIdMax) ids.push(id);
                }
                ids.sort(Array.NUMERIC);
            }
            if (ids.length == 0) {
                for (var n:int = apIdMin; n <= apIdMax; n++) ids.push(n);
            }

            for (var i:int = 0; i < ids.length; i++) {
                var apId:int = int(ids[i]);
                var label:String = (nameMap != null && nameMap[String(apId)] != null)
                    ? String(nameMap[String(apId)])
                    : (fallbackSuffix + " " + apId);
                var px:Number = (i % 2 == 0) ? COL_LEFT_X : COL_RIGHT_X;
                var pnl:McOptPanel = new McOptPanel(label, px, vY, false);
                registry.push({ panel: pnl, apId: apId });
                arr.push(pnl);
                if (i % 2 == 1) vY += ROW_HEIGHT_NORM;
            }
            if (ids.length % 2 != 0) vY += ROW_HEIGHT_NORM;
            return vY;
        }

        // -----------------------------------------------------------------------
        // Title overlay (unchanged)

        private function overlayTitle(label:String):void {
            var original:StaticText = findStaticText(_inner, "Options");
            if (original != null) {
                original.visible = false;
                var bounds:Rectangle = original.getBounds(original.parent);
                var tf:TextField = new TextField();
                var fmt:TextFormat = new TextFormat("Palatino Linotype", 28, 0xffffff, true);
                fmt.align = "center";
                tf.defaultTextFormat = fmt;
                tf.selectable   = false;
                tf.mouseEnabled = false;
                var tfWidth:Number = 400;
                tf.x      = bounds.x + bounds.width / 2 - tfWidth / 2;
                tf.y      = bounds.y;
                tf.width  = tfWidth;
                tf.height = bounds.height + 8;
                tf.text   = label;
                original.parent.addChild(tf);
            }
        }

        private function findStaticText(obj:DisplayObjectContainer, search:String):StaticText {
            for (var i:int = 0; i < obj.numChildren; i++) {
                var child:* = obj.getChildAt(i);
                if (child is StaticText && StaticText(child).text == search) return StaticText(child);
                if (child is DisplayObjectContainer) {
                    var found:StaticText = findStaticText(DisplayObjectContainer(child), search);
                    if (found != null) return found;
                }
            }
            return null;
        }
    }
}
