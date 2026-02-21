--[[
	MapSetup4.server.lua
	ServerScriptService

	Adds 7 new dense themed areas across the map:
	1. Whispering Woods (X: 200-350, Z: 50-200)
	2. Deep Mine (X: -300 to -200, Z: -50 to 50)
	3. Crystal Cavern (X: -350 to -250, Z: -150 to -80)
	4. Moonlit Pond (X: 250-320, Z: -50 to 20)
	5. Thornwood Thicket (X: -200 to -100, Z: 200-350)
	6. Sunflower Fields (X: 100-250, Z: 250-380)
	7. Abandoned Quarry (X: -150 to -50, Z: -250 to -150)
]]

-- Wait for other MapSetup files to finish
task.wait(5)

print("[MapSetup4] Starting themed area creation...")

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------
local function getOrMake(parent, name)
	local existing = parent:FindFirstChild(name)
	if existing then return existing end
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function makePart(name, size, position, color, material, parent, props)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.CanCollide = true
	part.Color = typeof(color) == "string" and BrickColor.new(color).Color or color
	part.Material = material or Enum.Material.SmoothPlastic
	
	if props then
		for key, value in pairs(props) do
			if key == "Orientation" then
				part.Orientation = value
			else
				part[key] = value
			end
		end
	end
	
	part.Parent = parent
	return part
end

local function randomInRange(min, max)
	return min + math.random() * (max - min)
end

local function randomPointInRect(xMin, xMax, zMin, zMax)
	return Vector3.new(randomInRange(xMin, xMax), 0, randomInRange(zMin, zMax))
end

local Workspace = game:GetService("Workspace")
local MapDecorations = getOrMake(Workspace, "MapDecorations")

--------------------------------------------------------------------------------
-- 1. WHISPERING WOODS (X: 200-350, Z: 50-200)
--------------------------------------------------------------------------------
print("[MapSetup4] Building Whispering Woods...")
local WhisperingWoods = getOrMake(MapDecorations, "WhisperingWoods")

-- Create 40+ trees of varying sizes
for i = 1, 45 do
	local pos = randomPointInRect(200, 350, 50, 200)
	local treeHeight = randomInRange(8, 18)
	local trunkSize = randomInRange(1.5, 3.0)
	local crownSize = randomInRange(6, 12)
	
	-- Tree trunk
	makePart("TreeTrunk" .. i, Vector3.new(trunkSize, treeHeight, trunkSize), pos + Vector3.new(0, treeHeight/2, 0), 
		Color3.fromRGB(101, 67, 33), Enum.Material.Wood, WhisperingWoods)
	
	-- Tree crown
	makePart("TreeCrown" .. i, Vector3.new(crownSize, crownSize * 0.8, crownSize), pos + Vector3.new(0, treeHeight + crownSize/3, 0), 
		Color3.fromRGB(34, 139, 34), Enum.Material.Grass, WhisperingWoods, {Shape = Enum.PartType.Ball})
end

-- Undergrowth bushes
for i = 1, 25 do
	local pos = randomPointInRect(200, 350, 50, 200)
	makePart("Bush" .. i, Vector3.new(randomInRange(2, 4), randomInRange(1.5, 2.5), randomInRange(2, 4)), 
		pos + Vector3.new(0, 1, 0), Color3.fromRGB(85, 107, 47), Enum.Material.Grass, WhisperingWoods)
end

-- Fallen logs
for i = 1, 8 do
	local pos = randomPointInRect(200, 350, 50, 200)
	makePart("FallenLog" .. i, Vector3.new(0.8, 0.8, randomInRange(6, 12)), pos + Vector3.new(0, 0.4, 0), 
		Color3.fromRGB(101, 67, 33), Enum.Material.Wood, WhisperingWoods, 
		{Orientation = Vector3.new(0, randomInRange(0, 360), randomInRange(-15, 15))})
end

-- Mushroom rings
for ring = 1, 3 do
	local centerPos = randomPointInRect(210, 340, 60, 190)
	local radius = randomInRange(3, 6)
	for j = 1, 8 do
		local angle = (j / 8) * 2 * math.pi
		local mushroomPos = centerPos + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		makePart("Mushroom" .. ring .. "_" .. j, Vector3.new(0.6, 1.2, 0.6), mushroomPos + Vector3.new(0, 0.6, 0), 
			Color3.fromRGB(160, 82, 45), Enum.Material.SmoothPlastic, WhisperingWoods)
		-- Mushroom cap
		makePart("MushroomCap" .. ring .. "_" .. j, Vector3.new(1.5, 0.3, 1.5), mushroomPos + Vector3.new(0, 1.35, 0), 
			Color3.fromRGB(220, 20, 60), Enum.Material.SmoothPlastic, WhisperingWoods, {Shape = Enum.PartType.Cylinder})
	end
end

-- Hidden clearing with ancient stones
local clearingCenter = Vector3.new(275, 0, 125)
for i = 1, 6 do
	local angle = (i / 6) * 2 * math.pi
	local stonePos = clearingCenter + Vector3.new(math.cos(angle) * 8, 0, math.sin(angle) * 8)
	makePart("AncientStone" .. i, Vector3.new(randomInRange(2, 3), randomInRange(4, 7), randomInRange(1.5, 2.5)), 
		stonePos + Vector3.new(0, 2.5, 0), Color3.fromRGB(105, 105, 105), Enum.Material.Rock, WhisperingWoods)
end

-- Fog-colored ground patches
for i = 1, 15 do
	local pos = randomPointInRect(200, 350, 50, 200)
	makePart("FogPatch" .. i, Vector3.new(randomInRange(4, 8), 0.1, randomInRange(4, 8)), 
		pos + Vector3.new(0, 0.05, 0), Color3.fromRGB(248, 248, 255), Enum.Material.ForceField, WhisperingWoods, 
		{Transparency = 0.7, CanCollide = false})
end

-- Owl perches on tall trees
for i = 1, 5 do
	local pos = randomPointInRect(220, 330, 70, 180)
	makePart("OwlPerch" .. i, Vector3.new(0.5, 0.5, 1.2), pos + Vector3.new(0, 15, 0), 
		Color3.fromRGB(101, 67, 33), Enum.Material.Wood, WhisperingWoods)
	-- Owl
	makePart("Owl" .. i, Vector3.new(0.8, 1, 0.6), pos + Vector3.new(0, 15.7, 0), 
		Color3.fromRGB(139, 69, 19), Enum.Material.SmoothPlastic, WhisperingWoods)
end

-- Firefly particles (neon dots)
for i = 1, 20 do
	local pos = randomPointInRect(200, 350, 50, 200)
	makePart("Firefly" .. i, Vector3.new(0.1, 0.1, 0.1), pos + Vector3.new(0, randomInRange(2, 6), 0), 
		Color3.fromRGB(255, 255, 0), Enum.Material.Neon, WhisperingWoods, 
		{Transparency = 0.3, CanCollide = false, Shape = Enum.PartType.Ball})
	-- Add light
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 255, 0)
	light.Brightness = 1
	light.Range = 3
	light.Parent = WhisperingWoods:FindFirstChild("Firefly" .. i)
end

--------------------------------------------------------------------------------
-- 2. DEEP MINE (X: -300 to -200, Z: -50 to 50)
--------------------------------------------------------------------------------
print("[MapSetup4] Building Deep Mine...")
local DeepMine = getOrMake(MapDecorations, "DeepMine")

-- Mine entrance (stone arch)
makePart("MineEntrance", Vector3.new(12, 8, 3), Vector3.new(-250, 4, 0), 
	Color3.fromRGB(105, 105, 105), Enum.Material.Rock, DeepMine)
makePart("MineEntranceHole", Vector3.new(6, 6, 4), Vector3.new(-250, 3, 0), 
	Color3.fromRGB(0, 0, 0), Enum.Material.SmoothPlastic, DeepMine, {Transparency = 0.9})

-- Minecart tracks (parallel thin dark parts)
for i = 1, 20 do
	local zPos = -40 + (i * 4)
	-- Left rail
	makePart("RailLeft" .. i, Vector3.new(0.2, 0.3, 2), Vector3.new(-275, 0.15, zPos), 
		Color3.fromRGB(64, 64, 64), Enum.Material.Metal, DeepMine)
	-- Right rail
	makePart("RailRight" .. i, Vector3.new(0.2, 0.3, 2), Vector3.new(-272, 0.15, zPos), 
		Color3.fromRGB(64, 64, 64), Enum.Material.Metal, DeepMine)
	-- Cross ties
	if i % 2 == 0 then
		makePart("CrossTie" .. i, Vector3.new(4, 0.5, 0.3), Vector3.new(-273.5, 0.1, zPos), 
			Color3.fromRGB(101, 67, 33), Enum.Material.Wood, DeepMine)
	end
end

-- Support beams (brown blocks)
for i = 1, 12 do
	local pos = randomPointInRect(-295, -205, -45, 45)
	makePart("SupportBeam" .. i, Vector3.new(0.8, randomInRange(6, 10), 0.8), pos + Vector3.new(0, 4, 0), 
		Color3.fromRGB(101, 67, 33), Enum.Material.Wood, DeepMine)
	-- Cross beam
	makePart("CrossBeam" .. i, Vector3.new(randomInRange(4, 8), 0.6, 0.6), pos + Vector3.new(0, 8, 0), 
		Color3.fromRGB(101, 67, 33), Enum.Material.Wood, DeepMine)
end

-- Ore veins glowing on walls
for i = 1, 15 do
	local pos = randomPointInRect(-295, -205, -45, 45)
	local oreColor = ({Color3.fromRGB(255, 215, 0), Color3.fromRGB(169, 169, 169), Color3.fromRGB(184, 115, 51)})[math.random(1,3)]
	makePart("OreVein" .. i, Vector3.new(randomInRange(2, 4), randomInRange(1.5, 3), 0.5), pos + Vector3.new(0, 2, 0), 
		oreColor, Enum.Material.Neon, DeepMine, {Transparency = 0.2})
end

-- Mine shaft going down (dark hole with ladder)
makePart("MineShaft", Vector3.new(6, 20, 6), Vector3.new(-260, -10, 10), 
	Color3.fromRGB(0, 0, 0), Enum.Material.SmoothPlastic, DeepMine, {Transparency = 0.8})
-- Ladder
for i = 1, 10 do
	makePart("LadderRung" .. i, Vector3.new(0.3, 0.2, 2), Vector3.new(-257, i * -2, 10), 
		Color3.fromRGB(101, 67, 33), Enum.Material.Wood, DeepMine)
end

-- Lanterns
for i = 1, 8 do
	local pos = randomPointInRect(-290, -210, -40, 40)
	makePart("LanternPost" .. i, Vector3.new(0.3, 4, 0.3), pos + Vector3.new(0, 2, 0), 
		Color3.fromRGB(64, 64, 64), Enum.Material.Metal, DeepMine)
	makePart("Lantern" .. i, Vector3.new(1, 1.5, 1), pos + Vector3.new(0, 4.5, 0), 
		Color3.fromRGB(255, 140, 0), Enum.Material.Neon, DeepMine, {Transparency = 0.3})
	-- Light
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 140, 0)
	light.Brightness = 2
	light.Range = 12
	light.Parent = DeepMine:FindFirstChild("Lantern" .. i)
end

-- Rubble piles
for i = 1, 10 do
	local pos = randomPointInRect(-295, -205, -45, 45)
	makePart("RubblePile" .. i, Vector3.new(randomInRange(2, 5), randomInRange(1, 2.5), randomInRange(2, 5)), 
		pos + Vector3.new(0, 1, 0), Color3.fromRGB(105, 105, 105), Enum.Material.Rock, DeepMine)
end

--------------------------------------------------------------------------------
-- 3. CRYSTAL CAVERN (X: -350 to -250, Z: -150 to -80)
--------------------------------------------------------------------------------
print("[MapSetup4] Building Crystal Cavern...")
local CrystalCavern = getOrMake(MapDecorations, "CrystalCavern")

-- Large crystal spires (neon purple/blue/pink transparent parts pointing up at angles)
for i = 1, 20 do
	local pos = randomPointInRect(-345, -255, -145, -85)
	local crystalColors = {Color3.fromRGB(138, 43, 226), Color3.fromRGB(75, 0, 130), Color3.fromRGB(255, 20, 147)}
	local color = crystalColors[math.random(1, #crystalColors)]
	local height = randomInRange(6, 15)
	
	makePart("CrystalSpire" .. i, Vector3.new(randomInRange(1.5, 3), height, randomInRange(1.5, 3)), 
		pos + Vector3.new(0, height/2, 0), color, Enum.Material.ForceField, CrystalCavern,
		{Transparency = 0.4, Orientation = Vector3.new(randomInRange(-10, 10), randomInRange(0, 360), randomInRange(-10, 10))})
	
	-- Crystal glow
	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = 1.5
	light.Range = 8
	light.Parent = CrystalCavern:FindFirstChild("CrystalSpire" .. i)
end

-- Crystal pools (blue transparent floors)
for i = 1, 6 do
	local pos = randomPointInRect(-340, -260, -140, -90)
	makePart("CrystalPool" .. i, Vector3.new(randomInRange(6, 12), 0.5, randomInRange(6, 12)), 
		pos + Vector3.new(0, 0.25, 0), Color3.fromRGB(65, 130, 175), Enum.Material.Water, CrystalCavern,
		{Transparency = 0.3})
end

-- Glowing mushrooms
for i = 1, 15 do
	local pos = randomPointInRect(-345, -255, -145, -85)
	makePart("GlowMushroom" .. i, Vector3.new(randomInRange(0.8, 2), randomInRange(1, 3), randomInRange(0.8, 2)), 
		pos + Vector3.new(0, 1, 0), Color3.fromRGB(0, 255, 127), Enum.Material.Neon, CrystalCavern, 
		{Transparency = 0.3})
end

-- Ambient sparkle parts
for i = 1, 30 do
	local pos = randomPointInRect(-345, -255, -145, -85)
	makePart("Sparkle" .. i, Vector3.new(0.2, 0.2, 0.2), pos + Vector3.new(0, randomInRange(1, 8), 0), 
		Color3.fromRGB(255, 255, 255), Enum.Material.Neon, CrystalCavern,
		{Transparency = 0.2, CanCollide = false, Shape = Enum.PartType.Ball})
end

--------------------------------------------------------------------------------
-- 4. MOONLIT POND (X: 250-320, Z: -50 to 20)
--------------------------------------------------------------------------------
print("[MapSetup4] Building Moonlit Pond...")
local MoonlitPond = getOrMake(MapDecorations, "MoonlitPond")

-- Large scenic pond (blue transparent part)
makePart("MainPond", Vector3.new(60, 2, 60), Vector3.new(285, 1, -15), 
	Color3.fromRGB(65, 130, 175), Enum.Material.Water, MoonlitPond, {Transparency = 0.3})

-- Water lilies (green+pink flat parts)
for i = 1, 12 do
	local pos = randomPointInRect(260, 310, -40, 10)
	makePart("LilyPad" .. i, Vector3.new(randomInRange(2, 3), 0.1, randomInRange(2, 3)), 
		pos + Vector3.new(0, 2.1, 0), Color3.fromRGB(34, 139, 34), Enum.Material.SmoothPlastic, MoonlitPond,
		{CanCollide = false, Shape = Enum.PartType.Cylinder})
	-- Lily flower
	makePart("LilyFlower" .. i, Vector3.new(0.8, 0.3, 0.8), pos + Vector3.new(0, 2.3, 0), 
		Color3.fromRGB(255, 182, 193), Enum.Material.SmoothPlastic, MoonlitPond, {CanCollide = false})
end

-- Cattails (thin brown+green parts)
for i = 1, 20 do
	local pos = randomPointInRect(255, 315, -45, 15)
	makePart("CattailStem" .. i, Vector3.new(0.3, randomInRange(4, 6), 0.3), pos + Vector3.new(0, 2.5, 0), 
		Color3.fromRGB(85, 107, 47), Enum.Material.SmoothPlastic, MoonlitPond)
	makePart("CattailHead" .. i, Vector3.new(0.5, 1.5, 0.5), pos + Vector3.new(0, 5.5, 0), 
		Color3.fromRGB(101, 67, 33), Enum.Material.SmoothPlastic, MoonlitPond, {Shape = Enum.PartType.Cylinder})
end

-- Wooden dock (brown planks)
local dockStart = Vector3.new(270, 2, -5)
for i = 1, 8 do
	makePart("DockPlank" .. i, Vector3.new(3, 0.5, 12), dockStart + Vector3.new(i * 3, 0, 0), 
		Color3.fromRGB(101, 67, 33), Enum.Material.Wood, MoonlitPond)
end
-- Dock posts
for i = 1, 3 do
	makePart("DockPost" .. i, Vector3.new(0.8, 4, 0.8), dockStart + Vector3.new(i * 8, -1, -5), 
		Color3.fromRGB(101, 67, 33), Enum.Material.Wood, MoonlitPond)
	makePart("DockPost" .. i .. "B", Vector3.new(0.8, 4, 0.8), dockStart + Vector3.new(i * 8, -1, 5), 
		Color3.fromRGB(101, 67, 33), Enum.Material.Wood, MoonlitPond)
end

-- Frogs (small green parts)
for i = 1, 8 do
	local pos = randomPointInRect(260, 310, -40, 10)
	makePart("Frog" .. i, Vector3.new(0.8, 0.6, 1.2), pos + Vector3.new(0, 2.3, 0), 
		Color3.fromRGB(0, 128, 0), Enum.Material.SmoothPlastic, MoonlitPond, {CanCollide = false})
end

-- Willow trees (drooping branch parts)
for i = 1, 5 do
	local pos = randomPointInRect(252, 318, -48, 18)
	-- Main trunk
	makePart("WillowTrunk" .. i, Vector3.new(2, 12, 2), pos + Vector3.new(0, 6, 0), 
		Color3.fromRGB(101, 67, 33), Enum.Material.Wood, MoonlitPond)
	-- Drooping branches
	for j = 1, 8 do
		local angle = (j / 8) * 2 * math.pi
		local branchPos = pos + Vector3.new(math.cos(angle) * 4, 10, math.sin(angle) * 4)
		makePart("WillowBranch" .. i .. "_" .. j, Vector3.new(0.5, randomInRange(6, 10), 0.5), 
			branchPos + Vector3.new(0, -3, 0), Color3.fromRGB(85, 107, 47), Enum.Material.Grass, MoonlitPond,
			{Orientation = Vector3.new(randomInRange(15, 35), randomInRange(0, 360), randomInRange(-10, 10))})
	end
end

--------------------------------------------------------------------------------
-- 5. THORNWOOD THICKET (X: -200 to -100, Z: 200-350)
--------------------------------------------------------------------------------
print("[MapSetup4] Building Thornwood Thicket...")
local ThornwoodThicket = getOrMake(MapDecorations, "ThornwoodThicket")

-- Twisted dark trees
for i = 1, 25 do
	local pos = randomPointInRect(-195, -105, 205, 345)
	local height = randomInRange(8, 16)
	makePart("TwistedTrunk" .. i, Vector3.new(randomInRange(1.5, 2.5), height, randomInRange(1.5, 2.5)), 
		pos + Vector3.new(0, height/2, 0), Color3.fromRGB(64, 64, 64), Enum.Material.Wood, ThornwoodThicket,
		{Orientation = Vector3.new(0, randomInRange(0, 360), randomInRange(-15, 15))})
	-- Dark crown
	makePart("TwistedCrown" .. i, Vector3.new(randomInRange(5, 8), randomInRange(3, 5), randomInRange(5, 8)), 
		pos + Vector3.new(0, height + 2, 0), Color3.fromRGB(25, 25, 25), Enum.Material.Grass, ThornwoodThicket,
		{Shape = Enum.PartType.Ball})
end

-- Thorny bushes (dark green with red dots)
for i = 1, 20 do
	local pos = randomPointInRect(-195, -105, 205, 345)
	makePart("ThornBush" .. i, Vector3.new(randomInRange(3, 5), randomInRange(2, 3), randomInRange(3, 5)), 
		pos + Vector3.new(0, 1.5, 0), Color3.fromRGB(25, 25, 25), Enum.Material.Grass, ThornwoodThicket)
	-- Red thorns
	for j = 1, 5 do
		local thornPos = pos + Vector3.new(randomInRange(-2, 2), randomInRange(1, 3), randomInRange(-2, 2))
		makePart("Thorn" .. i .. "_" .. j, Vector3.new(0.2, 0.8, 0.2), thornPos, 
			Color3.fromRGB(139, 0, 0), Enum.Material.SmoothPlastic, ThornwoodThicket, {CanCollide = false})
	end
end

-- Spider webs between trees (white thin parts)
for i = 1, 12 do
	local pos = randomPointInRect(-190, -110, 210, 340)
	makePart("SpiderWeb" .. i, Vector3.new(randomInRange(3, 6), 0.1, randomInRange(3, 6)), 
		pos + Vector3.new(0, randomInRange(3, 8), 0), Color3.fromRGB(248, 248, 255), Enum.Material.ForceField, 
		ThornwoodThicket, {Transparency = 0.7, CanCollide = false})
end

-- Dark purple ground patches
for i = 1, 15 do
	local pos = randomPointInRect(-195, -105, 205, 345)
	makePart("DarkPatch" .. i, Vector3.new(randomInRange(4, 8), 0.1, randomInRange(4, 8)), 
		pos + Vector3.new(0, 0.05, 0), Color3.fromRGB(75, 0, 130), Enum.Material.SmoothPlastic, ThornwoodThicket,
		{Transparency = 0.5, CanCollide = false})
end

-- Ravens (small black parts on trees)
for i = 1, 8 do
	local pos = randomPointInRect(-190, -110, 210, 340)
	makePart("Raven" .. i, Vector3.new(0.6, 0.5, 0.8), pos + Vector3.new(0, randomInRange(10, 15), 0), 
		Color3.fromRGB(0, 0, 0), Enum.Material.SmoothPlastic, ThornwoodThicket, {CanCollide = false})
end

--------------------------------------------------------------------------------
-- 6. SUNFLOWER FIELDS (X: 100-250, Z: 250-380)
--------------------------------------------------------------------------------
print("[MapSetup4] Building Sunflower Fields...")
local SunflowerFields = getOrMake(MapDecorations, "SunflowerFields")

-- Rows of sunflowers (yellow circles on green stems)
for row = 1, 8 do
	for col = 1, 15 do
		local pos = Vector3.new(110 + col * 9, 0, 260 + row * 15)
		-- Stem
		makePart("SunflowerStem" .. row .. "_" .. col, Vector3.new(0.4, randomInRange(4, 7), 0.4), 
			pos + Vector3.new(0, 2.5, 0), Color3.fromRGB(85, 107, 47), Enum.Material.Grass, SunflowerFields)
		-- Flower head
		makePart("SunflowerHead" .. row .. "_" .. col, Vector3.new(2, 0.5, 2), 
			pos + Vector3.new(0, randomInRange(5, 8), 0), Color3.fromRGB(255, 215, 0), Enum.Material.SmoothPlastic, 
			SunflowerFields, {Shape = Enum.PartType.Cylinder})
	end
end

-- Bee hives (yellow cubes)
for i = 1, 6 do
	local pos = randomPointInRect(120, 240, 270, 370)
	makePart("BeeHive" .. i, Vector3.new(2, 3, 2), pos + Vector3.new(0, 1.5, 0), 
		Color3.fromRGB(255, 215, 0), Enum.Material.SmoothPlastic, SunflowerFields)
	makePart("BeeHiveEntry" .. i, Vector3.new(0.8, 0.8, 0.3), pos + Vector3.new(0, 1.5, 1.2), 
		Color3.fromRGB(0, 0, 0), Enum.Material.SmoothPlastic, SunflowerFields)
end

-- Honey puddles
for i = 1, 8 do
	local pos = randomPointInRect(110, 240, 260, 370)
	makePart("HoneyPuddle" .. i, Vector3.new(randomInRange(2, 4), 0.2, randomInRange(2, 4)), 
		pos + Vector3.new(0, 0.1, 0), Color3.fromRGB(255, 140, 0), Enum.Material.SmoothPlastic, SunflowerFields,
		{Transparency = 0.3})
end

-- Picket fences
for i = 1, 20 do
	local pos = Vector3.new(105 + i * 7, 0, 255)
	makePart("FencePost" .. i, Vector3.new(0.3, 2, 0.3), pos + Vector3.new(0, 1, 0), 
		Color3.fromRGB(245, 245, 220), Enum.Material.SmoothPlastic, SunflowerFields)
	if i < 20 then
		makePart("FenceRail" .. i, Vector3.new(7, 0.2, 0.3), pos + Vector3.new(3.5, 1.5, 0), 
			Color3.fromRGB(245, 245, 220), Enum.Material.SmoothPlastic, SunflowerFields)
	end
end

-- Windmill (large structure)
local windmillPos = Vector3.new(175, 0, 315)
makePart("WindmillBase", Vector3.new(6, 20, 6), windmillPos + Vector3.new(0, 10, 0), 
	Color3.fromRGB(245, 245, 220), Enum.Material.SmoothPlastic, SunflowerFields, {Shape = Enum.PartType.Cylinder})
-- Windmill blades
for i = 1, 4 do
	local angle = (i / 4) * 2 * math.pi
	makePart("WindmillBlade" .. i, Vector3.new(0.5, 12, 1), 
		windmillPos + Vector3.new(math.cos(angle) * 8, 20, math.sin(angle) * 8), 
		Color3.fromRGB(245, 245, 220), Enum.Material.SmoothPlastic, SunflowerFields,
		{Orientation = Vector3.new(0, math.deg(angle), 0)})
end

-- Wheat patches (tan thin parts)
for i = 1, 15 do
	local pos = randomPointInRect(120, 230, 270, 370)
	for j = 1, 10 do
		makePart("WheatStalk" .. i .. "_" .. j, Vector3.new(0.1, randomInRange(2, 3), 0.1), 
			pos + Vector3.new(randomInRange(-2, 2), 1.5, randomInRange(-2, 2)), 
			Color3.fromRGB(210, 180, 140), Enum.Material.SmoothPlastic, SunflowerFields)
	end
end

--------------------------------------------------------------------------------
-- 7. ABANDONED QUARRY (X: -150 to -50, Z: -250 to -150)
--------------------------------------------------------------------------------
print("[MapSetup4] Building Abandoned Quarry...")
local AbandonedQuarry = getOrMake(MapDecorations, "AbandonedQuarry")

-- Stepped terrain going down
for level = 1, 5 do
	local yPos = -(level * 3)
	local size = 80 - (level * 10)
	makePart("QuarryLevel" .. level, Vector3.new(size, 1, size), 
		Vector3.new(-100, yPos, -200), Color3.fromRGB(105, 105, 105), Enum.Material.Rock, AbandonedQuarry)
end

-- Broken machinery
for i = 1, 6 do
	local pos = randomPointInRect(-145, -55, -245, -155)
	makePart("BrokenMachine" .. i, Vector3.new(randomInRange(3, 6), randomInRange(2, 4), randomInRange(2, 5)), 
		pos + Vector3.new(0, 1.5, 0), Color3.fromRGB(64, 64, 64), Enum.Material.Metal, AbandonedQuarry)
	-- Rust patches
	makePart("RustPatch" .. i, Vector3.new(randomInRange(1, 3), randomInRange(1, 2), 0.1), 
		pos + Vector3.new(0, 2, 2.6), Color3.fromRGB(139, 69, 19), Enum.Material.SmoothPlastic, AbandonedQuarry)
end

-- Ore carts
for i = 1, 4 do
	local pos = randomPointInRect(-140, -60, -240, -160)
	makePart("OreCart" .. i, Vector3.new(3, 2, 4), pos + Vector3.new(0, 1, 0), 
		Color3.fromRGB(64, 64, 64), Enum.Material.Metal, AbandonedQuarry)
	-- Cart contents (ore)
	makePart("CartOre" .. i, Vector3.new(2.5, 1, 3.5), pos + Vector3.new(0, 2.25, 0), 
		Color3.fromRGB(105, 105, 105), Enum.Material.Rock, AbandonedQuarry)
end

-- Stagnant water at bottom
makePart("StagnantWater", Vector3.new(60, 1, 60), Vector3.new(-100, -14.5, -200), 
	Color3.fromRGB(30, 80, 120), Enum.Material.Water, AbandonedQuarry, {Transparency = 0.3})

-- Rusted metal parts
for i = 1, 12 do
	local pos = randomPointInRect(-145, -55, -245, -155)
	makePart("RustedMetal" .. i, Vector3.new(randomInRange(1, 3), randomInRange(0.5, 2), randomInRange(1, 3)), 
		pos + Vector3.new(0, 0.75, 0), Color3.fromRGB(139, 69, 19), Enum.Material.Metal, AbandonedQuarry)
end

-- Danger signs
for i = 1, 5 do
	local pos = randomPointInRect(-140, -60, -240, -160)
	makePart("DangerSignPost" .. i, Vector3.new(0.3, 4, 0.3), pos + Vector3.new(0, 2, 0), 
		Color3.fromRGB(101, 67, 33), Enum.Material.Wood, AbandonedQuarry)
	makePart("DangerSign" .. i, Vector3.new(0.2, 2, 3), pos + Vector3.new(0, 3, 0), 
		Color3.fromRGB(255, 0, 0), Enum.Material.SmoothPlastic, AbandonedQuarry)
end

print("[MapSetup4] All themed areas completed!")