--[[
	CookingManager.server.lua
	Cook raw fish at fires/ranges. Burn chance based on level.
	Click once to start, auto-repeats (AFK-able).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataManager = require(ReplicatedStorage.Modules.DataManager)
local Config = require(ReplicatedStorage.Modules.Config)

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)

-- Get cooking remotes
local CookItemEvent = Remotes:WaitForChild("CookItem", 10)

------------------------------------------------------------
-- Recipes
------------------------------------------------------------
local CookingRecipes = {
	["Shrimp"] = {
		result = "Cooked Shrimp", burnResult = "Burnt Shrimp",
		baseTime = 3, baseXP = 30, levelRequired = 1,
		burnChanceAt1 = 0.4, burnChanceAt99 = 0.05,
	},
	["Trout"] = {
		result = "Cooked Trout", burnResult = "Burnt Trout",
		baseTime = 4, baseXP = 55, levelRequired = 15,
		burnChanceAt1 = 0.5, burnChanceAt99 = 0.08,
	},
	["Lobster"] = {
		result = "Cooked Lobster", burnResult = "Burnt Lobster",
		baseTime = 5, baseXP = 80, levelRequired = 40,
		burnChanceAt1 = 0.6, burnChanceAt99 = 0.12,
	},
	["Dark Crab"] = {
		result = "Cooked Dark Crab", burnResult = "Burnt Dark Crab",
		baseTime = 6, baseXP = 130, levelRequired = 70,
		burnChanceAt1 = 0.7, burnChanceAt99 = 0.18,
	},
}

------------------------------------------------------------
-- State
------------------------------------------------------------
local activeCookers = {} -- [UserId] = true

------------------------------------------------------------
-- Find nearby cooking fire
------------------------------------------------------------
local function findNearbyFire(player)
	local char = player.Character
	if not char then return nil end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	local fires = workspace:FindFirstChild("CookingFires")
	if not fires then return nil end

	for _, fire in ipairs(fires:GetChildren()) do
		if fire:IsA("Part") then
			local d = (fire.Position - root.Position).Magnitude
			if d <= 10 then return fire end
		end
	end
	return nil
end

------------------------------------------------------------
-- Burn chance
------------------------------------------------------------
local function calculateBurnChance(recipe, cookingLevel)
	local minChance = recipe.burnChanceAt99
	local maxChance = recipe.burnChanceAt1
	local factor = math.max(0, math.min(1, (99 - cookingLevel) / 98))
	return minChance + (maxChance - minChance) * factor
end

------------------------------------------------------------
-- Cook one item, returns true to keep going
------------------------------------------------------------
local function cookOne(player, rawItemName, recipe, cookingSpot)
	local cookingLevel = DataManager.GetSkillLevel(player, "Cooking")

	-- Tell client cooking started
	CookItemEvent:FireClient(player, {
		action = "start",
		totalTime = recipe.baseTime,
		itemName = rawItemName,
	})

	-- Wait for cook time, checking distance
	local elapsed = 0
	while elapsed < recipe.baseTime do
		task.wait(0.25)
		elapsed = elapsed + 0.25

		if not activeCookers[player.UserId] then return false end

		local char = player.Character
		if not char then return false end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return false end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then return false end
		if (root.Position - cookingSpot.Position).Magnitude > 12 then return false end

		-- Send progress
		CookItemEvent:FireClient(player, {
			action = "progress",
			progress = elapsed / recipe.baseTime,
		})
	end

	-- Determine if burnt
	local burnChance = calculateBurnChance(recipe, cookingLevel)
	local isBurnt = math.random() < burnChance
	local resultItem = isBurnt and recipe.burnResult or recipe.result
	local xpGained = isBurnt and 0 or recipe.baseXP

	-- Add result
	local added = DataManager.AddToInventory(player, resultItem, 1)
	if not added then
		CookItemEvent:FireClient(player, {action = "full"})
		return false
	end

	-- Award XP
	if xpGained > 0 then
		DataManager.AddSkillXP(player, "Cooking", xpGained)
		local xpRemote = Remotes:FindFirstChild("XPUpdate")
		if xpRemote then xpRemote:FireClient(player) end
	end

	-- Update inventory
	local invRemote = Remotes:FindFirstChild("InventoryUpdate")
	if invRemote then invRemote:FireClient(player) end

	-- Notify completion
	CookItemEvent:FireClient(player, {
		result = resultItem,
		xpGained = xpGained,
		burnt = isBurnt,
	})

	return true
end

------------------------------------------------------------
-- Main cooking handler (auto-repeat)
------------------------------------------------------------
local function startCooking(player, rawItemName)
	if activeCookers[player.UserId] then return end

	local recipe = CookingRecipes[rawItemName]
	if not recipe then return end

	local cookingLevel = DataManager.GetSkillLevel(player, "Cooking")
	if cookingLevel < recipe.levelRequired then return end

	if not DataManager.HasItem(player, rawItemName, 1) then return end

	local cookingSpot = findNearbyFire(player)
	if not cookingSpot then return end

	activeCookers[player.UserId] = true

	task.spawn(function()
		while activeCookers[player.UserId] do
			-- Check still have the raw item
			if not DataManager.HasItem(player, rawItemName, 1) then break end

			-- Remove raw item
			if not DataManager.RemoveFromInventory(player, rawItemName, 1) then break end

			-- Cook it
			local keepGoing = cookOne(player, rawItemName, recipe, cookingSpot)
			if not keepGoing then break end

			task.wait(0.3)
		end

		activeCookers[player.UserId] = nil
		CookItemEvent:FireClient(player, {action = "stop"})
	end)
end

------------------------------------------------------------
-- Events
------------------------------------------------------------
CookItemEvent.OnServerEvent:Connect(function(player, rawItemName)
	if activeCookers[player.UserId] then
		-- Toggle off
		activeCookers[player.UserId] = nil
		return
	end
	startCooking(player, rawItemName)
end)

Players.PlayerRemoving:Connect(function(player)
	activeCookers[player.UserId] = nil
end)

------------------------------------------------------------
-- Add ClickDetectors to cooking fires
------------------------------------------------------------
task.defer(function()
	task.wait(3)
	local fires = workspace:FindFirstChild("CookingFires")
	if not fires then return end

	for _, fire in ipairs(fires:GetChildren()) do
		if fire:IsA("Part") then
			-- Add click detector
			if not fire:FindFirstChild("ClickDetector") then
				local cd = Instance.new("ClickDetector")
				cd.MaxActivationDistance = 10
				cd.Parent = fire
			end

			-- Add label
			if not fire:FindFirstChild("BillboardGui") then
				local bbg = Instance.new("BillboardGui")
				bbg.Size = UDim2.new(5, 0, 1, 0)
				bbg.StudsOffset = Vector3.new(0, 2.5, 0)
				bbg.Parent = fire

				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, 0, 1, 0)
				lbl.BackgroundTransparency = 1
				lbl.Text = "🔥 Cooking Fire"
				lbl.TextColor3 = Color3.fromRGB(255, 180, 80)
				lbl.TextScaled = true
				lbl.Font = Enum.Font.GothamBold
				lbl.TextStrokeTransparency = 0.5
				lbl.Parent = bbg
			end
		end
	end
	print("[CookingManager] Cooking fires ready")
end)

print("[CookingManager] Cooking system initialized")
