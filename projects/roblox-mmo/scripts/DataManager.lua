-- DataManager.lua (Script in ServerScriptService)
-- Handles saving/loading player data with DataStoreService

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Modules.Config)

local PlayerStore = DataStoreService:GetDataStore("PlayerData_v1")

local DataManager = {}
DataManager.PlayerData = {} -- cached data for online players

-- Default data for new players
local function getDefaultData()
	return {
		-- Skills (stored as total XP)
		Skills = {
			Mining = 0,
			Woodcutting = 0,
			Fishing = 0,
			Smithing = 0,
			Cooking = 0,
			Combat = 0,
		},

		-- Inventory: array of {name, quantity}
		Inventory = {},

		-- Bank: array of {name, quantity}
		Bank = {},

		-- Stats
		Gold = 0,
		TotalDeaths = 0,
		TotalKills = 0,
		PlayTime = 0,

		-- Settings
		PvPEnabled = true, -- can toggle off in safe zone (always on in wilderness)
		
		-- Timestamps
		FirstJoin = os.time(),
		LastSave = os.time(),
	}
end

-- Load player data
function DataManager.LoadData(player)
	local key = "Player_" .. player.UserId
	local success, data = pcall(function()
		return PlayerStore:GetAsync(key)
	end)

	if success and data then
		-- Merge with defaults (handles new fields added in updates)
		local defaults = getDefaultData()
		for k, v in pairs(defaults) do
			if data[k] == nil then
				data[k] = v
			end
		end
		for skillName, _ in pairs(defaults.Skills) do
			if data.Skills[skillName] == nil then
				data.Skills[skillName] = 0
			end
		end
		DataManager.PlayerData[player.UserId] = data
		print("[DataManager] Loaded data for " .. player.Name)
	else
		-- New player or load failed
		DataManager.PlayerData[player.UserId] = getDefaultData()
		print("[DataManager] Created new data for " .. player.Name)
	end

	return DataManager.PlayerData[player.UserId]
end

-- Save player data
function DataManager.SaveData(player)
	local data = DataManager.PlayerData[player.UserId]
	if not data then return end

	data.LastSave = os.time()
	local key = "Player_" .. player.UserId

	local success, err = pcall(function()
		PlayerStore:SetAsync(key, data)
	end)

	if success then
		print("[DataManager] Saved data for " .. player.Name)
	else
		warn("[DataManager] FAILED to save data for " .. player.Name .. ": " .. tostring(err))
	end
end

-- Get cached data (fast, no DataStore call)
function DataManager.GetData(player)
	return DataManager.PlayerData[player.UserId]
end

-- === SKILL HELPERS ===

function DataManager.AddSkillXP(player, skillName, amount)
	local data = DataManager.PlayerData[player.UserId]
	if not data or not data.Skills[skillName] then return end

	local oldLevel = Config.GetLevelFromXP(data.Skills[skillName])
	data.Skills[skillName] = data.Skills[skillName] + amount
	local newLevel = Config.GetLevelFromXP(data.Skills[skillName])

	-- Fire level up event if leveled
	if newLevel > oldLevel then
		local levelUpRemote = ReplicatedStorage.Remotes:FindFirstChild("LevelUp")
		if levelUpRemote then
			levelUpRemote:FireClient(player, skillName, newLevel)
		end
		print("[Skills] " .. player.Name .. " reached " .. skillName .. " level " .. newLevel .. "!")
	end

	-- Update client
	local xpUpdateRemote = ReplicatedStorage.Remotes:FindFirstChild("XPUpdate")
	if xpUpdateRemote then
		xpUpdateRemote:FireClient(player, skillName, data.Skills[skillName], newLevel)
	end
end

function DataManager.GetSkillLevel(player, skillName)
	local data = DataManager.PlayerData[player.UserId]
	if not data or not data.Skills[skillName] then return 1 end
	return Config.GetLevelFromXP(data.Skills[skillName])
end

-- === INVENTORY HELPERS ===

function DataManager.AddToInventory(player, itemName, quantity)
	local data = DataManager.PlayerData[player.UserId]
	if not data then return false end

	quantity = quantity or 1

	-- Check if item already in inventory (stackable)
	for _, slot in ipairs(data.Inventory) do
		if slot.name == itemName then
			slot.quantity = slot.quantity + quantity
			return true
		end
	end

	-- Check if inventory is full
	if #data.Inventory >= Config.MaxInventorySlots then
		return false -- inventory full
	end

	-- Add new slot
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
			if slot.quantity <= 0 then
				table.remove(data.Inventory, i)
			end
			return true
		end
	end

	return false -- item not found
end

function DataManager.HasItem(player, itemName, quantity)
	local data = DataManager.PlayerData[player.UserId]
	if not data then return false end

	quantity = quantity or 1

	for _, slot in ipairs(data.Inventory) do
		if slot.name == itemName and slot.quantity >= quantity then
			return true
		end
	end

	return false
end

-- === BANK HELPERS ===

function DataManager.DepositToBank(player, itemName, quantity)
	local data = DataManager.PlayerData[player.UserId]
	if not data then return false end

	-- Must have item in inventory
	if not DataManager.HasItem(player, itemName, quantity) then
		return false
	end

	-- Remove from inventory
	DataManager.RemoveFromInventory(player, itemName, quantity)

	-- Add to bank
	for _, slot in ipairs(data.Bank) do
		if slot.name == itemName then
			slot.quantity = slot.quantity + quantity
			return true
		end
	end

	if #data.Bank >= Config.MaxBankSlots then
		-- Bank full — put back in inventory
		DataManager.AddToInventory(player, itemName, quantity)
		return false
	end

	table.insert(data.Bank, { name = itemName, quantity = quantity })
	return true
end

function DataManager.WithdrawFromBank(player, itemName, quantity)
	local data = DataManager.PlayerData[player.UserId]
	if not data then return false end

	-- Find in bank
	for i, slot in ipairs(data.Bank) do
		if slot.name == itemName and slot.quantity >= quantity then
			-- Check inventory space
			if #data.Inventory >= Config.MaxInventorySlots then
				-- Check if item already exists in inventory (stackable)
				local found = false
				for _, invSlot in ipairs(data.Inventory) do
					if invSlot.name == itemName then
						found = true
						break
					end
				end
				if not found then return false end -- no space
			end

			slot.quantity = slot.quantity - quantity
			if slot.quantity <= 0 then
				table.remove(data.Bank, i)
			end

			DataManager.AddToInventory(player, itemName, quantity)
			return true
		end
	end

	return false
end

-- === DROP ALL INVENTORY (for PvP death) ===

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

-- === PLAYER CONNECT/DISCONNECT ===

Players.PlayerAdded:Connect(function(player)
	DataManager.LoadData(player)
end)

Players.PlayerRemoving:Connect(function(player)
	DataManager.SaveData(player)
	DataManager.PlayerData[player.UserId] = nil
end)

-- Auto-save every 5 minutes
task.spawn(function()
	while true do
		task.wait(300)
		for _, player in ipairs(Players:GetPlayers()) do
			DataManager.SaveData(player)
		end
		print("[DataManager] Auto-save complete for " .. #Players:GetPlayers() .. " players")
	end
end)

-- Save all on server shutdown
game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		DataManager.SaveData(player)
	end
end)

return DataManager
