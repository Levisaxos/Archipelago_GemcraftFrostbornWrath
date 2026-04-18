package ui {
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.mcDyn.McOptPanel;
    import com.giab.games.gcfw.mcDyn.McOptTitle;
    import ui.McWizardLevelSlider;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.geom.Rectangle;
    import flash.text.StaticText;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.getDefinitionByName;
    import tracker.CollectedState;
    import unlockers.TraitUnlocker;

    /**
     * Debug options panel.
     *
     * McOptions is not in the SWC stub (and its source depends on fl.motion.AdjustColor
     * which is Flash-authoring-only), so we cannot extend it at compile time.
     * Instead we extend plain MovieClip and instantiate McOptions at runtime via
     * getDefinitionByName -- the class is present in the game SWF.
     *
     * Critical: McOptions extends SpriteExt extends Sprite (NOT MovieClip), so the
     * inner instance must be typed * (not MovieClip) to avoid a silent null from "as MovieClip".
     */
    public class McDebugOptions extends MovieClip {

        // -- Our own additions (NOT in McOptions) --
        public var skillPanels:Array;
        public var traitPanels:Array;
        // stageStrId -> McOptPanel
        public var stageIdToPanel:Object;
        public var wizardSlider:McWizardLevelSlider;

        // -- Inner McOptions instance (typed * because McOptions extends Sprite, not MovieClip) --
        private var _inner:*;

        public function get arrCntContents():Array           { return _inner.arrCntContents; }
        public function set arrCntContents(v:Array):void     { _inner.arrCntContents = v; }
        public function get cnt():*                          { return _inner.cnt; }
        public function get btnClose():*                     { return _inner.btnClose; }
        public function get btnScrollKnob():MovieClip        { return _inner.btnScrollKnob; }
        public function get mcScrollBar():*                  { return _inner.mcScrollBar; }
        public function get btnConfirmRetry():*              { return _inner.btnConfirmRetry; }
        public function get btnConfirmReturn():*             { return _inner.btnConfirmReturn; }
        public function get btnConfirmEndBattle():*          { return _inner.btnConfirmEndBattle; }
        public function get btnEndBattle():*                 { return _inner.btnEndBattle; }
        public function get btnReturn():*                    { return _inner.btnReturn; }
        public function get btnRetry():*                     { return _inner.btnRetry; }
        public function get btnMainMenu():*                  { return _inner.btnMainMenu; }

        // Layout constants
        private static const CONTENT_START_Y:Number = 140;
        private static const ROW_HEIGHT:Number       = 60;
        private static const SECTION_GAP:Number      = 120;
        private static const TITLE_X:Number          = 536;
        private static const COL_LEFT_X:Number       = 250;
        private static const COL_RIGHT_X:Number      = 1067;

        // Canonical name lists live in CollectedState and TraitUnlocker — reference them directly.
        private static function get SKILL_NAMES():Array        { return CollectedState.SKILL_NAMES; }
        private static function get BATTLE_TRAIT_NAMES():Array { return TraitUnlocker.BATTLE_TRAIT_NAMES; }

        private static const TILE_LETTERS:Array = [
            "A","B","C","D","E","F","G","H","I","J","K","L","M",
            "N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
        ];

        public function McDebugOptions() {
            var i:int = 0;
            super();

            // Instantiate the real McOptions from the game SWF at runtime.
            // Must NOT cast to MovieClip -- McOptions extends Sprite, not MovieClip.
            var McOptionsClass:Class =
                getDefinitionByName("com.giab.games.gcfw.mcStat.McOptions") as Class;
            _inner = new McOptionsClass();
            addChild(_inner);   // positions at (0,0) so chrome renders correctly

            overlayTitle("Archipelago Debug");

            // Clear normal options content -- only our panels go in.
            while (_inner.cnt.numChildren > 0) _inner.cnt.removeChildAt(0);
            _inner.arrCntContents = new Array();
            skillPanels    = new Array();
            traitPanels    = new Array();
            stageIdToPanel = {};

            var vY:Number = CONTENT_START_Y;

            // -- Wizard Level --
            _inner.arrCntContents.push(new McOptTitle("Wizard Level", TITLE_X, vY));
            vY += ROW_HEIGHT;
            wizardSlider = new McWizardLevelSlider(0, vY);
            _inner.arrCntContents.push(wizardSlider);
            vY += ROW_HEIGHT + SECTION_GAP;

            // -- Skills --
            _inner.arrCntContents.push(new McOptTitle("Skills", TITLE_X, vY));
            vY += ROW_HEIGHT;
            for (i = 0; i < 24; i++) {
                var spX:Number = (i % 2 == 0) ? COL_LEFT_X : COL_RIGHT_X;
                var spnl:McOptPanel = new McOptPanel(SKILL_NAMES[i], spX, vY, false);
                skillPanels.push(spnl);
                _inner.arrCntContents.push(spnl);
                if (i % 2 == 1) vY += ROW_HEIGHT;
            }

            vY += SECTION_GAP;

            // -- Battle Traits --
            _inner.arrCntContents.push(new McOptTitle("Battle Traits", TITLE_X, vY));
            vY += ROW_HEIGHT;
            for (i = 0; i < 15; i++) {
                var tpX:Number = (i % 2 == 0) ? COL_LEFT_X : COL_RIGHT_X;
                var tpnl:McOptPanel = new McOptPanel(BATTLE_TRAIT_NAMES[i], tpX, vY, false);
                traitPanels.push(tpnl);
                _inner.arrCntContents.push(tpnl);
                if (i % 2 == 1) vY += ROW_HEIGHT;
            }
            vY += ROW_HEIGHT; // last trait row (15 is odd)

            // -- Stages --
            if (GV.stageCollection != null) {
                vY += SECTION_GAP;
                _inner.arrCntContents.push(new McOptTitle("Stages", TITLE_X, vY));
                vY += ROW_HEIGHT;

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

                    _inner.arrCntContents.push(new McOptTitle(tileLetter, TITLE_X, vY));
                    vY += ROW_HEIGHT;

                    for (var si:int = 0; si < stages.length; si++) {
                        var sId:String = stages[si];
                        var sX:Number  = (si % 2 == 0) ? COL_LEFT_X : COL_RIGHT_X;
                        var stagePnl:McOptPanel = new McOptPanel(sId, sX, vY, false);
                        stageIdToPanel[sId] = stagePnl;
                        _inner.arrCntContents.push(stagePnl);
                        if (si % 2 == 1) vY += ROW_HEIGHT;
                    }
                    if (stages.length % 2 != 0) vY += ROW_HEIGHT;
                }
            }

            for (i = 0; i < _inner.arrCntContents.length; i++) {
                _inner.cnt.addChild(_inner.arrCntContents[i]);
            }
        }

        private function overlayTitle(label:String):void {
            var original:StaticText = findStaticText(_inner, "Options");
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

        private function findStaticText(obj:DisplayObjectContainer, search:String):StaticText {
            for (var i:int = 0; i < obj.numChildren; i++) {
                var child:* = obj.getChildAt(i);
                if (child is StaticText && StaticText(child).text == search) return StaticText(child);
                if (child is DisplayObjectContainer) {
                    var found:StaticText = findStaticText(DisplayObjectContainer(child), search);
                    if (found != null) return found;
                }
            }
            return null;
        }
    }
}
