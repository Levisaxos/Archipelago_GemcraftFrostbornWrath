package unlockers {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import ui.ReceivedToast;

    /**
     * Base class for all unlocker types.
     * Provides shared initialization, logging, toast notifications, and common utilities.
     */
    public class BaseUnlocker {

        protected var _logger:Logger;
        protected var _modName:String;
        protected var _itemToast:ReceivedToast;

        public function BaseUnlocker(logger:Logger, modName:String, itemToast:ReceivedToast) {
            _logger    = logger;
            _modName   = modName;
            _itemToast = itemToast;
        }

        /**
         * Log an action with the configured logger and mod name.
         */
        protected function logAction(action:String):void {
            _logger.log(_modName, action);
        }

        /**
         * Show a toast notification via ReceivedToast.
         */
        protected function showToast(message:String, color:uint):void {
            _itemToast.addItem(message, color);
        }

        /**
         * Verify that GV.ppd is not null, logging an error if it is.
         * Returns true if ppd exists, false otherwise.
         */
        protected function ensurePpdExists(action:String):Boolean {
            if (GV.ppd == null) {
                logAction(action + ": GV.ppd null");
                return false;
            }
            return true;
        }

        /**
         * Show a plus node on the selector (if it exists).
         * Used to highlight newly unlocked items on the stage selector.
         */
        protected function showPlusNodeOnSelector(nodeName:String):void {
            try {
                var mc:* = GV.selectorCore != null ? GV.selectorCore.mc : null;
                if (mc == null) return;
                var node:* = mc[nodeName];
                if (node != null) mc.addChild(node);
            } catch (err:Error) {
                logAction("showPlusNodeOnSelector " + nodeName + " error: " + err.message);
            }
        }
    }
}
