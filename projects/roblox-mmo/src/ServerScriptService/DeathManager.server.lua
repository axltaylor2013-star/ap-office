--[[
	DeathManager.server.lua
	Server-side death and respawn system for the Wilderness MMO.
	- Wilderness deaths: drop ALL inventory (full loot PvP), create grave
	- Safe zone deaths: keep items, respawn at Haven
	- Death screen overlay with timer and respawn button
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local DataManager = require(ReplicatedStorage.Modules.DataManager)

------------------------------------------------------------
-- Remote Events
------------------------------------------------------------
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local PlayerDiedEvent = Remotes:WaitForChild("PlayerDied", 10)
local RespawnPlayerEvent = Remotes:WaitForChild("RespawnPlayer", 10)
local ShowDeathScreenEvent = Remotes:WaitForChild("ShowDeathScreen", 10)
local GraveInteractEvent = Remotes:WaitForChild("GraveInteract", 10)

------------------------------------------------------------
-- Constants
------------------------------------------------------------
local RESPAWN_POSITIONS = {
	Safe = Vector3.new(0, 15, 0), -- Haven City center (consistent with GameInit)
	Wilderness = Vector3.new(0, 15, 0), -- Still respawn at Haven
}

local GRAVE_LIFETIME = 120 -- 2 minutes in seconds
local DEATH_TIMER = 5 -- 5 seconds before can respawn

------------------------------------------------------------
-- Active Graves
------------------------------------------------------------
local activeGraves = {} -- [graveModel] = { owner, items, timestamp, position }

------------------------------------------------------------
-- Zone Detection
------------------------------------------------------------
local function getPlayerZone(player)
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return "Safe" -- Default to safe
	end

	local position = character.HumanoidRootPart.Position
	-- Simple zone detection - beyond 200 studs from Haven (50,15,50) is Wilderness
	local havenCenter = Vector3.new(50, 15, 50)
	local distance = (position - havenCenter).Magnitude

	if distance > 200 then
		return "Wilderness"
	else
		return "Safe"
	end
end

------------------------------------------------------------
-- Grave System
------------------------------------------------------------
local function createGrave(player, position, droppedItems)
	-- Create grave model
	local grave = Instance.new("Model")
	grave.Name = player.Name .. "'s Grave"
	grave.Parent = workspace

	-- Main gravestone
	local stone = Instance.new("Part")
	stone.Name = "Gravestone"
	stone.Size = Vector3.new(2, 3, 0.5)
	stone.Position = position + Vector3.new(0, 1.5, 0)
	stone.BrickColor = BrickColor.new("Dark stone grey")
	stone.Material = Enum.Material.Rock
	stone.Anchored = true
	stone.CanCollide = false
	stone.Parent = grave

	-- Make it slightly rounded
	local cornerRound = Instance.new("UICorner")
	cornerRound.CornerRadius = UDim.new(0, 8)

	-- Cross on top
	local cross = Instance.new("Part")
	cross.Name = "Cross"
	cross.Size = Vector3.new(0.8, 0.2, 0.2)
	cross.Position = stone.Position + Vector3.new(0, 1.7, 0)
	cross.BrickColor = BrickColor.new("Institutional white")
	cross.Material = Enum.Material.Marble
	cross.Anchored = true
	cross.CanCollide = false
	cross.Parent = grave

	local crossV = cross:Clone()
	crossV.Size = Vector3.new(0.2, 0.8, 0.2)
	crossV.Position = cross.Position
	crossV.Parent = grave

	-- Nameplate
	local nameGui = Instance.new("BillboardGui")
	nameGui.Size = UDim2.new(4, 0, 2, 0)
	nameGui.StudsOffset = Vector3.new(0, 1, 0)
	nameGui.Parent = stone

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = "RIP " .. player.Name
	nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.Antique
	nameLabel.Parent = nameGui

	local itemCountLabel = Instance.new("TextLabel")
	itemCountLabel.Size = UDim2.new(1, 0, 0.4, 0)
	itemCountLabel.Position = UDim2.new(0, 0, 0.6, 0)
	itemCountLabel.BackgroundTransparency = 1
	itemCountLabel.Text = #droppedItems .. " items"
	itemCountLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	itemCountLabel.TextScaled = true
	itemCountLabel.Font = Enum.Font.Gotham
	itemCountLabel.Parent = nameGui

	-- Click detection
	local detector = Instance.new("ClickDetector")
	detector.MaxActivationDistance = 10
	detector.Parent = stone

	-- Store grave info
	activeGraves[grave] = {
		owner = player.UserId,
		ownerName = player.Name,
		items = droppedItems,
		timestamp = tick(),
		position = position
	}

	-- Handle clicks
	detector.MouseClick:Connect(function(clickingPlayer)
		if activeGraves[grave] then
			local items = activeGraves[grave].items
			local owner = activeGraves[grave].owner

			-- Anyone can loot graves in Wilderness (full PvP loot)
			GraveInteractEvent:FireClient(clickingPlayer, {
				graveName = grave.Name,
				items = items,
				isOwner = clickingPlayer.UserId == owner,
				ownerName = activeGraves[grave].ownerName
			})
		end
	end)

	-- Auto-cleanup after lifetime
	Debris:AddItem(grave, GRAVE_LIFETIME)
	task.spawn(function()
		task.wait(GRAVE_LIFETIME)
		activeGraves[grave] = nil
	end)

	print("[DeathManager] Created grave for", player.Name, "with", #droppedItems, "items")
	return grave
end

local function lootGrave(player, graveName)
	-- Find the grave
	local grave = workspace:FindFirstChild(graveName)
	if not grave or not activeGraves[grave] then
		return
	end

	local graveData = activeGraves[grave]
	local items = graveData.items

	-- Add items to player inventory
	local playerData = DataManager:GetData(player)
	if playerData then
		playerData.Inventory = playerData.Inventory or {}
		
		for _, item in ipairs(items) do
			table.insert(playerData.Inventory, item)
		end

		DataManager:SaveData(player)
		print("[DeathManager]", player.Name, "looted grave with", #items, "items")
		
		-- Update inventory UI
		local invUpdateEvent = ReplicatedStorage:FindFirstChild("InventoryUpdate")
		if invUpdateEvent and invUpdateEvent:IsA("RemoteEvent") then
			local data = DataManager:GetData(player)
			if data and data.Inventory then
				invUpdateEvent:FireClient(player, data.Inventory)
			end
		end
	end

	-- Remove grave
	activeGraves[grave] = nil
	if grave.Parent then
		grave:Destroy()
	end
end

------------------------------------------------------------
-- Death Handling
------------------------------------------------------------

-- Respawn function (must be defined before handlePlayerDeath uses it)
local function respawnPlayer(player)
	-- Respawn player at Haven City
	local respawnPosition = RESPAWN_POSITIONS.Safe
	
	-- Load character
	player:LoadCharacter()
	
	-- Wait for character to load and teleport
	local character = player.CharacterAdded:Wait()
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
	
	-- Teleport to respawn position
	task.wait(0.1) -- Small delay to ensure character is fully loaded
	humanoidRootPart.CFrame = CFrame.new(respawnPosition)
	
	print("[DeathManager]", player.Name, "respawned at Haven City")
end

local function handlePlayerDeath(player, killer)
	local character = player.Character
	if not character then return end

	local zone = getPlayerZone(player)
	local deathPosition = character:FindFirstChild("HumanoidRootPart") and 
		character.HumanoidRootPart.Position or Vector3.new(50, 15, 50)

	local playerData = DataManager:GetData(player)
	if not playerData then return end

	-- Update death stats
	playerData.TotalDeaths = (playerData.TotalDeaths or 0) + 1
	if killer then
		local killerData = DataManager:GetData(killer)
		if killerData then
			killerData.TotalKills = (killerData.TotalKills or 0) + 1
			DataManager:SaveData(killer)
		end
	end

	local droppedItems = {}

	if zone == "Wilderness" then
		-- WILDERNESS DEATH: Drop everything
		print("[DeathManager]", player.Name, "died in Wilderness - dropping all items")
		
		-- Copy inventory to dropped items
		if playerData.Inventory then
			for _, item in ipairs(playerData.Inventory) do
				table.insert(droppedItems, {
					name = item.name,
					quantity = item.quantity
				})
			end
		end

		-- Clear inventory
		playerData.Inventory = {}

		-- Create grave with dropped items
		if #droppedItems > 0 then
			createGrave(player, deathPosition, droppedItems)
		end
	else
		-- SAFE ZONE DEATH: Keep items
		print("[DeathManager]", player.Name, "died in Safe zone - keeping items")
		-- Items stay in inventory, no grave created
	end

	-- Save player data
	DataManager:SaveData(player)

	-- Show death screen
	ShowDeathScreenEvent:FireClient(player, {
		zone = zone,
		droppedItemCount = #droppedItems,
		killer = killer and killer.Name or nil,
		deathTimer = DEATH_TIMER
	})

	-- Force respawn after timer
	task.spawn(function()
		task.wait(DEATH_TIMER)
		respawnPlayer(player)
	end)

	print("[DeathManager]", player.Name, "died in", zone, "- dropped", #droppedItems, "items")
end

------------------------------------------------------------
-- Event Handlers
------------------------------------------------------------

-- Listen for player deaths
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid", 5)
		
		humanoid.Died:Connect(function()
			-- Try to find who killed the player (basic implementation)
			local killer = nil
			local lastDamager = character:FindFirstChild("LastDamager")
			if lastDamager and lastDamager.Value and lastDamager.Value.Parent then
				killer = Players:GetPlayerFromCharacter(lastDamager.Value.Parent)
			end
			
			handlePlayerDeath(player, killer)
		end)
	end)
end)

-- Handle respawn requests
RespawnPlayerEvent.OnServerEvent:Connect(function(player)
	respawnPlayer(player)
end)

-- Handle grave looting
GraveInteractEvent.OnServerEvent:Connect(function(player, graveName)
	lootGrave(player, graveName)
end)

------------------------------------------------------------
-- Cleanup
------------------------------------------------------------

-- Clean up graves periodically
task.spawn(function()
	while true do
		task.wait(30) -- Check every 30 seconds
		
		local currentTime = tick()
		for grave, data in pairs(activeGraves) do
			if currentTime - data.timestamp > GRAVE_LIFETIME then
				activeGraves[grave] = nil
				if grave.Parent then
					grave:Destroy()
				end
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	-- Clean up any data related to the leaving player
	-- Graves will persist for other players to loot
end)

print("[DeathManager] Death and respawn system initialized")
