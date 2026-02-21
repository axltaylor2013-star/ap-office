--[[
	PrayerManager.server.lua
	COMPLETE OVERHAUL: 30 prayers in 4 tiers with branching skill tree
	Prayer effects modify combat stats and provide special abilities
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[PrayerManager] Starting with new 30-prayer system...")

local Config = require(ReplicatedStorage.Modules.Config)
local DataManager = require(ReplicatedStorage.Modules.DataManager)

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local toggleEvent = Remotes:WaitForChild("TogglePrayer", 10)
local updateEvent = Remotes:WaitForChild("PrayerUpdate", 10)
local getDataFunc = Remotes:WaitForChild("GetPrayerData", 10)
local buryBonesEvent = Remotes:WaitForChild("BuryBones", 10)

-- Prayer definitions - 30 prayers in 4 tiers with 3 branches
local PRAYERS = {
	-- TIER 1 — NOVICE (Level 1-15) - Foundation prayers
	{id = 1,  name = "Thick Skin",           level = 1,  ppRate = 1, tier = 1, branch = "protector", effects = {defenseBonus = 0.05}, description = "+5% Defense"},
	{id = 2,  name = "Burst of Strength",    level = 1,  ppRate = 1, tier = 1, branch = "warrior",   effects = {strengthBonus = 0.05}, description = "+5% Strength"},
	{id = 3,  name = "Sharp Eye",            level = 1,  ppRate = 1, tier = 1, branch = "ranger",    effects = {rangedAccuracy = 0.05}, description = "+5% Ranged accuracy"},
	{id = 4,  name = "Rock Skin",            level = 5,  ppRate = 2, tier = 1, branch = "protector", effects = {defenseBonus = 0.10}, description = "+10% Defense", prereq = {1}},
	{id = 5,  name = "Clarity of Thought",   level = 8,  ppRate = 2, tier = 1, branch = "warrior",   effects = {allAccuracy = 0.10}, description = "+10% accuracy all styles", prereq = {2}},
	{id = 6,  name = "Mystic Will",          level = 12, ppRate = 2, tier = 1, branch = "ranger",    effects = {allStats = 0.05}, description = "+5% all combat stats", prereq = {3}},

	-- TIER 2 — ACOLYTE (Level 16-35) - Intermediate prayers
	{id = 7,  name = "Superhuman Strength",  level = 16, ppRate = 3, tier = 2, branch = "warrior",   effects = {strengthBonus = 0.15}, description = "+15% Strength", prereq = {2}},
	{id = 8,  name = "Improved Reflexes",    level = 18, ppRate = 3, tier = 2, branch = "protector", effects = {defenseBonus = 0.15}, description = "+15% Defense", prereq = {4}},
	{id = 9,  name = "Hawk Eye",             level = 20, ppRate = 3, tier = 2, branch = "ranger",    effects = {rangedBonus = 0.15}, description = "+15% Ranged", prereq = {3}},
	{id = 10, name = "Steel Skin",           level = 22, ppRate = 4, tier = 2, branch = "protector", effects = {defenseBonus = 0.20}, description = "+20% Defense", prereq = {8}},
	{id = 11, name = "Ultimate Strength",    level = 25, ppRate = 4, tier = 2, branch = "warrior",   effects = {strengthBonus = 0.20}, description = "+20% Strength", prereq = {7}},
	{id = 12, name = "Eagle Eye",            level = 28, ppRate = 4, tier = 2, branch = "ranger",    effects = {rangedBonus = 0.20}, description = "+20% Ranged", prereq = {9}},
	{id = 13, name = "Rapid Heal",           level = 30, ppRate = 3, tier = 2, branch = "protector", effects = {hpRegenBoost = 2.0}, description = "2x HP regeneration", prereq = {8}},
	{id = 14, name = "Rapid Restore",        level = 35, ppRate = 2, tier = 2, branch = "protector", effects = {ppRegenBoost = 2.0}, description = "2x PP regeneration", prereq = {13}},

	-- TIER 3 — PRIEST (Level 36-60) - Advanced prayers with special effects
	{id = 15, name = "Protect from Melee",   level = 36, ppRate = 6, tier = 3, branch = "protector", effects = {meleeProt = 0.50}, description = "Block 50% melee damage", prereq = {10}},
	{id = 16, name = "Protect from Ranged",  level = 38, ppRate = 6, tier = 3, branch = "protector", effects = {rangedProt = 0.50}, description = "Block 50% ranged damage", prereq = {10}},
	{id = 17, name = "Protect from Magic",   level = 40, ppRate = 6, tier = 3, branch = "protector", effects = {magicProt = 0.50}, description = "Block 50% magic damage", prereq = {10}},
	{id = 18, name = "Retribution",          level = 42, ppRate = 3, tier = 3, branch = "warrior",   effects = {retribution = true}, description = "On death, deal 25% max HP as AoE damage", prereq = {11}},
	{id = 19, name = "Redemption",           level = 45, ppRate = 4, tier = 3, branch = "protector", effects = {redemption = true}, description = "Auto-heal 25% HP when below 10%", prereq = {15}},
	{id = 20, name = "Smite",                level = 48, ppRate = 5, tier = 3, branch = "warrior",   effects = {smite = true}, description = "Drain enemy prayer on hit", prereq = {18}},
	{id = 21, name = "Holy Strength",        level = 52, ppRate = 7, tier = 3, branch = "warrior",   effects = {strengthBonus = 0.25, defenseBonus = 0.10}, description = "+25% Strength, +10% Defense", prereq = {11}},
	{id = 22, name = "Divine Aim",           level = 55, ppRate = 7, tier = 3, branch = "ranger",    effects = {rangedBonus = 0.25, allAccuracy = 0.10}, description = "+25% Ranged, +10% accuracy", prereq = {12}},

	-- TIER 4 — HIGH PRIEST (Level 61-99) - Master tier prayers
	{id = 23, name = "Chivalry",             level = 61, ppRate = 8,  tier = 4, branch = "warrior",   effects = {strengthBonus = 0.20, defenseBonus = 0.20, allAccuracy = 0.15}, description = "+20% Strength, +20% Defense, +15% accuracy", prereq = {21}},
	{id = 24, name = "Piety",                level = 70, ppRate = 10, tier = 4, branch = "warrior",   effects = {strengthBonus = 0.25, defenseBonus = 0.25, allAccuracy = 0.20}, description = "+25% Strength, +25% Defense, +20% accuracy", prereq = {23}},
	{id = 25, name = "Rigour",               level = 74, ppRate = 10, tier = 4, branch = "ranger",    effects = {rangedBonus = 0.25, defenseBonus = 0.25}, description = "+25% Ranged, +25% Defense", prereq = {22}},
	{id = 26, name = "Augury",               level = 78, ppRate = 12, tier = 4, branch = "ranger",    effects = {allStats = 0.25, allAccuracy = 0.15}, description = "+25% all stats, +15% accuracy", prereq = {25}},
	{id = 27, name = "Soul Split",           level = 82, ppRate = 12, tier = 4, branch = "protector", effects = {soulSplit = true}, description = "Heal 10% of damage dealt", prereq = {19}},
	{id = 28, name = "Turmoil",              level = 86, ppRate = 15, tier = 4, branch = "warrior",   effects = {strengthBonus = 0.30, defenseBonus = 0.30, turmoil = true}, description = "+30% Strength, +30% Defense, drain enemy stats", prereq = {24}},
	{id = 29, name = "Wrath",                level = 90, ppRate = 5,  tier = 4, branch = "warrior",   effects = {wrath = true}, description = "On death, massive AoE explosion", prereq = {28}},
	{id = 30, name = "Divine Shield",        level = 95, ppRate = 20, tier = 4, branch = "protector", effects = {divineShield = true}, description = "Reduce ALL damage by 40% for 30 seconds, then 5 min cooldown", prereq = {27}},
}

-- Create lookup tables
local prayerById = {}
local prayerByName = {}
for _, p in ipairs(PRAYERS) do
	prayerById[p.id] = p
	prayerByName[p.name] = p
end

-- Per-player state
local playerPrayers = {} -- [player] = {active = {id1=true, id2=true}, pp = 100, lastTick = tick()}
local playerCooldowns = {} -- [player] = {divineShield = endTime}

-- Prayer point system - Max PP = 10 + Prayer Level
local function getMaxPrayerPoints(player)
	local data = DataManager:GetData(player)
	if not data then return 10 end
	local prayerLevel = Config.GetLevelFromXP(data.Skills.Prayer or 0)
	return 10 + prayerLevel
end

-- Get current prayer level
local function getPrayerLevel(player)
	local data = DataManager:GetData(player)
	if not data then return 1 end
	return Config.GetLevelFromXP(data.Skills.Prayer or 0)
end

-- Check if player meets prayer prerequisites
local function canUsePrayer(player, prayerId)
	local prayer = prayerById[prayerId]
	if not prayer then return false end
	
	-- Level requirement
	local playerLevel = getPrayerLevel(player)
	if playerLevel < prayer.level then return false end
	
	-- Prerequisites
	if prayer.prereq then
		local playerState = playerPrayers[player]
		if not playerState then return false end
		
		for _, reqId in ipairs(prayer.prereq) do
			-- Check if player has access to prerequisite (either active or previously unlocked)
			local reqPrayer = prayerById[reqId]
			if reqPrayer and playerLevel < reqPrayer.level then
				return false
			end
		end
	end
	
	return true
end

-- Calculate total PP drain rate
local function getTotalPPDrain(player)
	local playerState = playerPrayers[player]
	if not playerState or not playerState.active then return 0 end
	
	local totalDrain = 0
	for prayerId, active in pairs(playerState.active) do
		if active then
			local prayer = prayerById[prayerId]
			if prayer then
				totalDrain = totalDrain + prayer.ppRate
			end
		end
	end
	
	-- Rapid Restore doubles PP regen, which effectively halves drain
	if playerState.active[14] then -- Rapid Restore
		totalDrain = totalDrain * 0.5
	end
	
	return totalDrain
end

-- Apply prayer effects to player
local function applyPrayerEffects(player)
	local playerState = playerPrayers[player]
	if not playerState or not playerState.active then return end
	
	-- This would integrate with CombatManager to actually modify stats
	-- For now, we'll just store the effects for other systems to query
	local totalEffects = {
		strengthBonus = 0, defenseBonus = 0, rangedBonus = 0,
		allAccuracy = 0, allStats = 0, hpRegenBoost = 1, ppRegenBoost = 1,
		meleeProt = 0, rangedProt = 0, magicProt = 0,
		retribution = false, redemption = false, smite = false,
		soulSplit = false, turmoil = false, wrath = false, divineShield = false
	}
	
	-- Combine effects from all active prayers
	for prayerId, active in pairs(playerState.active) do
		if active then
			local prayer = prayerById[prayerId]
			if prayer then
				for effect, value in pairs(prayer.effects) do
					if type(value) == "number" then
						-- Additive for number effects
						if totalEffects[effect] then
							totalEffects[effect] = totalEffects[effect] + value
						end
					else
						-- Boolean effects
						totalEffects[effect] = value
					end
				end
			end
		end
	end
	
	playerState.effects = totalEffects
end

-- Initialize player prayer state
local function initializePlayer(player)
	playerPrayers[player] = {
		active = {},
		pp = getMaxPrayerPoints(player),
		lastTick = tick(),
		effects = {}
	}
	playerCooldowns[player] = {}
end

-- Handle prayer toggle
toggleEvent.OnServerEvent:Connect(function(player, prayerId)
	if not playerPrayers[player] then
		initializePlayer(player)
	end
	
	local playerState = playerPrayers[player]
	local prayer = prayerById[prayerId]
	
	if not prayer then
		warn("[PrayerManager] Unknown prayer ID:", prayerId)
		return
	end
	
	-- Check if player can use this prayer
	if not canUsePrayer(player, prayerId) then
		print("[PrayerManager] Player cannot use prayer:", prayer.name)
		return
	end
	
	-- Check Divine Shield cooldown
	if prayer.effects.divineShield and playerCooldowns[player].divineShield and 
	   playerCooldowns[player].divineShield > tick() then
		print("[PrayerManager] Divine Shield on cooldown")
		return
	end
	
	-- Toggle the prayer
	local wasActive = playerState.active[prayerId] or false
	playerState.active[prayerId] = not wasActive
	
	print("[PrayerManager] " .. player.Name .. " " .. (wasActive and "disabled" or "enabled") .. " " .. prayer.name)
	
	-- Handle special activation effects
	if not wasActive then -- Just activated
		if prayer.effects.divineShield then
			-- Start Divine Shield duration and cooldown
			task.delay(30, function() -- 30 second duration
				if playerState.active[prayerId] then
					playerState.active[prayerId] = false
					playerCooldowns[player].divineShield = tick() + 300 -- 5 minute cooldown
					applyPrayerEffects(player)
					updateEvent:FireClient(player)
				end
			end)
		end
	end
	
	-- Apply new effects
	applyPrayerEffects(player)
	
	-- Notify client
	updateEvent:FireClient(player)
end)

-- Get prayer data for client
getDataFunc.OnServerInvoke = function(player)
	if not playerPrayers[player] then
		initializePlayer(player)
	end
	
	local playerState = playerPrayers[player]
	local playerLevel = getPrayerLevel(player)
	local maxPP = getMaxPrayerPoints(player)
	local totalDrain = getTotalPPDrain(player)
	
	-- Build prayer availability
	local availablePrayers = {}
	for _, prayer in ipairs(PRAYERS) do
		availablePrayers[prayer.id] = {
			id = prayer.id,
			name = prayer.name,
			level = prayer.level,
			ppRate = prayer.ppRate,
			tier = prayer.tier,
			branch = prayer.branch,
			description = prayer.description,
			prereq = prayer.prereq,
			canUse = canUsePrayer(player, prayer.id),
			active = playerState.active[prayer.id] or false
		}
	end
	
	return {
		prayers = availablePrayers,
		currentPP = math.floor(playerState.pp),
		maxPP = maxPP,
		ppDrainRate = totalDrain,
		playerLevel = playerLevel,
		effects = playerState.effects,
		cooldowns = playerCooldowns[player]
	}
end

-- Handle bone burying for Prayer XP
buryBonesEvent.OnServerEvent:Connect(function(player, boneName)
	local boneXP = {
		["Bones"] = 10,
		["Big Bones"] = 30,
		["Dragon Bones"] = 100
	}
	
	local xp = boneXP[boneName] or 10
	
	-- Check if player has the bones
	local removed = DataManager.RemoveItem(player, boneName, 1)
	if removed then
		-- Give Prayer XP
		DataManager.AddSkillXP(player, "Prayer", xp)
		print("[PrayerManager] " .. player.Name .. " buried " .. boneName .. " for " .. xp .. " Prayer XP")
		
		-- Update max PP if leveled up
		if playerPrayers[player] then
			playerPrayers[player].pp = math.min(playerPrayers[player].pp, getMaxPrayerPoints(player))
		end
	end
end)

-- Prayer point regeneration and drain system
local lastUpdateTime = tick()
RunService.Heartbeat:Connect(function()
	local currentTime = tick()
	local deltaTime = currentTime - lastUpdateTime
	lastUpdateTime = currentTime
	
	-- Update every 6 seconds (10 times per minute)
	if deltaTime < 6 then return end
	
	for player, playerState in pairs(playerPrayers) do
		if not player.Parent then
			-- Clean up disconnected players
			playerPrayers[player] = nil
			playerCooldowns[player] = nil
			continue
		end
		
		local totalDrain = getTotalPPDrain(player)
		local maxPP = getMaxPrayerPoints(player)
		
		if totalDrain > 0 then
			-- Drain PP (rate is per minute, so divide by 10 for 6-second intervals)
			playerState.pp = playerState.pp - (totalDrain / 10)
			
			-- Disable prayers if out of PP
			if playerState.pp <= 0 then
				playerState.pp = 0
				playerState.active = {}
				applyPrayerEffects(player)
				updateEvent:FireClient(player)
				print("[PrayerManager] " .. player.Name .. " ran out of Prayer Points")
			end
		else
			-- Regenerate PP when no prayers active (1 PP per 10 seconds base)
			local regenRate = 0.6 -- 0.6 PP per 6 seconds = 6 PP per minute
			if playerState.active[14] then -- Rapid Restore
				regenRate = regenRate * 2
			end
			
			playerState.pp = math.min(playerState.pp + regenRate, maxPP)
		end
	end
end)

-- Player initialization
local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function()
		task.wait(2) -- Wait for character to fully load
		initializePlayer(player)
	end)
end

-- Existing players
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- New players
Players.PlayerAdded:Connect(onPlayerAdded)

-- Cleanup on player leaving
Players.PlayerRemoving:Connect(function(player)
	playerPrayers[player] = nil
	playerCooldowns[player] = nil
end)

print("[PrayerManager] New 30-prayer system ready!")
