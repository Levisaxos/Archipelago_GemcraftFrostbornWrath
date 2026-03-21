package {
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.net.SharedObject;
    import flash.ui.Keyboard;

    import Bezel.Bezel;
    import Bezel.BezelMod;
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    public class ArchipelagoMod extends MovieClip implements BezelMod {

        public function get VERSION():String       { return "0.0.1"; }
        public function get MOD_NAME():String      { return "ArchipelagoMod"; }
        public function get BEZEL_VERSION():String { return "2.1.1"; }

        // Offset from the top-left of the game content (inside the letterbox).
        private static const TOAST_OFFSET_X:Number = 52;
        private static const TOAST_OFFSET_Y:Number = 10;

        private var _logger:Logger;
        private var _bezel:Bezel;
        private var _btn:ArchipelagoButton;
        private var _buttonAdded:Boolean = false;

        private var _toast:ToastPanel;
        private var _toastOnStage:Boolean = false;

        private var _debugOptions:ScrDebugOptions;
        private var _progressionBlocker:ProgressionBlocker;
        private var _ws:WebSocketClient;
        private var _tokenMap:Object = {};       // item AP ID (string) → stage str_id
        private var _tokenStages:Object = {};    // stage str_id → true  (has an AP token)
        private var _apState:SharedObject;       // persistent AP-specific state (xp, checks, etc.)
        private var _keyListenerAdded:Boolean = false;

        // -----------------------------------------------------------------------
        // Archipelago connection settings — replace with UI config later.
        private static const AP_HOST:String     = "localhost";
        private static const AP_PORT:int        = 38281;
        private static const AP_SLOT:String     = "Levisaxos";
        private static const AP_PASSWORD:String = "";
        private static const AP_SECURE:Boolean  = false; // local server = plain ws://
        // -----------------------------------------------------------------------

        // Set to false whenever the selector closes so unlockAllMapTiles() re-runs on next open.
        private var _mapTilesUnlocked:Boolean = false;

        // -----------------------------------------------------------------------
        // Debug mode — toggled at runtime by Ctrl+Shift+Alt+End.
        // Set DEBUG_MODE_DEFAULT = true to start with debug mode already on,
        // useful during development so you don't need the hotkey every session.
        // For a public release, leave it false.
        private static const DEBUG_MODE_DEFAULT:Boolean = false;
        private var _debugMode:Boolean = DEBUG_MODE_DEFAULT;
        // -----------------------------------------------------------------------

        // Skill names indexed by game_id (matches SkillId constants).
        private static const SKILL_NAMES:Array = [
            "Mana Stream", "True Colors", "Fusion", "Orb of Presence",
            "Resonance", "Demolition", "Critical Hit", "Mana Leech",
            "Bleeding", "Armor Tearing", "Poison", "Slowing",
            "Freeze", "Whiteout", "Ice Shards", "Bolt",
            "Beam", "Barrage", "Fury", "Amplifiers",
            "Pylons", "Lanterns", "Traps", "Seeker Sense"
        ];

        // Battle trait names indexed by game_id (matches BattleTraitId constants).
        private static const BATTLE_TRAIT_NAMES:Array = [
            "Adaptive Carapace", "Dark Masonry", "Swarmling Domination", "Overcrowd",
            "Corrupted Banishment", "Awakening", "Insulation", "Hatred",
            "Swarmling Parasites", "Haste", "Thick Air", "Vital Link",
            "Giant Domination", "Strength in Numbers", "Ritual"
        ];

        public function ArchipelagoMod() {
            super();
            _logger = Logger.getLogger(MOD_NAME);
        }

        public function bind(bezel:Bezel, gameObjects:Object):void {
            try {
                _bezel = bezel;
                _apState = SharedObject.getLocal("gcfw_archipelago");
                if (_apState.data.apXpGranted == undefined) _apState.data.apXpGranted = 0;
                _toast = new ToastPanel();
                _debugOptions = new ScrDebugOptions(this);
                _progressionBlocker = new ProgressionBlocker(_logger, MOD_NAME);
                _progressionBlocker.enable(_bezel);
                addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
                _logger.log(MOD_NAME, "ArchipelagoMod loaded!");

                _ws = new WebSocketClient(_logger);
                _ws.onOpen    = function():void {
                    _toast.addMessage("AP connected!", 0xFF88FF88);
                };
                _ws.onMessage = onApMessage;
                _ws.onError   = function(msg:String):void {
                    _toast.addMessage("AP error: " + msg, 0xFFFF6666);
                };
                _ws.onClose   = function():void {
                    _toast.addMessage("AP disconnected", 0xFFFFAA44);
                };
                _ws.connect(AP_HOST, AP_PORT, AP_SECURE);
            } catch (err:Error) {
                _logger.log(MOD_NAME, "BIND ERROR: " + err.message + "\n" + err.getStackTrace());
            }
        }

        public function unload():void {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            if (_ws != null) {
                _ws.disconnect();
                _ws = null;
            }
            if (_progressionBlocker != null) {
                _progressionBlocker.disable();
                _progressionBlocker = null;
            }
            if (this.stage != null) {
                this.stage.removeEventListener(Event.RESIZE, onStageResize);
            }
            if (_toast != null && _toast.parent != null) {
                _toast.parent.removeChild(_toast);
            }
            _toast = null;
            _toastOnStage = false;
            if (_keyListenerAdded && this.stage != null) {
                this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
                _keyListenerAdded = false;
            }
            if (_debugOptions != null && _debugOptions.isOpen) {
                _debugOptions.close();
            }
            _debugOptions = null;
            if (_btn != null && _btn.parent != null) {
                _btn.parent.removeChild(_btn);
                _btn = null;
            }
            _buttonAdded = false;
            _logger.log(MOD_NAME, "ArchipelagoMod unloaded");
        }

        // -----------------------------------------------------------------------

        private function onEnterFrame(e:Event):void {
            // Add toast to stage using the mod's own stage reference — available on any screen.
            if (!_toastOnStage && _toast != null && this.stage != null) {
                this.stage.addChild(_toast);
                _toastOnStage = true;
                positionToast();
                this.stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);
            }

            // Register the debug hotkey (Ctrl+Shift+Alt+End) once the stage exists.
            if (!_keyListenerAdded && this.stage != null) {
                this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
                _keyListenerAdded = true;
            }

            // selectorCore is never null — use renderer == null as the "not in selector" signal.
            if (GV.ppd == null || GV.selectorCore.renderer == null) {
                _mapTilesUnlocked = false;
                return;
            }

            // Sync tile visibility with stage unlock state once per selector session.
            if (!_mapTilesUnlocked) {
                syncMapTilesWithStages();
                GV.selectorCore.renderer.setMapTilesVisibility();
                _mapTilesUnlocked = true;
                _logger.log(MOD_NAME, "Map tile visibility synced with stage states");
            }

            // Enforce full-world scroll limits every frame so the W4 lock in
            // setVpLimits() can never stick — even after returning from a level.
            enforceFullWorldScrollLimits();

            var mc:* = GV.selectorCore.mc;
            if (mc == null) return;

            if (mc.btnTutorial == null) return;

            if (!_buttonAdded) {
                if (mc.btnSkills == null || mc.btnTalisman == null) return;
                addArchipelagoButton(mc);
                _buttonAdded = true;
            }

            // Sync x every frame so the button rides the slide-in animation.
            if (_btn != null) {
                _btn.x = mc.btnTutorial.x;
            }

            // Drive scroll-knob drag in the debug options panel.
            if (_debugOptions != null && _debugOptions.isOpen) {
                _debugOptions.doEnterFrame();
            }
        }

        private function positionToast():void {
            if (_toast == null || this.stage == null) return;
            // stage[0] is [object Main] — the game's content root.
            // Multiply offsets by Main's scale so they stay in game units at any window size.
            var gameRoot:* = this.stage.getChildAt(0);
            _toast.x = gameRoot.x + TOAST_OFFSET_X * gameRoot.scaleX;
            _toast.y = gameRoot.y + TOAST_OFFSET_Y * gameRoot.scaleY;
        }

        private function onStageResize(e:Event):void {
            positionToast();
        }

        private function addArchipelagoButton(mc:*):void {
            var btnSkills:*   = mc.btnSkills;
            var btnTalisman:* = mc.btnTalisman;
            var btnTutorial:* = mc.btnTutorial;

            var stepY:Number = btnTalisman.y - btnSkills.y;

            _btn = new ArchipelagoButton(btnTutorial);
            _btn.x = btnTutorial.x;
            _btn.y = btnTutorial.y + stepY;
            _btn.visible = _debugMode;
            _btn.addEventListener(MouseEvent.CLICK, onArchipelagoClicked, false, 0, true);

            mc.addChild(_btn);
            _logger.log(MOD_NAME, "Archipelago button added at (" + _btn.x + ", " + _btn.y + ")");
        }

        private function onKeyDown(e:KeyboardEvent):void {
            if (e.keyCode == Keyboard.END && e.ctrlKey && e.shiftKey && e.altKey) {
                _debugMode = !_debugMode;
                _logger.log(MOD_NAME, "Debug mode " + (_debugMode ? "ON" : "OFF"));
                if (_btn != null) _btn.visible = _debugMode;
                // If debug mode was just turned off, close the panel if it is open.
                if (!_debugMode && _debugOptions != null && _debugOptions.isOpen) {
                    _debugOptions.close();
                }
            }
        }

        private function onArchipelagoClicked(e:MouseEvent):void {
            if (!_debugMode) return;
            if (_debugOptions == null) return;
            if (_debugOptions.isOpen) {
                _logger.log(MOD_NAME, "Closing debug options panel");
                _debugOptions.close();
            } else {
                _logger.log(MOD_NAME, "Opening debug options panel");
                _debugOptions.open();
            }
        }

        // -----------------------------------------------------------------------
        // Archipelago item handling

        /**
         * Unlock a skill by its Archipelago item ID (300-323).
         * Sets the skill tome flag and initialises the level to 0 if not yet available.
         */
        public function unlockSkill(apId:int):void {
            var gameId:int = apId - 300;
            if (gameId < 0 || gameId > 23) {
                _logger.log(MOD_NAME, "unlockSkill: invalid AP ID " + apId);
                return;
            }
            if (GV.ppd == null) {
                _logger.log(MOD_NAME, "unlockSkill: GV.ppd is null, cannot unlock skill " + apId);
                return;
            }
            GV.ppd.gainedSkillTomes[gameId] = true;
            GV.ppd.setSkillLevel(gameId, Math.max(GV.ppd.getSkillLevel(gameId), 0));
            var skillName:String = SKILL_NAMES[gameId];
            _logger.log(MOD_NAME, "Unlocked skill game_id=" + gameId + " (AP ID=" + apId + ")");
            _toast.addMessage("Skill Unlocked: " + skillName, 0xFFDDA0FF);
        }

        // -----------------------------------------------------------------------
        // Stage / tile unlock API (called by debug panel and later by AP manager)

        /**
         * Reveal the map tile for a given stage letter, and for every stage
         * whose Journey XP is already >= 0.  Called once per selector session.
         */
        private function syncMapTilesWithStages():void {
            if (GV.ppd == null || GV.stageCollection == null) return;
            var metas:Array = GV.stageCollection.stageMetas;
            for (var i:int = 0; i < metas.length; i++) {
                var meta:* = metas[i];
                if (meta == null) continue;
                if (GV.ppd.stageHighestXpsJourney[meta.id].g() >= 0) {
                    var tileIdx:int = 90 - meta.strId.charCodeAt(0);
                    if (tileIdx >= 0 && tileIdx < GV.ppd.gainedMapTiles.length) {
                        GV.ppd.gainedMapTiles[tileIdx] = true;
                    }
                }
            }
        }

        /**
         * Make a stage available (Journey XP = 0) and reveal its map tile.
         * Refreshes the selector display if it is currently open.
         */
        public function unlockStage(stageStrId:String):void {
            if (GV.ppd == null) return;
            var stageId:int = GV.getFieldId(stageStrId);
            if (stageId < 0) {
                _logger.log(MOD_NAME, "unlockStage: unknown stage " + stageStrId);
                return;
            }
            GV.ppd.stageHighestXpsJourney[stageId].s(0);
            var tileIdx:int = 90 - stageStrId.charCodeAt(0);
            if (tileIdx >= 0 && tileIdx < GV.ppd.gainedMapTiles.length) {
                GV.ppd.gainedMapTiles[tileIdx] = true;
            }
            refreshSelectorIfOpen();
            _logger.log(MOD_NAME, "Stage unlocked: " + stageStrId);
        }

        /**
         * Lock a stage (Journey XP = -1).  Hides the map tile if no other
         * stage on the same tile is still unlocked.
         */
        public function lockStage(stageStrId:String):void {
            if (GV.ppd == null) return;
            var stageId:int = GV.getFieldId(stageStrId);
            if (stageId < 0) return;
            GV.ppd.stageHighestXpsJourney[stageId].s(-1);
            // Re-evaluate tile visibility.
            var letter:String = stageStrId.charAt(0);
            var tileIdx:int = 90 - letter.charCodeAt(0);
            if (tileIdx >= 0 && tileIdx < GV.ppd.gainedMapTiles.length) {
                var anyUnlocked:Boolean = false;
                var metas:Array = GV.stageCollection.stageMetas;
                for (var i:int = 0; i < metas.length; i++) {
                    var meta:* = metas[i];
                    if (meta != null && meta.strId.charAt(0) == letter
                            && GV.ppd.stageHighestXpsJourney[meta.id].g() >= 0) {
                        anyUnlocked = true;
                        break;
                    }
                }
                GV.ppd.gainedMapTiles[tileIdx] = anyUnlocked;
            }
            refreshSelectorIfOpen();
            _logger.log(MOD_NAME, "Stage locked: " + stageStrId);
        }

        /** Returns true if the stage's Journey XP >= 0 (available or completed). */
        public function isStageUnlocked(stageStrId:String):Boolean {
            if (GV.ppd == null) return false;
            var stageId:int = GV.getFieldId(stageStrId);
            if (stageId < 0) return false;
            return GV.ppd.stageHighestXpsJourney[stageId].g() >= 0;
        }

        /** Refreshes field-token and tile visibility on the selector if it is open. */
        public function refreshSelectorIfOpen():void {
            if (GV.selectorCore == null || GV.selectorCore.renderer == null) return;
            GV.selectorCore.renderer.setMapTilesVisibility();
            GV.selectorCore.renderer.adjustFieldTokens();
        }

        /**
         * Override the scroll limits to the full world extent every frame.
         *
         * setVpLimits() in SelectorCore has a hard-coded override that collapses
         * the scroll area to just the W tile whenever W4 Journey hasn't been
         * completed.  It is called both on selector open and whenever the event
         * queue processes a level-return, so a one-shot fix is not enough.
         *
         * The constants are the global-clamp values from setVpLimits() lines 1030-1033,
         * which represent the widest bounds the game ever allows:
         *   vpXMin = 264, vpXMax = 1864, vpYMin = 330, vpYMax = 3712
         */
        private function enforceFullWorldScrollLimits():void {
            GV.selectorCore.vpXMin = 200 + 104 - 40 - 544 + 960 - 416;  // 264
            GV.selectorCore.vpXMax = 1400 - 408 + 40 - 544 + 960 + 416; // 1864
            GV.selectorCore.vpYMin = 0 + 61 - 40 + 115 - 40 - 306 + 540; // 330
            GV.selectorCore.vpYMax = 3300 - 306 + 540 + 178;              // 3712
        }

        /**
         * Unlock a battle trait by its Archipelago item ID (400-414).
         * Sets the gained flag and initialises the selected level to 0.
         */
        public function unlockBattleTrait(apId:int):void {
            var gameId:int = apId - 400;
            if (gameId < 0 || gameId > 14) {
                _logger.log(MOD_NAME, "unlockBattleTrait: invalid AP ID " + apId);
                return;
            }
            if (GV.ppd == null) {
                _logger.log(MOD_NAME, "unlockBattleTrait: GV.ppd is null, cannot unlock trait " + apId);
                return;
            }
            GV.ppd.gainedBattleTraits[gameId] = true;
            GV.ppd.selectedBattleTraitLevels[gameId].s(Math.max(GV.ppd.selectedBattleTraitLevels[gameId].g(), 0));
            var traitName:String = BATTLE_TRAIT_NAMES[gameId];
            _logger.log(MOD_NAME, "Unlocked battle trait game_id=" + gameId + " (AP ID=" + apId + ")");
            _toast.addMessage("Trait Unlocked: " + traitName, 0xFFFFAA44);
        }

        // -----------------------------------------------------------------------
        // Archipelago protocol

        /** Dispatch all packets in an incoming AP message (JSON array). */
        private function onApMessage(text:String):void {
            try {
                var packets:Array = JSON.parse(text) as Array;
                for each (var packet:Object in packets) {
                    handlePacket(packet);
                }
            } catch (e:Error) {
                _logger.log(MOD_NAME, "Failed to parse AP message: " + e.message);
                _toast.addMessage("AP parse error: " + e.message, 0xFFFF6666);
            }
        }

        private function handlePacket(p:Object):void {
            var cmd:String = p.cmd;
            _logger.log(MOD_NAME, "AP << " + cmd);

            switch (cmd) {
                case "RoomInfo":
                    _logger.log(MOD_NAME, "  seed=" + p.seed_name + "  server=" +
                        p.version.major + "." + p.version.minor + "." + p.version.build);
                    _toast.addMessage("AP: Have fun and play well!", 0xFF88DDFF);
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
                    _logger.log(MOD_NAME, "  ConnectionRefused: " + errMsg);
                    _toast.addMessage("AP refused: " + errMsg, 0xFFFF6666);
                    break;

                case "PrintJSON":
                    // Ignore chat/notifications for now
                    break;

                default:
                    _logger.log(MOD_NAME, "  (unhandled)");
            }
        }

        private function handleReceivedItems(p:Object):void {
            var index:int   = p.index;
            var items:Array = p.items as Array;
            _logger.log(MOD_NAME, "ReceivedItems index=" + index + " count=" + items.length);

            if (index == 0) {
                // Initial sync: diff AP inventory against game state and reconcile.
                syncWithAP(items);
            } else {
                // Incremental: grant only the new items in this packet.
                for each (var networkItem:Object in items) {
                    var apId:int = networkItem.item;
                    _logger.log(MOD_NAME, "  + item=" + apId + " (" + itemName(apId) + ")");
                    grantItem(apId);
                }
            }
        }

        /**
         * Diff the full AP item list against the current game state and reconcile.
         * Only changes what is actually different — preserves skill levels, trait
         * levels and any completed stage XP.
         */
        private function syncWithAP(items:Array):void {
            if (GV.ppd == null) return;

            // Build expected state from the complete AP inventory
            var apSkills:Object = {};   // gameId (0-23) → true
            var apTraits:Object = {};   // gameId (0-14) → true
            var apTokens:Object = {};   // str_id → true
            var apXpTotal:int   = 0;    // wizard-level equivalents from AP

            for each (var item:Object in items) {
                var apId:int = item.item;
                if (apId >= 300 && apId <= 323) {
                    apSkills[apId - 300] = true;
                } else if (apId >= 400 && apId <= 414) {
                    apTraits[apId - 400] = true;
                } else if (_tokenMap[String(apId)] != null) {
                    apTokens[_tokenMap[String(apId)]] = true;
                } else if (apId == 500) apXpTotal += 1;
                  else if (apId == 501) apXpTotal += 3;
                  else if (apId == 502) apXpTotal += 9;
            }

            // --- Skills ---
            var skillChanges:int = 0;
            for (var i:int = 0; i < 24; i++) {
                var shouldHaveSkill:Boolean = apSkills[i] == true;
                if (GV.ppd.gainedSkillTomes[i] != shouldHaveSkill) {
                    GV.ppd.gainedSkillTomes[i] = shouldHaveSkill;
                    if (shouldHaveSkill) {
                        GV.ppd.setSkillLevel(i, Math.max(GV.ppd.getSkillLevel(i), 0));
                    } else {
                        GV.ppd.setSkillLevel(i, -1);
                    }
                    skillChanges++;
                }
            }

            // --- Traits ---
            var traitChanges:int = 0;
            for (var j:int = 0; j < 15; j++) {
                var shouldHaveTrait:Boolean = apTraits[j] == true;
                if (GV.ppd.gainedBattleTraits[j] != shouldHaveTrait) {
                    GV.ppd.gainedBattleTraits[j] = shouldHaveTrait;
                    if (shouldHaveTrait) {
                        GV.ppd.selectedBattleTraitLevels[j].s(
                            Math.max(GV.ppd.selectedBattleTraitLevels[j].g(), 0));
                    }
                    traitChanges++;
                }
            }

            // --- Stages ---
            var stageChanges:int = 0;
            if (GV.stageCollection != null) {
                var metas:Array = GV.stageCollection.stageMetas;
                for (var k:int = 0; k < metas.length; k++) {
                    var meta:* = metas[k];
                    if (meta == null) continue;
                    var xp:int = GV.ppd.stageHighestXpsJourney[meta.id].g();
                    if (xp == 0) {
                        // Only log accessible-but-unplayed stages — these are the interesting ones
                        var inTokenStages:Boolean = _tokenStages[meta.strId] == true;
                        var shouldHaveToken:Boolean = apTokens[meta.strId] == true;
                        _logger.log(MOD_NAME, "  stage=" + meta.strId
                            + " xp=" + xp
                            + " inTokenStages=" + inTokenStages
                            + " shouldHave=" + shouldHaveToken);
                    }
                    if (!_tokenStages[meta.strId]) continue; // no AP token (W1 etc) — always accessible
                    var shouldHave:Boolean = apTokens[meta.strId] == true;
                    if (shouldHave && xp < 0) {
                        unlockStage(meta.strId);
                        stageChanges++;
                    } else if (!shouldHave && xp == 0) {
                        lockStage(meta.strId);
                        stageChanges++;
                    }
                    // xp > 0 → stage completed, leave it alone
                }
            }

            // --- XP ---
            // Store AP-granted XP in SharedObject so it's tracked separately from
            // level-earned XP. Application (what in-game effect it has) is TODO.
            _apState.data.apXpGranted = apXpTotal;
            _apState.flush();

            _logger.log(MOD_NAME, "AP sync complete — skills:" + skillChanges +
                " traits:" + traitChanges + " stages:" + stageChanges +
                " apXp:" + apXpTotal);
        }

        /** Grant an item by its AP item ID. */
        private function grantItem(apId:int):void {
            // Field token
            var strId:String = _tokenMap[String(apId)];
            if (strId != null) {
                unlockStage(strId);
                _toast.addMessage("Unlocked: " + strId + " Field Token", 0xFFFFDD55);
                return;
            }

            // Skill (300–323)
            if (apId >= 300 && apId <= 323) {
                unlockSkill(apId);
                return;
            }

            // Battle trait (400–414)
            if (apId >= 400 && apId <= 414) {
                unlockBattleTrait(apId);
                return;
            }

            // XP / filler — nothing to do in-game yet
            _logger.log(MOD_NAME, "  grantItem: no handler for AP ID " + apId);
        }

        private function handleConnected(p:Object):void {
            _logger.log(MOD_NAME, "  team=" + p.team + "  slot=" + p.slot);

            // Log all players in this multiworld
            var players:Array = p.players as Array;
            if (players) {
                for each (var player:Object in players) {
                    _logger.log(MOD_NAME, "  player: slot=" + player.slot +
                        "  name=" + player.alias + "  game=" + player.game);
                }
            }

            // Store token map and build inverse (str_id → has token)
            if (p.slot_data && p.slot_data.token_map) {
                _tokenMap = p.slot_data.token_map;
                _tokenStages = {};
                var tokenCount:int = 0;
                for (var apIdStr:String in _tokenMap) {
                    _tokenStages[_tokenMap[apIdStr]] = true;
                    tokenCount++;
                }
                _logger.log(MOD_NAME, "  token_map loaded: " + tokenCount + " entries");
            }
            _logger.log(MOD_NAME, "  goal=" + p.slot_data.goal + "  skill_placement=" + p.slot_data.skill_placement);

            var missing:Array  = p.missing_locations as Array;
            var checked:Array  = p.checked_locations as Array;
            _logger.log(MOD_NAME, "  missing_locations=" + (missing ? missing.length : "?") +
                "  checked_locations=" + (checked ? checked.length : "?"));

            _toast.addMessage("Slot connected! " + missing.length + " locations remaining", 0xFF88FF88);

            // TODO: remove — hardcoded test check for W1 (Journey=1, Bonus=501)
            sendLocationChecks([1, 501]);
        }

        /**
         * Tell the server one or more locations have been checked.
         * For a Journey completion, pass both the Journey ID and Bonus ID (journey + 500).
         */
        public function sendLocationChecks(locationIds:Array):void {
            if (_ws == null || locationIds.length == 0) return;
            var packet:String = '[{"cmd":"LocationChecks","locations":[' + locationIds.join(",") + ']}]';
            _logger.log(MOD_NAME, "AP >> LocationChecks  ids=" + locationIds.join(","));
            _ws.send(packet);
        }

        /**
         * Human-readable name for an AP item ID.
         * Returns the raw ID as a string if not recognised.
         */
        private function itemName(apId:int):String {
            if (apId >= 300 && apId <= 323) return SKILL_NAMES[apId - 300] + " Skill";
            if (apId >= 400 && apId <= 414) return BATTLE_TRAIT_NAMES[apId - 400] + " Battle Trait";
            if (apId >= 1   && apId <= 199) return "Field Token (id=" + apId + ")";
            if (apId == 500) return "Small XP Bonus";
            if (apId == 501) return "Medium XP Bonus";
            if (apId == 502) return "Large XP Bonus";
            return "Item #" + apId;
        }

        /** Send the Connect packet to identify this slot to the server. */
        private function sendConnect():void {
            var packet:String = '[{"cmd":"Connect",' +
                '"game":"GemCraft: Frostborn Wrath",' +
                '"name":"' + AP_SLOT + '",' +
                '"password":"' + AP_PASSWORD + '",' +
                '"version":{"major":0,"minor":6,"build":6,"class":"Version"},' +
                '"items_handling":7,' +
                '"tags":[],' +
                '"uuid":"gcfw-mod"}]';
            _logger.log(MOD_NAME, "AP >> Connect  slot=" + AP_SLOT);
            _ws.send(packet);
        }
    }
}
