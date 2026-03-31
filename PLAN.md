# Project Plan — GemCraft: Frostborn Wrath Archipelago Randomizer

## Overview

The goal is to integrate GemCraft: Frostborn Wrath into the [Archipelago](https://archipelago.gg) multiworld randomizer framework. Items the player would normally earn by completing levels are instead shuffled — sent to other players' games or held back until received from them.

This document tracks the plan of action, phase by phase.

---

## Architecture

Two components must be built:

### 1. `apworld` (Python — runs on the Archipelago server)
Defines the game to the Archipelago server:
- All **items** (things that can be in the item pool)
- All **locations** (things the player checks / completes)
- **Logic rules** (what items are needed to reach what locations)
- **Goal conditions** (what counts as "game complete")
- **Player YAML options** (what the player can configure for their seed)

### 2. Bezel Mod (ActionScript — runs inside the game)
The in-game client:
- Connects to the Archipelago server via WebSocket
- Intercepts level completion events to **send checks** (tell the server a location was completed)
- Receives items from the server and **grants them** in-game
- Persists received items across sessions (what has been given must not be given again on reload)

---

## What gets shuffled

### Items (366 total)

| Item type | Count | Notes |
|---|---|---|
| Field Tokens | 118 | Unlock stages on the map — primary progression gates |
| Skills | 24 | Includes 6 gem-type unlocks (Crit, Leech, Bleed, Armor Tear, Poison, Slow) |
| Battle Traits | 15 | Optional upgrades |
| Talisman Fragments (specific) | 53 | Named by original field, carries original seed/rarity |
| Talisman Fragments (extra) | 47 | "Extra Talisman Fragment #1–47", rarity 2–94 evenly spread |
| Shadow Core Stashes (specific) | 17 | Named by original field, original amount |
| Shadow Core Stashes (extra) | 52 | "Extra Shadow Cores #1–52", amounts 60–1080 |
| XP Tomes | 40 | 2 Ancient Grimoires + 6 Worn Tomes + 32 Tattered Scrolls |

### Locations (366 total)

| Location type | Count | Trigger |
|---|---|---|
| Stage clear — Journey | 122 | Complete any stage in Journey mode |
| Stage clear — Bonus | 122 | Reach 50+ waves in Journey mode |
| Wizard stash clear | 122 | Defeat the wizard stash on any stage |

### Always free (not randomized)
- W1 is the starting stage
- W2, W3, W4 unlock automatically on AP connect
- Talisman fragments from wave completion (untouched)
- Shadow cores from normal gameplay (untouched — only stash grants are intercepted)

---

## Goals

### Default goal — Beat the game
**"The Frostborn Wrath"** — defeat the final boss by completing stage **A4** with all 24 skills unlocked.

### Optional goal — Full Talisman *(disabled — not yet tested)*
Fill all 25 talisman sockets with fragments each meeting a minimum rarity (configurable).

---

## Phases

---

### Phase 0 — Research & Feasibility ✅

- [x] Identify "game beaten" trigger — A4 completion with all 24 skills
- [x] Confirm item grant functions work without side effects
- [x] `SAVE_SAVE` hook sufficient for progression blocking
- [x] WebSocket confirmed working in AIR runtime
- [x] Counted all skill tomes (24), battle traits (15), stages (122)

---

### Phase 1 — Core Mod: Item Grant & Location Check System ✅

- [x] `unlockStage(stageStrId)` — field token grant
- [x] `unlockSkill(apId)` — skill tome grant with toast
- [x] `unlockBattleTrait(apId)` — battle trait grant with toast
- [x] `grantXpBonus(apId)` — wizard level grant (Tattered Scroll / Worn Tome / Ancient Grimoire)
- [x] `grantFragment(apId)` — talisman fragment grant by seed/rarity/type
- [x] `grantShadowCores(apId)` — shadow core grant by amount
- [x] `NormalProgressionBlocker` — reverts field tokens, map tiles, skills, traits, shadow cores, and talisman fragments from wizard stashes on `SAVE_SAVE`
- [x] Location checks sent on stage completion (Journey + Bonus) and wizard stash clear
- [x] Full sync on reconnect — deduplicates by seed for talismans, delta-grants for shadow cores

---

### Phase 2 — apworld ✅

- [x] Item table: field tokens, skills, traits, talismans, shadow cores, XP tomes
- [x] Location table: Journey, Bonus, Wizard Stash per stage (366 total)
- [x] Logic rules: tier system with token gates + skill requirements
- [x] Goal: `beat_game` (A4 + all skills) and `full_talisman`
- [x] `fill_slot_data`: token_map, talisman_map, shadow_core_map, name maps, XP tome levels, free stages
- [x] `fill_hook`: forces tier-ordered placement for generation consistency
- [x] Options: goal, talisman_min_rarity, xp_tome_bonus, force_early_skills, death_link + punishment options

---

### Phase 3 — Archipelago Client ✅

- [x] WebSocket client + AP protocol (Connect, Connected, ReceivedItems, LocationChecks, StatusUpdate, PrintJSON, Bounced)
- [x] Full sync on index=0, incremental grant on index>0
- [x] DeathLink: send on player death, receive and apply punishment (gem loss / wave surge / instant fail)
- [x] Connection panel UI, auto-reconnect, standalone (no-AP) mode
- [x] Item toast notifications with proper names for all item types
- [x] Message log (backtick toggle)
- [x] Slot file persistence (host, port, slot, password, bonusWizardLevel, totalShadowCoresGranted, completed, deathLinkEnabled, standalone)

---

### Phase 4 — Alpha Release 🔄 (in progress)

- [x] All items and locations defined with stable IDs
- [x] apworld structure complete
- [x] Mod connects, receives, and sends correctly
- [x] Win condition fires correctly
- [x] Installation instructions written (README.md)
- [ ] End-to-end testing
- [ ] apworld passes Archipelago generation tests
- [ ] No save corruption on install or removal

---

### Phase 5 — Polish & Extended Features

- [ ] Wizard stash display/indication on map (which stashes are cleared)
- [ ] Hints and in-game AP chat display
- [ ] Trap items
- [ ] Iron Wizard mode support
- [ ] Achievement locations (very large scope — 500+ achievements)
- [ ] Trial mode locations as optional setting

---

## ID assignment

Every item and every location gets a unique integer ID. IDs are stable — never renumber or reuse after any public release.

| Category | Item ID range | Location ID range |
|---|---|---|
| Stages (Field Tokens) | 1–124 | 1–124 (Journey) / 501–624 (Bonus) / 1001–1124 (Wiz Stash) |
| Map Tiles | 200–299 | 200–299 |
| Skills | 300–399 | — |
| Battle Traits | 400–499 | — |
| XP Tomes | 500–599 | — |
| Talisman Fragments (specific) | 700–752 | — |
| Talisman Fragments (extra) | 753–799 | — |
| Shadow Core Stashes (specific) | 800–816 | — |
| Shadow Core Stashes (extra) | 817–868 | — |
