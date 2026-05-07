from dataclasses import dataclass

from Options import Choice, DeathLink, PerGameCommonOptions, Range, Toggle


class EnforceLogic(Toggle):
    """When enabled, prevents starting out-of-logic stages in Journey mode.

    Journey mode is where Archipelago check locations live. With this on, the Journey start button is disabled for stages whose tier gate is not yet met, forcing the player to follow the randomizer's intended progression order.
    Endurance and Trial modes are unaffected (they have no AP checks).
    """
    display_name = "Enforce Logic"
    default = 0


class StartingStage(Choice):
    """Which early-game stage you start the run on.

    The chosen stage is playable from the menu immediately; every other stage (including the W/S stages you didn't pick) needs to be unlocked through Archipelago. If you're using tile- or tier-based granularity for field tokens or stash keys, the starter's tile/tier is unlocked from the start as well so you can play and collect checks right away.
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

    Rounded up if it doesn't divide evenly. Default of 66% requires 80 of the 122 stages.
    """
    display_name = "Fields Required Percentage"
    range_start = 40
    range_end   = 100
    default     = 66

class XpTomeBonus(Range):
    """Approximate total wizard levels granted by all XP tomes you'll find combined.

    XP tomes come as Tattered Scrolls, Worn Tomes, and Ancient Grimoires (40 in total), with progressively larger level rewards. This option scales their combined value. Lower for a slower XP curve, higher for a faster one.
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
    per_tier:             One pouch per power tier (13 total). Each tier's pouch unlocks gems on every stage of that tier.
    per_tier_progressive: 13 generic progressive pouches. Each one unlocks gems on the next tier.
    global:               A single master pouch unlocks gems on every stage at once.

    Whichever mode you pick, your starting stage always has gems available immediately so you can play from the moment you connect.
    """
    display_name = "Gem Pouch Granularity"
    option_off                  = 0
    option_per_tile             = 1
    option_per_tile_progressive = 2
    option_per_tier             = 3
    option_per_tier_progressive = 4
    option_global               = 5
    default = 2


class FieldTokenGranularity(Choice):
    """How coarse the items that unlock new stages are.

    Stages start locked and require Field Tokens to access. This option controls whether each stage has its own token or whole groups of stages unlock together. Coarser settings put fewer unique tokens in the pool but each token unlocks more stages; finer settings give you more individual unlocks but a larger item pool overall.

    Each granularity has a "_progressive" sibling. Progressive variants use a single generic token that appears multiple times in the pool, and the Nth copy you receive unlocks the Nth stage/tile/tier in a randomized order. The in-game effect is identical, but progressive variants tend to produce faster and more reliable seeds.

    per_stage:             One token per stage (122 tokens). Each stage has its own unlock.
    per_stage_progressive: 122 generic tokens. Each one unlocks the next stage in a randomized order.
    per_tile:              One token per map tile (26 tokens). A tile's token unlocks every stage on that tile.
    per_tile_progressive:  26 generic tokens. Each one unlocks the next tile.
    per_tier:              One token per power tier (13 tokens). A tier's token unlocks every stage in that tier.
    per_tier_progressive:  13 generic tokens. Each one unlocks the next tier.
    """
    display_name = "Field Token Granularity"
    option_per_stage             = 0
    option_per_stage_progressive = 1
    option_per_tile              = 2
    option_per_tile_progressive  = 3
    option_per_tier              = 4
    option_per_tier_progressive  = 5
    default = 3


class StashKeyGranularity(Choice):
    """How coarse the items that unlock Wizard Stashes are.

    Wizard Stashes start locked and need a key to open. This option controls whether each stash needs its own key or groups of stashes unlock together. Coarser settings mean fewer unique keys but each key opens more stashes.

    Like Field Tokens, each granularity has a "_progressive" sibling that uses a generic key. The Nth copy unlocks the Nth stash in a randomized order. The in-game effect is identical, but progressive variants tend to produce faster and more reliable seeds.

    off:                   Stashes are not gated. Every Wizard Stash is open from the start — no keys exist.
    per_stage:             One key per stage (122 keys). Each stash has its own key.
    per_stage_progressive: 122 generic keys. Each one unlocks the next stash in a randomized order.
    per_tile:              One key per map tile (26 keys). A tile's key unlocks every stash on that tile.
    per_tile_progressive:  26 generic keys. Each one unlocks the next tile's stashes.
    per_tier:              One key per power tier (13 keys). A tier's key unlocks every stash in that tier.
    per_tier_progressive:  13 generic keys. Each one unlocks the next tier's stashes.
    global:                A single master key unlocks every stash at once.
    """
    display_name = "Stash Key Granularity"
    option_off                   = 0
    option_per_stage             = 1
    option_per_stage_progressive = 2
    option_per_tile              = 3
    option_per_tile_progressive  = 4
    option_per_tier              = 5
    option_per_tier_progressive  = 6
    option_global                = 7
    
    default = 4


class StartingOvercrowd(Toggle):
    """When enabled, the Overcrowd battle trait is active from the start of the run.

    Overcrowd makes more monsters arrive each wave, increasing the difficulty of every stage from the very start. With this on, you receive Overcrowd up front and it won't appear as a collectible item anywhere in the multiworld.
    """
    display_name = "Start with Overcrowd"
    default = 0


class AchievementRequiredEffort(Choice):
    """How many of the in-game achievements count as Archipelago checks.

    1:    Trivial achievements only (~362 checks).
    2:    Trivial + Minor (~453 checks).
    3:    Trivial + Minor + Major (~537 checks).
    4:    Trivial + Minor + Major + Extreme (~620 checks).
    5:    All achievements (~636 checks).

    Selecting level N includes every achievement up to and including level N. More achievements means more checks to find and a longer seed. Trivial achievements are always included so the randomizer has enough room for the progression items.
    """
    display_name = "Achievement Required Effort"
    option_1   = 1
    option_2   = 2
    option_3   = 3
    option_4   = 4
    option_5   = 5
    default = 1


class SkillpointMultiplier(Range):
    """Adjusts the total skill points you'll earn from Skillpoint Bundle items.

    In the randomizer, the per-achievement skillpoint rewards from vanilla GemCraft are replaced by Skillpoint Bundles found throughout the multiworld. This option scales the total payout from those bundles.

    100 = roughly the same total skill points you would earn in a vanilla full-achievement run. Lower values tighten the skill-point economy; higher values give you more skill points to spend on wizard skills.
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
    field_token_granularity:   FieldTokenGranularity
    stash_key_granularity:     StashKeyGranularity
    gem_pouch_granularity:     GemPouchGranularity
    starting_stage:              StartingStage
    achievement_required_effort: AchievementRequiredEffort        
    disable_endurance:         DisableEndurance
    disable_trial:             DisableTrial
    enforce_logic:             EnforceLogic
    xp_tome_bonus:             XpTomeBonus            
    starting_overcrowd:        StartingOvercrowd    
    starting_wizard_level:     StartingWizardLevel
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
