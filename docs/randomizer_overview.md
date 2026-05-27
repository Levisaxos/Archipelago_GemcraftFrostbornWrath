# GemCraft: Frostborn Wrath — Archipelago Randomizer

A randomizer mod for **GemCraft: Frostborn Wrath** built on the [Archipelago](https://archipelago.gg) multiworld framework. Items the player would normally earn by completing levels are instead shuffled — sent to other players' games, or held back until received from them.

This document describes the full feature set of the randomizer: what is shuffled, how progression is gated, all available YAML options, the in-game UI, and the supported play modes.

---

## What gets randomized

### Locations — 244 base + up to ~636 achievement locations

| Location type | Count | Trigger |
|---|---|---|
| Stage clear — Journey | 122 | Complete any stage in Journey mode |
| Wizard Stash clear | 122 | Defeat the Wizard Stash on any stage |
| Achievements | up to ~636 | Optional, scaled by `achievement_required_effort` (4 tiers, see below) |

### Items

| Item | Count | Notes |
|---|---|---|
| Field Tokens | 122 | Unlock stages across the world map. Granularity is configurable (per-stage, per-tile, or per-tier — each with a progressive sibling). |
| Skills | 24 | Includes the 6 gem-type unlocks (Crit, Leech, Bleed, Armor Tear, Poison, Slow) |
| Battle Traits | 15 | Optional upgrades — one optionally moved to "starting" via YAML (Overcrowd) |
| Talisman Fragments | 53 | Named by original field, e.g. "Z3 Talisman Fragment" — carries the field's original seed and rarity. Vanilla in-game wave drops still cover any additional fragments, so no "extras" are added to the pool. |
| Shadow Core stashes — specific | 17 | Named by original field, e.g. "Z2 Shadow Cores" — original drop amount (totals 120–1200, sum 10,100) |
| Shadow Core stashes — extra | 18 | "Extra Shadow Cores #1–18" — amounts from 200 to 1900 (sum 18,900). Combined with the specifics, the pool delivers 29,000 cores — comfortably above the 25,000 cap used by `shadowCore:N` gates. |
| XP Tomes | 40 | 2 Ancient Grimoires + 6 Worn Tomes + 32 Tattered Scrolls. Total wizard levels granted is configurable. |
| Map Tiles | up to 26 | Optional terrain tiles, depending on starting stage |
| Gem Pouches | variable | Configurable granularity — see below |
| Wizard Stash Keys | variable | Configurable granularity — see below |
| Skillpoint Bundles | filler | Four named tiers (Small/Medium/Large/Huge), per-seed SP values; total scales by `skillpoint_multiplier` |

### Always free (not randomized)

- The selected starting stage is accessible from the menu without a Field Token
- Talisman fragments earned from normal wave completion are untouched
- Shadow cores earned during gameplay are untouched (only Wizard Stash drops are intercepted)

### Item classification

Items are tagged so the Archipelago fill algorithm knows what counts as in-logic-relevant:

**Progression** — required by logic, placed first

- Field Tokens (all 122, plus all coarse / progressive variants)
- Skills (all 24, including the 6 gem-type unlocks)
- Battle Traits (all 15 — many achievement counters require them)
- Map Tiles (all of them)
- Shadow Core stashes (all 17 specific + all 18 extras — the full pool sums into the `shadowCore:N` gate)
- Wizard Stash Keys (per-stage, coarse, and progressive variants)
- Gem Pouches (per-tile, per-tier, master, and progressive variants)
- 25 Talisman Fragments — the highest-rarity fragment in each slot type (4 corner + 12 edge + 9 inner) so the `talismanCornerFragment:N / Edge / Center` counters can be gated
- ~50% of XP Tomes — odd-indexed Tattered Scrolls / Worn Tomes / Ancient Grimoires / Extra XP Items, so `wizardLevel:N` gates can be reasoned about

**Useful** — not required by logic, but worth placing where they help

- The remaining ~28 Talisman Fragments (still drop, just don't gate)
- ~50% of XP Tomes — even-indexed Tattered Scrolls / Worn Tomes / Ancient Grimoires / Extra XP Items

**Filler** — pure pool-padding once the real items are placed

- Skillpoint Bundles — four named tiers (Small/Medium/Large/Huge); per-tier SP value is computed per-seed so the total (scaled by `skillpoint_multiplier`) divides cleanly across the actual filler-slot count

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
| `field_token_granularity` | `per_tile_progressive` | How coarse Field Token items are. Three families — `per_stage` (122 unique tokens), `per_tile` (26, one per map-tile prefix), `per_tier` (13, one per power tier) — each with a `_progressive` sibling that uses a single fungible item ordered by play order. |
| `enforce_logic` | `false` | When enabled, prevents starting out-of-logic stages in Journey mode |
| `xp_tome_bonus` | `150` | Approximate total wizard levels granted by all XP tomes combined (50–300). Scales tomes in a 1:2:3 ratio. |
| `starting_wizard_level` | `1` | Wizard level granted at the start of the run, before any tomes (1–100) |
| `starting_overcrowd` | `false` | Start with the Overcrowd battle trait. Removes Overcrowd from the item pool. |
| `skillpoint_multiplier` | `100` | Total skill points distributed as filler bundles, as a percentage of the 2500-SP baseline |

### Stash & gem gating

| Option | Default | Description |
|---|---|---|
| `stash_key_granularity` | `per_tile_progressive` | Wizard Stashes start locked. Same `per_stage` / `per_tile` / `per_tier` families as Field Tokens (each with a `_progressive` sibling), plus a `global` option that uses one master key for every stash, and an `off` option that leaves every stash unlocked from the start. |
| `gem_pouch_granularity` | `per_tile_progressive` | Gates gem-orb spawns behind Gem Pouch items. Options: `off`, `per_tile`, `per_tile_progressive`, `per_tier`, `per_tier_progressive`, `global`. |

### Difficulty

| Option | Default | Description |
|---|---|---|
| `disable_endurance` | `false` | Permanently disables Endurance mode |
| `disable_trial` | `true` | Permanently disables Trial mode (no AP checks there) |
| `enemy_hp_multiplier` | `100` | Enemy HP as a percentage of normal (50–200) |
| `enemy_armor_multiplier` | `100` | Enemy armor as a percentage of normal (50–200) |
| `enemy_shield_multiplier` | `100` | Enemy shield HP as a percentage of normal (50–200) |
| `enemies_per_wave_multiplier` | `100` | Enemies per wave as a percentage of normal (50–200) |
| `extra_wave_count` | `0` | Extra waves appended to each stage beyond its normal length (0–24) |

### Achievements

| Option | Default | Description |
|---|---|---|
| `achievement_required_effort` | `1` | Effort tier of achievements to include as locations. Integer `1`–`4`: `1` Trivial only (~362), `2` +Minor (~453), `3` +Major (~537), `4` +Extreme (~636). Untrackable achievements are excluded. |

### DeathLink

| Option | Default | Description |
|---|---|---|
| `death_link` | `false` | Enables DeathLink with other players in the session |
| `death_link_punishment` | `gem_loss` | What happens on a received DeathLink: `gem_loss`, `wave_surge`, `instant_fail`, `spawn_horde`, or `spawn_special` |
| `gem_loss_percent` | `20` | Percentage of placed gems destroyed on `gem_loss` (10–50) |
| `wave_surge_count` | `3` | Number of enraged waves injected on `wave_surge` (1–10) |
| `wave_surge_gem_level` | `3` | Gem level used for the surge enrage multiplier (1–9) |
| `spawn_horde_count` | `100` | Number of vanilla-strength monsters spawned on `spawn_horde` (50–500) |
| `spawn_special_elements` | all five | Special enemy types eligible for `spawn_special`: `Apparition`, `Specter`, `Wraith`, `Spire`, `Wizard Hunter` |
| `spawn_special_count` | `5` | Number of specials spawned on `spawn_special` (1–10), each picked at random from `spawn_special_elements` and scaled to ~10 waves above the current one |
| `death_link_grace_period` | `15` | Seconds of immunity at the start of each stage (10–30) |
| `death_link_cooldown` | `20` | Minimum seconds between two punishments (10–30) |

---

## Hollow Gem

When Gem Pouches are enabled, you can't create gems on a stage until you've received a Gem Pouch covering that gem type — which would leave you stuck on your very first stage with nothing to fight back with. The **Hollow Gem** is your starter tool:

- On your starter stage, while you don't yet own a Gem Pouch, an extra **"Create Hollow Gem"** button appears alongside the normal gem-create buttons.
- A Hollow Gem is a plain, colorless gem with **no special effect** — no leech, no crit, no slow, no poison. It hits for the minimum damage in the game. Just enough to clear early waves and start earning real items.
- Combining or duplicating Hollow Gems works normally — the result stays hollow.
- **Free starter towers (Frostborn mode):** Chilling already grants 3 free buildings at level start, but Frostborn normally grants 0. While Hollow Gem is active on a Frostborn stage, you get up to **3 free towers** at the start of the level (topped up to 3 minus any pre-placed towers on that stage), so you have something to socket your Hollow Gems into.
- The button **disappears automatically** as soon as you receive a Gem Pouch for that stage. From then on you create gems the normal way.
- Costs the same mana as a regular gem create.

In short: Hollow Gem keeps your run playable from turn one when Gem Pouches are gating your gem types.

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
- **Endurance / Trial** — togglable in YAML; neither has AP checks.

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
