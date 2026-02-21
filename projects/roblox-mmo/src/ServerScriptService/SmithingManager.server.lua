--[[
	SmithingManager.server.lua
	Server-side smithing system for the Wilderness MMO.
	Smelt ores into bars at furnace, smith bars into equipment at anvil.
	Gives Smithing XP and skill progression.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DataManager = require(ReplicatedStorage.Modules.DataManager)
local ItemDatabase = require(ReplicatedStorage.Modules.ItemDatabase)

------------------------------------------------------------
-- Remote Events
------------------------------------------------------------
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)

local StartSmithingEvent = Remotes:WaitForChild("StartSmithing", 5)
local SmithingProgressEvent = Remotes:WaitForChild("SmithingProgress", 5)
local SmithingCompleteEvent = Remotes:WaitForChild("SmithingComplete", 5)
local XPUpdateEvent = Remotes:WaitForChild("XPUpdate", 5)
local InventoryUpdateEvent = Remotes:WaitForChild("InventoryUpdate", 5)

------------------------------------------------------------
-- Smithing Recipes
------------------------------------------------------------

-- Smelting: Ore -> Bar
local SmeltingRecipes = {
	["Copper Ore"] = {
		result = "Copper Bar",
		baseTime = 4,
		baseXP = 17.5,
		levelRequired = 1,
	},
	["Iron Ore"] = {
		result = "Iron Bar",
		baseTime = 5,
		baseXP = 25,
		levelRequired = 15,
	},
	["Gold Ore"] = {
		result = "Gold Bar",
		baseTime = 6,
		baseXP = 56.2,
		levelRequired = 40,
	},
	["Runite Ore"] = {
		result = "Runite Bar",
		baseTime = 8,
		baseXP = 125,
		levelRequired = 85,
	},
}

-- Smithing: Bar -> Equipment
local SmithingRecipes = {
	-- Copper Equipment
	["Copper Bar"] = {
		{ result = "Copper Sword", bars = 1, baseTime = 5, baseXP = 37.5, levelRequired = 1 },
		{ result = "Copper Dagger", bars = 1, baseTime = 3, baseXP = 25, levelRequired = 1 },
		{ result = "Copper Axe", bars = 1, baseTime = 4, baseXP = 31.2, levelRequired = 1 },
		{ result = "Copper Mace", bars = 1, baseTime = 4, baseXP = 31.2, levelRequired = 2 },
		{ result = "Copper Shield", bars = 2, baseTime = 6, baseXP = 50, levelRequired = 3 },
	},
	-- Iron Equipment
	["Iron Bar"] = {
		{ result = "Iron Sword", bars = 1, baseTime = 6, baseXP = 50, levelRequired = 19 },
		{ result = "Iron Dagger", bars = 1, baseTime = 4, baseXP = 37.5, levelRequired = 15 },
		{ result = "Iron Axe", bars = 1, baseTime = 5, baseXP = 43.7, levelRequired = 16 },
		{ result = "Iron Mace", bars = 1, baseTime = 5, baseXP = 43.7, levelRequired = 17 },
		{ result = "Iron Shield", bars = 2, baseTime = 7, baseXP = 75, levelRequired = 18 },
		{ result = "Iron Helmet", bars = 1, baseTime = 5, baseXP = 43.7, levelRequired = 20 },
		{ result = "Iron Platebody", bars = 3, baseTime = 8, baseXP = 112.5, levelRequired = 23 },
	},
	-- Gold Equipment (decorative/special)
	["Gold Bar"] = {
		{ result = "Gold Ring", bars = 1, baseTime = 3, baseXP = 75, levelRequired = 40 },
		{ result = "Gold Amulet", bars = 1, baseTime = 4, baseXP = 87.5, levelRequired = 45 },
		{ result = "Gold Bracelet", bars = 1, baseTime = 3, baseXP = 75, levelRequired = 42 },
	},
	-- Runite Equipment (highest tier)
	["Runite Bar"] = {
		{ result = "Runite Sword", bars = 1, baseTime = 10, baseXP = 200, levelRequired = 89 },
		{ result = "Runite Dagger", bars = 1, baseTime = 8, baseXP = 175, levelRequired = 85 },
		{ result = "Runite Axe", bars = 1, baseTime = 9, baseXP = 187.5, levelRequired = 86 },
		{ result = "Runite Shield", bars = 2, baseTime = 12, baseXP = 350, levelRequired = 90 },
		{ result = "Runite Helmet", bars = 1, baseTime = 9, baseXP = 187.5, levelRequired = 87 },
		{ result = "Runite Platebody", bars = 3, baseTime = 15, baseXP = 525, levelRequired = 95 },
	},
}

------------------------------------------------------------
-- Active Smithing Sessions
------------------------------------------------------------
local activeSmithingSessions = {} -- [player] = { recipe, startTime, station, totalTime, type }

------------------------------------------------------------
-- ClickDetectors and Station Setup
------------------------------------------------------------
local function setupClickDetectors()
	local smithingStations = workspace:WaitForChild("SmithingStations", 5)
	
	for _, station in ipairs(smithingStations:GetChildren()) do
		if station:IsA("Part") then
			-- Add ClickDetector
			local clickDetector = Instance.new("ClickDetector")
			clickDetector.MaxActivationDistance = 10
			clickDetector.Parent = station
			
			-- Add BillboardGui with label
			local billboardGui = Instance.new("BillboardGui")
			billboardGui.Size = UDim2.new(0, 200, 0, 50)
			billboardGui.StudsOffset = Vector3.new(0, 3, 0)
			billboardGui.Parent = station
			
			local textLabel = Instance.new("TextLabel")
			textLabel.Size = UDim2.new(1, 0, 1, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.TextColor3 = Color3.new(1, 1, 1)
			textLabel.TextStrokeTransparency = 0
			textLabel.Font = Enum.Font.SourceSansBold
			textLabel.TextSize = 18
			textLabel.Parent = billboardGui
			
			if station.Name:find("Furnace") then
				textLabel.Text = "🔥 Furnace (Smelting)"
				clickDetector.MouseClick:Connect(function(player)
					-- Auto-start smelting with first available ore
					for ore, _ in pairs(SmeltingRecipes) do
						if DataManager.HasItem(player, ore, 1) then
							StartSmithingEvent:FireServer("smelt", ore)
							break
						end
					end
				end)
			elseif station.Name:find("Anvil") then
				textLabel.Text = "🔨 Anvil (Smithing)"
				clickDetector.MouseClick:Connect(function(player)
					-- Show available recipes (fire event to client)
					StartSmithingEvent:FireClient(player, "showRecipes")
				end)
			end
		end
	end
end

-- Set up click detectors after a short delay to ensure stations exist
game:GetService("Debris"):AddItem(game:GetService("RunService").Heartbeat:Connect(function()
	if workspace:FindFirstChild("SmithingStations") then
		setupClickDetectors()
		return true -- Disconnect
	end
end), 10)

------------------------------------------------------------
-- Smithing Logic
------------------------------------------------------------
local function startSmelting(player, oreItemName)
	if activeSmithingSessions[player] then return end

	local recipe = SmeltingRecipes[oreItemName]
	if not recipe then return end

	local smithingLevel = DataManager.GetSkillLevel(player, "Smithing")
	if smithingLevel < recipe.levelRequired then return end

	if not DataManager.HasItem(player, oreItemName, 1) then return end

	local furnace = findNearbyFurnace(player)
	if not furnace then return end

	if not DataManager.RemoveFromInventory(player, oreItemName, 1) then return end
	local data = DataManager:GetData(player); if data and data.Inventory then InventoryUpdateEvent:FireClient(player, data.Inventory) end

	local totalTime = recipe.baseTime
	activeSmithingSessions[player] = {
		recipe = recipe,
		startTime = tick(),
		station = furnace,
		totalTime = totalTime,
		sourceItem = oreItemName,
		type = "smelting"
	}

	SmithingProgressEvent:FireClient(player, {
		action = "start",
		totalTime = totalTime,
		itemName = oreItemName,
		type = "smelting"
	})

	print("[SmithingManager]", player.Name, "started smelting", oreItemName)
end

local function startSmithing(player, barItemName, equipmentName)
	if activeSmithingSessions[player] then return end

	local recipes = SmithingRecipes[barItemName]
	if not recipes then return end

	local recipe = nil
	for _, r in ipairs(recipes) do
		if r.result == equipmentName then
			recipe = r
			break
		end
	end
	if not recipe then return end

	local smithingLevel = DataManager.GetSkillLevel(player, "Smithing")
	if smithingLevel < recipe.levelRequired then return end

	if not DataManager.HasItem(player, barItemName, recipe.bars) then return end

	local anvil = findNearbyAnvil(player)
	if not anvil then return end

	if not DataManager.RemoveFromInventory(player, barItemName, recipe.bars) then return end
	local data = DataManager:GetData(player); if data and data.Inventory then InventoryUpdateEvent:FireClient(player, data.Inventory) end

	local totalTime = recipe.baseTime
	activeSmithingSessions[player] = {
		recipe = recipe,
		startTime = tick(),
		station = anvil,
		totalTime = totalTime,
		sourceItem = barItemName,
		type = "smithing"
	}

	SmithingProgressEvent:FireClient(player, {
		action = "start",
		totalTime = totalTime,
		itemName = equipmentName,
		type = "smithing"
	})

	print("[SmithingManager]", player.Name, "started smithing", equipmentName)
end

local function completeSmithing(player, session)
	local recipe = session.recipe
	local resultItem = recipe.result
	local xpGained = recipe.baseXP

	DataManager.AddToInventory(player, resultItem, 1)
	local data = DataManager:GetData(player); if data and data.Inventory then InventoryUpdateEvent:FireClient(player, data.Inventory) end
	
	DataManager.AddSkillXP(player, "Smithing", xpGained)
	XPUpdateEvent:FireClient(player, "Smithing", xpGained)

	SmithingCompleteEvent:FireClient(player, {
		result = resultItem,
		xpGained = xpGained,
		type = session.type
	})

	-- Fire quest event
	local questCraftEvent = ReplicatedStorage:FindFirstChild("QuestCraftEvent")
	if questCraftEvent and questCraftEvent:IsA("BindableEvent") then
		questCraftEvent:Fire(player, resultItem, 1)
	end

	print("[SmithingManager]", player.Name, "completed", session.type, ":", resultItem, "XP:", xpGained)
	
	-- Auto-continue if materials available
	if session.type == "smelting" then
		local sameOre = session.sourceItem
		if DataManager.HasItem(player, sameOre, 1) then
			wait(0.1) -- Brief delay then auto-continue
			startSmelting(player, sameOre)
		end
	end
end

function findNearbyFurnace(player)
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

	local position = character.HumanoidRootPart.Position
	local furnaces = workspace:FindFirstChild("SmithingStations")
	if not furnaces then return nil end

	for _, station in ipairs(furnaces:GetChildren()) do
		if station:IsA("Part") and station.Name:find("Furnace") then
			local distance = (station.Position - position).Magnitude
			if distance <= 10 then
				return station
			end
		end
	end
	return nil
end

function findNearbyAnvil(player)
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

	local position = character.HumanoidRootPart.Position
	local anvils = workspace:FindFirstChild("SmithingStations")
	if not anvils then return nil end

	for _, station in ipairs(anvils:GetChildren()) do
		if station:IsA("Part") and station.Name:find("Anvil") then
			local distance = (station.Position - position).Magnitude
			if distance <= 10 then
				return station
			end
		end
	end
	return nil
end

------------------------------------------------------------
-- Update Loop
------------------------------------------------------------
local function updateSmithingSessions()
	local currentTime = tick()

	for player, session in pairs(activeSmithingSessions) do
		local elapsed = currentTime - session.startTime
		local progress = elapsed / session.totalTime

		-- Check if player is still near the station
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local distance = (character.HumanoidRootPart.Position - session.station.Position).Magnitude
			if distance > 10 then
				-- Player moved too far, cancel
				activeSmithingSessions[player] = nil
				SmithingProgressEvent:FireClient(player, {action = "cancel"})
				-- Return materials
				if session.type == "smelting" then
					DataManager.AddToInventory(player, session.sourceItem, 1)
				else
					DataManager.AddToInventory(player, session.sourceItem, session.recipe.bars)
				end
				local data = DataManager:GetData(player); if data and data.Inventory then InventoryUpdateEvent:FireClient(player, data.Inventory) end
				continue
			end
		end

		if progress >= 1 then
			completeSmithing(player, session)
			activeSmithingSessions[player] = nil
		else
			SmithingProgressEvent:FireClient(player, {
				action = "progress",
				progress = progress
			})
		end
	end
end

RunService.Heartbeat:Connect(updateSmithingSessions)

------------------------------------------------------------
-- Event Handlers
------------------------------------------------------------
StartSmithingEvent.OnServerEvent:Connect(function(player, actionType, sourceItem, targetItem)
	if actionType == "smelt" then
		startSmelting(player, sourceItem)
	elseif actionType == "smith" then
		startSmithing(player, sourceItem, targetItem)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	activeSmithingSessions[player] = nil
end)

print("[SmithingManager] Smithing system initialized")
