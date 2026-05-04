# 0.1.0 — First Beta

First public beta of the GemCraft: Frostborn Wrath Archipelago randomizer. See [randomizer_overview.md](randomizer_overview.md) for the full feature breakdown.

## Highlights

- Connect to an Archipelago multiworld and play GCFW with shuffled progression
- Standalone mode lets you launch the mod without a server (vanilla progression)
- 244 base location checks across all 122 stages, plus optional achievement checks

## Items in the pool

- 122 Field Tokens — the primary stage-unlock currency
- 24 Skill tomes (including the 6 gem-type unlocks)
- 15 Battle Traits
- 53 Talisman Fragments (named by their original field)
- 35 Shadow Core stashes (17 specific + 18 extras)
- 40 XP Tomes (Tattered Scrolls, Worn Tomes, Ancient Grimoires)
- Up to 26 Map Tiles
- Gem Pouches, Wizard Stash Keys, and Skillpoint Bundles

## Locations

- 122 Journey-clear checks (one per stage)
- 122 Wizard Stash checks (one per stage, stashes start locked)
- Up to ~537 optional achievement checks

## Goals

- Kill the Gatekeeper (A4)
- Kill the Swarm Queen (K4)
- Complete a fixed number of Journey stages
- Complete a percentage of all Journey stages

## YAML options

- Choose your starting stage (W1–W4 / S1–S4 / random)
- Field Token granularity: per-stage, per-tile, per-tier, or progressive
- Wizard Stash Key granularity: same options
- Gem Pouch granularity: same options, or off
- Field Token placement: any world, own world only, or other worlds only
- Tier-requirement percentage controls how strict logic is
- XP tome bonus and starting wizard level are configurable
- Optional starting Overcrowd trait
- Skillpoint multiplier for filler skill points
- Difficulty multipliers: enemy HP, armor, shield, count, and extra waves
- Achievement effort tier: trivial / minor / major
- Toggle Endurance and Trial modes

## DeathLink

- Three punishment types: gem loss, wave surge, instant fail
- Configurable grace period and cooldown

## Hollow Gem

- A starter tool when Gem Pouches are enabled — lets you create plain colorless gems on your starter stage until your first real Gem Pouch arrives
- Frostborn-mode bonus: up to 3 free starter towers while Hollow Gem is active

## In-game UI

- Connection and disconnect panels
- Achievement browser with search and group filtering
- Field tooltip showing in-logic status, stage elements, and stash lock state
- Offline summary collector for checks completed while disconnected
- Custom drop icons for every item category
- Item-receive toasts with proper names
- Persistent scrollable message log (toggle with `` ` ``)
- Per-slot settings panel
- In-game changelog viewer

## Client

- Full Archipelago protocol support
- Auto-reconnect with backoff
- Full state sync on reconnect (deduplicated, idempotent)
- Win condition fires correctly for every goal type

## Supported modes

- Chilling and Frostborn

## Known limitations

- Iron Wizard mode is not supported
- DeathLink may have edge cases
- Some achievements are flagged "untrackable" and excluded from the location pool
- Archipelago tooltip additions can sometimes appear in the wrong place — e.g. a level tooltip showing up while hovering a trait or achievement
- This is a beta — feedback welcome on GitHub Issues

## Install

1. Install **BezelModLoader**
2. Drop `ArchipelagoMod.swf` in the game's `Mods` folder
3. Drop `gcfw.apworld` in Archipelago's `lib/worlds` folder
4. Generate or join a multiworld that includes `gcfw`
5. Launch the game, pick a slot, and connect from the in-game panel

See the [README](../README.md) for full setup details.
