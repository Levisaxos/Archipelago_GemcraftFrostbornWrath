package unlockers
{
	import Bezel.Logger;
	import net.ConnectionManager;
	import tracker.CollectedState;
	import com.giab.games.gcfw.GV;

	/**
	 * Handles achievement unlocks and skill point distribution.
	 *
	 * New flow: achievements queue to dropIcons and are processed at level end.
	 *
	 * Two cases:
	 * 1. When player collects achievement in-game: queue (mark + send check + points) to dropIcons
	 * 2. When receiving achievement from another player: queue (points) to dropIcons
	 */
	public class AchievementUnlocker
	{
		private var _logger: Logger;
		private var _modName: String;
		private var _connectionManager: ConnectionManager;
		private var _collectedState: CollectedState;

		public function AchievementUnlocker(
			logger: Logger,
			modName: String,
			connectionManager: ConnectionManager,
			collectedState: CollectedState
		): void
		{
			_logger = logger;
			_modName = modName;
			_connectionManager = connectionManager;
			_collectedState = collectedState;
		}

		/**
		 * Queue an achievement unlock (when player collects it in-game).
		 * Queues TWO drops:
		 * 1. AP_ACHIEVEMENT_COLLECTED - marks it collected + sends check
		 * 2. AP_ACHIEVEMENT_SKILL - awards skill points
		 * Both are processed at level end.
		 *
		 * @param achievementName The game's achievement name (e.g., "First Blood")
		 * @param apId The Archipelago location ID for this achievement (2000-2636)
		 * @param achievementData Achievement metadata (from achievement_map.json)
		 */
		public function unlockAchievement(
			achievementName: String,
			apId: int,
			achievementData: Object
		): void
		{
			if (!achievementName || apId < 2000 || apId > 2636)
			{
				return;
			}

			_collectedState.onAchievementCollected(apId);
			if (_connectionManager.isConnected) {
				_connectionManager.sendLocationChecks([apId]);
			}
			awardSkillPointsForAchievement(achievementName, achievementData);
			_logger.log(_modName, "Sent achievement check: " + achievementName + "  apId=" + apId);
		}

		/**
		 * Receive an achievement reward (when another player sends it to us).
		 * If in-game (ending exists): queues to dropIcons for processing at level end
		 * If not in-game (ending null): calls unlocker directly (e.g., during sync)
		 *
		 * @param achievementName The game's achievement name
		 * @param apId The Archipelago item ID (2000-2636)
		 * @param achievementData Achievement metadata (from achievement_map.json)
		 */
		public function receiveAchievementReward(
			achievementName: String,
			apId: int,
			achievementData: Object
		): void
		{
			if (!achievementName || apId < 2000 || apId > 2636)
			{
				return;
			}

			// Get the ending object (only exists during gameplay)
			var ending:Object = GV.ingameController != null && GV.ingameController.core != null
				? GV.ingameController.core.ending
				: null;

			if (ending != null) {
				// In-game: queue to dropIcons for level-end processing
				var rewardType:String = _parseAchievementRewardType(achievementName, achievementData);
				var meta:Object = {
					achievementName: achievementName,
					achievementData: achievementData
				};

				NormalProgressionBlocker.addApDropToIcons(ending, rewardType, apId, meta);
				_logger.log(_modName, "Queued achievement reward: " + achievementName + " (AP ID " + apId + ", type: " + rewardType + ")");
			} else {
				// Not in-game (e.g., full sync): award points immediately
				awardSkillPointsForAchievement(achievementName, achievementData);
				_logger.log(_modName, "Received achievement reward (offline): " + achievementName + " (AP ID " + apId + ")");
			}
		}

		/**
		 * Award skill points for an achievement.
		 * Helper method used by both unlockAchievement and receiveAchievementReward.
		 *
		 * @param achievementName The game's achievement name
		 * @param achievementData Achievement metadata (from achievement_map.json)
		 */
		private function awardSkillPointsForAchievement(
			achievementName: String,
			achievementData: Object
		): void
		{
			if (!achievementData)
			{
				return;
			}

			var achInfo: Object = achievementData[achievementName];
			if (achInfo && achInfo.reward)
			{
				var reward:String = String(achInfo.reward);
				if (reward.indexOf("skillPoints:") == 0)
				{
					var skillPoints:int = int(reward.substring(12));
					awardSkillPoints(skillPoints);
				}
			}
		}

		/**
		 * Award skill points to the player.
		 * Adds the points to GV.ppd.skillPtsFromLoot (an ENumber with .g()/.s() methods).
		 *
		 * @param points Number of skill points to award
		 */
		private function awardSkillPoints(points: int): void
		{
			if (points <= 0 || GV.ppd == null)
			{
				return;
			}

			try {
				// Award skill points using the game's ENumber getter/setter pattern
				// GV.ppd.skillPtsFromLoot is an ENumber with .g() (get) and .s() (set) methods
				var currentPoints:int = int(GV.ppd.skillPtsFromLoot.g());
				GV.ppd.skillPtsFromLoot.s(currentPoints + points);
				_logger.log(_modName, "Awarded " + points + " skill points (total: " + (currentPoints + points) + ")");
			} catch (err:Error) {
				_logger.log(_modName, "Error awarding skill points: " + err.message);
			}
		}

		// -----------------------------------------------------------------------
		// Public methods for dropIcons processor

		/**
		 * Mark achievement as collected and send location check to AP.
		 * Called by dropIcons processor when processing AP_ACHIEVEMENT_COLLECTED drops.
		 *
		 * @param apId The achievement AP ID (2000-2636)
		 */
		public function markCollectedAndSendCheck(apId: int): void
		{
			if (apId < 2000 || apId > 2636) return;

			// Mark as collected for logic evaluation
			_collectedState.onAchievementCollected(apId);

			// Send location check to AP server if connected
			if (_connectionManager.isConnected)
			{
				_connectionManager.sendLocationChecks([apId]);
			}

			_logger.log(_modName, "Sent: achievement check  apId=" + apId);
		}

		/**
		 * Public wrapper for awardSkillPointsForAchievement (called by dropIcons processor).
		 * Called when processing achievement reward drops.
		 *
		 * @param achievementName The game's achievement name
		 * @param achievementData Achievement metadata
		 */
		public function awardSkillPointsPublic(achievementName: String, achievementData: Object): void
		{
			awardSkillPointsForAchievement(achievementName, achievementData);
		}

		/**
		 * Parse the reward type from achievement metadata.
		 * Returns the appropriate AP_ACHIEVEMENT_* drop type.
		 *
		 * @param achievementName The game's achievement name
		 * @param achievementData Achievement metadata
		 * @return Drop type constant (e.g., AP_ACHIEVEMENT_SKILL)
		 */
		private function _parseAchievementRewardType(achievementName: String, achievementData: Object): String
		{
			// Default to skill reward (most common)
			// In the future, this could parse different reward types from metadata
			return NormalProgressionBlocker.AP_ACHIEVEMENT_SKILL;
		}
	}
}
