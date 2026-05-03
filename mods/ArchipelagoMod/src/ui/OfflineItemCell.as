package ui {
    import flash.display.Sprite;

    /**
     * Single grid cell in the offline-items panel.
     *
     * Sealed Sprite doesn't allow dynamic property assignment, so we declare
     * the slots we need explicitly:
     *   - itemName / sender — used by the hover tooltip
     *   - xReal / yReal     — used by ScrollablePanel for scroll positioning
     */
    public class OfflineItemCell extends Sprite {
        public var apId:int;
        public var itemName:String;
        public var sender:String;
        public var xReal:Number = 0;
        public var yReal:Number = 0;

        public function OfflineItemCell() {
            super();
        }
    }
}
