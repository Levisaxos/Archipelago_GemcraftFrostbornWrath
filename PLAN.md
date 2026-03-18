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

This is a Python package that gets installed into an Archipelago server.

### 2. Bezel Mod (ActionScript — runs inside the game)
The in-game client:
- Connects to the Archipelago server via WebSocket
- Intercepts level completion events to **send checks** (tell the server a location was completed)
- Receives items from the server and **grants them** in-game
- Persists received items across sessions (what has been given must not be given again on reload)

---

## What gets shuffled

### Items (things you receive)
| Item type | Notes |
|---|---|
| Field Tokens | Unlock stages on the map — these are the primary progression gates |
| Skill Tomes | Unlock individual skills (Freeze, Beam, etc.) — core to build variety |
| Battle Trait Scrolls | 15 total — optional upgrades |
| Map Tiles | 26 total — lore / map reveals |
| Journey Pages | 36 total — story pages, one of the extended goal tracks |
| Shadow Cores | In-game currency — likely used as filler items |
| Skill Points | Minor upgrades — likely used as filler items |

### Locations (things you check)
| Location type | Notes |
|---|---|
| Complete stage — Journey mode | Primary location source, one per stage (122 stages total) |
| Complete stage — Endurance mode | Optional, harder — may be included as extended locations |
| Complete stage — Trial mode | Even harder — likely optional |
| Achievements | 500+ achievements — ambitious, track for a future goal option |

---

## Goals

### Alpha goal — Beat the game
> **"The Frostborn Wrath"** — defeat the main boss / complete the main story.

The exact in-game trigger for "game beaten" needs to be confirmed during research (see Phase 0). The story appears to culminate in specific STORY_RELATED and EPIC stages. Journey Page 10 is a known special reward tied to the endurance completion of the main-path stages (W1–W4, S1–S3), which suggests those stages form the story spine.

### Extended goals (post-alpha)
- Collect all Skills
- Find all Map Tiles
- Complete all Journey stages
- Collect all Journey Pages
- Collect all Achievements _(very ambitious — 500+ achievements)_

---

## Phases

---

### Phase 0 — Research & Feasibility

Before writing anything permanent, answer these questions:

**Victory condition**
- [ ] Identify exactly what triggers "game beaten" in the code
- [ ] Confirm whether there is a single final stage or a cumulative story condition
- [ ] Understand how the game tracks story progress (journey pages? stage completion flags?)

**Item granting**
- [ ] Confirm we can call the reward functions (e.g. grant a Field Token, a Skill Tome) from mod code without side effects
- [ ] Determine whether a coremod is needed to intercept `updatePpdWithDrops` or whether hooking around it (via `SAVE_SAVE` / `INGAME_NEW_SCENE`) is sufficient
- [ ] Understand the save system well enough to safely add "received from AP" state without corrupting existing save data

**Network connectivity**
- [ ] Confirm the game runs as an AIR application (not sandboxed Flash Player)
- [ ] Test whether `flash.net.Socket` or AIR's WebSocket support can connect to an Archipelago server
- [ ] If native WebSocket is unavailable, evaluate a small companion process (e.g. a local proxy) as a fallback

**Item / location counts**
- [ ] Count all skill tomes (partial data found: at least 22+, need exact number)
- [ ] Enumerate all field tokens and their stage unlock targets
- [ ] Map the full stage dependency graph (which stages unlock which)

---

### Phase 1 — Core Mod: Item Grant & Location Check System

Build the fundamental plumbing. No Archipelago server yet — just the mod-internal logic.

**Item grant system**
Design a single function `grantItem(itemId)` that can be called from anywhere (level completion or AP connection) and correctly applies the item:
- Grant a Field Token → unlock the target stage
- Grant a Skill Tome → add skill to player's tome list
- Grant a Battle Trait Scroll → add trait
- Grant a Map Tile → reveal map tile
- Grant Shadow Cores / Skill Points → add to totals
- Handle duplicates gracefully (don't double-grant)

**Location check system**
Hook into level completion to fire `sendCheck(locationId)`:
- Intercept the post-victory flow (currently researched via `SAVE_SAVE`; may require a coremod)
- Track which locations have already been sent (store in save or a sidecar file)

**Persistence**
- Decide where to store AP-received items and sent checks
  - Options: piggyback on `GV.ppd` (risky), use a sidecar JSON in the game's Local Store, or use Bezel's settings manager
- Implement load/save of this state so nothing is double-granted or lost on crash

**Test in solo mode**
- Hardcode a set of item grants on load to verify the grant functions work correctly
- Complete a stage and verify the check is detected

---

### Phase 2 — apworld (Archipelago Server Side)

Build the Python package that tells Archipelago how this game works.

**File structure**
```
worlds/gcfw/
├── __init__.py        # World class — main entry point
├── Items.py           # Item definitions and IDs
├── Locations.py       # Location definitions and IDs
├── Rules.py           # Logic: which items are needed to reach which locations
├── Options.py         # Player-configurable YAML settings
└── data/
    └── stages.json    # Stage graph data (IDs, unlock chains, types)
```

**Items**
- Assign a unique numeric ID to every item (Field Tokens, Skill Tomes, etc.)
- Mark items as progression, useful, or filler

**Locations**
- Assign a unique numeric ID to every location (one per stage per included mode)
- For alpha: Journey completions only

**Logic / Rules**
- Encode the stage dependency graph: stage X is accessible only if the player has the Field Token that unlocks it
- For alpha: pure token logic is sufficient (no skill requirements)
- Later: optionally add skill-based access rules for harder stages

**Goal**
- Define the win condition that matches the in-game "beat the game" trigger

**Options**
- Include/exclude Endurance and Trial locations
- Goal selection (beat game, collect all skills, all pages, etc.)
- Starting inventory (e.g. start with the first few field tokens so the player isn't immediately locked out)

---

### Phase 3 — Archipelago Client (In-Game Connection)

Connect the Bezel mod to a live Archipelago server.

**WebSocket / connection**
- Implement the Archipelago client protocol in ActionScript
  - Connect to `ws://<host>:<port>`
  - Send `Connect` packet (game name, slot name, password)
  - Handle `Connected`, `ReceivedItems`, `RoomInfo`, `PrintJSON` packets
  - Send `LocationChecks`, `StatusUpdate` (goal complete) packets
- Handle reconnection on disconnect
- On connect/reconnect, sync: re-request any items not yet received, confirm already-sent checks

**Item delivery**
- On `ReceivedItems` packet, call `grantItem()` for each new item
- Track item index to avoid re-granting on reconnect

**Location checks**
- On level completion, call `sendCheck()` which emits a `LocationChecks` packet

**Goal reporting**
- When the win condition is met, send `StatusUpdate` with goal complete

**UI (minimal)**
- Show connection status somewhere in the game (small overlay or log)
- Optionally: show item received messages (AP sends these as `PrintJSON`)

---

### Phase 4 — Alpha Release

Playable end-to-end with the core shuffle working.

**Scope**
- Goal: beat the main boss / complete the main story
- Shuffled: Field Tokens, Skill Tomes, Battle Trait Scrolls
- Locations: Journey mode completions only
- Logic: field token dependency graph
- Starting inventory: a defined set of early-game tokens so the player can start

**Checklist**
- [ ] All items and locations have stable IDs (do not change after release)
- [ ] apworld passes Archipelago's generation tests
- [ ] Mod connects to AP server, receives items, sends checks
- [ ] Win condition fires correctly
- [ ] No save corruption on install or removal
- [ ] Installation instructions written

---

### Phase 5 — Extended Goals & Polish

After alpha:
- Add Endurance and Trial locations as optional settings
- Add Map Tiles and Journey Pages to the item pool
- Implement additional goal options (collect all skills, all pages, etc.)
- Add Shadow Cores / Skill Points as filler items
- Achievement goal research (large scope — hundreds of locations)
- Deathlink support (optional community feature — dying sends a death to other players)
- Trap items (fun negative items that can appear in the pool)
- Hints and in-game AP chat display

---

## ID assignment

Every item and every location gets a unique integer ID. Items and locations have separate namespaces (the same number can appear in both without conflict), but within each list every ID must be unique and **must never change** after a multiworld has been generated with it — the Archipelago server stores raw IDs in save data with no migration path.

### Rules
- Items: each gets a unique ID, starting from `1`
- Locations: each gets a unique ID, starting from `1` (independent from items)
- Once assigned, an ID is permanent — never renumber, never reuse a retired ID
- New items/locations always get a new number appended at the end of their category bucket

### Structure
Use sub-range buckets per category so each can grow independently:

| Category | Item ID range | Location ID range |
|---|---|---|
| Stages (Field Tokens / Completions) | 1 – 199 | 1 – 199 |
| Map Tiles | 200 – 299 | 200 – 299 |
| Skills | 300 – 399 | 300 – 399 |
| Battle Traits | 400 – 499 | 400 – 499 |

> **Note on global uniqueness:** Archipelago namespaces IDs by game name, so there is no requirement to be unique across other games. Starting from 1 is valid. We keep items and locations unique within their own lists, and use the bucket structure above to make future additions safe without renumbering anything.

---

## Open questions

- **What is the exact "game beaten" trigger?** Needs code research. Likely tied to specific EPIC/STORY_RELATED stages or the final journey page.
- **Can we grant items safely mid-battle?** Or should grants always happen on the map screen?
- **WebSocket in AIR:** Flash Player cannot do WebSocket natively in older versions. AIR can. Needs a quick feasibility test. If not possible, a lightweight local proxy (Node.js or Python script) can translate TCP ↔ WebSocket.
- **How many skill tomes exist?** Partial count found (22+). Need exact number from code.
- **Item IDs must be stable.** Once an apworld is released, item and location IDs cannot change. Get these right before any public release.

---

## Notes on the DropLogger mod

`mods/DropLogger` is an exploratory mod that logs the contents of `IngameEnding.dropIcons` on every `SAVE_SAVE` event. It is not part of the randomizer itself — it exists to help understand what the game gives out and when, feeding into the research for Phase 0.
