package data {
    /**
     * ServerOptions — Game-specific options received from slot_data.
     * These are immutable after connection and define game mode settings.
     */
    public class ServerOptions {
        // Goal and Primary Settings
        public var goal:int;                     // 0=beat_game, 2=swarm_queen, 3=fields_count, 4=fields_percentage
        public var fieldTokenPlacement:int;      // 0=own_world, 1=any_world, 2=different_world
        public var enforce_logic:Boolean;
        public var disable_endurance:Boolean;
        public var disable_trial:Boolean;

        // XP Tome Levels
        public var tomeXpLevels:Object;          // { tattered, worn, ancient }
        public var talismanMinRarity:int;

        // Difficulty Multipliers
        public var enemyMultipliers:Object;      // { hp, armor, shield, waves, extraWaves }

        // Starting State
        public var startingWizardLevel:int;
        public var startingOvercrowd:Boolean;

        // Gating granularity for the three gating-item categories.
        // fieldTokenGranularity: 0=per_stage, 1=per_tile, 2=per_tier
        // stashKeyGranularity:   0=per_stage, 1=per_tile, 2=per_tier, 3=global
        // gemPouchGranularity:   0=off, 1=per_tile_distinct,
        //                        2=per_tile_progressive, 3=per_tier, 4=global
        // gemPouchPlayOrder is the prefix list (W, S, V, R, ...) used by
        // per_tile_distinct (item id = 626 + index) and per_tile_progressive
        // (Nth copy unlocks Nth prefix).
        public var fieldTokenGranularity:int;
        public var stashKeyGranularity:int;
        public var gemPouchGranularity:int;
        public var gemPouchPlayOrder:Array;
        public var gemPouchProgressiveId:int;

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
            fieldTokenPlacement = 1;
            enforce_logic = true;
            disable_endurance = false;
            disable_trial = true;

            tomeXpLevels = { tattered: 1, worn: 2, ancient: 3 };
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
            gemPouchProgressiveId = 0;
            stageTierByStrId = {};

            fieldsRequired = 0;
            fieldsRequiredPercentage = 0;
            achievementRequiredEffort = 0;

            deathLinkEnabled = false;
            deathLinkRound = false;
            deathLinkCoup = false;
            deathLinkAnyBonus = false;
        }
    }
}
