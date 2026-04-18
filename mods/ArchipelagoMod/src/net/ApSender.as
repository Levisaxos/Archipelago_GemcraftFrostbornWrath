package net {
    import Bezel.Logger;

    /**
     * Builds and sends all outbound Archipelago protocol packets.
     *
     * Pure sender — no connection state, no game logic, no callbacks.
     * ConnectionManager creates this in load() and calls setWebSocket()
     * once the WebSocketClient is ready.
     *
     * Guards: caller is responsible for checking isConnected before calling
     * send methods that require an active session (sendDeathLink, sendGoalComplete,
     * sendConnectUpdate). sendLocationChecks and sendLocationScouts guard
     * themselves because they are called in more varied contexts.
     */
    public class ApSender {

        private var _logger:Logger;
        private var _modName:String;
        private var _ws:WebSocketClient;

        // -----------------------------------------------------------------------

        public function ApSender(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        /** Provide the WebSocketClient once it is created in ConnectionManager.load(). */
        public function setWebSocket(ws:WebSocketClient):void {
            _ws = ws;
        }

        // -----------------------------------------------------------------------
        // Outbound packets

        /** Send the Connect handshake immediately after RoomInfo is received. */
        public function sendConnect(slot:String, password:String):void {
            if (_ws == null) return;
            var packet:String = '[{"cmd":"Connect",' +
                '"game":"GemCraft: Frostborn Wrath",' +
                '"name":"' + slot + '",' +
                '"password":"' + password + '",' +
                '"version":{"major":0,"minor":6,"build":6,"class":"Version"},' +
                '"items_handling":7,' +
                '"tags":[],' +
                '"uuid":"gcfw-mod"}]';
            _logger.log(_modName, "AP >> Connect  slot=" + slot);
            _ws.send(packet);
        }

        /** Send location check IDs to the server. */
        public function sendLocationChecks(locationIds:Array):void {
            if (_ws == null || locationIds.length == 0) return;
            var packet:String = '[{"cmd":"LocationChecks","locations":[' + locationIds.join(",") + ']}]';
            _logger.log(_modName, "AP >> LocationChecks  ids=" + locationIds.join(","));
            _ws.send(packet);
        }

        /**
         * Scout all currently missing locations so we get item names back in LocationInfo.
         * @param missingLocations  Object mapping locationId(int) → true.
         */
        public function sendLocationScouts(missingLocations:Object):void {
            if (_ws == null) return;
            var ids:Array = [];
            for (var locId:String in missingLocations)
                ids.push(int(locId));
            if (ids.length == 0) return;
            var packet:String = '[{"cmd":"LocationScouts","locations":[' + ids.join(",") + '],"create_as_hint":0}]';
            _logger.log(_modName, "AP >> LocationScouts  count=" + ids.length);
            _ws.send(packet);
        }

        /** Send a DeathLink bounce to all DeathLink-tagged players. */
        public function sendDeathLink(source:String):void {
            if (_ws == null) return;
            var packet:String = '[{"cmd":"Bounce","tags":["DeathLink"],"data":{"time":0,"cause":"died","source":"' + source + '"}}]';
            _logger.log(_modName, "AP >> Bounce (DeathLink) source=" + source);
            _ws.send(packet);
        }

        /** Update the tag list on the server (e.g. add/remove "DeathLink" after connect). */
        public function sendConnectUpdate(tags:Array):void {
            if (_ws == null) return;
            var tagJson:String = tags.length == 0 ? "[]" : '["' + tags.join('","') + '"]';
            var packet:String = '[{"cmd":"ConnectUpdate","tags":' + tagJson + '}]';
            _logger.log(_modName, "AP >> ConnectUpdate tags=" + tagJson);
            _ws.send(packet);
        }

        /** Notify the server that the goal has been completed (status 30 = CLIENT_GOAL). */
        public function sendGoalComplete():void {
            if (_ws == null) return;
            var packet:String = '[{"cmd":"StatusUpdate","status":30}]';
            _logger.log(_modName, "AP >> StatusUpdate (Goal complete)");
            _ws.send(packet);
        }

        /** Request the DataPackage for a specific game (lazy, one request per game). */
        public function sendDataPackageRequest(gameName:String):void {
            if (_ws == null || gameName == null || gameName.length == 0) return;
            var safe:String = gameName.split('"').join('\\"');
            var packet:String = '[{"cmd":"GetDataPackage","games":["' + safe + '"]}]';
            _logger.log(_modName, "AP >> GetDataPackage  game=" + gameName);
            _ws.send(packet);
        }
    }
}
