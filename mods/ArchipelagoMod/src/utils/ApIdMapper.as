package utils {

    /**
     * Utility for mapping AP item IDs to game data.
     * Provides a generic lookup interface for id → data conversions.
     */
    public class ApIdMapper {

        private var _map:Object;

        public function ApIdMapper(dataMap:Object) {
            _map = dataMap;
        }

        /**
         * Retrieve a value from the map by AP ID.
         * Returns defaultValue if the ID is not found.
         */
        public function getValue(apId:int, defaultValue:* = null):* {
            if (_map != null) {
                var key:String = String(apId);
                if (key in _map) {
                    return _map[key];
                }
            }
            return defaultValue;
        }

        /**
         * Check if an AP ID exists in the map.
         */
        public function hasId(apId:int):Boolean {
            if (_map == null) return false;
            return String(apId) in _map;
        }
    }
}
