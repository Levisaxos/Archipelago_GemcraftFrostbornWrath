# Building a Bezel Mod for GemCraft Frostborn Wrath

## Prerequisites

### 1. Node.js & asconfigc
Install `asconfigc` which reads `asconfig.json` and drives the AS3 compiler:
```powershell
npm install -g asconfigc
```

### 2. Adobe AIR SDK 32
AIR SDK 51 (current) produces bytecode that is too new for GemCraft's Flash runtime. You need **AIR SDK 32** specifically.

Download from the Wayback Machine archive:
```
https://web.archive.org/web/2019/https://airdownload.adobe.com/air/win/download/32.0/AIRSDK_Compiler.zip
```
Extract to a folder, e.g. `D:\SDKs\AIRSDK_32\`

### 3. BezelLibs
You need three `.swc` files in a libs folder, e.g. `D:\BezelLibs\`:

| File | Source |
|---|---|
| `BezelModLoader.swc` | Build from source or get from the GemCraft Discord |
| `GemCraft.Frostborn.Wrath.swc` | Download from [GemCraftTypeCheckReleases](https://github.com/gemforce-team/GemCraftTypeCheckReleases/releases/latest) |
| `ANEBytecodeEditor.swc` | Build from source or get from the GemCraft Discord |

---

## Project Structure
```
YourMod/
├── asconfig.json
├── obj/                  ← compiler output goes here
└── src/
    └── DropLogger.as     ← file name must match class name exactly (case-sensitive)
```

---

## asconfig.json
```json
{
    "config": "air",
    "compilerOptions": {
        "source-path": ["src"],
        "output": "obj/DropLogger.swf",
        "target-player": "17.0",
        "debug": false,
        "external-library-path": [
            "D:/BezelLibs/BezelModLoader.swc",
            "D:/BezelLibs/GemCraft.Frostborn.Wrath.swc",
            "D:/BezelLibs/ANEBytecodeEditor.swc"
        ]
    },
    "mainClass": "DropLogger"
}
```

**Important rules for `asconfig.json`:**
- Use `"config": "air"` — not `"flex"` (causes a float type error with SDK 32)
- `mainClass` must be just the class name with no package — Bezel looks for the class at the root level
- `target-player` must be `"17.0"` to produce the correct ABC bytecode version for GemCraft

---

## ActionScript File Rules
- The file name must **exactly match** the class name including casing — `DropLogger.as` not `droplogger.as`
- The package must be **empty** — Bezel loads mods by looking up the class name at root level:
```actionscript
package {
    public class DropLogger extends MovieClip implements BezelMod {
        // ...
    }
}
```

---

## Building

In PowerShell, set `FLEX_HOME` to your SDK folder first — this must be done every session as it is not persistent:
```powershell
$env:FLEX_HOME = "D:\SDKs\AIRSDK_32"
```

Then run `asconfigc` from your mod project folder:
```powershell
cd D:\YourMod
asconfigc
```

This produces `obj/DropLogger.swf`.

To make `FLEX_HOME` permanent so you don't have to set it every session, run this once:
```powershell
[System.Environment]::SetEnvironmentVariable("FLEX_HOME", "D:\SDKs\AIRSDK_32", "User")
```

---

## Installing the Mod
Copy the compiled `.swf` to the game's `Mods` folder:
```
<Steam Game Folder>\GemCraft Frostborn Wrath\Mods\DropLogger.swf
```

---

## Verifying It Works
Check the Bezel log at:
```
%AppData%\com.giab.games.gcfw.steam\Local Store\Bezel Mod Loader\Bezel_log.log
```

On a successful load you should see:
```
[DropLogger]: DropLogger loaded!
[Bezel]:      Bound mod: DropLogger
```

---

## Hot Reloading During Development
You can reload mods without restarting the game by pressing:
```
Ctrl + Alt + Shift + Home
```
Note this does not reapply coremods, only regular mods.