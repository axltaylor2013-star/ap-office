-- MapSetup.server.lua
-- Complete Wilderness world generation using MapGenerator module

print("[MapSetup] =========================================")
print("[MapSetup] STARTING COMPLETE WILDERNESS WORLD GENERATION")
print("[MapSetup] =========================================")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Wait a moment for services to initialize
task.wait(1)

-- Load MapGenerator module
local MapGenerator
local success, err = pcall(function()
	local Modules = ReplicatedStorage:WaitForChild("Modules", 5)
	MapGenerator = require(Modules:WaitForChild("MapGenerator", 5))
end)

if not success then
	warn("[MapSetup] Failed to load MapGenerator: " .. tostring(err))
	warn("[MapSetup] Creating fallback basic map...")
	
	-- Fallback basic map
	local ground = Instance.new("Part")
	ground.Name = "Ground"
	ground.Size = Vector3.new(1000, 10, 1000)
	ground.Position = Vector3.new(0, 5, 0)
	ground.Anchored = true
	ground.CanCollide = true
	ground.Color = Color3.fromRGB(34, 139, 34)
	ground.Material = Enum.Material.Grass
	ground.Parent = Workspace
	
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnLocation"
	spawn.Size = Vector3.new(20, 2, 20)
	spawn.Position = Vector3.new(0, 12, 0)
	spawn.Anchored = true
	spawn.CanCollide = true
	spawn.Parent = Workspace
	
	print("[MapSetup] Fallback basic map created")
	return
end

-- Generate complete world
local worldFolder = MapGenerator.GenerateCompleteWorld()

-- Clean up any old map parts
for _, child in ipairs(Workspace:GetChildren()) do
	if child.Name == "MapParts" or child.Name == "WildernessWorld" then
		child:Destroy()
	end
end

worldFolder.Parent = Workspace

print("[MapSetup] =========================================")
print("[MapSetup] MAP GENERATION COMPLETE")
print("[MapSetup] World ready for exploration")
print("[MapSetup] Spawn location: Haven City Central Plaza")
print("[MapSetup] =========================================")

-- Output region information for debugging
print("[MapSetup] World Regions:")
for _, child in ipairs(worldFolder:GetChildren()) do
	print("[MapSetup]   - " .. child.Name)
end

print("[MapSetup]")
print("[MapSetup] Navigation Guide:")
print("[MapSetup]   Haven City: Center of map (spawn point)")
print("[MapSetup]   Forest: East of Haven City")
print("[MapSetup]   Mountains: West of Haven City")
print("[MapSetup]   Lakes: North-West of Haven City")
print("[MapSetup]   Swamp: North-East of Haven City")
print("[MapSetup]   Desert: Far West")
print("[MapSetup]   Volcano: Far East")
print("[MapSetup]   Wilderness: Outer ring with varied terrain")
print("[MapSetup]")
print("[MapSetup] All regions connected by roads and paths")
print("[MapSetup] Resource nodes placed throughout world")
print("[MapSetup] Ready for player exploration!")