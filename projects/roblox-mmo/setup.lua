-- WILDERNESS SETUP SCRIPT
-- Paste this entire thing into the Command Bar in Roblox Studio and press Enter
-- It will create all folders, scripts, and remote events

local SS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")

-- Clean up existing stuff from bad XML load
for _, child in ipairs(RS:GetChildren()) do if child.Name == "Folder" or child.Name == "Script" or child.Name == "ModuleScript" then child:Destroy() end end
for _, child in ipairs(SS:GetChildren()) do if child.Name == "Script" then child:Destroy() end end
for _, child in ipairs(WS:GetChildren()) do if child.Name == "Script" or child.Name == "Folder" then child:Destroy() end end

-- === REPLICATED STORAGE ===
local modules = Instance.new("Folder")
modules.Name = "Modules"
modules.Parent = RS

local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = RS

-- Remote Events
local re1 = Instance.new("RemoteEvent") re1.Name = "LevelUp" re1.Parent = remotes
local re2 = Instance.new("RemoteEvent") re2.Name = "XPUpdate" re2.Parent = remotes
local re3 = Instance.new("RemoteEvent") re3.Name = "InventoryUpdate" re3.Parent = remotes

-- Config ModuleScript
local config = Instance.new("ModuleScript")
config.Name = "Config"
config.Parent = modules
config.Source = [==[
local Config = {}

Config.Skills = {
	Mining = { maxLevel = 99, baseXP = 50 },
	Woodcutting = { maxLevel = 99, baseXP = 45 },
	Fishing = { maxLevel = 99, baseXP = 40 },
	Smithing = { maxLevel = 99, baseXP = 60 },
	Cooking = { maxLevel = 99, baseXP = 55 },
	Combat = { maxLevel = 99, baseXP = 70 },
}

function Config.GetXPForLevel(level)
	return math.floor(level * level * 100)
end

function Config.GetLevelFromXP(totalXP)
	local level = 1
	while Config.GetXPForLevel(level + 1) <= totalXP and level < 99 do
		level = level + 1
	end
	return level
end

Config.MaxInventorySlots = 28
Config.MaxBankSlots = 100
Config.WildernessEnabled = true
Config.SafeZoneOnDeath = true
Config.LootDropDuration = 60
Config.BaseHealth = 100
Config.HealthPerCombatLevel = 5
Config.RespawnTime = 5
Config.AttackCooldown = 1.5
Config.ResourceRespawnTime = { Tree = 15, Rock = 20, FishingSpot = 10 }
Config.Zones = { SafeZone = "SafeZone", Wilderness = "Wilderness" }

return Config
]==]

-- ItemDatabase ModuleScript
local itemDB = Instance.new("ModuleScript")
itemDB.Name = "ItemDatabase"
itemDB.Parent = modules
itemDB.Source = [==[
local ItemDatabase = {}

ItemDatabase.Items = {
	["Copper Ore"] = { id = "copper_ore", type = "resource", skill = "Mining", levelReq = 1, xp = 20, stackable = true, value = 5, description = "A chunk of copper ore." },
	["Iron Ore"] = { id = "iron_ore", type = "resource", skill = "Mining", levelReq = 15, xp = 35, stackable = true, value = 15, description = "A chunk of iron ore." },
	["Gold Ore"] = { id = "gold_ore", type = "resource", skill = "Mining", levelReq = 40, xp = 65, stackable = true, value = 50, description = "A chunk of gold ore." },
	["Runite Ore"] = { id = "runite_ore", type = "resource", skill = "Mining", levelReq = 70, xp = 125, stackable = true, value = 200, description = "Extremely rare. Wilderness only.", wildernessOnly = true },

	["Oak Log"] = { id = "oak_log", type = "resource", skill = "Woodcutting", levelReq = 1, xp = 18, stackable = true, value = 4, description = "A sturdy oak log." },
	["Willow Log"] = { id = "willow_log", type = "resource", skill = "Woodcutting", levelReq = 20, xp = 40, stackable = true, value = 12, description = "A flexible willow log." },
	["Yew Log"] = { id = "yew_log", type = "resource", skill = "Woodcutting", levelReq = 50, xp = 80, stackable = true, value = 75, description = "Dense yew wood." },
	["Magic Log"] = { id = "magic_log", type = "resource", skill = "Woodcutting", levelReq = 75, xp = 150, stackable = true, value = 250, description = "Pulsing with energy. Wilderness only.", wildernessOnly = true },

	["Shrimp"] = { id = "shrimp", type = "resource", skill = "Fishing", levelReq = 1, xp = 15, stackable = true, value = 3, cookable = true, healAmount = 5, description = "A small shrimp." },
	["Trout"] = { id = "trout", type = "resource", skill = "Fishing", levelReq = 20, xp = 35, stackable = true, value = 10, cookable = true, healAmount = 15, description = "A fresh trout." },
	["Lobster"] = { id = "lobster", type = "resource", skill = "Fishing", levelReq = 40, xp = 60, stackable = true, value = 40, cookable = true, healAmount = 30, description = "A large lobster." },
	["Dark Crab"] = { id = "dark_crab", type = "resource", skill = "Fishing", levelReq = 70, xp = 130, stackable = true, value = 180, cookable = true, healAmount = 50, description = "Wilderness only.", wildernessOnly = true },

	["Copper Bar"] = { id = "copper_bar", type = "crafted", skill = "Smithing", levelReq = 1, xp = 25, stackable = true, value = 12, recipe = { ["Copper Ore"] = 1 }, description = "A smelted copper bar." },
	["Iron Bar"] = { id = "iron_bar", type = "crafted", skill = "Smithing", levelReq = 15, xp = 45, stackable = true, value = 35, recipe = { ["Iron Ore"] = 1 }, description = "A smelted iron bar." },
	["Gold Bar"] = { id = "gold_bar", type = "crafted", skill = "Smithing", levelReq = 40, xp = 75, stackable = true, value = 120, recipe = { ["Gold Ore"] = 1 }, description = "A gleaming gold bar." },

	["Copper Sword"] = { id = "copper_sword", type = "weapon", skill = "Smithing", levelReq = 1, combatReq = 1, xp = 50, stackable = false, value = 30, damage = 8, attackSpeed = 1.5, recipe = { ["Copper Bar"] = 2 }, description = "A basic copper sword." },
	["Iron Sword"] = { id = "iron_sword", type = "weapon", skill = "Smithing", levelReq = 20, combatReq = 15, xp = 80, stackable = false, value = 85, damage = 15, attackSpeed = 1.4, recipe = { ["Iron Bar"] = 2 }, description = "A solid iron blade." },
	["Gold Sword"] = { id = "gold_sword", type = "weapon", skill = "Smithing", levelReq = 45, combatReq = 40, xp = 120, stackable = false, value = 300, damage = 25, attackSpeed = 1.3, recipe = { ["Gold Bar"] = 3 }, description = "A powerful gold sword." },

	["Cooked Shrimp"] = { id = "cooked_shrimp", type = "food", skill = "Cooking", levelReq = 1, xp = 20, stackable = true, value = 8, healAmount = 10, recipe = { ["Shrimp"] = 1 }, description = "Heals 10 HP." },
	["Cooked Trout"] = { id = "cooked_trout", type = "food", skill = "Cooking", levelReq = 20, xp = 40, stackable = true, value = 25, healAmount = 25, recipe = { ["Trout"] = 1 }, description = "Heals 25 HP." },
	["Cooked Lobster"] = { id = "cooked_lobster", type = "food", skill = "Cooking", levelReq = 40, xp = 65, stackable = true, value = 90, healAmount = 45, recipe = { ["Lobster"] = 1 }, description = "Heals 45 HP." },
	["Cooked Dark Crab"] = { id = "cooked_dark_crab", type = "food", skill = "Cooking", levelReq = 70, xp = 140, stackable = true, value = 350, healAmount = 70, recipe = { ["Dark Crab"] = 1 }, description = "Heals 70 HP. Best food in the game." },
}

function ItemDatabase.GetItem(name) return ItemDatabase.Items[name] end

function ItemDatabase.GetItemsBySkill(skill)
	local results = {}
	for name, item in pairs(ItemDatabase.Items) do
		if item.skill == skill then results[name] = item end
	end
	return results
end

function ItemDatabase.GetWildernessItems()
	local results = {}
	for name, item in pairs(ItemDatabase.Items) do
		if item.wildernessOnly then results[name] = item end
	end
	return results
end

return ItemDatabase
]==]

-- === SERVER SCRIPT SERVICE ===
local dataManager = Instance.new("Script")
dataManager.Name = "DataManager"
dataManager.Parent = SS
dataManager.Source = [==[
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Modules.Config)

local PlayerStore = DataStoreService:GetDataStore("PlayerData_v1")

local DataManager = {}
DataManager.PlayerData = {}

local function getDefaultData()
	return {
		Skills = {
			Mining = 0, Woodcutting = 0, Fishing = 0,
			Smithing = 0, Cooking = 0, Combat = 0,
		},
		Inventory = {},
		Bank = {},
		Gold = 0,
		TotalDeaths = 0,
		TotalKills = 0,
		PlayTime = 0,
		PvPEnabled = true,
		FirstJoin = os.time(),
		LastSave = os.time(),
	}
end

function DataManager.LoadData(player)
	local key = "Player_" .. player.UserId
	local success, data = pcall(function() return PlayerStore:GetAsync(key) end)
	if success and data then
		local defaults = getDefaultData()
		for k, v in pairs(defaults) do
			if data[k] == nil then data[k] = v end
		end
		for skillName, _ in pairs(defaults.Skills) do
			if data.Skills[skillName] == nil then data.Skills[skillName] = 0 end
		end
		DataManager.PlayerData[player.UserId] = data
		print("[DataManager] Loaded data for " .. player.Name)
	else
		DataManager.PlayerData[player.UserId] = getDefaultData()
		print("[DataManager] Created new data for " .. player.Name)
	end
	return DataManager.PlayerData[player.UserId]
end

function DataManager.SaveData(player)
	local data = DataManager.PlayerData[player.UserId]
	if not data then return end
	data.LastSave = os.time()
	local key = "Player_" .. player.UserId
	local success, err = pcall(function() PlayerStore:SetAsync(key, data) end)
	if success then
		print("[DataManager] Saved data for " .. player.Name)
	else
		warn("[DataManager] FAILED to save for " .. player.Name .. ": " .. tostring(err))
	end
end

function DataManager.GetData(player) return DataManager.PlayerData[player.UserId] end

function DataManager.AddSkillXP(player, skillName, amount)
	local data = DataManager.PlayerData[player.UserId]
	if not data or not data.Skills[skillName] then return end
	local oldLevel = Config.GetLevelFromXP(data.Skills[skillName])
	data.Skills[skillName] = data.Skills[skillName] + amount
	local newLevel = Config.GetLevelFromXP(data.Skills[skillName])
	if newLevel > oldLevel then
		local remote = ReplicatedStorage.Remotes:FindFirstChild("LevelUp")
		if remote then remote:FireClient(player, skillName, newLevel) end
		print("[Skills] " .. player.Name .. " reached " .. skillName .. " level " .. newLevel)
	end
	local xpRemote = ReplicatedStorage.Remotes:FindFirstChild("XPUpdate")
	if xpRemote then xpRemote:FireClient(player, skillName, data.Skills[skillName], newLevel) end
end

function DataManager.GetSkillLevel(player, skillName)
	local data = DataManager.PlayerData[player.UserId]
	if not data or not data.Skills[skillName] then return 1 end
	return Config.GetLevelFromXP(data.Skills[skillName])
end

function DataManager.AddToInventory(player, itemName, quantity)
	local data = DataManager.PlayerData[player.UserId]
	if not data then return false end
	quantity = quantity or 1
	for _, slot in ipairs(data.Inventory) do
		if slot.name == itemName then slot.quantity = slot.quantity + quantity return true end
	end
	if #data.Inventory >= Config.MaxInventorySlots then return false end
	table.insert(data.Inventory, { name = itemName, quantity = quantity })
	return true
end

function DataManager.RemoveFromInventory(player, itemName, quantity)
	local data = DataManager.PlayerData[player.UserId]
	if not data then return false end
	quantity = quantity or 1
	for i, slot in ipairs(data.Inventory) do
		if slot.name == itemName then
			slot.quantity = slot.quantity - quantity
			if slot.quantity <= 0 then table.remove(data.Inventory, i) end
			return true
		end
	end
	return false
end

function DataManager.HasItem(player, itemName, quantity)
	local data = DataManager.PlayerData[player.UserId]
	if not data then return false end
	quantity = quantity or 1
	for _, slot in ipairs(data.Inventory) do
		if slot.name == itemName and slot.quantity >= quantity then return true end
	end
	return false
end

function DataManager.DepositToBank(player, itemName, quantity)
	local data = DataManager.PlayerData[player.UserId]
	if not data then return false end
	if not DataManager.HasItem(player, itemName, quantity) then return false end
	DataManager.RemoveFromInventory(player, itemName, quantity)
	for _, slot in ipairs(data.Bank) do
		if slot.name == itemName then slot.quantity = slot.quantity + quantity return true end
	end
	if #data.Bank >= Config.MaxBankSlots then
		DataManager.AddToInventory(player, itemName, quantity)
		return false
	end
	table.insert(data.Bank, { name = itemName, quantity = quantity })
	return true
end

function DataManager.WithdrawFromBank(player, itemName, quantity)
	local data = DataManager.PlayerData[player.UserId]
	if not data then return false end
	for i, slot in ipairs(data.Bank) do
		if slot.name == itemName and slot.quantity >= quantity then
			if #data.Inventory >= Config.MaxInventorySlots then
				local found = false
				for _, invSlot in ipairs(data.Inventory) do
					if invSlot.name == itemName then found = true break end
				end
				if not found then return false end
			end
			slot.quantity = slot.quantity - quantity
			if slot.quantity <= 0 then table.remove(data.Bank, i) end
			DataManager.AddToInventory(player, itemName, quantity)
			return true
		end
	end
	return false
end

function DataManager.GetAndClearInventory(player)
	local data = DataManager.PlayerData[player.UserId]
	if not data then return {} end
	local dropped = {}
	for _, slot in ipairs(data.Inventory) do
		table.insert(dropped, { name = slot.name, quantity = slot.quantity })
	end
	data.Inventory = {}
	data.TotalDeaths = data.TotalDeaths + 1
	return dropped
end

Players.PlayerAdded:Connect(function(player) DataManager.LoadData(player) end)
Players.PlayerRemoving:Connect(function(player) DataManager.SaveData(player) DataManager.PlayerData[player.UserId] = nil end)

task.spawn(function()
	while true do
		task.wait(300)
		for _, player in ipairs(Players:GetPlayers()) do DataManager.SaveData(player) end
		print("[DataManager] Auto-save complete for " .. #Players:GetPlayers() .. " players")
	end
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do DataManager.SaveData(player) end
end)

return DataManager
]==]

-- === WORKSPACE FOLDERS ===
local safeZone = Instance.new("Folder") safeZone.Name = "SafeZone" safeZone.Parent = WS
local wilderness = Instance.new("Folder") wilderness.Name = "Wilderness" wilderness.Parent = WS
local resourceNodes = Instance.new("Folder") resourceNodes.Name = "ResourceNodes" resourceNodes.Parent = WS

-- === WILDERNESS BORDER WALL ===
local border = Instance.new("Part")
border.Name = "WildernessBorder"
border.Size = Vector3.new(512, 50, 2)
border.Position = Vector3.new(0, 25, -100)
border.Anchored = true
border.Transparency = 0.7
border.BrickColor = BrickColor.new("Really red")
border.CanCollide = false
border.Parent = WS

-- Warning text on the border
local billboardGui = Instance.new("BillboardGui")
billboardGui.Size = UDim2.new(20, 0, 5, 0)
billboardGui.StudsOffset = Vector3.new(0, 10, 0)
billboardGui.Parent = border

local warningLabel = Instance.new("TextLabel")
warningLabel.Size = UDim2.new(1, 0, 1, 0)
warningLabel.BackgroundTransparency = 1
warningLabel.Text = "⚠️ WILDERNESS - FULL LOOT PVP ⚠️"
warningLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
warningLabel.TextScaled = true
warningLabel.Font = Enum.Font.GothamBold
warningLabel.Parent = billboardGui

print("✅ Wilderness project setup complete!")
print("   - Config module loaded")
print("   - ItemDatabase loaded (22 items)")
print("   - DataManager loaded (save/load/inventory/bank)")
print("   - 3 RemoteEvents created")
print("   - Wilderness border wall placed")
print("   - Folder structure ready")
