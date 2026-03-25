# Archipelago — GemCraft: Frostborn Wrath

A randomizer mod for **GemCraft: Frostborn Wrath** built on the [Archipelago](https://archipelago.gg) multiworld framework.

---

## What is Archipelago?

[Archipelago](https://archipelago.gg) is a cross-game multiworld randomizer platform. It takes multiple games, randomizes each of them, and then links them together into a single shared session: items from your game can end up in someone else's game, and vice versa. You can't always progress on your own — you depend on other players finding your items in their worlds, and you find items for them in yours.

This turns randomization from a solo challenge into a cooperative, cross-game puzzle. Archipelago supports hundreds of games and thousands of sessions are run every week.

---

## About GemCraft: Frostborn Wrath

GemCraft: Frostborn Wrath is a Flash-based tower defense game by Game in a Bottle. You play as a wizard defending against waves of monsters by crafting and combining gems — each with unique attributes and synergies — and socketing them into towers, traps, and lanterns across a hex-grid battlefield.

The game features:
- A large world map of stages, unlocked progressively by completing battles and finding field tokens
- A deep gem crafting system with dozens of gem types and combinable grades
- Skill trees, battle traits, and talismans that carry over between stages
- Multiple game modes per stage: Journey, Endurance, and Trial
- A progression system built around XP, shadow cores, skill tomes, and achievement unlocks

Its progression is well-suited to randomization: unlocks are plentiful, stages gate each other, and many items have clear logical dependencies.

---

## Pre-Alpha Testing

> **Note:** This is an early pre-alpha. Expect rough edges. Feedback is very welcome.

### Requirements

- **GemCraft: Frostborn Wrath** (Steam)
- **[BezelModLoader](https://github.com/gemforce-team/BezelModLoader)** installed for the game
- **[Archipelago](https://archipelago.gg)** client/server (0.6.x recommended)
- An active Archipelago session with `gcfw` included

---

### Step 1 — Install BezelModLoader

Follow the instructions at the [BezelModLoader repository](https://github.com/gemforce-team/BezelModLoader).

Once installed, a `Mods` folder will appear inside your GemCraft: Frostborn Wrath install directory:

```
Steam\steamapps\common\GemCraft Frostborn Wrath\
└── Mods\
```

---

### Step 2 — Install the Archipelago mod

Download `ArchipelagoMod.swf` from the [Releases](../../releases) page and place it in your `Mods` folder:

```
GemCraft Frostborn Wrath\
└── Mods\
    └── ArchipelagoMod.swf
```

---

### Step 3 — Install the apworld

Download `gcfw.apworld` from the [Releases](../../releases) page and place it in the `lib/worlds` folder of your Archipelago installation:

```
Archipelago\
└── lib\
    └── worlds\
        └── gcfw.apworld
```

---

### Step 4 — Set up an Archipelago session

Generate a multiworld that includes GemCraft: Frostborn Wrath. You can host locally using the Archipelago launcher or connect to an existing hosted session.

A minimal YAML for solo testing:

```yaml
name: YourName
game: GemCraft - Frostborn Wrath
GemCraft - Frostborn Wrath:
  progression_balancing: 50
  accessibility: items
```

---

### Step 5 — Launch and connect

1. Start **GemCraft: Frostborn Wrath** with BezelModLoader active
2. Select or create a save slot — a connection panel will appear
3. Enter your Archipelago server address, port, slot name, and password (if any)
4. Click **Connect**

Once connected, the game will sync your received items and begin tracking location checks automatically.

To play without an Archipelago server (vanilla progression), click **Play without randomizer** on the connection panel.

---

### Finding the log file

If something isn't working, the Bezel log contains detailed output from the mod.

It is located at:

```
GemCraft Frostborn Wrath\
└── Mods\
    └── bezel_log.txt
```

Please include this file when reporting issues.

---

## What's randomized

| Item pool | Details |
|---|---|
| Field tokens | Unlock stages across the world map |
| Skill tomes | 24 skills (one per zone) |
| Battle traits | 15 traits |
| Wizard XP bonuses | Small (+1), Medium (+3), Large (+9) bonus wizard levels |

Location checks are sent when you **complete a stage in Journey mode**. The goal is to complete stage **A4**.

---

## Known limitations (pre-alpha)

- Iron Wizard mode is not yet supported — only Chilling and Frostborn modes work
- Talisman and shard rewards are not yet randomized
- DeathLink is implemented but may have edge cases

---

## Repository structure

```
mods/
└── ArchipelagoMod/   # ActionScript 3 mod (Bezel) — runs inside the game
apworld/
└── gcfw/             # Python apworld — runs on the Archipelago server
```

---

## Development

**Tools used:**
- [BezelModLoader](https://github.com/gemforce-team/BezelModLoader) — mod loader for GemCraft: Frostborn Wrath
- [JPEXS Free Flash Decompiler](https://github.com/jindrapetrik/jpexs-decompiler) — used to decompile the game's SWF for reference
- [Harman AIR SDK](https://airsdk.harman.com/) — ActionScript compiler
- [Archipelago](https://archipelago.gg) — multiworld randomizer platform
