package data {
    /**
     * ServerOptions — Game-specific options received from slot_data.
     * These are immutable after connection and define game mode settings.
     */
    public class ServerOptions {
        // Goal and Primary Settings
        public var goal:int;                     // 0=beat_game, 2=swarm_queen, 3=fields_count, 4=fields_percentage
        public var startingStage:int;            // 0=W1..3=W4, 4=S1..7=S4 (StartingStage option order)
        public var fieldTokenPlacement:int;      // 0=own_world, 1=any_world, 2=different_world
        public var enforce_logic:Boolean;
        public var disable_endurance:Boolean;
        public var disable_trial:Boolean;

        // XP Tome Levels — derived per-tome counts plus raw % multiplier.
        public var tomeXpLevels:Object;          // { tattered, worn, ancient }
        public var xpTomeBonus:int;              // raw yaml % (50–300, default 150)

        // Skill point pool scale (50–200% of the 2000 SP baseline).
        public var skillpointMultiplier:int;

        // Reserved for full_talisman goal — currently no yaml option, kept
        // wired so GoalManager.configure / FullTalismanGoal still compile.
        public var talismanMinRarity:int;

        // Difficulty Multipliers
        public var enemyMultipliers:Object;      // { hp, armor, shield, waves, extraWaves }

        // Starting State
        public var startingWizardLevel:int;
        public var startingOvercrowd:Boolean;

        // Gating granularity for the three gating-item categories.
        // fieldTokenGranularity: 0=per_stage, 1=per_stage_progressive,
        //                        2=per_tile,  3=per_tile_progressive,
        //                        4=per_tier,  5=per_tier_progressive
        // stashKeyGranularity:   0=per_stage, 1=per_stage_progressive,
        //                        2=per_tile,  3=per_tile_progressive,
        //                        4=per_tier,  5=per_tier_progressive, 6=global
        // gemPouchGranularity:   0=off, 1=per_tile, 2=per_tile_progressive,
        //                        3=per_tier, 4=per_tier_progressive, 5=global
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
        public var progressiveTierOrder:Array;            // <int>[] (tier ints)
        public var gemPouchProgressiveId:int;             // 1614 by default — per_tile_progressive
        public var gemPouchPerTierProgressiveId:int;      // per_tier_progressive
        public var fieldTokenPerStageProgressiveId:int;
        public var fieldTokenPerTileProgressiveId:int;
        public var fieldTokenPerTierProgressiveId:int;
        public var stashKeyPerStageProgressiveId:int;
        public var stashKeyPerTileProgressiveId:int;
        public var stashKeyPerTierProgressiveId:int;

        // Per-stage tier number, sent from the apworld so the mod can resolve
        // coarse tier-keyed items. Map: str_id -> tier int (e.g. {"W1": 0}).
        public var stageTierByStrId:Object;

        // Goal-Specific Settings
        public var fieldsRequired:int;           // for fields_count goal
        public var fieldsRequiredPercentage:int; // for fields_percentage goal
        public var achievementRequiredEffort:int; // 0=Off, 1=Trivial, 2=Minor, 3=Major, 4=Extreme

        // Death Link Settings
        public var deathLinkEnabled:Boolean;
        public var deathLinkRound:Boolean;
        public var deathLinkCoup:Boolean;
        public var deathLinkAnyBonus:Boolean;

        public function ServerOptions() {
            initialize();
        }

        public function initialize():void {
            goal = 0;
            startingStage = 0;
            fieldTokenPlacement = 1;
            enforce_logic = true;
            disable_endurance = false;
            disable_trial = true;

            tomeXpLevels = { tattered: 1, worn: 2, ancient: 3 };
            xpTomeBonus = 150;
            skillpointMultiplier = 100;
            talismanMinRarity = 0;

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
            progressiveTierOrder = [];
            gemPouchProgressiveId = 0;
            gemPouchPerTierProgressiveId = 0;
            fieldTokenPerStageProgressiveId = 0;
            fieldTokenPerTileProgressiveId = 0;
            fieldTokenPerTierProgressiveId = 0;
            stashKeyPerStageProgressiveId = 0;
            stashKeyPerTileProgressiveId = 0;
            stashKeyPerTierProgressiveId = 0;
            stageTierByStrId = {};

            fieldsRequired = 0;
            fieldsRequiredPercentage = 0;
            achievementRequiredEffort = 0;

            deathLinkEnabled = false;
            deathLinkRound = false;
            deathLinkCoup = false;
            deathLinkAnyBonus = false;
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
    }
}
