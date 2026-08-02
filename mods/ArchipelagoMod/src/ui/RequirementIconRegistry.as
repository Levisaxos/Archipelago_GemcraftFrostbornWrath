package ui {
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.GemComponentType;
    import com.giab.games.gcfw.entity.Gem;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.utils.getDefinitionByName;

    /**
     * Maps each requirement type to its in-game icon.
     *
     * Three render paths (see field_finder_plan.md):
     *   A. Bmpd*  — embedded BitmapData (build-menu / weather art). `new BmpdX(0,0)`.
     *   B. Gem    — GemBitmapCreator.giveGemBitmaps, then snapshot the gem MC.
     *   C. Mc*    — full entity sprite, instantiated by symbol name and snapshot
     *               into a fixed, centred, scaled BitmapData.
     *
     * makeIcon() never throws — any missing/blank symbol yields a "?" placeholder
     * so the mock grid renders and surfaces which icons still need work.
     *
     * This is the visual-mock version: the CATEGORIES list drives the grid; the
     * real feature will drive its filter set from FieldLogicEvaluator's inverse
     * maps instead.
     */
    public class RequirementIconRegistry {

        // Ordered groups shown in the window. Each entry: { title, names }.
        public static const CATEGORIES:Array = [
            { title: "Structures", names: [
                "Trap", "Lantern", "Pylon", "Amplifier", "Barricade", "Monster Nest",
                "Tomb", "Mana Shard", "Shrine", "Beacon", "Sealed Gem",
                "Abandoned Dwelling", "Drop Holder", "Obelisk",
                "Sleeping Hive", "Watchtower", "Wizard Tower", "Jar of Wasps" ] },
            { title: "Creatures", names: [
                "Shadow", "Specter", "Apparition", "Wraith", "Wizard Hunter",
                "Swarm Queen", "Gatekeeper", "Marked Monster", "Spire" ] },
            { title: "Weather", names: [ "Rain", "Snow" ] },
            { title: "Gems", names: [
                "Crit Hit", "Mana Leech", "Bleeding", "Armor Tearing", "Poison", "Slowing" ] }
        ];

        // Icons known to be wrong / placeholder — flagged with a red marker in
        // the grid so they're easy to spot and fix later.
        // TODO: "Marked Monster" still uses a placeholder icon (falls back to
        // the generic McMonsterBase sprite in the MC map below). Give it a
        // dedicated icon eventually. Deliberately no longer flagged as
        // needs-fix so it renders cleanly (no red marker) for now.
        private static const NEEDS_FIX:Object = {
        };

        public static function needsFix(name:String):Boolean {
            return NEEDS_FIX.hasOwnProperty(name);
        }

        // Path A — embedded bitmaps (com.giab.games.gcfw.bmpd.*)
        private static const BMPD:Object = {
            "Trap":      "BmpdBuildHelperTrap",
            "Lantern":   "BmpdBuildHelperLantern",
            "Pylon":     "BmpdBuildHelperPylon",
            "Amplifier": "BmpdBuildHelperAmp",
            "Tower":     "BmpdBuildHelperTower",
            "Wall":      "BmpdBuildHelperWall",
            "Rain":      "BmpdRainDrop1",
            "Snow":      "BmpdSnowFlake1"
        };

        // Path C — entity sprites (com.giab.games.gcfw.mcDyn.*)
        private static const MC:Object = {
            "Barricade":          "McBarricade",
            "Monster Nest":       "McNestUpper",
            "Tomb":               "McTomb",
            "Mana Shard":         "McManaShard",
            "Shrine":             "McShrine",
            "Beacon":             "McBeacon",
            "Sealed Gem":         "McGemSeal",
            "Abandoned Dwelling": "McDwelling",
            "Drop Holder":        "McDropHolder",
            "Old Wall":           "McOldWall",
            "Obelisk":            "McPossessionObelisk",
            "Sleeping Hive":      "McSleepingHive",
            "Spire":              "McSpire",
            "Watchtower":         "McWatchTower",
            "Wizard Tower":       "McWizTower",
            "Shadow":             "McShadow",
            "Specter":            "McSpecter",
            "Apparition":         "McApparition",
            "Wraith":             "McWraith",
            "Wizard Hunter":      "McWizardHunter",
            "Jar of Wasps":       "McJarOfWasps",
            "Swarm Queen":        "McSwarmQueen",
            // Fallbacks — no dedicated single symbol.
            "Gatekeeper":         "McGateKeeperFang",
            "Marked Monster":     "McMonsterBase"
        };

        // Path B — gem component ids (com.giab.games.gcfw.constants.GemComponentType)
        private static const GEM:Object = {
            "Crit Hit":      GemComponentType.CRITHIT,
            "Mana Leech":    GemComponentType.MANA_LEECHING,
            "Bleeding":      GemComponentType.BLEEDING,
            "Armor Tearing": GemComponentType.ARMOR_TEARING,
            "Poison":        GemComponentType.POISON,
            "Slowing":       GemComponentType.SLOWING
        };

        // Per-icon snapshot tuning for entity sprites whose natural bounds don't
        // frame nicely. All fields optional:
        //   scale — multiply the fit-scale (<1 zooms out, >1 zooms in)
        //   dx/dy — nudge in final icon pixels
        // Add an entry here when an icon looks off-centre or over-zoomed.
        private static const OVERRIDE:Object = {
            // "Sealed Gem": { scale: 0.85 },
            // "Mana Shard": { scale: 0.9, dy: -2 }
        };

        public function RequirementIconRegistry() {
        }

        /** A fresh DisplayObject icon for `name`, fit for a `box`-sized cell. */
        public static function makeIcon(name:String, box:Number):DisplayObject {
            try {
                // Embedded game art takes priority (hand-picked replacements).
                if (EmbeddedIcons.has(name)) {
                    var d:DisplayObject = EmbeddedIcons.make(name);
                    if (d != null)
                        return _snapshot(d, box, name);
                }
                if (name == "Marked Monster")
                    return _markedMonsterIcon(box);
                if (BMPD.hasOwnProperty(name))
                    return _bmpd(String(BMPD[name]));
                if (GEM.hasOwnProperty(name))
                    return _gem(int(GEM[name]), box);
                if (MC.hasOwnProperty(name))
                    return _mcSnapshot(String(MC[name]), box, name);
            } catch (e:Error) {
            }
            return _placeholder(box);
        }

        // -----------------------------------------------------------------------

        private static function _bmpd(className:String):DisplayObject {
            var cls:Class = getDefinitionByName("com.giab.games.gcfw.bmpd." + className) as Class;
            var bd:BitmapData = new cls(0, 0) as BitmapData;
            var bmp:Bitmap = new Bitmap(bd);
            bmp.smoothing = true;
            return bmp;
        }

        private static function _mcSnapshot(className:String, box:Number, name:String):DisplayObject {
            var cls:Class = getDefinitionByName("com.giab.games.gcfw.mcDyn." + className) as Class;
            var mc:DisplayObject = new cls() as DisplayObject;
            return _snapshot(mc, box, name);
        }

        /** Instantiate an auto-named Flash library symbol (GemCraftFrostbornWrath_fla.*). */
        private static function _fla(symbol:String):DisplayObject {
            var cls:Class = getDefinitionByName("GemCraftFrostbornWrath_fla." + symbol) as Class;
            return new cls() as DisplayObject;
        }

        private static function _gem(component:int, box:Number):DisplayObject {
            if (GV.gemBitmapCreator == null)
                return _placeholder(box);
            var gem:Gem = new Gem();
            gem.elderComponents = [component];
            gem.manaValuesByComponent[component].s(1);
            GV.gemBitmapCreator.giveGemBitmaps(gem, false);
            var mc:DisplayObject = gem.mc as DisplayObject;
            if (mc == null)
                return _placeholder(box);
            return _snapshot(mc, box, null);
        }

        // ── Marked Monster: no clean single monster sprite exists (monsters are
        //    sprite-sheet assembled). Use the swarm-monster body as a stand-in
        //    with a distinct gold ring for the "marked / special" read. Falls
        //    back to the monster-egg bitmap under the same ring.
        private static function _markedMonsterIcon(box:Number):DisplayObject {
            var container:Sprite = new Sprite();

            var inner:DisplayObject = null;
            try {
                inner = _snapshot(_fla("mcSwarmBody_255"), box * 0.78, null);
            } catch (e:Error) {
                try {
                    inner = _bmpd("BmpdMonsterEgg");
                } catch (e2:Error) {
                }
            }
            if (inner != null) {
                var s:Number = Math.min((box * 0.78) / inner.width, (box * 0.78) / inner.height);
                if (s > 0 && s < Number.POSITIVE_INFINITY)
                    inner.scaleX = inner.scaleY = s;
                inner.x = (box - inner.width) * 0.5;
                inner.y = (box - inner.height) * 0.5;
                container.addChild(inner);
            }

            var ring:Shape = new Shape();
            ring.graphics.lineStyle(3, 0xFFB020, 1);
            ring.graphics.drawRoundRect(2, 2, box - 4, box - 4, 12, 12);
            container.addChild(ring);
            return container;
        }

        // Fraction of the icon box the artwork fills; the rest is margin so
        // icons don't touch the plate edges.
        private static const SNAPSHOT_INSET:Number = 0.86;
        // Off-screen render resolution before the visible region is cropped and
        // downscaled into the icon (higher = crisper downscale).
        private static const SCRATCH:int = 160;

        /**
         * Render `mc`, detect its actual opaque pixels, then centre THAT region
         * (not the geometric bounds, which for entity sprites include invisible
         * bases / spawn points and throw off centring) into a box-sized bitmap
         * with uniform margin. `name` (may be null) looks up OVERRIDE nudges.
         */
        private static function _snapshot(mc:DisplayObject, box:Number, name:String):DisplayObject {
            var b:Rectangle = mc.getBounds(mc);
            if (b.width <= 1 || b.height <= 1)
                return _placeholder(box);

            // 1. Draw the sprite, centred, into a square scratch buffer.
            var s0:Number = Math.min(SCRATCH / b.width, SCRATCH / b.height);
            var scratch:BitmapData = new BitmapData(SCRATCH, SCRATCH, true, 0x00000000);
            var m0:Matrix = new Matrix();
            m0.translate(-(b.x + b.width * 0.5), -(b.y + b.height * 0.5));
            m0.scale(s0, s0);
            m0.translate(SCRATCH * 0.5, SCRATCH * 0.5);
            scratch.draw(mc, m0, null, null, null, true);

            // 2. Crop to the actual non-transparent pixels.
            var rect:Rectangle = scratch.getColorBoundsRect(0xFF000000, 0x00000000, false);
            if (rect.width < 1 || rect.height < 1)
                return _placeholder(box);

            // 3. Fit that region into the icon box (with inset + optional nudge).
            var dx:Number = 0;
            var dy:Number = 0;
            var extra:Number = 1;
            var ov:Object = (name != null) ? OVERRIDE[name] : null;
            if (ov != null) {
                if (ov.scale != undefined) extra = Number(ov.scale);
                if (ov.dx != undefined)    dx = Number(ov.dx);
                if (ov.dy != undefined)    dy = Number(ov.dy);
            }
            var fit:Number = box * SNAPSHOT_INSET * extra;
            var s1:Number = Math.min(fit / rect.width, fit / rect.height);

            var out:BitmapData = new BitmapData(box, box, true, 0x00000000);
            var m1:Matrix = new Matrix();
            m1.translate(-(rect.x + rect.width * 0.5), -(rect.y + rect.height * 0.5));
            m1.scale(s1, s1);
            m1.translate(box * 0.5 + dx, box * 0.5 + dy);
            out.draw(scratch, m1, null, null, null, true);

            var bmp:Bitmap = new Bitmap(out);
            bmp.smoothing = true;
            return bmp;
        }

        private static function _placeholder(box:Number):DisplayObject {
            var s:Sprite = new Sprite();
            s.graphics.beginFill(0x2A2A2A, 1);
            s.graphics.drawRoundRect(0, 0, box, box, 10, 10);
            s.graphics.endFill();

            var tf:TextField = new TextField();
            var fmt:TextFormat = new TextFormat("Arial", Math.round(box * 0.5), 0x888888, true);
            fmt.align = TextFormatAlign.CENTER;
            tf.defaultTextFormat = fmt;
            tf.selectable   = false;
            tf.mouseEnabled = false;
            tf.width  = box;
            tf.height = box;
            tf.y      = box * 0.2;
            tf.text   = "?";
            s.addChild(tf);
            return s;
        }
    }
}
