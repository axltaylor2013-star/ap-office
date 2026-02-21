-- DataManager.lua (ModuleScript in ReplicatedStorage/Modules)
-- Handles saving/loading player data with DataStoreService and comprehensive error handling

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load ErrorHandler first
local ErrorHandler
local success, err = pcall(function()
	ErrorHandler = require(script.Parent:WaitForChild("ErrorHandler", 5))
end)

if not success then
	-- Fallback if ErrorHandler fails to load
	warn("[DataManager] ErrorHandler not available: " .. tostring(err))
	ErrorHandler = {
		LogInfo = function(self, msg, data) warn(tostring(msg)) end,
		LogWarning = function(self, msg, data) warn(tostring(msg)) end,
		LogError = function(self, msg, data) warn(tostring(msg)) end,
		SafeDataStoreOperation = function(self, opName, callback, fallback)
			local s, r = pcall(callback)
			return s and r or fallback
		end,
		ValidateNotNil = function(self, val, ctx, fallback) return val or fallback end
	}
end

ErrorHandler:LogInfo("DataManager loading...")

-- Load Config with error handling
local Config
local configSuccess, configErr = pcall(function()
	Config = require(script.Parent:WaitForChild("Config", 5))
end)

if not configSuccess then
	ErrorHandler:LogWarning("Config module not available, using defaults", {error = configErr})
	Config = {
		DATASTORE_NAME = "PlayerData_v1",
		AUTOSAVE_INTERVAL = 60,
		MAX_DATA_SIZE = 10000
	}
end

-- Check if DataStore is available
local dataStoreAvailable = false
local PlayerStore
local memoryCache = {} -- In-memory fallback storage

local function initializeDataStore()
	return ErrorHandler:SafeDataStoreOperation("GetDataStore", function()
		PlayerStore = DataStoreService:GetDataStore(Config.DATASTORE_NAME or "PlayerData_v1")
		dataStoreAvailable = true
		return true
	end, false)
end

-- Initialize DataStore
local initSuccess = initializeDataStore()
if not initSuccess then
	ErrorHandler:LogWarning("DataStore initialization failed, using memory cache only")
	dataStoreAvailable = false
end

local DataManager = {}
DataManager.PlayerData = {}
DataManager.PendingSaves = {}
DataManager.SaveQueue = {}

-- Default player data template
local function getDefaultData()
	return {
		Skills = {
			Mining = 0, Woodcutting = 0, Fishing = 0,
			Smithing = 0, Cooking = 0, Strength = 0, Defense = 0,
			Ranged = 0, Fletching = 0, Prayer = 0,
			Magic = 0, Herblore = 0, Crafting = 0,
			Attack = 0, Hitpoints = 10
		},
		Inventory = {},
		Bank = {},
		Equipment = {
			Head = "", Body = "", Legs = "", 
			Weapon = "", Shield = "", Tool = "", 
			Cape = "", Ammo = "", Ring = "", Neck = ""
		},
		Gold = 0,
		TotalDeaths = 0,
		TotalKills = 0,
		PlayTime = 0,
		PvPEnabled = true,
		FirstJoin = os.time(),
		LastSave = os.time(),
		Hotbar = {},
		Prestige = 0,
		PrayerPoints = 10,
		ActivePrayers = {},
		Quests = {},
		Settings = {
			musicVolume = 0.5,
			sfxVolume = 0.7,
			uiScale = 1.0,
			chatEnabled = true
		}
	}
end

-- Safe data loading with fallback
function DataManager:LoadData(player)
	local userId = tostring(player.UserId)
	local playerData
	
	-- Try DataStore first if available
	if dataStoreAvailable then
		playerData = ErrorHandler:SafeDataStoreOperation(
			"LoadData",
			function()
				return PlayerStore:GetAsync(userId)
			end,
			nil
		)
	end
	
	-- If DataStore failed or returned nil, try memory cache
	if not playerData then
		playerData = memoryCache[userId]
		if playerData then
			ErrorHandler:LogInfo("Loaded from memory cache", {player = player.Name})
		end
	end
	
	-- If still no data, create default
	if not playerData then
		playerData = getDefaultData()
		ErrorHandler:LogInfo("Created new player data", {player = player.Name})
	else
		-- Validate and repair existing data
		playerData = self:_validateAndRepairData(playerData, player)
	end
	
	-- Store in memory
	self.PlayerData[userId] = playerData
	memoryCache[userId] = playerData
	
	ErrorHandler:LogInfo("Data loaded successfully", {
		player = player.Name,
		fromDataStore = dataStoreAvailable and playerData ~= memoryCache[userId],
		gold = playerData.Gold
	})
	
	return playerData
end

-- Safe data saving with queue system
function DataManager:SaveData(player, immediate)
	local userId = tostring(player.UserId)
	local playerData = self.PlayerData[userId]
	
	if not playerData then
		ErrorHandler:LogWarning("No data to save", {player = player.Name})
		return false
	end
	
	-- Update timestamp
	playerData.LastSave = os.time()
	
	-- Queue the save
	self.SaveQueue[userId] = {
		data = playerData,
		timestamp = os.time(),
		playerName = player.Name
	}
	
	-- Immediate save requested
	if immediate then
		return self:_processSaveQueue(userId)
	end
	
	return true
end

-- Process save queue for a specific player
function DataManager:_processSaveQueue(userId)
	local saveJob = self.SaveQueue[userId]
	if not saveJob then return true end
	
	local success = ErrorHandler:SafeDataStoreOperation(
		"SaveData",
		function()
			if dataStoreAvailable then
				PlayerStore:SetAsync(userId, saveJob.data)
				return true
			end
			return false
		end,
		false
	)
	
	if success then
		ErrorHandler:LogDebug("Data saved successfully", {
			player = saveJob.playerName,
			timestamp = saveJob.timestamp
		})
		self.SaveQueue[userId] = nil
	else
		-- Store in memory cache as fallback
		memoryCache[userId] = saveJob.data
		ErrorHandler:LogWarning("DataStore save failed, stored in memory", {
			player = saveJob.playerName
		})
	end
	
	return success
end

-- Get player data (safe)
function DataManager:GetData(player)
	local userId = tostring(player.UserId)
	local data = self.PlayerData[userId]
	
	if not data then
		ErrorHandler:LogWarning("Data not found, loading...", {player = player.Name})
		data = self:LoadData(player)
	end
	
	return ErrorHandler:ValidateNotNil(data, {player = player.Name}, getDefaultData())
end

-- Update player data (safe)
function DataManager:UpdateData(player, updates)
	local userId = tostring(player.UserId)
	local playerData = self:GetData(player)
	
	if not playerData then
		ErrorHandler:LogError("Cannot update nil player data", {player = player.Name})
		return false
	end
	
	-- Apply updates
	for key, value in pairs(updates) do
		if type(value) == "table" then
			playerData[key] = playerData[key] or {}
			for subKey, subValue in pairs(value) do
				playerData[key][subKey] = subValue
			end
		else
			playerData[key] = value
		end
	end
	
	-- Update storage
	self.PlayerData[userId] = playerData
	memoryCache[userId] = playerData
	
	ErrorHandler:LogDebug("Data updated", {
		player = player.Name,
		updates = updates
	})
	
	return true
end

-- Validate and repair player data
function DataManager:_validateAndRepairData(data, player)
	local defaultData = getDefaultData()
	local repaired = false
	
	-- Ensure all top-level fields exist
	for key, defaultValue in pairs(defaultData) do
		if data[key] == nil then
			data[key] = defaultValue
			repaired = true
		end
	end
	
	-- Ensure Skills table is complete
	if data.Skills then
		for skillName, defaultLevel in pairs(defaultData.Skills) do
			if data.Skills[skillName] == nil then
				data.Skills[skillName] = defaultLevel
				repaired = true
			end
		end
	end
	
	-- Ensure Equipment table is complete
	if data.Equipment then
		for slot, defaultItem in pairs(defaultData.Equipment) do
			if data.Equipment[slot] == nil then
				data.Equipment[slot] = defaultItem
				repaired = true
			end
		end
	end
	
	-- Validate numeric values
	local numericFields = {"Gold", "TotalDeaths", "TotalKills", "PlayTime", "Prestige", "PrayerPoints"}
	for _, field in ipairs(numericFields) do
		if type(data[field]) ~= "number" or data[field] < 0 then
			data[field] = defaultData[field] or 0
			repaired = true
		end
	end
	
	if repaired then
		ErrorHandler:LogInfo("Repaired player data", {player = player.Name})
	end
	
	return data
end

-- Auto-save system
local autoSaveConnections = {}

function DataManager:EnableAutoSave(player, interval)
	interval = interval or Config.AUTOSAVE_INTERVAL or 60
	
	local userId = tostring(player.UserId)
	
	-- Remove existing auto-save if any
	if autoSaveConnections[userId] then
		autoSaveConnections[userId]:Disconnect()
	end
	
	-- Create new auto-save
	autoSaveConnections[userId] = game:GetService("RunService").Heartbeat:Connect(function()
		local playerData = self.PlayerData[userId]
		if playerData and os.time() - playerData.LastSave >= interval then
			self:SaveData(player)
		end
	end)
	
	ErrorHandler:LogInfo("Auto-save enabled", {
		player = player.Name,
		interval = interval
	})
end

function DataManager:DisableAutoSave(player)
	local userId = tostring(player.UserId)
	if autoSaveConnections[userId] then
		autoSaveConnections[userId]:Disconnect()
		autoSaveConnections[userId] = nil
	end
end

-- Player event handlers
Players.PlayerAdded:Connect(function(player)
	ErrorHandler:LogInfo("Player added, loading data", {player = player.Name})
	
	-- Load data with retry
	local retries = 0
	local maxRetries = 3
	
	while retries < maxRetries do
		local success = pcall(function()
			DataManager:LoadData(player)
		end)
		
		if success then
			DataManager:EnableAutoSave(player)
			break
		else
			retries = retries + 1
			ErrorHandler:LogWarning("Data load failed, retrying...", {
				player = player.Name,
				retry = retries,
				maxRetries = maxRetries
			})
			wait(1)
		end
	end
	
	if retries >= maxRetries then
		ErrorHandler:LogError("Failed to load player data after retries", {player = player.Name})
	end
end)

Players.PlayerRemoving:Connect(function(player)
	ErrorHandler:LogInfo("Player leaving, saving data", {player = player.Name})
	
	-- Save data immediately
	DataManager:SaveData(player, true)
	
	-- Clean up
	local userId = tostring(player.UserId)
	DataManager:DisableAutoSave(player)
	DataManager.PlayerData[userId] = nil
	DataManager.SaveQueue[userId] = nil
end)

-- Periodic save queue processing
game:GetService("RunService").Heartbeat:Connect(function()
	for userId, saveJob in pairs(DataManager.SaveQueue) do
		if os.time() - saveJob.timestamp >= 5 then -- Process after 5 seconds
			DataManager:_processSaveQueue(userId)
		end
	end
end)

-- Emergency save on shutdown
game:BindToClose(function()
	ErrorHandler:LogInfo("Server shutting down, saving all data")
	
	for _, player in ipairs(Players:GetPlayers()) do
		pcall(function()
			DataManager:SaveData(player, true)
		end)
	end
	
	-- Process all remaining saves
	for userId, _ in pairs(DataManager.SaveQueue) do
		pcall(function()
			DataManager:_processSaveQueue(userId)
		end)
	end
	
	ErrorHandler:LogInfo("Emergency save complete")
end)

ErrorHandler:LogInfo("DataManager initialized successfully", {
	dataStoreAvailable = dataStoreAvailable,
	autoSaveInterval = Config.AUTOSAVE_INTERVAL or 60
})

return DataManager