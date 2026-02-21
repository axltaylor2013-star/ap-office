-- AchievementManager.server.lua
-- Achievement system for Wilderness MMO

print("[AchievementManager] Starting...")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for dependencies with timeouts
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)

-- Load required modules
local DataManager = require(Modules:WaitForChild("DataManager", 10))

-- Get remotes
local AchievementUnlock = Remotes:WaitForChild("AchievementUnlock", 5)
local AchievementProgress = Remotes:WaitForChild("AchievementProgress", 5)
local GetAchievements = Remotes:WaitForChild("GetAchievements", 5)

-- Validate remotes
if not AchievementUnlock or not AchievementProgress or not GetAchievements then
	warn("[AchievementManager] Missing remotes!")
	return
end

-- Achievement definitions
local ACHIEVEMENTS = {
	{
		id = "first_kill",
		name = "First Blood",
		description = "Defeat your first monster",
		category = "Combat",
		icon = "⚔️",
		check = function(player, data)
			return data.monstersKilled >= 1
		end,
		progress = function(player, data)
			return math.min(data.monstersKilled or 0, 1), 1
		end
	},
	{
		id = "level_10_skill",
		name = "Skilled",
		description = "Reach level 10 in any skill",
		category = "Skills",
		icon = "📈",
		check = function(player, data)
			for skill, level in pairs(data.skillLevels or {}) do
				if level >= 10 then
					return true
				end
			end
			return false
		end,
		progress = function(player, data)
			local maxLevel = 0
			for skill, level in pairs(data.skillLevels or {}) do
				if level > maxLevel then
					maxLevel = level
				end
			end
			return math.min(maxLevel, 10), 10
		end
	},
	{
		id = "catch_100_fish",
		name = "Master Angler",
		description = "Catch 100 fish",
		category = "Skills",
		icon = "🎣",
		check = function(player, data)
			return (data.fishCaught or 0) >= 100
		end,
		progress = function(player, data)
			return math.min(data.fishCaught or 0, 100), 100
		end
	},
	{
		id = "kill_dragon",
		name = "Dragon Slayer",
		description = "Defeat a Dragon",
		category = "Combat",
		icon = "🐉",
		check = function(player, data)
			return (data.dragonsKilled or 0) >= 1
		end,
		progress = function(player, data)
			return math.min(data.dragonsKilled or 0, 1), 1
		end
	},
	{
		id = "mine_500_ore",
		name = "Mining Expert",
		description = "Mine 500 ores",
		category = "Skills",
		icon = "⛏️",
		check = function(player, data)
			return (data.oresMined or 0) >= 500
		end,
		progress = function(player, data)
			return math.min(data.oresMined or 0, 500), 500
		end
	},
	{
		id = "chop_500_logs",
		name = "Lumberjack",
		description = "Chop 500 logs",
		category = "Skills",
		icon = "🪓",
		check = function(player, data)
			return (data.logsChopped or 0) >= 500
		end,
		progress = function(player, data)
			return math.min(data.logsChopped or 0, 500), 500
		end
	},
	{
		id = "reach_combat_50",
		name = "Warrior",
		description = "Reach combat level 50",
		category = "Combat",
		icon = "🛡️",
		check = function(player, data)
			return (data.combatLevel or 0) >= 50
		end,
		progress = function(player, data)
			return math.min(data.combatLevel or 0, 50), 50
		end
	},
	{
		id = "earn_100k_gold",
		name = "Rich",
		description = "Earn 100,000 gold",
		category = "Wealth",
		icon = "💰",
		check = function(player, data)
			return (data.totalGoldEarned or 0) >= 100000
		end,
		progress = function(player, data)
			return math.min(data.totalGoldEarned or 0, 100000), 100000
		end
	},
	{
		id = "complete_10_quests",
		name = "Quest Master",
		description = "Complete 10 quests",
		category = "Quests",
		icon = "📜",
		check = function(player, data)
			return (data.questsCompleted or 0) >= 10
		end,
		progress = function(player, data)
			return math.min(data.questsCompleted or 0, 10), 10
		end
	},
	{
		id = "craft_100_items",
		name = "Master Crafter",
		description = "Craft 100 items",
		category = "Skills",
		icon = "🔨",
		check = function(player, data)
			return (data.itemsCrafted or 0) >= 100
		end,
		progress = function(player, data)
			return math.min(data.itemsCrafted or 0, 100), 100
		end
	},
	{
		id = "kill_1000_monsters",
		name = "Monster Hunter",
		description = "Defeat 1,000 monsters",
		category = "Combat",
		icon = "👹",
		check = function(player, data)
			return (data.monstersKilled or 0) >= 1000
		end,
		progress = function(player, data)
			return math.min(data.monstersKilled or 0, 1000), 1000
		end
	},
	{
		id = "reach_total_500",
		name = "Legend",
		description = "Reach total skill level 500",
		category = "Skills",
		icon = "🌟",
		check = function(player, data)
			local total = 0
			for skill, level in pairs(data.skillLevels or {}) do
				total = total + level
			end
			return total >= 500
		end,
		progress = function(player, data)
			local total = 0
			for skill, level in pairs(data.skillLevels or {}) do
				total = total + level
			end
			return math.min(total, 500), 500
		end
	},
	{
		id = "explore_all_areas",
		name = "Explorer",
		description = "Discover all areas",
		category = "Exploration",
		icon = "🗺️",
		check = function(player, data)
			return (data.areasDiscovered or 0) >= 15
		end,
		progress = function(player, data)
			return math.min(data.areasDiscovered or 0, 15), 15
		end
	},
	{
		id = "win_50_pvp",
		name = "Champion",
		description = "Win 50 PvP battles",
		category = "PvP",
		icon = "⚔️",
		check = function(player, data)
			return (data.pvpWins or 0) >= 50
		end,
		progress = function(player, data)
			return math.min(data.pvpWins or 0, 50), 50
		end
	},
	{
		id = "cook_100_food",
		name = "Master Chef",
		description = "Cook 100 food items",
		category = "Skills",
		icon = "🍳",
		check = function(player, data)
			return (data.foodCooked or 0) >= 100
		end,
		progress = function(player, data)
			return math.min(data.foodCooked or 0, 100), 100
		end
	},
	{
		id = "fletch_100_arrows",
		name = "Fletcher",
		description = "Fletch 100 arrows",
		category = "Skills",
		icon = "🏹",
		check = function(player, data)
			return (data.arrowsFletched or 0) >= 100
		end,
		progress = function(player, data)
			return math.min(data.arrowsFletched or 0, 100), 100
		end
	},
	{
		id = "smith_100_bars",
		name = "Blacksmith",
		description = "Smith 100 metal bars",
		category = "Skills",
		icon = "🔥",
		check = function(player, data)
			return (data.barsSmithed or 0) >= 100
		end,
		progress = function(player, data)
			return math.min(data.barsSmithed or 0, 100), 100
		end
	},
	{
		id = "join_party",
		name = "Team Player",
		description = "Join a party",
		category = "Social",
		icon = "👥",
		check = function(player, data)
			return (data.partiesJoined or 0) >= 1
		end,
		progress = function(player, data)
			return math.min(data.partiesJoined or 0, 1), 1
		end
	},
	{
		id = "die_10_times",
		name = "Persistent",
		description = "Die 10 times",
		category = "Combat",
		icon = "💀",
		check = function(player, data)
			return (data.deaths or 0) >= 10
		end,
		progress = function(player, data)
			return math.min(data.deaths or 0, 10), 10
		end
	},
	{
		id = "reach_max_level",
		name = "Maxed Out",
		description = "Reach level 99 in a skill",
		category = "Skills",
		icon = "🏆",
		check = function(player, data)
			for skill, level in pairs(data.skillLevels or {}) do
				if level >= 99 then
					return true
				end
			end
			return false
		end,
		progress = function(player, data)
			local maxLevel = 0
			for skill, level in pairs(data.skillLevels or {}) do
				if level > maxLevel then
					maxLevel = level
				end
			end
			return math.min(maxLevel, 99), 99
		end
	}
}

-- Player achievement data cache
local playerAchievements = {}

-- Helper function to get player achievement data
local function getPlayerAchievementData(player)
	if not player then return nil end
	
	if not playerAchievements[player.UserId] then
		-- Load from DataManager
		local data = DataManager:GetData(player)
		playerAchievements[player.UserId] = {
			unlocked = data.achievementsUnlocked or {},
			progress = data.achievementProgress or {}
		}
	end
	
	return playerAchievements[player.UserId]
end

-- Helper function to save player achievement data
local function savePlayerAchievementData(player)
	if not player then return end
	
	local data = playerAchievements[player.UserId]
	if data then
		DataManager.UpdatePlayerData(player, {
			achievementsUnlocked = data.unlocked,
			achievementProgress = data.progress
		})
	end
end

-- Check achievements for a player
local function checkAchievements(player, eventType, eventData)
	local achievementData = getPlayerAchievementData(player)
	if not achievementData then return end
	
	local playerData = DataManager:GetData(player)
	local unlockedAny = false
	
	for _, achievement in ipairs(ACHIEVEMENTS) do
		-- Skip if already unlocked
		if not achievementData.unlocked[achievement.id] then
			-- Check if achievement is unlocked
			if achievement.check(player, playerData) then
				-- Unlock achievement
				achievementData.unlocked[achievement.id] = os.time()
				unlockedAny = true
				
				-- Fire unlock event
				AchievementUnlock:FireClient(player, {
					id = achievement.id,
					name = achievement.name,
					description = achievement.description,
					category = achievement.category,
					icon = achievement.icon
				})
				
				-- Save immediately
				savePlayerAchievementData(player)
			else
				-- Update progress
				local current, target = achievement.progress(player, playerData)
				if current > (achievementData.progress[achievement.id] or 0) then
					achievementData.progress[achievement.id] = current
					
					-- Fire progress event
					AchievementProgress:FireClient(player, {
						id = achievement.id,
						current = current,
						target = target
					})
				end
			end
		end
	end
	
	if unlockedAny then
		savePlayerAchievementData(player)
	end
end

-- Handle GetAchievements remote function
GetAchievements.OnServerInvoke = function(player)
	local achievementData = getPlayerAchievementData(player)
	local playerData = DataManager:GetData(player)
	
	local result = {}
	
	for _, achievement in ipairs(ACHIEVEMENTS) do
		local unlocked = achievementData.unlocked[achievement.id]
		local current, target = achievement.progress(player, playerData)
		
		table.insert(result, {
			id = achievement.id,
			name = achievement.name,
			description = achievement.description,
			category = achievement.category,
			icon = achievement.icon,
			unlocked = unlocked,
			unlockTime = unlocked,
			current = current,
			target = target,
			progress = target > 0 and math.floor((current / target) * 100) or 0
		})
	end
	
	return result
end

-- Hook into game events
local function setupEventHooks()
	-- Player joined
	Players.PlayerAdded:Connect(function(player)
		-- Initial achievement check
		task.wait(2) -- Wait for data to load
		checkAchievements(player, "join", {})
	end)
	
	-- Player data changed (other systems should call this)
	-- Example: when player kills a monster, levels up, etc.
end

-- Public API for other systems
local AchievementManager = {
	CheckAchievements = checkAchievements,
	GetAchievementData = getPlayerAchievementData
}

-- Clean up on player leave
Players.PlayerRemoving:Connect(function(player)
	playerAchievements[player.UserId] = nil
end)

-- Initialize
setupEventHooks()
print("[AchievementManager] Ready with " .. tostring(#ACHIEVEMENTS) .. " achievements!")

return AchievementManager