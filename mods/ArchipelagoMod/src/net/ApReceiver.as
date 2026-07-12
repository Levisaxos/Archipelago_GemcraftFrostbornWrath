package net {
    import Bezel.Logger;
    import data.AV;
    import data.PlayerData;
    import ui.SystemToast;
    import ui.ReceivedToast;
    import ui.MessageLog;
    import ui.ItemColors;

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
        private var _myTeam:int              = 0;
        private var _tokenMap:Object         = {};
        private var _tokenStages:Object      = {};
        private var _talismanMap:Object      = {};
        private var _talismanNameMap:Object  = {};
        private var _talismanChargeMap:Object = {}; // propId(str) → {fragApId(str) → value}
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
        /** Called when we are the sender of an AP item. Signature: (itemName:String, apId:int, recipientName:String, isForMe:Boolean):void */
        public var onItemSent:Function;
        /** Called when AP responds to a `Get` with a `Retrieved` packet. Signature: (keysMap:Object):void
         *  keysMap is the `keys` object from the packet — { key:String → value:* (null if absent) }. */
        public var onDataStorageRetrieved:Function;
        /** Called after a LocationInfo packet has been processed and the scout
         *  cache (`_pendingChecks` / AV.archipelagoData.checks) is up to date.
         *  Signature: ():void. Used by triggers that depend on scout data,
         *  e.g. L5 skill-location hints that may arrive before the cache lands. */
        public var onScoutsUpdated:Function;

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
        public function get myTeam():int               { return _myTeam; }
        public function get tokenMap():Object          { return _tokenMap; }
        public function get tokenStages():Object       { return _tokenStages; }
        public function get talismanMap():Object       { return _talismanMap; }
        public function get talismanNameMap():Object   { return _talismanNameMap; }
        public function get talismanChargeMap():Object { return _talismanChargeMap; }
        public function get shadowCoreMap():Object     { return _shadowCoreMap; }
        public function get shadowCoreNameMap():Object { return _shadowCoreNameMap; }
        public function get wizStashTalData():Object   { return _wizStashTalData; }
        public function get missingLocations():Object  { return _missingLocations; }

        /**
         * Reverse lookup: find the AP locationId scouted to contain the given
         * item AP id, where the item is destined for OUR slot. Returns -1 if
         * no scout cache entry matches — caller should treat as "not known".
         *
         * Filters by receiving slot so a foreign game's coincidentally-numbered
         * item can't shadow our own. Only finds items placed in our own world
         * (we only scout our own missing_locations); items placed in another
         * player's world are unreachable via this lookup.
         */
        public function findLocationForItem(apItemId:int):int {
            for (var locIdStr:String in _pendingChecks) {
                var entry:Object = _pendingChecks[locIdStr];
                if (entry == null) continue;
                if (int(entry.item) != apItemId) continue;
                if (int(entry.player) != _mySlot) continue;
                return int(locIdStr);
            }
            return -1;
        }

        /** Scout-cache entry as stored by handleLocationInfo:
         *  {id:int, name:String, game:String, playerName:String}.
         *  Looked up by the same int locationId returned from findLocationForItem.
         *  Returns null if not yet scouted. */
        public function getScoutEntry(locId:int):Object {
            return AV.archipelagoData.checks[locId];
        }

        // -----------------------------------------------------------------------
        // Packet handlers — called by ConnectionManager._dispatchPacket

        public function handleConnected(p:Object):void {
            _mySlot = int(p.slot);
            _myTeam = (p.team !== undefined) ? int(p.team) : 0;
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
            if (p.slot_data && p.slot_data.talisman_charge_map)
                _talismanChargeMap = p.slot_data.talisman_charge_map;
            if (p.slot_data && p.slot_data.shadow_core_map)
                _shadowCoreMap = p.slot_data.shadow_core_map;
            if (p.slot_data && p.slot_data.shadow_core_name_map)
                _shadowCoreNameMap = p.slot_data.shadow_core_name_map;
            if (p.slot_data && p.slot_data.wiz_stash_tal_data)
                _wizStashTalData = p.slot_data.wiz_stash_tal_data;

            // Server options
            if (p.slot_data && p.slot_data.free_stages)
                AV.serverData.freeStages = p.slot_data.free_stages as Array;

            // Progression talisman set (25 fragments the mod unlocks + slots).
            if (p.slot_data && p.slot_data.progression_talisman_set)
                AV.serverData.progressionTalismanSet = p.slot_data.progression_talisman_set as Array;

            if (p.slot_data) {
                var sd:Object = p.slot_data;
                AV.serverData.serverOptions.goal              = int(sd.goal);
                if (sd.starting_stage !== undefined)
                    AV.serverData.serverOptions.startingStage = int(sd.starting_stage);
                if (sd.tattered_scroll_levels !== undefined)
                    AV.serverData.serverOptions.tomeXpLevels.tattered = int(sd.tattered_scroll_levels);
                if (sd.worn_tome_levels !== undefined)
                    AV.serverData.serverOptions.tomeXpLevels.worn = int(sd.worn_tome_levels);
                if (sd.ancient_grimoire_levels !== undefined)
                    AV.serverData.serverOptions.tomeXpLevels.ancient = int(sd.ancient_grimoire_levels);
                if (sd.xp_tome_bonus !== undefined)
                    AV.serverData.serverOptions.xpTomeBonus = int(sd.xp_tome_bonus);
                if (sd.sp_bundle_values !== undefined && sd.sp_bundle_values is Array) {
                    var vSpVals:Array = sd.sp_bundle_values as Array;
                    var vSpOut:Array = [0, 0, 0, 0];
                    for (var iSp:int = 0; iSp < 4 && iSp < vSpVals.length; iSp++)
                        vSpOut[iSp] = int(vSpVals[iSp]);
                    AV.serverData.serverOptions.spBundleValues = vSpOut;
                }
                if (sd.field_token_placement !== undefined)
                    AV.serverData.serverOptions.fieldTokenPlacement = int(sd.field_token_placement);
                if (sd.disable_endurance !== undefined)
                    AV.serverData.serverOptions.disable_endurance = Boolean(sd.disable_endurance);
                if (sd.disable_trial !== undefined)
                    AV.serverData.serverOptions.disable_trial = Boolean(sd.disable_trial);
                if (sd.starting_wizard_level !== undefined)
                    AV.serverData.serverOptions.startingWizardLevel = int(sd.starting_wizard_level);
                if (sd.starting_overcrowd !== undefined)
                    AV.serverData.serverOptions.startingOvercrowd = Boolean(sd.starting_overcrowd);
                if (sd.field_token_granularity !== undefined)
                    AV.serverData.serverOptions.fieldTokenGranularity = int(sd.field_token_granularity);
                if (sd.stash_key_granularity !== undefined)
                    AV.serverData.serverOptions.stashKeyGranularity = int(sd.stash_key_granularity);
                if (sd.gem_pouch_granularity !== undefined)
                    AV.serverData.serverOptions.gemPouchGranularity = int(sd.gem_pouch_granularity);
                if (sd.gem_pouch_play_order !== undefined)
                    AV.serverData.serverOptions.gemPouchPlayOrder = sd.gem_pouch_play_order as Array;
                if (sd.stage_progressive_order !== undefined)
                    AV.serverData.serverOptions.stageProgressiveOrder = sd.stage_progressive_order as Array;
                if (sd.progressive_tile_order !== undefined)
                    AV.serverData.serverOptions.progressiveTileOrder = sd.progressive_tile_order as Array;
                if (sd.progressive_stage_order !== undefined)
                    AV.serverData.serverOptions.progressiveStageOrder = sd.progressive_stage_order as Array;
                if (sd.progressive_tier_order !== undefined)
                    AV.serverData.serverOptions.progressiveTierOrder = sd.progressive_tier_order as Array;
                if (sd.gem_pouch_progressive_id !== undefined)
                    AV.serverData.serverOptions.gemPouchProgressiveId = int(sd.gem_pouch_progressive_id);
                if (sd.gem_pouch_per_tier_progressive_id !== undefined)
                    AV.serverData.serverOptions.gemPouchPerTierProgressiveId = int(sd.gem_pouch_per_tier_progressive_id);
                if (sd.field_token_per_stage_progressive_id !== undefined)
                    AV.serverData.serverOptions.fieldTokenPerStageProgressiveId = int(sd.field_token_per_stage_progressive_id);
                if (sd.field_token_per_tile_progressive_id !== undefined)
                    AV.serverData.serverOptions.fieldTokenPerTileProgressiveId = int(sd.field_token_per_tile_progressive_id);
                if (sd.field_token_per_tier_progressive_id !== undefined)
                    AV.serverData.serverOptions.fieldTokenPerTierProgressiveId = int(sd.field_token_per_tier_progressive_id);
                if (sd.stash_key_per_stage_progressive_id !== undefined)
                    AV.serverData.serverOptions.stashKeyPerStageProgressiveId = int(sd.stash_key_per_stage_progressive_id);
                if (sd.stash_key_per_tile_progressive_id !== undefined)
                    AV.serverData.serverOptions.stashKeyPerTileProgressiveId = int(sd.stash_key_per_tile_progressive_id);
                if (sd.stash_key_per_tier_progressive_id !== undefined)
                    AV.serverData.serverOptions.stashKeyPerTierProgressiveId = int(sd.stash_key_per_tier_progressive_id);
                if (sd.stage_tier_by_str_id !== undefined)
                    AV.serverData.serverOptions.stageTierByStrId = sd.stage_tier_by_str_id;
                if (sd.extra_shadow_cores_per_wave !== undefined)
                    AV.serverData.serverOptions.extraShadowCoresPerWave = int(sd.extra_shadow_cores_per_wave);
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
                if (sd.fields_required_count !== undefined)
                    AV.serverData.serverOptions.fieldsRequiredCount = int(sd.fields_required_count);
                if (sd.achievement_required_effort !== undefined)
                    AV.serverData.serverOptions.achievementRequiredEffort = int(sd.achievement_required_effort);
                if (sd.difficulty !== undefined)
                    AV.serverData.serverOptions.difficulty = int(sd.difficulty);
                if (sd.stage_gates !== undefined)
                    AV.serverData.serverOptions.stageGates = sd.stage_gates;
                if (sd.achievement_min_wl !== undefined)
                    AV.serverData.serverOptions.achievementMinWl = sd.achievement_min_wl;
                if (sd.wl_eff_xp !== undefined)
                    AV.serverData.serverOptions.wlEffXp = sd.wl_eff_xp;
                if (sd.xp_trait_ap_ids !== undefined)
                    AV.serverData.serverOptions.xpTraitApIds = sd.xp_trait_ap_ids as Array;
                if (sd.xp_trait_multiplier !== undefined)
                    AV.serverData.serverOptions.xpTraitMultiplier = sd.xp_trait_multiplier as Array;
                if (sd.xp_trait_min_wl !== undefined)
                    AV.serverData.serverOptions.xpTraitMinWl = sd.xp_trait_min_wl as Array;
                if (sd.death_link !== undefined)
                    AV.serverData.serverOptions.deathLinkEnabled = Boolean(sd.death_link);
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

            // Checked locations — server-authoritative list of locations already
            // completed on this slot. Used by AchievementUnlocker.restoreCheckedAchievements
            // on a fresh slot (e.g. lost save file) so previously-earned
            // achievements show as completed in the in-game panel instead of
            // appearing as out-of-logic.
            var checkedMap:Object = {};
            if (checked != null) {
                for each (var checkedLocId:int in checked)
                    checkedMap[checkedLocId] = true;
            }
            AV.saveData.checkedLocations = checkedMap;

            _sender.sendLocationScouts(_missingLocations);

            // Request our own game's DataPackage so location names (Journey,
            // Stash, achievements) resolve from the AP server's authoritative
            // table — same source foreign games use. Without this,
            // gamesLocations["GemCraft: Frostborn Wrath"] stays empty and
            // resolveLocationName falls back to numeric "Location #N" strings.
            _requestDataPackage("GemCraft: Frostborn Wrath");

            if (onConnectionEstablished != null)
                onConnectionEstablished(p);
        }

        public function handleReceivedItems(p:Object):void {
            var index:int   = p.index;
            var items:Array = p.items as Array;
            _logger.log(_modName, "ReceivedItems index=" + index + " count=" + items.length);

            // Cache classification flags so toast emitters can colour the
            // popup by importance (progression / useful / trap / filler).
            for each (var ni:Object in items) {
                if (ni == null || ni.item == null) continue;
                ItemColors.setFlags(int(ni.item), int(ni.flags));
            }

            if (index == 0) {
                if (onFullSync != null) onFullSync(items);
            } else {
                for each (var networkItem:Object in items) {
                    if (onItemReceived != null) onItemReceived(int(networkItem.item));
                }
            }
        }

        /**
         * Inbound `Retrieved` — async response to our `Get`. The `keys` object
         * maps each requested key to its stored value (null when absent). We
         * just forward the map to whoever registered onDataStorageRetrieved.
         */
        public function handleRetrieved(p:Object):void {
            var keys:Object = p.keys;
            if (keys == null) {
                _logger.log(_modName, "Retrieved with no keys field — ignoring");
                return;
            }
            if (onDataStorageRetrieved != null) {
                try {
                    onDataStorageRetrieved(keys);
                } catch (e:Error) {
                    _logger.log(_modName, "onDataStorageRetrieved threw: " + e.message);
                }
            }
        }

        public function handleBounced(p:Object):void {
            var tags:Array = p.tags as Array;
            if (tags == null || tags.indexOf("DeathLink") < 0) return;
            var source:String = (p.data && p.data.source) ? String(p.data.source) : "unknown";
            // The server bounces Bounce packets to every DeathLink-tagged client,
            // including us. Drop the echo of our own death so the punishment
            // doesn't get applied to the killer.
            if (AV.currentSlot != null && AV.currentSlot.length > 0 && source == AV.currentSlot) {
                return;
            }
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
                var logHtml:String = resolvePartsHtml(p.data, senderSlot);
                _logger.log(_modName, "  ItemSend: " + logText);
                if (_messageLog != null) _messageLog.add(logText, 0xFFFFFF, MessageLog.SOURCE_SYSTEM, logHtml);

                if (senderSlot == _mySlot) {
                    var sentItemId:int      = int(p.item.item);
                    var sentLocId:int       = int(p.item.location);
                    var sentFlags:int       = (p.item.flags != null) ? int(p.item.flags) : 0;
                    var sentItemName:String = resolveItemNameForSlot(sentItemId, receiving);
                    var sentLocName:String  = resolveLocationNameForSlot(sentLocId, _mySlot);
                    var recvPlayer:PlayerData = AV.archipelagoData.players[receiving] as PlayerData;
                    var recvName:String = (recvPlayer != null) ? recvPlayer.name : ("Slot " + receiving);

                    // Item appears in its Archipelago importance colour;
                    // surrounding text stays the toast's default white.
                    var itemHex:String = _hex6(ItemColors.forFlags(sentFlags));
                    var html:String = "Sent <font color=\"#" + itemHex + "\">"
                        + _escapeHtml(sentItemName) + "</font> to "
                        + _escapeHtml(recvName)
                        + " (Found at " + _escapeHtml(sentLocName) + ")";
                    var plain:String = "Sent " + sentItemName + " to " + recvName
                        + " (Found at " + sentLocName + ")";
                    _toast.addRichMessage(html, plain);

                    var isForMe:Boolean = (receiving == _mySlot);
                    if (onItemSent != null) onItemSent(sentItemName, sentItemId, recvName, isForMe);
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

                    // Same treatment for locations so foreign-game location ids
                    // in ItemSend messages can be resolved to readable names.
                    var locNameToId:Object = gameData.location_name_to_id;
                    var locCount:int = 0;
                    if (locNameToId != null) {
                        var locById:Object = {};
                        for (var lname:String in locNameToId) {
                            locById[String(int(locNameToId[lname]))] = lname;
                            locCount++;
                        }
                        AV.archipelagoData.gamesLocations[gameName] = locById;
                    }
                    _logger.log(_modName, "    [DataPackage] Game '" + gameName + "': " + itemCount + " items, " + locCount + " locations");

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

            if (onScoutsUpdated != null) {
                try { onScoutsUpdated(); }
                catch (e:Error) { _logger.log(_modName, "onScoutsUpdated threw: " + e.message); }
            }
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
         * HTML variant of resolvePartsText: emits the same readable text but
         * wraps each item_id part in a <font color="…"> tag matching the
         * Archipelago importance of the part's flags. Other segments are
         * escaped so they render as literal text. Used by the MessageLog so
         * the ItemSend history shows item names in their progression /
         * useful / trap / filler colour while the rest of the line stays
         * the panel's default white.
         */
        private function resolvePartsHtml(data:*, defaultItemOwner:int = -1):String {
            var result:String = "";
            if (data == null) return result;
            var parts:Array = data as Array;
            for each (var part:Object in parts) {
                var ptype:String = (part.type != null) ? String(part.type) : "text";
                if (ptype == "player_id") {
                    var pSlot:int = int(part.text);
                    var pData:PlayerData = AV.archipelagoData.players[pSlot] as PlayerData;
                    var pName:String = (pData != null) ? pData.name : ("Slot " + pSlot);
                    result += _escapeHtml(pName);
                } else if (ptype == "item_id") {
                    var ownerSlot:int = (part.player != null) ? int(part.player) : defaultItemOwner;
                    var itemName:String = resolveItemNameForSlot(int(part.text), ownerSlot);
                    var flags:int = (part.flags != null) ? int(part.flags) : 0;
                    var hex:String = _hex6(ItemColors.forFlags(flags));
                    result += "<font color=\"#" + hex + "\">" + _escapeHtml(itemName) + "</font>";
                } else if (ptype == "location_id") {
                    var locOwner:int = (part.player != null) ? int(part.player) : -1;
                    result += _escapeHtml(resolveLocationNameForSlot(int(part.text), locOwner));
                } else {
                    if (part.text != null) result += _escapeHtml(String(part.text));
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
                    var pData:PlayerData = AV.archipelagoData.players[pSlot] as PlayerData;
                    result += (pData != null) ? pData.name : ("Slot " + pSlot);
                } else if (ptype == "item_id") {
                    var ownerSlot:int = (part.player != null) ? int(part.player) : defaultItemOwner;
                    result += resolveItemNameForSlot(int(part.text), ownerSlot);
                } else if (ptype == "location_id") {
                    var locOwner:int = (part.player != null) ? int(part.player) : -1;
                    result += resolveLocationNameForSlot(int(part.text), locOwner);
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

        /**
         * Resolve a location id to a name when the owning slot is unknown
         * (legacy callers). Tries the GCFW stage table first, then walks the
         * cached per-game location maps as a fallback.
         */
        private function resolveLocationName(locId:int):String {
            return resolveLocationNameForSlot(locId, -1);
        }

        /**
         * Resolve a location id given the slot whose game owns the location.
         *
         * Priority:
         *   1. If owner is our slot (or the helper inferred it via the GCFW
         *      stage map), use the stage-aware GCFW name (Journey / Stash).
         *   2. If the owner's game has a cached location_name_to_id map
         *      (loaded from DataPackage), use it.
         *   3. Fall back to "Location #<id>".
         */
        private function resolveLocationNameForSlot(locId:int, ownerSlot:int):String {
            // Step 1: GCFW stage table (only meaningful for our own slot).
            if (ownerSlot < 0 || ownerSlot == _mySlot) {
                var suffix:String = "";
                var baseId:int = locId;
                if (baseId >= 400 && baseId < 1400) { baseId -= 399;  suffix = " Stash"; }
                var stageLocIds:Object = ConnectionManager.stageLocIds;
                if (stageLocIds != null) {
                    for (var strId:String in stageLocIds) {
                        if (int(stageLocIds[strId]) == baseId) return strId + suffix;
                    }
                }
            }

            // Step 2: per-game DataPackage cache.
            if (ownerSlot >= 0) {
                var ownerData:PlayerData = AV.archipelagoData.players[ownerSlot] as PlayerData;
                var gameName:String = (ownerData != null) ? ownerData.game : null;
                if (gameName != null) {
                    var gameLocs:Object = AV.archipelagoData.gamesLocations[gameName];
                    if (gameLocs != null) {
                        var resolved:String = gameLocs[String(locId)];
                        if (resolved != null) return resolved;
                    }
                }
            }

            return "Location #" + locId;
        }

        private function _countKeys(obj:Object):int {
            var n:int = 0;
            for (var k:String in obj) n++;
            return n;
        }

        /** Format a uint as a zero-padded 6-digit hex string for HTML colour tags. */
        private function _hex6(c:uint):String {
            var s:String = (c & 0xFFFFFF).toString(16);
            while (s.length < 6) s = "0" + s;
            return s;
        }

        /** Escape the few characters that would otherwise be parsed as HTML. */
        private function _escapeHtml(s:String):String {
            if (s == null) return "";
            return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
        }
    }
}
