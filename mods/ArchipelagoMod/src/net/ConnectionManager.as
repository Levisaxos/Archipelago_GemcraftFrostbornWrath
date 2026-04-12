package net {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import ui.ToastPanel;
    import ui.ItemToastPanel;
    import ui.MessageLog;

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
        private var _itemToast:ItemToastPanel;
        private var _messageLog:MessageLog;
        private var _ws:WebSocketClient;

        // Connection state
        private var _isConnected:Boolean  = false;
        private var _isConnecting:Boolean = false;
        private var _reconnecting:Boolean = false;

        // Connection settings
        private var _apHost:String     = "archipelago.gg";
        private var _apPort:int        = 38281;
        private var _apSlot:String     = "";
        private var _apPassword:String = "";
        private var _saveSlot:int      = 0;
        // TLS is used only for archipelago.gg; local/IP servers use plain ws://
        private static function isSecureHost(host:String):Boolean {
            return host.toLowerCase() == "archipelago.gg";
        }

        // AP slot data
        private var _tokenMap:Object    = {};   // item AP ID (string) → stage str_id
        private var _tokenStages:Object = {};   // stage str_id → true  (has an AP token)
        private var _talismanMap:Object = {};     // item AP ID (string) → "seed/rarity/type/upgradeLevel"
        private var _talismanNameMap:Object = {}; // item AP ID (string) → str_id (e.g. "Z3")
        private var _shadowCoreMap:Object = {};     // item AP ID (string) → amount (int)
        private var _shadowCoreNameMap:Object = {}; // item AP ID (string) → str_id (e.g. "Z2")
        private var _wizStashTalData:Object = {};   // str_id → "seed/rarity/type/upgradeLevel"
        private var _missingLocations:Object = {};
        private var _mySlot:int         = 0;
        private var _playerNames:Object = {};   // slot (int) → alias (String)
        private var _playerGames:Object = {};   // slot (int) → game name (String)
        private var _itemIdToNameByGame:Object = {}; // gameName → { itemIdStr → itemName }
        private var _resolvedItemNames:Object  = {}; // itemId (String) → resolved name (String) — persistent cache
        private var _goal:int           = 0;    // 0 = beat_game, 2 = kill_swarm_queen, 3 = fields_count, 4 = fields_percentage
        private var _fieldsRequired:int           = 80;
        private var _fieldsRequiredPercentage:int = 66;
        private var _talismanMinRarity:int = 1;
        private var _achievementGrindiness:int = 1;  // 0=off, 1=Trivial, 2=Minor, 3=Major, 4=Extreme
        private var _tatteredScrollLevels:int  = 1;
        private var _wornTomeLevels:int        = 2;
        private var _ancientGrimoireLevels:int = 3;
        private var _freeStages:Array          = null;
        private var _fieldTokenPlacement:int   = 1;  // 0=own_world, 1=any_world, 2=different_world
        private var _tierRequirements:int      = 75; // percent
        private var _enforceLogic:Boolean      = false;
        private var _disableEndurance:Boolean  = false;
        private var _disableTrial:Boolean      = true;
        private var _startingWizardLevel:int   = 1;
        private var _startingOvercrowd:Boolean = false;
        private var _enemyHpMultiplier:int          = 100;
        private var _enemyArmorMultiplier:int       = 100;
        private var _enemyShieldMultiplier:int      = 100;
        private var _enemiesPerWaveMultiplier:int   = 100;
        private var _extraWaveCount:int             = 0;

        // Stage str_id → AP location ID (Journey).  Bonus = locId + 500.
        private static const STAGE_LOC_AP_IDS:Object = {
            "W1":1,  "W2":2,  "W3":3,  "W4":4,
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
            "G1":70, "G2":71, "G3":72, "G4":73,
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

        /** Public read-only view of the stage -> base-Journey AP location id map. */
        public static function get stageLocIds():Object { return STAGE_LOC_AP_IDS; }

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
        /** Called for each PrintJSON ItemSend event involving us. Signature: (msg:String, color:uint):void */
        public var onItemSend:Function;
        /** Called when the connection drops unexpectedly (was connected, not a deliberate disconnect). Signature: ():void */
        public var onUnexpectedDisconnect:Function;

        // -----------------------------------------------------------------------

        public function ConnectionManager(logger:Logger, modName:String, toast:ToastPanel) {
            _logger  = logger;
            _modName = modName;
            _toast   = toast;
        }

        public function get isConnected():Boolean { return _isConnected; }
        public function get tokenMap():Object { return _tokenMap; }
        public function get tokenStages():Object { return _tokenStages; }
        public function get talismanMap():Object { return _talismanMap; }
        public function get talismanNameMap():Object { return _talismanNameMap; }
        public function get shadowCoreMap():Object { return _shadowCoreMap; }
        public function get shadowCoreNameMap():Object { return _shadowCoreNameMap; }
        public function get wizStashTalData():Object { return _wizStashTalData; }
        public function get missingLocations():Object { return _missingLocations; }
        public function get goal():int { return _goal; }
        public function get talismanMinRarity():int { return _talismanMinRarity; }
        public function get achievementGrindiness():int { return _achievementGrindiness; }
        public function get tatteredScrollLevels():int  { return _tatteredScrollLevels; }
        public function get wornTomeLevels():int        { return _wornTomeLevels; }
        public function get ancientGrimoireLevels():int { return _ancientGrimoireLevels; }
        public function get freeStages():Array          { return _freeStages; }
        public function get fieldTokenPlacement():int  { return _fieldTokenPlacement; }
        public function get tierRequirements():int     { return _tierRequirements; }
        public function get enforceLogic():Boolean      { return _enforceLogic; }
        public function get disableEndurance():Boolean  { return _disableEndurance; }
        public function get disableTrial():Boolean      { return _disableTrial; }
        public function get startingWizardLevel():int   { return _startingWizardLevel; }
        public function get startingOvercrowd():Boolean { return _startingOvercrowd; }
        public function get enemyHpMultiplier():int          { return _enemyHpMultiplier; }
        public function get enemyArmorMultiplier():int       { return _enemyArmorMultiplier; }
        public function get enemyShieldMultiplier():int      { return _enemyShieldMultiplier; }
        public function get enemiesPerWaveMultiplier():int   { return _enemiesPerWaveMultiplier; }
        public function get extraWaveCount():int             { return _extraWaveCount; }
        public function get fieldsRequired():int             { return _fieldsRequired; }
        public function get fieldsRequiredPercentage():int   { return _fieldsRequiredPercentage; }

        public function get apHost():String { return _apHost; }
        public function set apHost(v:String):void { _apHost = v; }
        public function get apPort():int { return _apPort; }
        public function set apPort(v:int):void { _apPort = v; }
        public function get apSlot():String { return _apSlot; }
        public function set apSlot(v:String):void { _apSlot = v; }
        public function get apPassword():String { return _apPassword; }
        public function set apPassword(v:String):void { _apPassword = v; }
        public function get saveSlot():int { return _saveSlot; }
        public function set saveSlot(v:int):void { _saveSlot = v; }

        /** Provide the item-notification panel used for received/found/sent item toasts. */
        public function setItemToast(panel:ItemToastPanel):void { _itemToast = panel; }

        /** Provide the message log so item send/receive events are recorded. */
        public function setMessageLog(log:MessageLog):void { _messageLog = log; }

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
            if (_ws != null && _isConnecting == false) {
                _isConnecting = true;
                _reconnecting = true;
                _ws.disconnect();
                _reconnecting = false;
                _toast.addMessage("Connecting to " + _apHost + ":" + _apPort + " as " + _apSlot + " (Slot " + _saveSlot + ")...", 0xFFFFDD55);
                _ws.connect(_apHost, _apPort, isSecureHost(_apHost));
                _logger.log(_modName, "Connecting to " + _apHost + ":" + _apPort + "  slot=" + _apSlot);
            }
        }

        public function disconnect():void {
            if (_ws != null) {
                _ws.disconnect();                
            }
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
            _apHost     = "archipelago.gg";
            _apPort     = 38281;
            _apSlot     = "";
            _apPassword = "";
        }

        public function failConnection():void {
            _isConnecting=false;
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

                case "DataPackage":
                    handleDataPackage(p);
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
            _playerGames = {};

            // Extract player names from players array
            var players:Array = p.players as Array;
            if (players) {
                for each (var player:Object in players) {
                    _playerNames[int(player.slot)] = String(player.alias);
                    _logger.log(_modName, "  player: slot=" + player.slot + "  name=" + player.alias);
                }
            }

            // Extract game names from slot_info (Archipelago standard)
            // This is where the server sends which game each slot is playing
            var slotInfo:Object = p.slot_info;
            var foundGames:int = 0;
            if (slotInfo) {
                _logger.log(_modName, "  Extracting game names from slot_info...");
                for (var slotStr:String in slotInfo) {
                    var slot:int = int(slotStr);
                    var info:Object = slotInfo[slotStr];
                    if (info && info.game != null) {
                        var gameName:String = String(info.game);
                        _playerGames[slot] = gameName;
                        foundGames++;
                        _logger.log(_modName, "    slot " + slot + " game: " + gameName);
                    }
                }
            }

            // Fallback: if no slot_info found any games, try to get game from players
            if (foundGames == 0) {
                _logger.log(_modName, "  No slot_info found, trying players array...");
                if (players) {
                    for each (var playerFallback:Object in players) {
                        if (playerFallback.game != null) {
                            _playerGames[int(playerFallback.slot)] = String(playerFallback.game);
                            _logger.log(_modName, "    slot " + playerFallback.slot + " game: " + playerFallback.game);
                        }
                    }
                }
            }

            // Fetch item name tables for every game in the room so we can
            // resolve cross-game item names in PrintJSON events.
            sendGetDataPackage();

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
            if (p.slot_data && p.slot_data.talisman_map) {
                _talismanMap = p.slot_data.talisman_map;
                _logger.log(_modName, "  talisman_map loaded");
            }
            if (p.slot_data && p.slot_data.talisman_name_map) {
                _talismanNameMap = p.slot_data.talisman_name_map;
            }
            if (p.slot_data && p.slot_data.shadow_core_map) {
                _shadowCoreMap = p.slot_data.shadow_core_map;
                _logger.log(_modName, "  shadow_core_map loaded");
            }
            if (p.slot_data && p.slot_data.shadow_core_name_map) {
                _shadowCoreNameMap = p.slot_data.shadow_core_name_map;
            }
            if (p.slot_data && p.slot_data.wiz_stash_tal_data) {
                _wizStashTalData = p.slot_data.wiz_stash_tal_data;
            }
            if (p.slot_data && p.slot_data.free_stages) {
                _freeStages = p.slot_data.free_stages as Array;
            }
            if (p.slot_data) {
                _goal = int(p.slot_data.goal);
                if (p.slot_data.achievement_grindiness !== undefined) _achievementGrindiness = int(p.slot_data.achievement_grindiness);
                _talismanMinRarity = int(p.slot_data.talisman_min_rarity);
                if (p.slot_data.tattered_scroll_levels  !== undefined) _tatteredScrollLevels  = int(p.slot_data.tattered_scroll_levels);
                if (p.slot_data.worn_tome_levels         !== undefined) _wornTomeLevels         = int(p.slot_data.worn_tome_levels);
                if (p.slot_data.ancient_grimoire_levels  !== undefined) _ancientGrimoireLevels  = int(p.slot_data.ancient_grimoire_levels);
                if (p.slot_data.field_token_placement    !== undefined) _fieldTokenPlacement    = int(p.slot_data.field_token_placement);
                if (p.slot_data.tier_requirements_percent !== undefined) _tierRequirements      = int(p.slot_data.tier_requirements_percent);
                if (p.slot_data.enforce_logic             !== undefined) _enforceLogic           = Boolean(p.slot_data.enforce_logic);
                if (p.slot_data.disable_endurance         !== undefined) _disableEndurance       = Boolean(p.slot_data.disable_endurance);
                if (p.slot_data.disable_trial             !== undefined) _disableTrial           = Boolean(p.slot_data.disable_trial);
                if (p.slot_data.starting_wizard_level     !== undefined) _startingWizardLevel    = int(p.slot_data.starting_wizard_level);
                if (p.slot_data.starting_overcrowd        !== undefined) _startingOvercrowd      = Boolean(p.slot_data.starting_overcrowd);
                if (p.slot_data.enemy_hp_multiplier          !== undefined) _enemyHpMultiplier        = int(p.slot_data.enemy_hp_multiplier);
                if (p.slot_data.enemy_armor_multiplier       !== undefined) _enemyArmorMultiplier     = int(p.slot_data.enemy_armor_multiplier);
                if (p.slot_data.enemy_shield_multiplier      !== undefined) _enemyShieldMultiplier    = int(p.slot_data.enemy_shield_multiplier);
                if (p.slot_data.enemies_per_wave_multiplier  !== undefined) _enemiesPerWaveMultiplier = int(p.slot_data.enemies_per_wave_multiplier);
                if (p.slot_data.extra_wave_count             !== undefined) _extraWaveCount              = int(p.slot_data.extra_wave_count);
                if (p.slot_data.fields_required              !== undefined) _fieldsRequired              = int(p.slot_data.fields_required);
                if (p.slot_data.fields_required_percentage   !== undefined) _fieldsRequiredPercentage    = int(p.slot_data.fields_required_percentage);
            }
            _logger.log(_modName, "  goal=" + _goal + "  talisman_min_rarity=" + _talismanMinRarity);

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

            _toast.addMessage("Connected to " + _apHost + ":" + _apPort
                + " as " + _apSlot + " (Slot " + _saveSlot + ")", 0xFF88FF88);

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
            var msgType:String = (p.type != null) ? String(p.type) : "";

            if (msgType == "ItemSend") {
                var receiving:int  = int(p.receiving);
                var senderSlot:int = int(p.item.player);
                if (receiving != _mySlot && senderSlot != _mySlot) return;

                // Resolve item names using DataPackage
                var logText:String = resolvePartsText(p.data, senderSlot);
                _logger.log(_modName, "  ItemSend: " + logText);

                // Always log to message log
                if (_messageLog != null) _messageLog.add(logText, 0xFFCC99FF, MessageLog.SOURCE_SYSTEM);

                if (senderSlot == _mySlot && receiving != _mySlot) {
                    // Player sent an item for someone else — show only on the item HUD
                    var sentItemId:int   = int(p.item.item);
                    var sentItemName:String = resolveItemNameForSlot(sentItemId, senderSlot);
                    var recvName:String  = (_playerNames[receiving] != null)
                        ? String(_playerNames[receiving]) : ("Slot " + receiving);
                    if (_itemToast != null) {
                        _itemToast.addItem("Sent " + sentItemName + " to " + recvName, 0xCC99FF);
                    }
                }
                return;
            }

            if (msgType == "Chat" || msgType == "ServerChat") {
                var chatText:String = resolvePartsText(p.data);
                _logger.log(_modName, "  Chat: " + chatText);
                _toast.addMessage(chatText, 0xFFFFFFDD);
                return;
            }
        }

        /**
         * Build a simple message from parts using minimal processing.
         * This is the Archipelago server's native message - just resolve player names
         * (for our own world) and pass everything else through as-is.
         * This avoids trying to guess item/location names when the server hasn't resolved them.
         */
        private function partsToSimpleText(data:*):String {
            var result:String = "";
            if (data == null) return result;
            var parts:Array = data as Array;
            for each (var part:Object in parts) {
                var ptype:String = (part.type != null) ? String(part.type) : "text";
                if (ptype == "player_id") {
                    // Replace slot numbers with player names for readability
                    var pSlot:int = int(part.text);
                    result += (_playerNames[pSlot] != null) ? String(_playerNames[pSlot]) : ("Slot " + pSlot);
                } else {
                    // For item_id, location_id, and text parts, use server's text as-is
                    if (part.text != null) result += String(part.text);
                }
            }
            return result;
        }

        /**
         * Resolve a PrintJSON data array to a human-readable string.
         * defaultItemOwner is the slot to assume owns any item_id part that
         * does not include its own player field (e.g. the receiving slot in
         * an ItemSend PrintJSON).
         */
        private function resolvePartsText(data:*, defaultItemOwner:int = -1):String {
            var result:String = "";
            if (data == null) return result;
            var parts:Array = data as Array;
            for each (var part:Object in parts) {
                var ptype:String = (part.type != null) ? String(part.type) : "text";
                if (ptype == "player_id") {
                    var pSlot:int = int(part.text);
                    result += (_playerNames[pSlot] != null) ? String(_playerNames[pSlot]) : ("Slot " + pSlot);
                } else if (ptype == "item_id") {
                    var ownerSlot:int = (part.player != null) ? int(part.player) : defaultItemOwner;
                    result += resolveItemNameForSlot(int(part.text), ownerSlot);
                } else if (ptype == "location_id") {
                    result += resolveLocationName(int(part.text));
                } else {
                    if (part.text != null) result += String(part.text);
                }
            }
            return result;
        }

        /**
         * Extract the item name from a PrintJSON data array by finding the matching
         * item_id and resolving it using the player field from that part.
         * This is the "Ori approach" — use the message structure from the server
         * rather than trying to resolve the ID independently.
         */
        private function extractItemNameFromParts(data:*, targetItemId:int):String {
            if (data == null) return "Item #" + targetItemId;
            var parts:Array = data as Array;
            for each (var part:Object in parts) {
                var ptype:String = (part.type != null) ? String(part.type) : "text";
                if (ptype == "item_id" && int(part.text) == targetItemId) {
                    // Found the matching item_id part — extract the formatted name directly
                    // Some servers don't populate game names in Connected packets, so we
                    // try to use the formatted text that the server already resolved.
                    // If it's "Item #2001", that means it wasn't resolved on the server either,
                    // so we'll get the same result, but at least it's consistent.
                    if (part.text != null && String(part.text).indexOf("Item #") != 0) {
                        // Server provided a resolved name (not a fallback), use it directly
                        return String(part.text);
                    }
                    // Otherwise, try resolution via player slot
                    var ownerSlot:int = (part.player != null) ? int(part.player) : -1;
                    var resolvedName:String = resolveItemNameForSlot(targetItemId, ownerSlot);
                    return resolvedName;
                }
            }
            // Fallback if not found in parts
            return "Item #" + targetItemId;
        }

        /**
         * Resolve an item name given its AP id and the slot whose game owns it.
         *
         * Resolution order:
         *   0. Persistent cache — returns previously-resolved names instantly.
         *   1. Own game resolver (itemName) — fast path for our own items.
         *   2. DataPackage cache — covers all games, including our own, using
         *      the item_name_to_id tables received over the WebSocket.
         *   3. Own game resolver again — last-resort fallback for cross-slot
         *      items from the same game when the DataPackage hasn't arrived yet.
         */
        private function resolveItemNameForSlot(itemId:int, ownerSlot:int):String {
            var itemIdStr:String = String(itemId);

            // Step 0: Check persistent cache first (Ori-style approach)
            if (_resolvedItemNames[itemIdStr] != null) {
                return String(_resolvedItemNames[itemIdStr]);
            }

            var debug:Boolean = true; // Enabled to help debug cross-world item resolution
            var result:String = null;

            // Step 1: fast path for our own items.
            if (ownerSlot == _mySlot || ownerSlot < 0) {
                var mine:String = itemName(itemId);
                if (mine != null) result = mine;
            }

            // Step 2: DataPackage lookup — works for any game, including GCFW
            // itself (populated from the DataPackage WebSocket message).
            if (result == null) {
                var effectiveSlot:int = (ownerSlot >= 0) ? ownerSlot : _mySlot;
                var gameName:String = _playerGames[effectiveSlot];

                if (debug) _logger.log(_modName, "[resolveItemName] itemId=" + itemId + " ownerSlot=" + ownerSlot +
                    " effectiveSlot=" + effectiveSlot + " gameName=" + gameName);

                if (gameName != null) {
                    var gameItems:Object = _itemIdToNameByGame[gameName];
                    if (gameItems != null) {
                        var name:String = gameItems[itemIdStr];
                        if (name != null) {
                            result = name;
                            if (debug) _logger.log(_modName, "[resolveItemName] Found in DataPackage: " + name);
                        } else {
                            if (debug) _logger.log(_modName, "[resolveItemName] Not in DataPackage for " + gameName + ", itemId=" + itemId);
                        }
                    } else {
                        if (debug) _logger.log(_modName, "[resolveItemName] Game '" + gameName + "' not in DataPackage cache");
                    }
                } else {
                    if (debug) _logger.log(_modName, "[resolveItemName] No gameName for slot " + effectiveSlot);
                }
            }

            // Step 3: DataPackage not loaded yet (timing) — try own resolver as
            // a last resort so same-game cross-slot items still resolve.
            if (result == null && ownerSlot != _mySlot) {
                var fallback:String = itemName(itemId);
                if (fallback != null) result = fallback;
            }

            if (result == null) {
                result = "Item #" + itemId;
                if (debug) _logger.log(_modName, "[resolveItemName] Falling back to Item #" + itemId);
            }

            // Cache the result for next time (Ori-style persistent caching)
            _resolvedItemNames[itemIdStr] = result;
            return result;
        }

        private function resolveLocationName(locId:int):String {
            var suffix:String = "";
            var baseId:int = locId;
            if (baseId >= 1000) { baseId -= 1000; suffix = " Stash"; }
            else if (baseId >= 500) { baseId -= 500; suffix = " Bonus"; }
            for (var strId:String in STAGE_LOC_AP_IDS) {
                if (int(STAGE_LOC_AP_IDS[strId]) == baseId) return strId + suffix;
            }
            return "Location #" + locId;
        }

        /**
         * Request the DataPackage for every game represented in the room so
         * we can resolve cross-game item names in PrintJSON events.
         * Since most servers don't populate game names in Connected packets,
         * we request a comprehensive list of all major Archipelago games.
         */
        private function sendGetDataPackage():void {
            if (_ws == null) return;
            var gamesSet:Object = {};

            // First, add any games we know about from _playerGames
            for (var slotKey:String in _playerGames) {
                var g:String = String(_playerGames[slotKey]);
                if (g != null && g.length > 0) gamesSet[g] = true;
            }

            // Always request data for all major Archipelago games
            // This ensures we have item names for any game in the multiworld
            var allGames:Array = [
                "Stardew Valley",
                "The Legend of Zelda: A Link to the Past",
                "The Legend of Zelda: A Link to the Past (Randomizer)",
                "Super Metroid",
                "Secret of Mana",
                "Yo-kai Watch 2: Psychic Specters",
                "Heretic",
                "Final Fantasy",
                "Undertale",
                "A Link to the Past",
                "A Link to the Past - Randomizer",
                "Bumper Sticker Bros",
                "Splatoon",
                "Kingdom Hearts 2",
                "Donkey Kong Country 3",
                "Kirby Super Star Ultra",
                "Mega Man 3",
                "Mega Man X3",
                "Pokémon Emerald",
                "Pokémon Red Version",
                "Pokémon Blue Version",
                "Factorio",
                "Hollow Knight",
                "Risk of Rain 2",
                "Starcraft",
                "StarFox",
                "Super Mario 64",
                "Super Mario Bros",
                "Super Mario Bros 3",
                "Super Mario World",
                "The Legend of Zelda",
                "The Legend of Zelda: Oracle of Seasons",
                "Terraria",
                "Wargroove",
                "Zillion"
            ];

            for each (var game:String in allGames) {
                gamesSet[game] = true;
            }

            var quoted:Array = [];
            for (var gameName:String in gamesSet) {
                quoted.push('"' + gameName + '"');
            }

            var packet:String = '[{"cmd":"GetDataPackage","games":[' + quoted.join(",") + ']}]';
            _logger.log(_modName, "AP >> GetDataPackage  games=" + quoted.length);
            _ws.send(packet);
        }

        private function handleDataPackage(p:Object):void {
            try {
                var data:Object = p.data;
                if (data == null) return;
                var games:Object = data.games;
                if (games == null) return;
                var loaded:int = 0;
                for (var gameName:String in games) {
                    var gameData:Object = games[gameName];
                    if (gameData == null) continue;
                    var nameToId:Object = gameData.item_name_to_id;
                    if (nameToId == null) continue;
                    var byId:Object = {};
                    var itemCount:int = 0;
                    for (var iname:String in nameToId) {
                        byId[String(int(nameToId[iname]))] = iname;
                        itemCount++;
                    }
                    _itemIdToNameByGame[gameName] = byId;
                    _logger.log(_modName, "    [DataPackage] Game '" + gameName + "': " + itemCount + " items");
                    loaded++;
                }
                _logger.log(_modName, "  DataPackage loaded: " + loaded + " game(s)");

                // Debug: log current player games mapping
                var playerGamesList:String = "";
                for (var slot:String in _playerGames) {
                    playerGamesList += "Slot" + slot + "=" + _playerGames[slot] + " ";
                }
                _logger.log(_modName, "    [DataPackage] Player games: " + playerGamesList);
            } catch (err:Error) {
                _logger.log(_modName, "handleDataPackage ERROR: " + err.message);
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

                    // Wiz stash check: OPEN (1) or DESTROYED (2) = stash was cleared.
                    var wizStashLocId:int = locId + 1000;
                    if (_missingLocations[wizStashLocId] == true) {
                        var stashStatus:int = int(GV.ppd.stageWizStashStauses[meta.id]);
                        if (stashStatus == 1 || stashStatus == 2) {
                            toSend.push(wizStashLocId);
                            _logger.log(_modName, "  WIZ_STASH_CLEARED stage=" + meta.strId
                                + "  status=" + stashStatus + "  wizStashLocId=" + wizStashLocId);
                        }
                    }
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
