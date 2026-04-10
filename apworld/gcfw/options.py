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

    beat_game:        Defeat the final boss (complete A4) with all 24 skills unlocked.
    kill_swarm_queen: Kill the Swarm Queen on K4. Requires all 24 skills (same as
                     beat_game) but the final objective is K4 instead of A4.
    """
    display_name = "Goal"
    option_beat_game = 0
    option_kill_swarm_queen = 2
    default = 0

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


class TierRequirementsPercentage(Range):
    """Logic is currently determined by grouping stages into tiers based on difficulty, then requiring a percentage of the
    stages in all previous tiers to be accessible in order to consider the next tier accessible.
    This setting determines what that percentage is. Lower values may require heavy usage of endurance mode to progress. Rounds down.
    """
    display_name = "Tier Completion Percentage"
    range_start = 40
    range_end = 100
    default = 75


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
    range_end   = 20
    default     = 0


class StartingOvercrowd(Toggle):
    """When enabled, the Overcrowd battle trait is added to the player's starting inventory.

    Overcrowd makes more monsters arrive each wave, increasing the difficulty
    of every stage from the very start of the run.  The trait is removed from the
    randomised item pool — it will not appear as a collectable item for anyone.
    """
    display_name = "Starting Overcrowd"
    default = 0


@dataclass
class GCFWOptions(PerGameCommonOptions):
    goal:                      Goal
    field_token_placement:     FieldTokenPlacement
    tier_requirements_percent: TierRequirementsPercentage
    xp_tome_bonus:             XpTomeBonus
    enforce_logic:             EnforceLogic
    disable_endurance:         DisableEndurance
    disable_trial:             DisableTrial
    starting_wizard_level:     StartingWizardLevel
    starting_overcrowd:        StartingOvercrowd
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
