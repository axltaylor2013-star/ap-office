-- MapSetup2.server.lua
-- WORLD EXPANSION: Areas outside Haven, safe zone content, and deep wilderness
-- Runs AFTER MapSetup.server.lua

task.wait(1) -- let MapSetup finish first
print("[MapSetup2] Starting world expansion...")

local WS = game:GetService("Workspace")

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
	if props then for k, v in pairs(props) do p[k] = v end end
	return p
end

local function makeSign(parent, text, offset, size)
	local bg = Instance.new("BillboardGui")
	bg.Size = size or UDim2.new(10, 0, 2.5, 0)
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
end

local function makeLantern(position, parent)
	makePart("LPost", Vector3.new(0.4, 5, 0.4), position, "Dark stone grey", Enum.Material.Metal, parent)
	local lamp = makePart("Lamp", Vector3.new(1.2, 1.5, 1.2), position + Vector3.new(0, 3.2, 0), "Bright yellow", Enum.Material.Neon, parent, {Transparency = 0.3})
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 220, 120)
	light.Brightness = 1.5
	light.Range = 25
	light.Parent = lamp
end

local function makeTree(position, parent, scale, leafColor)
	scale = scale or 1
	leafColor = leafColor or "Forest green"
	makePart("Trunk", Vector3.new(2*scale, 10*scale, 2*scale), position + Vector3.new(0, 5*scale, 0), "Reddish brown", Enum.Material.Wood, parent)
	makePart("Leaves", Vector3.new(10*scale, 10*scale, 10*scale), position + Vector3.new(0, 11*scale, 0), leafColor, Enum.Material.Grass, parent)
end

local function makeHouse(position, parent, width, depth, height, wallColor, roofColor, name)
	local f = Instance.new("Folder") f.Name = name or "House" f.Parent = parent
	makePart("Floor", Vector3.new(width, 0.3, depth), position + Vector3.new(0, 0.15, 0), "Reddish brown", Enum.Material.WoodPlanks, f)
	makePart("WallBack", Vector3.new(width, height, 1), position + Vector3.new(0, height/2, -depth/2), wallColor, Enum.Material.Brick, f)
	makePart("WallLeft", Vector3.new(1, height, depth), position + Vector3.new(-width/2, height/2, 0), wallColor, Enum.Material.Brick, f)
	makePart("WallRight", Vector3.new(1, height, depth), position + Vector3.new(width/2, height/2, 0), wallColor, Enum.Material.Brick, f)
	makePart("Roof", Vector3.new(width+2, 1, depth+2), position + Vector3.new(0, height+0.5, 0), roofColor, Enum.Material.Slate, f)
	return f
end

local function getOrMake(parent, name)
	local f = parent:FindFirstChild(name)
	if not f then f = Instance.new("Folder") f.Name = name f.Parent = parent end
	return f
end

local safeZone = getOrMake(WS, "SafeZone")
local wilderness = getOrMake(WS, "Wilderness")

-- ============================================================
-- 1. FARMLANDS (east, x=100-250, z=120-220)
-- ============================================================
print("[MapSetup2] Building Farmlands...")
local farm = getOrMake(safeZone, "Farmlands")

-- Dirt ground
makePart("FarmGround", Vector3.new(160, 0.15, 110), Vector3.new(175, 0.08, 170), "Brown", Enum.Material.Ground, farm)

-- Wheat fields (rows of yellow)
for row = 0, 5 do
	for col = 0, 8 do
		makePart("Wheat", Vector3.new(3, 2, 12), Vector3.new(110 + col * 7, 1, 130 + row * 14), "Bright yellow", Enum.Material.Grass, farm, {CanCollide = false})
	end
end

-- Farmhouse 1
local fh1 = makeHouse(Vector3.new(200, 0, 140), farm, 14, 10, 8, "Brick yellow", "Reddish brown", "Farmhouse1")
local fh1Sign = makePart("Sign", Vector3.new(1,1,1), Vector3.new(200, 10, 145), "White", nil, farm, {Transparency = 1})
makeSign(fh1Sign, "🏡 Old MacDonald's Farm", Vector3.new(0,0,0))

-- Farmhouse 2
makeHouse(Vector3.new(230, 0, 180), farm, 12, 8, 7, "Brown", "Dark stone grey", "Farmhouse2")

-- Fences around pasture
for i = 0, 15 do
	makePart("FencePost", Vector3.new(0.5, 3, 0.5), Vector3.new(155 + i * 6, 1.5, 155), "Reddish brown", Enum.Material.Wood, farm)
	makePart("FenceRail", Vector3.new(6, 0.3, 0.3), Vector3.new(158 + i * 6, 2.2, 155), "Reddish brown", Enum.Material.Wood, farm)
	makePart("FenceRail2", Vector3.new(6, 0.3, 0.3), Vector3.new(158 + i * 6, 1.2, 155), "Reddish brown", Enum.Material.Wood, farm)
end
for i = 0, 8 do
	makePart("FencePost", Vector3.new(0.5, 3, 0.5), Vector3.new(155, 1.5, 155 + i * 6), "Reddish brown", Enum.Material.Wood, farm)
	makePart("FencePost", Vector3.new(0.5, 3, 0.5), Vector3.new(245, 1.5, 155 + i * 6), "Reddish brown", Enum.Material.Wood, farm)
end

-- Scarecrow
makePart("ScarecrowPole", Vector3.new(0.5, 6, 0.5), Vector3.new(140, 3, 145), "Reddish brown", Enum.Material.Wood, farm)
makePart("ScarecrowArms", Vector3.new(4, 0.5, 0.5), Vector3.new(140, 5, 145), "Reddish brown", Enum.Material.Wood, farm)
makePart("ScarecrowHead", Vector3.new(1.5, 1.5, 1.5), Vector3.new(140, 6.5, 145), "Bright orange", Enum.Material.SmoothPlastic, farm)

-- Hay bales
for i = 1, 6 do
	makePart("HayBale"..i, Vector3.new(3, 2, 3), Vector3.new(210 + math.random(-5,5), 1, 165 + math.random(-5,5)), "Bright yellow", Enum.Material.Grass, farm)
end

-- Windmill
makePart("WindmillBase", Vector3.new(8, 20, 8), Vector3.new(240, 10, 145), "Brick yellow", Enum.Material.Brick, farm)
makePart("WindmillRoof", Vector3.new(10, 2, 10), Vector3.new(240, 21, 145), "Reddish brown", Enum.Material.Wood, farm)
-- Sails (simplified as crossed planks)
makePart("Sail1", Vector3.new(1, 18, 1), Vector3.new(240, 18, 141), "White", Enum.Material.Fabric, farm, {CanCollide = false})
makePart("Sail2", Vector3.new(18, 1, 1), Vector3.new(240, 18, 141), "White", Enum.Material.Fabric, farm, {CanCollide = false})

-- Chicken coop
makePart("CoopBase", Vector3.new(6, 3, 5), Vector3.new(170, 1.5, 170), "Reddish brown", Enum.Material.Wood, farm)
makePart("CoopRoof", Vector3.new(7, 0.5, 6), Vector3.new(170, 3.5, 170), "Reddish brown", Enum.Material.Wood, farm)
makePart("CoopFence", Vector3.new(12, 2, 0.3), Vector3.new(170, 1, 175), "Reddish brown", Enum.Material.Wood, farm)

task.wait()

-- ============================================================
-- 2. HAVEN LAKE (west, x=-200 to -100, z=100-200)
-- ============================================================
print("[MapSetup2] Building Haven Lake...")
local lake = getOrMake(safeZone, "HavenLake")

-- Lake water
makePart("LakeWater", Vector3.new(80, 1, 60), Vector3.new(-150, -0.5, 150), Color3.fromRGB(65, 130, 175), Enum.Material.Water, lake, {Transparency = 0.3, CanCollide = false})
-- Sandy beach (south side)
makePart("Beach", Vector3.new(90, 0.3, 15), Vector3.new(-150, 0.15, 185), "Brick yellow", Enum.Material.Sand, lake)
-- Dirt banks
makePart("BankNorth", Vector3.new(90, 0.8, 5), Vector3.new(-150, 0.1, 118), "Brown", Enum.Material.Ground, lake)
makePart("BankWest", Vector3.new(5, 0.8, 70), Vector3.new(-195, 0.1, 150), "Brown", Enum.Material.Ground, lake)
makePart("BankEast", Vector3.new(5, 0.8, 70), Vector3.new(-105, 0.1, 150), "Brown", Enum.Material.Ground, lake)

-- Fishing dock
makePart("Dock", Vector3.new(5, 0.6, 20), Vector3.new(-130, 0.5, 170), "Reddish brown", Enum.Material.WoodPlanks, lake)
makePart("DockPost1", Vector3.new(0.5, 3, 0.5), Vector3.new(-128, 0.5, 180), "Reddish brown", Enum.Material.Wood, lake)
makePart("DockPost2", Vector3.new(0.5, 3, 0.5), Vector3.new(-132, 0.5, 180), "Reddish brown", Enum.Material.Wood, lake)

-- Rowboat
makePart("BoatHull", Vector3.new(3, 1, 6), Vector3.new(-140, 0.2, 165), "Reddish brown", Enum.Material.Wood, lake)
makePart("BoatSeat", Vector3.new(2, 0.3, 1), Vector3.new(-140, 1, 165), "Reddish brown", Enum.Material.Wood, lake)

-- Small island in lake
makePart("Island", Vector3.new(12, 1, 10), Vector3.new(-155, 0.2, 148), "Bright green", Enum.Material.Grass, lake)
makeTree(Vector3.new(-155, 0.7, 148), lake, 0.8, "Forest green")

-- Lighthouse
makePart("LighthouseBase", Vector3.new(6, 25, 6), Vector3.new(-192, 12.5, 135), "White", Enum.Material.Brick, lake)
makePart("LighthouseTop", Vector3.new(8, 3, 8), Vector3.new(-192, 26.5, 135), "Bright red", Enum.Material.Brick, lake)
local lhLight = makePart("LighthouseLight", Vector3.new(2, 2, 2), Vector3.new(-192, 29, 135), "Bright yellow", Enum.Material.Neon, lake, {Transparency = 0.2})
local pl = Instance.new("PointLight") pl.Color = Color3.fromRGB(255, 255, 200) pl.Brightness = 5 pl.Range = 60 pl.Parent = lhLight

-- Cattails/reeds
for i = 1, 12 do
	local rx = -190 + math.random(0, 80)
	local rz = 120 + math.random(0, 60)
	makePart("Reed"..i, Vector3.new(0.3, 2 + math.random(), 0.3), Vector3.new(rx, 1, rz), "Earth green", Enum.Material.Grass, lake)
end

local lakeSign = makePart("LakeSign", Vector3.new(1,1,1), Vector3.new(-150, 4, 190), "White", nil, lake, {Transparency = 1})
makeSign(lakeSign, "🏞️ Haven Lake", Vector3.new(0,0,0))

task.wait()

-- ============================================================
-- 3. COMBAT TRAINING GROUNDS (east, x=150-250, z=-30 to 70)
-- ============================================================
print("[MapSetup2] Building Training Grounds...")
local training = getOrMake(safeZone, "TrainingGrounds")

-- Arena floor
makePart("ArenaFloor", Vector3.new(80, 0.2, 80), Vector3.new(195, 0.1, 20), "Brown", Enum.Material.Ground, training)
-- Arena walls (stone)
makePart("ArenaWallN", Vector3.new(84, 8, 3), Vector3.new(195, 4, -22), "Medium stone grey", Enum.Material.Cobblestone, training)
makePart("ArenaWallS", Vector3.new(84, 8, 3), Vector3.new(195, 4, 62), "Medium stone grey", Enum.Material.Cobblestone, training)
makePart("ArenaWallW", Vector3.new(3, 8, 80), Vector3.new(152, 4, 20), "Medium stone grey", Enum.Material.Cobblestone, training)
makePart("ArenaWallE", Vector3.new(3, 8, 80), Vector3.new(238, 4, 20), "Medium stone grey", Enum.Material.Cobblestone, training)

-- Training dummies (T-shapes)
for i = 0, 2 do
	local dx = 170 + i * 20
	makePart("DummyPole"..i, Vector3.new(1, 6, 1), Vector3.new(dx, 3, 10), "Reddish brown", Enum.Material.Wood, training)
	makePart("DummyArms"..i, Vector3.new(4, 1, 1), Vector3.new(dx, 5, 10), "Reddish brown", Enum.Material.Wood, training)
	makePart("DummyHead"..i, Vector3.new(1.5, 1.5, 1.5), Vector3.new(dx, 7, 10), "Bright yellow", Enum.Material.SmoothPlastic, training)
end

-- Archery targets
for i = 0, 3 do
	makePart("Target"..i, Vector3.new(0.5, 4, 4), Vector3.new(230, 2.5, 0 + i * 12), "White", Enum.Material.SmoothPlastic, training)
	makePart("TargetRing"..i, Vector3.new(0.6, 2, 2), Vector3.new(230, 2.5, 0 + i * 12), "Bright red", Enum.Material.SmoothPlastic, training)
	makePart("TargetBull"..i, Vector3.new(0.7, 0.8, 0.8), Vector3.new(230, 2.5, 0 + i * 12), "Bright yellow", Enum.Material.SmoothPlastic, training)
end

-- Weapon racks
makePart("WeaponRack1", Vector3.new(0.5, 5, 4), Vector3.new(158, 2.5, 30), "Reddish brown", Enum.Material.Wood, training)
makePart("WeaponRack2", Vector3.new(0.5, 5, 4), Vector3.new(158, 2.5, 40), "Reddish brown", Enum.Material.Wood, training)

-- Spectator benches
for i = 0, 3 do
	makePart("Bench"..i, Vector3.new(8, 1.5, 1.5), Vector3.new(195, 0.75 + i * 1.5, 58 - i * 2), "Reddish brown", Enum.Material.Wood, training)
end

-- Armory building
makeHouse(Vector3.new(170, 0, 50), training, 12, 10, 8, "Dark stone grey", "Dark stone grey", "Armory")
local armSign = makePart("ArmSign", Vector3.new(1,1,1), Vector3.new(170, 10, 55), "White", nil, training, {Transparency = 1})
makeSign(armSign, "⚔️ Combat Training Grounds", Vector3.new(0,0,0))

task.wait()

-- ============================================================
-- 4. ANCIENT GROVE (west, x=-250 to -100, z=-60 to 60)
-- ============================================================
print("[MapSetup2] Building Ancient Grove...")
local grove = getOrMake(safeZone, "AncientGrove")

-- Mystic ground
makePart("GroveGround", Vector3.new(140, 0.15, 120), Vector3.new(-175, 0.08, 0), "Earth green", Enum.Material.Grass, grove)

-- HUGE ancient trees (5 studs wide trunks, 25 tall)
local ancientPos = {
	{-200, 0, -30}, {-160, 0, -40}, {-130, 0, -20}, {-220, 0, 10},
	{-180, 0, 30}, {-140, 0, 40}, {-210, 0, 50}, {-160, 0, 20},
}
for i, tp in ipairs(ancientPos) do
	makePart("AncientTrunk"..i, Vector3.new(5, 25, 5), Vector3.new(tp[1], 12.5, tp[3]), "Reddish brown", Enum.Material.Wood, grove)
	makePart("AncientCanopy"..i, Vector3.new(20, 15, 20), Vector3.new(tp[1], 27, tp[3]), "Dark green", Enum.Material.Grass, grove, {CanCollide = false})
	-- Roots
	makePart("Root"..i.."a", Vector3.new(1, 1, 6), Vector3.new(tp[1]+3, 0.5, tp[3]+2), "Reddish brown", Enum.Material.Wood, grove)
	makePart("Root"..i.."b", Vector3.new(6, 1, 1), Vector3.new(tp[1]-2, 0.5, tp[3]-3), "Reddish brown", Enum.Material.Wood, grove)
end

-- Glowing blue mushrooms
for i = 1, 15 do
	local mx = -240 + math.random(0, 130)
	local mz = -55 + math.random(0, 110)
	local shroom = makePart("BlueMushroom"..i, Vector3.new(0.8, 1.2, 0.8), Vector3.new(mx, 0.6, mz), "Bright blue", Enum.Material.Neon, grove, {Transparency = 0.3, CanCollide = false})
	local sl = Instance.new("PointLight") sl.Color = Color3.fromRGB(50, 120, 255) sl.Brightness = 1 sl.Range = 6 sl.Parent = shroom
end

-- Stone circle (8 standing stones in a ring)
local circleCenter = Vector3.new(-180, 0, 0)
for i = 0, 7 do
	local angle = (i / 8) * math.pi * 2
	local sx = circleCenter.X + math.cos(angle) * 15
	local sz = circleCenter.Z + math.sin(angle) * 15
	local height = 6 + math.random(0, 4)
	makePart("DruidStone"..i, Vector3.new(2, height, 1.5), Vector3.new(sx, height/2, sz), "Medium stone grey", Enum.Material.Slate, grove)
end
-- Center altar
makePart("DruidAltar", Vector3.new(4, 1.5, 4), Vector3.new(-180, 0.75, 0), "Medium stone grey", Enum.Material.Marble, grove)
local altarGlow = makePart("AltarGlow", Vector3.new(2, 0.5, 2), Vector3.new(-180, 1.75, 0), "Bright green", Enum.Material.Neon, grove, {Transparency = 0.4})
local agl = Instance.new("PointLight") agl.Color = Color3.fromRGB(50, 255, 100) agl.Brightness = 2 agl.Range = 15 agl.Parent = altarGlow

-- Moss-covered ruins
makePart("MossRuin1", Vector3.new(5, 4, 1.5), Vector3.new(-220, 2, -40), "Earth green", Enum.Material.Cobblestone, grove)
makePart("MossRuin2", Vector3.new(1.5, 3, 5), Vector3.new(-217, 1.5, -37), "Earth green", Enum.Material.Cobblestone, grove)

-- Waterfall cave entrance
makePart("CaveRockL", Vector3.new(5, 12, 5), Vector3.new(-245, 6, 20), "Dark stone grey", Enum.Material.Slate, grove)
makePart("CaveRockR", Vector3.new(5, 12, 5), Vector3.new(-235, 6, 20), "Dark stone grey", Enum.Material.Slate, grove)
makePart("CaveArch", Vector3.new(15, 4, 5), Vector3.new(-240, 14, 20), "Dark stone grey", Enum.Material.Slate, grove)
makePart("Waterfall", Vector3.new(6, 12, 0.5), Vector3.new(-240, 6, 20), Color3.fromRGB(65, 130, 175), Enum.Material.Water, grove, {Transparency = 0.3, CanCollide = false})

local groveSign = makePart("GroveSign", Vector3.new(1,1,1), Vector3.new(-175, 5, 60), "White", nil, grove, {Transparency = 1})
makeSign(groveSign, "🌿 Ancient Grove", Vector3.new(0,0,0))

task.wait()

-- ============================================================
-- 5. OUTSKIRTS VILLAGE (south, x=-60 to 60, z=150-230)
-- ============================================================
print("[MapSetup2] Building Outskirts Village...")
local village = getOrMake(safeZone, "OutskirtsVillage")

-- Village ground
makePart("VillageGround", Vector3.new(120, 0.15, 80), Vector3.new(0, 0.08, 190), "Brown", Enum.Material.Ground, village)

-- Houses
makeHouse(Vector3.new(-30, 0, 175), village, 10, 8, 7, "Brick yellow", "Reddish brown", "VHouse1")
makeHouse(Vector3.new(-10, 0, 200), village, 10, 8, 7, "Brown", "Dark stone grey", "VHouse2")
makeHouse(Vector3.new(15, 0, 175), village, 12, 8, 7, "Brick yellow", "Reddish brown", "VHouse3")
makeHouse(Vector3.new(35, 0, 200), village, 10, 8, 7, "Brown", "Dark stone grey", "VHouse4")
makeHouse(Vector3.new(-35, 0, 210), village, 10, 8, 7, "Brick yellow", "Reddish brown", "VHouse5")

-- Well in center
makePart("WellBase", Vector3.new(4, 3, 4), Vector3.new(0, 1.5, 190), "Medium stone grey", Enum.Material.Cobblestone, village)
makePart("WellWater", Vector3.new(2, 0.3, 2), Vector3.new(0, 0.5, 190), Color3.fromRGB(65, 130, 175), Enum.Material.Water, village, {Transparency = 0.3})
makePart("WellRoof", Vector3.new(5, 0.5, 5), Vector3.new(0, 5, 190), "Reddish brown", Enum.Material.Wood, village)
makePart("WellPost1", Vector3.new(0.3, 5, 0.3), Vector3.new(-2, 2.5, 188), "Reddish brown", Enum.Material.Wood, village)
makePart("WellPost2", Vector3.new(0.3, 5, 0.3), Vector3.new(2, 2.5, 192), "Reddish brown", Enum.Material.Wood, village)

-- Market cart
makePart("CartBody", Vector3.new(4, 2, 6), Vector3.new(25, 1.5, 190), "Reddish brown", Enum.Material.Wood, village)
makePart("CartGoods", Vector3.new(3, 1, 5), Vector3.new(25, 3, 190), "Bright green", Enum.Material.Fabric, village)

-- Small chapel
local chapel = makeHouse(Vector3.new(45, 0, 185), village, 8, 10, 8, "White", "Dark stone grey", "VChapel")
makePart("ChapelSteeple", Vector3.new(3, 6, 3), Vector3.new(45, 14, 182), "Dark stone grey", Enum.Material.Slate, village)

-- Clotheslines
makePart("ClothPost1", Vector3.new(0.3, 4, 0.3), Vector3.new(-20, 2, 188), "Reddish brown", Enum.Material.Wood, village)
makePart("ClothPost2", Vector3.new(0.3, 4, 0.3), Vector3.new(-5, 2, 188), "Reddish brown", Enum.Material.Wood, village)
makePart("ClothLine", Vector3.new(15, 0.1, 0.1), Vector3.new(-12.5, 3.8, 188), "White", Enum.Material.Fabric, village)
makePart("Cloth1", Vector3.new(2, 2, 0.1), Vector3.new(-15, 2.8, 188), "Bright blue", Enum.Material.Fabric, village, {CanCollide = false})
makePart("Cloth2", Vector3.new(2, 2, 0.1), Vector3.new(-10, 2.8, 188), "Bright red", Enum.Material.Fabric, village, {CanCollide = false})

local villSign = makePart("VillSign", Vector3.new(1,1,1), Vector3.new(0, 7, 230), "White", nil, village, {Transparency = 1})
makeSign(villSign, "🏘️ Outskirts Village", Vector3.new(0,0,0))

task.wait()

-- ============================================================
-- 6. WATCHTOWER HILL (northeast, x=200-240, z=-80 to -50)
-- ============================================================
print("[MapSetup2] Building Watchtower Hill...")
local hill = getOrMake(safeZone, "WatchtowerHill")

-- Raised hill platform
makePart("HillBase", Vector3.new(50, 8, 40), Vector3.new(220, 4, -65), "Earth green", Enum.Material.Grass, hill)
makePart("HillRamp", Vector3.new(12, 1, 20), Vector3.new(200, 4, -55), "Earth green", Enum.Material.Grass, hill, {Orientation = Vector3.new(20, 0, 0)})

-- Watchtower (tall!)
makePart("TowerBase", Vector3.new(8, 30, 8), Vector3.new(220, 23, -65), "Medium stone grey", Enum.Material.Cobblestone, hill)
makePart("TowerTop", Vector3.new(12, 2, 12), Vector3.new(220, 39, -65), "Dark stone grey", Enum.Material.Cobblestone, hill)
-- Railings
makePart("Rail1", Vector3.new(12, 3, 0.5), Vector3.new(220, 41.5, -71), "Dark stone grey", Enum.Material.Cobblestone, hill)
makePart("Rail2", Vector3.new(12, 3, 0.5), Vector3.new(220, 41.5, -59), "Dark stone grey", Enum.Material.Cobblestone, hill)
makePart("Rail3", Vector3.new(0.5, 3, 12), Vector3.new(214, 41.5, -65), "Dark stone grey", Enum.Material.Cobblestone, hill)
makePart("Rail4", Vector3.new(0.5, 3, 12), Vector3.new(226, 41.5, -65), "Dark stone grey", Enum.Material.Cobblestone, hill)

-- Warning flags
makePart("FlagPole1", Vector3.new(0.3, 8, 0.3), Vector3.new(214, 47, -71), "Dark stone grey", Enum.Material.Metal, hill)
makePart("Flag1", Vector3.new(3, 2, 0.1), Vector3.new(216, 49, -71), "Really red", Enum.Material.Fabric, hill, {CanCollide = false})

-- Guard campfire
makePart("FireLogs1", Vector3.new(2, 0.5, 0.5), Vector3.new(210, 8.5, -60), "Reddish brown", Enum.Material.Wood, hill)
makePart("FireLogs2", Vector3.new(0.5, 0.5, 2), Vector3.new(210, 8.5, -60), "Reddish brown", Enum.Material.Wood, hill)
local campfire = makePart("Campfire", Vector3.new(1.5, 2, 1.5), Vector3.new(210, 9.5, -60), "Bright orange", Enum.Material.Neon, hill, {Transparency = 0.3})
local cfl = Instance.new("PointLight") cfl.Color = Color3.fromRGB(255, 140, 40) cfl.Brightness = 3 cfl.Range = 20 cfl.Parent = campfire

local hillSign = makePart("HillSign", Vector3.new(1,1,1), Vector3.new(220, 44, -65), "White", nil, hill, {Transparency = 1})
makeSign(hillSign, "🏰 Watchtower Hill", Vector3.new(0,0,0))

task.wait()

-- ============================================================
-- 7. MERCHANT ROADS (connecting all areas)
-- ============================================================
print("[MapSetup2] Building roads...")
local roads = getOrMake(safeZone, "Roads")

-- Haven gate to south (Outskirts Village)
makePart("RoadSouth", Vector3.new(6, 0.12, 120), Vector3.new(0, 0.06, 168), "Medium stone grey", Enum.Material.Cobblestone, roads)
-- Haven to east (Farmlands/Training)
makePart("RoadEast", Vector3.new(120, 0.12, 6), Vector3.new(120, 0.06, 108), "Medium stone grey", Enum.Material.Cobblestone, roads)
-- Haven to west (Lake/Grove)
makePart("RoadWest", Vector3.new(130, 0.12, 6), Vector3.new(-120, 0.06, 108), "Medium stone grey", Enum.Material.Cobblestone, roads)
-- Road to lake
makePart("RoadToLake", Vector3.new(6, 0.12, 80), Vector3.new(-150, 0.06, 148), "Medium stone grey", Enum.Material.Cobblestone, roads)
-- Road to grove
makePart("RoadToGrove", Vector3.new(6, 0.12, 60), Vector3.new(-120, 0.06, 70), "Medium stone grey", Enum.Material.Cobblestone, roads)
-- Road to training
makePart("RoadToTraining", Vector3.new(6, 0.12, 40), Vector3.new(195, 0.06, 80), "Medium stone grey", Enum.Material.Cobblestone, roads)
-- Road to wilderness (north from Haven)
makePart("RoadNorth", Vector3.new(6, 0.12, 100), Vector3.new(0, 0.06, -55), "Medium stone grey", Enum.Material.Cobblestone, roads)

-- Signposts at intersections
local function makeSignpost(position, texts)
	makePart("Signpost", Vector3.new(0.5, 5, 0.5), position, "Reddish brown", Enum.Material.Wood, roads)
	for i, t in ipairs(texts) do
		local board = makePart("SignBoard"..i, Vector3.new(4, 1, 0.3), position + Vector3.new(2, 4.5 - i * 1.2, 0), "Brown", Enum.Material.Wood, roads)
		makeSign(board, t, Vector3.new(0, 0.5, 0), UDim2.new(6, 0, 1.5, 0))
	end
end

makeSignpost(Vector3.new(5, 0, 115), {"→ Farmlands", "← Haven Lake", "↑ Haven"})
makeSignpost(Vector3.new(0, 0, 155), {"↑ Haven", "↓ Outskirts Village"})
makeSignpost(Vector3.new(0, 0, -50), {"↑ ⚠️ WILDERNESS", "↓ Haven"})

-- Lanterns along roads
for i = 0, 8 do
	makeLantern(Vector3.new(5, 0, 120 + i * 12), roads)
	makeLantern(Vector3.new(-5, 0, -10 - i * 10), roads)
end

task.wait()

-- ============================================================
-- 8. BANDIT CAMP (wilderness, x=-80 to -30, z=-180 to -130)
-- ============================================================
print("[MapSetup2] Building Bandit Camp...")
local bandits = getOrMake(wilderness, "BanditCamp")

-- Palisade walls (crude wooden fence)
makePart("PalisadeN", Vector3.new(55, 6, 1), Vector3.new(-55, 3, -130), "Reddish brown", Enum.Material.Wood, bandits)
makePart("PalisadeS", Vector3.new(55, 6, 1), Vector3.new(-55, 3, -180), "Reddish brown", Enum.Material.Wood, bandits)
makePart("PalisadeW", Vector3.new(1, 6, 50), Vector3.new(-82, 3, -155), "Reddish brown", Enum.Material.Wood, bandits)
makePart("PalisadeE", Vector3.new(1, 6, 50), Vector3.new(-28, 3, -155), "Reddish brown", Enum.Material.Wood, bandits)

-- Tents
for i, pos in ipairs({{-65, 0, -145}, {-50, 0, -160}, {-40, 0, -145}, {-70, 0, -170}}) do
	makePart("TentBase"..i, Vector3.new(6, 0.1, 6), Vector3.new(pos[1], 0.05, pos[3]), "Brown", Enum.Material.Fabric, bandits)
	makePart("TentPole"..i, Vector3.new(0.3, 5, 0.3), Vector3.new(pos[1], 2.5, pos[3]), "Reddish brown", Enum.Material.Wood, bandits)
	makePart("TentCover"..i, Vector3.new(7, 0.2, 7), Vector3.new(pos[1], 4.5, pos[3]), "Brown", Enum.Material.Fabric, bandits, {Orientation = Vector3.new(10, math.random(-20,20), 0)})
end

-- Campfire
makePart("BanditFireLogs", Vector3.new(2, 0.5, 2), Vector3.new(-55, 0.25, -155), "Reddish brown", Enum.Material.Wood, bandits)
local bf = makePart("BanditFire", Vector3.new(1.5, 2, 1.5), Vector3.new(-55, 1.5, -155), "Bright orange", Enum.Material.Neon, bandits, {Transparency = 0.3})
local bfl = Instance.new("PointLight") bfl.Color = Color3.fromRGB(255, 120, 30) bfl.Brightness = 3 bfl.Range = 20 bfl.Parent = bf

-- Weapon crates
makePart("WeaponCrate1", Vector3.new(3, 2, 2), Vector3.new(-45, 1, -150), "Brown", Enum.Material.Wood, bandits)
makePart("WeaponCrate2", Vector3.new(3, 2, 2), Vector3.new(-45, 3, -150), "Brown", Enum.Material.Wood, bandits)

-- Skull flag
makePart("SkullPole", Vector3.new(0.4, 8, 0.4), Vector3.new(-55, 4, -132), "Reddish brown", Enum.Material.Wood, bandits)
makePart("SkullFlag", Vector3.new(4, 3, 0.1), Vector3.new(-53, 7, -132), "Black", Enum.Material.Fabric, bandits)

local banditSign = makePart("BSign", Vector3.new(1,1,1), Vector3.new(-55, 8, -130), "White", nil, bandits, {Transparency = 1})
makeSign(banditSign, "⚔️ Bandit Camp", Vector3.new(0,0,0))

task.wait()

-- ============================================================
-- 9. DARK FOREST (wilderness, x=60 to 200, z=-220 to -120)
-- ============================================================
print("[MapSetup2] Building Dark Forest...")
local darkForest = getOrMake(wilderness, "DarkForest")

-- Dark ground
makePart("DarkForestGround", Vector3.new(140, 0.15, 100), Vector3.new(130, 0.08, -170), "Really black", Enum.Material.Ground, darkForest)

-- Dense dead/twisted trees
for i = 1, 25 do
	local tx = 70 + math.random(0, 120)
	local tz = -210 + math.random(0, 80)
	local th = 6 + math.random(0, 8)
	makePart("DarkTrunk"..i, Vector3.new(1.5, th, 1.5), Vector3.new(tx, th/2, tz), "Really black", Enum.Material.Wood, darkForest)
	if math.random() > 0.4 then
		makePart("DarkBranch"..i, Vector3.new(0.5, 3, 0.5), Vector3.new(tx+1.5, th-1, tz), "Really black", Enum.Material.Wood, darkForest, {Orientation = Vector3.new(0,0,30)})
	end
end

-- Spider webs between trees
for i = 1, 8 do
	local wx = 80 + math.random(0, 100)
	local wz = -200 + math.random(0, 70)
	makePart("Web"..i, Vector3.new(5, 5, 0.1), Vector3.new(wx, 4, wz), "White", Enum.Material.Neon, darkForest, {Transparency = 0.7, CanCollide = false})
end

-- Fog (low transparent grey)
for i = 1, 6 do
	local fx = 80 + math.random(0, 110)
	local fz = -205 + math.random(0, 75)
	makePart("Fog"..i, Vector3.new(25, 3, 25), Vector3.new(fx, 1.5, fz), "Medium stone grey", Enum.Material.SmoothPlastic, darkForest, {Transparency = 0.85, CanCollide = false})
end

-- Abandoned cabin
local cabin = getOrMake(darkForest, "AbandonedCabin")
makePart("CabinFloor", Vector3.new(10, 0.3, 8), Vector3.new(140, 0.15, -180), "Reddish brown", Enum.Material.WoodPlanks, cabin)
makePart("CabinWall1", Vector3.new(10, 6, 1), Vector3.new(140, 3, -184), "Reddish brown", Enum.Material.Wood, cabin)
makePart("CabinWall2", Vector3.new(1, 6, 8), Vector3.new(135, 3, -180), "Reddish brown", Enum.Material.Wood, cabin)
-- Missing wall (broken)
makePart("CabinWall3Broken", Vector3.new(1, 3, 5), Vector3.new(145, 1.5, -178), "Reddish brown", Enum.Material.Wood, cabin)
-- Partial roof
makePart("CabinRoof", Vector3.new(8, 0.5, 6), Vector3.new(138, 6.5, -181), "Reddish brown", Enum.Material.Wood, cabin)

-- Creepy totem poles
for i = 0, 2 do
	makePart("Totem"..i, Vector3.new(1.5, 8, 1.5), Vector3.new(100 + i * 25, 4, -140), "Reddish brown", Enum.Material.Wood, darkForest)
	makePart("TotemFace"..i, Vector3.new(2, 2, 0.5), Vector3.new(100 + i * 25, 6, -139.5), "Bright red", Enum.Material.Neon, darkForest, {Transparency = 0.4})
end

local dfSign = makePart("DFSign", Vector3.new(1,1,1), Vector3.new(130, 5, -120), "White", nil, darkForest, {Transparency = 1})
makeSign(dfSign, "🌑 Dark Forest", Vector3.new(0,0,0))

task.wait()

-- ============================================================
-- 10. DRAGON'S SPINE MOUNTAINS (deep wilderness, x=-180 to -60, z=-380 to -260)
-- ============================================================
print("[MapSetup2] Building Dragon's Spine Mountains...")
local mountains = getOrMake(wilderness, "DragonSpine")

-- Mountain base
makePart("MtnBase", Vector3.new(130, 2, 130), Vector3.new(-120, 1, -320), "Dark stone grey", Enum.Material.Slate, mountains)

-- Rock spires/peaks
local peakData = {
	{-160, 0, -290, 50}, {-130, 0, -310, 40}, {-100, 0, -280, 45},
	{-80, 0, -330, 55}, {-140, 0, -350, 35}, {-110, 0, -360, 42},
	{-170, 0, -340, 38}, {-90, 0, -300, 48},
}
for i, pd in ipairs(peakData) do
	local h = pd[4]
	makePart("Peak"..i, Vector3.new(12, h, 12), Vector3.new(pd[1], h/2 + 2, pd[3]), "Dark stone grey", Enum.Material.Slate, mountains)
	-- Snow cap
	makePart("Snow"..i, Vector3.new(10, 3, 10), Vector3.new(pd[1], h + 1, pd[3]), "White", Enum.Material.SmoothPlastic, mountains)
end

-- Cave entrance in mountain
makePart("MtnCaveL", Vector3.new(6, 14, 6), Vector3.new(-130, 9, -270), "Dark stone grey", Enum.Material.Slate, mountains)
makePart("MtnCaveR", Vector3.new(6, 14, 6), Vector3.new(-118, 9, -270), "Dark stone grey", Enum.Material.Slate, mountains)
makePart("MtnCaveTop", Vector3.new(18, 4, 6), Vector3.new(-124, 18, -270), "Dark stone grey", Enum.Material.Slate, mountains)

-- Rope bridge between peaks
makePart("RopeBridge", Vector3.new(3, 0.3, 30), Vector3.new(-115, 25, -305), "Reddish brown", Enum.Material.Wood, mountains)
makePart("BridgeRope1", Vector3.new(0.2, 2, 30), Vector3.new(-113.5, 26, -305), "Brown", Enum.Material.Fabric, mountains)
makePart("BridgeRope2", Vector3.new(0.2, 2, 30), Vector3.new(-116.5, 26, -305), "Brown", Enum.Material.Fabric, mountains)

-- Dragon bones
makePart("DragonSkull", Vector3.new(6, 4, 8), Vector3.new(-140, 4, -370), "White", Enum.Material.SmoothPlastic, mountains)
makePart("DragonSpine1", Vector3.new(2, 3, 2), Vector3.new(-140, 3, -362), "White", Enum.Material.SmoothPlastic, mountains)
makePart("DragonSpine2", Vector3.new(2, 2.5, 2), Vector3.new(-140, 2.5, -356), "White", Enum.Material.SmoothPlastic, mountains)
makePart("DragonRib1", Vector3.new(0.5, 5, 3), Vector3.new(-138, 3, -365), "White", Enum.Material.SmoothPlastic, mountains)
makePart("DragonRib2", Vector3.new(0.5, 5, 3), Vector3.new(-142, 3, -365), "White", Enum.Material.SmoothPlastic, mountains)

local mtnSign = makePart("MtnSign", Vector3.new(1,1,1), Vector3.new(-120, 30, -275), "White", nil, mountains, {Transparency = 1})
makeSign(mtnSign, "🏔️ Dragon's Spine", Vector3.new(0,0,0))

task.wait()

-- ============================================================
-- 11. CURSED SWAMP (deep wilderness, x=40 to 200, z=-380 to -270)
-- ============================================================
print("[MapSetup2] Building Cursed Swamp...")
local swamp = getOrMake(wilderness, "CursedSwamp")

-- Murky water
makePart("SwampWater", Vector3.new(160, 0.5, 110), Vector3.new(120, -0.25, -325), Color3.fromRGB(30, 80, 120), Enum.Material.Water, swamp, {Transparency = 0.3, CanCollide = false})
-- Muddy ground
makePart("SwampMud", Vector3.new(170, 0.3, 120), Vector3.new(120, -0.1, -325), "Brown", Enum.Material.Ground, swamp)

-- Dead trees emerging from water
for i = 1, 12 do
	local sx = 50 + math.random(0, 140)
	local sz = -370 + math.random(0, 90)
	makePart("SwampTree"..i, Vector3.new(1, 6 + math.random(0,4), 1), Vector3.new(sx, 3, sz), "Dark stone grey", Enum.Material.Wood, swamp)
end

-- Bubbling pits
for i = 1, 5 do
	local bx = 60 + math.random(0, 120)
	local bz = -360 + math.random(0, 70)
	local pit = makePart("BubblePit"..i, Vector3.new(4, 0.5, 4), Vector3.new(bx, 0.1, bz), "Bright green", Enum.Material.Neon, swamp, {Transparency = 0.4})
	local pgl = Instance.new("PointLight") pgl.Color = Color3.fromRGB(50, 200, 50) pgl.Brightness = 1.5 pgl.Range = 10 pgl.Parent = pit
end

-- Rickety walkways
makePart("Walkway1", Vector3.new(3, 0.3, 40), Vector3.new(100, 0.4, -315), "Reddish brown", Enum.Material.WoodPlanks, swamp)
makePart("Walkway2", Vector3.new(30, 0.3, 3), Vector3.new(120, 0.4, -335), "Reddish brown", Enum.Material.WoodPlanks, swamp)
makePart("Walkway3", Vector3.new(3, 0.3, 30), Vector3.new(140, 0.4, -345), "Reddish brown", Enum.Material.WoodPlanks, swamp)

-- Witch's hut on stilts
makePart("HutStilt1", Vector3.new(0.5, 6, 0.5), Vector3.new(155, 3, -350), "Reddish brown", Enum.Material.Wood, swamp)
makePart("HutStilt2", Vector3.new(0.5, 6, 0.5), Vector3.new(165, 3, -350), "Reddish brown", Enum.Material.Wood, swamp)
makePart("HutStilt3", Vector3.new(0.5, 6, 0.5), Vector3.new(155, 3, -356), "Reddish brown", Enum.Material.Wood, swamp)
makePart("HutStilt4", Vector3.new(0.5, 6, 0.5), Vector3.new(165, 3, -356), "Reddish brown", Enum.Material.Wood, swamp)
makePart("HutFloor", Vector3.new(12, 0.3, 8), Vector3.new(160, 6, -353), "Reddish brown", Enum.Material.WoodPlanks, swamp)
makePart("HutWall1", Vector3.new(12, 6, 0.5), Vector3.new(160, 9, -357), "Reddish brown", Enum.Material.Wood, swamp)
makePart("HutWall2", Vector3.new(0.5, 6, 8), Vector3.new(154, 9, -353), "Reddish brown", Enum.Material.Wood, swamp)
makePart("HutRoof", Vector3.new(14, 0.5, 10), Vector3.new(160, 12, -353), "Really black", Enum.Material.Slate, swamp)

-- Poisonous mushrooms (red with white)
for i = 1, 8 do
	local mx = 60 + math.random(0, 130)
	local mz = -370 + math.random(0, 80)
	makePart("PoisonShroom"..i, Vector3.new(1.2, 1.5, 1.2), Vector3.new(mx, 0.75, mz), "Bright red", Enum.Material.SmoothPlastic, swamp, {CanCollide = false})
	makePart("ShroomSpot"..i, Vector3.new(0.4, 0.4, 0.1), Vector3.new(mx + 0.3, 1.2, mz), "White", Enum.Material.SmoothPlastic, swamp, {CanCollide = false})
end

local swampSign = makePart("SwampSign", Vector3.new(1,1,1), Vector3.new(120, 4, -272), "White", nil, swamp, {Transparency = 1})
makeSign(swampSign, "🧪 Cursed Swamp", Vector3.new(0,0,0))

task.wait()

-- ============================================================
-- 12. THE ABYSS (deepest wilderness, x=-80 to 80, z=-520 to -420)
-- ============================================================
print("[MapSetup2] Building The Abyss...")
local abyss = getOrMake(wilderness, "TheAbyss")

-- Obsidian ground
makePart("AbyssGround", Vector3.new(180, 0.3, 120), Vector3.new(0, 0.15, -470), "Really black", Enum.Material.Slate, abyss)

-- Lava rivers (red neon strips)
makePart("LavaRiver1", Vector3.new(4, 0.5, 100), Vector3.new(-30, 0.25, -470), "Bright red", Enum.Material.Neon, abyss, {Transparency = 0.2, CanCollide = false})
makePart("LavaRiver2", Vector3.new(80, 0.5, 4), Vector3.new(10, 0.25, -450), "Bright red", Enum.Material.Neon, abyss, {Transparency = 0.2, CanCollide = false})
makePart("LavaRiver3", Vector3.new(4, 0.5, 60), Vector3.new(40, 0.25, -490), "Bright red", Enum.Material.Neon, abyss, {Transparency = 0.2, CanCollide = false})

-- Floating crystal formations
for i = 1, 10 do
	local cx = -60 + math.random(0, 120)
	local cy = 5 + math.random(0, 15)
	local cz = -510 + math.random(0, 80)
	local crystal = makePart("Crystal"..i, Vector3.new(2, 5 + math.random(0, 4), 2), Vector3.new(cx, cy, cz), "Bright violet", Enum.Material.Neon, abyss, {Transparency = 0.3, CanCollide = false, Orientation = Vector3.new(math.random(-15,15), math.random(0,360), math.random(-15,15))})
	local crl = Instance.new("PointLight") crl.Color = Color3.fromRGB(150, 50, 255) crl.Brightness = 2 crl.Range = 15 crl.Parent = crystal
end

-- Ruined altar/temple
local temple = getOrMake(abyss, "DarkTemple")
makePart("TempleFloor", Vector3.new(30, 1, 24), Vector3.new(0, 0.5, -480), "Really black", Enum.Material.Marble, temple)
-- Pillars
for i = 0, 3 do
	makePart("TPillarL"..i, Vector3.new(3, 16, 3), Vector3.new(-12, 8, -472 - i * 5), "Dark stone grey", Enum.Material.Marble, temple)
	makePart("TPillarR"..i, Vector3.new(3, 16, 3), Vector3.new(12, 8, -472 - i * 5), "Dark stone grey", Enum.Material.Marble, temple)
end
-- Temple roof fragments
makePart("TempleRoof1", Vector3.new(15, 2, 10), Vector3.new(-3, 17, -475), "Dark stone grey", Enum.Material.Marble, temple)
makePart("TempleRoof2", Vector3.new(10, 2, 8), Vector3.new(5, 17, -488), "Dark stone grey", Enum.Material.Marble, temple)
-- Dark altar
makePart("DarkAltar", Vector3.new(6, 3, 4), Vector3.new(0, 2, -490), "Really black", Enum.Material.Marble, temple)
local altarOrb = makePart("AltarOrb", Vector3.new(2, 2, 2), Vector3.new(0, 4.5, -490), "Bright violet", Enum.Material.Neon, temple, {Transparency = 0.2})
local aol = Instance.new("PointLight") aol.Color = Color3.fromRGB(200, 50, 255) aol.Brightness = 5 aol.Range = 30 aol.Parent = altarOrb

-- Demonic statues
for i, pos in ipairs({{-20, 0, -465}, {20, 0, -465}, {-15, 0, -495}, {15, 0, -495}}) do
	makePart("DemonBase"..i, Vector3.new(3, 1, 3), Vector3.new(pos[1], 0.5, pos[3]), "Really black", Enum.Material.Marble, abyss)
	makePart("DemonBody"..i, Vector3.new(2, 6, 2), Vector3.new(pos[1], 4, pos[3]), "Really black", Enum.Material.Slate, abyss)
	makePart("DemonHead"..i, Vector3.new(1.5, 1.5, 1.5), Vector3.new(pos[1], 7.75, pos[3]), "Really black", Enum.Material.Slate, abyss)
	makePart("DemonEyes"..i, Vector3.new(0.8, 0.3, 0.1), Vector3.new(pos[1], 8, pos[3] + 0.8), "Bright red", Enum.Material.Neon, abyss)
end

local abyssSign = makePart("AbyssSign", Vector3.new(1,1,1), Vector3.new(0, 20, -425), "White", nil, abyss, {Transparency = 1})
makeSign(abyssSign, "👁️ THE ABYSS — Turn Back", Vector3.new(0,0,0), UDim2.new(14, 0, 3, 0))

-- ============================================================
-- 13. ADDITIONAL TERRAIN FEATURES
-- ============================================================
print("[MapSetup2] Adding terrain details...")

-- Cliff edges near Dragon's Spine
local cliffs = getOrMake(wilderness, "DragonSpine")
for i = 1, 6 do
	local cx = -180 + i * 20
	makePart("Cliff"..i, Vector3.new(15, 12 + math.random(0, 8), 4), Vector3.new(cx, 6, -265), "Dark stone grey", Enum.Material.Slate, cliffs)
end

-- Extra boulders around training grounds
for i = 1, 6 do
	local bx = 155 + math.random(0, 80)
	local bz = -25 + math.random(0, 90)
	local bs = 2 + math.random() * 3
	makePart("TrainBoulder"..i, Vector3.new(bs, bs * 0.7, bs), Vector3.new(bx, bs * 0.35, bz), "Medium stone grey", Enum.Material.Slate, safeZone)
end

-- Flower meadow near lake
for i = 1, 15 do
	local fx = -190 + math.random(0, 80)
	local fz = 190 + math.random(0, 20)
	local colors = {"Bright red", "Bright yellow", "Hot pink", "Bright violet", "Bright blue"}
	makePart("LakeFlower"..i, Vector3.new(0.5, 0.7, 0.5), Vector3.new(fx, 0.35, fz), colors[math.random(#colors)], Enum.Material.SmoothPlastic, safeZone, {CanCollide = false})
end

-- Bushes around village
for i = 1, 12 do
	local bx = -50 + math.random(0, 100)
	local bz = 160 + math.random(0, 60)
	local bs = 1.5 + math.random() * 1.5
	makePart("VillageBush"..i, Vector3.new(bs, bs * 0.6, bs), Vector3.new(bx, bs * 0.3, bz), "Forest green", Enum.Material.Grass, safeZone, {CanCollide = false})
end

-- Swamp fog patches
for i = 1, 5 do
	local fx = 60 + math.random(0, 120)
	local fz = -370 + math.random(0, 80)
	makePart("SwampFog"..i, Vector3.new(25 + math.random(0, 15), 4, 25 + math.random(0, 15)), Vector3.new(fx, 2, fz), "Dark green", Enum.Material.SmoothPlastic, wilderness, {Transparency = 0.88, CanCollide = false})
end

-- Grove moss patches
for i = 1, 10 do
	local mx = -240 + math.random(0, 120)
	local mz = -50 + math.random(0, 100)
	makePart("MossPatch"..i, Vector3.new(3 + math.random() * 4, 0.15, 3 + math.random() * 4), Vector3.new(mx, 0.1, mz), "Earth green", Enum.Material.Grass, safeZone, {CanCollide = false})
end

-- ============================================================
-- EXPAND BASEPLATE for all new areas
-- ============================================================
local bp = WS:FindFirstChild("Baseplate")
if bp then
	bp.Size = Vector3.new(800, 1, 800)
	bp.Position = Vector3.new(0, -0.5, 50)
end
local wg = WS:FindFirstChild("WildernessGround")
if wg then
	wg.Size = Vector3.new(800, 1.01, 800)
	wg.Position = Vector3.new(0, -0.5, -400)
end

print("[MapSetup2] World expansion complete!")
print("[MapSetup2] Areas: Farmlands, Haven Lake, Training Grounds, Ancient Grove, Outskirts Village, Watchtower Hill")
print("[MapSetup2] Wilderness: Bandit Camp, Dark Forest, Dragon's Spine, Cursed Swamp, The Abyss")
print("[MapSetup2] Roads connecting all areas with signposts and lanterns")
