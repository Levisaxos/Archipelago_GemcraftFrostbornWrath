from dataclasses import dataclass

from Options import Choice, DeathLink, PerGameCommonOptions, Range, Toggle


class EnforceLogic(Toggle):
    """When enabled, prevents starting out-of-logic stages in Journey mode.

    Journey mode is where Archipelago check locations live. With this on, the
    Journey start button is disabled for stages whose tier gate is not yet met,
    forcing the player to follow the randomizer's intended progression order.

    Endurance and Trial modes are unaffected (they have no AP checks).
    """
    display_name = "Enforce Logic"
    default = 0


class StartingStage(Choice):
    """Which early-game stage you start the run on.

    The chosen stage is accessible from the menu without a Field Token; all
    other stages (including the W/S stages you didn't pick) require their
    own token plus a clearable prereq stage.

    Default 'random' picks one of W1-W4 / S1-S4 each generation.
    """
    display_name = "Starting Stage"
    option_w1 = 0
    option_w2 = 1
    option_w3 = 2
    option_w4 = 3
    option_s1 = 4
    option_s2 = 5
    option_s3 = 6
    option_s4 = 7
    default = "random"


# Map StartingStage option int -> stage str_id. Order matches the option_* values
# above. Imported by __init__.py and rules.py to resolve the chosen start.
STARTING_STAGE_BY_VALUE = {
    StartingStage.option_w1: "W1",
    StartingStage.option_w2: "W2",
    StartingStage.option_w3: "W3",
    StartingStage.option_w4: "W4",
    StartingStage.option_s1: "S1",
    StartingStage.option_s2: "S2",
    StartingStage.option_s3: "S3",
    StartingStage.option_s4: "S4",
}


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
    fields_percentage:  Complete a percentage of all Journey stages (set by Fields Required Percentage).
    """
    display_name = "Goal"
    option_kill_gatekeeper    = 0
    option_kill_swarm_queen   = 2
    option_fields_count       = 3
    option_fields_percentage  = 4
    default = 0


class FieldsRequired(Range):
    """Number of Journey stages that must be completed to win.
    Only used when Goal is set to 'fields_count'.

    The game has 122 stages total.
    """
    display_name = "Fields Required"
    range_start = 50
    range_end   = 122
    default     = 80


class FieldsRequiredPercentage(Range):
    """Percentage of Journey stages that must be completed to win.
    Only used when Goal is set to 'fields_percentage'.

    The required field count is ceil(percentage × 122 / 100).
    Default of 66% requires exactly 80 fields (ceil(66 × 122 / 100) = 80).
    """
    display_name = "Fields Required Percentage"
    range_start = 40
    range_end   = 100
    default     = 66

class XpTomeBonus(Range):
    """Approximate total wizard levels granted by all XP tomes in the item pool combined.

    The pool contains 32 Tattered Scrolls, 6 Worn Tomes, and 2 Ancient Grimoires.
    Their per-tome level values are scaled in a 1:2:3 ratio to hit the target total.

    At the default of 100 each tome gives 1 / 2 / 3 levels (118 total).
    Values below ~100 all resolve to the same minimum (1/2/3 levels, ~118 total).
    At 200 tomes give roughly 2/3/5 levels (~224 total).
    At 300 tomes give roughly 3/5/8 levels (~342 total).
    """
    display_name = "XP Tome Bonus"
    range_start = 50
    range_end   = 300
    default     = 150


class DeathLinkPunishment(Choice):
    """What happens when a DeathLink signal is received.

    gem_loss:    A percentage of placed gems (and their towers/traps) are destroyed.
    wave_surge:  A set of enraged waves is injected immediately.
    instant_fail: The current level fails immediately (traditional DeathLink).
    """
    display_name = "DeathLink Punishment"
    option_gem_loss    = 0
    option_wave_surge  = 1
    option_instant_fail = 2
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

    Setting this above 1 grants bonus wizard levels at game start, giving extra
    skill points to spend before the run is in full swing.  Useful for runs where
    you want to skip early skill-grinding and get into the interesting decisions
    faster.  Has no effect on tier logic or item placement.
    """
    display_name = "Starting Wizard Level"
    range_start = 1
    range_end   = 100
    default     = 1


class DisableEndurance(Toggle):
    """When enabled, Endurance mode is permanently blocked on the stage settings screen.

    Useful for players who want to restrict themselves to Journey mode only,
    or for seeds where Endurance farming would trivialise progression.
    """
    display_name = "Disable Endurance Mode"
    default = 0


class DisableTrial(Toggle):
    """When enabled, Wizard Trial mode is permanently blocked on the stage settings screen.

    Trial mode has no Archipelago check locations, so it is disabled by default to
    keep the focus on Journey mode progression.
    """
    display_name = "Disable Trial Mode"
    default = 1


class EnemyHpMultiplier(Range):
    """Percentage multiplier applied to every enemy's HP at the start of each wave.

    100 = no change.  Values below 100 make enemies weaker; values above 100
    make enemies tougher.  Applied once per monster when it first enters the
    field — does not stack with DeathLink wave surges.
    """
    display_name = "Enemy HP Multiplier"
    range_start = 50
    range_end   = 200
    default     = 100


class EnemyArmorMultiplier(Range):
    """Percentage multiplier applied to every enemy's armor level at the start of each wave.

    100 = no change.  Values below 100 make enemies weaker; values above 100
    make enemies tougher.
    """
    display_name = "Enemy Armor Multiplier"
    range_start = 50
    range_end   = 200
    default     = 100


class EnemyShieldMultiplier(Range):
    """Percentage multiplier applied to every enemy's shield HP at the start of each wave.

    100 = no change.  Values below 100 make enemies weaker; values above 100
    make enemies tougher.
    """
    display_name = "Enemy Shield Multiplier"
    range_start = 50
    range_end   = 200
    default     = 100


class EnemiesPerWaveMultiplier(Range):
    """Percentage multiplier applied to the number of monsters in every wave.

    100 = no change.  150 = 50% more monsters per wave.  50 = half as many.
    Applied to wave definitions before the first wave spawns, so the wave bar
    tooltip reflects the real counts.
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
    """How gem availability per stage is gated by Archipelago items.

    off:         No gempouches. Stages keep their original `gemSkills: N` gate
                 (collect N of the 6 gem-skill items); gem orbs spawn freely
                 in every level.
    distinct:    26 named pouches (one per stage-prefix letter / tile). A stage
                 in prefix X spawns no gem orbs at all until you collect
                 `Gempouch (X)`. Replaces `gemSkills: N` on every stage.
    progressive: 26 copies of `Progressive Gempouch` in play order
                 (W, S, V, R, Q, P, O, N, M, L, K, J, I, H, G, F, E, D, C, B,
                 A, Z, Y, X, U, T). The Nth copy unlocks the Nth world in that
                 order. Spoiler log shows fungible items but fill is more
                 forgiving.
    per_tier:    13 named pouches (one per power tier, 0-12). Stages unlock
                 gem orbs once you collect their tier's pouch. Coarser than
                 distinct — fewer items in the pool but unlocks chunks of
                 stages at a time.
    global:      1 master pouch unlocks gems on every stage at once.

    distinct, progressive, per_tier, and global all pre-collect the gating
    item that covers the chosen starting stage so the seed is solvable from
    frame zero.
    """
    display_name = "Gem Pouch Granularity"
    option_off                  = 0
    option_per_tile_distinct    = 1
    option_per_tile_progressive = 2
    option_per_tier             = 3
    option_global               = 4
    default = 1


class FieldTokenGranularity(Choice):
    """How coarse Field Token items are. Coarser = fewer unique items in the
    pool, larger swaths of stages unlocked per item. Lower density of
    progression items overall, achievement locations drift toward filler.

    per_stage: One token per stage (122 tokens total). Original behaviour.
    per_tile:  One token per stage prefix / map tile (26 tokens). Collecting
               `<Prefix> Tile Field Token` unlocks every stage starting with
               that prefix.
    per_tier:  One token per power tier (13 tokens, 0-12). Collecting
               `Tier <N> Field Token` unlocks every stage in that tier.

    The starting stage's covering token is precollected so Menu->starter
    still works regardless of which mode is chosen.
    """
    display_name = "Field Token Granularity"
    option_per_stage = 0
    option_per_tile  = 1
    option_per_tier  = 2
    default = 1


class StashKeyGranularity(Choice):
    """How coarse Wizard Stash Key items are.

    per_stage: One key per stage (122 keys total). Original behaviour.
    per_tile:  One key per stage prefix / map tile (26 keys). Collecting
               `<Prefix> Stash Tile Key` unlocks every stash starting with
               that prefix.
    per_tier:  One key per power tier (13 keys, 0-12). Collecting
               `Tier <N> Stash Key` unlocks every stash in that tier.
    global:    A single `Master Stash Key` unlocks every stash at once.

    The starting stage's covering key is precollected so the player can
    immediately collect the starter's stash check.
    """
    display_name = "Stash Key Granularity"
    option_per_stage = 0
    option_per_tile  = 1
    option_per_tier  = 2
    option_global    = 3
    default = 1


class StartingOvercrowd(Toggle):
    """When enabled, the Overcrowd battle trait is added to the player's starting inventory.

    Overcrowd makes more monsters arrive each wave, increasing the difficulty
    of every stage from the very start of the run.  The trait is removed from the
    randomised item pool — it will not appear as a collectable item for anyone.
    """
    display_name = "Start with Overcrowd"
    default = 0


class AchievementRequiredEffort(Choice):
    """Required effort level of achievements to include in the randomizer.

    1:    Trivial achievements only (~362 achievements).
    2:    Trivial + Minor (~453 achievements).
    3:    Trivial + Minor + Major (~537 achievements).
    4:    Trivial + Minor + Major + Extreme (~620 achievements).
    5:    All achievements (~636 achievements).

    Selecting level N includes all achievements from levels 1 through N.
    More achievements = more items to find, longer seed.

    Trivial achievements are always included (minimum is 1): the progression
    item pool requires their locations to fit.
    """
    display_name = "Achievement Required Effort"
    option_1   = 1
    option_2   = 2
    option_3   = 3
    option_4   = 4
    option_5   = 5
    default = 1


class AchievementProgression(Choice):
    """How progressive achievements are handled.

    progressive: Achievement chains are linked. For example, "Kill 10 Waves" must be obtained
                 before "Kill 20 Waves" can be collected. This spreads achievements across
                 spheres naturally and matches how Terraria does it in Archipelago.

    single:      All achievements are independent with no chaining. "Kill 10 Waves", "Kill 20 Waves",
                 etc. are all treated as separate items with no dependencies.
    """
    display_name = "Achievement Progression"
    option_progressive = 0
    option_single      = 1
    default = 0


class SkillpointMultiplier(Range):
    """Total skill points distributed via Skillpoint Bundle filler items, as a
    percentage of the 2000 SP baseline.

    Bundles are sized 1-10 SP each (skewed small), and the count of bundles is
    determined by the remaining filler slots after all real items are placed.

    Mod-side suppresses vanilla per-achievement SP rewards (see
    AchievementUnlocker.suppressVanillaAchievementSp), so AP bundles are the
    primary source of skill points. 100 = ~2000 SP from bundles, in the same
    order of magnitude as vanilla's full achievement payout. Lower for tighter
    SP economies, higher for abundance.
    """
    display_name = "Skillpoint Multiplier"
    range_start = 50
    range_end   = 200
    default     = 100


@dataclass
class GCFWOptions(PerGameCommonOptions):
    goal:                        Goal
    fields_required:             FieldsRequired
    fields_required_percentage:  FieldsRequiredPercentage
    field_token_placement:       FieldTokenPlacement
    starting_stage:              StartingStage
    xp_tome_bonus:             XpTomeBonus
    enforce_logic:             EnforceLogic
    disable_endurance:         DisableEndurance
    disable_trial:             DisableTrial
    starting_wizard_level:     StartingWizardLevel
    starting_overcrowd:        StartingOvercrowd
    achievement_required_effort: AchievementRequiredEffort
    achievement_progression:   AchievementProgression
    field_token_granularity:   FieldTokenGranularity
    stash_key_granularity:     StashKeyGranularity
    gem_pouch_granularity:     GemPouchGranularity
    skillpoint_multiplier:     SkillpointMultiplier
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
    death_link_grace_period:   DeathLinkGracePeriod
    death_link_cooldown:       DeathLinkCooldown
