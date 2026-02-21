-- PlayerSpawn.server.lua
-- Handles player spawning in the complete Wilderness world

print("[PlayerSpawn] Initializing wilderness spawning system...")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Wait for world generation to complete
task.wait(3)

-- Load configuration
local Config
local success, err = pcall(function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Modules = ReplicatedStorage:WaitForChild("Modules", 5)
	Config = require(Modules:WaitForChild("Config", 5))
end)

if not success then
	warn("[PlayerSpawn] Failed to load Config, using defaults: " .. tostring(err))
	Config = {SPAWN = {HAVEN_SPAWN = Vector3.new(0, 5, 0)}}
end

-- Find spawn location in the world
local function findSpawnLocation()
	-- First, check for SpawnLocation in world
	local spawnLocation = Workspace:FindFirstChild("SpawnLocation")
	if spawnLocation then
		print("[PlayerSpawn] Found SpawnLocation at:", spawnLocation.Position)
		return spawnLocation.Position
	end
	
	-- Check in world folder
	local worldFolder = Workspace:FindFirstChild("WildernessWorld")
	if worldFolder then
		spawnLocation = worldFolder:FindFirstChild("SpawnLocation")
		if spawnLocation then
			print("[PlayerSpawn] Found SpawnLocation in world folder at:", spawnLocation.Position)
			return spawnLocation.Position
		end
	end
	
	-- Look for Haven City spawn platform
	local havenCity = Workspace:FindFirstChild("HavenCity") or 
	                 (worldFolder and worldFolder:FindFirstChild("HavenCity"))
	
	if havenCity then
		local spawnPlatform = havenCity:FindFirstChild("SpawnPlatform")
		if spawnPlatform then
			local spawnPos = spawnPlatform.Position + Vector3.new(0, spawnPlatform.Size.Y/2 + 3, 0)
			print("[PlayerSpawn] Using Haven City spawn platform at:", spawnPos)
			return spawnPos
		end
		
		-- Look for central plaza
		local plaza = havenCity:FindFirstChild("CentralPlaza")
		if plaza then
			local spawnPos = plaza.Position + Vector3.new(0, plaza.Size.Y/2 + 5, 0)
			print("[PlayerSpawn] Using Haven City plaza at:", spawnPos)
			return spawnPos
		end
	end
	
	-- Fallback to config or default
	print("[PlayerSpawn] Using configured spawn position")
	return Config.SPAWN.HAVEN_SPAWN or Vector3.new(0, 50, 0)
end

-- Get spawn position
local spawnPosition = findSpawnLocation()
print("[PlayerSpawn] Final spawn position:", spawnPosition)

-- Function to safely spawn a player
local function spawnPlayer(player, position)
	if not player or not player:IsA("Player") then
		warn("[PlayerSpawn] Invalid player object")
		return false
	end
	
	local character = player.Character
	if not character then
		print("[PlayerSpawn] No character for", player.Name, "- waiting for one to load")
		return false
	end
	
	-- Wait for humanoid root part
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 3)
	if not humanoidRootPart then
		warn("[PlayerSpawn] Could not find HumanoidRootPart for", player.Name)
		return false
	end
	
	-- Wait for humanoid
	local humanoid = character:WaitForChild("Humanoid", 3)
	if not humanoid then
		warn("[PlayerSpawn] Could not find Humanoid for", player.Name)
		return false
	end
	
	-- Ensure character is alive
	if humanoid.Health <= 0 then
		humanoid.Health = 100
	end
	
	-- Teleport to spawn position
	humanoidRootPart.CFrame = CFrame.new(position)
	
	-- Ensure character doesn't fall through ground
	task.wait(0.1)
	
	-- Check if player fell below safe level
	if humanoidRootPart.Position.Y < -100 then
		print("[PlayerSpawn]", player.Name, "fell below world, repositioning...")
		humanoidRootPart.CFrame = CFrame.new(position)
	end
	
	print("[PlayerSpawn] Successfully spawned", player.Name, "at:", position)
	return true
end

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
	print("[PlayerSpawn] Player joined:", player.Name)
	
	-- Wait for character to load
	player.CharacterAdded:Connect(function(character)
		print("[PlayerSpawn] Character loaded for:", player.Name)
		
		-- Wait a moment for character to fully initialize
		task.wait(1)
		
		-- Spawn player
		spawnPlayer(player, spawnPosition)
		
		-- Send welcome message
		task.wait(1)
		
		-- Check if player needs help (stuck, etc.)
		task.delay(3, function()
			if player.Character then
				local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
				if rootPart and rootPart.Position.Y < -50 then
					print("[PlayerSpawn]", player.Name, "appears to be falling, respawning...")
					spawnPlayer(player, spawnPosition)
				end
			end
		end)
	end)
	
	-- If character already exists (rejoining)
	if player.Character then
		task.wait(1)
		spawnPlayer(player, spawnPosition)
	end
end)

-- Handle respawns
Players.PlayerAdded:Connect(function(player)
	player.CharacterAppearanceLoaded:Connect(function(character)
		-- This fires when character respawns
		task.wait(0.5)
		spawnPlayer(player, spawnPosition)
	end)
end)

-- Handle existing players (in case script loads after players join)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		task.wait(2) -- Wait for world to generate
		if player.Character then
			spawnPlayer(player, spawnPosition)
		end
	end)
end

-- Create a respawn command for testing (remove in production)
game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
if remotes then
	local respawnRemote = Instance.new("RemoteEvent")
	respawnRemote.Name = "RespawnPlayer"
	respawnRemote.Parent = remotes
	
	respawnRemote.OnServerEvent:Connect(function(player)
		print("[PlayerSpawn] Manual respawn requested by:", player.Name)
		spawnPlayer(player, spawnPosition)
	end)
end

print("[PlayerSpawn] Spawning system ready")
print("[PlayerSpawn] Spawn position:", spawnPosition)
print("[PlayerSpawn] Players will spawn in Haven City")