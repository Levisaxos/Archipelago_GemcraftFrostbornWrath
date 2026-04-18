package net {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import data.AV;
    import ui.SystemToast;
    import ui.ReceivedToast;
    import ui.MessageLog;

    /**
     * Manages the Archipelago server connection lifecycle.
     *
     * Owns the WebSocketClient, connection state, and credentials.
     * Delegates outbound packets to ApSender and inbound packet handling to ApReceiver.
     * Proxies the public getter / send API that ArchipelagoMod and other callers
     * already depend on.
     *
     * Guards: sendDeathLink, sendConnectUpdate, sendGoalComplete, and
     * checkCompletedLocations all require isConnected; callers need not check first.
     */
    public class ConnectionManager {

        private var _logger:Logger;
        private var _modName:String;
        private var _toast:SystemToast;
        private var _webSocketClient:WebSocketClient;
        private var _sender:ApSender;
        private var _receiver:ApReceiver;

        // Connection state
        private var _isConnected:Boolean  = false;
        private var _isConnecting:Boolean = false;
        private var _reconnecting:Boolean = false;

        // Connection settings
        private var _archipelagoHost:String     = "localhost";
        private var _archipelagoPort:int        = 38281;
        private var _archipelagoSlot:String     = "Levisaxos";
        private var _archipelagoPassword:String = "";
        private var _saveSlot:int               = 0;

        private static function isSecureHost(host:String):Boolean {
            return host.toLowerCase() == "archipelago.gg";
        }

        // Stage str_id → AP location ID (Journey).  Bonus = locId + 199.  Stash = locId + 399.
        private static const STAGE_LOC_AP_IDS:Object = {
            "W1":1,  "W2":2,  "W3":3,  "W4":4,
            "S1":5,  "S2":6,  "S3":7,  "S4":8,
            "V1":9,  "V2":10, "V3":11, "V4":12,
            "R1":13, "R2":14, "R3":15, "R4":16, "R5":17, "R6":112,
            "Q1":18, "Q2":19, "Q3":20, "Q4":21, "Q5":22,
            "T1":23, "T2":24, "T3":25, "T4":26, "T5":111,
            "U1":27, "U2":28, "U3":29, "U4":30,
            "Y1":31, "Y2":32, "Y3":33, "Y4":34,
            "X1":35, "X2":36, "X3":37, "X4":38,
            "Z1":39, "Z2":40, "Z3":41, "Z4":42, "Z5":110,
            "O1":43, "O2":44, "O3":45, "O4":46,
            "N1":47, "N2":48, "N3":49, "N4":50, "N5":51,
            "P1":52, "P2":53, "P3":54, "P4":55, "P5":56, "P6":113,
            "L1":57, "L2":58, "L3":59, "L4":60, "L5":61,
            "K1":62, "K2":63, "K3":64, "K4":65, "K5":114,
            "H1":66, "H2":67, "H3":68, "H4":69, "H5":115,
            "G1":70, "G2":71, "G3":72, "G4":73,
            "J1":74, "J2":75, "J3":76, "J4":77,
            "M1":78, "M2":79, "M3":80, "M4":81,
            "F1":82, "F2":83, "F3":84, "F4":85, "F5":116,
            "E1":86, "E2":87, "E3":88, "E4":89, "E5":117,
            "D1":90, "D2":91, "D3":92, "D4":93, "D5":122,
            "B1":94, "B2":95, "B3":96, "B4":97, "B5":118,
            "C1":98, "C2":99, "C3":100,"C4":101,"C5":102,
            "A1":103,"A2":104,"A3":105,"A4":106,"A5":119,"A6":120,
            "I1":121,"I2":107,"I3":108,"I4":109
        };

        /** Public read-only view of the stage → base Journey AP location id map. */
        public static function get stageLocIds():Object { return STAGE_LOC_AP_IDS; }

        // Populated by checkCompletedLocations(); read by LevelEndScreenBuilder.
        private var _lastCheckedLocations:Array = [];

        public function get lastCheckedLocations():Array { return _lastCheckedLocations; }

        /** Server data convenience getter. */
        public function get serverData():Object { return AV.serverData; }

        // -----------------------------------------------------------------------
        // Callbacks — set by ArchipelagoMod

        /** Called when the AP Connected packet is received. Signature: (packet:Object):void */
        public var onConnected:Function;
        /** Called with the full item list on initial sync (index=0). Signature: (items:Array):void */
        public var onFullSync:Function;
        /** Called for each incremental item grant. Signature: (apId:int):void */
        public var onItemReceived:Function;
        /** Called when the connection panel should show an error. Signature: (msg:String):void */
        public var onError:Function;
        /** Called when the connection panel should reset. Signature: ():void */
        public var onPanelReset:Function;
        /** Called when a DeathLink bounce is received. Signature: (source:String):void */
        public var onDeathLinkReceived:Function;
        /** Called when we send an item from a location. Signature: (locId:int, itemName:String, receivingName:String):void */
        public var onItemSentFromLocation:Function;
        /** Called when the connection drops unexpectedly. Signature: ():void */
        public var onUnexpectedDisconnect:Function;

        // -----------------------------------------------------------------------

        public function ConnectionManager(logger:Logger, modName:String, toast:SystemToast) {
            _logger  = logger;
            _modName = modName;
            _toast   = toast;

            _sender   = new ApSender(logger, modName);
            _receiver = new ApReceiver(logger, modName, _sender, toast);

            // Wire receiver callbacks up to CM-level callbacks
            _receiver.onConnectionEstablished = _onConnectionEstablished;
            _receiver.onFullSync = function(items:Array):void {
                if (onFullSync != null) onFullSync(items);
            };
            _receiver.onItemReceived = function(apId:int):void {
                if (onItemReceived != null) onItemReceived(apId);
            };
            _receiver.onDeathLinkReceived = function(src:String):void {
                if (onDeathLinkReceived != null) onDeathLinkReceived(src);
            };
            _receiver.onItemSentFromLocation = function(loc:int, name:String, recv:String):void {
                if (onItemSentFromLocation != null) onItemSentFromLocation(loc, name, recv);
            };
        }

        private function _onConnectionEstablished(p:Object):void {
            _isConnected = true;
            _toast.addMessage("Connected to " + _archipelagoHost + ":" + _archipelagoPort
                + " as " + _archipelagoSlot + " (Slot " + _saveSlot + ")", 0xFF88FF88);
            if (onConnected != null) onConnected(p);
        }

        // -----------------------------------------------------------------------
        // Proxy getters — backed by receiver

        public function get isConnected():Boolean          { return _isConnected; }
        public function get tokenMap():Object              { return _receiver.tokenMap; }
        public function get tokenStages():Object           { return _receiver.tokenStages; }
        public function get talismanMap():Object           { return _receiver.talismanMap; }
        public function get talismanNameMap():Object       { return _receiver.talismanNameMap; }
        public function get shadowCoreMap():Object         { return _receiver.shadowCoreMap; }
        public function get shadowCoreNameMap():Object     { return _receiver.shadowCoreNameMap; }
        public function get wizStashTalData():Object       { return _receiver.wizStashTalData; }
        public function get missingLocations():Object      { return _receiver.missingLocations; }
        public function get itemsSentThisLevel():Object    { return _receiver.itemsSentThisLevel; }

        // -----------------------------------------------------------------------
        // Credentials

        public function get apHost():String       { return _archipelagoHost; }
        public function set apHost(v:String):void  { _archipelagoHost = v; }
        public function get apPort():int          { return _archipelagoPort; }
        public function set apPort(v:int):void    { _archipelagoPort = v; }
        public function get apSlot():String       { return _archipelagoSlot; }
        public function set apSlot(v:String):void  { _archipelagoSlot = v; }
        public function get apPassword():String   { return _archipelagoPassword; }
        public function set apPassword(v:String):void { _archipelagoPassword = v; }
        public function get saveSlot():int        { return _saveSlot; }
        public function set saveSlot(v:int):void  { _saveSlot = v; }

        // -----------------------------------------------------------------------
        // Panel plumbing — forwarded to receiver

        /** Provide the panel used for received-item toasts. */
        public function setReceivedToast(panel:ReceivedToast):void { _receiver.setReceivedToast(panel); }

        /** Provide the message log so item send/receive events are recorded. */
        public function setMessageLog(log:MessageLog):void { _receiver.setMessageLog(log); }

        // -----------------------------------------------------------------------
        // Lifecycle

        public function load():void {
            _webSocketClient = new WebSocketClient(_logger);
            _webSocketClient.onOpen    = wsOnOpen;
            _webSocketClient.onMessage = onApMessage;
            _webSocketClient.onError   = wsOnError;
            _webSocketClient.onClose   = wsOnClose;
            _sender.setWebSocket(_webSocketClient);
            _logger.log(_modName, "ConnectionManager loaded — waiting for slot selection");
        }

        public function unload():void {
            if (_webSocketClient != null) {
                _webSocketClient.disconnect();
                _webSocketClient = null;
                _sender.setWebSocket(null);
            }
        }

        // -----------------------------------------------------------------------
        // Connection control

        public function connect(host:String, port:int, slot:String, password:String):void {
            _archipelagoHost     = host;
            _archipelagoPort     = port;
            _archipelagoSlot     = slot;
            _archipelagoPassword = password;
            if (_webSocketClient != null && _isConnecting == false) {
                _isConnecting = true;
                _reconnecting = true;
                _webSocketClient.disconnect();
                _reconnecting = false;
                _toast.addMessage("Connecting to " + host + ":" + port
                    + " as " + slot + " (Slot " + _saveSlot + ")...", 0xFFFFDD55);
                _webSocketClient.connect(host, port, isSecureHost(host));
                _logger.log(_modName, "Connecting to " + host + ":" + port + "  slot=" + slot);
            }
        }

        public function disconnect():void {
            if (_webSocketClient != null) _webSocketClient.disconnect();
        }

        public function disconnectAndReset():void {
            if (_webSocketClient != null) {
                _reconnecting = false;
                _webSocketClient.disconnect();
            }
            _isConnected = false;
        }

        /** Reset connection settings to defaults. */
        public function resetSettings():void {
            _archipelagoHost     = "localhost";
            _archipelagoPort     = 38281;
            _archipelagoSlot     = "Levisaxos";
            _archipelagoPassword = "";
        }

        public function failConnection():void {
            _isConnecting = false;
        }

        // -----------------------------------------------------------------------
        // WebSocket callbacks

        private function wsOnOpen():void {
            _logger.log(_modName, "WS onOpen — TCP+WS handshake done, waiting for AP Connected packet");
            if (onError != null) onError("Authenticating...");
        }

        private function wsOnError(msg:String):void {
            _logger.log(_modName, "WS onError — _isConnected: " + _isConnected + " → false  msg=" + msg);
            _isConnected = false;
            if (onPanelReset != null) onPanelReset();
            var failMsg:String = "Failed to connect to " + _archipelagoHost + ":" + _archipelagoPort
                + " with name " + _archipelagoSlot;
            if (onError != null) onError(failMsg);
            _toast.addMessage(failMsg, 0xFFFF6666);
        }

        private function wsOnClose():void {
            var wasConnected:Boolean = _isConnected;
            _logger.log(_modName, "WS onClose — _isConnected: " + _isConnected + " → false  _reconnecting=" + _reconnecting);
            _isConnected = false;
            if (!_reconnecting && onPanelReset != null) onPanelReset();
            if (!_reconnecting && wasConnected) {
                _toast.addMessage("AP disconnected", 0xFFFFAA44);
                if (onUnexpectedDisconnect != null) onUnexpectedDisconnect();
            }
        }

        // -----------------------------------------------------------------------
        // AP protocol dispatch

        private function onApMessage(text:String):void {
            try {
                var packets:Array = JSON.parse(text) as Array;
                for each (var packet:Object in packets)
                    _dispatchPacket(packet);
            } catch (e:Error) {
                _logger.log(_modName, "Failed to parse AP message: " + e.message);
                _toast.addMessage("AP parse error: " + e.message, 0xFFFF6666);
            }
        }

        private function _dispatchPacket(p:Object):void {
            var cmd:String = p.cmd;
            _logger.log(_modName, "AP << " + cmd);

            switch (cmd) {
                case "RoomInfo":
                    _logger.log(_modName, "  seed=" + p.seed_name + "  server=" +
                        p.version.major + "." + p.version.minor + "." + p.version.build);
                    _sender.sendConnect(_archipelagoSlot, _archipelagoPassword);
                    break;

                case "Connected":
                    _receiver.handleConnected(p);
                    break;

                case "ConnectionRefused":
                    var errors:Array  = p.errors as Array;
                    var errMsg:String = errors && errors.length > 0 ? errors.join(", ") : "unknown reason";
                    _logger.log(_modName, "  ConnectionRefused: " + errMsg);
                    _isConnected = false;
                    if (onPanelReset != null) onPanelReset();
                    if (onError != null) onError("Refused: " + errMsg);
                    _toast.addMessage("AP refused: " + errMsg, 0xFFFF6666);
                    break;

                case "ReceivedItems":
                    _receiver.handleReceivedItems(p);
                    break;

                case "PrintJSON":
                    _receiver.handlePrintJSON(p);
                    break;

                case "DataPackage":
                    _receiver.handleDataPackage(p);
                    break;

                case "LocationInfo":
                    _receiver.handleLocationInfo(p);
                    break;

                case "Bounced":
                    _receiver.handleBounced(p);
                    break;

                default:
                    _logger.log(_modName, "  (unhandled)");
            }
        }

        // -----------------------------------------------------------------------
        // Public send API — proxy to sender (isConnected guards applied here)

        /** Send location check IDs to the server. */
        public function sendLocationChecks(locationIds:Array):void {
            _sender.sendLocationChecks(locationIds);
        }

        /** Send a DeathLink bounce to all DeathLink-tagged players. */
        public function sendDeathLink(source:String):void {
            if (!_isConnected) return;
            _sender.sendDeathLink(source);
        }

        /**
         * Update our tag list on the server (e.g. add/remove DeathLink after connect).
         * @param tags  Array of tag strings, e.g. ["DeathLink"] or [].
         */
        public function sendConnectUpdate(tags:Array):void {
            if (!_isConnected) return;
            _sender.sendConnectUpdate(tags);
        }

        /** Send the goal-complete status to the AP server (status 30 = CLIENT_GOAL). */
        public function sendGoalComplete():void {
            if (!_isConnected) return;
            _sender.sendGoalComplete();
        }

        // -----------------------------------------------------------------------
        // Location checking — coordinates receiver state and sender

        /**
         * Scan completed stages and send any unchecked locations to the server.
         * Called after battle victories.
         */
        public function checkCompletedLocations():void {
            if (!_isConnected) return;
            try {
                var hasController:Boolean = GV.ingameController != null;
                var hasCore:Boolean = hasController && GV.ingameController.core != null;
                if (!hasController || !hasCore) return;

                var ending:* = GV.ingameController.core.ending;
                if (ending == null || !ending.isBattleWon) return;

                var hasPpd:Boolean   = GV.ppd != null;
                var hasMetas:Boolean = GV.stageCollection != null && GV.stageCollection.stageMetas != null;
                if (!hasPpd || !hasMetas) return;

                var metas:Array = GV.stageCollection.stageMetas;

                var toSend:Array = [];
                _lastCheckedLocations = [];
                // Clear stage-location data but preserve achievement entries (2000-2636)
                // so that hover lookups on achievement icons still work after this call.
                _receiver.resetItemsSentThisLevel(true);

                var missing:Object = _receiver.missingLocations;

                for (var i:int = 0; i < metas.length; i++) {
                    var meta:* = metas[i];
                    if (meta == null) continue;
                    var xp:int = GV.ppd.stageHighestXpsJourney[meta.id].g();
                    if (xp <= 0) continue;
                    var locId:int        = int(STAGE_LOC_AP_IDS[meta.strId]);
                    var bonusLocId:int   = locId + 199;
                    var wizStashLocId:int = locId + 399;
                    var journeyNew:Boolean = missing[locId] == true;
                    var bonusNew:Boolean   = missing[bonusLocId] == true;
                    _logger.log(_modName, "PLAYER_COMPLETED_STAGE stage=" + meta.strId
                        + "  xp=" + xp + "  locId=" + locId
                        + "  bonusLocId=" + bonusLocId + "  wizStashLocId=" + wizStashLocId
                        + "  journeyNew=" + journeyNew + "  bonusNew=" + bonusNew
                        + "  stashNew=" + (missing[wizStashLocId] == true));
                    if (locId <= 0) continue;
                    if (journeyNew) {
                        toSend.push(locId);
                        _lastCheckedLocations.push({strId: meta.strId, locType: "journey"});
                        _logger.log(_modName, "Pending: " + meta.strId + " (field journey)  locId=" + locId);
                    }
                    if (bonusNew) {
                        toSend.push(bonusLocId);
                        _lastCheckedLocations.push({strId: meta.strId, locType: "bonus"});
                        _logger.log(_modName, "Pending: " + meta.strId + " (field bonus)  locId=" + bonusLocId);
                    }
                    if (missing[wizStashLocId] == true) {
                        var stashStatus:int = int(GV.ppd.stageWizStashStauses[meta.id]);
                        if (stashStatus == 1 || stashStatus == 2) {
                            toSend.push(wizStashLocId);
                            _lastCheckedLocations.push({strId: meta.strId, locType: "stash"});
                            _logger.log(_modName, "Pending: " + meta.strId + " (field stash)  locId=" + wizStashLocId);
                        }
                    }
                }

                _logger.log(_modName, "  toSend=" + toSend.join(",") + "  (" + toSend.length + " new checks)");
                if (toSend.length > 0) {
                    for each (var sentId:int in toSend)
                        delete missing[sentId];
                    _sender.sendLocationChecks(toSend);
                }
            } catch (err:Error) {
                _logger.log(_modName, "checkCompletedLocations ERROR: " + err.message + "\n" + err.getStackTrace());
            }
        }
    }
}
