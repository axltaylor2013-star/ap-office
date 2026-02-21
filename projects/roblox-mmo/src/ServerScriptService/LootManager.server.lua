--[[
	LootManager.server.lua
	Handles full-loot PvP death drops in the wilderness.
	When a player dies at Z < -100, all inventory items drop as a loot bag
	that any player can loot within 60 seconds.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

-- Modules
local DataManager = require(ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("DataManager", 5))

-- Config
local Config = {
	WildernessZ = -100,          -- Z threshold for wilderness
	LootDropDuration = 60,       -- seconds before bag despawns
	BagSize = Vector3.new(2, 2, 2),
	BagColor = Color3.fromRGB(139, 90, 43), -- brown sack
	GlowColor = Color3.fromRGB(240, 192, 64),
	MaxLootDistance = 10,
	CleanupInterval = 5,         -- seconds between cleanup sweeps
}

-- RemoteEvents
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local LootBagOpen = Remotes:WaitForChild("LootBagOpen", 10)
local LootBagTake = Remotes:WaitForChild("LootBagTake", 10)
local LootBagUpdate = Remotes:WaitForChild("LootBagUpdate", 10)

-- Active loot bags: bagId -> { model, contents, position, timestamp, owner }
local activeBags = {}

local nextBagId = 1

--------------------------------------------------------------------------------
-- Loot Bag Creation
--------------------------------------------------------------------------------

--- Build the 3D loot bag model at the given position
local function createBagModel(position, ownerName, bagId)
	local model = Instance.new("Model")
	model.Name = "LootBag_" .. bagId

	-- Primary part: the brown sack
	local part = Instance.new("Part")
	part.Name = "Sack"
	part.Size = Config.BagSize
	part.Position = position + Vector3.new(0, 1, 0) -- slightly above ground
	part.Anchored = true
	part.CanCollide = false
	part.Shape = Enum.PartType.Ball
	part.Color = Config.BagColor
	part.Material = Enum.Material.Fabric
	part.Parent = model

	model.PrimaryPart = part

	-- Glow effect
	local light = Instance.new("PointLight")
	light.Color = Config.GlowColor
	light.Brightness = 0.8
	light.Range = 6
	light.Parent = part

	-- BillboardGui label
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Size = UDim2.new(0, 200, 0, 60)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = part

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0.5, 0)
	title.BackgroundTransparency = 1
	title.Text = "💀 Loot Bag"
	title.TextColor3 = Config.GlowColor
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = billboard

	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.new(1, 0, 0.5, 0)
	subtitle.Position = UDim2.new(0, 0, 0.5, 0)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = ownerName
	subtitle.TextColor3 = Color3.new(1, 1, 1)
	subtitle.TextScaled = true
	subtitle.Font = Enum.Font.Gotham
	subtitle.Parent = billboard

	-- ClickDetector for interaction
	local click = Instance.new("ClickDetector")
	click.MaxActivationDistance = Config.MaxLootDistance
	click.Parent = part

	-- Store bagId as attribute for identification
	model:SetAttribute("BagId", bagId)

	-- Parent to workspace
	model.Parent = workspace

	return model
end

--- Drop all of a player's inventory as a loot bag at their death position
local function dropLootBag(player, deathPosition)
	-- Get player inventory from DataManager
	local inventory = DataManager:GetInventory(player)
	if not inventory or #inventory == 0 then
		return -- nothing to drop
	end

	local bagId = tostring(nextBagId)
	nextBagId += 1

	-- Deep copy inventory contents
	local contents = {}
	for _, item in inventory do
		table.insert(contents, table.clone(item))
	end

	-- Clear player's inventory
	DataManager:ClearInventory(player)

	-- Create bag
	local model = createBagModel(deathPosition, player.Name, bagId)

	activeBags[bagId] = {
		model = model,
		contents = contents,
		position = deathPosition,
		timestamp = os.clock(),
		ownerName = player.Name,
	}

	-- Wire up click detector
	local sack = model.PrimaryPart
	local clickDetector = sack:FindFirstChildOfClass("ClickDetector")
	clickDetector.MouseClick:Connect(function(looter)
		local bag = activeBags[bagId]
		if not bag then return end

		-- Send bag contents to the clicking player
		LootBagOpen:FireClient(looter, bagId, bag.contents, bag.ownerName)
	end)

	-- Auto-despawn via Debris as a safety net
	Debris:AddItem(model, Config.LootDropDuration + 1)

	print(string.format("[LootManager] %s dropped loot bag #%s (%d items) at %s",
		player.Name, bagId, #contents, tostring(deathPosition)))
end

--------------------------------------------------------------------------------
-- Loot Taking
--------------------------------------------------------------------------------

--- Handle a player requesting to take a single item from a bag
LootBagTake.OnServerEvent:Connect(function(player, bagId, itemIndex)
	local bag = activeBags[bagId]
	if not bag then return end

	-- Validate index
	if itemIndex < 1 or itemIndex > #bag.contents then return end

	-- Distance check
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	local dist = (character.HumanoidRootPart.Position - bag.position).Magnitude
	if dist > Config.MaxLootDistance + 2 then return end -- small grace

	-- Remove item from bag and give to player
	local item = table.remove(bag.contents, itemIndex)
	if not item then return end

	DataManager:AddItem(player, item)

	print(string.format("[LootManager] %s looted %s from bag #%s", player.Name, item.name or item.itemId, bagId))

	-- Notify all clients who might have this bag open
	if #bag.contents == 0 then
		-- Bag is empty, destroy it
		LootBagUpdate:FireAllClients(bagId, nil) -- nil = bag gone
		if bag.model then bag.model:Destroy() end
		activeBags[bagId] = nil
	else
		-- Update remaining contents
		LootBagUpdate:FireAllClients(bagId, bag.contents)
	end
end)

--------------------------------------------------------------------------------
-- Death Handling
--------------------------------------------------------------------------------

local function onCharacterAdded(player, character)
	local humanoid = character:WaitForChild("Humanoid", 5)

	humanoid.Died:Connect(function()
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		local pos = rootPart.Position

		-- Only drop loot in wilderness (Z < -100)
		if pos.Z < Config.WildernessZ then
			dropLootBag(player, pos)
		end
	end)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)

	-- Handle already-spawned character
	if player.Character then
		onCharacterAdded(player, player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
	onPlayerAdded(player)
end

--------------------------------------------------------------------------------
-- Cleanup Loop: remove expired bags
--------------------------------------------------------------------------------

task.spawn(function()
	while true do
		task.wait(Config.CleanupInterval)
		local now = os.clock()

		for bagId, bag in activeBags do
			if now - bag.timestamp >= Config.LootDropDuration then
				print(string.format("[LootManager] Bag #%s expired, destroying", bagId))
				LootBagUpdate:FireAllClients(bagId, nil)
				if bag.model then bag.model:Destroy() end
				activeBags[bagId] = nil
			end
		end
	end
end)

print("[LootManager] Loot system active!")
