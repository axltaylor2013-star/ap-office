-- LeaderboardManager.server.lua
-- Leaderboard system for Wilderness MMO

print("[LeaderboardManager] Starting...")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for dependencies with timeouts
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)

-- Load required modules
local DataManager = require(Modules:WaitForChild("DataManager", 10))

-- Get remotes
local GetLeaderboard = Remotes:WaitForChild("GetLeaderboard", 5)
local LeaderboardUpdate = Remotes:WaitForChild("LeaderboardUpdate", 5)

-- Validate remotes
if not GetLeaderboard or not LeaderboardUpdate then
	warn("[LeaderboardManager] Missing remotes!")
	return
end

-- Leaderboard categories
local CATEGORIES = {
	"Total Level",
	"Monsters Killed", 
	"Gold",
	"Combat Level",
	"Mining",
	"Woodcutting",
	"Fishing",
	"Crafting",
	"Smithing",
	"Fletching",
	"Cooking"
}

-- Cache for leaderboard data
local leaderboardCache = {}
local lastUpdateTime = 0
local UPDATE_INTERVAL = 60 -- seconds

-- Helper function to calculate total level
local function calculateTotalLevel(playerData)
	local total = 0
	for skill, level in pairs(playerData.skillLevels or {}) do
		total = total + level
	end
	return total
end

-- Helper function to get player stats for leaderboard
local function getPlayerStats(player)
	if not player then return nil end
	
	local data = DataManager:GetData(player)
	if not data then return nil end
	
	return {
		userId = player.UserId,
		name = player.Name,
		totalLevel = calculateTotalLevel(data),
		monstersKilled = data.monstersKilled or 0,
		gold = data.gold or 0,
		combatLevel = data.combatLevel or 0,
		mining = data.skillLevels and data.skillLevels.Mining or 0,
		woodcutting = data.skillLevels and data.skillLevels.Woodcutting or 0,
		fishing = data.skillLevels and data.skillLevels.Fishing or 0,
		crafting = data.skillLevels and data.skillLevels.Crafting or 0,
		smithing = data.skillLevels and data.skillLevels.Smithing or 0,
		fletching = data.skillLevels and data.skillLevels.Fletching or 0,
		cooking = data.skillLevels and data.skillLevels.Cooking or 0
	}
end

-- Function to update leaderboard cache
local function updateLeaderboardCache()
	local allStats = {}
	
	-- Get stats for all players
	for _, player in ipairs(Players:GetPlayers()) do
		local stats = getPlayerStats(player)
		if stats then
			table.insert(allStats, stats)
		end
	end
	
	-- Sort by each category
	for _, category in ipairs(CATEGORIES) do
		local sorted = {}
		
		for _, stats in ipairs(allStats) do
			table.insert(sorted, stats)
		end
		
		-- Sort based on category
		if category == "Total Level" then
			table.sort(sorted, function(a, b)
				return a.totalLevel > b.totalLevel
			end)
		elseif category == "Monsters Killed" then
			table.sort(sorted, function(a, b)
				return a.monstersKilled > b.monstersKilled
			end)
		elseif category == "Gold" then
			table.sort(sorted, function(a, b)
				return a.gold > b.gold
			end)
		elseif category == "Combat Level" then
			table.sort(sorted, function(a, b)
				return a.combatLevel > b.combatLevel
			end)
		elseif category == "Mining" then
			table.sort(sorted, function(a, b)
				return a.mining > b.mining
			end)
		elseif category == "Woodcutting" then
			table.sort(sorted, function(a, b)
				return a.woodcutting > b.woodcutting
			end)
		elseif category == "Fishing" then
			table.sort(sorted, function(a, b)
				return a.fishing > b.fishing
			end)
		elseif category == "Crafting" then
			table.sort(sorted, function(a, b)
				return a.crafting > b.crafting
			end)
		elseif category == "Smithing" then
			table.sort(sorted, function(a, b)
				return a.smithing > b.smithing
			end)
		elseif category == "Fletching" then
			table.sort(sorted, function(a, b)
				return a.fletching > b.fletching
			end)
		elseif category == "Cooking" then
			table.sort(sorted, function(a, b)
				return a.cooking > b.cooking
			end)
		end
		
		-- Limit to top 100
		local limited = {}
		for i = 1, math.min(100, #sorted) do
			table.insert(limited, sorted[i])
		end
		
		leaderboardCache[category] = limited
	end
	
	lastUpdateTime = os.time()
	print("[LeaderboardManager] Cache updated at " .. tostring(lastUpdateTime))
end

-- Function to get leaderboard data
local function getLeaderboardData(category, limit)
	-- Check if cache needs update
	if os.time() - lastUpdateTime > UPDATE_INTERVAL then
		updateLeaderboardCache()
	end
	
	local data = leaderboardCache[category] or {}
	
	-- Apply limit
	if limit and limit > 0 then
		local limited = {}
		for i = 1, math.min(limit, #data) do
			table.insert(limited, data[i])
		end
		return limited
	end
	
	return data
end

-- Handle GetLeaderboard remote function
GetLeaderboard.OnServerInvoke = function(player, category, limit)
	if not category or not table.find(CATEGORIES, category) then
		category = "Total Level"
	end
	
	limit = limit or 100
	if limit > 100 then limit = 100 end
	
	local data = getLeaderboardData(category, limit)
	
	-- Add player's rank if they're not in top list
	local playerStats = getPlayerStats(player)
	if playerStats then
		local allData = getLeaderboardData(category, 0) -- Get all for ranking
		local playerRank = nil
		
		for i, stats in ipairs(allData) do
			if stats.userId == player.UserId then
				playerRank = i
				break
			end
		end
		
		-- If player not in top 100, find their rank
		if not playerRank then
			playerRank = #allData + 1
			for i, stats in ipairs(allData) do
				local playerValue = playerStats[category:gsub(" ", ""):lower()] or 0
				local otherValue = stats[category:gsub(" ", ""):lower()] or 0
				
				if category == "Total Level" then
					playerValue = playerStats.totalLevel
					otherValue = stats.totalLevel
				elseif category == "Monsters Killed" then
					playerValue = playerStats.monstersKilled
					otherValue = stats.monstersKilled
				elseif category == "Gold" then
					playerValue = playerStats.gold
					otherValue = stats.gold
				elseif category == "Combat Level" then
					playerValue = playerStats.combatLevel
					otherValue = stats.combatLevel
				end
				
				if playerValue > otherValue then
					playerRank = i
					break
				end
			end
		end
		
		return {
			category = category,
			data = data,
			playerRank = playerRank,
			playerStats = playerStats,
			totalPlayers = #allData,
			lastUpdate = lastUpdateTime
		}
	end
	
	return {
		category = category,
		data = data,
		playerRank = nil,
		playerStats = nil,
		totalPlayers = #data,
		lastUpdate = lastUpdateTime
	}
end

-- Function to force update (for other systems)
local function forceUpdate()
	updateLeaderboardCache()
	
	-- Notify all players
	for _, player in ipairs(Players:GetPlayers()) do
		LeaderboardUpdate:FireClient(player, {
			timestamp = lastUpdateTime
		})
	end
end

-- Periodic updates
task.spawn(function()
	while true do
		task.wait(UPDATE_INTERVAL)
		forceUpdate()
	end
end)

-- Update when player joins/leaves
Players.PlayerAdded:Connect(function(player)
	-- Small delay to let player data load
	task.wait(2)
	forceUpdate()
end)

Players.PlayerRemoving:Connect(function(player)
	forceUpdate()
end)

-- Initial update
task.wait(5) -- Wait for players to load
updateLeaderboardCache()

print("[LeaderboardManager] Ready with " .. tostring(#CATEGORIES) .. " categories!")

-- Public API
return {
	ForceUpdate = forceUpdate,
	GetLeaderboardData = getLeaderboardData,
	GetCategories = function() return CATEGORIES end
}