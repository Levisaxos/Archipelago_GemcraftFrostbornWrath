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

## This Project

This repository contains a GemCraft: Frostborn Wrath mod built using [BezelModLoader](https://github.com/gemforce-team/BezelModLoader), the community mod loader for the game.

The goal is to implement a full Archipelago integration — turning GemCraft: Frostborn Wrath into an Archipelago-compatible game that can participate in multiworld sessions alongside other supported titles.

### Planned features

- **Randomized progression** — stage unlocks, skill tomes, battle traits, talismans, and other rewards are shuffled and may be received from other players' games instead of earned locally
- **Multiworld item exchange** — completing stages or meeting objectives sends items to other players; their completions send items back to you
- **Logic-aware placement** — the randomizer will understand which items are needed to access which stages, ensuring seeds are always completable
- **Archipelago client integration** — connects directly to an Archipelago server to send and receive items in real time

### Randomizer logic

_Coming soon._

---

## Repository structure

```
mods/
└── DropLogger/       # Development/exploration mod — logs reward drops to file
```

---

## Development

This project is in early stages. The current code is exploratory — reading game internals and understanding how rewards and progression work before the randomizer logic is written.

**Tools used:**
- [BezelModLoader](https://github.com/gemforce-team/BezelModLoader) — mod loader for GemCraft: Frostborn Wrath
- [JPEXS Free Flash Decompiler](https://github.com/jindrapetrik/jpexs-decompiler) — used to decompile the game's SWF for reference
- [Harman AIR SDK](https://airsdk.harman.com/) — ActionScript compiler
- [Archipelago](https://archipelago.gg) — multiworld randomizer platform
