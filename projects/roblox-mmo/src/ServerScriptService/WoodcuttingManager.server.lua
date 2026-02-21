-- WoodcuttingManager.server.lua
-- Specialized woodcutting system with progress bars and tree respawning

print("[WoodcuttingManager] Starting...")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Wait for dependencies with timeouts
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)

-- Load required modules
local Config = require(Modules:WaitForChild("Config", 10))
local ItemDB = require(Modules:WaitForChild("ItemDatabase", 10))
local DataManager = require(Modules:WaitForChild("DataManager", 10))

-- Get remotes
local StartWoodcutting = Remotes:WaitForChild("StartWoodcutting", 5)
local WoodcuttingProgress = Remotes:WaitForChild("WoodcuttingProgress", 5)
local WoodcuttingComplete = Remotes:WaitForChild("WoodcuttingComplete", 5)

-- Validate remotes
if not StartWoodcutting or not WoodcuttingProgress or not WoodcuttingComplete then
	warn("[WoodcuttingManager] Missing remotes!")
	return
end

-- Tree data
local TREE_DATA = {
	["Oak Tree"] = {
		level = 1,
		log = "Oak Log",
		xp = 18,
		respawnTime = 30,
		axeSpeed = {
			["Bronze Axe"] = 1.0,
			["Iron Axe"] = 1.2,
			["Steel Axe"] = 1.5,
			["Mithril Axe"] = 1.8,
			["Adamant Axe"] = 2.0,
			["Rune Axe"] = 2.5
		}
	},
	["Willow Tree"] = {
		level = 20,
		log = "Willow Log",
		xp = 40,
		respawnTime = 45,
		axeSpeed = {
			["Bronze Axe"] = 0.8,
			["Iron Axe"] = 1.0,
			["Steel Axe"] = 1.3,
			["Mithril Axe"] = 1.6,
			["Adamant Axe"] = 1.8,
			["Rune Axe"] = 2.2
		}
	},
	["Yew Tree"] = {
		level = 50,
		log = "Yew Log",
		xp = 80,
		respawnTime = 60,
		axeSpeed = {
			["Bronze Axe"] = 0.5,
			["Iron Axe"] = 0.7,
			["Steel Axe"] = 1.0,
			["Mithril Axe"] = 1.3,
			["Adamant Axe"] = 1.5,
			["Rune Axe"] = 2.0
		}
	},
	["Magic Tree"] = {
		level = 75,
		log = "Magic Log",
		xp = 150,
		respawnTime = 180,
		axeSpeed = {
			["Bronze Axe"] = 0.3,
			["Iron Axe"] = 0.5,
			["Steel Axe"] = 0.8,
			["Mithril Axe"] = 1.0,
			["Adamant Axe"] = 1.2,
			["Rune Axe"] = 1.5
		}
	}
}

-- Active woodcutting sessions
local activeSessions = {}
local treeStates = {}

-- Helper function to get player's equipped axe
local function getPlayerAxe(player)
	local equipment = DataManager.GetEquipment(player)
	if not equipment then return nil end
	
	for _, item in pairs(equipment) do
		if item and item.Type == "axe" then
			return item.Name
		end
	end
	return nil
end

-- Helper function to check if player has required level
local function hasRequiredLevel(player, treeType)
	local treeInfo = TREE_DATA[treeType]
	if not treeInfo then return false end
	
	local woodcuttingLevel = DataManager.GetSkillLevel(player, "Woodcutting")
	return woodcuttingLevel >= treeInfo.level
end

-- Helper function to calculate chop time based on axe
local function getChopTime(treeType, axeName)
	local treeInfo = TREE_DATA[treeType]
	if not treeInfo then return 3.0 end
	
	local axeSpeed = treeInfo.axeSpeed[axeName] or 1.0
	return 3.0 / axeSpeed  -- Base 3 seconds, faster axes reduce time
end

-- Start woodcutting session
StartWoodcutting.OnServerEvent:Connect(function(player, treeModel)
	if not player or not treeModel then return end
	
	local treeName = treeModel.Name
	local treeInfo = TREE_DATA[treeName]
	
	-- Check if tree exists
	if not treeInfo then
		warn("[WoodcuttingManager] Unknown tree: " .. treeName)
		return
	end
	
	-- Check if player is already woodcutting
	if activeSessions[player.UserId] then
		WoodcuttingProgress:FireClient(player, 0, "Already woodcutting!")
		return
	end
	
	-- Check level requirement
	if not hasRequiredLevel(player, treeName) then
		WoodcuttingProgress:FireClient(player, 0, "Level " .. treeInfo.level .. " Woodcutting required!")
		return
	end
	
	-- Check for axe
	local axeName = getPlayerAxe(player)
	if not axeName then
		WoodcuttingProgress:FireClient(player, 0, "Equip an axe first!")
		return
	end
	
	-- Check if tree is depleted
	if treeStates[treeModel] and treeStates[treeModel].depleted then
		WoodcuttingProgress:FireClient(player, 0, "Tree is depleted!")
		return
	end
	
	-- Calculate chop time
	local chopTime = getChopTime(treeName, axeName)
	
	-- Start session
	activeSessions[player.UserId] = {
		tree = treeModel,
		startTime = os.time(),
		chopTime = chopTime,
		treeInfo = treeInfo,
		axeName = axeName
	}
	
	-- Send initial progress
	WoodcuttingProgress:FireClient(player, 0, "Chopping...")
	
	-- Start progress loop
	task.spawn(function()
		local startTime = os.time()
		local session = activeSessions[player.UserId]
		
		while session and os.time() - startTime < chopTime do
			if not activeSessions[player.UserId] then break end
			
			local elapsed = os.time() - startTime
			local progress = math.min(elapsed / chopTime, 1.0)
			
			WoodcuttingProgress:FireClient(player, progress, "Chopping...")
			task.wait(0.1)
		end
		
		-- Check if session still exists (player didn't cancel)
		if activeSessions[player.UserId] then
			-- Complete woodcutting
			completeWoodcutting(player, treeModel, treeInfo, axeName)
		end
	end)
end)

-- Complete woodcutting
local function completeWoodcutting(player, treeModel, treeInfo, axeName)
	-- Give XP
	DataManager.AddSkillXP(player, "Woodcutting", treeInfo.xp)
	
	-- Give log
	DataManager.AddItem(player, treeInfo.log, 1)
	
	-- Fire completion event
	WoodcuttingComplete:FireClient(player, treeInfo.log, treeInfo.xp)
	
	-- Deplete tree
	depleteTree(treeModel, treeInfo)
	
	-- Clear session
	activeSessions[player.UserId] = nil
end

-- Deplete tree and schedule respawn
local function depleteTree(treeModel, treeInfo)
	-- Mark as depleted
	treeStates[treeModel] = {
		depleted = true,
		depleteTime = os.time()
	}
	
	-- Hide tree
	for _, part in ipairs(treeModel:GetChildren()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
			part.CanCollide = false
		end
	end
	
	-- Schedule respawn
	task.delay(treeInfo.respawnTime, function()
		if treeModel.Parent then
			-- Restore tree
			for _, part in ipairs(treeModel:GetChildren()) do
				if part:IsA("BasePart") then
					part.Transparency = 0
					part.CanCollide = true
				end
			end
			
			-- Clear depleted state
			treeStates[treeModel] = nil
		end
	end)
end

-- Cancel woodcutting if player moves away
local function onPlayerMoved(player)
	if activeSessions[player.UserId] then
		activeSessions[player.UserId] = nil
		WoodcuttingProgress:FireClient(player, 0, "Cancelled - moved away")
	end
end

-- Clean up on player leave
Players.PlayerRemoving:Connect(function(player)
	activeSessions[player.UserId] = nil
end)

print("[WoodcuttingManager] Ready!")