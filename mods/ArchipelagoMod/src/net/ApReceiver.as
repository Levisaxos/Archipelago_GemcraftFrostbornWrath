package net {
    import Bezel.Logger;
    import data.AV;
    import data.PlayerData;
    import ui.SystemToast;
    import ui.ReceivedToast;
    import ui.MessageLog;

    /**
     * Handles all inbound Archipelago protocol packets.
     *
     * Owns all server-response state: slot data, missing locations, item maps,
     * pending scouts, and items-sent-this-level tracking.
     *
     * ConnectionManager calls the public handle* methods from its onApMessage
     * dispatch switch.  Callbacks let ConnectionManager (and ultimately
     * ArchipelagoMod) react to high-level events without the receiver knowing
     * anything about the rest of the mod.
     */
    public class ApReceiver {

        private var _logger:Logger;
        private var _modName:String;
        private var _sender:ApSender;
        private var _toast:SystemToast;
        private var _receivedToast:ReceivedToast;
        private var _messageLog:MessageLog;

        // AP slot data — populated by handleConnected
        private var _mySlot:int              = 0;
        private var _tokenMap:Object         = {};
        private var _tokenStages:Object      = {};
        private var _talismanMap:Object      = {};
        private var _talismanNameMap:Object  = {};
        private var _shadowCoreMap:Object    = {};
        private var _shadowCoreNameMap:Object = {};
        private var _wizStashTalData:Object  = {};
        private var _missingLocations:Object = {};
        private var _requestedGames:Object   = {};   // gameName → true (prevents duplicate DataPackage requests)
        private var _pendingChecks:Object    = {};   // locationId(int) → {id, player, item}
        // -----------------------------------------------------------------------
        // Callbacks — set by ConnectionManager

        /** Called after Connected is processed and slot data is ready. Signature: (packet:Object):void */
        public var onConnectionEstablished:Function;
        /** Called with the full item list on initial sync (index=0). Signature: (items:Array):void */
        public var onFullSync:Function;
        /** Called for each incremental item grant. Signature: (apId:int):void */
        public var onItemReceived:Function;
        /** Called when a DeathLink bounce is received. Signature: (source:String):void */
        public var onDeathLinkReceived:Function;
        /** Called when we are the sender of an AP item. Signature: (itemName:String, apId:int):void */
        public var onItemSent:Function;

        // -----------------------------------------------------------------------

        public function ApReceiver(logger:Logger, modName:String, sender:ApSender, toast:SystemToast) {
            _logger  = logger;
            _modName = modName;
            _sender  = sender;
            _toast   = toast;
        }

        /** Provide the panel used for received-item toasts. */
        public function setReceivedToast(panel:ReceivedToast):void { _receivedToast = panel; }

        /** Provide the message log so item send/receive events are recorded. */
        public function setMessageLog(log:MessageLog):void { _messageLog = log; }

        // -----------------------------------------------------------------------
        // Getters

        public function get mySlot():int               { return _mySlot; }
        public function get tokenMap():Object          { return _tokenMap; }
        public function get tokenStages():Object       { return _tokenStages; }
        public function get talismanMap():Object       { return _talismanMap; }
        public function get talismanNameMap():Object   { return _talismanNameMap; }
        public function get shadowCoreMap():Object     { return _shadowCoreMap; }
        public function get shadowCoreNameMap():Object { return _shadowCoreNameMap; }
        public function get wizStashTalData():Object   { return _wizStashTalData; }
        public function get missingLocations():Object  { return _missingLocations; }

        // -----------------------------------------------------------------------
        // Packet handlers — called by ConnectionManager._dispatchPacket

        public function handleConnected(p:Object):void {
            _mySlot = int(p.slot);
            _requestedGames = {};

            // Build player registry
            var players:Array = p.players as Array;
            if (players) {
                for each (var player:Object in players) {
                    var pd:PlayerData = new PlayerData();
                    pd.id   = player.slot;
                    pd.name = player.alias;
                    pd.game = p.slot_info[player.slot].game;
                    AV.archipelagoData.players[int(player.slot)] = pd;
                }
            }
            var myPlayer:PlayerData = AV.archipelagoData.players[_mySlot] as PlayerData;
            AV.currentSlot = (myPlayer != null) ? myPlayer.name : "";

            // Token map
            if (p.slot_data && p.slot_data.token_map) {
                _tokenMap    = p.slot_data.token_map;
                _tokenStages = {};
                for (var apIdStr:String in _tokenMap)
                    _tokenStages[_tokenMap[apIdStr]] = true;
            }

            // Talisman / shadow core / wiz stash maps
            if (p.slot_data && p.slot_data.talisman_map)
                _talismanMap = p.slot_data.talisman_map;
            if (p.slot_data && p.slot_data.talisman_name_map)
                _talismanNameMap = p.slot_data.talisman_name_map;
            if (p.slot_data && p.slot_data.shadow_core_map)
                _shadowCoreMap = p.slot_data.shadow_core_map;
            if (p.slot_data && p.slot_data.shadow_core_name_map)
                _shadowCoreNameMap = p.slot_data.shadow_core_name_map;
            if (p.slot_data && p.slot_data.wiz_stash_tal_data)
                _wizStashTalData = p.slot_data.wiz_stash_tal_data;

            // Server options
            if (p.slot_data && p.slot_data.free_stages)
                AV.serverData.freeStages = p.slot_data.free_stages as Array;

            if (p.slot_data) {
                var sd:Object = p.slot_data;
                AV.serverData.serverOptions.goal              = int(sd.goal);
                AV.serverData.serverOptions.talismanMinRarity = int(sd.talisman_min_rarity);
                if (sd.tattered_scroll_levels !== undefined)
                    AV.serverData.serverOptions.tomeXpLevels.tattered = int(sd.tattered_scroll_levels);
                if (sd.worn_tome_levels !== undefined)
                    AV.serverData.serverOptions.tomeXpLevels.worn = int(sd.worn_tome_levels);
                if (sd.ancient_grimoire_levels !== undefined)
                    AV.serverData.serverOptions.tomeXpLevels.ancient = int(sd.ancient_grimoire_levels);
                if (sd.field_token_placement !== undefined)
                    AV.serverData.serverOptions.fieldTokenPlacement = int(sd.field_token_placement);
                if (sd.enforce_logic !== undefined)
                    AV.serverData.serverOptions.enforce_logic = Boolean(sd.enforce_logic);
                if (sd.disable_endurance !== undefined)
                    AV.serverData.serverOptions.disable_endurance = Boolean(sd.disable_endurance);
                if (sd.disable_trial !== undefined)
                    AV.serverData.serverOptions.disable_trial = Boolean(sd.disable_trial);
                if (sd.starting_wizard_level !== undefined)
                    AV.serverData.serverOptions.startingWizardLevel = int(sd.starting_wizard_level);
                if (sd.starting_overcrowd !== undefined)
                    AV.serverData.serverOptions.startingOvercrowd = Boolean(sd.starting_overcrowd);
                if (sd.enemy_hp_multiplier !== undefined)
                    AV.serverData.serverOptions.enemyMultipliers.hp = int(sd.enemy_hp_multiplier);
                if (sd.enemy_armor_multiplier !== undefined)
                    AV.serverData.serverOptions.enemyMultipliers.armor = int(sd.enemy_armor_multiplier);
                if (sd.enemy_shield_multiplier !== undefined)
                    AV.serverData.serverOptions.enemyMultipliers.shield = int(sd.enemy_shield_multiplier);
                if (sd.enemies_per_wave_multiplier !== undefined)
                    AV.serverData.serverOptions.enemyMultipliers.waves = int(sd.enemies_per_wave_multiplier);
                if (sd.extra_wave_count !== undefined)
                    AV.serverData.serverOptions.enemyMultipliers.extraWaves = int(sd.extra_wave_count);
                if (sd.fields_required !== undefined)
                    AV.serverData.serverOptions.fieldsRequired = int(sd.fields_required);
                if (sd.fields_required_percentage !== undefined)
                    AV.serverData.serverOptions.fieldsRequiredPercentage = int(sd.fields_required_percentage);
                if (sd.achievement_required_effort !== undefined)
                    AV.serverData.serverOptions.achievementRequiredEffort = int(sd.achievement_required_effort);
            }

            // Missing locations
            var missing:Array = p.missing_locations as Array;
            var checked:Array = p.checked_locations as Array;
            _logger.log(_modName, " - missing_locations=" + (missing ? missing.length : "?")
                + "  checked_locations=" + (checked ? checked.length : "?"));
            _missingLocations = {};
            if (missing != null) {
                for each (var locId:int in missing)
                    _missingLocations[locId] = true;
            }
            // Mirror into AV so StageTinter, ModButtons, and AchievementLogicEvaluator
            // all read from a single shared reference without needing ConnectionManager.
            AV.saveData.missingLocations = _missingLocations;

            _sender.sendLocationScouts(_missingLocations);

            if (onConnectionEstablished != null)
                onConnectionEstablished(p);
        }

        public function handleReceivedItems(p:Object):void {
            var index:int   = p.index;
            var items:Array = p.items as Array;
            _logger.log(_modName, "ReceivedItems index=" + index + " count=" + items.length);

            if (index == 0) {
                if (onFullSync != null) onFullSync(items);
            } else {
                for each (var networkItem:Object in items) {
                    if (onItemReceived != null) onItemReceived(int(networkItem.item));
                }
            }
        }

        public function handleBounced(p:Object):void {
            var tags:Array = p.tags as Array;
            if (tags == null || tags.indexOf("DeathLink") < 0) return;
            var source:String = (p.data && p.data.source) ? String(p.data.source) : "unknown";
            _logger.log(_modName, "DeathLink received from " + source);
            if (onDeathLinkReceived != null) onDeathLinkReceived(source);
        }

        public function handlePrintJSON(p:Object):void {
            var msgType:String = (p.type != null) ? String(p.type) : "";

            if (msgType == "ItemSend") {
                var receiving:int  = int(p.receiving);
                var senderSlot:int = int(p.item.player);
                if (receiving != _mySlot && senderSlot != _mySlot) return;

                var logText:String = resolvePartsText(p.data, senderSlot);
                _logger.log(_modName, "  ItemSend: " + logText);
                if (_messageLog != null) _messageLog.add(logText, 0xFFCC99FF, MessageLog.SOURCE_SYSTEM);

                if (senderSlot == _mySlot) {
                    var sentItemId:int      = int(p.item.item);
                    var sentLocId:int       = int(p.item.location);
                    var sentItemName:String = resolveItemNameForSlot(sentItemId, receiving);
                    var recvPlayer:PlayerData = AV.archipelagoData.players[receiving] as PlayerData;
                    var recvName:String = (recvPlayer != null) ? recvPlayer.name : ("Slot " + receiving);
                    _toast.addMessage("Sent " + sentItemName + " to " + recvName, 0xCC99FF);
                    if (onItemSent != null) onItemSent(sentItemName, sentItemId);
                }
                return;
            }

            if (msgType == "Chat" || msgType == "ServerChat") {
                var chatText:String = resolvePartsText(p.data);
                _logger.log(_modName, "  Chat: " + chatText);
                _toast.addMessage(chatText, 0xFFFFFFDD);
            }
        }

        public function handleDataPackage(p:Object):void {
            try {
                var pkgData:Object = p.data;
                if (pkgData == null) return;
                var games:Object = pkgData.games;
                if (games == null) return;
                var loaded:int = 0;
                for (var gameName:String in games) {
                    var gameData:Object = games[gameName];
                    if (gameData == null) continue;
                    var nameToId:Object = gameData.item_name_to_id;
                    if (nameToId == null) continue;

                    // Invert name→id map to id→name for fast lookup
                    var byId:Object = {};
                    var itemCount:int = 0;
                    for (var iname:String in nameToId) {
                        byId[String(int(nameToId[iname]))] = iname;
                        itemCount++;
                    }
                    AV.archipelagoData.games[gameName] = byId;
                    _logger.log(_modName, "    [DataPackage] Game '" + gameName + "': " + itemCount + " items");

                    // Back-fill names for checks that were waiting on this DataPackage
                    var filled:int = 0;
                    for (var locIdStr:String in AV.archipelagoData.checks) {
                        var check:Object = AV.archipelagoData.checks[locIdStr];
                        if (check.name != null || check.game != gameName) continue;
                        var pending:Object = _pendingChecks[int(locIdStr)];
                        if (pending == null) continue;
                        var resolvedName:String = byId[String(int(pending.item))];
                        check.name = (resolvedName != null) ? resolvedName : ("Item #" + pending.item);
                        filled++;
                    }
                    if (filled > 0)
                        _logger.log(_modName, "    [DataPackage] Filled " + filled + " check name(s) for '" + gameName + "'");
                    loaded++;
                }
                _logger.log(_modName, "  DataPackage loaded: " + loaded + " game(s)");
            } catch (err:Error) {
                _logger.log(_modName, "handleDataPackage ERROR: " + err.message);
            }
        }

        public function handleLocationInfo(p:Object):void {
            var locations:Array = p.locations as Array;
            if (locations == null) return;

            var uniqueGames:Object = {};
            for each (var loc:Object in locations) {
                var locId:int     = int(loc.location);
                var ownerSlot:int = int(loc.player);
                var itemId:int    = int(loc.item);

                _pendingChecks[locId] = {id: locId, player: ownerSlot, item: itemId};

                var playerData:PlayerData = AV.archipelagoData.players[ownerSlot] as PlayerData;
                var game:String       = (playerData != null) ? playerData.game : null;
                var playerName:String = (playerData != null) ? playerData.name : ("Slot " + ownerSlot);
                AV.archipelagoData.checks[locId] = {id: locId, name: null, game: game, playerName: playerName};

                if (game != null) uniqueGames[game] = true;
            }

            for (var gameName:String in uniqueGames)
                _requestDataPackage(gameName);

            _logger.log(_modName, "LocationInfo: scouted " + locations.length
                + " locations, requested " + _countKeys(uniqueGames) + " DataPackage(s).");
        }

        // -----------------------------------------------------------------------
        // Private helpers

        private function _requestDataPackage(gameName:String):void {
            if (gameName == null || gameName.length == 0) return;
            if (_requestedGames[gameName] || AV.archipelagoData.games[gameName] != null) return;
            _requestedGames[gameName] = true;
            _sender.sendDataPackageRequest(gameName);
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
                    var pData:PlayerData = AV.archipelagoData.players[pSlot] as PlayerData;
                    result += (pData != null) ? pData.name : ("Slot " + pSlot);
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
         * Resolve an item name given its AP id and the slot whose game owns it.
         *
         * Resolution order:
         *   0. Persistent player cache — returns previously-resolved names instantly.
         *   1. DataPackage cache — covers all games using the item_name_to_id tables
         *      received over the WebSocket.
         *   2. Fallback — "Item #<id>".
         */
        private function resolveItemNameForSlot(itemId:int, ownerSlot:int):String {
            var itemIdStr:String = String(itemId);

            // Step 0: persistent player cache
            var playerEntry:PlayerData = AV.archipelagoData.players[ownerSlot] as PlayerData;
            if (playerEntry != null && playerEntry.items != null && playerEntry.items[itemId] != null)
                return playerEntry.items[itemId].name;

            var gameName:String = (playerEntry != null) ? playerEntry.game : null;

            if (gameName != null) {
                var gameItems:Object = AV.archipelagoData.games[gameName];
                if (gameItems != null) {
                    var name:String = gameItems[itemIdStr];
                    if (name != null)
                        return name;
                }
            }

            return "Item #" + itemId;
        }

        private function resolveLocationName(locId:int):String {
            var suffix:String = "";
            var baseId:int = locId;
            if (baseId >= 400)      { baseId -= 399;  suffix = " Stash"; }
            else if (baseId >= 200) { baseId -= 199;  suffix = " Bonus"; }
            var stageLocIds:Object = ConnectionManager.stageLocIds;
            for (var strId:String in stageLocIds) {
                if (int(stageLocIds[strId]) == baseId) return strId + suffix;
            }
            return "Location #" + locId;
        }

        private function _countKeys(obj:Object):int {
            var n:int = 0;
            for (var k:String in obj) n++;
            return n;
        }
    }
}
