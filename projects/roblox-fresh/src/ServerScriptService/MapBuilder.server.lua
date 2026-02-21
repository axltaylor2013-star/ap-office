--[[
	MapBuilder.server.lua
	Creates basic terrain and spawn area for the game.
	Simple, clean map generation.
]]

local Workspace = game:GetService("Workspace")

print("[MapBuilder] Starting map generation...")

-- Create a simple spawn platform
local spawnPlatform = Instance.new("Part")
spawnPlatform.Name = "SpawnPlatform"
spawnPlatform.Size = Vector3.new(50, 4, 50)
spawnPlatform.Position = Vector3.new(0, 0, 0)
spawnPlatform.Anchored = true
spawnPlatform.Material = Enum.Material.Concrete
spawnPlatform.Color = Color3.fromRGB(107, 107, 107)
spawnPlatform.Parent = Workspace

-- Create spawn point marker
local spawnMarker = Instance.new("Part")
spawnMarker.Name = "SpawnMarker"
spawnMarker.Size = Vector3.new(4, 1, 4)
spawnMarker.Position = Vector3.new(0, 3, 0)
spawnMarker.Anchored = true
spawnMarker.Material = Enum.Material.Neon
spawnMarker.Color = Color3.fromRGB(0, 255, 0)
spawnMarker.Shape = Enum.PartType.Cylinder
spawnMarker.Parent = Workspace

-- Add some basic ground around spawn
local ground = Instance.new("Part")
ground.Name = "Ground"
ground.Size = Vector3.new(500, 4, 500)
ground.Position = Vector3.new(0, -10, 0)
ground.Anchored = true
ground.Material = Enum.Material.Grass
ground.Color = Color3.fromRGB(75, 151, 75)
ground.Parent = Workspace

-- Set lighting
local Lighting = game:GetService("Lighting")
Lighting.Ambient = Color3.fromRGB(100, 100, 100)
Lighting.Brightness = 2
Lighting.ClockTime = 12

-- Create a simple sky
local sky = Instance.new("Sky")
sky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.jpg"
sky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.jpg"
sky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.jpg"
sky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.jpg"
sky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.jpg"
sky.SkyboxUp = "rbxasset://textures/sky/sky512_up.jpg"
sky.Parent = Lighting

print("[MapBuilder] Basic map created - spawn platform at (0,0,0)")