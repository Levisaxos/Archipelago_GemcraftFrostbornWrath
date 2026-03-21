package {
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.mcStat.McOptions;
    import com.giab.games.gcfw.mcDyn.McOptPanel;
    import com.giab.games.gcfw.mcDyn.McOptTitle;
    import flash.display.DisplayObjectContainer;
    import flash.geom.Rectangle;
    import flash.text.StaticText;
    import flash.text.TextField;
    import flash.text.TextFormat;

    // Extends the game's own McOptions so we get the symbol3117 chrome for free —
    // no [Embed] needed; the asset is already baked into the game's SWC.
    public class McDebugOptions extends McOptions {

        private static const SKILL_NAMES:Array = [
            "Mana Stream", "True Colors", "Fusion", "Orb of Presence",
            "Resonance", "Demolition", "Critical Hit", "Mana Leech",
            "Bleeding", "Armor Tearing", "Poison", "Slowing",
            "Freeze", "Whiteout", "Ice Shards", "Bolt",
            "Beam", "Barrage", "Fury", "Amplifiers",
            "Pylons", "Lanterns", "Traps", "Seeker Sense"
        ];

        private static const BATTLE_TRAIT_NAMES:Array = [
            "Adaptive Carapace", "Dark Masonry", "Swarmling Domination", "Overcrowd",
            "Corrupted Banishment", "Awakening", "Insulation", "Hatred",
            "Swarmling Parasites", "Haste", "Thick Air", "Vital Link",
            "Giant Domination", "Strength in Numbers", "Ritual"
        ];

        // Tile letters in alphabetical order for the Stages section.
        private static const TILE_LETTERS:Array = [
            "A","B","C","D","E","F","G","H","I","J","K","L","M",
            "N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
        ];

        // All buttons, cnt, arrCntContents, btnScrollKnob, mcScrollBar are inherited from McOptions.

        // Skill, battle trait, and stage panels (our additions, not in McOptions).
        public var skillPanels:Array;
        public var traitPanels:Array;
        // stageStrId -> McOptPanel  (e.g. "W1" -> the panel for W1)
        public var stageIdToPanel:Object;

        // Layout constants — tweak these to adjust panel positioning.
        private static const CONTENT_START_Y:Number = 140;  // Y of the first content item (Skills title)
        private static const ROW_HEIGHT:Number       = 60;   // Vertical step between panel rows
        private static const SECTION_GAP:Number      = 120;  // Extra gap between sections
        private static const TITLE_X:Number          = 536;  // X centre of section header titles
        private static const COL_LEFT_X:Number       = 250;  // X of left-column panels  (matches McOptions)
        private static const COL_RIGHT_X:Number      = 1067; // X of right-column panels (matches McOptions)

        public function McDebugOptions() {
            var i:int = 0;
            super(); // Populates cnt and arrCntContents with the normal options panels.

            // The title "Options" is static text baked into the symbol and can't be changed
            // via AS3, so we paint over it with a filled rectangle and our own TextField.
            overlayTitle("Archipelago Debug");

            // Clear out all the normal options content — we only want our own panels.
            while (cnt.numChildren > 0) cnt.removeChildAt(0);
            arrCntContents  = new Array();
            skillPanels     = new Array();
            traitPanels     = new Array();
            stageIdToPanel  = {};

            var vY:Number = CONTENT_START_Y;

            // ── Skills section ────────────────────────────────────────────────
            arrCntContents.push(new McOptTitle("Skills", TITLE_X, vY));
            vY += ROW_HEIGHT;

            for (i = 0; i < 24; i++) {
                var spX:Number  = (i % 2 == 0) ? COL_LEFT_X : COL_RIGHT_X;
                var spnl:McOptPanel = new McOptPanel(SKILL_NAMES[i], spX, vY, false);
                skillPanels.push(spnl);
                arrCntContents.push(spnl);
                if (i % 2 == 1) vY += ROW_HEIGHT;
            }
            // 24 is even, so the last pair already incremented vY.

            vY += SECTION_GAP;

            // ── Battle Traits section ─────────────────────────────────────────
            arrCntContents.push(new McOptTitle("Battle Traits", TITLE_X, vY));
            vY += ROW_HEIGHT;

            for (i = 0; i < 15; i++) {
                var tpX:Number  = (i % 2 == 0) ? COL_LEFT_X : COL_RIGHT_X;
                var tpnl:McOptPanel = new McOptPanel(BATTLE_TRAIT_NAMES[i], tpX, vY, false);
                traitPanels.push(tpnl);
                arrCntContents.push(tpnl);
                if (i % 2 == 1) vY += ROW_HEIGHT;
            }
            // 15 is odd: last item is at COL_LEFT_X, its row never got vY += ROW_HEIGHT.
            vY += ROW_HEIGHT;

            // ── Stages section (A → Z, one tile per sub-section) ──────────────
            if (GV.stageCollection != null) {
                vY += SECTION_GAP;
                arrCntContents.push(new McOptTitle("Stages", TITLE_X, vY));
                vY += ROW_HEIGHT;

                // Group stage IDs by tile letter.
                var tileStages:Object = {};
                var metas:Array = GV.stageCollection.stageMetas;
                for (var j:int = 0; j < metas.length; j++) {
                    if (metas[j] == null) continue;
                    var ltr:String = metas[j].strId.charAt(0).toUpperCase();
                    if (tileStages[ltr] == null) tileStages[ltr] = [];
                    (tileStages[ltr] as Array).push(metas[j].strId);
                }
                for (var l:String in tileStages) {
                    (tileStages[l] as Array).sort();
                }

                for (var li:int = 0; li < TILE_LETTERS.length; li++) {
                    var tileLetter:String = TILE_LETTERS[li];
                    var stages:Array = tileStages[tileLetter] as Array;
                    if (stages == null) continue;

                    // Tile sub-header.
                    arrCntContents.push(new McOptTitle(tileLetter, TITLE_X, vY));
                    vY += ROW_HEIGHT;

                    // Stage panels, two per row.
                    for (var si:int = 0; si < stages.length; si++) {
                        var sId:String  = stages[si];
                        var sX:Number   = (si % 2 == 0) ? COL_LEFT_X : COL_RIGHT_X;
                        var stagePnl:McOptPanel = new McOptPanel(sId, sX, vY, false);
                        stageIdToPanel[sId] = stagePnl;
                        arrCntContents.push(stagePnl);
                        if (si % 2 == 1) vY += ROW_HEIGHT;
                    }
                    // If odd stage count, the last item didn't trigger an increment.
                    if (stages.length % 2 != 0) vY += ROW_HEIGHT;
                }
            }

            // Add all content to the scrollable container.
            for (i = 0; i < arrCntContents.length; i++) {
                cnt.addChild(arrCntContents[i]);
            }
        }

        private function overlayTitle(label:String):void {
            // Find and hide the baked-in StaticText that reads "Options".
            var original:StaticText = findStaticText(this, "Options");
            if (original != null) {
                original.visible = false;

                // getBounds() gives the real position in the parent's coordinate space,
                // unlike x/y which are unreliable on StaticText objects.
                var bounds:Rectangle = original.getBounds(original.parent);

                var tf:TextField = new TextField();
                var fmt:TextFormat = new TextFormat("Palatino Linotype", 28, 0xffffff, true);
                fmt.align = "center";
                tf.defaultTextFormat = fmt;
                tf.selectable   = false;
                tf.mouseEnabled = false;
                // "Archipelago Debug" is wider than "Options", so expand the box
                // symmetrically around the original centre point.
                var tfWidth:Number = 400;
                tf.x      = bounds.x + bounds.width / 2 - tfWidth / 2;
                tf.y      = bounds.y;
                tf.width  = tfWidth;
                tf.height = bounds.height + 8;
                tf.text   = label;
                original.parent.addChild(tf);
            }
        }

        // Walk the display tree and return the first StaticText whose content matches.
        private function findStaticText(obj:DisplayObjectContainer, search:String):StaticText {
            var i:int = 0;
            for (i = 0; i < obj.numChildren; i++) {
                var child:* = obj.getChildAt(i);
                if (child is StaticText && StaticText(child).text == search) {
                    return StaticText(child);
                }
                if (child is DisplayObjectContainer) {
                    var found:StaticText = findStaticText(DisplayObjectContainer(child), search);
                    if (found != null) return found;
                }
            }
            return null;
        }
    }
}
