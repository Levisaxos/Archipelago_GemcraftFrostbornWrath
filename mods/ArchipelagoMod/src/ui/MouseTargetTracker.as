package ui {
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;

    import com.giab.games.gcfw.GV;

    /**
     * Records the topmost mouse target under the cursor, as routed by the
     * Flash player itself, so the mod's coordinate-driven hover code can
     * respect z-order.
     *
     * Several mod hovers (the field tooltip, the AP Shop button, the locked
     * Endurance/Trial tooltips, the Hollow Gem button, the In-Logic button)
     * poll mouseX/mouseY or hitTestPoint every frame instead of using
     * MOUSE_OVER. Those tests ignore z-order: anything drawn over the target
     * (a mod window on GV.main, the stage-level message log, a vanilla popup)
     * still lets the thing beneath react. The player's own mouse routing has
     * the z-order truth, and it hands it to us for free as the target of a
     * bubble-phase stage MOUSE_MOVE: the topmost visible, mouse-enabled object
     * under the cursor (the stage itself when over nothing).
     *
     * Consumers ask isInside(container): true when that target sits inside
     * the container that owns the hovered widget, i.e. nothing is drawn over
     * it at the cursor. Null target (no move seen yet) counts as inside, so
     * the geometry test alone decides. A stale target (the window over it was
     * closed under a stationary cursor) reads as outside until the next mouse
     * move, which is how vanilla rollovers behave too.
     *
     * Lifecycle: enable() in AP activation, disable() on deactivation and mod
     * unload (standalone clean-slate rule). The listener itself is installed
     * lazily on first use, because the stage may not exist at activation.
     */
    public class MouseTargetTracker {

        private static var _enabled:Boolean = false;
        private static var _installed:Boolean = false;
        private static var _stage:* = null;
        private static var _target:DisplayObject = null;

        /** Allow the tracker to install itself on first use. */
        public static function enable():void {
            _enabled = true;
        }

        /** Remove the stage listener and forget the last target. */
        public static function disable():void {
            _enabled = false;
            if (_installed && _stage != null) {
                try {
                    _stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
                } catch (e:Error) {}
            }
            _installed = false;
            _stage = null;
            _target = null;
        }

        /** The last routed mouse target, or null when none has been seen. */
        public static function get target():DisplayObject {
            ensureInstalled();
            return _target;
        }

        /**
         * True when the routed mouse target is `container` or one of its
         * descendants, or when no target is known yet. False when something
         * outside the container (a window, another panel, the stage) is the
         * topmost thing under the cursor.
         */
        public static function isInside(container:DisplayObject):Boolean {
            ensureInstalled();
            if (_target == null || container == null)
                return true;
            var d:DisplayObject = _target;
            while (d != null) {
                if (d === container)
                    return true;
                d = d.parent;
            }
            return false;
        }

        /** Bubble-phase stage listener: nothing in vanilla stops propagation,
         *  and a capture-phase listener would never see the stage-is-target
         *  case (the cursor over nothing mouse-enabled). */
        private static function ensureInstalled():void {
            if (_installed || !_enabled)
                return;
            try {
                var stg:* = (GV.main != null) ? GV.main.stage : null;
                if (stg == null)
                    return;
                stg.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove, false, 0, true);
                _stage = stg;
                _installed = true;
            } catch (e:Error) {}
        }

        private static function onStageMouseMove(e:MouseEvent):void {
            _target = e.target as DisplayObject;
        }
    }
}
