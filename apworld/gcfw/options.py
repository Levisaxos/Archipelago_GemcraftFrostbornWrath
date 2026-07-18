from dataclasses import dataclass

from Options import Choice, DeathLink, OptionSet, PerGameCommonOptions, Range, Toggle


class RandomStartingStages(Range):
    """How many starting stages to roll at random from the four W fields.

    0 = don't roll — start on exactly the fields you list in Starting Stages instead.
    1-4 = start on that many randomly-chosen W fields.
    Set this to `random` to roll the count itself (which can land on 0 = your specific list), or `random-range-1-4` to always roll a random 1 to 4.
    """
    display_name = "Random Starting Stages"
    range_start = 0
    range_end   = 4
    default     = 1


class StartingStages(OptionSet):
    """The exact W fields you start on, used when Random Starting Stages is 0.

    List one or more of W1, W2, W3, W4 — every one you list is playable from the menu immediately; all other stages must be unlocked through Archipelago. Must contain at least one field. Starting on more than one field only makes a difference with per-stage field-token granularity (with per-tile, the whole W tile is already free from any single W starter).
    """
    display_name = "Starting Stages"
    valid_keys = frozenset({"W1", "W2", "W3", "W4"})
    default = frozenset({"W1"})


# W-tile stages eligible as starters.
W_STARTER_SIDS = ["W1", "W2", "W3", "W4"]


class FieldTokenPlacement(Choice):
    """Controls where field tokens (stage unlocks) are allowed to be placed in the multiworld.

    own_world:       Field tokens can only appear in your own locations.
    any_world:       Field tokens can appear anywhere (default).
    different_world: Field tokens can only appear in other players' worlds.
    """
    display_name = "Field Token Placement"
    option_own_world       = 0
    option_any_world       = 1
    option_different_world = 2
    default = 1


class Goal(Choice):
    """What counts as completing GemCraft: Frostborn Wrath.

    kill_gatekeeper:    Kill the Gatekeeper on A4.
    kill_swarm_queen:   Kill the Swarm Queen on K4.
    fields_count:       Complete a fixed number of Journey stages (set by Fields Required).
    """
    display_name = "Goal"
    option_kill_gatekeeper  = 0
    option_kill_swarm_queen = 1
    option_fields_count     = 2
    default = 0


class FieldsRequired(Range):
    """Number of Journey stages that must be completed to win.
    Only used when Goal is set to 'fields_count'.

    The game has 122 stages total.
    """
    display_name = "Fields Required"
    range_start = 12
    range_end   = 122
    default     = 80


class XpTomeBonus(Range):
    """Approximate total wizard levels granted by all XP tomes you'll find combined.

    XP tomes come as Tattered Scrolls, Worn Tomes, and Ancient Grimoires (40 in total), with progressively larger level rewards. This option scales their combined value. Lower for a slower XP curve, higher for a faster one.
    These levels are "bonus" and not counted towards progression; adding more XP tomes makes the game easier.
    """
    display_name = "XP Tome Bonus"
    range_start = 0
    range_end   = 300
    default     = 100


class DeathLinkPunishment(Choice):
    """What happens when a DeathLink signal is received.

    gem_loss:     A percentage of placed gems (and their towers/traps) are destroyed.
    wave_surge:   A set of enraged waves is injected immediately.
    instant_fail: The current level fails immediately (traditional DeathLink).
    spawn_horde:  A flood of vanilla-strength monsters from the current wave is spawned at once.
    spawn_special: A burst of special enemies (Apparitions / Specters / etc.) is spawned with HP scaled to ~10 waves above the current one.
    """
    display_name = "DeathLink Punishment"
    option_gem_loss     = 0
    option_wave_surge   = 1
    option_instant_fail = 2
    option_spawn_horde  = 3
    option_spawn_special = 4
    default = 0


class GemLossPercent(Range):
    """Percentage of placed gems destroyed on a DeathLink (gem_loss punishment only).
    Always rounded up — so even 1 gem with 10% loses that gem.
    """
    display_name = "Gem Loss Percent"
    range_start = 10
    range_end   = 50
    default     = 20


class WaveSurgeCount(Range):
    """Number of enraged waves injected on a DeathLink (wave_surge punishment only)."""
    display_name = "Wave Surge Count"
    range_start = 1
    range_end   = 10
    default     = 3


class WaveSurgeGemLevel(Range):
    """Gem level used to calculate the enrage multiplier for surge waves (wave_surge only)."""
    display_name = "Wave Surge Gem Level"
    range_start = 1
    range_end   = 9
    default     = 3


class SpawnHordeCount(Range):
    """Number of vanilla-strength monsters spawned from the current wave on a DeathLink (spawn_horde only)."""
    display_name = "Spawn Horde Count"
    range_start = 50
    range_end   = 500
    default     = 100


class SpawnSpecialElements(OptionSet):
    """Special enemy types that may be spawned on a DeathLink (spawn_special only).

    Each of the N spawns picks a random type from this set. Leave the default to allow all five types.
    """
    display_name = "Spawn Special Elements"
    valid_keys = frozenset({
        "Apparition",
        "Specter",
        "Wraith",
        "Spire",
        "Wizard Hunter",
    })
    default = frozenset({"Apparition", "Specter", "Wraith", "Spire", "Wizard Hunter"})


class SpawnSpecialCount(Range):
    """Number of specials spawned on a DeathLink (spawn_special only)."""
    display_name = "Spawn Special Count"
    range_start = 1
    range_end   = 10
    default     = 5


class DeathLinkGracePeriod(Range):
    """Seconds of immunity at the start of each level before a queued DeathLink can trigger."""
    display_name = "DeathLink Grace Period"
    range_start = 10
    range_end   = 30
    default     = 15


class DeathLinkCooldown(Range):
    """Minimum seconds between two DeathLink punishments. Extra DeathLinks are queued."""
    display_name = "DeathLink Cooldown"
    range_start = 10
    range_end   = 30
    default     = 20


class StartingWizardLevel(Range):
    """Wizard level the player starts at, before any XP tomes are collected.

    Setting this above 1 grants bonus wizard levels at game start, giving extra skill points to spend before the run is in full swing. 
    """
    display_name = "Starting Wizard Level"
    range_start = 1
    range_end   = 100
    default     = 1


class DisableEndurance(Toggle):
    """When enabled, Endurance mode is permanently blocked on the stage settings screen.

    Useful for players who want to restrict themselves to Journey mode only, or for seeds where Endurance farming would trivialise progression.
    """
    display_name = "Disable Endurance Mode"
    default = 0


class DisableTrial(Toggle):
    """When enabled, Wizard Trial mode is permanently blocked on the stage settings screen.

    Trial mode has no Archipelago check locations, so it is disabled by default to keep the focus on Journey mode progression.
    """
    display_name = "Disable Trial Mode"
    default = 1


class EnemyHpMultiplier(Range):
    """Percentage multiplier applied to every enemy's HP at the start of each wave.

    100 = no change.  Values below 100 make enemies weaker; values above 100 make enemies tougher. 
    """
    display_name = "Enemy HP Multiplier"
    range_start = 50
    range_end   = 200
    default     = 100


class EnemyArmorMultiplier(Range):
    """Percentage multiplier applied to every enemy's armor level at the start of each wave.

    100 = no change.  Values below 100 make enemies weaker; values above 100 make enemies tougher.
    """
    display_name = "Enemy Armor Multiplier"
    range_start = 50
    range_end   = 200
    default     = 100


class EnemyShieldMultiplier(Range):
    """Percentage multiplier applied to every enemy's shield HP at the start of each wave.

    100 = no change.  Values below 100 make enemies weaker; values above 100 make enemies tougher.
    """
    display_name = "Enemy Shield Multiplier"
    range_start = 50
    range_end   = 200
    default     = 100


class EnemiesPerWaveMultiplier(Range):
    """Percentage multiplier applied to the number of monsters in every wave.

    100 = no change. 150 = 50% more monsters per wave. 50 = half as many. The wave bar tooltip reflects the actual counts you'll face.
    """
    display_name = "Enemies Per Wave Multiplier"
    range_start = 50
    range_end   = 200
    default     = 100


class ExtraWaveCount(Range):
    """Number of additional waves appended to each stage beyond its normal count.

    Extra waves continue the HP/armor scaling curve from the last natural wave.
    Set to 0 to leave stage lengths unchanged.
    """
    display_name = "Extra Wave Count"
    range_start = 0
    range_end   = 24
    default     = 0


class GemPouchGranularity(Choice):
    """How collectible gems on the field are gated by Archipelago items.

    By default GemCraft stages spawn loose gem orbs you can pick up to grow your mana pool. This option lets you lock those orbs behind Gem Pouch items, so stages stay "dry" until you receive a pouch that covers them.

    off:                  Gems are never gated. Every stage spawns gem orbs as normal.
    per_tile:             One pouch per map tile (26 total). A stage spawns no gem orbs until you receive the pouch for its tile.
    per_tile_progressive: 26 generic progressive pouches. Each one you receive unlocks gems on the next tile in a randomized order.
    global:               A single master pouch unlocks gems on every stage at once.

    Whichever mode you pick, your starting stage always has gems available immediately so you can play from the moment you connect.
    """
    display_name = "Gem Pouch Granularity"
    option_off                  = 0
    option_per_tile             = 1
    option_per_tile_progressive = 2
    option_global               = 5
    default = 1


class FieldTokenGranularity(Choice):
    """How coarse the items that unlock new stages are.

    Stages start locked and require Field Tokens to access. This option controls whether each stage has its own token or whole groups of stages unlock together. Coarser settings put fewer unique tokens in the pool but each token unlocks more stages; finer settings give you more individual unlocks but a larger item pool overall.

    Each granularity has a "_progressive" sibling. Progressive variants use a single generic token that appears multiple times in the pool, and the Nth copy you receive unlocks the Nth stage/tile in a randomized order. The in-game effect is identical, but progressive variants tend to produce faster and more reliable seeds.

    per_stage:             One token per stage (122 tokens). Each stage has its own unlock.
    per_stage_progressive: 122 generic tokens. Each one unlocks the next stage in a randomized order.
    per_tile:              One token per map tile (26 tokens). A tile's token unlocks every stage on that tile.
    per_tile_progressive:  26 generic tokens. Each one unlocks the next tile.
    """
    display_name = "Field Token Granularity"
    option_per_stage             = 0
    option_per_stage_progressive = 1
    option_per_tile              = 2
    option_per_tile_progressive  = 3
    default = 2


class StashKeyGranularity(Choice):
    """How coarse the items that unlock Wizard Stashes are.

    Wizard Stashes start locked and need a key to open. This option controls whether each stash needs its own key or groups of stashes unlock together. Coarser settings mean fewer unique keys but each key opens more stashes.

    Like Field Tokens, each granularity has a "_progressive" sibling that uses a generic key. The Nth copy unlocks the Nth stash in a randomized order. The in-game effect is identical, but progressive variants tend to produce faster and more reliable seeds.

    off:                  Stashes are not gated. Every Wizard Stash is open from the start — no keys exist.
    per_tile:             One key per map tile (26 keys). A tile's key unlocks every stash on that tile.
    per_tile_progressive: 26 generic keys. Each one unlocks the next tile's stashes.
    global:               A single master key unlocks every stash at once.
    """
    display_name = "Stash Key Granularity"
    # per_stage was retired — per-stage keys put 122 progression items in the
    # pool for little gameplay gain. Values mirror Gem Pouch Granularity.
    option_off                  = 0
    option_per_tile             = 1
    option_per_tile_progressive = 2
    option_global               = 5

    default = 1


class StartingOvercrowd(Toggle):
    """When enabled, the Overcrowd battle trait is active from the start of the run.

    Overcrowd makes more monsters arrive each wave, increasing the difficulty of every stage from the very start. With this on, you receive Overcrowd up front and it won't appear as a collectible item anywhere in the multiworld.
    """
    display_name = "Start with Overcrowd"
    default = 0


class AchievementRequiredEffort(Choice):
    """How many of the in-game achievements count as Archipelago checks.

    Each level includes every achievement from the levels below it, so the check counts are cumulative. Counts exclude achievements that can't be tracked (RNG-based or hidden ones); disabling Endurance mode removes a few more.

    off:      no achievement checks.
    trivial:  124 checks - collectable through normal vanilla play.
    minor:    335 checks - adds 211 that need some special actions.
    major:    474 checks - adds 139 that need some time investment.
    extreme:  570 checks - adds 96 that need massive time investment and luck.

    Trivial achievements are always included while this option is on, so the randomizer has enough locations for its progression items. More achievements means more checks to find and a longer seed.
    """
    display_name = "Achievement Required Effort"
    option_off      = 0
    option_trivial  = 1
    option_minor    = 2
    option_major    = 3
    option_extreme  = 4
    default = 2


class Difficulty(Choice):
    """Overall randomizer difficulty.

    Fields unlock based on your wizard level, which you raise by clearing fields. Difficulty acts as a bonus or penalty on how much wizard-level progress each clear is worth: Easy clears grant the most, Extreme clears the least, with Medium and Hard in between.
    So the two ends trade off against each other. Easy makes battles forgiving and each win pushes your wizard level up the fastest, so you blow through the unlock gates quickly. Extreme makes battles punishing and each win is worth the least, so the climb to each gate is the slowest and most gradual. The gates themselves sit at the same wizard levels on every difficulty.
    Hard and Extreme MUST have Endurance mode enabled (disable_endurance off): their clears grant little XP, so Endurance runs are the catch-up path to reach the gates if you get stuck. Generation fails if Hard or Extreme is chosen with Endurance disabled.
    """
    display_name = "Difficulty"
    option_easy    = 0
    option_medium  = 1
    option_hard    = 2
    option_extreme = 3
    default = 2


class ExtraShadowCoresPerWave(Range):
    """Mod-only quality-of-life option that makes shadow cores easier to earn.

    Grants this many extra shadow cores for every wave you get through in a battle. The extra cores drop into your normal shadow core pool exactly like vanilla drops, and are banked at the end of the level (on victory or defeat). Beating a 30-wave field at 5 gives 150 extra cores; losing a 50-wave field after 30 waves still gives 150.

    0 disables the feature. This option has no effect on generation, item placement, or logic.
    """
    display_name = "Extra Shadow Cores per Wave"
    range_start = 0
    range_end   = 5
    default     = 2


@dataclass
class GCFWOptions(PerGameCommonOptions):
    goal:                        Goal
    fields_required:             FieldsRequired
    field_token_placement:       FieldTokenPlacement
    field_token_granularity:   FieldTokenGranularity
    stash_key_granularity:     StashKeyGranularity
    gem_pouch_granularity:     GemPouchGranularity
    random_starting_stages:      RandomStartingStages
    starting_stages:             StartingStages
    achievement_required_effort: AchievementRequiredEffort
    difficulty:                Difficulty
    disable_endurance:         DisableEndurance
    disable_trial:             DisableTrial
    xp_tome_bonus:             XpTomeBonus
    starting_overcrowd:        StartingOvercrowd    
    starting_wizard_level:     StartingWizardLevel
    extra_shadow_cores_per_wave: ExtraShadowCoresPerWave
    enemy_hp_multiplier:         EnemyHpMultiplier
    enemy_armor_multiplier:      EnemyArmorMultiplier
    enemy_shield_multiplier:     EnemyShieldMultiplier
    enemies_per_wave_multiplier: EnemiesPerWaveMultiplier
    extra_wave_count:            ExtraWaveCount
    death_link:                DeathLink
    death_link_punishment:     DeathLinkPunishment
    gem_loss_percent:          GemLossPercent
    wave_surge_count:          WaveSurgeCount
    wave_surge_gem_level:      WaveSurgeGemLevel
    spawn_horde_count:         SpawnHordeCount
    spawn_special_elements:    SpawnSpecialElements
    spawn_special_count:       SpawnSpecialCount
    death_link_grace_period:   DeathLinkGracePeriod
    death_link_cooldown:       DeathLinkCooldown
