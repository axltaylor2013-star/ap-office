-- ItemDatabase.lua (ModuleScript in ReplicatedStorage/Modules)
-- Every item in the game defined here

local ItemDatabase = {}

ItemDatabase.Items = {
	-- === ORES (from Mining) ===
	["Copper Ore"] = {
		id = "copper_ore",
		type = "resource",
		skill = "Mining",
		levelReq = 1,
		xp = 20,
		stackable = true,
		value = 5,
		description = "A chunk of copper ore.",
	},
	["Iron Ore"] = {
		id = "iron_ore",
		type = "resource",
		skill = "Mining",
		levelReq = 15,
		xp = 35,
		stackable = true,
		value = 15,
		description = "A chunk of iron ore.",
	},
	["Gold Ore"] = {
		id = "gold_ore",
		type = "resource",
		skill = "Mining",
		levelReq = 40,
		xp = 65,
		stackable = true,
		value = 50,
		description = "A chunk of gold ore. Valuable.",
	},
	["Runite Ore"] = {
		id = "runite_ore",
		type = "resource",
		skill = "Mining",
		levelReq = 70,
		xp = 125,
		stackable = true,
		value = 200,
		description = "Extremely rare ore. Only found in the Wilderness.",
		wildernessOnly = true,
	},

	-- === LOGS (from Woodcutting) ===
	["Oak Log"] = {
		id = "oak_log",
		type = "resource",
		skill = "Woodcutting",
		levelReq = 1,
		xp = 18,
		stackable = true,
		value = 4,
		description = "A sturdy oak log.",
	},
	["Willow Log"] = {
		id = "willow_log",
		type = "resource",
		skill = "Woodcutting",
		levelReq = 20,
		xp = 40,
		stackable = true,
		value = 12,
		description = "A flexible willow log.",
	},
	["Yew Log"] = {
		id = "yew_log",
		type = "resource",
		skill = "Woodcutting",
		levelReq = 50,
		xp = 80,
		stackable = true,
		value = 75,
		description = "Dense yew wood. Prized by fletchers.",
	},
	["Magic Log"] = {
		id = "magic_log",
		type = "resource",
		skill = "Woodcutting",
		levelReq = 75,
		xp = 150,
		stackable = true,
		value = 250,
		description = "Pulsing with energy. Wilderness only.",
		wildernessOnly = true,
	},

	-- === FISH (from Fishing) ===
	["Shrimp"] = {
		id = "shrimp",
		type = "resource",
		skill = "Fishing",
		levelReq = 1,
		xp = 15,
		stackable = true,
		value = 3,
		cookable = true,
		healAmount = 5,
		description = "A small shrimp.",
	},
	["Trout"] = {
		id = "trout",
		type = "resource",
		skill = "Fishing",
		levelReq = 20,
		xp = 35,
		stackable = true,
		value = 10,
		cookable = true,
		healAmount = 15,
		description = "A fresh trout.",
	},
	["Lobster"] = {
		id = "lobster",
		type = "resource",
		skill = "Fishing",
		levelReq = 40,
		xp = 60,
		stackable = true,
		value = 40,
		cookable = true,
		healAmount = 30,
		description = "A large lobster.",
	},
	["Dark Crab"] = {
		id = "dark_crab",
		type = "resource",
		skill = "Fishing",
		levelReq = 70,
		xp = 130,
		stackable = true,
		value = 180,
		cookable = true,
		healAmount = 50,
		description = "Found only in Wilderness waters.",
		wildernessOnly = true,
	},

	-- === BARS (from Smithing) ===
	["Copper Bar"] = {
		id = "copper_bar",
		type = "crafted",
		skill = "Smithing",
		levelReq = 1,
		xp = 25,
		stackable = true,
		value = 12,
		recipe = { ["Copper Ore"] = 1 },
		description = "A smelted copper bar.",
	},
	["Iron Bar"] = {
		id = "iron_bar",
		type = "crafted",
		skill = "Smithing",
		levelReq = 15,
		xp = 45,
		stackable = true,
		value = 35,
		recipe = { ["Iron Ore"] = 1 },
		description = "A smelted iron bar.",
	},
	["Gold Bar"] = {
		id = "gold_bar",
		type = "crafted",
		skill = "Smithing",
		levelReq = 40,
		xp = 75,
		stackable = true,
		value = 120,
		recipe = { ["Gold Ore"] = 1 },
		description = "A gleaming gold bar.",
	},

	-- === WEAPONS ===
	["Copper Sword"] = {
		id = "copper_sword",
		type = "weapon",
		skill = "Smithing",
		levelReq = 1,
		combatReq = 1,
		xp = 50,
		stackable = false,
		value = 30,
		damage = 8,
		attackSpeed = 1.5,
		recipe = { ["Copper Bar"] = 2 },
		description = "A basic copper sword.",
	},
	["Iron Sword"] = {
		id = "iron_sword",
		type = "weapon",
		skill = "Smithing",
		levelReq = 20,
		combatReq = 15,
		xp = 80,
		stackable = false,
		value = 85,
		damage = 15,
		attackSpeed = 1.4,
		recipe = { ["Iron Bar"] = 2 },
		description = "A solid iron blade.",
	},
	["Gold Sword"] = {
		id = "gold_sword",
		type = "weapon",
		skill = "Smithing",
		levelReq = 45,
		combatReq = 40,
		xp = 120,
		stackable = false,
		value = 300,
		damage = 25,
		attackSpeed = 1.3,
		recipe = { ["Gold Bar"] = 3 },
		description = "A powerful gold sword.",
	},

	-- === COOKED FOOD ===
	["Cooked Shrimp"] = {
		id = "cooked_shrimp",
		type = "food",
		skill = "Cooking",
		levelReq = 1,
		xp = 20,
		stackable = true,
		value = 8,
		healAmount = 10,
		recipe = { ["Shrimp"] = 1 },
		description = "Heals 10 HP.",
	},
	["Cooked Trout"] = {
		id = "cooked_trout",
		type = "food",
		skill = "Cooking",
		levelReq = 20,
		xp = 40,
		stackable = true,
		value = 25,
		healAmount = 25,
		recipe = { ["Trout"] = 1 },
		description = "Heals 25 HP.",
	},
	["Cooked Lobster"] = {
		id = "cooked_lobster",
		type = "food",
		skill = "Cooking",
		levelReq = 40,
		xp = 65,
		stackable = true,
		value = 90,
		healAmount = 45,
		recipe = { ["Lobster"] = 1 },
		description = "Heals 45 HP.",
	},
	["Cooked Dark Crab"] = {
		id = "cooked_dark_crab",
		type = "food",
		skill = "Cooking",
		levelReq = 70,
		xp = 140,
		stackable = true,
		value = 350,
		healAmount = 70,
		recipe = { ["Dark Crab"] = 1 },
		description = "Heals 70 HP. The best food in the game.",
	},
}

-- Helper: get item by name
function ItemDatabase.GetItem(name)
	return ItemDatabase.Items[name]
end

-- Helper: get all items for a skill
function ItemDatabase.GetItemsBySkill(skill)
	local results = {}
	for name, item in pairs(ItemDatabase.Items) do
		if item.skill == skill then
			results[name] = item
		end
	end
	return results
end

-- Helper: get wilderness-only items
function ItemDatabase.GetWildernessItems()
	local results = {}
	for name, item in pairs(ItemDatabase.Items) do
		if item.wildernessOnly then
			results[name] = item
		end
	end
	return results
end

return ItemDatabase
