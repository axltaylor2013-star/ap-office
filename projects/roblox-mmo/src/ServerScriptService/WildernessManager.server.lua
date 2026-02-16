-- WildernessManager.server.lua
-- Handles PvP zone detection, full-loot death, and loot drops

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Modules.Config)

local DataManager = require(ReplicatedStorage.Modules.DataManager)

-- Track which players are in the wilderness
local playersInWilderness = {}

-- Wilderness boundary (Z < -100)
local WILDERNESS_Z = -100

-- === ZONE DETECTION ===
local function isInWilderness(position)
	return position.Z < WILDERNESS_Z
end

print("[WildernessManager] Waiting for Remotes...")
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
if not Remotes then
	warn("[WildernessManager] ERROR: Remotes folder not found!")
end
local zoneRemote = Remotes and Remotes:WaitForChild("ZoneChanged", 10)
if not zoneRemote then
	warn("[WildernessManager] ERROR: ZoneChanged remote not found!")
end
print("[WildernessManager] Remotes connected!")

-- Monitor player positions
task.spawn(function()
	while true do
		task.wait(0.5)
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			if character then
				local root = character:FindFirstChild("HumanoidRootPart")
				if root then
					local wasInWild = playersInWilderness[player.UserId]
					local isInWild = isInWilderness(root.Position)

					if isInWild and not wasInWild then
						-- Entered wilderness
						playersInWilderness[player.UserId] = true
						zoneRemote:FireClient(player, "Wilderness")
						print("[Wilderness] " .. player.Name .. " entered the Wilderness!")
					elseif not isInWild and wasInWild then
						-- Left wilderness
						playersInWilderness[player.UserId] = false
						zoneRemote:FireClient(player, "SafeZone")
						print("[Wilderness] " .. player.Name .. " returned to safety.")
					end
				end
			end
		end
	end
end)

-- === LOOT DROP SYSTEM ===

local function createLootPile(position, items, killerName)
	if #items == 0 then return end

	local lootPart = Instance.new("Part")
	lootPart.Name = "LootPile"
	lootPart.Size = Vector3.new(3, 1, 3)
	lootPart.Position = position + Vector3.new(0, 1, 0)
	lootPart.Anchored = true
	lootPart.CanCollide = false
	lootPart.BrickColor = BrickColor.new("Bright yellow")
	lootPart.Material = Enum.Material.Neon
	lootPart.Shape = Enum.PartType.Cylinder
	lootPart.Transparency = 0.3
	lootPart.Parent = Workspace

	-- Floating text
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(4, 0, 1, 0)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.Parent = lootPart

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "💀 Loot Pile (" .. #items .. " items)"
	label.TextColor3 = Color3.fromRGB(255, 215, 0)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard

	-- Click to loot
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 10
	clickDetector.Parent = lootPart

	local looted = false
	clickDetector.MouseClick:Connect(function(player)
		if looted then return end
		looted = true

		-- Give all items to the player who clicked
		local itemsGiven = 0
		for _, item in ipairs(items) do
			local added = DataManager.AddToInventory(player, item.name, item.quantity)
			if added then
				itemsGiven = itemsGiven + 1
			end
		end

		-- Update their inventory UI
		local invRemote = ReplicatedStorage.Remotes:FindFirstChild("InventoryUpdate")
		if invRemote then
			local data = DataManager.GetData(player)
			invRemote:FireClient(player, data.Inventory)
		end

		print("[Loot] " .. player.Name .. " looted " .. itemsGiven .. " items from a pile")
		lootPart:Destroy()
	end)

	-- Auto-despawn after duration
	task.delay(Config.LootDropDuration, function()
		if lootPart and lootPart.Parent then
			lootPart:Destroy()
			print("[Loot] A loot pile despawned")
		end
	end)
end

-- === PVP DEATH HANDLER ===

local function onCharacterDied(player, character)
	if not DataManager then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Check if player died in wilderness
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if not isInWilderness(root.Position) then
		-- Died in safe zone — no loot drop
		return
	end

	-- FULL LOOT DROP — drop everything!
	local droppedItems = DataManager.GetAndClearInventory(player)
	
	if #droppedItems > 0 then
		-- Find who killed them (for tracking)
		local killerName = "Unknown"
		-- Check the damage tag
		local tag = humanoid:FindFirstChild("creator")
		if tag and tag.Value then
			killerName = tag.Value.Name
			-- Award kill to the killer
			local killerData = DataManager.GetData(tag.Value)
			if killerData then
				killerData.TotalKills = killerData.TotalKills + 1
			end
		end

		-- Create loot pile at death location
		createLootPile(root.Position, droppedItems, killerName)
		
		print("[PvP] " .. player.Name .. " was killed by " .. killerName .. " — dropped " .. #droppedItems .. " item stacks!")
	end

	-- Update victim's empty inventory
	local invRemote = ReplicatedStorage.Remotes:FindFirstChild("InventoryUpdate")
	if invRemote then
		invRemote:FireClient(player, {})
	end
end

-- === PLAYER SETUP ===

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			onCharacterDied(player, character)
		end)
	end)
end)

-- Cleanup on leave
Players.PlayerRemoving:Connect(function(player)
	playersInWilderness[player.UserId] = nil
end)

print("[WildernessManager] Full-loot PvP system active!")
