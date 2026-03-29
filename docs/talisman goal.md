# GCFW Talisman System Reference

Source files:
- `do not commit/GCFW/scripts/com/giab/games/gcfw/entity/TalismanFragment.as`
- `do not commit/GCFW/scripts/com/giab/games/gcfw/selector/PnlTalisman.as`
- `do not commit/GCFW/scripts/com/giab/games/gcfw/constants/TalismanFragmentType.as`
- `do not commit/GCFW/scripts/com/giab/games/gcfw/struct/PlayerProgressData.as`
- `do not commit/GCFW/scripts/com/giab/games/gcfw/ingame/IngameAchiChecker3.as`
- `do not commit/GCFW/scripts/com/giab/games/gcfw/ingame/IngameAchiChecker5.as`
- `do not commit/GCFW/scripts/com/giab/games/gcfw/ingame/IngameAchiChecker6.as`

---

## Grid Layout

The talisman is a **5x5 grid of 25 sockets**. Each socket has a fixed type.

```
 [COR] [EDG] [EDG] [EDG] [COR]     Slot IDs:   0   1   2   3   4
 [EDG] [INN] [INN] [INN] [EDG]                  5   6   7   8   9
 [EDG] [INN] [INN] [INN] [EDG]                 10  11  12  13  14
 [EDG] [INN] [INN] [INN] [EDG]                 15  16  17  18  19
 [COR] [EDG] [EDG] [EDG] [COR]                 20  21  22  23  24
```

Type array (index = slot ID):
```
talSlotTypes = [1, 0, 0, 0, 1,
                0, 2, 2, 2, 0,
                0, 2, 2, 2, 0,
                0, 2, 2, 2, 0,
                1, 0, 0, 0, 1]
```

### Fragment Types (TalismanFragmentType.as)

| Value | Name | Count | Grid Position |
|-------|------|-------|---------------|
| 0 | EDGE | 12 | Border non-corners |
| 1 | CORNER | 4 | Positions 0, 4, 20, 24 |
| 2 | INNER | 9 | Center 3x3 block |

Fragments can **only** be placed in sockets matching their type.

---

## Socket Unlock Costs (Shadow Cores)

```
talSlotUnlockCosts = [9000, 3000, 1000, 3600, 10000,
                      4200,  200,    0,  300,  4800,
                      1200,    0,    0,    0,  1400,
                      5400,  400,    0,  500,  6000,
                     11000, 7200, 1600, 7800, 12000]
```

**Free at start (cost 0):** Slots 7, 11, 12, 13, 17 (the center cross of inner sockets)

**Total cost to unlock all:** 9000+3000+1000+3600+10000+4200+200+300+4800+1200+1400+5400+400+500+6000+11000+7200+1600+7800+12000 = **90,600 shadow cores**

Currency: `GV.ppd.shadowCoreAmount`

---

## Fragment Data Structure (TalismanFragment.as)

### Constructor
```actionscript
new TalismanFragment(seed, rarity, type, upgradeLevel)
```

### Core Properties
| Property | Type | Description |
|----------|------|-------------|
| `seed` | int | Random seed 1,000,000-9,999,998 (determines shape and properties) |
| `rarity` | int | 1-100 (determines upgrade cap and property count) |
| `type` | int | 0=EDGE, 1=CORNER, 2=INNER |
| `upgradeLevel` | ObscuredInt | Current upgrade level (starts at 0) |
| `upgradeLevelMax` | ObscuredInt | Max upgrade level (derived from rarity+type) |

### Directional Links (shape)
| Property | Values | Description |
|----------|--------|-------------|
| `linkUp` | -1, 0, 1 | Up connection (-1=inward, 0=flat, 1=outward) |
| `linkDown` | -1, 0, 1 | Down connection |
| `linkLeft` | -1, 0, 1 | Left connection |
| `linkRight` | -1, 0, 1 | Right connection |

Adjacent fragments must have **opposite** matching links:
- `fragmentA.linkDown == -1 * fragmentB.linkUp` (A above B)
- `fragmentA.linkRight == -1 * fragmentB.linkLeft` (A left of B)

Boundary rule: Fragments on grid edges must have 0 (flat) on the side facing the boundary.

---

## Fragment Shapes

**64 total shapes**, split by type:
| Shape ID Range | Type | Count |
|----------------|------|-------|
| 0-15 | INNER | 16 |
| 16-47 | EDGE | 32 |
| 48-63 | CORNER | 16 |

Shape is deterministically generated from `seed` via `getOriginalShapeId()`.

Tracked in: `GV.ppd.talFragShapeCollection[shapeId]` (boolean array of 64)

---

## Max Upgrade Level by Rarity and Type

The `upgradeLevelMax` is calculated from rarity and fragment type:

| Rarity Range | INNER max | EDGE max | CORNER max |
|-------------|-----------|----------|------------|
| 0-9 | 2 | 2 | 2 |
| 10-19 | 3 | 3 | 3 |
| 20-29 | 4 | 4 | 4 |
| 30-39 | 5 | 5 | 5 |
| 40-49 | 6 | 6 | 6 |
| 50-59 | 7 | 8 | 9 |
| 60-69 | 8 | 9 | 10 |
| 70-79 | 9 | 10 | 11 |
| 80-89 | 10 | 11 | 12 |
| 90-99 | 11 | 12 | 13 |
| 100 | 12 | 13 | 14 |

Note: Achieving "Sigil" (all at level 5+) requires every fragment to be rarity 30+ minimum.
"Charm" (all at max) means each fragment is individually maxed per its own upgradeLevelMax.

---

## Fragment Properties

Each fragment gets a number of stat properties based on rarity:

| Rarity Range | Property Slots |
|-------------|----------------|
| 0-9 | 2 |
| 10-19 | 3 |
| 20-29 | 4 |
| 30-39 | 5 |
| 40-49 | 6 |
| 50-59 | 6-8 (type-dependent) |
| 60-69 | 7-10 |
| 70-79 | 8-11 |
| 80-89 | 9-12 |
| 90-99 | 10-13 |
| 100 | 11-14 |

**Rune system:** Each fragment has a 5/9 chance of having a rune (runeId 0-4), and 4/9 chance of no rune.

---

## Fragment Drop Calculation (IngamePopulator.as)

### Quantity (per battle)

Up to 6 fragment drops, each with a probability threshold based on waves beaten:

| Fragment | Guaranteed at | Probabilistic range | Formula (when not guaranteed) |
|----------|--------------|--------------------|-----------------------------|
| vFrag1 | 40+ waves | 0 < waves < 40 | `0.5 * waves/40` chance |
| vFrag2 | 80+ waves | 20 < waves < 80 | `0.5 * (waves-20)/60` chance |
| vFrag3 | 140+ waves | 60 < waves < 140 | `0.5 * (waves-60)/80` chance |
| vFrag4 | 200+ waves | 100 < waves < 200 | `0.5 * (waves-100)/100` chance |
| vFrag5 | 320+ waves | 170 < waves < 320 | `0.5 * (waves-170)/150` chance |
| vFrag6 | 500+ waves | 250 < waves < 500 | `0.5 * (waves-250)/250` chance |

**Caps:**
- If wizard stash is CLOSED: max 3 fragments per battle
- Iron Mode: no fragments drop at all

### Rarity Calculation

**Drop Power** (varies by battle mode):

Journey/Trial:
```
dropPower = (hpFirstWave * 0.76 + traitsValue) / 1000 * (0.63 + 0.63 * wavesNum / 135)
```

Endurance:
```
dropPower = (hpFirstWave * 0.8 + traitsValue * 0.9) / 1000 * (0.63 + 0.63 * max(wavesNum/52.5, min(500, 30+enduranceWaveStones)/65.5))
```

**Rarity range:**
- Min: `max(1, min(85, 64 * dropPower))`
- Max: `min(100, 20 + 105 * dropPower)`

**Per-fragment rarity:** Takes the MAX of two random rolls:
```
rarity = max(
  rarityMin + round((rarityMax - rarityMin) * random() * random()),
  rarityMin + round((rarityMax - rarityMin) * random() * random())
)
```

### Type Selection

Based on wizard level:
- Level < 35: INNER only
- Level 35-69: INNER or EDGE (equal chance)
- Level 70+: INNER, EDGE, or CORNER (equal chance)

---

## Data Storage (PlayerProgressData.as)

| Field | Type | Size | Description |
|-------|------|------|-------------|
| `talismanSlots` | Array | 25 | Active grid; TalismanFragment or null |
| `talismanInventory` | Array | 36 | Inventory; TalismanFragment or null |
| `talSlotUnlockStatuses` | Array | 25 | Boolean: is socket unlocked? |
| `talFragShapeCollection` | Array | 64 | Boolean: has this shape been seen? |
| `shadowCoreAmount` | Number | 1 | Currency for unlocking sockets |

### Serialization

Fragments are base64-encoded as: `seed/rarity/type/upgradeLevel/linkUp/linkRight/linkDown/linkLeft`

Endurance mode stores recovered fragments separately in `recoveredEnduranceTalFragsBase64`.

---

## Programmatic Completeness Checks

### "Is the talisman full?" (all 25 sockets occupied)
```actionscript
var full:Boolean = true;
for (var i:int = 0; i < 25; i++) {
    if (GV.ppd.talismanSlots[i] == null) { full = false; break; }
}
```
This is exactly what **Achievement 359 "Amulet"** checks.

### "Are all fragments at level 5+?"
```actionscript
var sigil:Boolean = true;
for (var i:int = 0; i < 25; i++) {
    if (GV.ppd.talismanSlots[i] == null ||
        TalismanFragment(GV.ppd.talismanSlots[i]).upgradeLevel.g() < 5) {
        sigil = false; break;
    }
}
```
This is **Achievement 361 "Sigil"**.

### "Are all fragments at max level?"
```actionscript
var charm:Boolean = true;
for (var i:int = 0; i < 25; i++) {
    var frag:TalismanFragment = GV.ppd.talismanSlots[i];
    if (frag == null || frag.upgradeLevel.g() != frag.upgradeLevelMax.g()) {
        charm = false; break;
    }
}
```
This is **Achievement 360 "Charm"**.

### "How many unique shapes collected?"
```actionscript
var count:int = 0;
for (var i:int = 0; i < 64; i++) {
    if (GV.ppd.talFragShapeCollection[i]) count++;
}
// 8 = Starter Pack (631), 32 = Half Full (633), 64 = Shapeshifter (634)
```

### "How many distinct talisman properties active?"
```actionscript
var propCount:int = GV.selectorCore.pnlTalisman.talPropRows;
// 15 = Quite a List (505), 20 = Almost Like Hacked (506)
```

---

## Talisman-Related Achievements Summary

| ID | Title | Condition | Data Checked |
|----|-------|-----------|--------------|
| 363 | Gearing Up | 5+ slots filled | `talismanSlots[i] != null`, count >= 5 |
| 359 | Amulet | All 25 slots filled | `talismanSlots[i] != null`, count == 25 |
| 361 | Sigil | All 25 at upgradeLevel >= 5 | `upgradeLevel.g() >= 5` for all |
| 360 | Charm | All 25 at max upgrade | `upgradeLevel == upgradeLevelMax` for all |
| 364 | First Puzzle Piece | Find 1 fragment (in battle) | Checked during battle loot |
| 365 | Fortunate | Find 2 fragments | Checked during battle loot |
| 366 | Ground Luck | Find 3 fragments | Checked during battle loot |
| 358 | Frag Rain | Find 5 fragments | Checked during battle loot |
| 505 | Quite a List | 15+ talisman properties | `talPropRows > 14` |
| 506 | Almost Like Hacked | 20+ talisman properties | `talPropRows > 19` |
| 631 | Starter Pack | 8+ shapes collected | `talFragShapeCollection`, count > 7 |
| 633 | Half Full | 32+ shapes collected | `talFragShapeCollection`, count > 31 |
| 634 | Shapeshifter | All 64 shapes collected | `talFragShapeCollection`, count > 63 |

---

## Placement Validation Rules (PnlTalisman.as)

When placing a fragment in slot `pSlotNum`:

1. **Type match:** `fragment.type == talSlotTypes[pSlotNum]`
2. **Boundary links:** Fragment links facing grid boundary must be 0 (flat)
   - Top row (slots 0-4): `linkUp == 0`
   - Bottom row (slots 20-24): `linkDown == 0`
   - Left column (slots 0,5,10,15,20): `linkLeft == 0`
   - Right column (slots 4,9,14,19,24): `linkRight == 0`
3. **Neighbor matching:** For each adjacent occupied slot:
   - Up neighbor: `neighbor.linkDown == -1 * fragment.linkUp`
   - Down neighbor: `neighbor.linkUp == -1 * fragment.linkDown`
   - Left neighbor: `neighbor.linkRight == -1 * fragment.linkLeft`
   - Right neighbor: `neighbor.linkLeft == -1 * fragment.linkRight`
4. **Socket must be unlocked:** `talSlotUnlockStatuses[pSlotNum] == true`

If no neighbor exists on a given side (and it's not a boundary), any link value is accepted.

---

## Archipelago Goal: Talisman Completion

### Mod Change Required: Remove Fragment Type Level Restriction

In vanilla, fragment type drops are gated by wizard level:
- Level < 35: INNER only
- Level 35-69: INNER or EDGE
- Level 70+: all types

**For the AP talisman goal, the mod must remove this restriction** so that INNER, EDGE, and CORNER fragments can all drop at any wizard level. Without this, reaching the goal depends on hitting wizard level 70 first, which is too restrictive and couples two unrelated progression axes.

The change should be in `IngamePopulator.as` where fragment type is selected — force equal chance for all three types regardless of wizard level.

### Player Option: Minimum Fragment Upgrade Level to Win

The player should be able to configure a **minimum upgrade level** that all 25 socketed talisman fragments must reach in order to complete the talisman goal. This is an AP slot option (set at generation time).

Suggested option values:
| Option | Meaning | Difficulty |
|--------|---------|------------|
| 0 | Just fill all 25 sockets (= "Amulet") | Easiest |
| 5 | All fragments at level 5+ (= "Sigil") | Medium |
| Max | All fragments at their individual max level (= "Charm") | Hardest |

The mod checks completion by iterating `GV.ppd.talismanSlots[0..24]` and verifying each fragment's `upgradeLevel.g() >= requiredLevel` (or `== upgradeLevelMax.g()` for the "Max" option).

This option would be sent to the mod via the AP slot data so it knows the win threshold.
