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
     *   0 Wizard     — compact level slider + presets
     *   1 Skills     — 24 skill toggles
     *   2 Traits     — 15 battle-trait toggles
     *   3 Stages     — YAML-aware: per-stage / per-tile / per-tier toggles
     *   4 Talismans  — base (900–952) + extra (1200–1246) one-shot grants
     *   5 Cores      — shadow-core bundles (1000–1016, 1300–1351) one-shot grants
     *   6 XP         — XP-tome drop-icon grants (Tattered/Worn/Ancient/Filler)
     *
     * Each tab owns an Array of display objects (each with `yReal`). On tab
     * switch the active array is assigned to `_inner.arrCntContents` and its
     * children are re-parented into `_inner.cnt`; ScrollablePanel.refreshContents()
     * recomputes the scroll range.
     */
    public class McDebugOptions extends MovieClip {

        // ── Tab indices ─────────────────────────────────────────────────────────
        public static const TAB_LEVELS:int    = 0; // Wizard slider + XP tomes
        public static const TAB_SKILLS:int    = 1;
        public static const TAB_TRAITS:int    = 2;
        public static const TAB_STAGES:int    = 3;
        public static const TAB_TALISMANS:int = 4;
        public static const TAB_CORES:int     = 5;
        public static const TAB_ACHIEVEMENTS:int = 6;

        // ── Public state for ScrDebugOptions handlers ───────────────────────────
        public var wizardSlider:McWizardLevelSlider;
        public var skillPanels:Array;        // McOptPanel[24]
        public var traitPanels:Array;        // McOptPanel[15]
        public var stageIdToPanel:Object;    // strId -> McOptPanel (per-stage mode)
        public var tilePanels:Object;        // letter -> McOptPanel (per-tile mode)
        public var tilesByLetter:Object;     // letter -> Array<strId>
        public var tierPanels:Object;        // tier int -> McOptPanel (per-tier mode)
        public var tiersToStages:Object;     // tier int -> Array<strId>
        public var talismanPanels:Array;     // Array of { panel:McOptPanel, apId:int }
        public var corePanels:Array;         // Array of { panel:McOptPanel, apId:int }
        public var xpPanels:Array;           // Array of { panel:McOptPanel, apId:int }
        public var achievementPanels:Array;  // Array of { panel:McOptPanel, apId:int }
        public var stageMode:String = "stage"; // "stage" | "tile" | "tier"

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

            overlayTitle("Archipelago Debug");

            // Clear normal options content.
            while (_inner.cnt.numChildren > 0) _inner.cnt.removeChildAt(0);
            _inner.arrCntContents = [];

            // Build all tab contents up-front (lists are small, easier to reason about).
            _tabContents = [];
            _tabContents[TAB_LEVELS]    = _buildLevelsTab();
            _tabContents[TAB_SKILLS]    = _buildSkillsTab();
            _tabContents[TAB_TRAITS]    = _buildTraitsTab();
            _stagesByMode = {
                stage: _buildStagesPerStage(),
                tile:  _buildStagesPerTile(),
                tier:  _buildStagesPerTier()
            };
            _tabContents[TAB_STAGES]    = _stagesByMode.stage;
            _tabContents[TAB_TALISMANS] = _buildTalismansTab();
            _tabContents[TAB_CORES]     = _buildCoresTab();
            // Achievements pool depends on AP connection state; built empty here
            // and repopulated on open() via rebuildAchievementsContents().
            _tabContents[TAB_ACHIEVEMENTS] = _buildAchievementsTab(null);

            // Tab strip (sits on _inner above the scrollable cnt area)
            tabStrip = new DebugTabStrip(
                ["Levels","Skills","Traits","Stages","Talismans","Cores","Achievements"],
                TAB_STRIP_X, TAB_STRIP_Y, TAB_STRIP_W);
            _inner.addChild(tabStrip);

            // Show first tab
            _showTab(TAB_LEVELS);
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
         * Switch the Stages tab between "stage" / "tile" / "tier" mode.
         * If the Stages tab is currently visible, swaps the displayed contents.
         * Returns true if the mode changed.
         */
        public function setStageMode(mode:String):Boolean {
            if (mode != "stage" && mode != "tile" && mode != "tier") return false;
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
                tile:  _buildStagesPerTile(),
                tier:  _buildStagesPerTier()
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
        public function rebuildAchievementsContents(pool:Array):void {
            _tabContents[TAB_ACHIEVEMENTS] = _buildAchievementsTab(pool);
            if (tabStrip != null && tabStrip.activeIndex == TAB_ACHIEVEMENTS) {
                _showTab(TAB_ACHIEVEMENTS);
            }
        }

        // -----------------------------------------------------------------------
        // Tab builders

        private function _buildLevelsTab():Array {
            var arr:Array = [];
            xpPanels = [];

            // Wizard slider (top)
            wizardSlider = new McWizardLevelSlider(0, CONTENT_START_Y);
            arr.push(wizardSlider);

            // XP tomes (below slider, separated by a section gap)
            var vY:Number = CONTENT_START_Y + McWizardLevelSlider.TOTAL_HEIGHT + SECTION_GAP;
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

        private function _buildStagesPerTier():Array {
            var arr:Array = [];
            tierPanels   = {};
            tiersToStages = {};
            if (GV.stageCollection == null) return arr;

            // Bucket stages by tier from serverOptions.stageTierByStrId.
            // If no server data yet, this tab will be empty (caller can rebuild
            // after connect via setStageMode("tier") rebuild).
            var so:* = (AV.serverData != null) ? AV.serverData.serverOptions : null;
            var tierByStrId:Object = (so != null) ? so.stageTierByStrId : null;
            var hasTierData:Boolean = false;
            if (tierByStrId != null) {
                for (var probeKey:String in tierByStrId) { hasTierData = true; break; }
            }
            if (!hasTierData) {
                var vY0:Number = CONTENT_START_Y;
                arr.push(new McOptTitle("(no AP tier data — connect first)", TITLE_X, vY0));
                return arr;
            }

            var metas:Array = GV.stageCollection.stageMetas;
            for (var j:int = 0; j < metas.length; j++) {
                if (metas[j] == null) continue;
                var sid:String = String(metas[j].strId);
                if (tierByStrId[sid] == null) continue;
                var tier:int = int(tierByStrId[sid]);
                if (tiersToStages[tier] == null) tiersToStages[tier] = [];
                (tiersToStages[tier] as Array).push(sid);
            }

            // Sort tiers ascending using progressiveTierOrder if present, else numeric.
            var tierKeys:Array = [];
            for (var k:* in tiersToStages) tierKeys.push(int(k));
            tierKeys.sort(Array.NUMERIC);

            var vY:Number = CONTENT_START_Y;
            arr.push(new McOptTitle("Tiers", TITLE_X, vY));
            vY += ROW_HEIGHT_NORM;

            for (var ti:int = 0; ti < tierKeys.length; ti++) {
                var t:int = int(tierKeys[ti]);
                var px:Number = (ti % 2 == 0) ? COL_LEFT_X : COL_RIGHT_X;
                var label:String = "Tier " + t + "  (" + (tiersToStages[t] as Array).length + " stages)";
                var pnl:McOptPanel = new McOptPanel(label, px, vY, false);
                tierPanels[t] = pnl;
                arr.push(pnl);
                if (ti % 2 == 1) vY += ROW_HEIGHT_NORM;
            }
            return arr;
        }

        private function _buildTalismansTab():Array {
            var arr:Array = [];
            talismanPanels = [];
            var nameMap:Object = (AV.serverData != null) ? AV.serverData.talismanNameMap : null;

            var vY:Number = CONTENT_START_Y;
            vY = _appendGrantSection(arr, talismanPanels, "Base Talismans (900-952)",
                900, 952, nameMap, "Talisman Fragment", vY);
            vY += SECTION_GAP;
            _appendGrantSection(arr, talismanPanels, "Extra Talismans (1200-1246)",
                1200, 1246, nameMap, "Talisman Fragment", vY);
            return arr;
        }

        private function _buildCoresTab():Array {
            var arr:Array = [];
            corePanels = [];
            var nameMap:Object = (AV.serverData != null) ? AV.serverData.shadowCoreNameMap : null;

            var vY:Number = CONTENT_START_Y;
            vY = _appendGrantSection(arr, corePanels, "Base Shadow Cores (1000-1016)",
                1000, 1016, nameMap, "Shadow Cores", vY);
            vY += SECTION_GAP;
            _appendGrantSection(arr, corePanels, "Extra Shadow Cores (1300-1351)",
                1300, 1351, nameMap, "Shadow Cores", vY);
            return arr;
        }

        /**
         * Achievements tab: one click-to-send panel per achievement in the
         * trackable pool. Clicking a panel sends the AP location check (releases
         * the item behind it) without unlocking the achievement in-game — see
         * ScrDebugOptions._onAchievementClick. `pool` is Array of { apId, name };
         * null/empty renders a placeholder prompting the player to connect.
         */
        private function _buildAchievementsTab(pool:Array):Array {
            var arr:Array = [];
            achievementPanels = [];

            var vY:Number = CONTENT_START_Y;
            arr.push(new McOptTitle("Send Achievement Checks", TITLE_X, vY));
            vY += ROW_HEIGHT_NORM;

            if (pool == null || pool.length == 0) {
                arr.push(new McOptTitle("(connect to AP to list achievements)", TITLE_X, vY));
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
