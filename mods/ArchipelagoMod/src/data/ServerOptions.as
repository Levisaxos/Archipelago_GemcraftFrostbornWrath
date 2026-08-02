package data {
    /**
     * ServerOptions — Game-specific options received from slot_data.
     * These are immutable after connection and define game mode settings.
     */
    public class ServerOptions {
        // Goal and Primary Settings
        public var goal:int;                     // 0=beat_game, 1=swarm_queen, 2=fields_count
        public var difficulty:int;               // 0=Easy, 1=Medium, 2=Hard, 3=Extreme
        // Wizard-level gating (mirrors the apworld exactly). A stage is in logic
        // once the player's DERIVED wizard level >= stageGates[str_id]; an
        // achievement once derived WL >= achievementMinWl[effort tier].
        public var stageGates:Object;            // str_id -> required wizard level
        public var achievementMinWl:Object;      // effort tier name -> required wizard level
        // Derived-WL inputs (mirror difficulty_gates.derived_wl). Derived WL =
        // levelFromXp( sum(wlEffXp[strId] over cleared fields) * xpTraitMultiplier[eff] ),
        // where eff is the effective XP-trait count after the harness gate:
        // the k-th of the (up to 4) held xpTraitApIds counts only if the WL
        // already reached with k-1 traits >= xpTraitMinWl[k]. See WizardLevelCalc.
        public var wlEffXp:Object;               // str_id -> per-field XP (this difficulty)
        public var xpTraitApIds:Array;           // AP ids of the 4 XP-scaling traits
        public var xpTraitMultiplier:Array;      // [1.0,1.2,1.44,1.728,2.0736]; index = n held
        public var xpTraitMinWl:Array;           // [0,10,20,30,40]; harness gate, index = target count
        public var startingStages:Array;         // starter stage str_ids, e.g. ["W1","W3"]
        public var fieldTokenPlacement:int;      // 0=own_world, 1=any_world, 2=different_world
        public var disable_endurance:Boolean;
        public var disable_trial:Boolean;

        // XP Tome Levels — derived per-tome counts plus raw % multiplier.
        public var tomeXpLevels:Object;          // { tattered, worn, ancient }
        public var xpTomeBonus:int;              // raw yaml % (50–300, default 150)

        // Mod-only QoL: extra shadow cores granted per wave reached in a battle
        // (0–5, default 0). Accumulated into the vanilla per-battle loot tally
        // and banked at level end like any other shadow-core drop.
        public var extraShadowCoresPerWave:int;

        // Fixed SP value granted by each SP item, indexed by AP id offset
        // from 1700: [Small, Medium, Big, Single]. Constant every seed
        // (see items_skillpoints.SP_ITEMS apworld-side). Used for grant
        // amounts (ArchipelagoMod.grantItem) and the in-mod skillPoints:N
        // achievement-gate counter.
        public var spBundleValues:Array;          // <int>[4]

        // Difficulty Multipliers
        public var enemyMultipliers:Object;      // { hp, armor, shield, waves, extraWaves }

        // Starting State
        public var startingWizardLevel:int;
        public var startingOvercrowd:Boolean;

        // Gating granularity for the three gating-item categories.
        // (per_tier / per_tier_progressive retired; those values never occur.)
        // fieldTokenGranularity: 0=per_stage, 1=per_stage_progressive,
        //                        2=per_tile,  3=per_tile_progressive
        // stashKeyGranularity:   0=off, 1=per_tile, 2=per_tile_progressive,
        //                        5=global (per_stage retired; mirrors gemPouchGranularity)
        // gemPouchGranularity:   0=off, 1=per_tile, 2=per_tile_progressive,
        //                        5=global
        // gemPouchPlayOrder is the prefix list (W, S, V, R, ...) used by
        // per_tile (item id = 626 + index) and shared by every per_tile /
        // per_tile_progressive variant across all three categories.
        public var fieldTokenGranularity:int;
        public var stashKeyGranularity:int;
        public var gemPouchGranularity:int;
        public var gemPouchPlayOrder:Array;
        // Per-stage progressive unlock order — walks gemPouchPlayOrder,
        // within each tile alphabetical by stage strId. Nth copy of any
        // per_stage_progressive item unlocks stageProgressiveOrder[N-1].
        public var stageProgressiveOrder:Array;
        // Starter-first variants of the three progressive orders. The Nth
        // received copy of a progressive item unlocks the Nth entry of these
        // (so position 0 = starter's group, the precollect lands the player
        // there; position 1+ = canonical sequence with starter's group
        // removed). All progressive grant / sync / tooltip logic reads from
        // these, NOT from gemPouchPlayOrder / stageProgressiveOrder which
        // remain in canonical order for distinct ID assignment + UI display.
        public var progressiveTileOrder:Array;            // <prefix>[]
        public var progressiveStageOrder:Array;           // <strId>[]
        public var gemPouchProgressiveId:int;             // 1614 by default — per_tile_progressive
        public var fieldTokenPerStageProgressiveId:int;
        public var fieldTokenPerTileProgressiveId:int;
        public var stashKeyPerStageProgressiveId:int;
        public var stashKeyPerTileProgressiveId:int;

        // Goal-Specific Settings
        // Resolved absolute stage threshold sent by the apworld. Use this for
        // both fields_count and fields_percentage goal triggering — never
        // recompute from the percentage on the mod side (would drift against
        // the apworld's floor() formula).
        public var fieldsRequiredCount:int;
        public var achievementRequiredEffort:int; // 0=Off, 1=Trivial, 2=Minor, 3=Major, 4=Extreme

        // Death Link Settings
        public var deathLinkEnabled:Boolean;

        public function ServerOptions() {
            initialize();
        }

        public function initialize():void {
            goal = 0;
            difficulty = 1;
            stageGates = {};
            achievementMinWl = {};
            wlEffXp = {};
            xpTraitApIds = [];
            xpTraitMultiplier = [1.0, 1.0, 1.0, 1.0, 1.0]; // DROPPED 2026-07-19: trait multiplier no longer affects WL. Slot_data ships [1,1,1,1,1]; this fallback matches.
            xpTraitMinWl = [0, 10, 20, 30, 40];
            startingStages = ["W1"];
            fieldTokenPlacement = 1;
            disable_endurance = false;
            disable_trial = true;

            tomeXpLevels = { tattered: 1, worn: 2, ancient: 3 };
            xpTomeBonus = 150;
            extraShadowCoresPerWave = 0;
            spBundleValues = [5, 25, 250, 1];

            enemyMultipliers = {
                hp: 1.0,
                armor: 1.0,
                shield: 1.0,
                waves: 1.0,
                extraWaves: 0
            };

            startingWizardLevel = 1;
            startingOvercrowd = false;

            fieldTokenGranularity = 0;
            stashKeyGranularity = 0;
            gemPouchGranularity = 0;
            gemPouchPlayOrder = [];
            stageProgressiveOrder = [];
            progressiveTileOrder = [];
            progressiveStageOrder = [];
            gemPouchProgressiveId = 0;
            fieldTokenPerStageProgressiveId = 0;
            fieldTokenPerTileProgressiveId = 0;
            stashKeyPerStageProgressiveId = 0;
            stashKeyPerTileProgressiveId = 0;

            fieldsRequiredCount = 0;
            achievementRequiredEffort = 0;

            deathLinkEnabled = false;
        }

        /**
         * Number of tiles in the starter-first progressive unlock order.
         * Falls back to 26 (alphabet length) when slot_data hasn't populated
         * the order yet — matches the drop-icon tooltip's "X / N worlds
         * unlocked" defaults from before this was centralized.
         */
        public function progressiveTileOrderLength():int {
            if (progressiveTileOrder == null)
                return 26;
            return progressiveTileOrder.length;
        }

        /**
         * Tile prefix letter unlocked by the Nth copy of any per-tile
         * progressive item (1-based). Returns "?" if copies is out of range
         * or the order array isn't populated.
         */
        public function progressiveTilePrefix(copies:int):String {
            if (progressiveTileOrder == null
                    || copies < 1 || copies > progressiveTileOrder.length)
                return "?";
            return String(progressiveTileOrder[copies - 1]);
        }

        /** Fixed SP value granted by an SP apId in 1700..1703.
         *  Returns 0 if slot_data hasn't loaded yet or apId is out of range. */
        public function getSpBundleValue(apId:int):int {
            var idx:int = apId - 1700;
            if (idx < 0 || idx > 3) return 0;
            if (spBundleValues == null || idx >= spBundleValues.length) return 0;
            return int(spBundleValues[idx]);
        }

        /** User-facing display name for an SP apId in 1700..1703. The first
         *  three are chunky fixed "bundle" tiers; 1703 is the common single
         *  Skillpoint filler (shown as just "Skillpoint", no "Bundle"). */
        public function getSpItemName(apId:int):String {
            switch (apId) {
                case 1700: return "Skillpoint Bundle (Small)";
                case 1701: return "Skillpoint Bundle (Medium)";
                case 1702: return "Skillpoint Bundle (Big)";
                case 1703: return "Skillpoint";
            }
            return "Skillpoint";
        }
    }
}
