package ui {
    /**
     * Maps Archipelago item-classification flags to toast colours so the
     * receive popup conveys importance instead of item type.
     *
     * Flags arrive on every NetworkItem (RoomInfo / ReceivedItems): bit 1 is
     * progression, bit 2 useful, bit 4 trap, 0 means filler. Captured once
     * per apId by ApReceiver; toast sites then call forApId() with the
     * received apId.
     *
     * Colours mirror the Archipelago client palette (CommonClient / kvui):
     *   progression — plum / light purple
     *   useful      — slate blue
     *   trap        — salmon
     *   filler      — cyan
     */
    public class ItemColors {

        public static const PROGRESSION:uint = 0xAF99EF;
        public static const USEFUL:uint      = 0x6D8BE8;
        public static const TRAP:uint        = 0xFA8072;
        public static const FILLER:uint      = 0x00EEEE;

        private static const FLAG_PROGRESSION:int = 0x1;
        private static const FLAG_USEFUL:int      = 0x2;
        private static const FLAG_TRAP:int        = 0x4;

        // apId (int) -> flags (int). Populated by ApReceiver every time a
        // NetworkItem arrives. Multiple copies of the same apId always carry
        // the same flags for a given seed, so first-write-wins is fine.
        private static var _flagsByApId:Object = {};

        public static function setFlags(apId:int, flags:int):void {
            _flagsByApId[apId] = flags;
        }

        public static function clear():void {
            _flagsByApId = {};
        }

        /** Resolve flags to the toast colour. Trap wins over progression
         *  wins over useful; absent flags fall through to filler. */
        public static function forFlags(flags:int):uint {
            if ((flags & FLAG_TRAP)        != 0) return TRAP;
            if ((flags & FLAG_PROGRESSION) != 0) return PROGRESSION;
            if ((flags & FLAG_USEFUL)      != 0) return USEFUL;
            return FILLER;
        }

        /** Look up the cached flags for an apId and return the matching
         *  colour. Falls back to PROGRESSION when nothing has been cached
         *  yet — most items in this mod are progression so it's the safest
         *  default for the brief window before a NetworkItem has been
         *  observed for that apId. */
        public static function forApId(apId:int):uint {
            if (apId in _flagsByApId) {
                return forFlags(int(_flagsByApId[apId]));
            }
            return PROGRESSION;
        }
    }
}
