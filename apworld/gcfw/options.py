from dataclasses import dataclass

from Options import Choice, DeathLink, PerGameCommonOptions, Range, Toggle


class Goal(Choice):
    """What counts as completing GemCraft: Frostborn Wrath.

    beat_game: Defeat the final boss (complete A4).
    full_talisman: Fill all 25 talisman sockets with fragments that each meet the minimum rarity.
    """
    display_name = "Goal"
    option_beat_game = 0
    option_full_talisman = 1
    default = 0


class TalismanMinRarity(Range):
    """Minimum rarity each of the 25 socketed talisman fragments must have to complete
    the full_talisman goal. Higher rarity fragments are harder to find.
    Only used when goal is set to full_talisman.
    """
    display_name = "Talisman Minimum Rarity"
    range_start = 1
    range_end   = 100
    default     = 1


class ForceEarlySkills(Toggle):
    """Whether or not skills should be redistributed to appear roughly uniformly throughout the game.
    The current generation method often results in skills appearing later on average; setting this to true
    will force some skills to appear near the start of the game.
    """
    display_name = "Force Early Skills"
    default = True


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
    talisman_min_rarity:       TalismanMinRarity
    force_early_skills:        ForceEarlySkills
    death_link:                DeathLink
    death_link_punishment:     DeathLinkPunishment
    gem_loss_percent:          GemLossPercent
    wave_surge_count:          WaveSurgeCount
    wave_surge_gem_level:      WaveSurgeGemLevel
    death_link_grace_period:   DeathLinkGracePeriod
    death_link_cooldown:       DeathLinkCooldown
