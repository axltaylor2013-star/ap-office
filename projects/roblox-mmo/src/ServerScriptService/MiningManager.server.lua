-- MiningManager.server.lua
-- Server-side mining system with error handling

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

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
			return {skills = {Mining = 1}, inventory = {}, equipment = {Tool = ""}}
		end,
		UpdateData = function() return true end
	}
end

-- RemoteEvents with validation
local StartMiningEvent = Remotes and Remotes:WaitForChild("StartMining", 5)
local MiningProgressEvent = Remotes and Remotes:WaitForChild("MiningProgress", 5)
local MiningCompleteEvent = Remotes and Remotes:WaitForChild("MiningComplete", 5)
local InventoryUpdateEvent = Remotes and Remotes:WaitForChild("InventoryUpdate", 5)

-- Validate remotes
if not StartMiningEvent then
	ErrorHandler:LogError("StartMining remote not found")
	return
end

-- Mining configuration
local MINING_CONFIG = {
	-- Ore types with their properties
	OreTypes = {
		["Copper Ore"] = {
			id = "copper_ore",
			levelReq = 1,
			xp = 20,
			respawnTime = 30, -- seconds
			baseMiningTime = 3.0 -- seconds
		},
		["Tin Ore"] = {
			id = "tin_ore",
			levelReq = 1,
			xp = 25,
			respawnTime = 35,
			baseMiningTime = 3.5
		},
		["Iron Ore"] = {
			id = "iron_ore",
			levelReq = 15,
			xp = 35,
			respawnTime = 45,
			baseMiningTime = 4.0
		},
		["Coal Ore"] = {
			id = "coal_ore",
			levelReq = 30,
			xp = 50,
			respawnTime = 60,
			baseMiningTime = 4.5
		},
		["Mithril Ore"] = {
			id = "mithril_ore",
			levelReq = 55,
			xp = 80,
			respawnTime = 90,
			baseMiningTime = 5.0
		},
		["Adamant Ore"] = {
			id = "adamant_ore",
			levelReq = 70,
			xp = 95,
			respawnTime = 120,
			baseMiningTime = 5.5
		},
		["Runite Ore"] = {
			id = "runite_ore",
			levelReq = 85,
			xp = 125,
			respawnTime = 180,
			baseMiningTime = 6.0
		}
	},
	
	-- Pickaxe types with speed multipliers
	Pickaxes = {
		["bronze_pickaxe"] = {speedMultiplier = 1.0, levelReq = 1},
		["iron_pickaxe"] = {speedMultiplier = 1.2, levelReq = 10},
		["steel_pickaxe"] = {speedMultiplier = 1.4, levelReq = 20},
		["mithril_pickaxe"] = {speedMultiplier = 1.6, levelReq = 30},
		["adamant_pickaxe"] = {speedMultiplier = 1.8, levelReq = 40},
		["rune_pickaxe"] = {speedMultiplier = 2.0, levelReq = 50}
	}
}

-- Active mining sessions
local activeMiningSessions = {}
local oreNodes = {} -- Track ore node states

-- Helper: Get player's mining level
local function getMiningLevel(player)
	local playerData = DataManager:GetData(player)
	return playerData.skills.Mining or 1
end

-- Helper: Get equipped pickaxe
local function getEquippedPickaxe(player)
	local playerData = DataManager:GetData(player)
	local toolId = playerData.equipment.Tool or ""
	
	if toolId == "" then
		return nil
	end
	
	-- Check if it's a pickaxe
	local toolData = ItemDatabase[toolId]
	if toolData and toolData.type == "Tool" and string.find(toolId:lower(), "pickaxe") then
		return toolId
	end
	
	return nil
end

-- Helper: Calculate mining time
local function calculateMiningTime(player, oreType, pickaxeId)
	local baseTime = MINING_CONFIG.OreTypes[oreType].baseMiningTime
	local miningLevel = getMiningLevel(player)
	
	-- Level-based speed bonus (up to 50% faster at high levels)
	local levelBonus = math.min(0.5, (miningLevel - MINING_CONFIG.OreTypes[oreType].levelReq) * 0.02)
	
	-- Pickaxe speed multiplier
	local pickaxeMultiplier = 1.0
	if pickaxeId and MINING_CONFIG.Pickaxes[pickaxeId] then
		pickaxeMultiplier = MINING_CONFIG.Pickaxes[pickaxeId].speedMultiplier
	end
	
	-- Random variation ±20%
	local randomFactor = 0.8 + (math.random() * 0.4)
	
	local totalTime = baseTime * (1 - levelBonus) / pickaxeMultiplier * randomFactor
	
	return math.max(1.0, totalTime) -- Minimum 1 second
end

-- Helper: Award mining XP
local function awardMiningXP(player, oreType)
	local xpAmount = MINING_CONFIG.OreTypes[oreType].xp
	local playerData = DataManager:GetData(player)
	
	-- Update mining skill
	playerData.skills.Mining = (playerData.skills.Mining or 1) + xpAmount
	
	-- Save updated data
	DataManager:UpdateData(player, {skills = playerData.skills})
	
	-- Notify client of XP gain
	if Remotes then
		local xpEvent = Remotes:WaitForChild("SkillXPUpdate", 5)
		if xpEvent then
			xpEvent:FireClient(player, "Mining", xpAmount, playerData.skills.Mining)
		end
	end
	
	ErrorHandler:LogDebug("Awarded mining XP", {
		player = player.Name,
		ore = oreType,
		xp = xpAmount,
		newLevel = playerData.skills.Mining
	})
end

-- Helper: Add ore to inventory
local function addOreToInventory(player, oreType)
	local oreId = MINING_CONFIG.OreTypes[oreType].id
	
	-- Get player data
	local playerData = DataManager:GetData(player)
	
	-- Initialize inventory if needed
	playerData.inventory = playerData.inventory or {}
	
	-- Add ore to inventory
	local currentCount = playerData.inventory[oreId] or 0
	playerData.inventory[oreId] = currentCount + 1
	
	-- Save updated data
	DataManager:UpdateData(player, {inventory = playerData.inventory})
	
	-- Notify client of inventory update
	if InventoryUpdateEvent then
		InventoryUpdateEvent:FireClient(player, oreId, playerData.inventory[oreId])
	end
	
	ErrorHandler:LogDebug("Added ore to inventory", {
		player = player.Name,
		ore = oreId,
		count = playerData.inventory[oreId]
	})
	
	return true
end

-- Helper: Validate mining attempt
local function validateMining(player, oreNode)
	-- Check player character
	if not player or not player.Character then
		return false, "Player character not found"
	end
	
	-- Check ore node
	if not oreNode or not oreNode:IsA("BasePart") then
		return false, "Invalid ore node"
	end
	
	-- Check if node is already being mined
	if activeMiningSessions[player.UserId] then
		return false, "Already mining"
	end
	
	-- Check if node is depleted
	if oreNodes[oreNode] and oreNodes[oreNode].depleted then
		return false, "Ore node depleted"
	end
	
	-- Get ore type from node name
	local oreType = oreNode.Name
	if not MINING_CONFIG.OreTypes[oreType] then
		return false, "Unknown ore type: " .. oreType
	end
	
	-- Check mining level requirement
	local miningLevel = getMiningLevel(player)
	if miningLevel < MINING_CONFIG.OreTypes[oreType].levelReq then
		return false, string.format("Need Mining level %d (current: %d)", 
			MINING_CONFIG.OreTypes[oreType].levelReq, miningLevel)
	end
	
	-- Check for pickaxe
	local pickaxeId = getEquippedPickaxe(player)
	if not pickaxeId then
		return false, "Need a pickaxe equipped"
	end
	
	-- Check pickaxe level requirement
	local pickaxeData = MINING_CONFIG.Pickaxes[pickaxeId]
	if not pickaxeData then
		return false, "Invalid pickaxe"
	end
	
	if miningLevel < pickaxeData.levelReq then
		return false, string.format("Need Mining level %d for this pickaxe", pickaxeData.levelReq)
	end
	
	return true, "Valid", oreType, pickaxeId
end

-- Main mining handler
StartMiningEvent.OnServerEvent:Connect(function(player, oreNode)
	-- Validate input
	if not player or not player:IsA("Player") then
		ErrorHandler:LogWarning("Invalid player in mining attempt")
		return
	end
	
	if not oreNode then
		ErrorHandler:LogWarning("No ore node provided", {player = player.Name})
		return
	end
	
	-- Validate mining attempt
	local isValid, errorMessage, oreType, pickaxeId = validateMining(player, oreNode)
	
	if not isValid then
		ErrorHandler:LogDebug("Mining validation failed", {
			player = player.Name,
			error = errorMessage
		})
		
		-- Notify client of failure
		if MiningCompleteEvent then
			MiningCompleteEvent:FireClient(player, false, errorMessage)
		end
		return
	end
	
	-- Calculate mining time
	local miningTime = calculateMiningTime(player, oreType, pickaxeId)
	
	-- Start mining session
	activeMiningSessions[player.UserId] = {
		player = player,
		oreNode = oreNode,
		oreType = oreType,
		startTime = tick(),
		miningTime = miningTime,
		completed = false
	}
	
	ErrorHandler:LogDebug("Mining session started", {
		player = player.Name,
		ore = oreType,
		time = miningTime,
		pickaxe = pickaxeId
	})
	
	-- Start progress updates
	local startTime = tick()
	local updateInterval = 0.1 -- Update every 100ms
	
	while tick() - startTime < miningTime do
		if not activeMiningSessions[player.UserId] then
			-- Session cancelled
			break
		end
		
		local progress = (tick() - startTime) / miningTime
		
		-- Send progress update to client
		if MiningProgressEvent then
			MiningProgressEvent:FireClient(player, oreType, progress)
		end
		
		wait(updateInterval)
	end
	
	-- Check if mining was completed
	local session = activeMiningSessions[player.UserId]
	if session and not session.completed then
		-- Mining completed successfully
		session.completed = true
		
		-- Award XP
		awardMiningXP(player, oreType)
		
		-- Add ore to inventory
		addOreToInventory(player, oreType)
		
		-- Deplete ore node
		oreNodes[oreNode] = {
			depleted = true,
			respawnTime = tick() + MINING_CONFIG.OreTypes[oreType].respawnTime,
			oreType = oreType
		}
		
		-- Notify client of completion
		if MiningCompleteEvent then
			MiningCompleteEvent:FireClient(player, true, "Mined " .. oreType)
		end
		
		ErrorHandler:LogInfo("Mining completed", {
			player = player.Name,
			ore = oreType,
			timeTaken = tick() - startTime
		})
		
		-- Hide ore node visually (client will handle this)
		-- In a full implementation, we'd change the node's appearance
		
	else
		-- Mining was cancelled or failed
		if MiningCompleteEvent then
			MiningCompleteEvent:FireClient(player, false, "Mining cancelled")
		end
	end
	
	-- Clean up session
	activeMiningSessions[player.UserId] = nil
end)

-- Cancel mining if player moves too far
local function checkMiningDistance()
	for userId, session in pairs(activeMiningSessions) do
		if session.player and session.player.Character and session.oreNode then
			local character = session.player.Character
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			
			if humanoidRootPart then
				local distance = (humanoidRootPart.Position - session.oreNode.Position).Magnitude
				
				if distance > 10 then -- Cancel if more than 10 studs away
					ErrorHandler:LogDebug("Mining cancelled due to distance", {
						player = session.player.Name,
						distance = distance
					})
					
					activeMiningSessions[userId] = nil
					
					if MiningCompleteEvent then
						MiningCompleteEvent:FireClient(session.player, false, "Moved too far from ore")
					end
				end
			end
		end
	end
end

-- Periodic distance check
RunService.Heartbeat:Connect(function(deltaTime)
	checkMiningDistance()
end)

-- Ore node respawn system
local function respawnOreNodes()
	for oreNode, nodeData in pairs(oreNodes) do
		if nodeData.depleted and tick() >= nodeData.respawnTime then
			-- Respawn the ore node
			oreNodes[oreNode] = nil
			
			ErrorHandler:LogDebug("Ore node respawned", {
				ore = nodeData.oreType,
				node = oreNode:GetFullName()
			})
			
			-- Notify clients that node is available again
			-- In a full implementation, we'd change the node's appearance back
		end
	end
end

-- Periodic respawn check
RunService.Heartbeat:Connect(function(deltaTime)
	respawnOreNodes()
end)

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(player)
	if activeMiningSessions[player.UserId] then
		activeMiningSessions[player.UserId] = nil
		ErrorHandler:LogDebug("Cleaned up mining session", {player = player.Name})
	end
end)

-- Initialize ore nodes in workspace
local function initializeOreNodes()
	-- Look for ore nodes in workspace
	-- In a full implementation, we'd tag parts with CollectionService
	-- For now, we'll just log that initialization happened
	
	ErrorHandler:LogInfo("MiningManager initialized", {
		oreTypes = #MINING_CONFIG.OreTypes,
		pickaxeTypes = #MINING_CONFIG.Pickaxes
	})
end

-- Initialize on server start
game:GetService("Players").PlayerAdded:Wait()
initializeOreNodes()

ErrorHandler:LogInfo("MiningManager loaded successfully!")