# GemCraft: Frostborn Wrath — Archipelago Randomizer

A randomizer mod for **GemCraft: Frostborn Wrath** built on the [Archipelago](https://archipelago.gg) multiworld framework. Items the player would normally earn by completing levels are instead shuffled — sent to other players' games, or held back until received from them.

This release covers the full feature set of the randomizer: what is shuffled, how progression is gated, all available YAML options, the in-game UI, and the supported play modes.

---

## What gets randomized

### Locations — 244 base + up to ~537 achievement locations

| Location type | Count | Trigger |
|---|---|---|
| Stage clear — Journey | 122 | Complete any stage in Journey mode |
| Wizard Stash clear | 122 | Defeat the Wizard Stash on any stage |
| Achievements | up to ~537 | Optional, scaled by `achievement_required_effort` |

### Items

| Item | Count | Notes |
|---|---|---|
| Field Tokens | 122 | Unlock stages across the world map. Granularity is configurable (per-stage, per-region, world-aligned, or progressive). |
| Skills | 24 | Includes the 6 gem-type unlocks (Crit, Leech, Bleed, Armor Tear, Poison, Slow) |
| Battle Traits | 15 | Optional upgrades — one optionally moved to "starting" via YAML (Overcrowd) |
| Talisman Fragments | 53 | Named by original field, e.g. "Z3 Talisman Fragment" — carries the field's original seed and rarity. Vanilla in-game wave drops still cover any additional fragments, so no "extras" are added to the pool. |
| Shadow Core stashes — specific | 17 | Named by original field, e.g. "Z2 Shadow Cores" — original drop amount (totals 120–1200, sum 10,100) |
| Shadow Core stashes — extra | 18 | "Extra Shadow Cores #1–18" — amounts from 200 to 1900 (sum 18,900). Combined with the specifics, the pool delivers 29,000 cores — comfortably above the 25,000 cap used by `shadowCore:N` gates. |
| XP Tomes | 40 | 2 Ancient Grimoires + 6 Worn Tomes + 32 Tattered Scrolls. Total wizard levels granted is configurable. |
| Map Tiles | up to 26 | Optional terrain tiles, depending on starting stage |
| Gem Pouches | variable | Configurable granularity — see below |
| Wizard Stash Keys | variable | Configurable granularity — see below |
| Skillpoint Bundles | filler | Sized 1–10 SP each, count scaled by `skillpoint_multiplier` |

### Always free (not randomized)

- The selected starting stage is accessible from the menu without a Field Token
- Talisman fragments earned from normal wave completion are untouched
- Shadow cores earned during gameplay are untouched (only Wizard Stash drops are intercepted)

---

## Goals

| Value | Description |
|---|---|
| `kill_gatekeeper` *(default)* | Kill the Gatekeeper on stage A4 |
| `kill_swarm_queen` | Kill the Swarm Queen on stage K4 |
| `fields_count` | Complete a fixed number of Journey stages (`fields_required`, 50–122) |
| `fields_percentage` | Complete a percentage of all Journey stages (`fields_required_percentage`, 40–100) |

---

## YAML options

### Goal & progression

| Option | Default | Description |
|---|---|---|
| `goal` | `kill_gatekeeper` | Win condition (see above) |
| `fields_required` | `80` | Used when `goal = fields_count` (50–122) |
| `fields_required_percentage` | `66` | Used when `goal = fields_percentage` (40–100) |
| `starting_stage` | `random` | Choose one of W1–W4 / S1–S4, or randomize per seed |
| `field_token_placement` | `any_world` | Where Field Tokens may be placed: `any_world`, `own_world`, or `different_world` (multiplayer required) |
| `field_token_granularity` | per-stage | How coarse Field Token items are — also has `_progressive` siblings that use a single fungible item type ordered by tier |
| `tier_requirements_percent` | `75` | Percentage of earlier-tier stages that must be accessible before later tiers are considered in logic (40–100). Lower values may demand heavier Endurance use. |
| `enforce_logic` | `false` | When enabled, prevents starting out-of-logic stages in Journey mode |
| `xp_tome_bonus` | `150` | Approximate total wizard levels granted by all XP tomes combined (50–300). Scales tomes in a 1:2:3 ratio. |
| `starting_wizard_level` | `1` | Wizard level granted at the start of the run, before any tomes (1–100) |
| `starting_overcrowd` | `false` | Start with the Overcrowd battle trait. Removes Overcrowd from the item pool. |
| `skillpoint_multiplier` | `100` | Total skill points distributed as filler bundles, as a percentage of the 2000-SP baseline |

### Stash & gem gating

| Option | Default | Description |
|---|---|---|
| `stash_key_granularity` | per-stage | Wizard Stashes start locked. Keys can be per-stage, per-region, world-aligned, or progressive. |
| `gem_pouch_granularity` | `off` | When enabled, gem-orb spawns are gated behind Gem Pouch items (per-gem, per-region, or progressive) |

### Difficulty

| Option | Default | Description |
|---|---|---|
| `disable_endurance` | `false` | Permanently disables Endurance mode |
| `disable_trial` | `true` | Permanently disables Trial mode (no AP checks there) |
| `enemy_hp_multiplier` | `100` | Enemy HP as a percentage of normal (50–200) |
| `enemy_armor_multiplier` | `100` | Enemy armor as a percentage of normal (50–200) |
| `enemy_shield_multiplier` | `100` | Enemy shield HP as a percentage of normal (50–200) |
| `enemies_per_wave_multiplier` | `100` | Enemies per wave as a percentage of normal (50–200) |
| `extra_wave_count` | `0` | Extra waves appended to each stage beyond its normal length (0–20) |

### Achievements

| Option | Default | Description |
|---|---|---|
| `achievement_required_effort` | none | Tier of achievements to include as locations: `trivial` (~362), `trivial+minor` (~453), `trivial+minor+major` (~537). Untrackable achievements are excluded. |

### DeathLink

| Option | Default | Description |
|---|---|---|
| `death_link` | `false` | Enables DeathLink with other players in the session |
| `death_link_punishment` | `gem_loss` | What happens on a received DeathLink: `gem_loss`, `wave_surge`, or `instant_fail` |
| `gem_loss_percent` | `20` | Percentage of placed gems destroyed on `gem_loss` (10–50) |
| `wave_surge_count` | `3` | Number of enraged waves injected on `wave_surge` (1–10) |
| `wave_surge_gem_level` | `5` | Gem level used for the surge enrage multiplier (1–9) |
| `death_link_grace_period` | `15` | Seconds of immunity at the start of each stage (10–30) |
| `death_link_cooldown` | `20` | Minimum seconds between two punishments (10–30) |

---

## In-game UI

- **Connection panel** — opens automatically on slot select. Enter host, port, slot, password and connect, or click **Play without randomizer** for a vanilla run.
- **Disconnect panel** — re-enter connection details mid-session.
- **Standalone mode** — the mod can run without an Archipelago server; the game falls back to vanilla progression. Switching from standalone to AP mid-save is handled cleanly (achievements no longer persist incorrectly across the boundary).
- **Drop icons** — every item type has a custom drop icon: Field Tokens, Map Tiles, XP Tomes, Skill Tomes, Battle Trait Scrolls, Skillpoints, Gem Pouches, Tile Pouches, Key Pouches, Wizard Stash Keys, and a generic Archipelago icon for items being sent to other worlds.
- **Achievement window** — in-game panel listing every achievement available on the current stage, with a search bar and group filtering. Untrackable achievements are flagged.
- **Field tooltip** — hovering a stage shows in-logic status, stage elements (gem types, traits, etc.), and Wizard Stash lock state.
- **Offline summary collector** — a panel that surfaces all checks completed while disconnected so they can be flushed when you reconnect.
- **Message log** — scrollable history of all Archipelago messages. Toggle with the **backtick** (`` ` ``) key, scroll with mouse wheel. Persisted per slot to `slot_N_log.jsonl` and reloaded on reopen.
- **Item toasts** — receive notifications with the proper item name for every category.
- **Changelog panel** — in-game changelog viewer.
- **Slot settings panel** — per-slot configuration UI inside the game.

---

## Client behavior

- **Full Archipelago protocol support** — Connect, Connected, ReceivedItems, LocationChecks, StatusUpdate, PrintJSON, Bounced.
- **Full sync on reconnect** — deduplicates by seed for talismans, delta-grants for shadow cores, idempotent for everything else.
- **Auto-reconnect** with backoff.
- **Slot file persistence** — host, port, slot, password, granted items, completion state, deathLinkEnabled, standalone flag.
- **Win condition** fires correctly for every supported goal type.
- **Progression blocker** reverts vanilla grants of field tokens, map tiles, skills, traits, shadow cores, and Wizard Stash talisman fragments so they only arrive through Archipelago.

---

## Supported modes

- **Chilling** — supported
- **Frostborn** — supported
- **Iron Wizard** — *not supported*
- **Endurance / Trial** — togglable in yaml; Neither has no AP checks.

---

## Known limitations (pre-alpha)

- Iron Wizard mode is not supported
- DeathLink is implemented but may have edge cases
- Some achievements are flagged "untrackable" and excluded from the location pool
- This is an early pre-alpha — feedback is very welcome via GitHub Issues

---

## Installation

See the [README](../README.md) for full setup steps:
1. Install **BezelModLoader** for GemCraft: Frostborn Wrath
2. Drop `ArchipelagoMod.swf` into the game's `Mods` folder
3. Drop `gcfw.apworld` into Archipelago's `lib/worlds` folder
4. Generate or join a multiworld that includes `gcfw`
5. Launch the game, pick a slot, and connect via the in-game panel

---

## Credits

- **Game**: GemCraft: Frostborn Wrath by Game in a Bottle
- **Mod loader**: [BezelModLoader](https://github.com/gemforce-team/BezelModLoader)
- **Decompiler**: [JPEXS Free Flash Decompiler](https://github.com/jindrapetrik/jpexs-decompiler)
- **Compiler**: [Harman AIR SDK](https://airsdk.harman.com/)
- **Framework**: [Archipelago](https://archipelago.gg)
- Linux/Wine setup contributed by **Xindage**
