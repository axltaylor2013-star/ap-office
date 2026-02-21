-- FishingManager.server.lua
-- Server-side fishing system with error handling

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Wait for dependencies with timeouts
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local Modules = ReplicatedStorage:WaitForChild("Modules", 5)

-- Load ErrorHandler first for error handling
local ErrorHandler
local itemDatabaseSuccess, ItemDatabase = pcall(function()
	return require(Modules:WaitForChild("ItemDatabase", 5))
end)

local dataManagerSuccess, DataManager = pcall(function()
	return require(Modules:WaitForChild("DataManager", 5))
end)

-- Initialize ErrorHandler
local errorHandlerSuccess, errorHandlerResult = pcall(function()
	return require(Modules:WaitForChild("ErrorHandler", 5))
end)

if errorHandlerSuccess then
	ErrorHandler = errorHandlerResult
else
	-- Fallback ErrorHandler
	ErrorHandler = {
		LogWarning = function(self, msg, data) warn(tostring(msg)) end,
		LogError = function(self, msg, data) warn(tostring(msg)) end,
		ValidateNotNil = function(self, val, ctx, fallback) return val or fallback end,
		LogDebug = function(self, msg, data) warn(tostring(msg)) end,
		LogInfo = function(self, msg, data) warn(tostring(msg)) end
	}
end

-- Validate dependencies
if not itemDatabaseSuccess then
	ErrorHandler:LogError("Failed to load ItemDatabase", {error = ItemDatabase})
	ItemDatabase = {Items = {}}
else
	ItemDatabase = ItemDatabase.Items or {}
end

if not dataManagerSuccess then
	ErrorHandler:LogWarning("Failed to load DataManager, using fallback", {error = DataManager})
	DataManager = {
		GetData = function(player) 
			return {skills = {Fishing = 1}, inventory = {}, equipment = {Tool = ""}}
		end,
		UpdateData = function() return true end
	}
end

-- RemoteEvents with validation
local StartFishingEvent = Remotes and Remotes:WaitForChild("StartFishing", 5)
local FishingProgressEvent = Remotes and Remotes:WaitForChild("FishingProgress", 5)
local FishingCompleteEvent = Remotes and Remotes:WaitForChild("FishingComplete", 5)
local FishCaughtEvent = Remotes and Remotes:WaitForChild("FishCaught", 5)
local InventoryUpdateEvent = Remotes and Remotes:WaitForChild("InventoryUpdate", 5)

-- Validate remotes
if not StartFishingEvent then
	ErrorHandler:LogError("StartFishing remote not found")
	return
end

-- Fishing configuration
local FISHING_CONFIG = {
	-- Fish types with their properties
	FishTypes = {
		["Shrimp"] = {
			id = "shrimp",
			levelReq = 1,
			xp = 15,
			baseCatchTime = 3.0, -- seconds
			rarity = "common",
			value = 3
		},
		["Trout"] = {
			id = "trout",
			levelReq = 20,
			xp = 35,
			baseCatchTime = 4.0,
			rarity = "uncommon",
			value = 10
		},
		["Salmon"] = {
			id = "salmon",
			levelReq = 30,
			xp = 45,
			baseCatchTime = 4.5,
			rarity = "uncommon",
			value = 15
		},
		["Lobster"] = {
			id = "lobster",
			levelReq = 40,
			xp = 60,
			baseCatchTime = 5.0,
			rarity = "rare",
			value = 40
		},
		["Swordfish"] = {
			id = "swordfish",
			levelReq = 50,
			xp = 75,
			baseCatchTime = 5.5,
			rarity = "rare",
			value = 60
		},
		["Shark"] = {
			id = "shark",
			levelReq = 70,
			xp = 110,
			baseCatchTime = 6.5,
			rarity = "epic",
			value = 150
		}
	},
	
	-- Fishing rod types with effectiveness
	FishingRods = {
		["fishing_rod"] = {effectiveness = 1.0, levelReq = 1},
		["fly_fishing_rod"] = {effectiveness = 1.3, levelReq = 20},
		["harpoon"] = {effectiveness = 1.5, levelReq = 35},
		["dragon_harpoon"] = {effectiveness = 2.0, levelReq = 60}
	},
	
	-- Fishing spot types (could be tied to location)
	FishingSpots = {
		["River"] = {availableFish = {"Shrimp", "Trout", "Salmon"}},
		["Ocean"] = {availableFish = {"Lobster", "Swordfish", "Shark"}},
		["Lake"] = {availableFish = {"Trout", "Salmon"}}
	}
}

-- Active fishing sessions
local activeFishingSessions = {}

-- Helper: Get player's fishing level
local function getFishingLevel(player)
	local playerData = DataManager:GetData(player)
	return playerData.skills.Fishing or 1
end

-- Helper: Get equipped fishing rod
local function getEquippedRod(player)
	local playerData = DataManager:GetData(player)
	local toolId = playerData.equipment.Tool or ""
	
	if toolId == "" then
		return nil
	end
	
	-- Check if it's a fishing rod
	local toolData = ItemDatabase[toolId]
	if toolData and toolData.type == "Tool" then
		-- Check if it's a fishing tool (rod, harpoon, etc.)
		local rodNames = {"fishing_rod", "fly_fishing_rod", "harpoon", "dragon_harpoon"}
		for _, rodName in ipairs(rodNames) do
			if toolId == rodName then
				return toolId
			end
		end
	end
	
	return nil
end

-- Helper: Determine available fish based on location and level
local function getAvailableFish(player, fishingSpotType)
	local fishingLevel = getFishingLevel(player)
	local availableFish = {}
	
	-- Get fish for this spot type
	local spotConfig = FISHING_CONFIG.FishingSpots[fishingSpotType or "River"]
	if not spotConfig then
		spotConfig = FISHING_CONFIG.FishingSpots["River"] -- Default to river
	end
	
	-- Filter by level requirement
	for _, fishName in ipairs(spotConfig.availableFish) do
		local fishConfig = FISHING_CONFIG.FishTypes[fishName]
		if fishConfig and fishingLevel >= fishConfig.levelReq then
			table.insert(availableFish, fishName)
		end
	end
	
	return availableFish
end

-- Helper: Select random fish to catch
local function selectFishToCatch(availableFish, fishingLevel, rodEffectiveness)
	if #availableFish == 0 then
		return nil
	end
	
	-- Weight fish based on level difference and rarity
	local weights = {}
	local totalWeight = 0
	
	for _, fishName in ipairs(availableFish) do
		local fishConfig = FISHING_CONFIG.FishTypes[fishName]
		local levelDiff = fishingLevel - fishConfig.levelReq
		
		-- Base weight from level difference (higher level fish are rarer)
		local weight = 100 / (1 + levelDiff * 0.5)
		
		-- Adjust by rod effectiveness
		weight = weight * rodEffectiveness
		
		-- Adjust by rarity
		if fishConfig.rarity == "common" then
			weight = weight * 2.0
		elseif fishConfig.rarity == "uncommon" then
			weight = weight * 1.5
		elseif fishConfig.rarity == "rare" then
			weight = weight * 1.0
		elseif fishConfig.rarity == "epic" then
			weight = weight * 0.5
		end
		
		weights[fishName] = weight
		totalWeight = totalWeight + weight
	end
	
	-- Select random fish based on weights
	local randomValue = math.random() * totalWeight
	local cumulativeWeight = 0
	
	for fishName, weight in pairs(weights) do
		cumulativeWeight = cumulativeWeight + weight
		if randomValue <= cumulativeWeight then
			return fishName
		end
	end
	
	-- Fallback to first available fish
	return availableFish[1]
end

-- Helper: Calculate catch time
local function calculateCatchTime(player, fishName, rodId)
	local baseTime = FISHING_CONFIG.FishTypes[fishName].baseCatchTime
	local fishingLevel = getFishingLevel(player)
	
	-- Level-based speed bonus (up to 40% faster at high levels)
	local levelDiff = fishingLevel - FISHING_CONFIG.FishTypes[fishName].levelReq
	local levelBonus = math.min(0.4, levelDiff * 0.02)
	
	-- Rod effectiveness multiplier
	local rodMultiplier = 1.0
	if rodId and FISHING_CONFIG.FishingRods[rodId] then
		rodMultiplier = FISHING_CONFIG.FishingRods[rodId].effectiveness
	end
	
	-- Random variation ±30% (fishing has more variance than mining)
	local randomFactor = 0.7 + (math.random() * 0.6)
	
	local totalTime = baseTime * (1 - levelBonus) / rodMultiplier * randomFactor
	
	return math.max(2.0, totalTime) -- Minimum 2 seconds
end

-- Helper: Award fishing XP
local function awardFishingXP(player, fishName)
	local xpAmount = FISHING_CONFIG.FishTypes[fishName].xp
	local playerData = DataManager:GetData(player)
	
	-- Update fishing skill
	playerData.skills.Fishing = (playerData.skills.Fishing or 1) + xpAmount
	
	-- Save updated data
	DataManager:UpdateData(player, {skills = playerData.skills})
	
	-- Notify client of XP gain
	if Remotes then
		local xpEvent = Remotes:WaitForChild("SkillXPUpdate", 5)
		if xpEvent then
			xpEvent:FireClient(player, "Fishing", xpAmount, playerData.skills.Fishing)
		end
	end
	
	ErrorHandler:LogDebug("Awarded fishing XP", {
		player = player.Name,
		fish = fishName,
		xp = xpAmount,
		newLevel = playerData.skills.Fishing
	})
end

-- Helper: Add fish to inventory
local function addFishToInventory(player, fishName)
	local fishId = FISHING_CONFIG.FishTypes[fishName].id
	
	-- Get player data
	local playerData = DataManager:GetData(player)
	
	-- Initialize inventory if needed
	playerData.inventory = playerData.inventory or {}
	
	-- Add fish to inventory
	local currentCount = playerData.inventory[fishId] or 0
	playerData.inventory[fishId] = currentCount + 1
	
	-- Save updated data
	DataManager:UpdateData(player, {inventory = playerData.inventory})
	
	-- Notify client of inventory update
	if InventoryUpdateEvent then
		InventoryUpdateEvent:FireClient(player, fishId, playerData.inventory[fishId])
	end
	
	ErrorHandler:LogDebug("Added fish to inventory", {
		player = player.Name,
		fish = fishId,
		count = playerData.inventory[fishId]
	})
	
	return true
end

-- Helper: Validate fishing attempt
local function validateFishing(player, fishingSpot)
	-- Check player character
	if not player or not player.Character then
		return false, "Player character not found"
	end
	
	-- Check fishing spot (could be a part or just location-based)
	if not fishingSpot then
		return false, "Invalid fishing spot"
	end
	
	-- Check if already fishing
	if activeFishingSessions[player.UserId] then
		return false, "Already fishing"
	end
	
	-- Check fishing level (basic check)
	local fishingLevel = getFishingLevel(player)
	if fishingLevel < 1 then
		return false, "Cannot fish"
	end
	
	-- Check for fishing rod
	local rodId = getEquippedRod(player)
	if not rodId then
		return false, "Need a fishing rod equipped"
	end
	
	-- Check rod level requirement
	local rodData = FISHING_CONFIG.FishingRods[rodId]
	if not rodData then
		return false, "Invalid fishing rod"
	end
	
	if fishingLevel < rodData.levelReq then
		return false, string.format("Need Fishing level %d for this rod", rodData.levelReq)
	end
	
	-- Determine fishing spot type (simplified - in real game would check location)
	local spotType = "River" -- Default
	
	return true, "Valid", spotType, rodId
end

-- Main fishing handler
StartFishingEvent.OnServerEvent:Connect(function(player, fishingSpot)
	-- Validate input
	if not player or not player:IsA("Player") then
		ErrorHandler:LogWarning("Invalid player in fishing attempt")
		return
	end
	
	-- Validate fishing attempt
	local isValid, errorMessage, spotType, rodId = validateFishing(player, fishingSpot)
	
	if not isValid then
		ErrorHandler:LogDebug("Fishing validation failed", {
			player = player.Name,
			error = errorMessage
		})
		
		-- Notify client of failure
		if FishingCompleteEvent then
			FishingCompleteEvent:FireClient(player, false, errorMessage)
		end
		return
	end
	
	-- Get available fish
	local availableFish = getAvailableFish(player, spotType)
	if #availableFish == 0 then
		ErrorHandler:LogDebug("No fish available", {player = player.Name, spot = spotType})
		
		if FishingCompleteEvent then
			FishingCompleteEvent:FireClient(player, false, "No fish available here")
		end
		return
	end
	
	-- Select fish to catch
	local fishingLevel = getFishingLevel(player)
	local rodEffectiveness = FISHING_CONFIG.FishingRods[rodId].effectiveness
	local fishName = selectFishToCatch(availableFish, fishingLevel, rodEffectiveness)
	
	if not fishName then
		ErrorHandler:LogWarning("Failed to select fish", {player = player.Name})
		
		if FishingCompleteEvent then
			FishingCompleteEvent:FireClient(player, false, "Failed to catch fish")
		end
		return
	end
	
	-- Calculate catch time
	local catchTime = calculateCatchTime(player, fishName, rodId)
	
	-- Start fishing session
	activeFishingSessions[player.UserId] = {
		player = player,
		fishingSpot = fishingSpot,
		fishName = fishName,
		startTime = tick(),
		catchTime = catchTime,
		completed = false
	}
	
	ErrorHandler:LogDebug("Fishing session started", {
		player = player.Name,
		fish = fishName,
		time = catchTime,
		rod = rodId,
		spot = spotType
	})
	
	-- Start progress updates
	local startTime = tick()
	local updateInterval = 0.1 -- Update every 100ms
	
	while tick() - startTime < catchTime do
		if not activeFishingSessions[player.UserId] then
			-- Session cancelled
			break
		end
		
		local progress = (tick() - startTime) / catchTime
		
		-- Send progress update to client
		if FishingProgressEvent then
			FishingProgressEvent:FireClient(player, fishName, progress)
		end
		
		-- Simulate "bites" - random events during fishing
		if math.random() < 0.1 then -- 10% chance per update
			if FishCaughtEvent then
				FishCaughtEvent:FireClient(player, "Bite!")
			end
		end
		
		wait(updateInterval)
	end
	
	-- Check if fishing was completed
	local session = activeFishingSessions[player.UserId]
	if session and not session.completed then
		-- Fishing completed successfully
		session.completed = true
		
		-- Award XP
		awardFishingXP(player, fishName)
		
		-- Add fish to inventory
		addFishToInventory(player, fishName)
		
		-- Notify client of completion
		if FishingCompleteEvent then
			FishingCompleteEvent:FireClient(player, true, "Caught " .. fishName)
		end
		
		ErrorHandler:LogInfo("Fishing completed", {
			player = player.Name,
			fish = fishName,
			timeTaken = tick() - startTime
		})
		
	else
		-- Fishing was cancelled or failed
		if FishingCompleteEvent then
			FishingCompleteEvent:FireClient(player, false, "Fishing cancelled")
		end
	end
	
	-- Clean up session
	activeFishingSessions[player.UserId] = nil
end)

-- Cancel fishing if player moves too far
local function checkFishingDistance()
	for userId, session in pairs(activeFishingSessions) do
		if session.player and session.player.Character and session.fishingSpot then
			local character = session.player.Character
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			
			if humanoidRootPart and session.fishingSpot:IsA("BasePart") then
				local distance = (humanoidRootPart.Position - session.fishingSpot.Position).Magnitude
				
				if distance > 15 then -- Cancel if more than 15 studs away
					ErrorHandler:LogDebug("Fishing cancelled due to distance", {
						player = session.player.Name,
						distance = distance
					})
					
					activeFishingSessions[userId] = nil
					
					if FishingCompleteEvent then
						FishingCompleteEvent:FireClient(session.player, false, "Moved too far from fishing spot")
					end
				end
			end
		end
	end
end

-- Periodic distance check
RunService.Heartbeat:Connect(function(deltaTime)
	checkFishingDistance()
end)

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(player)
	if activeFishingSessions[player.UserId] then
		activeFishingSessions[player.UserId] = nil
		ErrorHandler:LogDebug("Cleaned up fishing session", {player = player.Name})
	end
end)

-- Initialize
ErrorHandler:LogInfo("FishingManager loaded successfully", {
	fishTypes = #FISHING_CONFIG.FishTypes,
	rodTypes = #FISHING_CONFIG.FishingRods,
	spotTypes = #FISHING_CONFIG.FishingSpots
})