-- DataManager.lua (ModuleScript in ReplicatedStorage/Modules)
-- Handles saving/loading player data with DataStoreService

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[DataManager] Loading...")
local Config = require(script.Parent:WaitForChild("Config"))
print("[DataManager] Config loaded!")

-- Check if DataStore is available (requires published place)
local dataStoreAvailable = false
local PlayerStore
pcall(function()
	PlayerStore = DataStoreService:GetDataStore("PlayerData_v1")
	dataStoreAvailable = true
end)

if not dataStoreAvailable then
	warn("[DataManager] DataStore not available (place not published) — using in-memory storage. Data will NOT save between sessions.")
end

-- PlayerStore initialized above

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
	if dataStoreAvailable then
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
			print("[DataManager] Loaded saved data for " .. player.Name)
			return DataManager.PlayerData[player.UserId]
		end
	end
	-- New player or DataStore unavailable
	DataManager.PlayerData[player.UserId] = getDefaultData()
	print("[DataManager] Created fresh data for " .. player.Name)
	return DataManager.PlayerData[player.UserId]
end

function DataManager.SaveData(player)
	local data = DataManager.PlayerData[player.UserId]
	if not data then return end
	data.LastSave = os.time()
	if not dataStoreAvailable then return end -- skip save if no DataStore
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

return DataManager
