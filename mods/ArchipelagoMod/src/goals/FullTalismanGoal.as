package goals {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /** Goal: fill all 25 talisman sockets with fragments meeting a minimum rarity. */
    public class FullTalismanGoal implements IGoal {

        private var _logger:Logger;
        private var _modName:String;
        private var _minRarity:int;

        public function FullTalismanGoal(logger:Logger, modName:String, minRarity:int) {
            _logger    = logger;
            _modName   = modName;
            _minRarity = minRarity;
        }

        public function check():Boolean {
            var slots:Array = GV.ppd.talismanSlots;
            if (slots == null) return false;

            for (var i:int = 0; i < 25; i++) {
                var frag:* = slots[i];
                if (frag == null) return false;
                if (frag.rarity < _minRarity) return false;
            }
            return true;
        }

        public function get goalName():String {
            return "Full Talisman";
        }
    }
}
