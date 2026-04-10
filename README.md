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

#### Windows ####
Follow the instructions at the [BezelModLoader repository](https://github.com/gemforce-team/BezelModLoader).

Once installed, a `Mods` folder will appear inside your GemCraft: Frostborn Wrath install directory:

```
Steam\steamapps\common\GemCraft Frostborn Wrath\
└── Mods\
```

#### Linux (Steam/Proton)

With help from Xindage (as I dont own linux myself):

BezelModLoader's installer is a Windows executable and needs Wine to run. The following steps were confirmed working:

1. Make sure **Wine** is installed on your system
2. Download the BezelModLoader installer and place it in the same folder as the game executable (`GemCraft Frostborn Wrath.exe`)
3. In **winecfg** (run `winecfg` in a terminal), go to the **Graphics** tab and enable **Emulate a virtual desktop** — this prevents the installer's window from behaving oddly
4. Run the installer **manually through Wine** (do not use Proton): `wine BezelModLoader-installer.exe` (or right-click → Open With → Wine in your file manager)
5. A command prompt window will open — confirm the prompts and wait for the patch to complete, then close it
6. Continue with Step 2 below as normal — the `Mods` folder will now be present in the game directory

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
This can also be a solo GemCraft: Frostborn Wrath game.

---

### Step 5 — Launch and connect

1. Start **GemCraft: Frostborn Wrath** with BezelModLoader active
2. Select or create a save slot — a connection panel will appear
3. Enter your Archipelago server address, port, slot name, and password (if any)
4. Click **Connect**

Once connected, the game will sync your received items and begin tracking location checks automatically.

To play without an Archipelago server (vanilla progression), click **Play without randomizer** on the connection panel.

To disconnect from a session later, open the in-game **Disconnect** panel and click **Reconnect** to re-enter connection details.

---

### Finding the log file

If something isn't working, the Bezel log contains detailed output from the mod.

It is located at:

```
%appdata%\
└── com.giab.games.gcfw.steam\
    └── Local Store\
        └── Bezel Mod Loader\
            └── bezel_log.txt
```

Please include this file when reporting issues.

---

## What's randomized

**366 locations** across three check types:

| Location type | Count | Trigger |
|---|---|---|
| Stage clear — Journey | 122 | Complete any stage in Journey mode |
| Stage clear — Bonus | 122 | Reach 50+ waves in Journey mode |
| Wizard stash clear | 122 | Defeat the wizard stash on any stage |

**366 items** across the following categories:

| Item | Count | Notes |
|---|---|---|
| Field tokens | 118 | Unlock stages across the world map |
| Skills | 24 | Includes 6 gem-type unlocks (Crit, Leech, Bleed, Armor Tear, Poison, Slow) |
| Battle traits | 15 | |
| Talisman fragments (specific) | 53 | Named by original field, e.g. "Z3 Talisman Fragment" — carries that field's original seed/rarity |
| Talisman fragments (extra) | 47 | "Extra Talisman Fragment #1–47" — rarity spread from 2 to 94 |
| Shadow core stashes (specific) | 17 | Named by original field, e.g. "Z2 Shadow Cores" — original drop amount |
| Shadow core stashes (extra) | 52 | "Extra Shadow Cores #1–52" — amounts from 60 to 1080 |
| XP tomes | 40 | 2 Ancient Grimoires + 6 Worn Tomes + 32 Tattered Scrolls |

**Always free (not randomized):**
- W1 is the starting stage
- W2, W3, and W4 are unlocked automatically on connect
- Talisman fragments from normal wave completion are untouched
- Shadow cores earned during gameplay are untouched (only wizard stash grants are intercepted)

---

## YAML options

### Goal

| Option | Default | Description |
|---|---|---|
| `goal` | `kill_gatekeeper` | Win condition. See values below. |
| `fields_required` | `80` | Number of Journey stages to complete. Only used when `goal` is `fields_count` (50–122). |
| `fields_required_percentage` | `66` | Percentage of Journey stages to complete. Only used when `goal` is `fields_percentage` (40–100). |

**Goal values:**

| Value | Description |
|---|---|
| `kill_gatekeeper` | *(default)* Kill the Gatekeeper on A4 |
| `kill_swarm_queen` | Kill the Swarm Queen on K4 |
| `fields_count` | Complete a fixed number of Journey stages (set by `fields_required`) |
| `fields_percentage` | Complete a percentage of all Journey stages (set by `fields_required_percentage`) |

### Progression

| Option | Default | Description |
|---|---|---|
| `field_token_placement` | `any_world` | Where field tokens (stage unlocks) are placed: `any_world`, `own_world` (only in your locations), or `different_world` (only in other players' worlds — requires multiplayer). |
| `tier_requirements_percent` | `75` | Percentage of stages in earlier tiers that must be accessible before later tiers are considered in logic (40–100). Lower values may require heavier use of Endurance mode. |
| `xp_tome_bonus` | `150` | Approximate total wizard levels granted by all XP tomes combined (50–300). Scales tome values in a 1:2:3 ratio. |
| `enforce_logic` | `false` | When enabled, prevents starting out-of-logic stages in Journey mode. |
| `starting_wizard_level` | `1` | Wizard level granted at the start of the run, before any XP tomes are received (1–100). |
| `starting_overcrowd` | `false` | Start with the Overcrowd battle trait. Removes Overcrowd from the item pool. |

### Difficulty

| Option | Default | Description |
|---|---|---|
| `disable_endurance` | `false` | Permanently disables Endurance mode. |
| `disable_trial` | `true` | Permanently disables Trial mode (no AP checks there, disabled by default). |
| `enemy_hp_multiplier` | `100` | Enemy HP as a percentage of normal (50–200). |
| `enemy_armor_multiplier` | `100` | Enemy armor as a percentage of normal (50–200). |
| `enemy_shield_multiplier` | `100` | Enemy shield HP as a percentage of normal (50–200). |
| `enemies_per_wave_multiplier` | `100` | Number of enemies per wave as a percentage of normal (50–200). |
| `extra_wave_count` | `0` | Additional waves appended to each stage beyond its normal length (0–20). |

### DeathLink

| Option | Default | Description |
|---|---|---|
| `death_link` | `false` | Enables DeathLink with other players in the session. |
| `death_link_punishment` | `gem_loss` | What happens on a received DeathLink: `gem_loss`, `wave_surge`, or `instant_fail`. |
| `gem_loss_percent` | `20` | Percentage of placed gems destroyed on `gem_loss` punishment (10–50). |
| `wave_surge_count` | `3` | Number of enraged waves injected on `wave_surge` punishment (1–10). |
| `wave_surge_gem_level` | `5` | Gem level used to calculate the surge wave enrage multiplier (1–9). |
| `death_link_grace_period` | `15` | Seconds of immunity at the start of each stage before a queued DeathLink triggers (10–30). |
| `death_link_cooldown` | `20` | Minimum seconds between two DeathLink punishments (10–30). |

---

## Message Log

The mod keeps a scrollable history of all Archipelago messages received during your session.

- **Toggle:** Press the **backtick key** (`` ` ``) at any time to open or close the log overlay
- **Scroll:** Use the **mouse wheel** to browse history — newest messages appear at the top
- **Persistent:** The full log is saved to `slot_N_log.jsonl` next to your slot file and reloaded automatically when you reopen the same slot — the complete message history for a seed is always available
- Each entry shows a timestamp and a source tag: `[SYS]` for system/connection events and `[COL]` for item collection messages

---

## Known limitations (pre-alpha)

- Iron Wizard mode is not yet supported — only Chilling and Frostborn modes work
- DeathLink is implemented but may have edge cases

---

## Development

**Tools used:**
- [BezelModLoader](https://github.com/gemforce-team/BezelModLoader) — mod loader for GemCraft: Frostborn Wrath
- [JPEXS Free Flash Decompiler](https://github.com/jindrapetrik/jpexs-decompiler) — used to decompile the game's SWF for reference
- [Harman AIR SDK](https://airsdk.harman.com/) — ActionScript compiler
- [Archipelago](https://archipelago.gg) — multiworld randomizer platform

---