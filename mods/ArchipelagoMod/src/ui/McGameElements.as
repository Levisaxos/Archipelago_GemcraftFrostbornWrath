package ui {
    import com.giab.games.gcfw.GV;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.geom.Rectangle;
    import flash.text.StaticText;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.getDefinitionByName;
    import tracker.FieldLogicEvaluator;

    /**
     * The "Game Elements" browser window.
     *
     * Wraps the game's McOptions chrome (same technique as McDebugOptions).
     *
     *   - A fixed toolbar (on _inner) holds a compact strip of requirement-type
     *     toggle icons plus a hover readout.
     *   - A third toolbar row holds count filters (Reaver / Swarmling / Giant / Waves): selecting one shows an "at least N" box next to it, and only fields with at least that many (blank = any) match.
     *   - The scrolling area (cnt) holds a 26x6 grid of fields — one row per tile
     *     letter A-Z, one column per number 1-6. A field that matches every
     *     selected filter (AND) is green when it is in logic and red when it is
     *     not; with no filters selected all fields are neutral.
     *
     * Hovering a field shows a tooltip of everything on it; clicking a field
     * asks the owner to close the window and pan the selector to it.
     */
    public class McGameElements extends MovieClip {

        /** Fired when a field cell is clicked (after panning): onRequestClose(). */
        public var onRequestClose:Function;

        private var _inner:*;
        private var _evaluator:FieldLogicEvaluator;

        private var _selected:Object = {};   // requirement name -> true
        private var _countSelected:Object = {};  // count filter name -> true
        private var _countBoxes:Object = {};     // count filter name -> CountInputBox
        private var _fieldCells:Array = [];  // Array<FieldGridCell>
        private var _iconCells:Array = [];   // Array<IconToggleCell> (filter strip)
        private var _ownedSet:Object = {};   // strId -> true for fields the player has
        private var _hoverRow:ScrollRow;
        private var _tooltip:FieldTooltip;

        // ── Layout ──────────────────────────────────────────────────────────────
        private static const TITLE_X:Number     = 536;
        private static const STRIP_X0:Number     = 206;
        private static const STRIP_SPAN:Number   = 940;   // left edge -> right edge of a row
        private static const STRIP_RIGHT:Number  = 1168;  // used only to clamp the field tooltip
        private static const HOVER_Y:Number      = 96;
        private static const STRIP_ROW1_Y:Number = 124;
        private static const STRIP_ROW2_Y:Number = 178;
        private static const COUNT_ROW_Y:Number  = 232;
        private static const PLATE:Number        = 40;
        /** Where the scrolling grid may start: just under the count-filter row. ScrGameElements feeds this to ScrollablePanel.clipTop. */
        public static const SCROLL_CLIP_TOP:Number = COUNT_ROW_Y + PLATE + 4;
        private static const ICON_FIT:Number     = 32;
        private static const COUNT_BOX_GAP:Number   = 6;    // count icon -> its "at least" box
        private static const COUNT_GROUP_GAP:Number = 34;   // box -> next count icon

        // Explicit two-row strip. Top row = structures (ends on Jar of Wasps);
        // bottom row = creatures, a gap, weather, a gap, gems. `null` = gap.
        // Each row is spread evenly across STRIP_SPAN so the two rows share the
        // same left and right edges regardless of item count.
        private static const TOP_ROW:Array = [
            "Trap", "Lantern", "Pylon", "Amplifier", "Barricade", "Monster Nest",
            "Tomb", "Mana Shard", "Shrine", "Beacon", "Sealed Gem", "Abandoned Dwelling",
            "Drop Holder", "Obelisk", "Sleeping Hive", "Watchtower", "Wizard Tower", "Jar of Wasps"
        ];
        private static const BOTTOM_ROW:Array = [
            "Apparition", "Specter", "Wraith", "Shadow", "Spire", "Wizard Hunter",
            "Swarm Queen", "Gatekeeper", "Marked Monster",
            null,
            "Rain", "Snow",
            null,
            "Crit Hit", "Mana Leech", "Bleeding", "Armor Tearing", "Poison", "Slowing"
        ];

        private static const GRID_TOP:Number     = 316;
        private static const ROW_LABEL_X:Number  = 178;
        private static const CELL_X0:Number       = 214;
        private static const COL_STEP:Number     = 152;
        private static const GRID_CELL_W:Number  = 140;
        private static const GRID_CELL_H:Number  = 28;
        private static const GRID_ROW_H:Number   = 34;
        private static const LETTERS:String      = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

        // Proxies into _inner.
        public function get arrCntContents():Array       { return _inner.arrCntContents; }
        public function set arrCntContents(v:Array):void { _inner.arrCntContents = v; }
        public function get cnt():*                      { return _inner.cnt; }
        public function get btnClose():*                 { return _inner.btnClose; }
        public function get btnScrollKnob():MovieClip    { return _inner.btnScrollKnob; }
        public function get mcScrollBar():*              { return _inner.mcScrollBar; }
        public function get btnConfirmRetry():*          { return _inner.btnConfirmRetry; }
        public function get btnConfirmReturn():*         { return _inner.btnConfirmReturn; }
        public function get btnConfirmEndBattle():*      { return _inner.btnConfirmEndBattle; }
        public function get btnEndBattle():*             { return _inner.btnEndBattle; }
        public function get btnReturn():*                { return _inner.btnReturn; }
        public function get btnRetry():*                 { return _inner.btnRetry; }
        public function get btnMainMenu():*              { return _inner.btnMainMenu; }

        public function McGameElements(evaluator:FieldLogicEvaluator) {
            super();
            _evaluator = evaluator;

            var McOptionsClass:Class =
                getDefinitionByName("com.giab.games.gcfw.mcStat.McOptions") as Class;
            _inner = new McOptionsClass();
            addChild(_inner);

            _overlayTitle("Game Elements");

            while (_inner.cnt.numChildren > 0)
                _inner.cnt.removeChildAt(0);
            _inner.arrCntContents = [];

            _hoverRow = new ScrollRow(STRIP_X0, 18, false);
            _hoverRow.y = HOVER_Y;
            _inner.addChild(_hoverRow);
            _resetHover();

            _buildStrip();
            _buildGrid();
            refresh();

            // Tooltip on top of everything in this window.
            _tooltip = new FieldTooltip();
            addChild(_tooltip);
        }

        /**
         * Re-evaluate field ownership and refresh both the grid (lock fields the
         * player doesn't have) and the filter strip (disable types no available
         * field carries). Call on every open() — ownership changes with play.
         */
        public function refresh():void {
            _recomputeOwned();
            _updateIconAvailability();
            _applyFilters();
        }

        private function _recomputeOwned():void {
            _ownedSet = {};
            for each (var cell:FieldGridCell in _fieldCells) {
                if (_isAvailable(cell.strId))
                    _ownedSet[cell.strId] = true;
            }
        }

        /** A field the player has = journey XP entry >= 0 (-1 means locked). */
        private function _isAvailable(strId:String):Boolean {
            if (GV.stageCollection == null || GV.ppd == null)
                return false;
            var id:int = GV.getFieldId(strId);
            if (id < 0)
                return false;
            var arr:* = GV.ppd.stageHighestXpsJourney;
            if (arr == null)
                return false;
            var entry:* = arr[id];
            if (entry == null)
                return false;
            return int(entry.g()) >= 0;
        }

        /** Disable filter icons whose type no owned field carries; drop any such
         *  type from the current selection so it can't blank the grid. */
        private function _updateIconAvailability():void {
            for each (var cell:IconToggleCell in _iconCells) {
                var stages:Object = _stagesFor(cell.reqName);
                var avail:Boolean = false;
                for (var sid:String in stages) {
                    if (_ownedSet[sid] == true) {
                        avail = true;
                        break;
                    }
                }
                if (!avail && cell.selected) {
                    cell.setSelected(false);
                    _setFilterSelected(cell.reqName, false);
                }
                cell.setEnabled(avail);
            }
        }

        /** Fields carrying a single filter; a count filter needs at least one of its monster type / waves. */
        private function _stagesFor(name:String):Object {
            if (FieldLogicEvaluator.isCountFilter(name))
                return _evaluator.getStagesWithMinCount(name, 1);
            return _evaluator.getStagesMatching([name]);
        }

        /** Record a filter's selection; a count filter also shows/hides its "at least" box. */
        private function _setFilterSelected(name:String, selected:Boolean):void {
            if (FieldLogicEvaluator.isCountFilter(name)) {
                _countSelected[name] = selected;
                (_countBoxes[name] as CountInputBox).visible = selected;
            }
            else
                _selected[name] = selected;
        }

        // -----------------------------------------------------------------------
        // Fixed filter strip (on _inner)

        private function _buildStrip():void {
            _placeRow(TOP_ROW, STRIP_ROW1_Y);
            _placeRow(BOTTOM_ROW, STRIP_ROW2_Y);
            _placeCountRow(COUNT_ROW_Y);
        }

        /** Count filters, left-aligned at STRIP_X0: each icon is followed by its "at least N" box, shown only while the icon is selected. */
        private function _placeCountRow(y:Number):void {
            var x:Number = STRIP_X0;
            for each (var nm:String in FieldLogicEvaluator.COUNT_FILTERS) {
                var icon:DisplayObject = RequirementIconRegistry.makeIcon(nm, ICON_FIT);
                var cell:IconToggleCell = new IconToggleCell(
                    nm, icon, PLATE, false, RequirementIconRegistry.needsFix(nm));
                cell.x        = x;
                cell.y        = y;
                cell.onToggle = _onToggleFilter;
                cell.onHover  = _onIconHover;
                _inner.addChild(cell);
                _iconCells.push(cell);

                var box:CountInputBox = new CountInputBox();
                box.x        = x + PLATE + COUNT_BOX_GAP;
                box.y        = y + (PLATE - CountInputBox.BOX_H) * 0.5;
                box.visible  = false;
                box.onChange = _applyFilters;
                _inner.addChild(box);
                _countBoxes[nm] = box;

                x += PLATE + COUNT_BOX_GAP + CountInputBox.BOX_W + COUNT_GROUP_GAP;
            }
        }

        /** Place a row's icons evenly across STRIP_SPAN (skipping null gaps).
         *  Step is sized so the first slot's left edge sits at STRIP_X0 and the
         *  last slot's right edge sits at STRIP_X0 + STRIP_SPAN — so every row
         *  shares the same left/right edges. */
        private function _placeRow(row:Array, y:Number):void {
            var slots:int = row.length;
            var step:Number = (slots > 1) ? (STRIP_SPAN - PLATE) / (slots - 1) : 0;
            for (var i:int = 0; i < slots; i++) {
                var nm:String = row[i] as String;
                if (nm == null)
                    continue;
                var icon:DisplayObject = RequirementIconRegistry.makeIcon(nm, ICON_FIT);
                var cell:IconToggleCell = new IconToggleCell(
                    nm, icon, PLATE, false, RequirementIconRegistry.needsFix(nm));
                cell.x        = STRIP_X0 + i * step;
                cell.y        = y;
                cell.onToggle = _onToggleFilter;
                cell.onHover  = _onIconHover;
                _inner.addChild(cell);
                _iconCells.push(cell);
            }
        }

        // -----------------------------------------------------------------------
        // Scrolling field grid (in cnt)

        private function _buildGrid():void {
            var exists:Object = {};
            var metas:Array = (GV.stageCollection != null) ? GV.stageCollection.stageMetas : null;
            if (metas != null) {
                for each (var meta:* in metas) {
                    if (meta != null)
                        exists[String(meta.strId)] = true;
                }
            }

            var arr:Array = [];
            _fieldCells = [];

            // Column-number header.
            for (var ch:int = 1; ch <= 6; ch++) {
                var hdr:ScrollRow = new ScrollRow(CELL_X0 + (ch - 1) * COL_STEP + GRID_CELL_W * 0.5 - 6, 16, true);
                hdr.setText(String(ch), 0x8AA0B0);
                hdr.yReal = GRID_TOP - 24;
                arr.push(hdr);
            }

            var y:Number = GRID_TOP;
            for (var r:int = 0; r < LETTERS.length; r++) {
                var letter:String = LETTERS.charAt(r);

                var rowLabel:ScrollRow = new ScrollRow(ROW_LABEL_X, 20, true);
                rowLabel.setText(letter, 0x8AA0B0);
                rowLabel.yReal = y + 3;
                arr.push(rowLabel);

                for (var c:int = 1; c <= 6; c++) {
                    var strId:String = letter + c;
                    if (exists[strId] != true)
                        continue;
                    var cell:FieldGridCell = new FieldGridCell(strId, GRID_CELL_W, GRID_CELL_H);
                    cell.x       = CELL_X0 + (c - 1) * COL_STEP;
                    cell.yReal   = y;
                    cell.onHover = _onFieldHover;
                    cell.onClick = _onFieldClick;
                    arr.push(cell);
                    _fieldCells.push(cell);
                }
                y += GRID_ROW_H;
            }

            arrCntContents = arr;
            for (var k:int = 0; k < arr.length; k++)
                cnt.addChild(arr[k] as DisplayObject);
        }

        // -----------------------------------------------------------------------
        // Filtering

        private function _onToggleFilter(name:String, selected:Boolean):void {
            _setFilterSelected(name, selected);
            if (selected && FieldLogicEvaluator.isCountFilter(name))
                (_countBoxes[name] as CountInputBox).focusInput();
            _applyFilters();
        }

        private function _applyFilters():void {
            var names:Array = [];
            for (var k:String in _selected) {
                if (_selected[k] == true)
                    names.push(k);
            }
            // null = no filter active; otherwise the strId -> true set matching every selected filter (AND).
            var matchSet:Object = (names.length > 0) ? _evaluator.getStagesMatching(names) : null;
            for (var cn:String in _countSelected) {
                if (_countSelected[cn] != true)
                    continue;
                // A blank or 0 box still requires the type to be present on the field.
                var min:int = Math.max(1, (_countBoxes[cn] as CountInputBox).value);
                var hits:Object = _evaluator.getStagesWithMinCount(cn, min);
                matchSet = (matchSet == null) ? hits : _intersect(matchSet, hits);
            }
            var active:Boolean = matchSet != null;

            for each (var cell:FieldGridCell in _fieldCells) {
                // Ownership wins: a field the player doesn't have is always
                // locked (inert, never green) so it can't tempt them.
                if (_ownedSet[cell.strId] != true)
                    cell.setState(FieldGridCell.LOCKED);
                else if (!active)
                    cell.setState(FieldGridCell.NEUTRAL);
                else if (matchSet[cell.strId] != true)
                    cell.setState(FieldGridCell.DIMMED);
                else
                    // A match is only useful if the field can actually be beaten now: green in logic, red out of logic (same clearability as the field tooltip's Journey orb).
                    cell.setState(_evaluator.canCompleteStage(cell.strId)
                        ? FieldGridCell.MATCHED : FieldGridCell.MATCHED_OOL);
            }
        }

        private static function _intersect(a:Object, b:Object):Object {
            var out:Object = {};
            for (var sid:String in a) {
                if (a[sid] == true && b[sid] == true)
                    out[sid] = true;
            }
            return out;
        }

        // -----------------------------------------------------------------------
        // Field hover / click

        private function _onFieldHover(strId:String):void {
            if (strId == null) {
                _tooltip.hide();
                return;
            }
            var lines:Array = (_evaluator != null) ? _evaluator.getFieldContents(strId) : null;
            _tooltip.showFor(strId, lines, this.mouseX, this.mouseY, STRIP_RIGHT, _selectedLabels());
        }

        /** Selected filters as the labels they carry in the field tooltip, so the tooltip can colour them. */
        private function _selectedLabels():Object {
            var out:Object = {};
            if (_evaluator == null)
                return out;
            for (var k:String in _selected) {
                if (_selected[k] == true)
                    out[_evaluator.getContentsLabel(k)] = true;
            }
            // Count filters appear in the tooltip under their own name ("Reaver x358").
            for (var cn:String in _countSelected) {
                if (_countSelected[cn] == true)
                    out[cn] = true;
            }
            return out;
        }

        private function _onFieldClick(strId:String):void {
            _tooltip.hide();
            _panToField(strId);
            if (onRequestClose != null)
                onRequestClose();
        }

        private function _panToField(strId:String):void {
            if (GV.selectorCore == null || GV.stageCollection == null)
                return;
            var id:int = GV.getFieldId(strId);
            if (id < 0)
                return;
            var metas:Array = GV.stageCollection.stageMetas;
            if (id >= metas.length)
                return;
            var meta:* = metas[id];
            if (meta == null)
                return;
            var sc:* = GV.selectorCore;
            sc.vpX = Math.max(sc.vpXMin, Math.min(sc.vpXMax, Number(meta.mapX)));
            sc.vpY = Math.max(sc.vpYMin, Math.min(sc.vpYMax, Number(meta.mapY)));
        }

        // -----------------------------------------------------------------------
        // Icon hover readout

        private function _onIconHover(name:String):void {
            if (name == null) {
                _resetHover();
                return;
            }
            if (FieldLogicEvaluator.isCountFilter(name)) {
                _hoverRow.setText(name + ": select, then type the minimum in the box (blank = any)", 0xFFE9A8);
                return;
            }
            var flagged:Boolean = RequirementIconRegistry.needsFix(name);
            _hoverRow.setText(name + (flagged ? "   (icon needs fixing)" : ""),
                flagged ? 0xFF8A80 : 0xFFE9A8);
        }

        private function _resetHover():void {
            if (_hoverRow != null)
                _hoverRow.setText("Toggle element icons to filter fields below", 0x9FB0BE);
        }

        // -----------------------------------------------------------------------
        // Title overlay (copied from McDebugOptions)

        private function _overlayTitle(label:String):void {
            var original:StaticText = _findStaticText(_inner, "Options");
            if (original != null) {
                original.visible = false;
                var bounds:Rectangle = original.getBounds(original.parent);
                var tf:TextField = new TextField();
                var fmt:TextFormat = new TextFormat("Palatino Linotype", 28, 0xffffff, true);
                fmt.align = "center";
                tf.defaultTextFormat = fmt;
                tf.selectable   = false;
                tf.mouseEnabled = false;
                var tfWidth:Number = 400;
                tf.x      = bounds.x + bounds.width / 2 - tfWidth / 2;
                tf.y      = bounds.y;
                tf.width  = tfWidth;
                tf.height = bounds.height + 8;
                tf.text   = label;
                original.parent.addChild(tf);
            }
        }

        private function _findStaticText(obj:DisplayObjectContainer, search:String):StaticText {
            for (var i:int = 0; i < obj.numChildren; i++) {
                var child:* = obj.getChildAt(i);
                if (child is StaticText && StaticText(child).text == search)
                    return StaticText(child);
                if (child is DisplayObjectContainer) {
                    var found:StaticText = _findStaticText(DisplayObjectContainer(child), search);
                    if (found != null)
                        return found;
                }
            }
            return null;
        }
    }
}
