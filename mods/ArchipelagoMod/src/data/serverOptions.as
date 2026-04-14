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

        // Goal-Specific Settings
        public var fieldsRequired:int;           // for fields_count goal
        public var fieldsRequiredPercentage:int; // for fields_percentage goal

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

            fieldsRequired = 0;
            fieldsRequiredPercentage = 0;

            deathLinkEnabled = false;
            deathLinkRound = false;
            deathLinkCoup = false;
            deathLinkAnyBonus = false;
        }
    }
}
