--[[
	CraftingManager.server.lua
	Handles Smithing & Cooking crafting stations for Haven town.
	Validates recipes, consumes ingredients, awards products & XP.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Modules
local Modules = ReplicatedStorage:WaitForChild("Modules", 5)
local DataManager = require(Modules:WaitForChild("DataManager", 5))
local ItemDatabase = require(Modules:WaitForChild("ItemDatabase", 5))

----------------------------------------------------------------------
-- Remote Events
----------------------------------------------------------------------
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local CraftRequest = Remotes:WaitForChild("CraftRequest", 10)
local CraftComplete = Remotes:WaitForChild("CraftComplete", 10)
local CraftUpdate = Remotes:WaitForChild("CraftUpdate", 10)

----------------------------------------------------------------------
-- Recipe Definitions
----------------------------------------------------------------------
export type Recipe = {
	id: string,
	skill: string,
	level: number,
	xp: number,
	ingredients: { [string]: number },
	product: string,
	productQty: number,
	station: string, -- "Anvil" | "Forge" | "CookingRange"
}

local Recipes: { Recipe } = {
	-- Smithing: smelting (Forge)
	{ id = "smelt_copper",  skill = "Smithing", level = 1,  xp = 25,  ingredients = { ["Copper Ore"] = 1 }, product = "Copper Bar", productQty = 1, station = "Forge" },
	{ id = "smelt_iron",    skill = "Smithing", level = 15, xp = 45,  ingredients = { ["Iron Ore"]   = 1 }, product = "Iron Bar",   productQty = 1, station = "Forge" },
	{ id = "smelt_gold",    skill = "Smithing", level = 40, xp = 75,  ingredients = { ["Gold Ore"]   = 1 }, product = "Gold Bar",   productQty = 1, station = "Forge" },

	-- Smithing: smithing (Anvil)
	{ id = "smith_copper_sword", skill = "Smithing", level = 1,  xp = 50,  ingredients = { ["Copper Bar"] = 2 }, product = "Copper Sword", productQty = 1, station = "Anvil" },
	{ id = "smith_iron_sword",   skill = "Smithing", level = 20, xp = 80,  ingredients = { ["Iron Bar"]   = 2 }, product = "Iron Sword",   productQty = 1, station = "Anvil" },
	{ id = "smith_gold_sword",   skill = "Smithing", level = 45, xp = 120, ingredients = { ["Gold Bar"]   = 3 }, product = "Gold Sword",   productQty = 1, station = "Anvil" },

	-- Cooking (CookingRange)
	{ id = "cook_shrimp",    skill = "Cooking", level = 1,  xp = 20,  ingredients = { ["Shrimp"]    = 1 }, product = "Cooked Shrimp",    productQty = 1, station = "CookingRange" },
	{ id = "cook_trout",     skill = "Cooking", level = 20, xp = 40,  ingredients = { ["Trout"]     = 1 }, product = "Cooked Trout",     productQty = 1, station = "CookingRange" },
	{ id = "cook_lobster",   skill = "Cooking", level = 40, xp = 65,  ingredients = { ["Lobster"]   = 1 }, product = "Cooked Lobster",   productQty = 1, station = "CookingRange" },
	{ id = "cook_dark_crab", skill = "Cooking", level = 70, xp = 140, ingredients = { ["Dark Crab"] = 1 }, product = "Cooked Dark Crab", productQty = 1, station = "CookingRange" },
}

-- Index by id for fast lookup
local RecipeById: { [string]: Recipe } = {}
for _, r in Recipes do
	RecipeById[r.id] = r
end

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------

--- Check if player has enough of each ingredient
local function hasIngredients(player: Player, ingredients: { [string]: number }): boolean
	for itemName, qty in ingredients do
		if DataManager:GetItemCount(player, itemName) < qty then
			return false
		end
	end
	return true
end

--- Get player skill level
local function getSkillLevel(player: Player, skill: string): number
	return DataManager:GetSkillLevel(player, skill) or 1
end

--- How many times can the player craft this recipe?
local function maxCraftCount(player: Player, recipe: Recipe): number
	local count = math.huge
	for itemName, qty in recipe.ingredients do
		local have = DataManager:GetItemCount(player, itemName)
		count = math.min(count, math.floor(have / qty))
	end
	if count == math.huge then count = 0 end
	return count
end

----------------------------------------------------------------------
-- Craft Handler
----------------------------------------------------------------------
local function handleCraftRequest(player, recipeId, quantity)
	-- Validate recipe exists
	local recipe = RecipeById[recipeId]
	if not recipe then
		warn("[CraftingManager] Unknown recipe:", recipeId)
		CraftComplete:FireClient(player, { success = false, message = "Unknown recipe." })
		return
	end

	-- Clamp quantity
	quantity = math.clamp(math.floor(quantity or 1), 1, 100)

	-- Check skill level
	local level = getSkillLevel(player, recipe.skill)
	if level < recipe.level then
		CraftComplete:FireClient(player, {
			success = false,
			message = string.format("You need %s level %d to craft this.", recipe.skill, recipe.level),
		})
		return
	end

	-- Determine how many we can actually craft
	local canCraft = math.min(quantity, maxCraftCount(player, recipe))
	if canCraft <= 0 then
		CraftComplete:FireClient(player, { success = false, message = "Not enough ingredients." })
		return
	end

	-- Process each craft one at a time (allows progress updates)
	local crafted = 0
	for i = 1, canCraft do
		-- Re-check ingredients each iteration (safety)
		if not hasIngredients(player, recipe.ingredients) then break end

		-- Consume ingredients
		for itemName, qty in recipe.ingredients do
			DataManager:RemoveItem(player, itemName, qty)
		end

		-- Grant product
		DataManager:AddItem(player, recipe.product, recipe.productQty)

		-- Award XP
		DataManager:AddSkillXP(player, recipe.skill, recipe.xp)

		crafted += 1

		-- Send progress update to client
		CraftUpdate:FireClient(player, {
			recipeId = recipeId,
			current = i,
			total = canCraft,
		})

		-- Wait between crafts (server pacing — client shows progress bar)
		if i < canCraft then
			task.wait(1.5)
		end
	end

	-- Done
	CraftComplete:FireClient(player, {
		success = true,
		recipeId = recipeId,
		crafted = crafted,
		product = recipe.product,
		message = string.format("Crafted %dx %s!", crafted, recipe.product),
	})
end

CraftRequest.OnServerEvent:Connect(handleCraftRequest)

----------------------------------------------------------------------
-- Station Setup (ClickDetectors)
----------------------------------------------------------------------
local STATION_NAMES = { "Anvil", "Forge", "CookingRange" }

local function setupStations()
	-- Wait for MapSetup to finish placing parts
	task.wait(2)

	for _, stationName in STATION_NAMES do
		local part = workspace:FindFirstChild(stationName, true)
		if not part then
			-- Station not placed on map yet, skip silently
			continue
		end

		-- Add ClickDetector if missing
		local cd = part:FindFirstChildOfClass("ClickDetector")
		if not cd then
			cd = Instance.new("ClickDetector")
			cd.MaxActivationDistance = 10
			cd.Parent = part
		end

		cd.MouseClick:Connect(function(player: Player)
			-- Tell client to open the crafting UI for this station
			CraftUpdate:FireClient(player, {
				action = "open",
				station = stationName,
				recipes = getRecipesForStation(stationName, player),
			})
		end)

		print(string.format("[CraftingManager] ClickDetector ready on %s", stationName))
	end
end

--- Build recipe list payload for a station, annotated with player info
function getRecipesForStation(stationName: string, player: Player): { any }
	local list = {}
	local playerSkills = {} -- cache

	for _, recipe in Recipes do
		if recipe.station ~= stationName then continue end

		-- Cache skill level
		if not playerSkills[recipe.skill] then
			playerSkills[recipe.skill] = getSkillLevel(player, recipe.skill)
		end
		local lvl = playerSkills[recipe.skill]

		-- Build ingredient info
		local ingredientInfo = {}
		for itemName, qty in recipe.ingredients do
			table.insert(ingredientInfo, {
				name = itemName,
				required = qty,
				have = DataManager:GetItemCount(player, itemName),
			})
		end

		table.insert(list, {
			id = recipe.id,
			product = recipe.product,
			productQty = recipe.productQty,
			skill = recipe.skill,
			level = recipe.level,
			xp = recipe.xp,
			ingredients = ingredientInfo,
			canCraft = lvl >= recipe.level,
			maxCraft = maxCraftCount(player, recipe),
		})
	end

	return list
end

----------------------------------------------------------------------
-- Init
----------------------------------------------------------------------
task.spawn(setupStations)
print("[CraftingManager] Crafting system active!")
