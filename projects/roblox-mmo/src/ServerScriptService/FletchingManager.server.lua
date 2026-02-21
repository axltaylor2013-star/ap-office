--[[
	FletchingManager.server.lua
	Server-side fletching system for the Wilderness MMO.
	Craft logs into bows and arrows at fletching bench.
	Gives Fletching XP and skill progression.
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

local StartFletchingEvent = Remotes:WaitForChild("StartFletching", 5)
local FletchingProgressEvent = Remotes:WaitForChild("FletchingProgress", 5)
local FletchingCompleteEvent = Remotes:WaitForChild("FletchingComplete", 5)
local XPUpdateEvent = Remotes:WaitForChild("XPUpdate", 5)
local InventoryUpdateEvent = Remotes:WaitForChild("InventoryUpdate", 5)

------------------------------------------------------------
-- Fletching Recipes
------------------------------------------------------------

local FletchingRecipes = {
	["Oak Log"] = {
		{ result = "Oak Shortbow", baseTime = 3, baseXP = 20, levelRequired = 1 },
		{ result = "Oak Longbow", baseTime = 4, baseXP = 30, levelRequired = 5 },
	},
	["Willow Log"] = {
		{ result = "Willow Shortbow", baseTime = 4, baseXP = 45, levelRequired = 20 },
		{ result = "Willow Longbow", baseTime = 5, baseXP = 55, levelRequired = 25 },
	},
	["Yew Log"] = {
		{ result = "Yew Shortbow", baseTime = 5, baseXP = 80, levelRequired = 40 },
		{ result = "Yew Longbow", baseTime = 6, baseXP = 100, levelRequired = 50 },
	},
	["Magic Log"] = {
		{ result = "Magic Shortbow", baseTime = 6, baseXP = 150, levelRequired = 70 },
		{ result = "Magic Longbow", baseTime = 7, baseXP = 180, levelRequired = 80 },
	},
}

-- Arrow recipes - require logs + existing arrows to make more
local ArrowRecipes = {
	{
		log = "Oak Log",
		inputArrows = "Iron Arrows",
		inputQuantity = 5,
		result = "Iron Arrows",
		resultQuantity = 15,
		baseTime = 2,
		baseXP = 15,
		levelRequired = 1
	},
	{
		log = "Willow Log", 
		inputArrows = "Iron Bolts",
		inputQuantity = 5,
		result = "Iron Bolts",
		resultQuantity = 15,
		baseTime = 2,
		baseXP = 25,
		levelRequired = 15
	},
}

------------------------------------------------------------
-- Active Fletching Sessions
------------------------------------------------------------
local activeFletchingSessions = {} -- [player] = { recipe, startTime, station, totalTime, type }

------------------------------------------------------------
-- ClickDetectors and Station Setup
------------------------------------------------------------
local function setupClickDetectors()
	local fletchingStations = workspace:WaitForChild("FletchingStations", 5)
	
	for _, station in ipairs(fletchingStations:GetChildren()) do
		if station:IsA("Part") and station.Name == "FletchingBench" then
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
			textLabel.Text = "🏹 Fletching Bench"
			textLabel.Parent = billboardGui
			
			clickDetector.MouseClick:Connect(function(player)
				-- Show available recipes (fire event to client)
				StartFletchingEvent:FireClient(player, "showRecipes")
			end)
		end
	end
end

-- Set up click detectors after a short delay to ensure stations exist
spawn(function()
	wait(2)
	if workspace:FindFirstChild("FletchingStations") then
		setupClickDetectors()
	end
end)

------------------------------------------------------------
-- Helper Functions
------------------------------------------------------------
function findNearbyFletchingBench(player)
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

	local position = character.HumanoidRootPart.Position
	local stations = workspace:FindFirstChild("FletchingStations")
	if not stations then return nil end

	for _, station in ipairs(stations:GetChildren()) do
		if station:IsA("Part") and station.Name == "FletchingBench" then
			local distance = (station.Position - position).Magnitude
			if distance <= 10 then
				return station
			end
		end
	end
	return nil
end

------------------------------------------------------------
-- Fletching Logic
------------------------------------------------------------
local function startFletchingBow(player, logItemName, bowName)
	if activeFletchingSessions[player] then return end

	local recipes = FletchingRecipes[logItemName]
	if not recipes then return end

	local recipe = nil
	for _, r in ipairs(recipes) do
		if r.result == bowName then
			recipe = r
			break
		end
	end
	if not recipe then return end

	local fletchingLevel = DataManager.GetSkillLevel(player, "Fletching")
	if fletchingLevel < recipe.levelRequired then return end

	if not DataManager.HasItem(player, logItemName, 1) then return end

	local bench = findNearbyFletchingBench(player)
	if not bench then return end

	if not DataManager.RemoveFromInventory(player, logItemName, 1) then return end
	local data = DataManager:GetData(player); if data and data.Inventory then InventoryUpdateEvent:FireClient(player, data.Inventory) end

	local totalTime = recipe.baseTime
	activeFletchingSessions[player] = {
		recipe = recipe,
		startTime = tick(),
		station = bench,
		totalTime = totalTime,
		sourceItem = logItemName,
		type = "bow"
	}

	FletchingProgressEvent:FireClient(player, {
		action = "start",
		totalTime = totalTime,
		itemName = bowName,
		type = "fletching"
	})

	print("[FletchingManager]", player.Name, "started fletching", bowName)
end

local function startFletchingArrows(player, logItemName, arrowType)
	if activeFletchingSessions[player] then return end

	local recipe = nil
	for _, r in ipairs(ArrowRecipes) do
		if r.log == logItemName and r.inputArrows == arrowType then
			recipe = r
			break
		end
	end
	if not recipe then return end

	local fletchingLevel = DataManager.GetSkillLevel(player, "Fletching")
	if fletchingLevel < recipe.levelRequired then return end

	if not DataManager.HasItem(player, logItemName, 1) then return end
	if not DataManager.HasItem(player, recipe.inputArrows, recipe.inputQuantity) then return end

	local bench = findNearbyFletchingBench(player)
	if not bench then return end

	if not DataManager.RemoveFromInventory(player, logItemName, 1) then return end
	if not DataManager.RemoveFromInventory(player, recipe.inputArrows, recipe.inputQuantity) then return end
	local data = DataManager:GetData(player); if data and data.Inventory then InventoryUpdateEvent:FireClient(player, data.Inventory) end

	local totalTime = recipe.baseTime
	activeFletchingSessions[player] = {
		recipe = recipe,
		startTime = tick(),
		station = bench,
		totalTime = totalTime,
		sourceItem = logItemName,
		type = "arrows"
	}

	FletchingProgressEvent:FireClient(player, {
		action = "start",
		totalTime = totalTime,
		itemName = recipe.result,
		type = "fletching"
	})

	print("[FletchingManager]", player.Name, "started fletching arrows", recipe.result)
end

local function completeFletching(player, session)
	local recipe = session.recipe
	local resultItem = recipe.result
	local xpGained = recipe.baseXP

	if session.type == "arrows" then
		DataManager.AddToInventory(player, resultItem, recipe.resultQuantity)
	else
		DataManager.AddToInventory(player, resultItem, 1)
	end
	local data = DataManager:GetData(player); if data and data.Inventory then InventoryUpdateEvent:FireClient(player, data.Inventory) end
	
	DataManager.AddSkillXP(player, "Fletching", xpGained)
	XPUpdateEvent:FireClient(player, "Fletching", xpGained)

	FletchingCompleteEvent:FireClient(player, {
		result = resultItem,
		quantity = session.type == "arrows" and recipe.resultQuantity or 1,
		xpGained = xpGained,
		type = session.type
	})

	-- Fire quest event
	local questCraftEvent = ReplicatedStorage:FindFirstChild("QuestCraftEvent")
	if questCraftEvent and questCraftEvent:IsA("BindableEvent") then
		local quantity = session.type == "arrows" and recipe.resultQuantity or 1
		questCraftEvent:Fire(player, resultItem, quantity)
	end

	print("[FletchingManager]", player.Name, "completed fletching:", resultItem, "XP:", xpGained)
	
	-- Auto-continue if materials available
	if session.type == "bow" then
		local sameLog = session.sourceItem
		if DataManager.HasItem(player, sameLog, 1) then
			wait(0.1) -- Brief delay then auto-continue
			startFletchingBow(player, sameLog, recipe.result)
		end
	elseif session.type == "arrows" then
		local sameLog = session.sourceItem
		if DataManager.HasItem(player, sameLog, 1) and DataManager.HasItem(player, recipe.inputArrows, recipe.inputQuantity) then
			wait(0.1)
			startFletchingArrows(player, sameLog, recipe.inputArrows)
		end
	end
end

------------------------------------------------------------
-- Update Loop
------------------------------------------------------------
local function updateFletchingSessions()
	local currentTime = tick()

	for player, session in pairs(activeFletchingSessions) do
		local elapsed = currentTime - session.startTime
		local progress = elapsed / session.totalTime

		-- Check if player is still near the station
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local distance = (character.HumanoidRootPart.Position - session.station.Position).Magnitude
			if distance > 10 then
				-- Player moved too far, cancel
				activeFletchingSessions[player] = nil
				FletchingProgressEvent:FireClient(player, {action = "cancel"})
				-- Return materials
				DataManager.AddToInventory(player, session.sourceItem, 1)
				if session.type == "arrows" then
					DataManager.AddToInventory(player, session.recipe.inputArrows, session.recipe.inputQuantity)
				end
				local data = DataManager:GetData(player); if data and data.Inventory then InventoryUpdateEvent:FireClient(player, data.Inventory) end
				continue
			end
		end

		if progress >= 1 then
			completeFletching(player, session)
			activeFletchingSessions[player] = nil
		else
			FletchingProgressEvent:FireClient(player, {
				action = "progress",
				progress = progress
			})
		end
	end
end

RunService.Heartbeat:Connect(updateFletchingSessions)

------------------------------------------------------------
-- Event Handlers
------------------------------------------------------------
StartFletchingEvent.OnServerEvent:Connect(function(player, actionType, sourceItem, targetItem)
	if actionType == "bow" then
		startFletchingBow(player, sourceItem, targetItem)
	elseif actionType == "arrows" then
		startFletchingArrows(player, sourceItem, targetItem)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	activeFletchingSessions[player] = nil
end)

print("[FletchingManager] Fletching system initialized")
