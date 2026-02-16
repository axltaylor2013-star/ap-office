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
	p.BrickColor = BrickColor.new(color)
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
	local flame = makePart("TorchFlame", Vector3.new(1, 1.5, 1), position + Vector3.new(0, 3.5, 0), "Bright orange", Enum.Material.Neon, parent, {Transparency = 0.2})
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 150, 50)
	light.Brightness = 2
	light.Range = 20
	light.Parent = flame
	return pole
end

local function makeLantern(position, parent)
	local post = makePart("LanternPost", Vector3.new(0.4, 5, 0.4), position, "Dark stone grey", Enum.Material.Metal, parent)
	local lamp = makePart("Lantern", Vector3.new(1.2, 1.5, 1.2), position + Vector3.new(0, 3.2, 0), "Bright yellow", Enum.Material.Neon, parent, {Transparency = 0.3})
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 220, 120)
	light.Brightness = 1.5
	light.Range = 25
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
	local b = makePart("WildernessBorder", Vector3.new(800, 30, 2), Vector3.new(0, 15, -100), "Really red", Enum.Material.Neon, WS, {Transparency = 0.7, CanCollide = false})
	makeSign(b, "⚠️ WILDERNESS — FULL LOOT PVP ⚠️\nCross at your own risk!", Vector3.new(0, 8, 0))
end

-- ============================================================
-- === THE CITY OF HAVEN ===
-- ============================================================

local cityFolder = getOrMake(safeZone, "City")

-- ---- CITY WALLS (big stone perimeter) ----
-- Back wall (north side, near wilderness)
makePart("WallBack", Vector3.new(120, 14, 4), Vector3.new(0, 7, -10), "Medium stone grey", Enum.Material.Cobblestone, cityFolder)
-- Left wall (west)
makePart("WallLeft", Vector3.new(4, 14, 120), Vector3.new(-62, 7, 50), "Medium stone grey", Enum.Material.Cobblestone, cityFolder)
-- Right wall (east)
makePart("WallRight", Vector3.new(4, 14, 120), Vector3.new(62, 7, 50), "Medium stone grey", Enum.Material.Cobblestone, cityFolder)
-- Front wall LEFT of gate
makePart("WallFrontL", Vector3.new(48, 14, 4), Vector3.new(-36, 7, 108), "Medium stone grey", Enum.Material.Cobblestone, cityFolder)
-- Front wall RIGHT of gate
makePart("WallFrontR", Vector3.new(48, 14, 4), Vector3.new(36, 7, 108), "Medium stone grey", Enum.Material.Cobblestone, cityFolder)

-- Wall towers (corners)
makePart("TowerNW", Vector3.new(8, 18, 8), Vector3.new(-62, 9, -10), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("TowerNE", Vector3.new(8, 18, 8), Vector3.new(62, 9, -10), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("TowerSW", Vector3.new(8, 18, 8), Vector3.new(-62, 9, 108), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("TowerSE", Vector3.new(8, 18, 8), Vector3.new(62, 9, 108), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
-- Tower tops (crenellation feel)
makePart("TowerTopNW", Vector3.new(10, 2, 10), Vector3.new(-62, 19, -10), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("TowerTopNE", Vector3.new(10, 2, 10), Vector3.new(62, 19, -10), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("TowerTopSW", Vector3.new(10, 2, 10), Vector3.new(-62, 19, 108), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("TowerTopSE", Vector3.new(10, 2, 10), Vector3.new(62, 19, 108), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)

-- ---- MAIN GATE ----
makePart("GateLeft", Vector3.new(6, 18, 6), Vector3.new(-10, 9, 108), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("GateRight", Vector3.new(6, 18, 6), Vector3.new(10, 9, 108), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
makePart("GateArch", Vector3.new(26, 4, 6), Vector3.new(0, 18, 108), "Dark stone grey", Enum.Material.Cobblestone, cityFolder)
-- Gate portcullis (decorative iron bars)
makePart("Portcullis", Vector3.new(14, 14, 0.5), Vector3.new(0, 10, 108), "Black", Enum.Material.DiamondPlate, cityFolder, {Transparency = 0.5})
-- Gate sign
local gateSign = makePart("GateSignPost", Vector3.new(1, 1, 1), Vector3.new(0, 22, 108), "Dark stone grey", Enum.Material.Cobblestone, cityFolder, {Transparency = 1})
makeSign(gateSign, "🏰 HAVEN", Vector3.new(0, 0, 0), UDim2.new(10, 0, 3, 0))
-- Gate torches
makeTorch(Vector3.new(-7, 3, 112), cityFolder)
makeTorch(Vector3.new(7, 3, 112), cityFolder)

-- ---- CITY GROUND ----
makePart("CityFloor", Vector3.new(120, 0.2, 116), Vector3.new(0, 0.1, 49), "Medium stone grey", Enum.Material.Cobblestone, cityFolder)

-- ---- MAIN ROAD (gate to town square and beyond) ----
makePart("MainRoad", Vector3.new(8, 0.15, 60), Vector3.new(0, 0.12, 78), "Institutional white", Enum.Material.Cobblestone, cityFolder)
-- East-west crossroad
makePart("CrossRoad", Vector3.new(100, 0.15, 6), Vector3.new(0, 0.12, 50), "Institutional white", Enum.Material.Cobblestone, cityFolder)

-- ============================================================
-- === TOWN SQUARE (center) ===
-- ============================================================

-- Big fountain
makePart("FountainBase", Vector3.new(14, 3, 14), Vector3.new(0, 1.5, 50), "Medium stone grey", Enum.Material.Marble, cityFolder)
makePart("FountainInner", Vector3.new(10, 0.5, 10), Vector3.new(0, 3.25, 50), "Medium stone grey", Enum.Material.Marble, cityFolder)
makePart("FountainWater", Vector3.new(9, 0.4, 9), Vector3.new(0, 3, 50), "Cyan", Enum.Material.Neon, cityFolder, {Transparency = 0.4})
makePart("FountainPillar", Vector3.new(2, 8, 2), Vector3.new(0, 7, 50), "Medium stone grey", Enum.Material.Marble, cityFolder)
makePart("FountainTop", Vector3.new(6, 1, 6), Vector3.new(0, 11.5, 50), "Medium stone grey", Enum.Material.Marble, cityFolder)
makePart("FountainTopWater", Vector3.new(4, 0.3, 4), Vector3.new(0, 11.8, 50), "Cyan", Enum.Material.Neon, cityFolder, {Transparency = 0.3})

local squareSign = makePart("SquareSign", Vector3.new(1, 1, 1), Vector3.new(0, 13, 50), "White", nil, cityFolder, {Transparency = 1})
makeSign(squareSign, "⛲ Town Square", Vector3.new(0, 0, 0))

-- Benches around fountain
makePart("Bench1", Vector3.new(5, 1.5, 1.5), Vector3.new(-10, 0.75, 50), "Reddish brown", Enum.Material.Wood, cityFolder)
makePart("Bench2", Vector3.new(5, 1.5, 1.5), Vector3.new(10, 0.75, 50), "Reddish brown", Enum.Material.Wood, cityFolder)
makePart("Bench3", Vector3.new(1.5, 1.5, 5), Vector3.new(0, 0.75, 40), "Reddish brown", Enum.Material.Wood, cityFolder)
makePart("Bench4", Vector3.new(1.5, 1.5, 5), Vector3.new(0, 0.75, 60), "Reddish brown", Enum.Material.Wood, cityFolder)

-- Town square lanterns
makeLantern(Vector3.new(-10, 0, 44), cityFolder)
makeLantern(Vector3.new(10, 0, 44), cityFolder)
makeLantern(Vector3.new(-10, 0, 56), cityFolder)
makeLantern(Vector3.new(10, 0, 56), cityFolder)

-- ============================================================
-- === BANK OF HAVEN (east side) ===
-- ============================================================
local bankBuilding = getOrMake(cityFolder, "BankBuilding")
-- Foundation
makePart("BankFoundation", Vector3.new(22, 1, 18), Vector3.new(35, 0.5, 50), "Dark stone grey", Enum.Material.Cobblestone, bankBuilding)
-- Floor
makePart("BankFloor", Vector3.new(20, 0.3, 16), Vector3.new(35, 1.15, 50), "Reddish brown", Enum.Material.WoodPlanks, bankBuilding)
-- Walls
makePart("BankWallBack", Vector3.new(20, 12, 1), Vector3.new(35, 7, 42), "Brick yellow", Enum.Material.Brick, bankBuilding)
makePart("BankWallLeft", Vector3.new(1, 12, 16), Vector3.new(25, 7, 50), "Brick yellow", Enum.Material.Brick, bankBuilding)
makePart("BankWallRight", Vector3.new(1, 12, 16), Vector3.new(45, 7, 50), "Brick yellow", Enum.Material.Brick, bankBuilding)
-- Front wall with gap for door
makePart("BankFrontL", Vector3.new(7, 12, 1), Vector3.new(28.5, 7, 58), "Brick yellow", Enum.Material.Brick, bankBuilding)
makePart("BankFrontR", Vector3.new(7, 12, 1), Vector3.new(41.5, 7, 58), "Brick yellow", Enum.Material.Brick, bankBuilding)
makePart("BankFrontTop", Vector3.new(6, 4, 1), Vector3.new(35, 11, 58), "Brick yellow", Enum.Material.Brick, bankBuilding)
-- Roof
makePart("BankRoof", Vector3.new(24, 1.5, 20), Vector3.new(35, 13.75, 50), "Dark stone grey", Enum.Material.Slate, bankBuilding)
-- Peaked roof
makeWedge("BankRoofPeakL", Vector3.new(20, 6, 12), Vector3.new(35, 17.5, 44), "Dark stone grey", Enum.Material.Slate, bankBuilding, {Orientation = Vector3.new(0, 0, 0)})
-- Gold trim along roofline
makePart("BankGoldTrim", Vector3.new(24, 0.5, 0.5), Vector3.new(35, 14.75, 60), "Bright yellow", Enum.Material.Metal, bankBuilding)
-- Bank counter inside
makePart("BankCounter", Vector3.new(12, 3, 2), Vector3.new(35, 2.5, 48), "Reddish brown", Enum.Material.WoodPlanks, bankBuilding)
-- Gold bars on counter
makePart("GoldBar1", Vector3.new(1, 0.5, 0.5), Vector3.new(33, 4.25, 48), "Bright yellow", Enum.Material.Metal, bankBuilding)
makePart("GoldBar2", Vector3.new(1, 0.5, 0.5), Vector3.new(35, 4.25, 48), "Bright yellow", Enum.Material.Metal, bankBuilding)
makePart("GoldBar3", Vector3.new(1, 0.5, 0.5), Vector3.new(37, 4.25, 48), "Bright yellow", Enum.Material.Metal, bankBuilding)
-- Bank sign
local bankSign = makePart("BankSign", Vector3.new(1, 1, 1), Vector3.new(35, 16, 58), "White", nil, bankBuilding, {Transparency = 1})
makeSign(bankSign, "🏦 BANK OF HAVEN", Vector3.new(0, 0, 0), UDim2.new(10, 0, 2, 0))
-- Bank torches
makeTorch(Vector3.new(26, 3, 58), bankBuilding)
makeTorch(Vector3.new(44, 3, 58), bankBuilding)

-- ============================================================
-- === GENERAL STORE (west side) ===
-- ============================================================
local shopBuilding = getOrMake(cityFolder, "ShopBuilding")
makePart("ShopFoundation", Vector3.new(18, 1, 14), Vector3.new(-35, 0.5, 50), "Dark stone grey", Enum.Material.Cobblestone, shopBuilding)
makePart("ShopFloor", Vector3.new(16, 0.3, 12), Vector3.new(-35, 1.15, 50), "Reddish brown", Enum.Material.WoodPlanks, shopBuilding)
makePart("ShopWallBack", Vector3.new(16, 10, 1), Vector3.new(-35, 6, 44), "Brick yellow", Enum.Material.Brick, shopBuilding)
makePart("ShopWallLeft", Vector3.new(1, 10, 12), Vector3.new(-43, 6, 50), "Brick yellow", Enum.Material.Brick, shopBuilding)
makePart("ShopWallRight", Vector3.new(1, 10, 12), Vector3.new(-27, 6, 50), "Brick yellow", Enum.Material.Brick, shopBuilding)
makePart("ShopRoof", Vector3.new(20, 1, 16), Vector3.new(-35, 11.5, 50), "Reddish brown", Enum.Material.Wood, shopBuilding)
-- Awning over door
makePart("ShopAwning", Vector3.new(10, 0.3, 4), Vector3.new(-35, 8, 58), "Bright red", Enum.Material.Fabric, shopBuilding)
-- Display shelves outside
makePart("ShopShelf1", Vector3.new(3, 3, 1), Vector3.new(-30, 1.5, 57), "Reddish brown", Enum.Material.Wood, shopBuilding)
makePart("ShopShelf2", Vector3.new(3, 3, 1), Vector3.new(-40, 1.5, 57), "Reddish brown", Enum.Material.Wood, shopBuilding)
-- Barrels
makePart("Barrel1", Vector3.new(2, 3, 2), Vector3.new(-44, 1.5, 55), "Reddish brown", Enum.Material.Wood, shopBuilding)
makePart("Barrel2", Vector3.new(2, 3, 2), Vector3.new(-44, 1.5, 52), "Reddish brown", Enum.Material.Wood, shopBuilding)
makePart("Barrel3", Vector3.new(2, 3, 2), Vector3.new(-44, 4.3, 53.5), "Reddish brown", Enum.Material.Wood, shopBuilding)
local shopSign = makePart("ShopSign", Vector3.new(1, 1, 1), Vector3.new(-35, 13, 56), "White", nil, shopBuilding, {Transparency = 1})
makeSign(shopSign, "🏪 General Store", Vector3.new(0, 0, 0))
makeTorch(Vector3.new(-27, 3, 56), shopBuilding)
makeTorch(Vector3.new(-43, 3, 56), shopBuilding)

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
forgeLight.Brightness = 3
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

-- ============================================================
-- === CHAPEL OF LIGHT (northeast area) ===
-- ============================================================
local church = getOrMake(cityFolder, "Church")
makePart("ChurchFoundation", Vector3.new(16, 1, 22), Vector3.new(35, 0.5, 25), "White", Enum.Material.Marble, church)
makePart("ChurchFloor", Vector3.new(14, 0.3, 20), Vector3.new(35, 1.15, 25), "White", Enum.Material.Marble, church)
-- Walls
makePart("ChurchWallBack", Vector3.new(14, 14, 1), Vector3.new(35, 8, 15), "White", Enum.Material.Brick, church)
makePart("ChurchWallLeft", Vector3.new(1, 14, 20), Vector3.new(28, 8, 25), "White", Enum.Material.Brick, church)
makePart("ChurchWallRight", Vector3.new(1, 14, 20), Vector3.new(42, 8, 25), "White", Enum.Material.Brick, church)
-- Stained glass windows (colored panels)
makePart("StainedGlass1", Vector3.new(0.3, 4, 2), Vector3.new(28, 9, 22), "Bright blue", Enum.Material.Neon, church, {Transparency = 0.4})
makePart("StainedGlass2", Vector3.new(0.3, 4, 2), Vector3.new(42, 9, 22), "Bright violet", Enum.Material.Neon, church, {Transparency = 0.4})
makePart("StainedGlass3", Vector3.new(0.3, 4, 2), Vector3.new(28, 9, 28), "Bright green", Enum.Material.Neon, church, {Transparency = 0.4})
makePart("StainedGlass4", Vector3.new(0.3, 4, 2), Vector3.new(42, 9, 28), "Bright red", Enum.Material.Neon, church, {Transparency = 0.4})
-- Roof
makePart("ChurchRoof", Vector3.new(18, 1.5, 24), Vector3.new(35, 15.75, 25), "Dark stone grey", Enum.Material.Slate, church)
-- Steeple
makePart("Steeple", Vector3.new(6, 12, 6), Vector3.new(35, 22, 18), "Dark stone grey", Enum.Material.Slate, church)
makePart("SteepleTop", Vector3.new(3, 6, 3), Vector3.new(35, 31, 18), "Dark stone grey", Enum.Material.Slate, church)
-- Cross on top
makePart("CrossV", Vector3.new(0.5, 4, 0.5), Vector3.new(35, 36, 18), "Bright yellow", Enum.Material.Metal, church)
makePart("CrossH", Vector3.new(2.5, 0.5, 0.5), Vector3.new(35, 37, 18), "Bright yellow", Enum.Material.Metal, church)
-- Interior altar
makePart("Altar", Vector3.new(4, 3, 2), Vector3.new(35, 2.5, 16), "White", Enum.Material.Marble, church)
makePart("AltarCloth", Vector3.new(4.2, 0.1, 2.2), Vector3.new(35, 4.05, 16), "Bright violet", Enum.Material.Fabric, church)
-- Pews
for i = 1, 4 do
	makePart("Pew" .. i, Vector3.new(8, 2, 1.5), Vector3.new(35, 1, 20 + i * 3), "Reddish brown", Enum.Material.Wood, church)
end
local churchSign = makePart("ChurchSign", Vector3.new(1, 1, 1), Vector3.new(35, 17, 35), "White", nil, church, {Transparency = 1})
makeSign(churchSign, "⛪ Chapel of Light", Vector3.new(0, 0, 0))

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
-- === MARKETPLACE (south-west area) ===
-- ============================================================
local market = getOrMake(cityFolder, "Market")
-- Market stalls
for i = 0, 3 do
	local xOff = -50 + i * 10
	local stallColor = ({"Bright red", "Bright blue", "Bright green", "Bright yellow"})[i + 1]
	-- Posts
	makePart("Stall" .. i .. "PostL", Vector3.new(0.5, 6, 0.5), Vector3.new(xOff - 3, 3, 75), "Reddish brown", Enum.Material.Wood, market)
	makePart("Stall" .. i .. "PostR", Vector3.new(0.5, 6, 0.5), Vector3.new(xOff + 3, 3, 75), "Reddish brown", Enum.Material.Wood, market)
	-- Awning
	makePart("Stall" .. i .. "Awning", Vector3.new(7, 0.2, 5), Vector3.new(xOff, 6.5, 75), stallColor, Enum.Material.Fabric, market)
	-- Counter
	makePart("Stall" .. i .. "Counter", Vector3.new(6, 3, 2), Vector3.new(xOff, 1.5, 76), "Reddish brown", Enum.Material.WoodPlanks, market)
end
local marketSign = makePart("MarketSign", Vector3.new(1, 1, 1), Vector3.new(-35, 8, 75), "White", nil, market, {Transparency = 1})
makeSign(marketSign, "🏪 Marketplace", Vector3.new(0, 0, 0))

-- ============================================================
-- === FISHING POND (south-east, inside walls) ===
-- ============================================================
local pond = getOrMake(safeZone, "FishingPond")
-- Pond water
makePart("PondWater", Vector3.new(30, 0.5, 20), Vector3.new(80, -0.25, 80), "Cyan", Enum.Material.Neon, pond, {Transparency = 0.4})
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
makePart("LilyPond", Vector3.new(14, 0.5, 10), Vector3.new(110, -0.25, 60), "Cyan", Enum.Material.Neon, pond, {Transparency = 0.5})
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
-- === WILDERNESS DECORATIONS ===
-- ============================================================

-- Dead trees scattered
local function makeDeadTree(position)
	makePart("DeadTrunk", Vector3.new(1.5, 7, 1.5), position + Vector3.new(0, 3.5, 0), "Dark stone grey", Enum.Material.Wood, wilderness)
	makePart("DeadBranch1", Vector3.new(0.5, 3, 0.5), position + Vector3.new(1.5, 6, 0), "Dark stone grey", Enum.Material.Wood, wilderness, {Orientation = Vector3.new(0, 0, 30)})
	makePart("DeadBranch2", Vector3.new(0.5, 2.5, 0.5), position + Vector3.new(-1, 5, 0.5), "Dark stone grey", Enum.Material.Wood, wilderness, {Orientation = Vector3.new(0, 0, -25)})
end

local deadTreePos = {
	{20, 0, -120}, {-30, 0, -140}, {50, 0, -160}, {-15, 0, -180},
	{35, 0, -200}, {-45, 0, -220}, {70, 0, -130}, {-60, 0, -170},
	{10, 0, -250}, {-40, 0, -280}, {80, 0, -210}, {-70, 0, -240},
}
for _, dt in ipairs(deadTreePos) do
	makeDeadTree(Vector3.new(dt[1], dt[2], dt[3]))
end

-- Skull warning signs
local function makeWarningSign(position)
	local post = makePart("SignPost", Vector3.new(0.5, 4, 0.5), position + Vector3.new(0, 2, 0), "Reddish brown", Enum.Material.Wood, wilderness)
	local board = makePart("SignBoard", Vector3.new(3, 2, 0.3), position + Vector3.new(0, 4.5, 0), "Brown", Enum.Material.Wood, wilderness)
	makeSign(board, "☠️ DANGER", Vector3.new(0, 1, 0))
end
makeWarningSign(Vector3.new(25, 0, -105))
makeWarningSign(Vector3.new(-25, 0, -105))
makeWarningSign(Vector3.new(0, 0, -105))
makeWarningSign(Vector3.new(60, 0, -105))
makeWarningSign(Vector3.new(-60, 0, -105))

-- Ancient ruins (bigger)
local ruins = getOrMake(wilderness, "AncientRuins")
makePart("RuinWall1", Vector3.new(6, 10, 1.5), Vector3.new(60, 5, -170), "Medium stone grey", Enum.Material.Cobblestone, ruins)
makePart("RuinWall2", Vector3.new(1.5, 8, 10), Vector3.new(66, 4, -175), "Medium stone grey", Enum.Material.Cobblestone, ruins)
makePart("RuinWall3", Vector3.new(6, 5, 1.5), Vector3.new(60, 2.5, -180), "Medium stone grey", Enum.Material.Cobblestone, ruins)
makePart("RuinFloor", Vector3.new(14, 0.3, 14), Vector3.new(61, 0.15, -175), "Medium stone grey", Enum.Material.Cobblestone, ruins)
-- Broken pillars
makePart("Pillar1", Vector3.new(2, 8, 2), Vector3.new(55, 4, -172), "Medium stone grey", Enum.Material.Marble, ruins)
makePart("Pillar2", Vector3.new(2, 5, 2), Vector3.new(67, 2.5, -178), "Medium stone grey", Enum.Material.Marble, ruins)
makePart("PillarBroken", Vector3.new(2, 3, 2), Vector3.new(55, 1.5, -178), "Medium stone grey", Enum.Material.Marble, ruins)
local ruinSign = makePart("RuinSign", Vector3.new(1, 1, 1), Vector3.new(61, 12, -175), "White", nil, ruins, {Transparency = 1})
makeSign(ruinSign, "🏛️ Ancient Ruins", Vector3.new(0, 0, 0))

-- Wilderness graveyard
local graveyard = getOrMake(wilderness, "Graveyard")
for i = 1, 8 do
	local gx = -50 + (i % 4) * 8
	local gz = -145 - math.floor(i / 4) * 8
	makePart("Grave" .. i, Vector3.new(2, 3, 0.5), Vector3.new(gx, 1.5, gz), "Medium stone grey", Enum.Material.Cobblestone, graveyard)
	makePart("GraveMound" .. i, Vector3.new(3, 0.5, 4), Vector3.new(gx, 0.25, gz + 2.5), "Brown", Enum.Material.Ground, graveyard)
end
-- Spooky fence
makePart("GraveFence1", Vector3.new(40, 3, 0.3), Vector3.new(-34, 1.5, -140), "Black", Enum.Material.Metal, graveyard)
makePart("GraveFence2", Vector3.new(0.3, 3, 20), Vector3.new(-54, 1.5, -150), "Black", Enum.Material.Metal, graveyard)
makePart("GraveFence3", Vector3.new(0.3, 3, 20), Vector3.new(-14, 1.5, -150), "Black", Enum.Material.Metal, graveyard)
local graveSign = makePart("GraveSign", Vector3.new(1, 1, 1), Vector3.new(-34, 5, -140), "White", nil, graveyard, {Transparency = 1})
makeSign(graveSign, "💀 Forgotten Graveyard", Vector3.new(0, 0, 0))

-- Lava pit (deep wilderness)
makePart("LavaRim", Vector3.new(20, 1, 20), Vector3.new(0, 0.5, -260), "Dark stone grey", Enum.Material.Slate, wilderness)
makePart("LavaPit", Vector3.new(16, 0.5, 16), Vector3.new(0, 0.1, -260), "Bright red", Enum.Material.Neon, wilderness, {Transparency = 0.2})
local lavaLight = Instance.new("PointLight")
lavaLight.Color = Color3.fromRGB(255, 60, 20)
lavaLight.Brightness = 4
lavaLight.Range = 40
lavaLight.Parent = wilderness:FindFirstChild("LavaPit") or wilderness
-- Lava rocks around pit
makePart("LavaRock1", Vector3.new(4, 3, 3), Vector3.new(12, 1.5, -255), "Black", Enum.Material.Slate, wilderness)
makePart("LavaRock2", Vector3.new(3, 4, 4), Vector3.new(-10, 2, -265), "Black", Enum.Material.Slate, wilderness)
makePart("LavaRock3", Vector3.new(5, 2, 3), Vector3.new(5, 1, -270), "Black", Enum.Material.Slate, wilderness)

-- Wilderness dark pond (for dark crabs)
local darkPond = getOrMake(wilderness, "DarkPond")
makePart("DarkPondWater", Vector3.new(20, 0.5, 14), Vector3.new(-60, -0.25, -210), "Really black", Enum.Material.Neon, darkPond, {Transparency = 0.3})
makePart("DarkPondBank", Vector3.new(24, 0.8, 18), Vector3.new(-60, -0.1, -210), "Dark stone grey", Enum.Material.Ground, darkPond)
-- Glowing mushrooms around dark pond
for i = 1, 5 do
	local mx = -68 + math.random(0, 16)
	local mz = -218 + math.random(0, 16)
	local shroom = makePart("Mushroom" .. i, Vector3.new(1, 1.5, 1), Vector3.new(mx, 0.75, mz), "Bright violet", Enum.Material.Neon, darkPond, {Transparency = 0.3})
	local shroomLight = Instance.new("PointLight")
	shroomLight.Color = Color3.fromRGB(180, 50, 255)
	shroomLight.Brightness = 1
	shroomLight.Range = 8
	shroomLight.Parent = shroom
end
local darkPondSign = makePart("DPSign", Vector3.new(1, 1, 1), Vector3.new(-60, 3, -200), "White", nil, darkPond, {Transparency = 1})
makeSign(darkPondSign, "🌑 Dark Waters", Vector3.new(0, 0, 0))

-- Scattered boulders in wilderness
for i = 1, 10 do
	local bx = math.random(-150, 150)
	local bz = math.random(-300, -110)
	local bs = 3 + math.random() * 4
	makePart("Boulder" .. i, Vector3.new(bs, bs * 0.7, bs), Vector3.new(bx, bs * 0.35, bz), "Dark stone grey", Enum.Material.Slate, wilderness)
end

-- ============================================================
-- === LIGHTING ===
-- ============================================================
local Lighting = game:GetService("Lighting")
Lighting.Ambient = Color3.fromRGB(80, 80, 100)
Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 120)
Lighting.Brightness = 2
Lighting.ClockTime = 10
Lighting.FogEnd = 1200
Lighting.FogColor = Color3.fromRGB(180, 200, 220)

-- ============================================================
print("[MapSetup] World generation complete!")
print("[MapSetup] City: Haven — walls, gate, bank, shop, smithy, chapel, tavern, guard tower, marketplace")
print("[MapSetup] Outside: Haven Pond, Haven Mine, Haven Forest")
print("[MapSetup] Wilderness: dead trees, graveyard, ruins, dark pond, lava pit, boulders")
