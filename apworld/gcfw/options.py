from dataclasses import dataclass

from Options import Choice, DeathLink, PerGameCommonOptions, Range, Toggle


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


@dataclass
class GCFWOptions(PerGameCommonOptions):
    goal:                      Goal
    field_token_placement:     FieldTokenPlacement
    tier_requirements_percent: TierRequirementsPercentage
    xp_tome_bonus:             XpTomeBonus
    death_link:                DeathLink
    death_link_punishment:     DeathLinkPunishment
    gem_loss_percent:          GemLossPercent
    wave_surge_count:          WaveSurgeCount
    wave_surge_gem_level:      WaveSurgeGemLevel
    death_link_grace_period:   DeathLinkGracePeriod
    death_link_cooldown:       DeathLinkCooldown
