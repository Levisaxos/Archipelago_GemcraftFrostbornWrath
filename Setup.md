# Building a Bezel Mod for GemCraft Frostborn Wrath

## Prerequisites

### 1. Node.js & asconfigc
Install `asconfigc` which reads `asconfig.json` and drives the AS3 compiler:
```powershell
npm install -g asconfigc
```

### 2. Java 8
The AIR SDK compiler is Java-based and requires a JRE to run. Install **Java 8** (later versions may not be compatible with AIR SDK 32).

Download Eclipse Temurin JDK 8 (open-source Java 8):
```
https://adoptium.net/temurin/releases/?version=8
```
Select **Windows x64**, package type **JDK**, and run the `.msi` installer with default settings.

After installing, update `JAVA_HOME` in `do not commit\config.bat` to match the installed folder name if it differs.

### 3. Adobe AIR SDK 32
AIR SDK 51 (current) produces bytecode that is too new for GemCraft's Flash runtime. You need **AIR SDK 32** specifically.

The SDK is already bundled at `do not commit\Air SDK\` — no separate download needed.

### 4. BezelLibs
You need three `.swc` files. They are bundled at `do not commit\BezelLibs\`:

| File | Source |
|---|---|
| `BezelModLoader.swc` | Installed automatically when installing Bezel Mod Loader for GC:FW |
| `GemCraft.Frostborn.Wrath.swc` | Download from [GemCraftTypeCheckReleases](https://github.com/gemforce-team/GemCraftTypeCheckReleases/releases/latest) |
| `ANEBytecodeEditor.swc` | Request from Levisaxos |

---

## Project Structure
```
ArchipelagoMod/
├── asconfig.json
├── obj/                      ← compiler output goes here
└── src/
    └── ArchipelagoMod.as     ← file name must match class name exactly (case-sensitive)
```

---

## asconfig.json
```json
{
    "config": "air",
    "compilerOptions": {
        "source-path": ["src"],
        "output": "obj/ArchipelagoMod.swf",
        "target-player": "17.0",
        "debug": false,
        "external-library-path": [
            "${BEZEL_LIBS}/BezelModLoader.swc",
            "${BEZEL_LIBS}/GemCraft.Frostborn.Wrath.swc",
            "${BEZEL_LIBS}/ANEBytecodeEditor.swc"
        ]
    },
    "mainClass": "ArchipelagoMod"
}
```

`${BEZEL_LIBS}` is substituted at build time by `build_mod.bat` using the value from `do not commit\config.bat`.

**Important rules for `asconfig.json`:**
- Use `"config": "air"` — not `"flex"` (causes a float type error with SDK 32)
- `mainClass` must be just the class name with no package — Bezel looks for the class at the root level
- `target-player` must be `"17.0"` to produce the correct ABC bytecode version for GemCraft

---

## ActionScript File Rules
- The file name must **exactly match** the class name including casing — `ArchipelagoMod.as` not `archipelagomod.as`
- The package must be **empty** — Bezel loads mods by looking up the class name at root level:
```actionscript
package {
    public class ArchipelagoMod extends MovieClip implements BezelMod {
        // ...
    }
}
```

---

## Building

Use the provided bat scripts in `do not commit\`. All paths are configured in `do not commit\config.bat`.

**Build and install the mod:**
```
do not commit\build_mod.bat
```
This substitutes `${BEZEL_LIBS}` in `asconfig.json`, compiles with the bundled AIR SDK, and copies the output to the game's `Mods` folder.

**Build and install the apworld:**
```
do not commit\build_apworld.bat
```

---

## Installing the Mod Manually
Copy the compiled `.swf` to the game's `Mods` folder:
```
E:\SteamLibrary\steamapps\common\GemCraft Frostborn Wrath\Mods\ArchipelagoMod.swf
```

---

## Verifying It Works
Check the Bezel log at:
```
%AppData%\com.giab.games.gcfw.steam\Local Store\Bezel Mod Loader\Bezel_log.log
```

On a successful load you should see:
```
[ArchipelagoMod]: ArchipelagoMod loaded!
[Bezel]:          Bound mod: ArchipelagoMod
```

---

## Hot Reloading During Development
You can reload mods without restarting the game by pressing:
```
Ctrl + Alt + Shift + Home
```
Note this does not reapply coremods, only regular mods.
