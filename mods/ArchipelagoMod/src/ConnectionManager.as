package {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Manages the Archipelago server connection lifecycle and protocol.
     *
     * Owns the WebSocketClient, connection state, AP packet parsing,
     * token maps, and missing-location tracking.  Fires callbacks to
     * ArchipelagoMod when high-level events occur (connected, items
     * received, state changes).
     */
    public class ConnectionManager {

        private var _logger:Logger;
        private var _modName:String;
        private var _toast:ToastPanel;
        private var _ws:WebSocketClient;

        // Connection state
        private var _isConnected:Boolean  = false;
        private var _reconnecting:Boolean = false;

        // Connection settings
        private var _apHost:String     = "localhost";
        private var _apPort:int        = 38281;
        private var _apSlot:String     = "";
        private var _apPassword:String = "";
        private static const AP_SECURE:Boolean = false;

        // AP slot data
        private var _tokenMap:Object    = {};   // item AP ID (string) → stage str_id
        private var _tokenStages:Object = {};   // stage str_id → true  (has an AP token)
        private var _missingLocations:Object = {};
        private var _mySlot:int         = 0;
        private var _playerNames:Object = {};   // slot (int) → alias (String)

        // Stage str_id → AP location ID (Journey).  Bonus = locId + 500.
        private static const STAGE_LOC_AP_IDS:Object = {
            "W1":1,  "W2":2,  "W3":3,  "W4":4,  "W5":110,
            "S1":5,  "S2":6,  "S3":7,  "S4":8,
            "V1":9,  "V2":10, "V3":11, "V4":12,
            "R1":13, "R2":14, "R3":15, "R4":16, "R5":17, "R6":113,
            "Q1":18, "Q2":19, "Q3":20, "Q4":21, "Q5":22,
            "T1":23, "T2":24, "T3":25, "T4":26, "T5":112,
            "U1":27, "U2":28, "U3":29, "U4":30,
            "Y1":31, "Y2":32, "Y3":33, "Y4":34,
            "X1":35, "X2":36, "X3":37, "X4":38,
            "Z1":39, "Z2":40, "Z3":41, "Z4":42, "Z5":111,
            "O1":43, "O2":44, "O3":45, "O4":46,
            "N1":47, "N2":48, "N3":49, "N4":50, "N5":51,
            "P1":52, "P2":53, "P3":54, "P4":55, "P5":56, "P6":114,
            "L1":57, "L2":58, "L3":59, "L4":60, "L5":61,
            "K1":62, "K2":63, "K3":64, "K4":65, "K5":115,
            "H1":66, "H2":67, "H3":68, "H4":69, "H5":116,
            "G1":70, "G2":71, "G3":72, "G4":73, "G5":117,
            "J1":74, "J2":75, "J3":76, "J4":77,
            "M1":78, "M2":79, "M3":80, "M4":81,
            "F1":82, "F2":83, "F3":84, "F4":85, "F5":118,
            "E1":86, "E2":87, "E3":88, "E4":89, "E5":119,
            "D1":90, "D2":91, "D3":92, "D4":93, "D5":124,
            "B1":94, "B2":95, "B3":96, "B4":97, "B5":120,
            "C1":98, "C2":99, "C3":100,"C4":101,"C5":102,
            "A1":103,"A2":104,"A3":105,"A4":106,"A5":121,"A6":122,
            "I1":123,"I2":107,"I3":108,"I4":109
        };

        // -----------------------------------------------------------------------
        // Callbacks — set by ArchipelagoMod

        /** Called when the AP Connected packet is received. Signature: (packet:Object):void */
        public var onConnected:Function;
        /** Called with the full item list on initial sync (index=0). Signature: (items:Array):void */
        public var onFullSync:Function;
        /** Called for each incremental item grant. Signature: (apId:int):void */
        public var onItemReceived:Function;
        /** Called when connection state changes. Signature: (connected:Boolean):void */
        public var onConnectionStateChanged:Function;
        /** Called when the connection panel should show an error. Signature: (msg:String):void */
        public var onError:Function;
        /** Called when the connection panel should reset. Signature: ():void */
        public var onPanelReset:Function;
        /** Called when a DeathLink bounce is received. Signature: (source:String):void */
        public var onDeathLinkReceived:Function;

        // -----------------------------------------------------------------------

        public function ConnectionManager(logger:Logger, modName:String, toast:ToastPanel) {
            _logger  = logger;
            _modName = modName;
            _toast   = toast;
        }

        public function get isConnected():Boolean { return _isConnected; }
        public function get tokenMap():Object { return _tokenMap; }
        public function get tokenStages():Object { return _tokenStages; }
        public function get missingLocations():Object { return _missingLocations; }

        public function get apHost():String { return _apHost; }
        public function set apHost(v:String):void { _apHost = v; }
        public function get apPort():int { return _apPort; }
        public function set apPort(v:int):void { _apPort = v; }
        public function get apSlot():String { return _apSlot; }
        public function set apSlot(v:String):void { _apSlot = v; }
        public function get apPassword():String { return _apPassword; }
        public function set apPassword(v:String):void { _apPassword = v; }

        // -----------------------------------------------------------------------
        // Lifecycle

        public function load():void {
            _ws = new WebSocketClient(_logger);
            _ws.onOpen    = wsOnOpen;
            _ws.onMessage = onApMessage;
            _ws.onError   = wsOnError;
            _ws.onClose   = wsOnClose;
            _logger.log(_modName, "ConnectionManager loaded — waiting for slot selection");
        }

        public function unload():void {
            if (_ws != null) {
                _ws.disconnect();
                _ws = null;
            }
        }

        // -----------------------------------------------------------------------
        // Connection control

        public function connect(host:String, port:int, slot:String, password:String):void {
            _apHost     = host;
            _apPort     = port;
            _apSlot     = slot;
            _apPassword = password;
            if (_ws != null) {
                _reconnecting = true;
                _ws.disconnect();
                _reconnecting = false;
                _ws.connect(_apHost, _apPort, AP_SECURE);
                _logger.log(_modName, "Connecting to " + _apHost + ":" + _apPort
                    + "  slot=" + _apSlot);
            }
        }

        public function disconnect():void {
            if (_ws != null) _ws.disconnect();
        }

        public function disconnectAndReset():void {
            if (_ws != null) {
                _reconnecting = false;
                _ws.disconnect();
            }
            _isConnected = false;
        }

        /** Reset connection settings to defaults. */
        public function resetSettings():void {
            _apHost     = "localhost";
            _apPort     = 38281;
            _apSlot     = "";
            _apPassword = "";
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
            var failMsg:String = "Failed to connect to " + _apHost + ":" + _apPort
                + " with name " + _apSlot;
            if (onError != null) onError(failMsg);
            _toast.addMessage(failMsg, 0xFFFF6666);
            if (onConnectionStateChanged != null) onConnectionStateChanged(false);
        }

        private function wsOnClose():void {
            _logger.log(_modName, "WS onClose — _isConnected: " + _isConnected + " → false  _reconnecting=" + _reconnecting);
            _isConnected = false;
            if (!_reconnecting && onPanelReset != null) onPanelReset();
            if (!_reconnecting) _toast.addMessage("AP disconnected", 0xFFFFAA44);
            if (onConnectionStateChanged != null) onConnectionStateChanged(false);
        }

        // -----------------------------------------------------------------------
        // AP protocol

        private function onApMessage(text:String):void {
            try {
                var packets:Array = JSON.parse(text) as Array;
                for each (var packet:Object in packets) {
                    handlePacket(packet);
                }
            } catch (e:Error) {
                _logger.log(_modName, "Failed to parse AP message: " + e.message);
                _toast.addMessage("AP parse error: " + e.message, 0xFFFF6666);
            }
        }

        private function handlePacket(p:Object):void {
            var cmd:String = p.cmd;
            _logger.log(_modName, "AP << " + cmd);

            switch (cmd) {
                case "RoomInfo":
                    _logger.log(_modName, "  seed=" + p.seed_name + "  server=" +
                        p.version.major + "." + p.version.minor + "." + p.version.build);
                    sendConnect();
                    break;

                case "Connected":
                    handleConnected(p);
                    break;

                case "ReceivedItems":
                    handleReceivedItems(p);
                    break;

                case "ConnectionRefused":
                    var errors:Array = p.errors as Array;
                    var errMsg:String = errors && errors.length > 0 ? errors.join(", ") : "unknown reason";
                    _logger.log(_modName, "  ConnectionRefused: " + errMsg);
                    _isConnected = false;
                    if (onPanelReset != null) onPanelReset();
                    if (onError != null) onError("Refused: " + errMsg);
                    _toast.addMessage("AP refused: " + errMsg, 0xFFFF6666);
                    break;

                case "PrintJSON":
                    handlePrintJSON(p);
                    break;

                case "Bounced":
                    handleBounced(p);
                    break;

                default:
                    _logger.log(_modName, "  (unhandled)");
            }
        }

        private function handleConnected(p:Object):void {
            _isConnected = true;
            _mySlot = int(p.slot);
            _logger.log(_modName, "  team=" + p.team + "  slot=" + p.slot);

            _playerNames = {};
            var players:Array = p.players as Array;
            if (players) {
                for each (var player:Object in players) {
                    _playerNames[int(player.slot)] = String(player.alias);
                    _logger.log(_modName, "  player: slot=" + player.slot +
                        "  name=" + player.alias + "  game=" + player.game);
                }
            }

            if (p.slot_data && p.slot_data.token_map) {
                _tokenMap = p.slot_data.token_map;
                _tokenStages = {};
                var tokenCount:int = 0;
                for (var apIdStr:String in _tokenMap) {
                    _tokenStages[_tokenMap[apIdStr]] = true;
                    tokenCount++;
                }
                _logger.log(_modName, "  token_map loaded: " + tokenCount + " entries");
            }
            _logger.log(_modName, "  goal=" + p.slot_data.goal + "  skill_placement=" + p.slot_data.skill_placement);

            var missing:Array  = p.missing_locations as Array;
            var checked:Array  = p.checked_locations as Array;
            _logger.log(_modName, "  missing_locations=" + (missing ? missing.length : "?") +
                "  checked_locations=" + (checked ? checked.length : "?"));

            _missingLocations = {};
            if (missing != null) {
                for each (var locId:int in missing) {
                    _missingLocations[locId] = true;
                }
            }

            _toast.addMessage("Successfully connected to " + _apHost + ":" + _apPort
                + " with name " + _apSlot, 0xFF88FF88);

            if (onConnected != null) onConnected(p);
        }

        private function handleReceivedItems(p:Object):void {
            var index:int   = p.index;
            var items:Array = p.items as Array;
            _logger.log(_modName, "ReceivedItems index=" + index + " count=" + items.length);

            if (index == 0) {
                if (onFullSync != null) onFullSync(items);
            } else {
                for each (var networkItem:Object in items) {
                    var apId:int = networkItem.item;
                    _logger.log(_modName, "  + item=" + apId + " (" + itemName(apId) + ")");
                    if (onItemReceived != null) onItemReceived(apId);
                }
            }
        }

        private function handleBounced(p:Object):void {
            var tags:Array = p.tags as Array;
            if (tags == null || tags.indexOf("DeathLink") < 0) return;
            var source:String = (p.data && p.data.source) ? String(p.data.source) : "unknown";
            _logger.log(_modName, "DeathLink received from " + source);
            if (onDeathLinkReceived != null) onDeathLinkReceived(source);
        }

        private function handlePrintJSON(p:Object):void {
            if (p.type != "ItemSend") return;
            var receiving:int  = int(p.receiving);
            var senderSlot:int = int(p.item.player);
            var name:String    = itemName(int(p.item.item));

            if (receiving == _mySlot && senderSlot != _mySlot) {
                var sender:String = _playerNames[senderSlot] || ("Player " + senderSlot);
                _logger.log(_modName, "  ItemSend: received " + name + " from " + sender);
                _toast.addMessage("Received " + name + " from " + sender, 0xFF88DDFF);
            } else if (receiving == _mySlot && senderSlot == _mySlot) {
                _logger.log(_modName, "  ItemSend: found " + name);
                _toast.addMessage("Found " + name, 0xFF88DDFF);
            } else if (senderSlot == _mySlot) {
                var receiver:String = _playerNames[receiving] || ("Player " + receiving);
                _logger.log(_modName, "  ItemSend: sent " + name + " to " + receiver);
                _toast.addMessage("Sent " + name + " to " + receiver, 0xFFDDFF88);
            }
        }

        private function sendConnect():void {
            var packet:String = '[{"cmd":"Connect",' +
                '"game":"GemCraft: Frostborn Wrath",' +
                '"name":"' + _apSlot + '",' +
                '"password":"' + _apPassword + '",' +
                '"version":{"major":0,"minor":6,"build":6,"class":"Version"},' +
                '"items_handling":7,' +
                '"tags":[],' +
                '"uuid":"gcfw-mod"}]';
            _logger.log(_modName, "AP >> Connect  slot=" + _apSlot);
            _ws.send(packet);
        }

        // -----------------------------------------------------------------------
        // Location checks

        public function sendLocationChecks(locationIds:Array):void {
            if (_ws == null || locationIds.length == 0) return;
            var packet:String = '[{"cmd":"LocationChecks","locations":[' + locationIds.join(",") + ']}]';
            _logger.log(_modName, "AP >> LocationChecks  ids=" + locationIds.join(","));
            _ws.send(packet);
        }

        /** Send a DeathLink bounce to all DeathLink-tagged players. */
        public function sendDeathLink(source:String):void {
            if (_ws == null || !_isConnected) return;
            var packet:String = '[{"cmd":"Bounce","tags":["DeathLink"],"data":{"time":0,"cause":"died","source":"' + source + '"}}]';
            _logger.log(_modName, "AP >> Bounce (DeathLink) source=" + source);
            _ws.send(packet);
        }

        /**
         * Update our tag list on the server (e.g. add/remove DeathLink after connect).
         * @param tags  Array of tag strings, e.g. ["DeathLink"] or [].
         */
        public function sendConnectUpdate(tags:Array):void {
            if (_ws == null || !_isConnected) return;
            var tagJson:String = '["' + tags.join('","') + '"]';
            if (tags.length == 0) tagJson = "[]";
            var packet:String = '[{"cmd":"ConnectUpdate","tags":' + tagJson + '}]';
            _logger.log(_modName, "AP >> ConnectUpdate tags=" + tagJson);
            _ws.send(packet);
        }

        /** Send the goal-complete status to the AP server (status 30 = CLIENT_GOAL). */
        public function sendGoalComplete():void {
            if (_ws == null || !_isConnected) return;
            var packet:String = '[{"cmd":"StatusUpdate","status":30}]';
            _logger.log(_modName, "AP >> StatusUpdate (Goal complete)");
            _ws.send(packet);
        }

        /**
         * Scan completed stages and send any unchecked locations to the server.
         * Called after battle victories.
         */
        public function checkCompletedLocations():void {
            if (!_isConnected) return;
            try {
                var hasController:Boolean = GV.ingameController != null;
                var hasCore:Boolean = hasController && GV.ingameController.core != null;
                _logger.log(_modName, "  ingameController=" + hasController + "  core=" + hasCore);
                if (!hasController || !hasCore) return;

                var ending:* = GV.ingameController.core.ending;
                _logger.log(_modName, "  ending=" + ending
                    + "  isBattleWon=" + (ending != null ? ending.isBattleWon : "n/a"));
                if (ending == null || !ending.isBattleWon) return;

                var hasPpd:Boolean   = GV.ppd != null;
                var hasMetas:Boolean = GV.stageCollection != null && GV.stageCollection.stageMetas != null;
                _logger.log(_modName, "  ppd=" + hasPpd + "  stageMetas=" + hasMetas);
                if (!hasPpd || !hasMetas) return;

                var metas:Array = GV.stageCollection.stageMetas;
                _logger.log(_modName, "  metas.length=" + metas.length);

                var toSend:Array = [];
                for (var i:int = 0; i < metas.length; i++) {
                    var meta:* = metas[i];
                    if (meta == null) continue;
                    var xp:int = GV.ppd.stageHighestXpsJourney[meta.id].g();
                    if (xp <= 0) continue;
                    var locId:int = int(STAGE_LOC_AP_IDS[meta.strId]);
                    var journeyNew:Boolean = _missingLocations[locId] == true;
                    var bonusNew:Boolean   = _missingLocations[locId + 500] == true;
                    _logger.log(_modName, "PLAYER_COMPLETED_STAGE stage=" + meta.strId
                        + "  xp=" + xp + "  locId=" + locId
                        + "  journeyNew=" + journeyNew + "  bonusNew=" + bonusNew);
                    if (locId <= 0) continue;
                    if (journeyNew) toSend.push(locId);
                    if (bonusNew)   toSend.push(locId + 500);
                }
                _logger.log(_modName, "  toSend=" + toSend.join(",") + "  (" + toSend.length + " new checks)");
                if (toSend.length > 0) {
                    for each (var sentId:int in toSend) {
                        delete _missingLocations[sentId];
                    }
                    sendLocationChecks(toSend);
                }
            } catch (err:Error) {
                _logger.log(_modName, "checkCompletedLocations ERROR: " + err.message + "\n" + err.getStackTrace());
            }
        }

        // -----------------------------------------------------------------------
        // Helpers

        /**
         * Resolve a human-readable name for an AP item ID.
         * If an external resolver was set, tries it first.
         */
        public function itemName(apId:int):String {
            if (_itemNameResolver != null) {
                var name:String = _itemNameResolver(apId);
                if (name != null) return name;
            }
            if (apId >= 1   && apId <= 199) return "Field Token (id=" + apId + ")";
            if (apId == 500) return "Tattered Scroll";
            if (apId == 501) return "Worn Tome";
            if (apId == 502) return "Ancient Grimoire";
            return "Item #" + apId;
        }

        /** Set an external name resolver. Signature: (apId:int):String — return null if unknown. */
        public function setItemNameResolver(resolver:Function):void {
            _itemNameResolver = resolver;
        }

        private var _itemNameResolver:Function;
    }
}
