package unlockers
{
	import Bezel.Logger;
	import net.ConnectionManager;
	import tracker.CollectedState;
	import com.giab.games.gcfw.GV;

	/**
	 * Handles achievement unlocks and skill point distribution.
	 *
	 * Two flows:
	 * 1. When player collects achievement in-game: mark as collected + send check + award points
	 * 2. When receiving achievement from another player: only award points
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
		 * Unlock an achievement (when player collects it in-game).
		 * 1. Mark as collected locally
		 * 2. Submit location check to AP server
		 * 3. Award skill points
		 *
		 * @param achievementName The game's achievement name (e.g., "First Blood")
		 * @param apId The Archipelago location ID for this achievement (1000-1635)
		 * @param achievementData Achievement metadata (from achievement_map.json)
		 */
		public function unlockAchievement(
			achievementName: String,
			apId: int,
			achievementData: Object
		): void
		{
			if (!achievementName || apId < 1000 || apId > 1635)
			{
				return;
			}

			// 1. Mark as collected for logic evaluation
			_collectedState.onAchievementCollected(apId);

			// 2. Submit location check to AP server if connected
			if (_connectionManager.isConnected)
			{
				_connectionManager.sendLocationChecks([apId]);
			}

			// 3. Award skill points to this player
			awardSkillPointsForAchievement(achievementName, achievementData);

			_logger.log(_modName, "Achievement unlocked: " + achievementName + " (AP ID " + apId + ")");
		}

		/**
		 * Receive an achievement reward (when another player sends it to us).
		 * This ONLY awards skill points, does NOT mark as collected or send check.
		 *
		 * @param achievementName The game's achievement name
		 * @param apId The Archipelago item ID (1000-1635)
		 * @param achievementData Achievement metadata (from achievement_map.json)
		 */
		public function receiveAchievementReward(
			achievementName: String,
			apId: int,
			achievementData: Object
		): void
		{
			if (!achievementName || apId < 1000 || apId > 1635)
			{
				return;
			}

			// Only award skill points, DO NOT mark as collected or send check
			awardSkillPointsForAchievement(achievementName, achievementData);

			_logger.log(_modName, "Received achievement reward: " + achievementName + " (AP ID " + apId + ")");
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
			if (achInfo && achInfo.skillPoints)
			{
				var skillPoints: int = int(achInfo.skillPoints);
				awardSkillPoints(skillPoints);
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
	}
}
