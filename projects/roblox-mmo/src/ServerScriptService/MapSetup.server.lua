-- MapSetup.server.lua
-- Creates the entire game world: terrain, city, wilderness, ponds, mine, forests

print("[MapSetup] Starting world generation...")
local WS = game:GetService("Workspace")

-- === HELPER FUNCTIONS ===
local function makePart(name, size, position, color, material, parent, props)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = position
	p.Anchored = true
	if typeof(color) == "Color3" then
		p.Color = color
	else
		p.BrickColor = BrickColor.new(color)
	end
	p.Material = material or Enum.Material.SmoothPlastic
	p.Parent = parent
	if props then
		for k, v in pairs(props) do
			p[k] = v
		end
	end
	return p
end

local function makeWedge(name, size, position, color, material, parent, props)
	local w = Instance.new("WedgePart")
	w.Name = name
	w.Size = size
	w.Position = position
	w.Anchored = true
	w.BrickColor = BrickColor.new(color)
	w.Material = material or Enum.Material.SmoothPlastic
	w.Parent = parent
	if props then
		for k, v in pairs(props) do
			w[k] = v
		end
	end
	return w
end

local function makeSign(parent, text, offset, size)
	local bg = Instance.new("BillboardGui")
	bg.Size = size or UDim2.new(8, 0, 2, 0)
	bg.StudsOffset = offset or Vector3.new(0, 5, 0)
	bg.Parent = parent
	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.new(1, 0, 1, 0)
	tl.BackgroundTransparency = 1
	tl.Text = text
	tl.TextColor3 = Color3.fromRGB(255, 255, 255)
	tl.TextScaled = true
	tl.Font = Enum.Font.GothamBold
	tl.TextStrokeTransparency = 0.3
	tl.Parent = bg
	return bg
end

local function makeTorch(position, parent)
	local pole = makePart("TorchPole", Vector3.new(0.5, 6, 0.5), position, "Reddish brown", Enum.Material.Wood, parent)
	local flame = makePart("TorchFlame", Vector3.new(0.8, 1.2, 0.8), position + Vector3.new(0, 3.5, 0), "Bright orange", Enum.Material.Neon, parent, {Transparency = 0.4})
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 150, 50)
	light.Brightness = 0.5
	light.Range = 10
	light.Parent = flame
	return pole
end

local function makeLantern(position, parent)
	local post = makePart("LanternPost", Vector3.new(0.4, 5, 0.4), position, "Dark stone grey", Enum.Material.Metal, parent)
	local lamp = makePart("Lantern", Vector3.new(1.2, 1.5, 1.2), position + Vector3.new(0, 3.2, 0), "Bright yellow", Enum.Material.Neon, parent, {Transparency = 0.5})
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 220, 120)
	light.Brightness = 0.4
	light.Range = 12
	light.Parent = lamp
	return post
end

-- === FOLDERS ===
local function getOrMake(parent, name)
	local f = parent:FindFirstChild(name)
	if not f then f = Instance.new("Folder") f.Name = name f.Parent = parent end
	return f
end

local safeZone = getOrMake(WS, "SafeZone")
local wilderness = getOrMake(WS, "Wilderness")
local resourceNodes = getOrMake(WS, "ResourceNodes")

-- ============================================================
-- === GROUND / TERRAIN ===
-- ============================================================

-- Main baseplate (safe zone - green grass) — HUGE
if not WS:FindFirstChild("Baseplate") then
	local bp = Instance.new("Part")
	bp.Name = "Baseplate"
	bp.Size = Vector3.new(800, 1, 800)
	bp.Position = Vector3.new(0, -0.5, 0)
	bp.Anchored = true
	bp.BrickColor = BrickColor.new("Bright green")
	bp.Material = Enum.Material.Grass
	bp.Parent = WS
end

-- Wilderness ground (darker, dead — extends north)
if not WS:FindFirstChild("WildernessGround") then
	local wg = Instance.new("Part")
	wg.Name = "WildernessGround"
	wg.Size = Vector3.new(800, 1.01, 600)
	wg.Position = Vector3.new(0, -0.5, -400)
	wg.Anchored = true
	wg.BrickColor = BrickColor.new("Dark stone grey")
	wg.Material = Enum.Material.Ground
	wg.Parent = WS
end

-- === SPAWN POINT ===
if not WS:FindFirstChild("SpawnLocation") then
	local sp = Instance.new("SpawnLocation")
	sp.Size = Vector3.new(12, 1, 12)
	sp.Position = Vector3.new(0, 0.5, 60)
	sp.Anchored = true
	sp.BrickColor = BrickColor.new("White")
	sp.Material = Enum.Material.Marble
	sp.Parent = WS
end

-- === WILDERNESS BORDER ===
if not WS:FindFirstChild("WildernessBorder") then
	local b = makePart("WildernessBorder", Vector3.new(800, 30, 2), Vector3.new(0, 15, -100), Color3.fromRGB(100, 15, 15), Enum.Material.ForceField, WS, {Transparency = 0.4, CanCollide = false})
	local borderGlow = Instance.new("PointLight")
	borderGlow.Color = Color3.fromRGB(180, 20, 20)
	borderGlow.Brightness = 0.8
	borderGlow.Range = 20
	borderGlow.Parent = b
	makeSign(b, "⚠️ WILDERNESS — FULL LOOT PVP ⚠️\nCross at your own risk!", Vector3.new(0, 8, 0))
end

-- ============================================================
-- === THE CITY OF HAVEN ===
-- ============================================================

local cityFolder = getOrMake(safeZone, "City")

-- ---- CITY WALLS (enhanced medieval perimeter with crenellations) ----
-- Back wall (north side) — split for North Gate with proper crenellations
makePart("WallBackL", Vector3.new(50, 14, 6), Vector3.new(-37, 7, -10), "Medium stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("WallBackR", Vector3.new(50, 14, 6), Vector3.new(37, 7, -10), "Medium stone grey", Enum.Material.Cobblestone, cityFolder)
-- Crenellations (battlements) on north walls
for i = 0, 8 do
	makePart("CreneL" .. i, Vector3.new(4, 4, 4), Vector3.new(-60 + i * 6, 16, -10), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
end
for i = 0, 8 do
	makePart("CreneR" .. i, Vector3.new(4, 4, 4), Vector3.new(12 + i * 6, 16, -10), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
end

-- North Gate (enhanced archway and architecture)
makePart("NorthGateLeft", Vector3.new(8, 20, 8), Vector3.new(-12, 10, -10), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("NorthGateRight", Vector3.new(8, 20, 8), Vector3.new(12, 10, -10), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("NorthGateArch", Vector3.new(28, 6, 8), Vector3.new(0, 20, -10), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
-- Decorative arch details
makePart("NorthArchTrim", Vector3.new(30, 1, 6), Vector3.new(0, 17, -10), "Bright yellow", Enum.Material.Metal, cityFolder)
-- Iron portcullis
makePart("NorthPortcullis", Vector3.new(16, 16, 1), Vector3.new(0, 10, -10), "Black", Enum.Material.DiamondPlate, cityFolder, {Transparency = 0.3, CanCollide = false})
-- Gate towers with peaked roofs
makeWedge("NorthGateRoofL", Vector3.new(8, 6, 8), Vector3.new(-12, 26, -10), "Dark red", Enum.Material.Slate, cityFolder)
makeWedge("NorthGateRoofR", Vector3.new(8, 6, 8), Vector3.new(12, 26, -10), "Dark red", Enum.Material.Slate, cityFolder)
-- Enhanced signage
local northGateSign = makePart("NorthGateSign", Vector3.new(1, 1, 1), Vector3.new(0, 24, -10), "Dark stone grey", Enum.Material.Cobblestone, cityFolder, {Transparency = 1})
makeSign(northGateSign, "⚠️ WILDERNESS BEYOND", Vector3.new(0, 0, 0), UDim2.new(12, 0, 4, 0))
-- Enhanced torches with brazier style
makePart("NorthBrazierL", Vector3.new(2, 1, 2), Vector3.new(-10, 24, -14), "Dark stone grey", Enum.Material.Metal, cityFolder)
makePart("NorthFlameL", Vector3.new(2, 3, 2), Vector3.new(-10, 26, -14), "Really red", Enum.Material.Neon, cityFolder, {Transparency = 0.5})
local nlLight = Instance.new("PointLight") nlLight.Color = Color3.fromRGB(255, 40, 40) nlLight.Brightness = 0.6 nlLight.Range = 10 nlLight.Parent = cityFolder:FindFirstChild("NorthFlameL")
makePart("NorthBrazierR", Vector3.new(2, 1, 2), Vector3.new(10, 24, -14), "Dark stone grey", Enum.Material.Metal, cityFolder)
makePart("NorthFlameR", Vector3.new(2, 3, 2), Vector3.new(10, 26, -14), "Really red", Enum.Material.Neon, cityFolder, {Transparency = 0.5})
local nrLight = Instance.new("PointLight") nrLight.Color = Color3.fromRGB(255, 40, 40) nrLight.Brightness = 0.6 nrLight.Range = 10 nrLight.Parent = cityFolder:FindFirstChild("NorthFlameR")

-- Left wall (west) — enhanced with crenellations
makePart("WallLeftN", Vector3.new(6, 14, 50), Vector3.new(-62, 7, 15), "Medium stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("WallLeftS", Vector3.new(6, 14, 50), Vector3.new(-62, 7, 85), "Medium stone grey", Enum.Material.Cobblestone, cityFolder)
-- West wall crenellations
for i = 0, 7 do
	makePart("WestCreneN" .. i, Vector3.new(4, 4, 4), Vector3.new(-62, 16, -8 + i * 6), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
end
for i = 0, 7 do
	makePart("WestCreneS" .. i, Vector3.new(4, 4, 4), Vector3.new(-62, 16, 62 + i * 6), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
end

-- West Gate (enhanced architecture)
makePart("WestGateTop", Vector3.new(8, 20, 8), Vector3.new(-62, 10, 38), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("WestGateBot", Vector3.new(8, 20, 8), Vector3.new(-62, 10, 62), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("WestGateArch", Vector3.new(8, 6, 28), Vector3.new(-62, 20, 50), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("WestArchTrim", Vector3.new(6, 1, 30), Vector3.new(-62, 17, 50), "Bright yellow", Enum.Material.Metal, cityFolder)
makePart("WestPortcullis", Vector3.new(1, 16, 16), Vector3.new(-62, 10, 50), "Black", Enum.Material.DiamondPlate, cityFolder, {Transparency = 0.3, CanCollide = false})
-- Gate towers with peaked roofs
makeWedge("WestGateRoofTop", Vector3.new(8, 6, 8), Vector3.new(-62, 26, 38), "Dark red", Enum.Material.Slate, cityFolder)
makeWedge("WestGateRoofBot", Vector3.new(8, 6, 8), Vector3.new(-62, 26, 62), "Dark red", Enum.Material.Slate, cityFolder)
local westGateSign = makePart("WestGateSign", Vector3.new(1, 1, 1), Vector3.new(-62, 24, 50), "Dark stone grey", Enum.Material.Cobblestone, cityFolder, {Transparency = 1})
makeSign(westGateSign, "⛏️ TO HAVEN MINE", Vector3.new(0, 0, 0), UDim2.new(10, 0, 3, 0))
-- Enhanced gate lighting
makeLantern(Vector3.new(-66, 0, 43), cityFolder)
makeLantern(Vector3.new(-66, 0, 57), cityFolder)

-- Right wall (east) — enhanced with crenellations
makePart("WallRightN", Vector3.new(6, 14, 50), Vector3.new(62, 7, 15), "Medium stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("WallRightS", Vector3.new(6, 14, 50), Vector3.new(62, 7, 85), "Medium stone grey", Enum.Material.Cobblestone, cityFolder)
-- East wall crenellations
for i = 0, 7 do
	makePart("EastCreneN" .. i, Vector3.new(4, 4, 4), Vector3.new(62, 16, -8 + i * 6), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
end
for i = 0, 7 do
	makePart("EastCreneS" .. i, Vector3.new(4, 4, 4), Vector3.new(62, 16, 62 + i * 6), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
end

-- East Gate (enhanced architecture)
makePart("EastGateTop", Vector3.new(8, 20, 8), Vector3.new(62, 10, 38), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("EastGateBot", Vector3.new(8, 20, 8), Vector3.new(62, 10, 62), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("EastGateArch", Vector3.new(8, 6, 28), Vector3.new(62, 20, 50), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("EastArchTrim", Vector3.new(6, 1, 30), Vector3.new(62, 17, 50), "Bright yellow", Enum.Material.Metal, cityFolder)
makePart("EastPortcullis", Vector3.new(1, 16, 16), Vector3.new(62, 10, 50), "Black", Enum.Material.DiamondPlate, cityFolder, {Transparency = 0.3, CanCollide = false})
-- Gate towers with peaked roofs
makeWedge("EastGateRoofTop", Vector3.new(8, 6, 8), Vector3.new(62, 26, 38), "Dark red", Enum.Material.Slate, cityFolder)
makeWedge("EastGateRoofBot", Vector3.new(8, 6, 8), Vector3.new(62, 26, 62), "Dark red", Enum.Material.Slate, cityFolder)
local eastGateSign = makePart("EastGateSign", Vector3.new(1, 1, 1), Vector3.new(62, 24, 50), "Dark stone grey", Enum.Material.Cobblestone, cityFolder, {Transparency = 1})
makeSign(eastGateSign, "🌲 TO HAVEN FOREST", Vector3.new(0, 0, 0), UDim2.new(10, 0, 3, 0))
-- Enhanced gate lighting
makeLantern(Vector3.new(66, 0, 43), cityFolder)
makeLantern(Vector3.new(66, 0, 57), cityFolder)

-- Front walls with crenellations
makePart("WallFrontL", Vector3.new(48, 14, 6), Vector3.new(-36, 7, 108), "Medium stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("WallFrontR", Vector3.new(48, 14, 6), Vector3.new(36, 7, 108), "Medium stone grey", Enum.Material.Cobblestone, cityFolder)
-- South wall crenellations
for i = 0, 7 do
	makePart("SouthCreneL" .. i, Vector3.new(4, 4, 4), Vector3.new(-58 + i * 6, 16, 108), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
end
for i = 0, 7 do
	makePart("SouthCreneR" .. i, Vector3.new(4, 4, 4), Vector3.new(12 + i * 6, 16, 108), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
end

-- Enhanced Corner Towers with detailed architecture
makePart("TowerNW", Vector3.new(10, 20, 10), Vector3.new(-62, 10, -10), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("TowerNE", Vector3.new(10, 20, 10), Vector3.new(62, 10, -10), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("TowerSW", Vector3.new(10, 20, 10), Vector3.new(-62, 10, 108), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("TowerSE", Vector3.new(10, 20, 10), Vector3.new(62, 10, 108), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)

-- Tower crenellations (proper battlements)
local towerPositions = {
	{-62, -10, "NW"}, {62, -10, "NE"}, {-62, 108, "SW"}, {62, 108, "SE"}
}
for _, pos in ipairs(towerPositions) do
	local x, z, name = pos[1], pos[2], pos[3]
	-- 8 crenellations per tower
	for i = 0, 7 do
		local angle = math.rad(i * 45) -- 8 sides
		local creneX = x + 6 * math.sin(angle)
		local creneZ = z + 6 * math.cos(angle)
		makePart("TowerCrene" .. name .. i, Vector3.new(3, 5, 3), Vector3.new(creneX, 22, creneZ), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
	end
	-- Conical tower roofs
	makePart("TowerRoof" .. name, Vector3.new(12, 8, 12), Vector3.new(x, 25, z), "Dark red", Enum.Material.Slate, cityFolder)
	-- Tower flags
	makePart("FlagPole" .. name, Vector3.new(0.3, 8, 0.3), Vector3.new(x, 33, z), "Reddish brown", Enum.Material.Wood, cityFolder)
	makePart("Flag" .. name, Vector3.new(4, 2, 0.1), Vector3.new(x + 2, 35, z), "Bright red", Enum.Material.Fabric, cityFolder)
end

-- ---- MAIN GATE (GRANDEST ENTRANCE) ----
makePart("GateLeft", Vector3.new(8, 22, 8), Vector3.new(-12, 11, 108), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("GateRight", Vector3.new(8, 22, 8), Vector3.new(12, 11, 108), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("GateArch", Vector3.new(28, 8, 8), Vector3.new(0, 22, 108), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
-- Ornate archway decorations
makePart("GateArchTrim", Vector3.new(30, 2, 6), Vector3.new(0, 18, 108), "Bright yellow", Enum.Material.Metal, cityFolder)
makePart("GateKeystone", Vector3.new(3, 3, 2), Vector3.new(0, 22, 110), "Bright yellow", Enum.Material.Metal, cityFolder)
-- Heavy iron portcullis (open - decorative only)
makePart("Portcullis", Vector3.new(16, 18, 2), Vector3.new(0, 11, 108), "Black", Enum.Material.DiamondPlate, cityFolder, {Transparency = 0.3, CanCollide = false})
-- Gate towers with peaked roofs
makeWedge("GateRoofL", Vector3.new(8, 8, 8), Vector3.new(-12, 30, 108), "Dark red", Enum.Material.Slate, cityFolder)
makeWedge("GateRoofR", Vector3.new(8, 8, 8), Vector3.new(12, 30, 108), "Dark red", Enum.Material.Slate, cityFolder)
-- Magnificent gate sign
local gateSign = makePart("GateSignPost", Vector3.new(1, 1, 1), Vector3.new(0, 28, 108), "Dark stone grey", Enum.Material.Cobblestone, cityFolder, {Transparency = 1})
makeSign(gateSign, "🏰 CITY OF HAVEN", Vector3.new(0, 0, 0), UDim2.new(12, 0, 4, 0))
-- Grand braziers
makePart("MainBrazierL", Vector3.new(3, 2, 3), Vector3.new(-10, 26, 112), "Dark stone grey", Enum.Material.Metal, cityFolder)
makePart("MainFlameL", Vector3.new(3, 4, 3), Vector3.new(-10, 29, 112), "Bright yellow", Enum.Material.Neon, cityFolder, {Transparency = 0.5})
local mlLight = Instance.new("PointLight") mlLight.Color = Color3.fromRGB(255, 200, 50) mlLight.Brightness = 0.8 mlLight.Range = 14 mlLight.Parent = cityFolder:FindFirstChild("MainFlameL")
makePart("MainBrazierR", Vector3.new(3, 2, 3), Vector3.new(10, 26, 112), "Dark stone grey", Enum.Material.Metal, cityFolder)
makePart("MainFlameR", Vector3.new(3, 4, 3), Vector3.new(10, 29, 112), "Bright yellow", Enum.Material.Neon, cityFolder, {Transparency = 0.5})
local mrLight = Instance.new("PointLight") mrLight.Color = Color3.fromRGB(255, 200, 50) mrLight.Brightness = 0.8 mrLight.Range = 14 mrLight.Parent = cityFolder:FindFirstChild("MainFlameR")

-- ---- ENHANCED CITY GROUND WITH PROPER COBBLESTONE ----
-- CityFloor is the base layer — sits just above baseplate so roads can layer on top without z-fighting
makePart("CityFloor", Vector3.new(120, 0.3, 116), Vector3.new(0, 0.15, 49), "Medium stone grey", Enum.Material.Cobblestone, cityFolder)

-- ---- ENHANCED STREET SYSTEM ----
-- Roads sit clearly above city floor (0.3 gap to prevent z-fighting)
-- Main road (grand boulevard from gate to square)
makePart("MainRoad", Vector3.new(12, 0.15, 60), Vector3.new(0, 0.38, 78), "Institutional white", Enum.Material.Cobblestone, cityFolder)
-- Road borders (darker stone, slightly raised)
makePart("MainRoadBorderL", Vector3.new(1, 0.2, 60), Vector3.new(-6.5, 0.4, 78), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("MainRoadBorderR", Vector3.new(1, 0.2, 60), Vector3.new(6.5, 0.4, 78), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)

-- East-west main crossroad
makePart("CrossRoad", Vector3.new(100, 0.15, 10), Vector3.new(0, 0.38, 50), "Institutional white", Enum.Material.Cobblestone, cityFolder)
makePart("CrossRoadBorderN", Vector3.new(100, 0.2, 1), Vector3.new(0, 0.4, 45), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("CrossRoadBorderS", Vector3.new(100, 0.2, 1), Vector3.new(0, 0.4, 55), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)

-- Secondary roads to different quarters
-- Road to smithy (northwest)
makePart("SmithyRoad", Vector3.new(8, 0.15, 20), Vector3.new(-25, 0.38, 35), "Institutional white", Enum.Material.Cobblestone, cityFolder)
-- Road to church (northeast)  
makePart("ChurchRoad", Vector3.new(8, 0.15, 20), Vector3.new(25, 0.38, 35), "Institutional white", Enum.Material.Cobblestone, cityFolder)
-- Road to market (southwest)
makePart("MarketRoad", Vector3.new(20, 0.15, 8), Vector3.new(-35, 0.38, 75), "Institutional white", Enum.Material.Cobblestone, cityFolder)
-- Road to guard tower (southeast)
makePart("GuardRoad", Vector3.new(12, 0.15, 8), Vector3.new(15, 0.38, 75), "Institutional white", Enum.Material.Cobblestone, cityFolder)

-- Street lamps along main roads
local streetLampPositions = {
	-- Main road lamps
	{-8, 0, 65}, {8, 0, 65}, {-8, 0, 85}, {8, 0, 85}, {-8, 0, 95}, {8, 0, 95},
	-- Cross road lamps
	{-25, 0, 48}, {25, 0, 48}, {-35, 0, 52}, {35, 0, 52},
	-- Quarter roads
	{-25, 0, 25}, {25, 0, 25}, {-45, 0, 75}, {15, 0, 67}
}
for _, pos in ipairs(streetLampPositions) do
	makeLantern(Vector3.new(pos[1], pos[2], pos[3]), cityFolder)
end

-- ============================================================
-- === GRAND TOWN SQUARE (center) ===
-- ============================================================

-- Magnificent Grand Fountain (multi-tiered)
-- Base platform
makePart("FountainPlatform", Vector3.new(20, 1, 20), Vector3.new(0, 0.5, 50), "Medium stone grey", Enum.Material.Marble, cityFolder)
-- Lower tier
makePart("FountainBaseLower", Vector3.new(16, 3, 16), Vector3.new(0, 2.5, 50), "Medium stone grey", Enum.Material.Marble, cityFolder)
makePart("FountainWaterLower", Vector3.new(14, 0.5, 14), Vector3.new(0, 3.75, 50), Color3.fromRGB(65, 130, 175), Enum.Material.Water, cityFolder, {Transparency = 0.3})
-- Middle tier
makePart("FountainBaseMiddle", Vector3.new(10, 3, 10), Vector3.new(0, 5.5, 50), "Medium stone grey", Enum.Material.Marble, cityFolder)
makePart("FountainWaterMiddle", Vector3.new(8, 0.5, 8), Vector3.new(0, 6.75, 50), Color3.fromRGB(65, 130, 175), Enum.Material.Water, cityFolder, {Transparency = 0.3})
-- Central pillar and top
makePart("FountainPillar", Vector3.new(3, 6, 3), Vector3.new(0, 10, 50), "Medium stone grey", Enum.Material.Marble, cityFolder)
makePart("FountainTop", Vector3.new(6, 1.5, 6), Vector3.new(0, 13.75, 50), "Medium stone grey", Enum.Material.Marble, cityFolder)
makePart("FountainTopWater", Vector3.new(4, 0.4, 4), Vector3.new(0, 14.4, 50), Color3.fromRGB(65, 130, 175), Enum.Material.Water, cityFolder, {Transparency = 0.3})

-- Decorative lion heads (water spouts)
for i = 0, 3 do
	local angle = math.rad(i * 90)
	local x = 6 * math.sin(angle)
	local z = 6 * math.cos(angle)
	makePart("LionHead" .. i, Vector3.new(2, 1.5, 1), Vector3.new(x, 5.5, 50 + z), "Dark stone grey", Enum.Material.Marble, cityFolder)
end

-- Ornate fountain sign
local squareSign = makePart("SquareSign", Vector3.new(1, 1, 1), Vector3.new(0, 16, 50), "White", nil, cityFolder, {Transparency = 1})
makeSign(squareSign, "⛲ HAVEN TOWN SQUARE", Vector3.new(0, 0, 0), UDim2.new(12, 0, 3, 0))

-- Enhanced seating area with decorative benches
local benchPositions = {
	{-14, 0.75, 50, 90}, {14, 0.75, 50, 90}, {0, 0.75, 36, 0}, {0, 0.75, 64, 0},
	{-10, 0.75, 40, 45}, {10, 0.75, 40, -45}, {-10, 0.75, 60, -45}, {10, 0.75, 60, 45}
}
for i, pos in ipairs(benchPositions) do
	local bench = makePart("Bench" .. i, Vector3.new(5, 1.5, 1.8), Vector3.new(pos[1], pos[2], pos[3]), "Reddish brown", Enum.Material.Wood, cityFolder)
	if pos[4] then
		bench.Orientation = Vector3.new(0, pos[4], 0)
	end
	-- Bench backs
	makePart("BenchBack" .. i, Vector3.new(5, 2, 0.3), Vector3.new(pos[1], pos[2] + 1.65, pos[3] + (pos[4] == 0 and 0.9 or 0)), "Reddish brown", Enum.Material.Wood, cityFolder)
end

-- Decorative planters with flowers
local planterPositions = {
	{-18, 35}, {18, 35}, {-18, 65}, {18, 65}
}
for i, pos in ipairs(planterPositions) do
	makePart("Planter" .. i, Vector3.new(3, 2, 3), Vector3.new(pos[1], 1, pos[2]), "Brown", Enum.Material.Wood, cityFolder)
	makePart("Soil" .. i, Vector3.new(2.8, 0.3, 2.8), Vector3.new(pos[1], 2.1, pos[2]), "Brown", Enum.Material.Ground, cityFolder)
	-- Flowers in planters
	for j = 1, 4 do
		local fx = pos[1] + math.random(-1, 1)
		local fz = pos[2] + math.random(-1, 1)
		local colors = {"Bright red", "Bright yellow", "Bright violet", "Hot pink"}
		makePart("PlanterFlower" .. i .. j, Vector3.new(0.4, 1, 0.4), Vector3.new(fx, 2.8, fz), colors[j], Enum.Material.SmoothPlastic, cityFolder, {CanCollide = false})
	end
end

-- Grand square lighting
local squareLanterns = {
	{-15, 0, 42}, {15, 0, 42}, {-15, 0, 58}, {15, 0, 58},
	{-20, 0, 50}, {20, 0, 50}, {0, 0, 32}, {0, 0, 68}
}
for _, pos in ipairs(squareLanterns) do
	makeLantern(Vector3.new(pos[1], pos[2], pos[3]), cityFolder)
end

-- Decorative statues around the square
makePart("StatueNorth", Vector3.new(2, 6, 2), Vector3.new(0, 3, 35), "Medium stone grey", Enum.Material.Marble, cityFolder)
makePart("StatueNorthBase", Vector3.new(3, 1, 3), Vector3.new(0, 0.5, 35), "Medium stone grey", Enum.Material.Marble, cityFolder)
makeSign(makePart("StatueNorthSign", Vector3.new(1, 1, 1), Vector3.new(0, 7, 35), "White", nil, cityFolder, {Transparency = 1}), "⚔️ HERO'S MEMORIAL", Vector3.new(0, 0, 0))

-- Town square decorative barrels and crates (medieval atmosphere)
local decorPositions = {
	{-25, 25}, {25, 25}, {-25, 75}, {25, 75}
}
for i, pos in ipairs(decorPositions) do
	-- Barrel clusters
	makePart("DecorBarrel" .. i .. "A", Vector3.new(2, 3, 2), Vector3.new(pos[1], 1.5, pos[2]), "Reddish brown", Enum.Material.Wood, cityFolder)
	makePart("DecorBarrel" .. i .. "B", Vector3.new(2, 3, 2), Vector3.new(pos[1] + 2, 1.5, pos[2] + 1), "Reddish brown", Enum.Material.Wood, cityFolder)
	-- Wooden crates
	makePart("DecorCrate" .. i, Vector3.new(2.5, 2.5, 2.5), Vector3.new(pos[1] - 2, 1.25, pos[2] - 1), "Brown", Enum.Material.Wood, cityFolder)
end

-- ============================================================
-- === BANK OF HAVEN (GRAND FINANCIAL INSTITUTION) ===
-- ============================================================
local bankBuilding = getOrMake(cityFolder, "BankBuilding")
-- Enhanced foundation with steps
makePart("BankFoundation", Vector3.new(24, 1.5, 20), Vector3.new(35, 0.75, 50), "Dark stone grey", Enum.Material.Cobblestone, bankBuilding)
makePart("BankSteps", Vector3.new(8, 0.5, 3), Vector3.new(35, 1.25, 59), "Medium stone grey", Enum.Material.Marble, bankBuilding)
-- Quality floor
makePart("BankFloor", Vector3.new(22, 0.5, 18), Vector3.new(35, 1.75, 50), "Reddish brown", Enum.Material.WoodPlanks, bankBuilding)

-- Enhanced walls with architectural details
makePart("BankWallBack", Vector3.new(22, 14, 2), Vector3.new(35, 8.5, 41), "Brick yellow", Enum.Material.Brick, bankBuilding)
makePart("BankWallLeft", Vector3.new(2, 14, 18), Vector3.new(24, 8.5, 50), "Brick yellow", Enum.Material.Brick, bankBuilding)
makePart("BankWallRight", Vector3.new(2, 14, 18), Vector3.new(46, 8.5, 50), "Brick yellow", Enum.Material.Brick, bankBuilding)
-- Front wall with grand entrance
makePart("BankFrontL", Vector3.new(8, 14, 2), Vector3.new(27, 8.5, 59), "Brick yellow", Enum.Material.Brick, bankBuilding)
makePart("BankFrontR", Vector3.new(8, 14, 2), Vector3.new(43, 8.5, 59), "Brick yellow", Enum.Material.Brick, bankBuilding)
makePart("BankEntryArch", Vector3.new(8, 6, 2), Vector3.new(35, 13, 59), "Brick yellow", Enum.Material.Brick, bankBuilding, {CanCollide = false})

-- Bank entrance — open doorway, no door

-- Windows with frames
local bankWindowPos = {
	{30, 7, 41}, {40, 7, 41}, -- Back wall windows
	{24, 7, 45}, {24, 7, 55}, -- Left wall windows  
	{46, 7, 45}, {46, 7, 55}, -- Right wall windows
	{30, 11, 59}, {40, 11, 59} -- Upper front windows
}
for i, pos in ipairs(bankWindowPos) do
	makePart("BankWindow" .. i, Vector3.new(2.5, 3, 0.3), Vector3.new(pos[1], pos[2], pos[3]), "Light blue", Enum.Material.Glass, bankBuilding, {Transparency = 0.3})
	makePart("BankWindowFrame" .. i, Vector3.new(3, 3.5, 0.5), Vector3.new(pos[1], pos[2], pos[3]), "Dark stone grey", Enum.Material.Marble, bankBuilding)
end

-- Peaked roof system
makeWedge("BankRoofNorth", Vector3.new(22, 8, 12), Vector3.new(35, 19, 45), "Dark red", Enum.Material.Slate, bankBuilding)
makeWedge("BankRoofSouth", Vector3.new(22, 8, 12), Vector3.new(35, 19, 55), "Dark red", Enum.Material.Slate, bankBuilding, {Orientation = Vector3.new(0, 180, 0)})
-- Ridge line
makePart("BankRoofRidge", Vector3.new(24, 0.5, 1), Vector3.new(35, 23, 50), "Dark stone grey", Enum.Material.Slate, bankBuilding)
-- Chimney
makePart("BankChimney", Vector3.new(2, 6, 2), Vector3.new(32, 26, 47), "Dark stone grey", Enum.Material.Cobblestone, bankBuilding)

-- Gold trim and decorative elements
makePart("BankGoldTrimFront", Vector3.new(24, 1, 1), Vector3.new(35, 15, 60), "Bright yellow", Enum.Material.Metal, bankBuilding)
makePart("BankGoldTrimSides", Vector3.new(1, 1, 20), Vector3.new(24, 15, 50), "Bright yellow", Enum.Material.Metal, bankBuilding)
makePart("BankGoldTrimSides2", Vector3.new(1, 1, 20), Vector3.new(46, 15, 50), "Bright yellow", Enum.Material.Metal, bankBuilding)

-- Interior furnishings
makePart("BankCounter", Vector3.new(14, 4, 3), Vector3.new(35, 3.5, 47), "Reddish brown", Enum.Material.WoodPlanks, bankBuilding)
makePart("CounterTop", Vector3.new(14, 0.5, 3), Vector3.new(35, 5.5, 47), "Dark stone grey", Enum.Material.Marble, bankBuilding)
-- Teller windows
makePart("TellerWindow1", Vector3.new(3, 2, 0.2), Vector3.new(31, 4.5, 49), "Light blue", Enum.Material.Glass, bankBuilding, {Transparency = 0.2})
makePart("TellerWindow2", Vector3.new(3, 2, 0.2), Vector3.new(35, 4.5, 49), "Light blue", Enum.Material.Glass, bankBuilding, {Transparency = 0.2})
makePart("TellerWindow3", Vector3.new(3, 2, 0.2), Vector3.new(39, 4.5, 49), "Light blue", Enum.Material.Glass, bankBuilding, {Transparency = 0.2})

-- Gold vault door (decorative)
makePart("VaultDoor", Vector3.new(4, 8, 1), Vector3.new(35, 5.5, 42), "Bright yellow", Enum.Material.Metal, bankBuilding)
makePart("VaultHandle", Vector3.new(1.5, 1.5, 0.5), Vector3.new(37, 5.5, 42.5), "Dark stone grey", Enum.Material.Metal, bankBuilding)

-- Display gold (secure behind glass)
makePart("GoldDisplay", Vector3.new(8, 0.3, 2), Vector3.new(35, 3.8, 48), "Bright yellow", Enum.Material.Metal, bankBuilding)
for i = 1, 6 do
	makePart("GoldBar" .. i, Vector3.new(1.2, 0.6, 0.8), Vector3.new(32 + i, 4.2, 48), "Bright yellow", Enum.Material.Metal, bankBuilding)
end

-- Grand bank signage
local bankSign = makePart("BankSign", Vector3.new(1, 1, 1), Vector3.new(35, 18, 60), "White", nil, bankBuilding, {Transparency = 1})
makeSign(bankSign, "🏦 FIRST BANK OF HAVEN", Vector3.new(0, 0, 0), UDim2.new(12, 0, 3, 0))

-- Enhanced lighting
makeLantern(Vector3.new(26, 0, 58), bankBuilding)
makeLantern(Vector3.new(44, 0, 58), bankBuilding)
makeLantern(Vector3.new(35, 0, 62), bankBuilding)

-- ============================================================
-- === GENERAL STORE (MERCHANT ESTABLISHMENT) ===
-- ============================================================
local shopBuilding = getOrMake(cityFolder, "ShopBuilding")
-- Enhanced foundation and steps
makePart("ShopFoundation", Vector3.new(20, 1.5, 16), Vector3.new(-35, 0.75, 50), "Dark stone grey", Enum.Material.Cobblestone, shopBuilding)
makePart("ShopSteps", Vector3.new(6, 0.4, 2), Vector3.new(-35, 1.4, 57), "Medium stone grey", Enum.Material.Cobblestone, shopBuilding)
makePart("ShopFloor", Vector3.new(18, 0.5, 14), Vector3.new(-35, 1.75, 50), "Reddish brown", Enum.Material.WoodPlanks, shopBuilding)

-- Tudor-style walls (half-timbered look)
makePart("ShopWallBack", Vector3.new(18, 12, 2), Vector3.new(-35, 7.5, 43), "Brick yellow", Enum.Material.Brick, shopBuilding)
makePart("ShopWallLeft", Vector3.new(2, 12, 14), Vector3.new(-44, 7.5, 50), "Brick yellow", Enum.Material.Brick, shopBuilding)
makePart("ShopWallRight", Vector3.new(2, 12, 14), Vector3.new(-26, 7.5, 50), "Brick yellow", Enum.Material.Brick, shopBuilding)
-- Front wall with shop window
makePart("ShopFrontL", Vector3.new(6, 12, 2), Vector3.new(-41, 7.5, 57), "Brick yellow", Enum.Material.Brick, shopBuilding)
makePart("ShopFrontR", Vector3.new(6, 12, 2), Vector3.new(-29, 7.5, 57), "Brick yellow", Enum.Material.Brick, shopBuilding)
makePart("ShopFrontTop", Vector3.new(8, 4, 2), Vector3.new(-35, 11.5, 57), "Brick yellow", Enum.Material.Brick, shopBuilding)

-- Tudor timber framing (dark wooden beams)
makePart("TimberFrameV1", Vector3.new(0.5, 12, 0.8), Vector3.new(-38, 7.5, 57.6), "Dark stone grey", Enum.Material.Wood, shopBuilding)
makePart("TimberFrameV2", Vector3.new(0.5, 12, 0.8), Vector3.new(-32, 7.5, 57.6), "Dark stone grey", Enum.Material.Wood, shopBuilding)
makePart("TimberFrameH1", Vector3.new(8, 0.5, 0.8), Vector3.new(-35, 9, 57.6), "Dark stone grey", Enum.Material.Wood, shopBuilding)
makePart("TimberFrameH2", Vector3.new(8, 0.5, 0.8), Vector3.new(-35, 6, 57.6), "Dark stone grey", Enum.Material.Wood, shopBuilding)

-- Shop entrance door (CanCollide false for entry)
makePart("ShopDoor", Vector3.new(4, 8, 0.5), Vector3.new(-35, 5.5, 57.5), "Brown", Enum.Material.Wood, shopBuilding, {CanCollide = false, Transparency = 0.15})
makePart("DoorHandle", Vector3.new(0.3, 0.8, 0.3), Vector3.new(-33, 5.5, 57.8), "Black", Enum.Material.Metal, shopBuilding, {CanCollide = false})

-- Large shop windows
makePart("ShopWindow", Vector3.new(6, 4, 0.3), Vector3.new(-35, 10, 57.3), "Light blue", Enum.Material.Glass, shopBuilding, {Transparency = 0.2})
makePart("WindowFrame", Vector3.new(6.5, 4.5, 0.5), Vector3.new(-35, 10, 57.2), "Dark stone grey", Enum.Material.Wood, shopBuilding)
-- Window cross-frames
makePart("WindowCrossH", Vector3.new(6, 0.3, 0.2), Vector3.new(-35, 10, 57.4), "Dark stone grey", Enum.Material.Wood, shopBuilding)
makePart("WindowCrossV", Vector3.new(0.3, 4, 0.2), Vector3.new(-35, 10, 57.4), "Dark stone grey", Enum.Material.Wood, shopBuilding)

-- Side windows
makePart("SideWindow1", Vector3.new(0.3, 3, 2.5), Vector3.new(-44.2, 8, 48), "Light blue", Enum.Material.Glass, shopBuilding, {Transparency = 0.2})
makePart("SideWindow2", Vector3.new(0.3, 3, 2.5), Vector3.new(-25.8, 8, 52), "Light blue", Enum.Material.Glass, shopBuilding, {Transparency = 0.2})

-- Steep peaked roof (medieval style)
makeWedge("ShopRoofNorth", Vector3.new(18, 6, 8), Vector3.new(-35, 16, 47), "Dark red", Enum.Material.Slate, shopBuilding)
makeWedge("ShopRoofSouth", Vector3.new(18, 6, 8), Vector3.new(-35, 16, 53), "Dark red", Enum.Material.Slate, shopBuilding, {Orientation = Vector3.new(0, 180, 0)})
makePart("ShopRoofRidge", Vector3.new(20, 0.5, 0.8), Vector3.new(-35, 19, 50), "Dark stone grey", Enum.Material.Slate, shopBuilding)

-- Enhanced storefront awning
makePart("ShopAwning", Vector3.new(12, 0.5, 5), Vector3.new(-35, 9.5, 59), "Bright red", Enum.Material.Fabric, shopBuilding)
makePart("AwningSupport1", Vector3.new(0.5, 2, 0.5), Vector3.new(-41, 8, 61), "Reddish brown", Enum.Material.Wood, shopBuilding)
makePart("AwningSupport2", Vector3.new(0.5, 2, 0.5), Vector3.new(-29, 8, 61), "Reddish brown", Enum.Material.Wood, shopBuilding)

-- Outdoor market display
makePart("DisplayShelf1", Vector3.new(4, 4, 1.5), Vector3.new(-30, 2.5, 59), "Reddish brown", Enum.Material.Wood, shopBuilding)
makePart("DisplayShelf2", Vector3.new(4, 4, 1.5), Vector3.new(-40, 2.5, 59), "Reddish brown", Enum.Material.Wood, shopBuilding)
-- Goods on display
makePart("DisplayBread1", Vector3.new(1, 0.5, 0.8), Vector3.new(-29, 4.5, 59), "Nougat", Enum.Material.SmoothPlastic, shopBuilding)
makePart("DisplayBread2", Vector3.new(1, 0.5, 0.8), Vector3.new(-31, 4.5, 59), "Nougat", Enum.Material.SmoothPlastic, shopBuilding)
makePart("DisplayApples", Vector3.new(1.5, 1, 1), Vector3.new(-39, 4.8, 59), "Bright red", Enum.Material.SmoothPlastic, shopBuilding)
makePart("DisplayCarrots", Vector3.new(0.8, 1.2, 0.8), Vector3.new(-41, 4.8, 59), "Bright orange", Enum.Material.SmoothPlastic, shopBuilding)

-- Storage barrels and crates (more extensive)
local storageItems = {
	{-45, 1.5, 52, "Barrel", Vector3.new(2, 3, 2), "Reddish brown"},
	{-45, 1.5, 54, "Barrel", Vector3.new(2, 3, 2), "Reddish brown"}, 
	{-45, 4.3, 53, "Barrel", Vector3.new(2, 3, 2), "Reddish brown"},
	{-45, 1.25, 49, "Crate", Vector3.new(2.5, 2.5, 2.5), "Brown"},
	{-45, 1.25, 46, "Crate", Vector3.new(2.5, 2.5, 2.5), "Brown"},
	{-25, 1.5, 55, "Sack", Vector3.new(1.5, 2.5, 1.5), "Dusty Rose"},
	{-25, 1.5, 53, "Sack", Vector3.new(1.5, 2.5, 1.5), "Dusty Rose"},
}
for i, item in ipairs(storageItems) do
	makePart("Storage" .. i, item[5], Vector3.new(item[1], item[2], item[3]), item[6], Enum.Material.Wood, shopBuilding)
end

-- Shop sign (hanging style)
makePart("SignPost", Vector3.new(0.5, 4, 0.5), Vector3.new(-32, 11, 60), "Reddish brown", Enum.Material.Wood, shopBuilding)
makePart("SignBoard", Vector3.new(6, 3, 0.3), Vector3.new(-28, 12, 60), "Brown", Enum.Material.Wood, shopBuilding)
local shopSign = makePart("ShopSign", Vector3.new(1, 1, 1), Vector3.new(-28, 12, 60), "White", nil, shopBuilding, {Transparency = 1})
makeSign(shopSign, "🏪 HAVEN GENERAL STORE", Vector3.new(0, 0, 0), UDim2.new(10, 0, 3, 0))

-- Enhanced lighting
makeLantern(Vector3.new(-27, 0, 60), shopBuilding)
makeLantern(Vector3.new(-43, 0, 60), shopBuilding)

-- ============================================================
-- === SMITHY & KITCHEN (northwest area) ===
-- ============================================================
local smithy = getOrMake(cityFolder, "Smithy")
makePart("SmithyFoundation", Vector3.new(20, 1, 16), Vector3.new(-35, 0.5, 20), "Dark stone grey", Enum.Material.Cobblestone, smithy)
makePart("SmithyFloor", Vector3.new(18, 0.3, 14), Vector3.new(-35, 1.15, 20), "Dark stone grey", Enum.Material.Slate, smithy)
-- Walls (open front for smoke/heat)
makePart("SmithyWallBack", Vector3.new(18, 10, 1), Vector3.new(-35, 6, 13), "Dark stone grey", Enum.Material.Cobblestone, smithy)
makePart("SmithyWallLeft", Vector3.new(1, 10, 14), Vector3.new(-44, 6, 20), "Dark stone grey", Enum.Material.Cobblestone, smithy)
makePart("SmithyWallRight", Vector3.new(1, 10, 8), Vector3.new(-26, 6, 17), "Dark stone grey", Enum.Material.Cobblestone, smithy)
makePart("SmithyRoof", Vector3.new(22, 1, 18), Vector3.new(-35, 11.5, 20), "Dark stone grey", Enum.Material.Slate, smithy)
-- Chimney
makePart("Chimney", Vector3.new(4, 8, 4), Vector3.new(-40, 16, 15), "Dark stone grey", Enum.Material.Cobblestone, smithy)
makePart("ChimneySmoke", Vector3.new(2, 2, 2), Vector3.new(-40, 21, 15), "Medium stone grey", Enum.Material.SmoothPlastic, smithy, {Transparency = 0.6})
-- Forge (big glowing furnace)
makePart("ForgeBase", Vector3.new(5, 3, 4), Vector3.new(-40, 2.5, 15), "Dark stone grey", Enum.Material.Cobblestone, smithy)
makePart("ForgeFire", Vector3.new(3, 2, 2), Vector3.new(-40, 2, 15), "Bright red", Enum.Material.Neon, smithy, {Transparency = 0.2})
local forgeLight = Instance.new("PointLight")
forgeLight.Color = Color3.fromRGB(255, 100, 30)
forgeLight.Brightness = 0.8
forgeLight.Range = 20
forgeLight.Parent = smithy:FindFirstChild("ForgeFire")
-- Anvil
makePart("Anvil", Vector3.new(2, 1.5, 3), Vector3.new(-35, 1.75, 18), "Black", Enum.Material.Metal, smithy)
makePart("AnvilHorn", Vector3.new(1, 0.5, 1), Vector3.new(-35, 2.75, 16.5), "Black", Enum.Material.Metal, smithy)
-- Weapon rack
makePart("WeaponRack", Vector3.new(0.5, 6, 4), Vector3.new(-43.5, 4, 18), "Reddish brown", Enum.Material.Wood, smithy)
makePart("RackSword1", Vector3.new(0.3, 4, 0.3), Vector3.new(-43.5, 4.5, 19.5), "Medium stone grey", Enum.Material.Metal, smithy)
makePart("RackSword2", Vector3.new(0.3, 3.5, 0.3), Vector3.new(-43.5, 4.5, 17.5), "Medium stone grey", Enum.Material.Metal, smithy)
-- Cooking range (next to smithy)
makePart("CookingRange", Vector3.new(4, 2, 4), Vector3.new(-30, 2, 18), "Bright orange", Enum.Material.Neon, smithy, {Transparency = 0.3})
makePart("CookingPot", Vector3.new(2, 1.5, 2), Vector3.new(-30, 3.5, 18), "Dark stone grey", Enum.Material.Metal, smithy)
local smithySign = makePart("SmithySign", Vector3.new(1, 1, 1), Vector3.new(-35, 13, 27), "White", nil, smithy, {Transparency = 1})
makeSign(smithySign, "🔨 Smithy & Kitchen", Vector3.new(0, 0, 0))

-- === INTERACTIVE STATIONS FOR COOKING & SMITHING ===
-- Create stations folders for the cooking and smithing systems
local stationsFolder = Instance.new("Folder")
stationsFolder.Name = "SmithingStations"
stationsFolder.Parent = workspace

local cookingFolder = Instance.new("Folder")
cookingFolder.Name = "CookingFires"
cookingFolder.Parent = workspace

-- Smithing Furnace (interactive - reuse existing forge position)
local furnace = makePart("SmithingFurnace", Vector3.new(5, 3, 4), Vector3.new(-40, 2.5, 15), "Dark stone grey", Enum.Material.Cobblestone, stationsFolder)
furnace.Name = "SmithingFurnace"

-- Smithing Anvil (interactive - reuse existing anvil position) 
local anvil = makePart("SmithingAnvil", Vector3.new(2, 1.5, 3), Vector3.new(-35, 1.75, 18), "Black", Enum.Material.Metal, stationsFolder)
anvil.Name = "SmithingAnvil"

-- Cooking Fire (interactive - reuse existing cooking range position)
local cookingFire = makePart("CookingFire", Vector3.new(4, 2, 4), Vector3.new(-30, 2, 18), "Bright orange", Enum.Material.Neon, cookingFolder, {Transparency = 0.3})
cookingFire.Name = "CookingFire"

-- Additional cooking fire near Old Bess (tavern area)
local tavernFire = makePart("TavernCookingFire", Vector3.new(3, 1.5, 3), Vector3.new(10, 1.75, 35), "Bright orange", Enum.Material.Neon, cookingFolder, {Transparency = 0.3})
tavernFire.Name = "TavernCookingFire"

-- Cooking fire near the marketplace for easy access
local marketFire = makePart("MarketCookingFire", Vector3.new(2.5, 1.5, 2.5), Vector3.new(25, 1.75, 10), "Bright orange", Enum.Material.Neon, cookingFolder, {Transparency = 0.3})
marketFire.Name = "MarketCookingFire"

-- === FLETCHING STATION ===
local fletchFolder = Instance.new("Folder")
fletchFolder.Name = "FletchingStations"
fletchFolder.Parent = workspace

local fletchBench = makePart("FletchingBench", Vector3.new(4, 2, 3), Vector3.new(-25, 2, 18), "Reddish brown", Enum.Material.Wood, fletchFolder)
fletchBench.Name = "FletchingBench"

-- ============================================================
-- === CATHEDRAL OF LIGHT (GRAND PRAYER TEMPLE) ===
-- ============================================================
local church = getOrMake(cityFolder, "Church")
-- Grand foundation with steps
makePart("ChurchFoundation", Vector3.new(20, 2, 26), Vector3.new(35, 1, 25), "White", Enum.Material.Marble, church)
makePart("ChurchSteps", Vector3.new(12, 0.8, 4), Vector3.new(35, 1.9, 37), "White", Enum.Material.Marble, church)
makePart("ChurchUpperSteps", Vector3.new(8, 0.6, 2), Vector3.new(35, 2.8, 38.5), "White", Enum.Material.Marble, church)
makePart("ChurchFloor", Vector3.new(18, 0.5, 24), Vector3.new(35, 2.75, 25), "White", Enum.Material.Marble, church)

-- Gothic architecture walls
makePart("ChurchWallBack", Vector3.new(18, 16, 2), Vector3.new(35, 10, 13), "White", Enum.Material.Brick, church)
makePart("ChurchWallLeft", Vector3.new(2, 16, 24), Vector3.new(26, 10, 25), "White", Enum.Material.Brick, church)
makePart("ChurchWallRight", Vector3.new(2, 16, 24), Vector3.new(44, 10, 25), "White", Enum.Material.Brick, church)
-- Front wall with grand entrance
makePart("ChurchFrontL", Vector3.new(6, 16, 2), Vector3.new(29, 10, 37), "White", Enum.Material.Brick, church)
makePart("ChurchFrontR", Vector3.new(6, 16, 2), Vector3.new(41, 10, 37), "White", Enum.Material.Brick, church)
makePart("ChurchEntryArch", Vector3.new(8, 8, 2), Vector3.new(35, 15, 37), "White", Enum.Material.Brick, church)

-- Grand entrance doors (CanCollide false for entry)
makePart("ChurchDoors", Vector3.new(6, 12, 0.5), Vector3.new(35, 8, 37.5), "Reddish brown", Enum.Material.Wood, church, {CanCollide = false, Transparency = 0.15})
makePart("DoorFrameArch", Vector3.new(8, 14, 1), Vector3.new(35, 9, 37.3), "Dark stone grey", Enum.Material.Marble, church, {CanCollide = false})
-- Door handles
makePart("DoorHandleL", Vector3.new(0.3, 1.2, 0.3), Vector3.new(32, 8, 37.8), "Bright yellow", Enum.Material.Metal, church, {CanCollide = false})
makePart("DoorHandleR", Vector3.new(0.3, 1.2, 0.3), Vector3.new(38, 8, 37.8), "Bright yellow", Enum.Material.Metal, church, {CanCollide = false})

-- Magnificent stained glass windows (larger and more elaborate)
local stainedGlassData = {
	{26, 11, 18, "Bright blue", "✝️"}, {44, 11, 18, "Bright violet", "🕊️"},
	{26, 11, 22, "Bright green", "🌟"}, {44, 11, 22, "Bright red", "❤️"},
	{26, 11, 28, "Bright yellow", "⭐"}, {44, 11, 28, "Hot pink", "🌸"},
	{26, 11, 32, "Bright orange", "🔥"}, {44, 11, 32, "Bright cyan", "💧"}
}
for i, glass in ipairs(stainedGlassData) do
	-- Window frame
	makePart("WindowFrame" .. i, Vector3.new(0.8, 7, 4), Vector3.new(glass[1], glass[2], glass[3]), "Dark stone grey", Enum.Material.Marble, church)
	-- Colored glass
	makePart("StainedGlass" .. i, Vector3.new(0.4, 6, 3), Vector3.new(glass[1], glass[2], glass[3]), glass[4], Enum.Material.Neon, church, {Transparency = 0.3})
	-- Symbol on glass
	local glassSign = makePart("GlassSymbol" .. i, Vector3.new(1, 1, 1), Vector3.new(glass[1], glass[2], glass[3]), "White", nil, church, {Transparency = 1})
	makeSign(glassSign, glass[5], Vector3.new(0, 0, 0), UDim2.new(4, 0, 4, 0))
end

-- Rose window (circular stained glass above entrance)
makePart("RoseWindowFrame", Vector3.new(0.8, 6, 6), Vector3.new(35, 16, 37), "Dark stone grey", Enum.Material.Marble, church)
makePart("RoseWindow", Vector3.new(0.4, 5, 5), Vector3.new(35, 16, 37), "Bright violet", Enum.Material.Neon, church, {Transparency = 0.2})

-- Flying buttresses (Gothic support structures)
makePart("Buttress1", Vector3.new(2, 12, 4), Vector3.new(23, 12, 18), "White", Enum.Material.Marble, church)
makePart("Buttress2", Vector3.new(2, 12, 4), Vector3.new(47, 12, 18), "White", Enum.Material.Marble, church)
makePart("Buttress3", Vector3.new(2, 12, 4), Vector3.new(23, 12, 32), "White", Enum.Material.Marble, church)
makePart("Buttress4", Vector3.new(2, 12, 4), Vector3.new(47, 12, 32), "White", Enum.Material.Marble, church)

-- Vaulted roof system
makeWedge("ChurchRoofNorth", Vector3.new(18, 8, 12), Vector3.new(35, 21, 19), "Dark stone grey", Enum.Material.Slate, church)
makeWedge("ChurchRoofSouth", Vector3.new(18, 8, 12), Vector3.new(35, 21, 31), "Dark stone grey", Enum.Material.Slate, church, {Orientation = Vector3.new(0, 180, 0)})
makePart("ChurchRoofRidge", Vector3.new(20, 1, 1), Vector3.new(35, 25, 25), "Dark stone grey", Enum.Material.Slate, church)

-- Twin bell towers (Gothic cathedral style)
makePart("BellTowerL", Vector3.new(6, 20, 6), Vector3.new(29, 20, 37), "White", Enum.Material.Brick, church)
makePart("BellTowerR", Vector3.new(6, 20, 6), Vector3.new(41, 20, 37), "White", Enum.Material.Brick, church)
-- Tower spires
makeWedge("SpireL", Vector3.new(6, 8, 6), Vector3.new(29, 34, 37), "Dark stone grey", Enum.Material.Slate, church)
makeWedge("SpireR", Vector3.new(6, 8, 6), Vector3.new(41, 34, 37), "Dark stone grey", Enum.Material.Slate, church)

-- Bell tower bells
makePart("BellL", Vector3.new(2, 3, 2), Vector3.new(29, 28, 37), "Dark stone grey", Enum.Material.Metal, church)
makePart("BellR", Vector3.new(2, 3, 2), Vector3.new(41, 28, 37), "Dark stone grey", Enum.Material.Metal, church)

-- Central steeple (tallest)
makePart("MainSteeple", Vector3.new(8, 16, 8), Vector3.new(35, 26, 13), "White", Enum.Material.Brick, church)
makeWedge("MainSpire", Vector3.new(8, 10, 8), Vector3.new(35, 39, 13), "Dark stone grey", Enum.Material.Slate, church)
-- Golden cross on main spire
makePart("CrossV", Vector3.new(0.8, 6, 0.8), Vector3.new(35, 47, 13), "Bright yellow", Enum.Material.Metal, church)
makePart("CrossH", Vector3.new(4, 0.8, 0.8), Vector3.new(35, 48, 13), "Bright yellow", Enum.Material.Metal, church)

-- Enhanced interior (prayer area)
-- Grand altar
makePart("AltarBase", Vector3.new(8, 2, 4), Vector3.new(35, 4, 14), "White", Enum.Material.Marble, church)
makePart("AltarTop", Vector3.new(8, 0.5, 4), Vector3.new(35, 5.25, 14), "Bright yellow", Enum.Material.Metal, church)
makePart("AltarCloth", Vector3.new(8.2, 0.1, 4.2), Vector3.new(35, 5.6, 14), "Bright violet", Enum.Material.Fabric, church)

-- Altar decorations
makePart("Chalice", Vector3.new(1, 1.5, 1), Vector3.new(35, 6.25, 14), "Bright yellow", Enum.Material.Metal, church)
makePart("Candle1", Vector3.new(0.3, 2, 0.3), Vector3.new(33, 6.5, 14), "White", Enum.Material.SmoothPlastic, church)
makePart("Candle2", Vector3.new(0.3, 2, 0.3), Vector3.new(37, 6.5, 14), "White", Enum.Material.SmoothPlastic, church)
makePart("Flame1", Vector3.new(0.5, 0.8, 0.5), Vector3.new(33, 7.9, 14), "Bright orange", Enum.Material.Neon, church, {Transparency = 0.5})
makePart("Flame2", Vector3.new(0.5, 0.8, 0.5), Vector3.new(37, 7.9, 14), "Bright orange", Enum.Material.Neon, church, {Transparency = 0.5})

-- Prayer pews (wooden benches in rows)
for row = 1, 6 do
	local z = 18 + row * 2.5
	-- Left side pews
	makePart("PewL" .. row, Vector3.new(6, 2.5, 2), Vector3.new(30, 4.25, z), "Reddish brown", Enum.Material.Wood, church)
	makePart("PewBackL" .. row, Vector3.new(6, 3, 0.3), Vector3.new(30, 5, z + 1), "Reddish brown", Enum.Material.Wood, church)
	-- Right side pews
	makePart("PewR" .. row, Vector3.new(6, 2.5, 2), Vector3.new(40, 4.25, z), "Reddish brown", Enum.Material.Wood, church)
	makePart("PewBackR" .. row, Vector3.new(6, 3, 0.3), Vector3.new(40, 5, z + 1), "Reddish brown", Enum.Material.Wood, church)
end

-- Prayer kneeling cushions
for i = 1, 12 do
	local x = 30 + (i % 2) * 10
	local z = 18 + math.floor((i-1) / 2) * 2.5 - 0.8
	makePart("Cushion" .. i, Vector3.new(5, 0.5, 1), Vector3.new(x, 3.25, z), "Bright violet", Enum.Material.Fabric, church)
end

-- Pulpit
makePart("PulpitBase", Vector3.new(3, 4, 3), Vector3.new(35, 5, 20), "White", Enum.Material.Marble, church)
makePart("PulpitTop", Vector3.new(4, 0.5, 4), Vector3.new(35, 7.25, 20), "Reddish brown", Enum.Material.Wood, church)
makePart("PulpitStairs", Vector3.new(2, 2, 1), Vector3.new(35, 4, 22), "White", Enum.Material.Marble, church)

-- Holy water fonts
makePart("FontL", Vector3.new(2, 3, 2), Vector3.new(28, 4.5, 35), "White", Enum.Material.Marble, church)
makePart("FontR", Vector3.new(2, 3, 2), Vector3.new(42, 4.5, 35), "White", Enum.Material.Marble, church)
makePart("HolyWaterL", Vector3.new(1.5, 0.3, 1.5), Vector3.new(28, 5.9, 35), Color3.fromRGB(65, 130, 175), Enum.Material.Water, church, {Transparency = 0.3})
makePart("HolyWaterR", Vector3.new(1.5, 0.3, 1.5), Vector3.new(42, 5.9, 35), Color3.fromRGB(65, 130, 175), Enum.Material.Water, church, {Transparency = 0.3})

-- Cathedral lighting (holy ambiance)
local churchLights = {
	{29, 0, 40}, {41, 0, 40}, {26, 0, 25}, {44, 0, 25}, {35, 0, 35}, {35, 0, 15}
}
for _, pos in ipairs(churchLights) do
	-- Holy braziers instead of lanterns
	makePart("HolyBrazier" .. _, Vector3.new(1.5, 3, 1.5), Vector3.new(pos[1], pos[2] + 3, pos[3]), "Dark stone grey", Enum.Material.Metal, church)
	makePart("HolyFlame" .. _, Vector3.new(2, 4, 2), Vector3.new(pos[1], pos[2] + 6, pos[3]), "Bright yellow", Enum.Material.Neon, church, {Transparency = 0.5})
	local holyLight = Instance.new("PointLight")
	holyLight.Color = Color3.fromRGB(255, 240, 200)
	holyLight.Brightness = 0.5
	holyLight.Range = 12
	holyLight.Parent = church:FindFirstChild("HolyFlame" .. _)
end

-- Grand cathedral sign
local churchSign = makePart("ChurchSign", Vector3.new(1, 1, 1), Vector3.new(35, 20, 40), "White", nil, church, {Transparency = 1})
makeSign(churchSign, "⛪ CATHEDRAL OF LIGHT\n🙏 HOUSE OF PRAYER", Vector3.new(0, 0, 0), UDim2.new(14, 0, 4, 0))

-- ============================================================
-- === TOWN DECORATIONS AND LANDSCAPING ===
-- ============================================================
local townDecor = getOrMake(cityFolder, "TownDecorations")

-- Trees and bushes around town perimeter (inside walls)
local function makeDecorativeTree(position, scale, leafColor)
	scale = scale or 1
	leafColor = leafColor or "Forest green"
	-- Tree trunk
	makePart("DecorTree", Vector3.new(2*scale, 8*scale, 2*scale), position + Vector3.new(0, 4*scale, 0), "Reddish brown", Enum.Material.Wood, townDecor)
	-- Tree foliage (fuller canopy)
	makePart("DecorLeaves", Vector3.new(8*scale, 8*scale, 8*scale), position + Vector3.new(0, 9*scale, 0), leafColor, Enum.Material.Grass, townDecor)
	-- Additional leaf layers for fullness
	makePart("DecorLeavesLower", Vector3.new(6*scale, 4*scale, 6*scale), position + Vector3.new(0, 6*scale, 0), leafColor, Enum.Material.Grass, townDecor)
	makePart("DecorLeavesUpper", Vector3.new(4*scale, 3*scale, 4*scale), position + Vector3.new(0, 12*scale, 0), leafColor, Enum.Material.Grass, townDecor)
end

-- Decorative trees OUTSIDE the city walls (walls at x=±62, z=-10 to z=108)
local perimeterTrees = {
	-- Outside north wall (z < -10)
	{-50, 0, -20}, {-30, 0, -22}, {30, 0, -20}, {50, 0, -22},
	-- Outside west wall (x < -62)
	{-72, 0, 10}, {-74, 0, 30}, {-70, 0, 50}, {-73, 0, 70}, {-71, 0, 90},
	-- Outside east wall (x > 62)
	{72, 0, 10}, {74, 0, 30}, {70, 0, 50}, {73, 0, 70}, {71, 0, 90},
	-- Outside south wall (z > 108)
	{-50, 0, 118}, {-25, 0, 120}, {25, 0, 118}, {50, 0, 120},
}

for i, pos in ipairs(perimeterTrees) do
	local scale = 0.8 + math.random() * 0.4
	local leafColors = {"Forest green", "Earth green", "Dark green"}
	makeDecorativeTree(Vector3.new(pos[1], pos[2], pos[3]), scale, leafColors[math.random(#leafColors)])
end

-- Small decorative bushes — only in open areas away from buildings
local bushPositions = {
	{-50, 0, 50}, {50, 0, 50}, -- along inner walls
}

for i, pos in ipairs(bushPositions) do
	makePart("Bush" .. i, Vector3.new(2, 1.5, 2), Vector3.new(pos[1], pos[2] + 0.75, pos[3]), "Forest green", Enum.Material.Grass, townDecor, {CanCollide = false})
end

-- (Gardens removed — too much visual clutter inside town)

-- Street decorations and furniture
local streetDecor = {
	-- Water troughs for horses
	{{-15, 1, 95}, "WaterTrough", Vector3.new(4, 2, 2), "Medium stone grey"},
	{{15, 1, 95}, "WaterTrough2", Vector3.new(4, 2, 2), "Medium stone grey"},
	-- Hitching posts
	{{-20, 2.5, 95}, "HitchPost", Vector3.new(0.5, 5, 0.5), "Reddish brown"},
	{{20, 2.5, 95}, "HitchPost2", Vector3.new(0.5, 5, 0.5), "Reddish brown"},
	-- Notice boards
	{{-5, 3, 95}, "NoticeBoard", Vector3.new(0.3, 4, 3), "Brown"},
	{{5, 3, 95}, "NoticeBoard2", Vector3.new(0.3, 4, 3), "Brown"},
	-- Town stocks (medieval punishment device)
	{{-40, 2, 90}, "Stocks", Vector3.new(4, 2, 1), "Reddish brown"},
	-- Wells in quarters
	{{-40, 2, 30}, "NorthWell", Vector3.new(3, 4, 3), "Medium stone grey"},
	{{40, 2, 30}, "NorthWellE", Vector3.new(3, 4, 3), "Medium stone grey"},
}

for i, item in ipairs(streetDecor) do
	makePart(item[2], item[3], Vector3.new(item[1][1], item[1][2], item[1][3]), item[4], Enum.Material.Wood, townDecor)
	-- Add water to troughs and wells
	if string.find(item[2], "Trough") or string.find(item[2], "Well") then
		makePart(item[2] .. "Water", Vector3.new(item[3].X - 0.2, 0.3, item[3].Z - 0.2), Vector3.new(item[1][1], item[1][2] + item[3].Y/2 - 0.2, item[1][3]), Color3.fromRGB(65, 130, 175), Enum.Material.Water, townDecor, {Transparency = 0.3})
	end
end

-- Decorative signposts throughout town
local signposts = {
	{-30, "🏦 BANK →", {30, 6, 50}},
	{30, "← 🏪 SHOP", {-30, 6, 50}},
	{0, "⛪ CATHEDRAL ↑", {35, 6, 40}},
	{-90, "🔨 SMITHY ↖", {-25, 6, 30}},
	{45, "🍺 TAVERN ↗", {-10, 6, 80}},
	{135, "🏪 MARKET ↙", {-25, 6, 70}},
}

for i, sign in ipairs(signposts) do
	local post = makePart("Signpost" .. i, Vector3.new(0.5, 4, 0.5), Vector3.new(sign[3][1], sign[3][2] - 2, sign[3][3]), "Reddish brown", Enum.Material.Wood, townDecor)
	local board = makePart("SignBoard" .. i, Vector3.new(6, 1.5, 0.3), Vector3.new(sign[3][1], sign[3][2], sign[3][3]), "Brown", Enum.Material.Wood, townDecor)
	board.Orientation = Vector3.new(0, sign[1], 0)
	local signText = makePart("SignText" .. i, Vector3.new(1, 1, 1), Vector3.new(sign[3][1], sign[3][2], sign[3][3]), "White", nil, townDecor, {Transparency = 1})
	makeSign(signText, sign[2], Vector3.new(0, 0, 0), UDim2.new(8, 0, 2, 0))
end

-- Decorative crates, barrels, and clutter around town
local clutter = {
	-- Near shops
	{-50, 1.5, 45, "Barrel", Vector3.new(2, 3, 2), "Reddish brown"},
	{-52, 1.5, 47, "Barrel", Vector3.new(2, 3, 2), "Reddish brown"},
	{48, 1.25, 45, "Crate", Vector3.new(2.5, 2.5, 2.5), "Brown"},
	{50, 1.25, 47, "Crate", Vector3.new(2.5, 2.5, 2.5), "Brown"},
	-- Near tavern
	{-8, 1.5, 88, "AleBarel", Vector3.new(2, 3, 2), "Reddish brown"},
	{-6, 1.5, 88, "AleBarel2", Vector3.new(2, 3, 2), "Reddish brown"},
	-- Near smithy
	{-40, 1, 25, "CoalPile", Vector3.new(3, 1.5, 3), "Black"},
	{-38, 1, 27, "IronOre", Vector3.new(2, 2, 2), "Dark stone grey"},
	-- Random town clutter
	{10, 1, 90, "WoodenBox", Vector3.new(2, 2, 2), "Brown"},
	{-25, 1, 60, "Sack", Vector3.new(1.5, 2.5, 1.5), "Dusty Rose"},
	{25, 1, 40, "Chest", Vector3.new(3, 2, 2), "Reddish brown"},
}

for i, item in ipairs(clutter) do
	makePart("TownClutter" .. i, item[5], Vector3.new(item[1], item[2], item[3]), item[6], Enum.Material.Wood, townDecor)
end

-- (Flower patches removed — too much visual clutter)

-- Decorative stone paths connecting major areas
local pathSegments = {
	-- Path from fountain to bank
	{{10, 0.35, 50}, {15, 0.35, 50}, {20, 0.35, 50}, {25, 0.35, 50}},
	-- Path from fountain to shop  
	{{-10, 0.35, 50}, {-15, 0.35, 50}, {-20, 0.35, 50}, {-25, 0.35, 50}},
	-- Path from square to cathedral
	{{0, 0.35, 45}, {5, 0.35, 40}, {15, 0.35, 35}, {25, 0.35, 30}},
	-- Path from square to smithy
	{{0, 0.35, 45}, {-5, 0.35, 40}, {-15, 0.35, 35}, {-25, 0.35, 30}},
}

for i, path in ipairs(pathSegments) do
	for j, segment in ipairs(path) do
		makePart("DecorPath" .. i .. j, Vector3.new(4, 0.1, 4), Vector3.new(segment[1], 0.36, segment[3]), "Light stone grey", Enum.Material.Cobblestone, townDecor)
	end
end

-- ============================================================
-- === TAVERN (south-central, near gate) ===
-- ============================================================
local tavern = getOrMake(cityFolder, "Tavern")
makePart("TavernFoundation", Vector3.new(18, 1, 14), Vector3.new(-15, 0.5, 85), "Dark stone grey", Enum.Material.Cobblestone, tavern)
makePart("TavernFloor", Vector3.new(16, 0.3, 12), Vector3.new(-15, 1.15, 85), "Reddish brown", Enum.Material.WoodPlanks, tavern)
makePart("TavernWallBack", Vector3.new(16, 10, 1), Vector3.new(-15, 6, 79), "Brown", Enum.Material.Wood, tavern)
makePart("TavernWallLeft", Vector3.new(1, 10, 12), Vector3.new(-23, 6, 85), "Brown", Enum.Material.Wood, tavern)
makePart("TavernWallRight", Vector3.new(1, 10, 12), Vector3.new(-7, 6, 85), "Brown", Enum.Material.Wood, tavern)
makePart("TavernRoof", Vector3.new(20, 1, 16), Vector3.new(-15, 11.5, 85), "Reddish brown", Enum.Material.Wood, tavern)
-- Second floor
makePart("TavernFloor2", Vector3.new(16, 0.5, 12), Vector3.new(-15, 6, 85), "Reddish brown", Enum.Material.WoodPlanks, tavern, {Transparency = 0.1})
-- Bar counter
makePart("BarCounter", Vector3.new(10, 3, 2), Vector3.new(-15, 2.5, 81), "Reddish brown", Enum.Material.WoodPlanks, tavern)
-- Tables
makePart("Table1", Vector3.new(3, 2, 3), Vector3.new(-19, 2, 86), "Reddish brown", Enum.Material.Wood, tavern)
makePart("Table2", Vector3.new(3, 2, 3), Vector3.new(-11, 2, 86), "Reddish brown", Enum.Material.Wood, tavern)
-- Kegs behind bar
makePart("Keg1", Vector3.new(2, 3, 2), Vector3.new(-19, 1.5, 80), "Reddish brown", Enum.Material.Wood, tavern)
makePart("Keg2", Vector3.new(2, 3, 2), Vector3.new(-17, 1.5, 80), "Reddish brown", Enum.Material.Wood, tavern)
local tavernSign = makePart("TavernSign", Vector3.new(1, 1, 1), Vector3.new(-15, 13, 91), "White", nil, tavern, {Transparency = 1})
makeSign(tavernSign, "🍺 The Rusty Blade Tavern", Vector3.new(0, 0, 0))
makeTorch(Vector3.new(-7, 3, 91), tavern)
makeTorch(Vector3.new(-23, 3, 91), tavern)

-- ============================================================
-- === GUARD TOWER (near gate, east side) ===
-- ============================================================
local guardTower = getOrMake(cityFolder, "GuardTower")
makePart("GTBase", Vector3.new(8, 20, 8), Vector3.new(15, 10, 85), "Medium stone grey", Enum.Material.Cobblestone, guardTower)
makePart("GTTop", Vector3.new(10, 1, 10), Vector3.new(15, 20.5, 85), "Dark stone grey", Enum.Material.Cobblestone, guardTower)
makePart("GTRail1", Vector3.new(10, 3, 0.5), Vector3.new(15, 22.5, 80), "Dark stone grey", Enum.Material.Cobblestone, guardTower)
makePart("GTRail2", Vector3.new(10, 3, 0.5), Vector3.new(15, 22.5, 90), "Dark stone grey", Enum.Material.Cobblestone, guardTower)
makePart("GTRail3", Vector3.new(0.5, 3, 10), Vector3.new(10, 22.5, 85), "Dark stone grey", Enum.Material.Cobblestone, guardTower)
makePart("GTRail4", Vector3.new(0.5, 3, 10), Vector3.new(20, 22.5, 85), "Dark stone grey", Enum.Material.Cobblestone, guardTower)
-- Ladder
makePart("Ladder", Vector3.new(0.5, 20, 2), Vector3.new(19, 10, 85), "Reddish brown", Enum.Material.Wood, guardTower)
local gtSign = makePart("GTSign", Vector3.new(1, 1, 1), Vector3.new(15, 25, 85), "White", nil, guardTower, {Transparency = 1})
makeSign(gtSign, "🛡️ Guard Tower", Vector3.new(0, 0, 0))

-- ============================================================
-- === HAVEN MARKETPLACE (BUSTLING MEDIEVAL MARKET) ===
-- ============================================================
local market = getOrMake(cityFolder, "Market")

-- Market square cobblestone foundation (slightly above city floor to avoid z-fighting)
makePart("MarketFloor", Vector3.new(60, 0.12, 40), Vector3.new(-35, 0.37, 75), "Medium stone grey", Enum.Material.Cobblestone, market)

-- Enhanced market stalls with detailed architecture
local stallData = {
	{-50, "Bright red", "🍞 BAKER"}, {-40, "Bright blue", "🐟 FISHMONGER"},
	{-30, "Bright green", "🥕 GROCER"}, {-20, "Bright yellow", "🧵 TAILOR"}
}
for i, stall in ipairs(stallData) do
	local xOff = stall[1]
	local color = stall[2]
	local sign = stall[3]
	
	-- Stall frame (more robust)
	makePart("Stall" .. i .. "PostFL", Vector3.new(0.8, 8, 0.8), Vector3.new(xOff - 4, 4, 72), "Reddish brown", Enum.Material.Wood, market)
	makePart("Stall" .. i .. "PostFR", Vector3.new(0.8, 8, 0.8), Vector3.new(xOff + 4, 4, 72), "Reddish brown", Enum.Material.Wood, market)
	makePart("Stall" .. i .. "PostBL", Vector3.new(0.8, 8, 0.8), Vector3.new(xOff - 4, 4, 78), "Reddish brown", Enum.Material.Wood, market)
	makePart("Stall" .. i .. "PostBR", Vector3.new(0.8, 8, 0.8), Vector3.new(xOff + 4, 4, 78), "Reddish brown", Enum.Material.Wood, market)
	
	-- Cross beams for structure
	makePart("Stall" .. i .. "BeamF", Vector3.new(8.5, 0.5, 0.5), Vector3.new(xOff, 7.5, 72), "Reddish brown", Enum.Material.Wood, market)
	makePart("Stall" .. i .. "BeamB", Vector3.new(8.5, 0.5, 0.5), Vector3.new(xOff, 7.5, 78), "Reddish brown", Enum.Material.Wood, market)
	makePart("Stall" .. i .. "BeamL", Vector3.new(0.5, 0.5, 6.5), Vector3.new(xOff - 4, 7.5, 75), "Reddish brown", Enum.Material.Wood, market)
	makePart("Stall" .. i .. "BeamR", Vector3.new(0.5, 0.5, 6.5), Vector3.new(xOff + 4, 7.5, 75), "Reddish brown", Enum.Material.Wood, market)
	
	-- Sloped roof awning
	makeWedge("Stall" .. i .. "RoofF", Vector3.new(9, 1.5, 3), Vector3.new(xOff, 8.75, 73.5), color, Enum.Material.Fabric, market)
	makeWedge("Stall" .. i .. "RoofB", Vector3.new(9, 1.5, 3), Vector3.new(xOff, 8.75, 76.5), color, Enum.Material.Fabric, market, {Orientation = Vector3.new(0, 180, 0)})
	
	-- Counter and shelving
	makePart("Stall" .. i .. "Counter", Vector3.new(8, 3.5, 2.5), Vector3.new(xOff, 2.25, 73), "Reddish brown", Enum.Material.WoodPlanks, market)
	makePart("Stall" .. i .. "BackShelf", Vector3.new(8, 4, 1), Vector3.new(xOff, 2.5, 77.5), "Reddish brown", Enum.Material.Wood, market)
	makePart("Stall" .. i .. "SideShelfL", Vector3.new(1, 4, 4), Vector3.new(xOff - 3.5, 2.5, 75), "Reddish brown", Enum.Material.Wood, market)
	makePart("Stall" .. i .. "SideShelfR", Vector3.new(1, 4, 4), Vector3.new(xOff + 3.5, 2.5, 75), "Reddish brown", Enum.Material.Wood, market)
	
	-- Stall-specific goods
	if i == 1 then -- Baker
		makePart("Bread1", Vector3.new(1.2, 0.6, 1), Vector3.new(xOff - 2, 4.3, 73), "Nougat", Enum.Material.SmoothPlastic, market)
		makePart("Bread2", Vector3.new(1, 0.5, 0.8), Vector3.new(xOff + 1, 4.3, 73), "Nougat", Enum.Material.SmoothPlastic, market)
		makePart("BreadBasket", Vector3.new(2, 1, 1.5), Vector3.new(xOff, 4.5, 77.5), "Brown", Enum.Material.Wood, market)
	elseif i == 2 then -- Fishmonger
		makePart("Fish1", Vector3.new(1.5, 0.3, 0.8), Vector3.new(xOff - 1, 4.3, 73), "Medium blue", Enum.Material.SmoothPlastic, market)
		makePart("Fish2", Vector3.new(1.2, 0.3, 0.6), Vector3.new(xOff + 2, 4.3, 73), "Medium blue", Enum.Material.SmoothPlastic, market)
		makePart("IceBox", Vector3.new(3, 2, 2), Vector3.new(xOff, 3, 77), "Light blue", Enum.Material.Ice, market)
	elseif i == 3 then -- Grocer
		makePart("Apples", Vector3.new(1.5, 1, 1.5), Vector3.new(xOff - 2, 4.8, 73), "Bright red", Enum.Material.SmoothPlastic, market)
		makePart("Carrots", Vector3.new(1, 1.5, 1), Vector3.new(xOff + 1, 4.8, 73), "Bright orange", Enum.Material.SmoothPlastic, market)
		makePart("Cabbage", Vector3.new(1.2, 1.2, 1.2), Vector3.new(xOff + 2, 4.8, 77.5), "Earth green", Enum.Material.SmoothPlastic, market)
	elseif i == 4 then -- Tailor
		makePart("Fabric1", Vector3.new(2, 0.3, 1.5), Vector3.new(xOff - 1.5, 4.3, 73), "Bright red", Enum.Material.Fabric, market)
		makePart("Fabric2", Vector3.new(2, 0.3, 1.5), Vector3.new(xOff + 1.5, 4.3, 73), "Bright blue", Enum.Material.Fabric, market)
		makePart("Thread", Vector3.new(0.8, 0.8, 0.8), Vector3.new(xOff, 4.6, 77.5), "Bright yellow", Enum.Material.SmoothPlastic, market)
	end
	
	-- Stall sign
	local stallSign = makePart("StallSign" .. i, Vector3.new(1, 1, 1), Vector3.new(xOff, 9.5, 75), "White", nil, market, {Transparency = 1})
	makeSign(stallSign, sign, Vector3.new(0, 0, 0), UDim2.new(8, 0, 2, 0))
end

-- Central market well
makePart("MarketWellBase", Vector3.new(6, 3, 6), Vector3.new(-35, 1.5, 85), "Medium stone grey", Enum.Material.Cobblestone, market)
makePart("MarketWellRim", Vector3.new(6.5, 0.5, 6.5), Vector3.new(-35, 3.25, 85), "Medium stone grey", Enum.Material.Marble, market)
makePart("MarketWellWater", Vector3.new(5, 0.3, 5), Vector3.new(-35, 2.9, 85), Color3.fromRGB(65, 130, 175), Enum.Material.Water, market, {Transparency = 0.3})
-- Well post and bucket system
makePart("WellPost", Vector3.new(0.8, 6, 0.8), Vector3.new(-35, 6, 85), "Reddish brown", Enum.Material.Wood, market)
makePart("WellCrossbeam", Vector3.new(4, 0.6, 0.6), Vector3.new(-35, 9, 85), "Reddish brown", Enum.Material.Wood, market)
makePart("WellRoof", Vector3.new(5, 0.4, 5), Vector3.new(-35, 9.8, 85), "Dark red", Enum.Material.Wood, market)
makePart("WellBucket", Vector3.new(1.5, 2, 1.5), Vector3.new(-33, 7, 85), "Dark stone grey", Enum.Material.Metal, market)

-- Market decorations and atmosphere
local decorItems = {
	-- Flower carts
	{-15, 1, 70, "FlowerCart", Vector3.new(3, 2, 1.5), "Reddish brown"},
	{-55, 1, 80, "FlowerCart2", Vector3.new(3, 2, 1.5), "Reddish brown"},
	-- Spare barrels and crates
	{-58, 1.5, 72, "MarketBarrel1", Vector3.new(2, 3, 2), "Reddish brown"},
	{-58, 1.5, 74, "MarketBarrel2", Vector3.new(2, 3, 2), "Reddish brown"},
	{-12, 1.25, 82, "MarketCrate1", Vector3.new(2.5, 2.5, 2.5), "Brown"},
	{-10, 1.25, 82, "MarketCrate2", Vector3.new(2.5, 2.5, 2.5), "Brown"},
}
for i, item in ipairs(decorItems) do
	makePart(item[4], item[5], Vector3.new(item[1], item[2], item[3]), item[6], Enum.Material.Wood, market)
end

-- Flowers in flower carts
local flowers = {"Bright red", "Bright yellow", "Bright violet", "Hot pink"}
for i, pos in ipairs({{-15, 70}, {-55, 80}}) do
	for j = 1, 4 do
		makePart("CartFlower" .. i .. j, Vector3.new(0.4, 1, 0.4), Vector3.new(pos[1] + math.random(-1, 1), 2.8, pos[2] + math.random(-1, 1)), flowers[j], Enum.Material.SmoothPlastic, market, {CanCollide = false})
	end
end

-- Market entrance arch
makePart("MarketArchL", Vector3.new(4, 12, 4), Vector3.new(-65, 6, 75), "Medium stone grey", Enum.Material.Cobblestone, market)
makePart("MarketArchR", Vector3.new(4, 12, 4), Vector3.new(-5, 6, 75), "Medium stone grey", Enum.Material.Cobblestone, market)
makePart("MarketArchTop", Vector3.new(64, 4, 4), Vector3.new(-35, 12, 75), "Medium stone grey", Enum.Material.Cobblestone, market)

-- Grand market sign
local marketSign = makePart("MarketSign", Vector3.new(1, 1, 1), Vector3.new(-35, 16, 75), "White", nil, market, {Transparency = 1})
makeSign(marketSign, "🏪 HAVEN MARKETPLACE", Vector3.new(0, 0, 0), UDim2.new(14, 0, 4, 0))

-- Market lighting
local marketLanterns = {
	{-25, 0, 70}, {-45, 0, 70}, {-25, 0, 80}, {-45, 0, 80}, {-35, 0, 65}, {-35, 0, 90}
}
for _, pos in ipairs(marketLanterns) do
	makeLantern(Vector3.new(pos[1], pos[2], pos[3]), market)
end

-- ============================================================
-- === FISHING POND (south-east, inside walls) ===
-- ============================================================
local pond = getOrMake(safeZone, "FishingPond")
-- Pond water
makePart("PondWater", Vector3.new(30, 0.5, 20), Vector3.new(80, -0.25, 80), Color3.fromRGB(65, 130, 175), Enum.Material.Water, pond, {Transparency = 0.3})
-- Pond banks (dirt edges)
makePart("PondBankN", Vector3.new(34, 1, 3), Vector3.new(80, 0, 69), "Brown", Enum.Material.Ground, pond)
makePart("PondBankS", Vector3.new(34, 1, 3), Vector3.new(80, 0, 91), "Brown", Enum.Material.Ground, pond)
makePart("PondBankW", Vector3.new(3, 1, 20), Vector3.new(64, 0, 80), "Brown", Enum.Material.Ground, pond)
makePart("PondBankE", Vector3.new(3, 1, 20), Vector3.new(96, 0, 80), "Brown", Enum.Material.Ground, pond)
-- Reeds / cattails
for i = 1, 6 do
	local rx = 64 + math.random(0, 30)
	local rz = 70 + math.random(0, 18)
	makePart("Reed" .. i, Vector3.new(0.3, 3 + math.random(), 0.3), Vector3.new(rx, 1.5, rz), "Earth green", Enum.Material.Grass, pond)
end
-- Dock / pier
makePart("Dock", Vector3.new(4, 0.5, 12), Vector3.new(80, 0.5, 86), "Reddish brown", Enum.Material.WoodPlanks, pond)
makePart("DockPost1", Vector3.new(0.5, 3, 0.5), Vector3.new(78, 0.5, 92), "Reddish brown", Enum.Material.Wood, pond)
makePart("DockPost2", Vector3.new(0.5, 3, 0.5), Vector3.new(82, 0.5, 92), "Reddish brown", Enum.Material.Wood, pond)
local pondSign = makePart("PondSign", Vector3.new(1, 1, 1), Vector3.new(80, 3, 68), "White", nil, pond, {Transparency = 1})
makeSign(pondSign, "🎣 Haven Pond", Vector3.new(0, 0, 0))

-- Second smaller pond (lily pond)
makePart("LilyPond", Vector3.new(14, 0.5, 10), Vector3.new(110, -0.25, 60), Color3.fromRGB(65, 130, 175), Enum.Material.Water, pond, {Transparency = 0.3})
makePart("LilyPondBank", Vector3.new(18, 0.8, 14), Vector3.new(110, -0.1, 60), "Brown", Enum.Material.Ground, pond)
-- Lily pads
for i = 1, 4 do
	makePart("LilyPad" .. i, Vector3.new(2, 0.1, 2), Vector3.new(106 + i * 2, 0.1, 58 + math.random(-3, 3)), "Earth green", Enum.Material.Grass, pond)
end

-- ============================================================
-- === MINING CAVE (west side, outside walls) ===
-- ============================================================
local mine = getOrMake(safeZone, "MiningCave")
-- Cave entrance (big rocky arch)
makePart("CaveWallL", Vector3.new(6, 16, 8), Vector3.new(-100, 8, 30), "Dark stone grey", Enum.Material.Slate, mine)
makePart("CaveWallR", Vector3.new(6, 16, 8), Vector3.new(-86, 8, 30), "Dark stone grey", Enum.Material.Slate, mine)
makePart("CaveArch", Vector3.new(20, 5, 8), Vector3.new(-93, 18.5, 30), "Dark stone grey", Enum.Material.Slate, mine)
-- Cave interior (hollowed out area)
makePart("CaveFloor", Vector3.new(30, 0.3, 30), Vector3.new(-93, 0.15, 15), "Dark stone grey", Enum.Material.Slate, mine)
makePart("CaveRoof", Vector3.new(34, 2, 34), Vector3.new(-93, 14, 15), "Dark stone grey", Enum.Material.Slate, mine)
makePart("CaveWallBack", Vector3.new(34, 14, 2), Vector3.new(-93, 7, -1), "Dark stone grey", Enum.Material.Slate, mine)
makePart("CaveWallSideL", Vector3.new(2, 14, 34), Vector3.new(-110, 7, 15), "Dark stone grey", Enum.Material.Slate, mine)
makePart("CaveWallSideR", Vector3.new(2, 14, 34), Vector3.new(-76, 7, 15), "Dark stone grey", Enum.Material.Slate, mine)
-- Cave supports (wooden beams)
makePart("Support1", Vector3.new(1, 12, 1), Vector3.new(-100, 6, 20), "Reddish brown", Enum.Material.Wood, mine)
makePart("Support2", Vector3.new(1, 12, 1), Vector3.new(-86, 6, 20), "Reddish brown", Enum.Material.Wood, mine)
makePart("SupportBeam", Vector3.new(16, 1, 1), Vector3.new(-93, 12, 20), "Reddish brown", Enum.Material.Wood, mine)
makePart("Support3", Vector3.new(1, 12, 1), Vector3.new(-100, 6, 8), "Reddish brown", Enum.Material.Wood, mine)
makePart("Support4", Vector3.new(1, 12, 1), Vector3.new(-86, 6, 8), "Reddish brown", Enum.Material.Wood, mine)
makePart("SupportBeam2", Vector3.new(16, 1, 1), Vector3.new(-93, 12, 8), "Reddish brown", Enum.Material.Wood, mine)
-- Mine cart tracks
makePart("Track1", Vector3.new(0.3, 0.2, 30), Vector3.new(-91.5, 0.3, 15), "Dark stone grey", Enum.Material.Metal, mine)
makePart("Track2", Vector3.new(0.3, 0.2, 30), Vector3.new(-94.5, 0.3, 15), "Dark stone grey", Enum.Material.Metal, mine)
-- Mine cart
makePart("CartBody", Vector3.new(3, 2, 4), Vector3.new(-93, 1.5, 22), "Dark stone grey", Enum.Material.Metal, mine)
makePart("CartWheel1", Vector3.new(1.5, 1.5, 0.3), Vector3.new(-91.5, 0.8, 24), "Black", Enum.Material.Metal, mine)
makePart("CartWheel2", Vector3.new(1.5, 1.5, 0.3), Vector3.new(-94.5, 0.8, 24), "Black", Enum.Material.Metal, mine)
-- Torch lighting inside cave
makeTorch(Vector3.new(-100, 3, 15), mine)
makeTorch(Vector3.new(-86, 3, 15), mine)
makeTorch(Vector3.new(-100, 3, 5), mine)
makeTorch(Vector3.new(-86, 3, 5), mine)
-- Ore veins (visual, the actual clickable nodes are from SkillManager)
makePart("OreVeinCopper", Vector3.new(3, 3, 1), Vector3.new(-109, 3, 10), "Nougat", Enum.Material.Slate, mine)
makePart("OreVeinIron", Vector3.new(2, 4, 1), Vector3.new(-109, 4, 18), "Dark stone grey", Enum.Material.Slate, mine)
local mineSign = makePart("MineSign", Vector3.new(1, 1, 1), Vector3.new(-93, 22, 34), "White", nil, mine, {Transparency = 1})
makeSign(mineSign, "⛏️ Haven Mine", Vector3.new(0, 0, 0), UDim2.new(10, 0, 2, 0))

-- ============================================================
-- === FOREST (east side, outside walls) ===
-- ============================================================
local forest = getOrMake(safeZone, "Forest")
-- Grass clearing floor
makePart("ForestFloor", Vector3.new(80, 0.15, 80), Vector3.new(130, 0.08, 30), "Earth green", Enum.Material.Grass, forest)
-- Scattered decorative trees (non-clickable, just scenery)
local function makeSceneryTree(pos, scale, leafColor)
	scale = scale or 1
	leafColor = leafColor or "Forest green"
	makePart("STree", Vector3.new(2*scale, 10*scale, 2*scale), pos + Vector3.new(0, 5*scale, 0), "Reddish brown", Enum.Material.Wood, forest)
	makePart("SLeaf", Vector3.new(10*scale, 10*scale, 10*scale), pos + Vector3.new(0, 11*scale, 0), leafColor, Enum.Material.Grass, forest)
end
-- Dense forest — many trees
local treePositions = {
	{100, 0, 10}, {110, 0, 15}, {120, 0, 5}, {105, 0, 25}, {115, 0, 30},
	{130, 0, 10}, {140, 0, 20}, {150, 0, 15}, {135, 0, 35}, {145, 0, 40},
	{100, 0, 45}, {110, 0, 50}, {125, 0, 55}, {155, 0, 30}, {160, 0, 45},
	{115, 0, 60}, {130, 0, 65}, {145, 0, 55}, {150, 0, 65}, {105, 0, 70},
}
for _, tp in ipairs(treePositions) do
	local scale = 0.7 + math.random() * 0.6
	local colors = {"Forest green", "Earth green", "Dark green", "Bright green"}
	makeSceneryTree(Vector3.new(tp[1], tp[2], tp[3]), scale, colors[math.random(#colors)])
end
-- Path into forest
makePart("ForestPath", Vector3.new(4, 0.12, 40), Vector3.new(90, 0.06, 30), "Brown", Enum.Material.Ground, forest)
local forestSign = makePart("ForestSign", Vector3.new(1, 1, 1), Vector3.new(90, 4, 50), "White", nil, forest, {Transparency = 1})
makeSign(forestSign, "🌲 Haven Forest", Vector3.new(0, 0, 0))

-- ============================================================
-- === WILDERNESS — THEMED ZONES ===
-- ============================================================

-- Helper: dead tree (reusable)
local function makeDeadTree(position, parent)
	parent = parent or wilderness
	makePart("DeadTrunk", Vector3.new(1.5, 7, 1.5), position + Vector3.new(0, 3.5, 0), "Dark stone grey", Enum.Material.Wood, parent)
	makePart("DeadBranch1", Vector3.new(0.5, 3, 0.5), position + Vector3.new(1.5, 6, 0), "Dark stone grey", Enum.Material.Wood, parent, {Orientation = Vector3.new(0, 0, 30)})
	makePart("DeadBranch2", Vector3.new(0.5, 2.5, 0.5), position + Vector3.new(-1, 5, 0.5), "Dark stone grey", Enum.Material.Wood, parent, {Orientation = Vector3.new(0, 0, -25)})
end

-- Helper: warning sign
local function makeWarningSign(position, text)
	text = text or "DANGER"
	makePart("SignPost", Vector3.new(0.5, 4, 0.5), position + Vector3.new(0, 2, 0), "Reddish brown", Enum.Material.Wood, wilderness)
	local board = makePart("SignBoard", Vector3.new(3, 2, 0.3), position + Vector3.new(0, 4.5, 0), "Brown", Enum.Material.Wood, wilderness)
	makeSign(board, text, Vector3.new(0, 1, 0))
end

-- Helper: rock cluster
local function makeRockCluster(center, count, spread, parent)
	parent = parent or wilderness
	for i = 1, count do
		local ox = (math.random() - 0.5) * spread
		local oz = (math.random() - 0.5) * spread
		local s = 2 + math.random() * 3
		makePart("Rock"..i, Vector3.new(s, s * 0.7, s * 0.9), center + Vector3.new(ox, s * 0.35, oz), "Dark stone grey", Enum.Material.Slate, parent)
	end
end

-- ---- WILDERNESS BORDER (z = -100 to -110) ----
-- Warning signs at the border
makeWarningSign(Vector3.new(0, 0, -105), "WILDERNESS")
makeWarningSign(Vector3.new(-40, 0, -105), "DANGER")
makeWarningSign(Vector3.new(40, 0, -105), "DANGER")

-- === WILDERNESS BARRIER — low red wall you can jump over ===
local wildBorder = getOrMake(safeZone, "WildernessBorder")
-- Main wall segments (left and right of path gap)
makePart("RedWallLeft", Vector3.new(90, 3, 2), Vector3.new(-49, 1.5, -100), Color3.fromRGB(140, 20, 20), Enum.Material.Brick, wildBorder)
makePart("RedWallRight", Vector3.new(90, 3, 2), Vector3.new(49, 1.5, -100), Color3.fromRGB(140, 20, 20), Enum.Material.Brick, wildBorder)
-- Gap posts (frame the path opening, 8 stud gap)
makePart("RedPostL", Vector3.new(2, 5, 2), Vector3.new(-4, 2.5, -100), Color3.fromRGB(100, 10, 10), Enum.Material.Brick, wildBorder)
makePart("RedPostR", Vector3.new(2, 5, 2), Vector3.new(4, 2.5, -100), Color3.fromRGB(100, 10, 10), Enum.Material.Brick, wildBorder)
-- Top trim (darker red accent line)
makePart("RedTrimL", Vector3.new(90, 0.4, 2.2), Vector3.new(-49, 3.2, -100), Color3.fromRGB(80, 5, 5), Enum.Material.Metal, wildBorder)
makePart("RedTrimR", Vector3.new(90, 0.4, 2.2), Vector3.new(49, 3.2, -100), Color3.fromRGB(80, 5, 5), Enum.Material.Metal, wildBorder)
-- Warning sign above gap
local wildWallSign = makePart("WildWallSign", Vector3.new(1, 1, 1), Vector3.new(0, 6, -100), "White", nil, wildBorder, {Transparency = 1})
makeSign(wildWallSign, "WILDERNESS", Vector3.new(0, 0, 0), UDim2.new(8, 0, 2, 0))

-- Dirt path from Haven north gate into wilderness
makePart("NorthPath", Vector3.new(8, 0.12, 80), Vector3.new(0, 0.06, -50), "Brown", Enum.Material.Ground, safeZone)
makePart("WildMainPath", Vector3.new(6, 0.12, 400), Vector3.new(0, 0.06, -300), "Dark stone grey", Enum.Material.Ground, wilderness)

-- Wilderness ground — darker terrain floor
makePart("WildFloorNear", Vector3.new(200, 0.15, 100), Vector3.new(0, 0.05, -155), Color3.fromRGB(60, 55, 45), Enum.Material.Ground, wilderness)
makePart("WildFloorMid", Vector3.new(200, 0.15, 150), Vector3.new(0, 0.05, -280), Color3.fromRGB(50, 45, 38), Enum.Material.Ground, wilderness)
makePart("WildFloorDeep", Vector3.new(200, 0.15, 200), Vector3.new(0, 0.05, -430), Color3.fromRGB(35, 30, 28), Enum.Material.Ground, wilderness)

-- ============================================================
-- ZONE 1: SKELETON GRAVEYARD (z: -120 to -165)
-- ============================================================
local graveyard = getOrMake(wilderness, "Graveyard")
-- Ground: dark earth
makePart("GraveFloor", Vector3.new(80, 0.18, 50), Vector3.new(-30, 0.07, -145), Color3.fromRGB(45, 40, 35), Enum.Material.Ground, graveyard)
-- Iron fence perimeter
makePart("GraveFenceN", Vector3.new(80, 3, 0.3), Vector3.new(-30, 1.5, -120), "Black", Enum.Material.Metal, graveyard)
makePart("GraveFenceS", Vector3.new(80, 3, 0.3), Vector3.new(-30, 1.5, -170), "Black", Enum.Material.Metal, graveyard)
makePart("GraveFenceW", Vector3.new(0.3, 3, 50), Vector3.new(-70, 1.5, -145), "Black", Enum.Material.Metal, graveyard)
makePart("GraveFenceE", Vector3.new(0.3, 3, 50), Vector3.new(10, 1.5, -145), "Black", Enum.Material.Metal, graveyard)
-- Gate opening on east side
makePart("GatePostL", Vector3.new(1, 5, 1), Vector3.new(10, 2.5, -140), "Dark stone grey", Enum.Material.Cobblestone, graveyard)
makePart("GatePostR", Vector3.new(1, 5, 1), Vector3.new(10, 2.5, -150), "Dark stone grey", Enum.Material.Cobblestone, graveyard)
-- Gravestones in rows
for row = 0, 2 do
	for col = 0, 5 do
		local gx = -60 + col * 10
		local gz = -130 - row * 14
		makePart("Grave"..row..col, Vector3.new(2, 3, 0.5), Vector3.new(gx, 1.5, gz), "Medium stone grey", Enum.Material.Cobblestone, graveyard)
		makePart("Mound"..row..col, Vector3.new(3, 0.5, 4), Vector3.new(gx, 0.25, gz + 2.5), Color3.fromRGB(50, 42, 35), Enum.Material.Ground, graveyard)
	end
end
-- Dead trees in graveyard
makeDeadTree(Vector3.new(-55, 0, -135), graveyard)
makeDeadTree(Vector3.new(-10, 0, -155), graveyard)
makeDeadTree(Vector3.new(-35, 0, -165), graveyard)
-- Eerie fog
makePart("GraveFog1", Vector3.new(30, 2, 20), Vector3.new(-40, 1, -140), Color3.fromRGB(80, 80, 90), Enum.Material.SmoothPlastic, graveyard, {Transparency = 0.9, CanCollide = false})
makePart("GraveFog2", Vector3.new(25, 2, 15), Vector3.new(-20, 1, -155), Color3.fromRGB(80, 80, 90), Enum.Material.SmoothPlastic, graveyard, {Transparency = 0.9, CanCollide = false})
local graveSign = makePart("GraveSign", Vector3.new(1, 1, 1), Vector3.new(10, 6, -145), "White", nil, graveyard, {Transparency = 1})
makeSign(graveSign, "Forgotten Graveyard", Vector3.new(0, 0, 0))

-- ============================================================
-- ZONE 2: DARK WIZARD RUINS (z: -165 to -195)
-- ============================================================
local ruins = getOrMake(wilderness, "AncientRuins")
-- Stone platform
makePart("RuinFloor", Vector3.new(50, 0.5, 40), Vector3.new(60, 0.25, -178), "Medium stone grey", Enum.Material.Cobblestone, ruins)
-- Crumbling walls
makePart("RuinWallN", Vector3.new(40, 10, 2), Vector3.new(60, 5, -160), "Medium stone grey", Enum.Material.Cobblestone, ruins)
makePart("RuinWallW", Vector3.new(2, 8, 30), Vector3.new(37, 4, -175), "Medium stone grey", Enum.Material.Cobblestone, ruins)
makePart("RuinWallBroken", Vector3.new(15, 5, 2), Vector3.new(52, 2.5, -195), "Medium stone grey", Enum.Material.Cobblestone, ruins)
-- Intact pillars
for i = 0, 3 do
	local px = 45 + i * 10
	local pHeight = (i == 1 or i == 3) and 10 or 6
	makePart("Pillar"..i, Vector3.new(2, pHeight, 2), Vector3.new(px, pHeight/2, -165), "Medium stone grey", Enum.Material.Marble, ruins)
end
-- Fallen pillar on ground
makePart("FallenPillar", Vector3.new(2, 2, 8), Vector3.new(55, 1, -180), "Medium stone grey", Enum.Material.Marble, ruins, {Orientation = Vector3.new(0, 25, 90)})
-- Dark magic circle on floor
makePart("MagicCircle", Vector3.new(12, 0.08, 12), Vector3.new(60, 0.55, -178), "Really black", Enum.Material.Neon, ruins, {Transparency = 0.4})
-- Candles around circle
for a = 0, 5 do
	local angle = a * (math.pi * 2 / 6)
	local cx = 60 + math.cos(angle) * 7
	local cz = -178 + math.sin(angle) * 7
	makePart("Candle"..a, Vector3.new(0.3, 1, 0.3), Vector3.new(cx, 1, cz), "Institutional white", Enum.Material.SmoothPlastic, ruins)
	local candleLight = Instance.new("PointLight")
	candleLight.Color = Color3.fromRGB(255, 180, 80)
	candleLight.Brightness = 0.5
	candleLight.Range = 6
	candleLight.Parent = ruins:FindFirstChild("Candle"..a)
end
local ruinSign = makePart("RuinSign", Vector3.new(1, 1, 1), Vector3.new(60, 12, -160), "White", nil, ruins, {Transparency = 1})
makeSign(ruinSign, "Ancient Ruins", Vector3.new(0, 0, 0))

-- ============================================================
-- ZONE 3: DEMON WASTELAND (z: -260 to -330)
-- ============================================================
local demonZone = getOrMake(wilderness, "DemonWaste")
-- Scorched ground
makePart("ScorchedFloor", Vector3.new(100, 0.2, 80), Vector3.new(0, 0.08, -295), Color3.fromRGB(30, 20, 15), Enum.Material.Ground, demonZone)
-- Lava cracks in the ground
for i = 1, 8 do
	local cx = -35 + math.random(0, 70)
	local cz = -270 - math.random(0, 50)
	local cw = 8 + math.random(0, 12)
	makePart("LavaCrack"..i, Vector3.new(cw, 0.15, 0.5 + math.random() * 0.5), Vector3.new(cx, 0.2, cz), "Bright orange", Enum.Material.Neon, demonZone, {Transparency = 0.2, Orientation = Vector3.new(0, math.random(-30, 30), 0)})
end
-- Lava pit (center of demon area)
makePart("LavaRim", Vector3.new(24, 1.5, 24), Vector3.new(0, 0.75, -295), "Dark stone grey", Enum.Material.Slate, demonZone)
makePart("LavaPool", Vector3.new(18, 0.5, 18), Vector3.new(0, 0.15, -295), "Bright red", Enum.Material.Neon, demonZone, {Transparency = 0.15})
local lavaLight = Instance.new("PointLight")
lavaLight.Color = Color3.fromRGB(255, 60, 20)
lavaLight.Brightness = 1.2
lavaLight.Range = 50
local lavaPoolPart = demonZone:FindFirstChild("LavaPool")
if lavaPoolPart then lavaLight.Parent = lavaPoolPart end
-- Dark obsidian spires
makePart("Spire1", Vector3.new(3, 18, 3), Vector3.new(-30, 9, -280), "Really black", Enum.Material.Slate, demonZone)
makePart("Spire2", Vector3.new(4, 22, 4), Vector3.new(35, 11, -310), "Really black", Enum.Material.Slate, demonZone)
makePart("Spire3", Vector3.new(2.5, 14, 2.5), Vector3.new(-20, 7, -315), "Really black", Enum.Material.Slate, demonZone)
makePart("Spire4", Vector3.new(3, 16, 3), Vector3.new(25, 8, -275), "Really black", Enum.Material.Slate, demonZone)
-- Lava rocks
makePart("LavaRock1", Vector3.new(5, 3, 4), Vector3.new(15, 1.5, -285), "Black", Enum.Material.Slate, demonZone)
makePart("LavaRock2", Vector3.new(4, 4, 5), Vector3.new(-12, 2, -305), "Black", Enum.Material.Slate, demonZone)
makePart("LavaRock3", Vector3.new(6, 2.5, 4), Vector3.new(8, 1.25, -320), "Black", Enum.Material.Slate, demonZone)
-- Smoke/ash
for i = 1, 4 do
	local sx = -20 + math.random(0, 40)
	local sz = -280 - math.random(0, 40)
	makePart("Smoke"..i, Vector3.new(15, 6, 15), Vector3.new(sx, 3, sz), Color3.fromRGB(40, 30, 25), Enum.Material.SmoothPlastic, demonZone, {Transparency = 0.85, CanCollide = false})
end
local demonSign = makePart("DemonSign", Vector3.new(1, 1, 1), Vector3.new(0, 6, -260), "White", nil, demonZone, {Transparency = 1})
makeSign(demonSign, "Demon Wasteland", Vector3.new(0, 0, 0))

-- ============================================================
-- ZONE 4: DARK WATERS (z: -200 to -240)
-- ============================================================
local darkPond = getOrMake(wilderness, "DarkPond")
makePart("DPBank", Vector3.new(30, 0.8, 22), Vector3.new(-60, -0.1, -220), Color3.fromRGB(40, 35, 30), Enum.Material.Ground, darkPond)
makePart("DPWater", Vector3.new(24, 0.5, 16), Vector3.new(-60, -0.25, -220), Color3.fromRGB(20, 60, 90), Enum.Material.Water, darkPond, {Transparency = 0.25})
-- Glowing mushrooms along shore
for i = 1, 6 do
	local angle = i * (math.pi * 2 / 6)
	local mx = -60 + math.cos(angle) * 14
	local mz = -220 + math.sin(angle) * 10
	local shroom = makePart("Mushroom"..i, Vector3.new(0.8, 1.2, 0.8), Vector3.new(mx, 0.6, mz), "Bright violet", Enum.Material.Neon, darkPond, {Transparency = 0.3})
	local shroomLight = Instance.new("PointLight")
	shroomLight.Color = Color3.fromRGB(140, 40, 200)
	shroomLight.Brightness = 0.6
	shroomLight.Range = 6
	shroomLight.Parent = shroom
end
-- Dead reeds
for i = 1, 8 do
	local rx = -72 + math.random(0, 24)
	local rz = -228 + math.random(0, 16)
	makePart("Reed"..i, Vector3.new(0.15, 2 + math.random(), 0.15), Vector3.new(rx, 1, rz), "Brown", Enum.Material.Grass, darkPond, {CanCollide = false})
end
local dpSign = makePart("DPSign", Vector3.new(1, 1, 1), Vector3.new(-60, 3, -207), "White", nil, darkPond, {Transparency = 1})
makeSign(dpSign, "Dark Waters", Vector3.new(0, 0, 0))

-- ============================================================
-- ZONE 5: DRAGON'S NEST (z: -430 to -500)
-- ============================================================
local dragonNest = getOrMake(wilderness, "DragonNest")
-- Massive scorched crater
makePart("NestFloor", Vector3.new(120, 0.3, 80), Vector3.new(50, -0.5, -465), Color3.fromRGB(25, 18, 15), Enum.Material.Slate, dragonNest)
makePart("NestRim", Vector3.new(130, 3, 90), Vector3.new(50, 1.5, -465), Color3.fromRGB(35, 25, 20), Enum.Material.Slate, dragonNest)
-- Rim is hollow (floor sits inside)
-- Jagged rock walls surrounding the nest
makePart("NestWallN", Vector3.new(100, 15, 5), Vector3.new(50, 7.5, -425), "Really black", Enum.Material.Slate, dragonNest)
makePart("NestWallS", Vector3.new(100, 12, 5), Vector3.new(50, 6, -505), "Really black", Enum.Material.Slate, dragonNest)
makePart("NestWallW", Vector3.new(5, 14, 80), Vector3.new(-12, 7, -465), "Really black", Enum.Material.Slate, dragonNest)
makePart("NestWallE", Vector3.new(5, 14, 80), Vector3.new(112, 7, -465), "Really black", Enum.Material.Slate, dragonNest)
-- Opening/entrance on north side
makePart("NestGateL", Vector3.new(5, 18, 8), Vector3.new(38, 9, -425), "Really black", Enum.Material.Slate, dragonNest)
makePart("NestGateR", Vector3.new(5, 18, 8), Vector3.new(62, 9, -425), "Really black", Enum.Material.Slate, dragonNest)
-- Lava veins running through the nest floor
for i = 1, 10 do
	local lx = 10 + math.random(0, 80)
	local lz = -490 + math.random(0, 50)
	local lw = 10 + math.random(0, 15)
	makePart("NestLava"..i, Vector3.new(lw, 0.12, 0.8), Vector3.new(lx, -0.3, lz), "Bright orange", Enum.Material.Neon, dragonNest, {Transparency = 0.15, Orientation = Vector3.new(0, math.random(-40, 40), 0)})
end
-- Charred bone piles (trophies)
for i = 1, 5 do
	local bx = 20 + math.random(0, 60)
	local bz = -450 - math.random(0, 35)
	makePart("BonePile"..i, Vector3.new(3 + math.random() * 2, 1, 3 + math.random() * 2), Vector3.new(bx, 0.2, bz), "Institutional white", Enum.Material.SmoothPlastic, dragonNest)
end
-- Giant skull decoration
makePart("GiantSkull", Vector3.new(5, 4, 4), Vector3.new(50, 2, -480), "Institutional white", Enum.Material.SmoothPlastic, dragonNest)
makePart("SkullJaw", Vector3.new(4, 1.5, 3), Vector3.new(50, 0.5, -479), "Institutional white", Enum.Material.SmoothPlastic, dragonNest)
-- Embers floating (neon particles)
for i = 1, 8 do
	local ex = 20 + math.random(0, 60)
	local ez = -445 - math.random(0, 45)
	makePart("Ember"..i, Vector3.new(0.3, 0.3, 0.3), Vector3.new(ex, 1 + math.random() * 3, ez), "Bright orange", Enum.Material.Neon, dragonNest, {CanCollide = false})
end
-- Nest lighting (orange glow)
local nestGlow = Instance.new("PointLight")
nestGlow.Color = Color3.fromRGB(255, 100, 30)
nestGlow.Brightness = 1
nestGlow.Range = 80
local nestFloor = dragonNest:FindFirstChild("NestFloor")
if nestFloor then nestGlow.Parent = nestFloor end
local nestSign = makePart("NestSign", Vector3.new(1, 1, 1), Vector3.new(50, 20, -425), "White", nil, dragonNest, {Transparency = 1})
makeSign(nestSign, "Dragon's Nest", Vector3.new(0, 0, 0), UDim2.new(10, 0, 3, 0))

-- ============================================================
-- ZONE 6: LICH KING'S DOMAIN (z: -370 to -420)
-- ============================================================
local lichDomain = getOrMake(wilderness, "LichDomain")
makePart("LichFloor", Vector3.new(60, 0.3, 60), Vector3.new(-50, 0.1, -395), Color3.fromRGB(20, 15, 25), Enum.Material.Slate, lichDomain)
-- Corrupted stone pillars in a circle
for i = 0, 7 do
	local angle = i * (math.pi * 2 / 8)
	local px = -50 + math.cos(angle) * 25
	local pz = -395 + math.sin(angle) * 25
	local height = 12 + math.random(0, 6)
	makePart("LichPillar"..i, Vector3.new(2.5, height, 2.5), Vector3.new(px, height/2, pz), "Really black", Enum.Material.Cobblestone, lichDomain)
end
-- Central altar
makePart("Altar", Vector3.new(6, 2, 6), Vector3.new(-50, 1, -395), "Really black", Enum.Material.Marble, lichDomain)
makePart("AltarGlow", Vector3.new(4, 0.1, 4), Vector3.new(-50, 2.1, -395), "Royal purple", Enum.Material.Neon, lichDomain, {Transparency = 0.3})
local altarLight = Instance.new("PointLight")
altarLight.Color = Color3.fromRGB(120, 40, 200)
altarLight.Brightness = 1.5
altarLight.Range = 40
local altarPart = lichDomain:FindFirstChild("AltarGlow")
if altarPart then altarLight.Parent = altarPart end
-- Floating dark energy wisps
for i = 1, 6 do
	local wx = -50 + (math.random() - 0.5) * 40
	local wz = -395 + (math.random() - 0.5) * 40
	makePart("Wisp"..i, Vector3.new(0.6, 0.6, 0.6), Vector3.new(wx, 2 + math.random() * 4, wz), "Royal purple", Enum.Material.Neon, lichDomain, {CanCollide = false, Transparency = 0.3})
end
local lichSign = makePart("LichSign", Vector3.new(1, 1, 1), Vector3.new(-50, 8, -370), "White", nil, lichDomain, {Transparency = 1})
makeSign(lichSign, "Lich King's Domain", Vector3.new(0, 0, 0))

-- ============================================================
-- SCATTERED WILDERNESS DECORATIONS (intentional, sparse)
-- ============================================================
-- Dead trees along the main path
local wildDeadTrees = {
	{15, 0, -130}, {-25, 0, -170}, {30, 0, -210}, {-15, 0, -250},
	{20, 0, -340}, {-30, 0, -360}, {45, 0, -190}, {-50, 0, -300},
}
for _, dt in ipairs(wildDeadTrees) do
	makeDeadTree(Vector3.new(dt[1], dt[2], dt[3]))
end

-- Rock formations along path edges (not random, placed)
makeRockCluster(Vector3.new(25, 0, -150), 3, 8)
makeRockCluster(Vector3.new(-30, 0, -200), 3, 10)
makeRockCluster(Vector3.new(35, 0, -270), 4, 12)
makeRockCluster(Vector3.new(-40, 0, -340), 3, 8)

-- Dead bushes (sparse, along path)
local deadBushPositions = {
	{-12, -135}, {18, -160}, {-20, -195}, {25, -230}, {-15, -265},
	{10, -310}, {-25, -350}, {20, -385},
}
for i, db in ipairs(deadBushPositions) do
	makePart("DeadBush"..i, Vector3.new(1.5, 1, 1.5), Vector3.new(db[1], 0.5, db[2]), "Brown", Enum.Material.Grass, wilderness, {CanCollide = false})
end

-- Sparse fog patches (only 3, subtle)
makePart("WildFog1", Vector3.new(40, 3, 30), Vector3.new(0, 1.5, -180), Color3.fromRGB(60, 55, 50), Enum.Material.SmoothPlastic, wilderness, {Transparency = 0.92, CanCollide = false})
makePart("WildFog2", Vector3.new(35, 3, 25), Vector3.new(-30, 1.5, -270), Color3.fromRGB(50, 45, 40), Enum.Material.SmoothPlastic, wilderness, {Transparency = 0.92, CanCollide = false})
makePart("WildFog3", Vector3.new(45, 4, 35), Vector3.new(20, 2, -400), Color3.fromRGB(40, 35, 35), Enum.Material.SmoothPlastic, wilderness, {Transparency = 0.9, CanCollide = false})

-- ============================================================
-- === SAFE ZONE TERRAIN ===
-- ============================================================

-- Gentle hills around Haven
local havenHillData = {
	{-30, 2, 140, 20, 15}, {30, 1.5, 150, 18, 14}, {-50, 2.5, 160, 25, 20},
	{50, 2, 170, 22, 16}, {0, 1.8, 180, 30, 20}, {-80, 2, 130, 15, 12},
	{80, 1.5, 145, 16, 14},
}
for i, h in ipairs(havenHillData) do
	makePart("HavenHill"..i, Vector3.new(h[4], h[2], h[5]), Vector3.new(h[1], h[2]/2, h[3]), "Bright green", Enum.Material.Grass, safeZone)
end

-- Farmland rolling hills
local hillData = {
	{170, 3, 130, 30, 6, 25}, {220, 4, 180, 25, 8, 20}, {280, 2.5, 160, 35, 5, 30},
	{310, 3.5, 200, 20, 7, 22}, {190, 2, 220, 28, 4, 24}, {250, 3, 240, 22, 6, 18},
}
for i, h in ipairs(hillData) do
	makePart("FarmHill"..i, Vector3.new(h[4], h[2], h[6]), Vector3.new(h[1], h[2]/2, h[3]), "Bright green", Enum.Material.Grass, safeZone)
end

-- River (east-west)
makePart("RiverWater", Vector3.new(200, 0.5, 8), Vector3.new(0, -0.3, 0), Color3.fromRGB(65, 130, 175), Enum.Material.Water, safeZone, {Transparency = 0.3, CanCollide = false})
makePart("RiverBankN", Vector3.new(200, 0.6, 3), Vector3.new(0, 0, -5), "Brown", Enum.Material.Ground, safeZone)
makePart("RiverBankS", Vector3.new(200, 0.6, 3), Vector3.new(0, 0, 5), "Brown", Enum.Material.Ground, safeZone)
-- Bridge
makePart("BridgeDeck", Vector3.new(10, 1, 12), Vector3.new(0, 1, 0), "Medium stone grey", Enum.Material.Cobblestone, safeZone)
makePart("BridgeRailL", Vector3.new(1, 3, 12), Vector3.new(-5, 2.5, 0), "Medium stone grey", Enum.Material.Cobblestone, safeZone)
makePart("BridgeRailR", Vector3.new(1, 3, 12), Vector3.new(5, 2.5, 0), "Medium stone grey", Enum.Material.Cobblestone, safeZone)

-- Paths from gates
makePart("WestPath", Vector3.new(30, 0.12, 6), Vector3.new(-78, 0.06, 50), "Brown", Enum.Material.Ground, safeZone)
makePart("EastPath", Vector3.new(30, 0.12, 6), Vector3.new(78, 0.06, 50), "Brown", Enum.Material.Ground, safeZone)
makePart("SouthPath", Vector3.new(8, 0.12, 40), Vector3.new(0, 0.06, 128), "Brown", Enum.Material.Ground, safeZone)

-- Bushes (safe zone, sparse)
for i = 1, 12 do
	local bx = -60 + math.random(0, 220)
	local bz = 115 + math.random(0, 100)
	local bs = 1.5 + math.random() * 1.5
	makePart("Bush"..i, Vector3.new(bs, bs * 0.7, bs), Vector3.new(bx, bs * 0.35, bz), "Forest green", Enum.Material.Grass, safeZone, {CanCollide = false})
end

-- Flowers near Haven
local flowerColors = {"Bright red", "Bright yellow", "Bright violet", "Hot pink"}
for i = 1, 12 do
	local fx = -40 + math.random(0, 80)
	local fz = 115 + math.random(0, 40)
	makePart("Flower"..i, Vector3.new(0.5, 0.8, 0.5), Vector3.new(fx, 0.4, fz), flowerColors[math.random(#flowerColors)], Enum.Material.SmoothPlastic, safeZone, {CanCollide = false})
end

-- Rock formations near mine
for i = 1, 4 do
	local rx = -112 + i * 8
	local rs = 3 + math.random() * 3
	makePart("MineRock"..i, Vector3.new(rs, rs * 1.2, rs * 0.8), Vector3.new(rx, rs * 0.6, 25 + math.random(0, 10)), "Dark stone grey", Enum.Material.Slate, safeZone)
end

-- ============================================================
-- === LIGHTING ===
-- ============================================================
local Lighting = game:GetService("Lighting")
Lighting.Ambient = Color3.fromRGB(80, 80, 100)
Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 120)
Lighting.Brightness = 1.5
Lighting.ClockTime = 10
Lighting.FogEnd = 1200
Lighting.FogColor = Color3.fromRGB(180, 200, 220)

-- ============================================================
-- CRIMSON WARLORD BATTLE ARENA (0, 0, 250)
-- Grand circular arena south of Haven — the centerpiece boss fight
-- ============================================================
local arenaFolder = getOrMake(safeZone, "BattleArena")

-- Arena floor — large circular stone platform
makePart("ArenaFloor", Vector3.new(40, 0.5, 40), Vector3.new(0, 0.25, 250), "Medium stone grey", Enum.Material.Cobblestone, arenaFolder)
-- Inner ring (darker)
makePart("ArenaInner", Vector3.new(28, 0.52, 28), Vector3.new(0, 0.27, 250), "Dark stone grey", Enum.Material.Slate, arenaFolder)
-- Center crimson circle (boss spawn point)
makePart("ArenaCenterRing", Vector3.new(10, 0.54, 10), Vector3.new(0, 0.28, 250), Color3.fromRGB(120, 20, 20), Enum.Material.Marble, arenaFolder)
makePart("ArenaCenterCore", Vector3.new(5, 0.56, 5), Vector3.new(0, 0.29, 250), Color3.fromRGB(180, 30, 30), Enum.Material.Neon, arenaFolder, {Transparency = 0.3})

-- Arena walls (stone pillars around perimeter)
local pillarAngles = 12
for i = 1, pillarAngles do
	local angle = (i / pillarAngles) * math.pi * 2
	local px = math.cos(angle) * 22
	local pz = math.sin(angle) * 22 + 250

	-- Stone pillar
	makePart("ArenaPillar" .. i, Vector3.new(2, 10, 2), Vector3.new(px, 5, pz), "Dark stone grey", Enum.Material.Cobblestone, arenaFolder)
	-- Pillar cap
	makePart("PillarCap" .. i, Vector3.new(2.5, 0.5, 2.5), Vector3.new(px, 10.25, pz), "Dark stone grey", Enum.Material.Slate, arenaFolder)

	-- Every 3rd pillar gets a torch
	if i % 3 == 0 then
		makePart("Torch" .. i, Vector3.new(0.3, 1.5, 0.3), Vector3.new(px, 8.5, pz), "Brown", Enum.Material.Wood, arenaFolder)
		local flame = makePart("TorchFlame" .. i, Vector3.new(0.6, 0.8, 0.6), Vector3.new(px, 9.5, pz), Color3.fromRGB(255, 100, 0), Enum.Material.Neon, arenaFolder, {Transparency = 0.3, CanCollide = false})
	end
end

-- Iron chain fences between pillars (low walls)
for i = 1, pillarAngles do
	local a1 = (i / pillarAngles) * math.pi * 2
	local a2 = ((i % pillarAngles + 1) / pillarAngles) * math.pi * 2
	local mx = (math.cos(a1) + math.cos(a2)) / 2 * 22
	local mz = (math.sin(a1) + math.sin(a2)) / 2 * 22 + 250
	local dx = math.cos(a2) * 22 - math.cos(a1) * 22
	local dz = (math.sin(a2) - math.sin(a1)) * 22
	local fenceLen = math.sqrt(dx * dx + dz * dz)
	local fenceAngle = math.deg(math.atan2(dx, dz))
	makePart("ArenaFence" .. i, Vector3.new(fenceLen, 3, 0.5), Vector3.new(mx, 1.5, mz), "Dark stone grey", Enum.Material.Metal, arenaFolder, {CanCollide = true, Orientation = Vector3.new(0, fenceAngle, 0)})
end

-- Entrance path from Haven (north side of arena)
makePart("ArenaPath", Vector3.new(6, 0.3, 30), Vector3.new(0, 0.15, 220), "Brown", Enum.Material.Ground, arenaFolder)
makePart("ArenaPathStone", Vector3.new(8, 0.4, 4), Vector3.new(0, 0.2, 230), "Medium stone grey", Enum.Material.Cobblestone, arenaFolder)

-- Grand entrance arch
makePart("ArchLeft", Vector3.new(2, 12, 2), Vector3.new(-4, 6, 228), "Dark stone grey", Enum.Material.Cobblestone, arenaFolder)
makePart("ArchRight", Vector3.new(2, 12, 2), Vector3.new(4, 6, 228), "Dark stone grey", Enum.Material.Cobblestone, arenaFolder)
makePart("ArchTop", Vector3.new(10, 2, 2), Vector3.new(0, 12, 228), "Dark stone grey", Enum.Material.Cobblestone, arenaFolder)
-- Crimson banner on arch
makePart("BannerL", Vector3.new(0.1, 4, 1.5), Vector3.new(-3, 8, 227.5), Color3.fromRGB(120, 15, 15), Enum.Material.Fabric, arenaFolder)
makePart("BannerR", Vector3.new(0.1, 4, 1.5), Vector3.new(3, 8, 227.5), Color3.fromRGB(120, 15, 15), Enum.Material.Fabric, arenaFolder)

-- Arena sign
local arenaSign = makePart("ArenaSign", Vector3.new(1, 1, 1), Vector3.new(0, 14, 228), "White", nil, arenaFolder, {Transparency = 1})
makeSign(arenaSign, "CRIMSON ARENA", Vector3.new(0, 0, 0), UDim2.new(10, 0, 2, 0))

-- Skull decorations on ground near entrance
makePart("Skull1", Vector3.new(0.8, 0.8, 0.8), Vector3.new(-6, 0.4, 232), "White", Enum.Material.SmoothPlastic, arenaFolder)
makePart("Skull2", Vector3.new(0.8, 0.8, 0.8), Vector3.new(7, 0.4, 235), "White", Enum.Material.SmoothPlastic, arenaFolder)

-- Weapon racks (decoration on sides)
makePart("WeaponRack1", Vector3.new(3, 4, 0.5), Vector3.new(-18, 2, 245), "Brown", Enum.Material.Wood, arenaFolder)
makePart("RackSword1", Vector3.new(0.2, 3, 0.1), Vector3.new(-18, 3, 244.5), Color3.fromRGB(180, 180, 190), Enum.Material.Metal, arenaFolder)
makePart("WeaponRack2", Vector3.new(3, 4, 0.5), Vector3.new(18, 2, 245), "Brown", Enum.Material.Wood, arenaFolder)
makePart("RackSword2", Vector3.new(0.2, 3, 0.1), Vector3.new(18, 3, 244.5), Color3.fromRGB(180, 180, 190), Enum.Material.Metal, arenaFolder)

print("[MapSetup] Battle Arena built at (0, 0, 250)")

-- ============================================================
-- WILDERNESS CASTLE — "The Dark Fortress" (0, 0, -350)
-- Deep wilderness PvP castle. Multi-level, towers, moat, throne room.
-- Center of PvP warfare. High-risk, high-reward territory.
-- ============================================================
local castleFolder = getOrMake(wilderness, "DarkFortress")
local CX, CZ = 0, -350 -- Castle center

-- === MOAT (lava ring around castle) ===
-- Outer lava moat ring (4 segments)
makePart("MoatN", Vector3.new(80, 2, 8), Vector3.new(CX, -1, CZ - 44), Color3.fromRGB(200, 60, 0), Enum.Material.Neon, castleFolder, {Transparency = 0.2, CanCollide = false})
makePart("MoatS", Vector3.new(80, 2, 8), Vector3.new(CX, -1, CZ + 44), Color3.fromRGB(200, 60, 0), Enum.Material.Neon, castleFolder, {Transparency = 0.2, CanCollide = false})
makePart("MoatE", Vector3.new(8, 2, 80), Vector3.new(CX + 44, -1, CZ), Color3.fromRGB(200, 60, 0), Enum.Material.Neon, castleFolder, {Transparency = 0.2, CanCollide = false})
makePart("MoatW", Vector3.new(8, 2, 80), Vector3.new(CX - 44, -1, CZ), Color3.fromRGB(200, 60, 0), Enum.Material.Neon, castleFolder, {Transparency = 0.2, CanCollide = false})

-- Drawbridge (south entrance — from Haven direction)
makePart("Drawbridge", Vector3.new(12, 1, 10), Vector3.new(CX, 0.5, CZ + 44), "Brown", Enum.Material.WoodPlanks, castleFolder)

-- === OUTER WALLS (40x40 perimeter, 20 studs high) ===
local WH = 20 -- wall height
local WS2 = 40 -- half-size of castle square
makePart("OuterWallN", Vector3.new(80, WH, 4), Vector3.new(CX, WH/2, CZ - WS2), "Dark stone grey", Enum.Material.Cobblestone, castleFolder)
makePart("OuterWallS_L", Vector3.new(30, WH, 4), Vector3.new(CX - 25, WH/2, CZ + WS2), "Dark stone grey", Enum.Material.Cobblestone, castleFolder)
makePart("OuterWallS_R", Vector3.new(30, WH, 4), Vector3.new(CX + 25, WH/2, CZ + WS2), "Dark stone grey", Enum.Material.Cobblestone, castleFolder)
makePart("OuterWallS_Top", Vector3.new(20, 8, 4), Vector3.new(CX, WH - 4 + WH/2 - 6, CZ + WS2), "Dark stone grey", Enum.Material.Cobblestone, castleFolder)
makePart("OuterWallE", Vector3.new(4, WH, 80), Vector3.new(CX + WS2, WH/2, CZ), "Dark stone grey", Enum.Material.Cobblestone, castleFolder)
makePart("OuterWallW", Vector3.new(4, WH, 80), Vector3.new(CX - WS2, WH/2, CZ), "Dark stone grey", Enum.Material.Cobblestone, castleFolder)

-- Gate arch (south wall gap)
makePart("GateArchTop", Vector3.new(20, 6, 4), Vector3.new(CX, WH - 3, CZ + WS2), "Dark stone grey", Enum.Material.Cobblestone, castleFolder)
-- Portcullis (iron gate)
makePart("Portcullis", Vector3.new(12, 14, 0.5), Vector3.new(CX, 7, CZ + WS2), Color3.fromRGB(60, 60, 70), Enum.Material.Metal, castleFolder, {Transparency = 0.3, CanCollide = false})

-- === WALL CRENELLATIONS (battlements along top) ===
for i = -36, 36, 4 do
	-- North wall merlons
	makePart("MerlonN" .. i, Vector3.new(2, 3, 1), Vector3.new(CX + i, WH + 1.5, CZ - WS2 + 2), "Dark stone grey", Enum.Material.Cobblestone, castleFolder)
	-- South wall merlons (skip gate area)
	if math.abs(i) > 8 then
		makePart("MerlonS" .. i, Vector3.new(2, 3, 1), Vector3.new(CX + i, WH + 1.5, CZ + WS2 - 2), "Dark stone grey", Enum.Material.Cobblestone, castleFolder)
	end
end
for i = -36, 36, 4 do
	makePart("MerlonE" .. i, Vector3.new(1, 3, 2), Vector3.new(CX + WS2 - 2, WH + 1.5, CZ + i), "Dark stone grey", Enum.Material.Cobblestone, castleFolder)
	makePart("MerlonW" .. i, Vector3.new(1, 3, 2), Vector3.new(CX - WS2 + 2, WH + 1.5, CZ + i), "Dark stone grey", Enum.Material.Cobblestone, castleFolder)
end

-- Wall walkway (along top of walls)
makePart("WalkwayN", Vector3.new(76, 1, 4), Vector3.new(CX, WH + 0.5, CZ - WS2), "Medium stone grey", Enum.Material.Slate, castleFolder)
makePart("WalkwayS", Vector3.new(76, 1, 4), Vector3.new(CX, WH + 0.5, CZ + WS2), "Medium stone grey", Enum.Material.Slate, castleFolder)
makePart("WalkwayE", Vector3.new(4, 1, 76), Vector3.new(CX + WS2, WH + 0.5, CZ), "Medium stone grey", Enum.Material.Slate, castleFolder)
makePart("WalkwayW", Vector3.new(4, 1, 76), Vector3.new(CX - WS2, WH + 0.5, CZ), "Medium stone grey", Enum.Material.Slate, castleFolder)

-- === CORNER TOWERS (4 towers, 30 studs tall) ===
local TH = 30
local corners = {
	{CX - WS2, CZ - WS2, "NW"},
	{CX + WS2, CZ - WS2, "NE"},
	{CX - WS2, CZ + WS2, "SW"},
	{CX + WS2, CZ + WS2, "SE"},
}
for _, c in ipairs(corners) do
	local tx, tz, tag = c[1], c[2], c[3]
	-- Tower body (cylindrical look — octagonal with 2 parts)
	makePart("Tower" .. tag, Vector3.new(8, TH, 8), Vector3.new(tx, TH/2, tz), "Dark stone grey", Enum.Material.Cobblestone, castleFolder)
	-- Tower cap (wider top)
	makePart("TowerCap" .. tag, Vector3.new(10, 2, 10), Vector3.new(tx, TH + 1, tz), "Dark stone grey", Enum.Material.Slate, castleFolder)
	-- Tower roof (pointed)
	makeWedge("TowerRoof" .. tag .. "A", Vector3.new(10, 8, 6), Vector3.new(tx, TH + 6, tz - 2), "Dark red", Enum.Material.Slate, castleFolder)
	makeWedge("TowerRoof" .. tag .. "B", Vector3.new(10, 8, 6), Vector3.new(tx, TH + 6, tz + 2), "Dark red", Enum.Material.Slate, castleFolder, {Orientation = Vector3.new(0, 180, 0)})
	-- Tower merlons (4 per tower)
	makePart("TowerMerlon" .. tag .. "1", Vector3.new(2, 3, 1), Vector3.new(tx - 3, TH + 3.5, tz - 4), "Dark stone grey", Enum.Material.Cobblestone, castleFolder)
	makePart("TowerMerlon" .. tag .. "2", Vector3.new(2, 3, 1), Vector3.new(tx + 3, TH + 3.5, tz - 4), "Dark stone grey", Enum.Material.Cobblestone, castleFolder)
	makePart("TowerMerlon" .. tag .. "3", Vector3.new(2, 3, 1), Vector3.new(tx - 3, TH + 3.5, tz + 4), "Dark stone grey", Enum.Material.Cobblestone, castleFolder)
	makePart("TowerMerlon" .. tag .. "4", Vector3.new(2, 3, 1), Vector3.new(tx + 3, TH + 3.5, tz + 4), "Dark stone grey", Enum.Material.Cobblestone, castleFolder)
	-- Torch on each tower
	makePart("TowerTorch" .. tag, Vector3.new(0.4, 2, 0.4), Vector3.new(tx, TH - 4, tz + 4.5), "Brown", Enum.Material.Wood, castleFolder)
	makePart("TowerFlame" .. tag, Vector3.new(0.8, 1, 0.8), Vector3.new(tx, TH - 2.5, tz + 4.5), Color3.fromRGB(255, 120, 0), Enum.Material.Neon, castleFolder, {CanCollide = false, Transparency = 0.2})
end

-- === COURTYARD (ground floor) ===
makePart("CourtyardFloor", Vector3.new(72, 0.5, 72), Vector3.new(CX, 0.25, CZ), "Medium stone grey", Enum.Material.Cobblestone, castleFolder)
-- Darker inner pattern
makePart("CourtyardInner", Vector3.new(40, 0.52, 40), Vector3.new(CX, 0.27, CZ), "Dark stone grey", Enum.Material.Slate, castleFolder)

-- === THE KEEP (central tower — throne room) ===
local KH = 25 -- keep height
-- Keep walls
makePart("KeepWallN", Vector3.new(24, KH, 3), Vector3.new(CX, KH/2, CZ - 12), Color3.fromRGB(50, 45, 55), Enum.Material.Cobblestone, castleFolder)
makePart("KeepWallS_L", Vector3.new(8, KH, 3), Vector3.new(CX - 8, KH/2, CZ + 12), Color3.fromRGB(50, 45, 55), Enum.Material.Cobblestone, castleFolder)
makePart("KeepWallS_R", Vector3.new(8, KH, 3), Vector3.new(CX + 8, KH/2, CZ + 12), Color3.fromRGB(50, 45, 55), Enum.Material.Cobblestone, castleFolder)
makePart("KeepArch", Vector3.new(8, 8, 3), Vector3.new(CX, KH - 4, CZ + 12), Color3.fromRGB(50, 45, 55), Enum.Material.Cobblestone, castleFolder)
makePart("KeepWallE", Vector3.new(3, KH, 24), Vector3.new(CX + 12, KH/2, CZ), Color3.fromRGB(50, 45, 55), Enum.Material.Cobblestone, castleFolder)
makePart("KeepWallW", Vector3.new(3, KH, 24), Vector3.new(CX - 12, KH/2, CZ), Color3.fromRGB(50, 45, 55), Enum.Material.Cobblestone, castleFolder)
-- Keep floor
makePart("KeepFloor", Vector3.new(21, 0.6, 21), Vector3.new(CX, 0.3, CZ), Color3.fromRGB(40, 35, 45), Enum.Material.Marble, castleFolder)
-- Keep roof / upper floor
makePart("KeepUpperFloor", Vector3.new(21, 1, 21), Vector3.new(CX, KH - 5, CZ), Color3.fromRGB(50, 45, 55), Enum.Material.Slate, castleFolder)
-- Keep roof
makeWedge("KeepRoofN", Vector3.new(24, 10, 14), Vector3.new(CX, KH + 5, CZ - 5), "Dark red", Enum.Material.Slate, castleFolder)
makeWedge("KeepRoofS", Vector3.new(24, 10, 14), Vector3.new(CX, KH + 5, CZ + 5), "Dark red", Enum.Material.Slate, castleFolder, {Orientation = Vector3.new(0, 180, 0)})

-- === THRONE (capture point) ===
-- Throne platform
makePart("ThronePlatform", Vector3.new(8, 1, 6), Vector3.new(CX, 1, CZ - 6), Color3.fromRGB(80, 20, 20), Enum.Material.Marble, castleFolder)
-- Throne back
makePart("ThroneBack", Vector3.new(4, 8, 1), Vector3.new(CX, 5, CZ - 8.5), Color3.fromRGB(60, 15, 15), Enum.Material.Metal, castleFolder)
-- Throne seat
makePart("ThroneSeat", Vector3.new(4, 1, 3), Vector3.new(CX, 2, CZ - 7), Color3.fromRGB(80, 20, 20), Enum.Material.Marble, castleFolder)
-- Throne armrests
makePart("ThroneArmL", Vector3.new(0.5, 3, 3), Vector3.new(CX - 2.2, 3, CZ - 7), Color3.fromRGB(60, 15, 15), Enum.Material.Metal, castleFolder)
makePart("ThroneArmR", Vector3.new(0.5, 3, 3), Vector3.new(CX + 2.2, 3, CZ - 7), Color3.fromRGB(60, 15, 15), Enum.Material.Metal, castleFolder)
-- Skull ornaments on throne
makePart("ThroneSkull1", Vector3.new(1, 1, 1), Vector3.new(CX - 1, 8.5, CZ - 8.5), "White", Enum.Material.SmoothPlastic, castleFolder)
makePart("ThroneSkull2", Vector3.new(1, 1, 1), Vector3.new(CX + 1, 8.5, CZ - 8.5), "White", Enum.Material.SmoothPlastic, castleFolder)
-- Crown above throne (glowing)
makePart("ThroneCrown", Vector3.new(2, 1, 2), Vector3.new(CX, 9.5, CZ - 8.5), Color3.fromRGB(255, 200, 50), Enum.Material.Neon, castleFolder, {Transparency = 0.2})

-- Capture point indicator (glowing floor ring)
makePart("CaptureRing", Vector3.new(10, 0.1, 8), Vector3.new(CX, 1.6, CZ - 6), Color3.fromRGB(200, 150, 0), Enum.Material.Neon, castleFolder, {Transparency = 0.5})

-- === STAIRCASES (access to wall walkways) ===
-- SW staircase (from courtyard to south wall)
for step = 0, 9 do
	local sy = step * 2 + 0.5
	local sz = CZ + 30 - step * 1.5
	makePart("StairSW" .. step, Vector3.new(4, 1, 2), Vector3.new(CX - 30, sy, sz), "Medium stone grey", Enum.Material.Slate, castleFolder)
end
-- NE staircase
for step = 0, 9 do
	local sy = step * 2 + 0.5
	local sz = CZ - 30 + step * 1.5
	makePart("StairNE" .. step, Vector3.new(4, 1, 2), Vector3.new(CX + 30, sy, sz), "Medium stone grey", Enum.Material.Slate, castleFolder)
end

-- === BANNERS & DECORATIONS ===
-- Dark purple/red banners on walls
local bannerPositions = {
	{CX - 15, 12, CZ - WS2 + 2.5}, {CX, 12, CZ - WS2 + 2.5}, {CX + 15, 12, CZ - WS2 + 2.5},
	{CX - 15, 12, CZ + WS2 - 2.5}, {CX + 15, 12, CZ + WS2 - 2.5},
}
for bi, bp in ipairs(bannerPositions) do
	makePart("Banner" .. bi, Vector3.new(0.1, 6, 3), Vector3.new(bp[1], bp[2], bp[3]), Color3.fromRGB(60, 10, 40), Enum.Material.Fabric, castleFolder)
	makePart("BannerPole" .. bi, Vector3.new(0.2, 0.2, 3.5), Vector3.new(bp[1], bp[2] + 3.2, bp[3]), Color3.fromRGB(80, 70, 60), Enum.Material.Metal, castleFolder)
end

-- Courtyard torches (8 around the courtyard)
for ti = 1, 8 do
	local angle = (ti / 8) * math.pi * 2
	local ttx = CX + math.cos(angle) * 25
	local ttz = CZ + math.sin(angle) * 25
	makePart("CTorch" .. ti, Vector3.new(0.5, 3, 0.5), Vector3.new(ttx, 2.5, ttz), "Brown", Enum.Material.Wood, castleFolder)
	makePart("CFlame" .. ti, Vector3.new(0.8, 1.2, 0.8), Vector3.new(ttx, 4.5, ttz), Color3.fromRGB(255, 100, 0), Enum.Material.Neon, castleFolder, {CanCollide = false, Transparency = 0.2})
end

-- Weapon racks in courtyard
makePart("CWRack1", Vector3.new(4, 5, 0.5), Vector3.new(CX - 18, 2.5, CZ + 15), "Brown", Enum.Material.Wood, castleFolder)
makePart("CWSword1", Vector3.new(0.2, 4, 0.1), Vector3.new(CX - 18, 3, CZ + 14.5), Color3.fromRGB(180, 180, 190), Enum.Material.Metal, castleFolder)
makePart("CWRack2", Vector3.new(4, 5, 0.5), Vector3.new(CX + 18, 2.5, CZ + 15), "Brown", Enum.Material.Wood, castleFolder)
makePart("CWSword2", Vector3.new(0.2, 4, 0.1), Vector3.new(CX + 18, 3, CZ + 14.5), Color3.fromRGB(180, 180, 190), Enum.Material.Metal, castleFolder)

-- Training dummies in courtyard
makePart("CDummy1Post", Vector3.new(0.5, 4, 0.5), Vector3.new(CX - 12, 2, CZ + 20), "Brown", Enum.Material.Wood, castleFolder)
makePart("CDummy1Body", Vector3.new(2, 2, 1), Vector3.new(CX - 12, 4, CZ + 20), "Bright orange", Enum.Material.Fabric, castleFolder)
makePart("CDummy1Arm", Vector3.new(3, 0.5, 0.5), Vector3.new(CX - 12, 4.5, CZ + 20), "Brown", Enum.Material.Wood, castleFolder)

-- Castle floor (dark wilderness ground around it)
makePart("CastleGround", Vector3.new(120, 0.15, 120), Vector3.new(CX, 0.05, CZ), Color3.fromRGB(30, 25, 22), Enum.Material.Ground, castleFolder)

-- Castle sign
local castleSign = makePart("CastleSign", Vector3.new(1, 1, 1), Vector3.new(CX, 24, CZ + WS2 + 2), "White", nil, castleFolder, {Transparency = 1})
makeSign(castleSign, "THE DARK FORTRESS", Vector3.new(0, 0, 0), UDim2.new(14, 0, 3, 0))

-- Warning sign outside
local castleWarn = makePart("CastleWarn", Vector3.new(1, 1, 1), Vector3.new(CX, 4, CZ + 55), "White", nil, castleFolder, {Transparency = 1})
makeSign(castleWarn, "PVP ZONE - ENTER AT YOUR OWN RISK", Vector3.new(0, 0, 0), UDim2.new(16, 0, 2, 0))

print("[MapSetup] Dark Fortress built at (0, 0, -350)")

-- ============================================================
print("[MapSetup] World generation complete!")
print("[MapSetup] Haven + 6 wilderness zones + terrain features + Crimson Arena + Dark Fortress")
