--[[
	MapSetup5.server.lua
	ServerScriptService

	Creates 6 MASSIVE new themed areas with incredible detail (50-80 parts each):
	1. Pirate Cove (X: 300-400, Z: -200 to -100)
	2. Frozen Peaks (X: -400 to -300, Z: -300 to -200)
	3. Volcanic Crater (X: 300-400, Z: -400 to -300)
	4. Enchanted Garden (X: -300 to -200, Z: 200-350)
	5. Underground Ruins (X: -100 to 50, Z: -450 to -350)
	6. Dragon's Nest (X: 0-100, Z: -500 to -450)
]]

-- Wait for previous map setups to finish
task.wait(7)

print("[MapSetup5] Starting major new area creation...")

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
			elseif key == "Transparency" then
				part.Transparency = value
			elseif key == "CanCollide" then
				part.CanCollide = value
			elseif key == "Shape" then
				part.Shape = value
			else
				part[key] = value
			end
		end
	end
	
	part.Parent = parent
	return part
end

local function makeSign(parent, text, offset, size)
	local bg = Instance.new("BillboardGui")
	bg.Size = size or UDim2.new(12, 0, 3, 0)
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

local function randomInRange(min, max)
	return min + math.random() * (max - min)
end

local function randomPointInRect(xMin, xMax, zMin, zMax)
	return Vector3.new(randomInRange(xMin, xMax), 0, randomInRange(zMin, zMax))
end

local Workspace = game:GetService("Workspace")
local NewAreas = getOrMake(Workspace, "NewAreas")
local ResourceNodes = getOrMake(Workspace, "ResourceNodes")

--------------------------------------------------------------------------------
-- 1. PIRATE COVE (X: 300-400, Z: -200 to -100)
--------------------------------------------------------------------------------
print("[MapSetup5] Building Pirate Cove...")
local PirateCove = getOrMake(NewAreas, "PirateCove")

-- Sandy beach ground
for i = 1, 8 do
	local pos = randomPointInRect(300, 400, -200, -100)
	makePart("SandPatch" .. i, Vector3.new(randomInRange(15, 25), 0.5, randomInRange(15, 25)), 
		pos + Vector3.new(0, 0.25, 0), Color3.fromRGB(194, 178, 128), Enum.Material.Sand, PirateCove)
end

-- WRECKED PIRATE SHIP (massive centerpiece)
local shipCenter = Vector3.new(350, 0, -150)
-- Hull pieces (broken ship)
makePart("ShipHullMain", Vector3.new(25, 8, 5), shipCenter + Vector3.new(0, 4, 0), 
	Color3.fromRGB(101, 67, 33), Enum.Material.Wood, PirateCove)
makePart("ShipHullBow", Vector3.new(15, 6, 4), shipCenter + Vector3.new(15, 3, -2), 
	Color3.fromRGB(101, 67, 33), Enum.Material.Wood, PirateCove, {Orientation = Vector3.new(0, 15, -10)})
makePart("ShipHullStern", Vector3.new(12, 5, 4), shipCenter + Vector3.new(-18, 2.5, 3), 
	Color3.fromRGB(101, 67, 33), Enum.Material.Wood, PirateCove, {Orientation = Vector3.new(0, -20, 5)})

-- Broken mast
makePart("MainMast", Vector3.new(1.5, 20, 1.5), shipCenter + Vector3.new(0, 10, 0), 
	Color3.fromRGB(101, 67, 33), Enum.Material.Wood, PirateCove, {Orientation = Vector3.new(0, 0, -15)})
makePart("BrokenMastTop", Vector3.new(1, 8, 1), shipCenter + Vector3.new(-8, 4, -5), 
	Color3.fromRGB(101, 67, 33), Enum.Material.Wood, PirateCove, {Orientation = Vector3.new(0, 45, -30)})

-- Tattered sails
for i = 1, 4 do
	local sailPos = shipCenter + Vector3.new(randomInRange(-10, 10), randomInRange(8, 15), randomInRange(-8, 8))
	makePart("TatteredSail" .. i, Vector3.new(randomInRange(6, 12), randomInRange(4, 8), 0.2), 
		sailPos, Color3.fromRGB(240, 230, 200), Enum.Material.Fabric, PirateCove, 
		{Transparency = 0.2, Orientation = Vector3.new(randomInRange(-20, 20), randomInRange(0, 360), randomInRange(-15, 15))})
end

-- Ship rigging (ropes)
for i = 1, 12 do
	local startPos = shipCenter + Vector3.new(randomInRange(-12, 12), randomInRange(5, 18), randomInRange(-6, 6))
	local endPos = startPos + Vector3.new(randomInRange(-8, 8), randomInRange(-5, 5), randomInRange(-8, 8))
	local midPoint = (startPos + endPos) * 0.5
	local length = (endPos - startPos).Magnitude
	makePart("Rigging" .. i, Vector3.new(0.15, 0.15, length), midPoint, 
		Color3.fromRGB(139, 90, 43), Enum.Material.Fabric, PirateCove)
end

-- Treasure chests scattered around
local treasurePositions = {
	{325, 0, -140}, {370, 0, -165}, {340, 0, -185}, {385, 0, -120}, {315, 0, -170}
}
for i, pos in ipairs(treasurePositions) do
	makePart("TreasureChest" .. i, Vector3.new(3, 2, 2), Vector3.new(pos[1], 1, pos[3]), 
		Color3.fromRGB(139, 90, 43), Enum.Material.Wood, PirateCove)
	makePart("ChestBanding" .. i, Vector3.new(3.2, 0.3, 2.2), Vector3.new(pos[1], 1, pos[3]), 
		Color3.fromRGB(64, 64, 64), Enum.Material.Metal, PirateCove)
	makePart("ChestLock" .. i, Vector3.new(0.6, 0.6, 0.4), Vector3.new(pos[1], 1, pos[3] + 1.2), 
		Color3.fromRGB(255, 215, 0), Enum.Material.Metal, PirateCove)
	-- Spilled treasure
	for j = 1, 5 do
		local coinPos = Vector3.new(pos[1], 0.2, pos[3]) + Vector3.new(randomInRange(-3, 3), 0, randomInRange(-3, 3))
		makePart("Coin" .. i .. "_" .. j, Vector3.new(0.3, 0.1, 0.3), coinPos, 
			Color3.fromRGB(255, 215, 0), Enum.Material.Metal, PirateCove, {Shape = Enum.PartType.Cylinder})
	end
end

-- Wooden dock with rope posts
local dockStart = Vector3.new(320, 0, -120)
for i = 1, 15 do
	makePart("DockPlank" .. i, Vector3.new(4, 0.5, 20), dockStart + Vector3.new(i * 4, 0.25, 0), 
		Color3.fromRGB(101, 67, 33), Enum.Material.Wood, PirateCove)
end
-- Dock posts with ropes
for i = 1, 4 do
	local postPos = dockStart + Vector3.new(i * 15, 0, -12)
	makePart("DockPost" .. i, Vector3.new(0.8, 6, 0.8), postPos + Vector3.new(0, 3, 0), 
		Color3.fromRGB(101, 67, 33), Enum.Material.Wood, PirateCove)
	-- Rope coiled around post
	makePart("CoiledRope" .. i, Vector3.new(2, 1.5, 2), postPos + Vector3.new(0, 1.5, 0), 
		Color3.fromRGB(139, 90, 43), Enum.Material.Fabric, PirateCove, {Shape = Enum.PartType.Ball})
end

-- Barrels and crates scattered around
for i = 1, 15 do
	local pos = randomPointInRect(305, 395, -195, -105)
	if math.random() > 0.5 then
		-- Barrel
		makePart("Barrel" .. i, Vector3.new(2.5, 3, 2.5), pos + Vector3.new(0, 1.5, 0), 
			Color3.fromRGB(101, 67, 33), Enum.Material.Wood, PirateCove, {Shape = Enum.PartType.Cylinder})
		makePart("BarrelBand" .. i, Vector3.new(2.7, 0.2, 2.7), pos + Vector3.new(0, 1.5, 0), 
			Color3.fromRGB(64, 64, 64), Enum.Material.Metal, PirateCove)
	else
		-- Crate
		makePart("Crate" .. i, Vector3.new(2.5, 2.5, 2.5), pos + Vector3.new(0, 1.25, 0), 
			Color3.fromRGB(139, 90, 43), Enum.Material.Wood, PirateCove)
	end
end

-- Cannons (old ship artillery)
for i = 1, 6 do
	local cannonPos = randomPointInRect(320, 380, -180, -120)
	makePart("CannonBase" .. i, Vector3.new(3, 1, 4), cannonPos + Vector3.new(0, 0.5, 0), 
		Color3.fromRGB(101, 67, 33), Enum.Material.Wood, PirateCove)
	makePart("CannonBarrel" .. i, Vector3.new(1.5, 1.5, 6), cannonPos + Vector3.new(0, 1.5, 0), 
		Color3.fromRGB(64, 64, 64), Enum.Material.Metal, PirateCove, 
		{Shape = Enum.PartType.Cylinder, Orientation = Vector3.new(0, 0, 90)})
	makePart("CannonMuzzle" .. i, Vector3.new(1.8, 1.8, 0.5), cannonPos + Vector3.new(0, 1.5, 3.5), 
		Color3.fromRGB(40, 40, 40), Enum.Material.Metal, PirateCove, {Shape = Enum.PartType.Cylinder})
end

-- Palm trees (curved trunks)
for i = 1, 12 do
	local palmPos = randomPointInRect(310, 390, -190, -110)
	-- Curved trunk
	makePart("PalmTrunk" .. i, Vector3.new(1.5, 12, 1.5), palmPos + Vector3.new(0, 6, 0), 
		Color3.fromRGB(101, 67, 33), Enum.Material.Wood, PirateCove, 
		{Orientation = Vector3.new(randomInRange(-15, 15), randomInRange(0, 360), randomInRange(-20, 20))})
	-- Palm fronds (large leaves)
	for j = 1, 8 do
		local angle = (j / 8) * 360
		local frondPos = palmPos + Vector3.new(
			math.cos(math.rad(angle)) * 4, 
			12, 
			math.sin(math.rad(angle)) * 4
		)
		makePart("PalmFrond" .. i .. "_" .. j, Vector3.new(0.5, 0.2, 6), frondPos, 
			Color3.fromRGB(34, 139, 34), Enum.Material.Grass, PirateCove, 
			{Orientation = Vector3.new(randomInRange(-20, 20), angle, randomInRange(-30, 30))})
	end
	-- Coconuts
	for k = 1, 3 do
		local coconutPos = palmPos + Vector3.new(randomInRange(-2, 2), 10, randomInRange(-2, 2))
		makePart("Coconut" .. i .. "_" .. k, Vector3.new(0.8, 1, 0.8), coconutPos, 
			Color3.fromRGB(139, 69, 19), Enum.Material.Wood, PirateCove, {Shape = Enum.PartType.Ball})
	end
end

-- Tide pools (small water features)
for i = 1, 8 do
	local poolPos = randomPointInRect(305, 395, -195, -105)
	makePart("TidePool" .. i, Vector3.new(randomInRange(3, 6), 0.3, randomInRange(3, 6)), 
		poolPos + Vector3.new(0, 0.15, 0), Color3.fromRGB(65, 130, 175), Enum.Material.Water, 
		PirateCove, {Transparency = 0.3, Shape = Enum.PartType.Ball})
	-- Pool creatures
	for j = 1, 3 do
		local creaturePos = poolPos + Vector3.new(randomInRange(-2, 2), 0.5, randomInRange(-2, 2))
		makePart("Starfish" .. i .. "_" .. j, Vector3.new(0.5, 0.1, 0.5), creaturePos, 
			Color3.fromRGB(255, 69, 0), Enum.Material.SmoothPlastic, PirateCove)
	end
end

-- Cave entrance in cliff
makePart("CliffWallL", Vector3.new(8, 15, 12), Vector3.new(390, 7.5, -180), 
	Color3.fromRGB(105, 105, 105), Enum.Material.Rock, PirateCove)
makePart("CliffWallR", Vector3.new(8, 15, 12), Vector3.new(405, 7.5, -180), 
	Color3.fromRGB(105, 105, 105), Enum.Material.Rock, PirateCove)
makePart("CaveArch", Vector3.new(9, 6, 8), Vector3.new(397.5, 13, -180), 
	Color3.fromRGB(105, 105, 105), Enum.Material.Rock, PirateCove)
makePart("CaveEntrance", Vector3.new(6, 8, 10), Vector3.new(397.5, 4, -175), 
	Color3.fromRGB(20, 20, 20), Enum.Material.SmoothPlastic, PirateCove, {Transparency = 0.8})

-- Seagull perches (tall posts)
for i = 1, 6 do
	local perchPos = randomPointInRect(315, 385, -185, -115)
	makePart("SeagullPerch" .. i, Vector3.new(0.5, 8, 0.5), perchPos + Vector3.new(0, 4, 0), 
		Color3.fromRGB(101, 67, 33), Enum.Material.Wood, PirateCove)
	makePart("Seagull" .. i, Vector3.new(1, 0.8, 1.5), perchPos + Vector3.new(0, 8.5, 0), 
		Color3.fromRGB(240, 240, 240), Enum.Material.SmoothPlastic, PirateCove)
end

-- Ship anchor
makePart("Anchor", Vector3.new(2, 4, 1), Vector3.new(345, 1, -130), 
	Color3.fromRGB(64, 64, 64), Enum.Material.Metal, PirateCove)
makePart("AnchorChain", Vector3.new(0.3, 15, 0.3), Vector3.new(345, 8, -130), 
	Color3.fromRGB(64, 64, 64), Enum.Material.Metal, PirateCove)

-- Pirate Cove sign
local pirateSign = makePart("PirateSign", Vector3.new(1, 1, 1), Vector3.new(350, 12, -100), 
	"White", nil, PirateCove, {Transparency = 1})
makeSign(pirateSign, "🏴‍☠️ PIRATE COVE", Vector3.new(0, 0, 0))

--------------------------------------------------------------------------------
-- 2. FROZEN PEAKS (X: -400 to -300, Z: -300 to -200)
--------------------------------------------------------------------------------
print("[MapSetup5] Building Frozen Peaks...")
local FrozenPeaks = getOrMake(NewAreas, "FrozenPeaks")

-- Snow-covered ground patches
for i = 1, 12 do
	local pos = randomPointInRect(-400, -300, -300, -200)
	makePart("SnowPatch" .. i, Vector3.new(randomInRange(12, 20), 0.8, randomInRange(12, 20)), 
		pos + Vector3.new(0, 0.4, 0), Color3.fromRGB(248, 248, 255), Enum.Material.Snow, FrozenPeaks)
end

-- Massive ice crystals (angled spires)
for i = 1, 15 do
	local pos = randomPointInRect(-395, -305, -295, -205)
	local height = randomInRange(8, 18)
	makePart("IceCrystal" .. i, Vector3.new(randomInRange(2, 4), height, randomInRange(2, 4)), 
		pos + Vector3.new(0, height/2, 0), Color3.fromRGB(173, 216, 230), Enum.Material.ForceField, 
		FrozenPeaks, {Transparency = 0.3, Orientation = Vector3.new(randomInRange(-15, 15), randomInRange(0, 360), randomInRange(-15, 15))})
	-- Crystal glow
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(173, 216, 230)
	light.Brightness = 1.5
	light.Range = 12
	light.Parent = FrozenPeaks:FindFirstChild("IceCrystal" .. i)
end

-- Frozen waterfall (vertical ice strip)
makePart("WaterfallIce", Vector3.new(6, 25, 1), Vector3.new(-370, 12.5, -220), 
	Color3.fromRGB(173, 216, 230), Enum.Material.ForceField, FrozenPeaks, {Transparency = 0.4})
makePart("WaterfallBase", Vector3.new(8, 2, 8), Vector3.new(-370, 1, -220), 
	Color3.fromRGB(173, 216, 230), Enum.Material.Ice, FrozenPeaks, {Transparency = 0.2})
-- Icicles around waterfall
for i = 1, 12 do
	local iciclePos = Vector3.new(-370, 0, -220) + Vector3.new(randomInRange(-8, 8), randomInRange(15, 22), randomInRange(-3, 3))
	makePart("Icicle" .. i, Vector3.new(0.5, randomInRange(3, 8), 0.5), iciclePos, 
		Color3.fromRGB(240, 248, 255), Enum.Material.Ice, FrozenPeaks, {Transparency = 0.2})
end

-- Snow-covered pine trees
for i = 1, 20 do
	local treePos = randomPointInRect(-390, -310, -290, -210)
	-- Trunk
	makePart("PineTrunk" .. i, Vector3.new(1.5, randomInRange(10, 16), 1.5), 
		treePos + Vector3.new(0, 6, 0), Color3.fromRGB(101, 67, 33), Enum.Material.Wood, FrozenPeaks)
	-- Layered pine branches with snow
	local treeHeight = 12
	for layer = 1, 4 do
		local layerY = treeHeight - (layer * 2.5)
		local layerSize = 5 + (4 - layer) * 1.5
		-- Green base
		makePart("PineBranch" .. i .. "_" .. layer, 
			Vector3.new(layerSize, 1.5, layerSize), 
			treePos + Vector3.new(0, layerY, 0), 
			Color3.fromRGB(34, 139, 34), Enum.Material.Grass, FrozenPeaks, {Shape = Enum.PartType.Ball})
		-- Snow topping
		makePart("PineSnow" .. i .. "_" .. layer, 
			Vector3.new(layerSize * 0.8, 0.8, layerSize * 0.8), 
			treePos + Vector3.new(0, layerY + 0.8, 0), 
			Color3.fromRGB(248, 248, 255), Enum.Material.Snow, FrozenPeaks, {Shape = Enum.PartType.Ball})
	end
end

-- Ice cave entrance
makePart("IceCaveL", Vector3.new(8, 12, 8), Vector3.new(-380, 6, -260), 
	Color3.fromRGB(173, 216, 230), Enum.Material.Ice, FrozenPeaks, {Transparency = 0.2})
makePart("IceCaveR", Vector3.new(8, 12, 8), Vector3.new(-365, 6, -260), 
	Color3.fromRGB(173, 216, 230), Enum.Material.Ice, FrozenPeaks, {Transparency = 0.2})
makePart("IceCaveTop", Vector3.new(23, 5, 8), Vector3.new(-372.5, 14, -260), 
	Color3.fromRGB(173, 216, 230), Enum.Material.Ice, FrozenPeaks, {Transparency = 0.2})
makePart("CaveInterior", Vector3.new(12, 8, 15), Vector3.new(-372.5, 4, -255), 
	Color3.fromRGB(30, 30, 60), Enum.Material.SmoothPlastic, FrozenPeaks, {Transparency = 0.7})

-- Frozen lake (large ice sheet)
makePart("FrozenLake", Vector3.new(40, 0.8, 30), Vector3.new(-350, 0.4, -240), 
	Color3.fromRGB(173, 216, 230), Enum.Material.Ice, FrozenPeaks, {Transparency = 0.3})
-- Cracks in ice
for i = 1, 8 do
	local crackPos = Vector3.new(-350, 0.9, -240) + Vector3.new(randomInRange(-18, 18), 0, randomInRange(-13, 13))
	makePart("IceCrack" .. i, Vector3.new(0.2, 0.1, randomInRange(5, 12)), crackPos, 
		Color3.fromRGB(100, 150, 200), Enum.Material.Ice, FrozenPeaks, {Transparency = 0.5})
end

-- Snow drifts (white bumps)
for i = 1, 15 do
	local driftPos = randomPointInRect(-395, -305, -295, -205)
	makePart("SnowDrift" .. i, Vector3.new(randomInRange(4, 8), randomInRange(2, 4), randomInRange(4, 8)), 
		driftPos + Vector3.new(0, 1, 0), Color3.fromRGB(248, 248, 255), Enum.Material.Snow, FrozenPeaks, 
		{Shape = Enum.PartType.Ball})
end

-- Rock overhangs with icicles
for i = 1, 6 do
	local overhangPos = randomPointInRect(-390, -310, -290, -210)
	makePart("RockOverhang" .. i, Vector3.new(randomInRange(8, 12), 3, randomInRange(6, 10)), 
		overhangPos + Vector3.new(0, 8, 0), Color3.fromRGB(105, 105, 105), Enum.Material.Rock, FrozenPeaks)
	-- Hanging icicles
	for j = 1, 6 do
		local iciclePos = overhangPos + Vector3.new(randomInRange(-5, 5), 6.5, randomInRange(-4, 4))
		makePart("HangingIcicle" .. i .. "_" .. j, 
			Vector3.new(0.4, randomInRange(2, 5), 0.4), iciclePos, 
			Color3.fromRGB(240, 248, 255), Enum.Material.Ice, FrozenPeaks, {Transparency = 0.2})
	end
end

-- Frozen Peaks sign
local frozenSign = makePart("FrozenSign", Vector3.new(1, 1, 1), Vector3.new(-350, 15, -200), 
	"White", nil, FrozenPeaks, {Transparency = 1})
makeSign(frozenSign, "🗻 FROZEN PEAKS", Vector3.new(0, 0, 0))

--------------------------------------------------------------------------------
-- 3. VOLCANIC CRATER (X: 300-400, Z: -400 to -300)
--------------------------------------------------------------------------------
print("[MapSetup5] Building Volcanic Crater...")
local VolcanicCrater = getOrMake(NewAreas, "VolcanicCrater")

-- Dark volcanic rock terrain
for i = 1, 10 do
	local pos = randomPointInRect(300, 400, -400, -300)
	makePart("VolcanicGround" .. i, Vector3.new(randomInRange(15, 25), 1, randomInRange(15, 25)), 
		pos + Vector3.new(0, 0.5, 0), Color3.fromRGB(64, 32, 32), Enum.Material.Rock, VolcanicCrater)
end

-- Lava pools (orange-red neon with lights)
for i = 1, 12 do
	local poolPos = randomPointInRect(310, 390, -390, -310)
	local pool = makePart("LavaPool" .. i, Vector3.new(randomInRange(5, 10), 0.8, randomInRange(5, 10)), 
		poolPos + Vector3.new(0, 0.4, 0), Color3.fromRGB(255, 69, 0), Enum.Material.Neon, 
		VolcanicCrater, {Transparency = 0.2})
	-- Lava light
	local lavaLight = Instance.new("PointLight")
	lavaLight.Color = Color3.fromRGB(255, 100, 20)
	lavaLight.Brightness = 3
	lavaLight.Range = 15
	lavaLight.Parent = pool
	-- Bubbling effect
	for j = 1, 3 do
		local bubblePos = poolPos + Vector3.new(randomInRange(-3, 3), 1.5, randomInRange(-3, 3))
		makePart("LavaBubble" .. i .. "_" .. j, Vector3.new(0.8, 0.8, 0.8), bubblePos, 
			Color3.fromRGB(255, 140, 0), Enum.Material.Neon, VolcanicCrater, 
			{Transparency = 0.4, Shape = Enum.PartType.Ball, CanCollide = false})
	end
end

-- Obsidian spikes (black shiny pointed parts)
for i = 1, 18 do
	local spikePos = randomPointInRect(305, 395, -395, -305)
	local height = randomInRange(4, 12)
	makePart("ObsidianSpike" .. i, Vector3.new(randomInRange(1.5, 3), height, randomInRange(1.5, 3)), 
		spikePos + Vector3.new(0, height/2, 0), Color3.fromRGB(20, 20, 20), Enum.Material.Glass, 
		VolcanicCrater, {Orientation = Vector3.new(randomInRange(-10, 10), randomInRange(0, 360), randomInRange(-10, 10))})
end

-- Sulfur vents (yellow parts with smoke effect)
for i = 1, 8 do
	local ventPos = randomPointInRect(315, 385, -385, -315)
	makePart("SulfurVent" .. i, Vector3.new(2, 1, 2), ventPos + Vector3.new(0, 0.5, 0), 
		Color3.fromRGB(255, 255, 0), Enum.Material.Neon, VolcanicCrater, {Transparency = 0.3})
	-- Sulfur crystals around vent
	for j = 1, 4 do
		local crystalPos = ventPos + Vector3.new(randomInRange(-3, 3), 0.5, randomInRange(-3, 3))
		makePart("SulfurCrystal" .. i .. "_" .. j, Vector3.new(0.5, randomInRange(1, 2), 0.5), crystalPos, 
			Color3.fromRGB(255, 215, 0), Enum.Material.Neon, VolcanicCrater, {Transparency = 0.4})
	end
	-- Smoke effect (gray transparent parts)
	for k = 1, 3 do
		local smokeHeight = k * 3
		makePart("Smoke" .. i .. "_" .. k, Vector3.new(3 + k, 2, 3 + k), 
			ventPos + Vector3.new(0, smokeHeight, 0), Color3.fromRGB(100, 100, 100), 
			Enum.Material.ForceField, VolcanicCrater, 
			{Transparency = 0.7 + (k * 0.1), CanCollide = false, Shape = Enum.PartType.Ball})
	end
end

-- Charred trees (black trunks, no leaves)
for i = 1, 15 do
	local treePos = randomPointInRect(310, 390, -390, -310)
	local height = randomInRange(6, 12)
	makePart("CharredTrunk" .. i, Vector3.new(1.2, height, 1.2), 
		treePos + Vector3.new(0, height/2, 0), Color3.fromRGB(20, 20, 20), 
		Enum.Material.Wood, VolcanicCrater)
	-- Charred branches
	for j = 1, 3 do
		local branchAngle = (j / 3) * 360
		local branchPos = treePos + Vector3.new(
			math.cos(math.rad(branchAngle)) * 2, 
			height * 0.7, 
			math.sin(math.rad(branchAngle)) * 2
		)
		makePart("CharredBranch" .. i .. "_" .. j, Vector3.new(0.5, 0.5, 3), branchPos, 
			Color3.fromRGB(30, 30, 30), Enum.Material.Wood, VolcanicCrater, 
			{Orientation = Vector3.new(0, branchAngle, randomInRange(-30, 30))})
	end
end

-- Volcanic boulders
for i = 1, 20 do
	local boulderPos = randomPointInRect(305, 395, -395, -305)
	makePart("VolcanicBoulder" .. i, 
		Vector3.new(randomInRange(3, 8), randomInRange(2, 5), randomInRange(3, 8)), 
		boulderPos + Vector3.new(0, 2, 0), Color3.fromRGB(80, 40, 40), 
		Enum.Material.Rock, VolcanicCrater, {Shape = Enum.PartType.Ball})
end

-- Cracked earth (dark lines on ground)
for i = 1, 15 do
	local crackPos = randomPointInRect(310, 390, -390, -310)
	makePart("EarthCrack" .. i, Vector3.new(0.5, 0.2, randomInRange(8, 15)), crackPos, 
		Color3.fromRGB(40, 20, 20), Enum.Material.Concrete, VolcanicCrater, 
		{Orientation = Vector3.new(0, randomInRange(0, 360), 0)})
end

-- Fire geysers
for i = 1, 6 do
	local geyserPos = randomPointInRect(320, 380, -380, -320)
	makePart("GeyserBase" .. i, Vector3.new(3, 0.8, 3), geyserPos + Vector3.new(0, 0.4, 0), 
		Color3.fromRGB(60, 30, 30), Enum.Material.Rock, VolcanicCrater)
	-- Fire column
	for j = 1, 5 do
		local fireHeight = j * 2
		makePart("GeyserFire" .. i .. "_" .. j, Vector3.new(2 - (j * 0.2), 1.5, 2 - (j * 0.2)), 
			geyserPos + Vector3.new(0, fireHeight, 0), Color3.fromRGB(255, 100 - (j * 15), 0), 
			Enum.Material.Neon, VolcanicCrater, 
			{Transparency = 0.2 + (j * 0.1), CanCollide = false})
	end
end

-- Ash piles
for i = 1, 12 do
	local ashPos = randomPointInRect(315, 385, -385, -315)
	makePart("AshPile" .. i, Vector3.new(randomInRange(3, 6), randomInRange(1, 2), randomInRange(3, 6)), 
		ashPos + Vector3.new(0, 0.75, 0), Color3.fromRGB(64, 64, 64), 
		Enum.Material.Sand, VolcanicCrater, {Shape = Enum.PartType.Ball})
end

-- Volcanic Crater sign
local volcanicSign = makePart("VolcanicSign", Vector3.new(1, 1, 1), Vector3.new(350, 12, -300), 
	"White", nil, VolcanicCrater, {Transparency = 1})
makeSign(volcanicSign, "🌋 VOLCANIC CRATER", Vector3.new(0, 0, 0))

--------------------------------------------------------------------------------
-- 4. ENCHANTED GARDEN (X: -300 to -200, Z: 200-350)
--------------------------------------------------------------------------------
print("[MapSetup5] Building Enchanted Garden...")
local EnchantedGarden = getOrMake(NewAreas, "EnchantedGarden")

-- Magical flower paradise - giant flowers
for i = 1, 20 do
	local flowerPos = randomPointInRect(-295, -205, 205, 345)
	local colors = {Color3.fromRGB(255, 20, 147), Color3.fromRGB(138, 43, 226), Color3.fromRGB(255, 69, 0), 
					Color3.fromRGB(50, 205, 50), Color3.fromRGB(30, 144, 255), Color3.fromRGB(255, 215, 0)}
	local color = colors[math.random(1, #colors)]
	
	-- Stem
	makePart("FlowerStem" .. i, Vector3.new(0.8, randomInRange(6, 10), 0.8), 
		flowerPos + Vector3.new(0, 4, 0), Color3.fromRGB(34, 139, 34), 
		Enum.Material.Grass, EnchantedGarden)
	
	-- Oversized petals
	local petalCount = 6
	local stemHeight = 8
	for j = 1, petalCount do
		local angle = (j / petalCount) * 360
		local petalPos = flowerPos + Vector3.new(
			math.cos(math.rad(angle)) * 3, 
			stemHeight, 
			math.sin(math.rad(angle)) * 3
		)
		makePart("FlowerPetal" .. i .. "_" .. j, Vector3.new(2, 0.3, 4), petalPos, 
			color, Enum.Material.Neon, EnchantedGarden, 
			{Transparency = 0.2, Orientation = Vector3.new(randomInRange(-15, 15), angle, randomInRange(-20, 20))})
	end
	
	-- Flower center
	makePart("FlowerCenter" .. i, Vector3.new(2, 1, 2), flowerPos + Vector3.new(0, stemHeight, 0), 
		Color3.fromRGB(255, 215, 0), Enum.Material.Neon, EnchantedGarden, 
		{Transparency = 0.1, Shape = Enum.PartType.Ball})
end

-- Fairy rings (circles of glowing mushrooms)
for ring = 1, 5 do
	local centerPos = randomPointInRect(-280, -220, 220, 330)
	local radius = randomInRange(5, 8)
	for i = 1, 12 do
		local angle = (i / 12) * 360
		local mushroomPos = centerPos + Vector3.new(
			math.cos(math.rad(angle)) * radius, 
			0, 
			math.sin(math.rad(angle)) * radius
		)
		local mushroom = makePart("FairyMushroom" .. ring .. "_" .. i, 
			Vector3.new(0.8, 1.5, 0.8), mushroomPos + Vector3.new(0, 0.75, 0), 
			Color3.fromRGB(147, 0, 211), Enum.Material.Neon, EnchantedGarden, 
			{Transparency = 0.3})
		-- Mushroom glow
		local mushroomLight = Instance.new("PointLight")
		mushroomLight.Color = Color3.fromRGB(147, 0, 211)
		mushroomLight.Brightness = 1.5
		mushroomLight.Range = 5
		mushroomLight.Parent = mushroom
		
		-- Mushroom cap
		makePart("FairyMushroomCap" .. ring .. "_" .. i, Vector3.new(1.5, 0.4, 1.5), 
			mushroomPos + Vector3.new(0, 1.7, 0), Color3.fromRGB(255, 20, 147), 
			Enum.Material.Neon, EnchantedGarden, {Transparency = 0.2, Shape = Enum.PartType.Ball})
	end
	-- Fairy ring center glow
	makePart("FairyRingCenter" .. ring, Vector3.new(radius * 2, 0.1, radius * 2), centerPos, 
		Color3.fromRGB(186, 85, 211), Enum.Material.Neon, EnchantedGarden, 
		{Transparency = 0.8, CanCollide = false})
end

-- Enchanted fountain
local fountainCenter = Vector3.new(-250, 0, 275)
makePart("FountainBase", Vector3.new(12, 3, 12), fountainCenter + Vector3.new(0, 1.5, 0), 
	Color3.fromRGB(176, 196, 222), Enum.Material.Marble, EnchantedGarden)
makePart("FountainPool", Vector3.new(10, 0.5, 10), fountainCenter + Vector3.new(0, 3.25, 0), 
	Color3.fromRGB(176, 196, 222), Enum.Material.Marble, EnchantedGarden)
makePart("FountainWater", Vector3.new(9, 0.4, 9), fountainCenter + Vector3.new(0, 3.5, 0), 
	Color3.fromRGB(65, 130, 175), Enum.Material.Water, EnchantedGarden, 
	{Transparency = 0.3, CanCollide = false})
makePart("FountainPillar", Vector3.new(2, 8, 2), fountainCenter + Vector3.new(0, 8, 0), 
	Color3.fromRGB(176, 196, 222), Enum.Material.Marble, EnchantedGarden)
makePart("FountainSpray", Vector3.new(1, 6, 1), fountainCenter + Vector3.new(0, 15, 0), 
	Color3.fromRGB(0, 191, 255), Enum.Material.Neon, EnchantedGarden, 
	{Transparency = 0.4, CanCollide = false})

-- Rainbow bridge (multi-colored arc)
local bridgeCenter = Vector3.new(-250, 0, 320)
local colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 165, 0), Color3.fromRGB(255, 255, 0), 
				Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(75, 0, 130), 
				Color3.fromRGB(238, 130, 238)}
for i, color in ipairs(colors) do
	local angle = (i - 1) * 15 - 45
	local radius = 15
	local bridgePos = bridgeCenter + Vector3.new(
		math.cos(math.rad(angle)) * radius, 
		8 + math.sin(math.rad(angle)) * 5, 
		0
	)
	makePart("RainbowSegment" .. i, Vector3.new(3, 1, 2), bridgePos, 
		color, Enum.Material.Neon, EnchantedGarden, 
		{Transparency = 0.2, Orientation = Vector3.new(0, 0, angle)})
end

-- Crystal butterflies (small neon parts)
for i = 1, 25 do
	local butterflyPos = randomPointInRect(-295, -205, 205, 345)
	butterflyPos = butterflyPos + Vector3.new(0, randomInRange(3, 8), 0)
	local colors = {Color3.fromRGB(255, 20, 147), Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 255, 0), 
					Color3.fromRGB(255, 0, 255), Color3.fromRGB(0, 255, 0)}
	local color = colors[math.random(1, #colors)]
	
	-- Butterfly body
	makePart("ButterflyBody" .. i, Vector3.new(0.1, 0.8, 0.1), butterflyPos, 
		Color3.fromRGB(0, 0, 0), Enum.Material.SmoothPlastic, EnchantedGarden, {CanCollide = false})
	-- Butterfly wings
	makePart("ButterflyWingL" .. i, Vector3.new(0.8, 0.1, 1), 
		butterflyPos + Vector3.new(-0.5, 0, 0), color, Enum.Material.Neon, 
		EnchantedGarden, {Transparency = 0.3, CanCollide = false})
	makePart("ButterflyWingR" .. i, Vector3.new(0.8, 0.1, 1), 
		butterflyPos + Vector3.new(0.5, 0, 0), color, Enum.Material.Neon, 
		EnchantedGarden, {Transparency = 0.3, CanCollide = false})
end

-- Magic trees with glowing fruit
for i = 1, 12 do
	local treePos = randomPointInRect(-290, -210, 210, 340)
	-- Trunk
	makePart("MagicTrunk" .. i, Vector3.new(2, randomInRange(10, 15), 2), 
		treePos + Vector3.new(0, 6, 0), Color3.fromRGB(139, 69, 19), 
		Enum.Material.Wood, EnchantedGarden)
	-- Magical canopy
	makePart("MagicCanopy" .. i, Vector3.new(8, 6, 8), treePos + Vector3.new(0, 14, 0), 
		Color3.fromRGB(50, 205, 50), Enum.Material.Grass, EnchantedGarden, {Shape = Enum.PartType.Ball})
	-- Glowing fruit
	for j = 1, 6 do
		local fruitPos = treePos + Vector3.new(randomInRange(-3, 3), randomInRange(11, 16), randomInRange(-3, 3))
		local fruit = makePart("MagicFruit" .. i .. "_" .. j, Vector3.new(0.6, 0.8, 0.6), fruitPos, 
			Color3.fromRGB(255, 215, 0), Enum.Material.Neon, EnchantedGarden, 
			{Transparency = 0.2, Shape = Enum.PartType.Ball, CanCollide = false})
		-- Fruit glow
		local fruitLight = Instance.new("PointLight")
		fruitLight.Color = Color3.fromRGB(255, 215, 0)
		fruitLight.Brightness = 1
		fruitLight.Range = 4
		fruitLight.Parent = fruit
	end
end

-- Hedge maze walls (green blocks in maze pattern)
local mazeCenter = Vector3.new(-270, 0, 300)
local mazeSize = 20
-- Outer walls
for i = 0, mazeSize do
	makePart("MazeWallN" .. i, Vector3.new(2, 4, 2), 
		mazeCenter + Vector3.new(-mazeSize + i * 2, 2, -mazeSize), 
		Color3.fromRGB(34, 139, 34), Enum.Material.Grass, EnchantedGarden)
	makePart("MazeWallS" .. i, Vector3.new(2, 4, 2), 
		mazeCenter + Vector3.new(-mazeSize + i * 2, 2, mazeSize), 
		Color3.fromRGB(34, 139, 34), Enum.Material.Grass, EnchantedGarden)
end
for i = 0, mazeSize do
	makePart("MazeWallW" .. i, Vector3.new(2, 4, 2), 
		mazeCenter + Vector3.new(-mazeSize, 2, -mazeSize + i * 2), 
		Color3.fromRGB(34, 139, 34), Enum.Material.Grass, EnchantedGarden)
	makePart("MazeWallE" .. i, Vector3.new(2, 4, 2), 
		mazeCenter + Vector3.new(mazeSize, 2, -mazeSize + i * 2), 
		Color3.fromRGB(34, 139, 34), Enum.Material.Grass, EnchantedGarden)
end
-- Internal maze walls (simple pattern)
local mazePattern = {
	{-10, -10, 8, 2}, {-5, -15, 2, 12}, {5, -10, 2, 8}, {10, -5, 8, 2},
	{-15, 5, 12, 2}, {0, 0, 2, 10}, {-8, 8, 16, 2}, {8, 12, 2, 8}
}
for i, wall in ipairs(mazePattern) do
	makePart("MazeInternal" .. i, Vector3.new(wall[3], 4, wall[4]), 
		mazeCenter + Vector3.new(wall[1], 2, wall[2]), 
		Color3.fromRGB(34, 139, 34), Enum.Material.Grass, EnchantedGarden)
end

-- Wishing well
local wellPos = Vector3.new(-230, 0, 250)
makePart("WishingWellBase", Vector3.new(5, 4, 5), wellPos + Vector3.new(0, 2, 0), 
	Color3.fromRGB(105, 105, 105), Enum.Material.Cobblestone, EnchantedGarden)
makePart("WellWater", Vector3.new(3, 0.5, 3), wellPos + Vector3.new(0, 4.5, 0), 
	Color3.fromRGB(65, 130, 175), Enum.Material.Water, EnchantedGarden, 
	{Transparency = 0.3, CanCollide = false})
makePart("WellRoof", Vector3.new(7, 0.5, 7), wellPos + Vector3.new(0, 8, 0), 
	Color3.fromRGB(139, 69, 19), Enum.Material.Wood, EnchantedGarden)
-- Well posts
makePart("WellPostL", Vector3.new(0.5, 6, 0.5), wellPos + Vector3.new(-3, 6, 0), 
	Color3.fromRGB(139, 69, 19), Enum.Material.Wood, EnchantedGarden)
makePart("WellPostR", Vector3.new(0.5, 6, 0.5), wellPos + Vector3.new(3, 6, 0), 
	Color3.fromRGB(139, 69, 19), Enum.Material.Wood, EnchantedGarden)

-- Enchanted Garden sign
local gardenSign = makePart("GardenSign", Vector3.new(1, 1, 1), Vector3.new(-250, 12, 350), 
	"White", nil, EnchantedGarden, {Transparency = 1})
makeSign(gardenSign, "🌺 ENCHANTED GARDEN", Vector3.new(0, 0, 0))

--------------------------------------------------------------------------------
-- 5. UNDERGROUND RUINS (X: -100 to 50, Z: -450 to -350)
--------------------------------------------------------------------------------
print("[MapSetup5] Building Underground Ruins...")
local UndergroundRuins = getOrMake(NewAreas, "UndergroundRuins")

-- Ancient civilization remains - broken pillars
for i = 1, 15 do
	local pillarPos = randomPointInRect(-95, 45, -445, -355)
	local height = randomInRange(8, 16)
	local isToppled = math.random() > 0.6
	
	if isToppled then
		-- Toppled pillar (horizontal)
		makePart("TopplePillar" .. i, Vector3.new(height, 2, 2), pillarPos + Vector3.new(height/2, 1, 0), 
			Color3.fromRGB(105, 105, 105), Enum.Material.Cobblestone, UndergroundRuins, 
			{Orientation = Vector3.new(0, 0, -90)})
	else
		-- Standing pillar (may be broken)
		local actualHeight = isToppled and height * 0.6 or height
		makePart("StandingPillar" .. i, Vector3.new(2, actualHeight, 2), 
			pillarPos + Vector3.new(0, actualHeight/2, 0), Color3.fromRGB(105, 105, 105), 
			Enum.Material.Cobblestone, UndergroundRuins)
		-- Pillar capital
		makePart("PillarCapital" .. i, Vector3.new(3, 1, 3), 
			pillarPos + Vector3.new(0, actualHeight + 0.5, 0), Color3.fromRGB(145, 145, 145), 
			Enum.Material.Marble, UndergroundRuins)
	end
end

-- Crumbled walls (stone blocks in ruined patterns)
local wallSections = {
	{-80, 0, -420, 20, 6}, {-50, 0, -440, 15, 4}, {-10, 0, -410, 25, 8},
	{20, 0, -380, 18, 5}, {-20, 0, -370, 22, 7}, {40, 0, -400, 16, 6}
}
for i, wall in ipairs(wallSections) do
	local basePos = Vector3.new(wall[1], wall[2], wall[3])
	local length = wall[4]
	local height = wall[5]
	-- Main wall section
	makePart("RuinedWall" .. i, Vector3.new(length, height, 3), 
		basePos + Vector3.new(0, height/2, 0), Color3.fromRGB(105, 105, 105), 
		Enum.Material.Cobblestone, UndergroundRuins)
	-- Wall breach (gap)
	local breachPos = basePos + Vector3.new(randomInRange(-length/3, length/3), height/2, 0)
	makePart("WallBreach" .. i, Vector3.new(randomInRange(4, 8), height * 0.7, 3.5), 
		breachPos, Color3.fromRGB(20, 20, 20), Enum.Material.SmoothPlastic, 
		UndergroundRuins, {Transparency = 0.9, CanCollide = false})
	-- Rubble at base
	for j = 1, 5 do
		local rubblePos = basePos + Vector3.new(randomInRange(-length/2, length/2), 1, randomInRange(-2, 5))
		makePart("WallRubble" .. i .. "_" .. j, 
			Vector3.new(randomInRange(1, 3), randomInRange(1, 2), randomInRange(1, 3)), 
			rubblePos, Color3.fromRGB(85, 85, 85), Enum.Material.Concrete, UndergroundRuins)
	end
end

-- Hieroglyph panels (decorated stone slabs)
for i = 1, 10 do
	local panelPos = randomPointInRect(-90, 40, -440, -360)
	makePart("HieroglyphPanel" .. i, Vector3.new(4, 6, 0.5), panelPos + Vector3.new(0, 3, 0), 
		Color3.fromRGB(139, 134, 130), Enum.Material.Slate, UndergroundRuins)
	-- Hieroglyph symbols (simple geometric shapes)
	for j = 1, 6 do
		local symbolPos = panelPos + Vector3.new(randomInRange(-1.5, 1.5), randomInRange(1, 5), 0.3)
		local shapes = {Enum.PartType.Block, Enum.PartType.Ball, Enum.PartType.Cylinder}
		makePart("Hieroglyph" .. i .. "_" .. j, Vector3.new(0.3, 0.3, 0.1), symbolPos, 
			Color3.fromRGB(205, 133, 63), Enum.Material.Neon, UndergroundRuins, 
			{Transparency = 0.3, Shape = shapes[math.random(1, #shapes)], CanCollide = false})
	end
end

-- Sacrificial altar (dark stone platform)
local altarPos = Vector3.new(-25, 0, -400)
makePart("AltarBase", Vector3.new(8, 2, 12), altarPos + Vector3.new(0, 1, 0), 
	Color3.fromRGB(64, 64, 64), Enum.Material.Slate, UndergroundRuins)
makePart("AltarTop", Vector3.new(6, 0.5, 10), altarPos + Vector3.new(0, 2.5, 0), 
	Color3.fromRGB(40, 40, 40), Enum.Material.Marble, UndergroundRuins)
makePart("AltarBowl", Vector3.new(3, 0.8, 3), altarPos + Vector3.new(0, 3.2, 0), 
	Color3.fromRGB(80, 0, 0), Enum.Material.Neon, UndergroundRuins, 
	{Transparency = 0.4, Shape = Enum.PartType.Ball})
-- Altar steps
for i = 1, 3 do
	makePart("AltarStep" .. i, Vector3.new(10 + i * 2, 1, 14 + i * 2), 
		altarPos + Vector3.new(0, -i * 0.5, 0), Color3.fromRGB(85, 85, 85), 
		Enum.Material.Cobblestone, UndergroundRuins)
end

-- Underground river (blue transparent strip)
local riverPath = {{-80, 0, -380}, {-50, 0, -390}, {-20, 0, -420}, {10, 0, -430}, {40, 0, -420}}
for i = 1, #riverPath - 1 do
	local startPos = Vector3.new(riverPath[i][1], riverPath[i][2], riverPath[i][3])
	local endPos = Vector3.new(riverPath[i+1][1], riverPath[i+1][2], riverPath[i+1][3])
	local midPos = (startPos + endPos) * 0.5
	local length = (endPos - startPos).Magnitude
	makePart("RiverSegment" .. i, Vector3.new(6, 0.8, length), midPos + Vector3.new(0, 0.4, 0), 
		Color3.fromRGB(30, 80, 120), Enum.Material.Water, UndergroundRuins, 
		{Transparency = 0.3, CanCollide = false})
	-- River rocks
	for j = 1, 3 do
		local rockPos = midPos + Vector3.new(randomInRange(-4, 4), 0.5, randomInRange(-length/2, length/2))
		makePart("RiverRock" .. i .. "_" .. j, 
			Vector3.new(randomInRange(0.8, 1.5), randomInRange(0.5, 1), randomInRange(0.8, 1.5)), 
			rockPos, Color3.fromRGB(105, 105, 105), Enum.Material.Rock, UndergroundRuins, 
			{Shape = Enum.PartType.Ball})
	end
end

-- Ancient statues (gray humanoid shapes)
for i = 1, 8 do
	local statuePos = randomPointInRect(-85, 35, -435, -365)
	-- Statue base/pedestal
	makePart("StatuePedestal" .. i, Vector3.new(3, 2, 3), statuePos + Vector3.new(0, 1, 0), 
		Color3.fromRGB(105, 105, 105), Enum.Material.Marble, UndergroundRuins)
	-- Statue body
	makePart("StatueBody" .. i, Vector3.new(2, 4, 1.5), statuePos + Vector3.new(0, 4, 0), 
		Color3.fromRGB(145, 145, 145), Enum.Material.Marble, UndergroundRuins)
	-- Statue head (some may be missing)
	if math.random() > 0.3 then
		makePart("StatueHead" .. i, Vector3.new(1.2, 1.2, 1.2), statuePos + Vector3.new(0, 6.5, 0), 
			Color3.fromRGB(145, 145, 145), Enum.Material.Marble, UndergroundRuins, {Shape = Enum.PartType.Ball})
	end
	-- Statue arms (may be broken)
	if math.random() > 0.4 then
		makePart("StatueArmL" .. i, Vector3.new(0.8, 3, 0.8), statuePos + Vector3.new(-1.5, 4, 0), 
			Color3.fromRGB(145, 145, 145), Enum.Material.Marble, UndergroundRuins)
	end
	if math.random() > 0.4 then
		makePart("StatueArmR" .. i, Vector3.new(0.8, 3, 0.8), statuePos + Vector3.new(1.5, 4, 0), 
			Color3.fromRGB(145, 145, 145), Enum.Material.Marble, UndergroundRuins)
	end
end

-- Treasure vault door (large ornate golden door)
local vaultPos = Vector3.new(30, 0, -380)
makePart("VaultDoorFrame", Vector3.new(12, 15, 4), vaultPos + Vector3.new(0, 7.5, 0), 
	Color3.fromRGB(105, 105, 105), Enum.Material.Slate, UndergroundRuins)
makePart("VaultDoor", Vector3.new(8, 12, 1), vaultPos + Vector3.new(0, 6, 2), 
	Color3.fromRGB(255, 215, 0), Enum.Material.Metal, UndergroundRuins)
-- Door decorations
for i = 1, 4 do
	local decorPos = vaultPos + Vector3.new(-2 + i, 6, 2.5)
	makePart("VaultDecor" .. i, Vector3.new(0.8, 0.8, 0.3), decorPos, 
		Color3.fromRGB(184, 134, 11), Enum.Material.Metal, UndergroundRuins, {Shape = Enum.PartType.Ball})
end
-- Door handles
makePart("VaultHandleL", Vector3.new(0.5, 1.5, 0.8), vaultPos + Vector3.new(-2, 6, 2.8), 
	Color3.fromRGB(139, 69, 19), Enum.Material.Wood, UndergroundRuins)
makePart("VaultHandleR", Vector3.new(0.5, 1.5, 0.8), vaultPos + Vector3.new(2, 6, 2.8), 
	Color3.fromRGB(139, 69, 19), Enum.Material.Wood, UndergroundRuins)

-- Trap floor tiles (slightly different colored)
for i = 1, 12 do
	local trapPos = randomPointInRect(-75, 25, -425, -375)
	makePart("TrapTile" .. i, Vector3.new(4, 0.2, 4), trapPos + Vector3.new(0, 0.1, 0), 
		Color3.fromRGB(120, 120, 120), Enum.Material.Slate, UndergroundRuins, {Transparency = 0.1})
	-- Trap mechanism (spikes that could emerge)
	for j = 1, 4 do
		local spikePos = trapPos + Vector3.new(randomInRange(-1.5, 1.5), -0.5, randomInRange(-1.5, 1.5))
		makePart("TrapSpike" .. i .. "_" .. j, Vector3.new(0.2, 1, 0.2), spikePos, 
			Color3.fromRGB(64, 64, 64), Enum.Material.Metal, UndergroundRuins, {Transparency = 0.7})
	end
end

-- Torch sconces (wall-mounted torches)
for i = 1, 15 do
	local sconcePillar = randomPointInRect(-90, 40, -440, -360)
	makePart("TorchSconce" .. i, Vector3.new(0.8, 6, 0.8), sconcePillar + Vector3.new(0, 3, 0), 
		Color3.fromRGB(139, 69, 19), Enum.Material.Wood, UndergroundRuins)
	makePart("TorchFlame" .. i, Vector3.new(0.8, 1.5, 0.8), sconcePillar + Vector3.new(0, 6.5, 0), 
		Color3.fromRGB(255, 140, 0), Enum.Material.Neon, UndergroundRuins, {Transparency = 0.3})
	-- Torch light
	local torchLight = Instance.new("PointLight")
	torchLight.Color = Color3.fromRGB(255, 140, 0)
	torchLight.Brightness = 2
	torchLight.Range = 12
	torchLight.Parent = UndergroundRuins:FindFirstChild("TorchFlame" .. i)
end

-- Underground Ruins sign
local ruinsSign = makePart("RuinsSign", Vector3.new(1, 1, 1), Vector3.new(-25, 15, -350), 
	"White", nil, UndergroundRuins, {Transparency = 1})
makeSign(ruinsSign, "🏛️ UNDERGROUND RUINS", Vector3.new(0, 0, 0))

--------------------------------------------------------------------------------
-- 6. DRAGON'S NEST (X: 0-100, Z: -500 to -450)
--------------------------------------------------------------------------------
print("[MapSetup5] Building Dragon's Nest...")
local DragonNest = getOrMake(NewAreas, "DragonNest")

-- Scorched earth (black/dark brown ground)
for i = 1, 8 do
	local pos = randomPointInRect(5, 95, -495, -455)
	makePart("ScorchedGround" .. i, Vector3.new(randomInRange(12, 20), 0.5, randomInRange(12, 20)), 
		pos + Vector3.new(0, 0.25, 0), Color3.fromRGB(25, 25, 25), Enum.Material.Asphalt, DragonNest)
end

-- MASSIVE dragon skeleton (centerpiece)
local skeletonCenter = Vector3.new(50, 0, -475)
-- Dragon skull (huge)
makePart("DragonSkull", Vector3.new(12, 8, 15), skeletonCenter + Vector3.new(0, 4, 20), 
	Color3.fromRGB(230, 225, 210), Enum.Material.SmoothPlastic, DragonNest)
-- Skull eye sockets
makePart("SkullEyeL", Vector3.new(2.5, 2.5, 2), skeletonCenter + Vector3.new(-3, 5, 26), 
	Color3.fromRGB(20, 20, 20), Enum.Material.SmoothPlastic, DragonNest, {Shape = Enum.PartType.Ball})
makePart("SkullEyeR", Vector3.new(2.5, 2.5, 2), skeletonCenter + Vector3.new(3, 5, 26), 
	Color3.fromRGB(20, 20, 20), Enum.Material.SmoothPlastic, DragonNest, {Shape = Enum.PartType.Ball})
-- Dragon fangs
makePart("SkullFangL", Vector3.new(0.8, 3, 0.8), skeletonCenter + Vector3.new(-2, 2, 27), 
	Color3.fromRGB(240, 235, 220), Enum.Material.SmoothPlastic, DragonNest)
makePart("SkullFangR", Vector3.new(0.8, 3, 0.8), skeletonCenter + Vector3.new(2, 2, 27), 
	Color3.fromRGB(240, 235, 220), Enum.Material.SmoothPlastic, DragonNest)

-- Dragon spine (vertebrae)
for i = 1, 20 do
	local vertebraPos = skeletonCenter + Vector3.new(0, 2, 15 - i * 3)
	makePart("Vertebra" .. i, Vector3.new(3, 2, 2), vertebraPos, 
		Color3.fromRGB(230, 225, 210), Enum.Material.SmoothPlastic, DragonNest)
	-- Spine spikes
	makePart("SpineSpike" .. i, Vector3.new(0.5, randomInRange(2, 4), 0.5), vertebraPos + Vector3.new(0, 2, 0), 
		Color3.fromRGB(210, 205, 190), Enum.Material.SmoothPlastic, DragonNest)
end

-- Dragon ribcage (curved ribs)
for i = 1, 12 do
	local ribSpacing = i * 3
	local ribHeight = 8 - (i * 0.3)
	local ribPos = skeletonCenter + Vector3.new(0, 0, 10 - ribSpacing)
	-- Left rib
	makePart("RibL" .. i, Vector3.new(0.8, 0.8, ribHeight), ribPos + Vector3.new(-ribHeight/2, ribHeight/2, 0), 
		Color3.fromRGB(230, 225, 210), Enum.Material.SmoothPlastic, DragonNest, 
		{Orientation = Vector3.new(0, 0, -45)})
	-- Right rib
	makePart("RibR" .. i, Vector3.new(0.8, 0.8, ribHeight), ribPos + Vector3.new(ribHeight/2, ribHeight/2, 0), 
		Color3.fromRGB(230, 225, 210), Enum.Material.SmoothPlastic, DragonNest, 
		{Orientation = Vector3.new(0, 0, 45)})
end

-- Dragon wing bones
for side = 1, 2 do
	local sideMultiplier = side == 1 and -1 or 1
	local wingBase = skeletonCenter + Vector3.new(sideMultiplier * 8, 2, 0)
	-- Wing arm bone
	makePart("WingArm" .. side, Vector3.new(1.5, 1.5, 12), wingBase + Vector3.new(sideMultiplier * 6, 3, 0), 
		Color3.fromRGB(220, 215, 200), Enum.Material.SmoothPlastic, DragonNest, 
		{Orientation = Vector3.new(0, sideMultiplier * 30, sideMultiplier * 20)})
	-- Wing finger bones
	for finger = 1, 4 do
		local fingerAngle = finger * 15
		local fingerPos = wingBase + Vector3.new(sideMultiplier * 12, 2, finger * 3)
		makePart("WingFinger" .. side .. "_" .. finger, Vector3.new(0.8, 0.8, 8), fingerPos, 
			Color3.fromRGB(210, 205, 190), Enum.Material.SmoothPlastic, DragonNest, 
			{Orientation = Vector3.new(0, sideMultiplier * fingerAngle, sideMultiplier * 10)})
	end
end

-- Dragon leg bones
for leg = 1, 4 do
	local legX = (leg <= 2) and -3 or 3
	local legZ = (leg == 1 or leg == 3) and 5 or -10
	local legPos = skeletonCenter + Vector3.new(legX, 0, legZ)
	-- Thigh bone
	makePart("LegThigh" .. leg, Vector3.new(1.5, 1.5, 6), legPos + Vector3.new(0, 3, 0), 
		Color3.fromRGB(225, 220, 205), Enum.Material.SmoothPlastic, DragonNest, 
		{Orientation = Vector3.new(-30, 0, 0)})
	-- Shin bone
	makePart("LegShin" .. leg, Vector3.new(1.2, 1.2, 5), legPos + Vector3.new(0, 1, 3), 
		Color3.fromRGB(215, 210, 195), Enum.Material.SmoothPlastic, DragonNest, 
		{Orientation = Vector3.new(30, 0, 0)})
	-- Foot/claw
	makePart("LegClaw" .. leg, Vector3.new(2, 1, 3), legPos + Vector3.new(0, 0, 5), 
		Color3.fromRGB(200, 195, 180), Enum.Material.SmoothPlastic, DragonNest)
end

-- Dragon tail bones (long chain)
for i = 1, 15 do
	local tailPos = skeletonCenter + Vector3.new(0, 1, -45 - i * 2)
	local tailSize = 2.5 - (i * 0.1)
	makePart("TailBone" .. i, Vector3.new(tailSize, tailSize, 1.5), tailPos, 
		Color3.fromRGB(220, 215, 200), Enum.Material.SmoothPlastic, DragonNest)
end

-- Egg nest (large oval parts in a crater)
local nestCenter = Vector3.new(75, 0, -480)
makePart("NestCrater", Vector3.new(20, 3, 15), nestCenter + Vector3.new(0, -1.5, 0), 
	Color3.fromRGB(64, 32, 32), Enum.Material.Rock, DragonNest, {Shape = Enum.PartType.Ball})
-- Dragon eggs (various sizes)
local eggSizes = {{4, 5, 3}, {3.5, 4.5, 2.5}, {5, 6, 4}, {3, 4, 2.5}, {4.5, 5.5, 3.5}}
for i, size in ipairs(eggSizes) do
	local eggPos = nestCenter + Vector3.new(randomInRange(-8, 8), 1, randomInRange(-6, 6))
	makePart("DragonEgg" .. i, Vector3.new(size[1], size[2], size[3]), eggPos, 
		Color3.fromRGB(139, 0, 0), Enum.Material.SmoothPlastic, DragonNest, {Shape = Enum.PartType.Ball})
	-- Egg patterns
	makePart("EggPattern" .. i, Vector3.new(size[1] * 0.8, size[2] * 0.8, size[3] * 0.8), eggPos, 
		Color3.fromRGB(255, 215, 0), Enum.Material.Neon, DragonNest, 
		{Shape = Enum.PartType.Ball, Transparency = 0.7, CanCollide = false})
end

-- Treasure hoard (gold-colored pile)
local treasureCenter = Vector3.new(25, 0, -465)
-- Gold pile base
makePart("TreasurePile", Vector3.new(15, 4, 12), treasureCenter + Vector3.new(0, 2, 0), 
	Color3.fromRGB(255, 215, 0), Enum.Material.Metal, DragonNest, {Shape = Enum.PartType.Ball})
-- Individual treasure items
for i = 1, 25 do
	local treasurePos = treasureCenter + Vector3.new(randomInRange(-8, 8), randomInRange(1, 5), randomInRange(-6, 6))
	local treasureTypes = {"Coin", "Gem", "Crown", "Goblet", "Sword"}
	local treasureType = treasureTypes[math.random(1, #treasureTypes)]
	
	if treasureType == "Coin" then
		makePart("TreasureCoin" .. i, Vector3.new(0.6, 0.1, 0.6), treasurePos, 
			Color3.fromRGB(255, 215, 0), Enum.Material.Metal, DragonNest, {Shape = Enum.PartType.Cylinder})
	elseif treasureType == "Gem" then
		makePart("TreasureGem" .. i, Vector3.new(0.8, 0.8, 0.8), treasurePos, 
			Color3.fromRGB(138, 43, 226), Enum.Material.Neon, DragonNest, 
			{Shape = Enum.PartType.Ball, Transparency = 0.3})
	elseif treasureType == "Crown" then
		makePart("TreasureCrown" .. i, Vector3.new(1.5, 1, 1.5), treasurePos, 
			Color3.fromRGB(255, 215, 0), Enum.Material.Metal, DragonNest)
	elseif treasureType == "Goblet" then
		makePart("TreasureGoblet" .. i, Vector3.new(0.8, 1.2, 0.8), treasurePos, 
			Color3.fromRGB(192, 192, 192), Enum.Material.Metal, DragonNest, {Shape = Enum.PartType.Cylinder})
	elseif treasureType == "Sword" then
		makePart("TreasureSword" .. i, Vector3.new(0.3, 3, 0.8), treasurePos, 
			Color3.fromRGB(192, 192, 192), Enum.Material.Metal, DragonNest)
	end
end

-- Dragon scale fragments scattered
for i = 1, 30 do
	local scalePos = randomPointInRect(10, 90, -490, -460)
	makePart("DragonScale" .. i, Vector3.new(randomInRange(0.5, 1.5), 0.2, randomInRange(0.8, 2)), scalePos, 
		Color3.fromRGB(139, 0, 0), Enum.Material.SmoothPlastic, DragonNest, 
		{Orientation = Vector3.new(randomInRange(0, 30), randomInRange(0, 360), randomInRange(0, 30))})
end

-- Burning ground patches (neon orange)
for i = 1, 10 do
	local firePos = randomPointInRect(15, 85, -485, -465)
	local fire = makePart("GroundFire" .. i, Vector3.new(randomInRange(4, 8), 1, randomInRange(4, 8)), 
		firePos + Vector3.new(0, 0.5, 0), Color3.fromRGB(255, 69, 0), Enum.Material.Neon, 
		DragonNest, {Transparency = 0.3})
	-- Fire light
	local fireLight = Instance.new("PointLight")
	fireLight.Color = Color3.fromRGB(255, 100, 20)
	fireLight.Brightness = 3
	fireLight.Range = 12
	fireLight.Parent = fire
end

-- Volcanic vents
for i = 1, 6 do
	local ventPos = randomPointInRect(20, 80, -485, -465)
	makePart("DragonVent" .. i, Vector3.new(3, 2, 3), ventPos + Vector3.new(0, 1, 0), 
		Color3.fromRGB(64, 32, 32), Enum.Material.Rock, DragonNest)
	-- Vent glow
	makePart("VentGlow" .. i, Vector3.new(2, 1, 2), ventPos + Vector3.new(0, 2.5, 0), 
		Color3.fromRGB(255, 140, 0), Enum.Material.Neon, DragonNest, {Transparency = 0.4})
end

-- Bones scattered everywhere (various creature remains)
for i = 1, 20 do
	local bonePos = randomPointInRect(10, 90, -490, -460)
	local boneTypes = {"Skull", "Femur", "Rib", "Spine"}
	local boneType = boneTypes[math.random(1, #boneTypes)]
	
	if boneType == "Skull" then
		makePart("ScatteredSkull" .. i, Vector3.new(1.5, 1, 2), bonePos + Vector3.new(0, 0.5, 0), 
			Color3.fromRGB(240, 235, 220), Enum.Material.SmoothPlastic, DragonNest)
	elseif boneType == "Femur" then
		makePart("ScatteredFemur" .. i, Vector3.new(0.8, 0.8, 3), bonePos + Vector3.new(0, 0.4, 0), 
			Color3.fromRGB(230, 225, 210), Enum.Material.SmoothPlastic, DragonNest)
	elseif boneType == "Rib" then
		makePart("ScatteredRib" .. i, Vector3.new(0.5, 2, 0.5), bonePos + Vector3.new(0, 1, 0), 
			Color3.fromRGB(225, 220, 205), Enum.Material.SmoothPlastic, DragonNest, 
			{Orientation = Vector3.new(randomInRange(0, 90), randomInRange(0, 360), randomInRange(0, 90))})
	elseif boneType == "Spine" then
		makePart("ScatteredSpine" .. i, Vector3.new(1, 1, 2), bonePos + Vector3.new(0, 0.5, 0), 
			Color3.fromRGB(220, 215, 200), Enum.Material.SmoothPlastic, DragonNest)
	end
end

-- Dragon's Nest sign
local nestSign = makePart("NestSign", Vector3.new(1, 1, 1), Vector3.new(50, 15, -450), 
	"White", nil, DragonNest, {Transparency = 1})
makeSign(nestSign, "🐉 DRAGON'S NEST", Vector3.new(0, 0, 0))

--------------------------------------------------------------------------------
-- RESOURCE NODES CREATION
--------------------------------------------------------------------------------
print("[MapSetup5] Creating resource nodes...")

-- Resource node creation helper
local function createResourceNode(name, position, nodeType, parent)
	local node = makePart(name, Vector3.new(2, 3, 2), position + Vector3.new(0, 1.5, 0), 
		Color3.fromRGB(105, 105, 105), Enum.Material.Rock, parent)
	
	-- Add ClickDetector
	local cd = Instance.new("ClickDetector")
	cd.MaxActivationDistance = 10
	cd.Parent = node
	
	-- Add BillboardGui label
	local bg = Instance.new("BillboardGui")
	bg.Size = UDim2.new(4, 0, 1, 0)
	bg.StudsOffset = Vector3.new(0, 2, 0)
	bg.Parent = node
	
	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.new(1, 0, 1, 0)
	tl.BackgroundTransparency = 1
	tl.Text = nodeType
	tl.TextColor3 = Color3.fromRGB(255, 255, 255)
	tl.TextScaled = true
	tl.Font = Enum.Font.GothamBold
	tl.TextStrokeTransparency = 0.3
	tl.Parent = bg
	
	return node
end

-- Frozen Peaks nodes
for i = 1, 5 do
	local pos = randomPointInRect(-390, -310, -290, -210)
	local iceNode = createResourceNode("IceMiningNode" .. i, pos, "⛏️ Ice Ore", ResourceNodes)
	iceNode.Color = Color3.fromRGB(173, 216, 230)
	iceNode.Material = Enum.Material.Ice
end

for i = 1, 3 do
	local pos = randomPointInRect(-385, -315, -285, -215)
	local frozenTree = createResourceNode("FrozenTreeNode" .. i, pos, "🌲 Frozen Wood", ResourceNodes)
	frozenTree.Color = Color3.fromRGB(101, 67, 33)
	frozenTree.Material = Enum.Material.Wood
	frozenTree.Size = Vector3.new(2, 6, 2)
	frozenTree.Position = pos + Vector3.new(0, 3, 0)
end

-- Pirate Cove nodes
local coastalPositions = {{320, 0, -120}, {340, 0, -110}, {360, 0, -115}, {380, 0, -125}}
for i, pos in ipairs(coastalPositions) do
	local fishNode = createResourceNode("FishingSpot" .. i, Vector3.new(pos[1], pos[2], pos[3]), "🎣 Fishing", ResourceNodes)
	fishNode.Color = Color3.fromRGB(0, 162, 232)
	fishNode.Material = Enum.Material.Neon
	fishNode.Transparency = 0.3
	fishNode.Shape = Enum.PartType.Ball
end

for i = 1, 2 do
	local pos = randomPointInRect(315, 385, -185, -115)
	local palmNode = createResourceNode("PalmTreeNode" .. i, pos, "🌴 Palm Wood", ResourceNodes)
	palmNode.Color = Color3.fromRGB(101, 67, 33)
	palmNode.Material = Enum.Material.Wood
	palmNode.Size = Vector3.new(1.5, 8, 1.5)
	palmNode.Position = pos + Vector3.new(0, 4, 0)
end

-- Volcanic Crater nodes
for i = 1, 5 do
	local pos = randomPointInRect(315, 385, -385, -315)
	local obsidianNode = createResourceNode("ObsidianMiningNode" .. i, pos, "⛏️ Obsidian", ResourceNodes)
	obsidianNode.Color = Color3.fromRGB(20, 20, 20)
	obsidianNode.Material = Enum.Material.Glass
end

for i = 1, 3 do
	local pos = randomPointInRect(320, 380, -380, -320)
	local volcanicNode = createResourceNode("VolcanicOreMiningNode" .. i, pos, "⛏️ Volcanic Ore", ResourceNodes)
	volcanicNode.Color = Color3.fromRGB(255, 69, 0)
	volcanicNode.Material = Enum.Material.Neon
	volcanicNode.Transparency = 0.2
end

-- Enchanted Garden nodes
for i = 1, 4 do
	local pos = randomPointInRect(-290, -210, 210, 340)
	local magicTree = createResourceNode("MagicTreeNode" .. i, pos, "🌲 Magic Wood", ResourceNodes)
	magicTree.Color = Color3.fromRGB(139, 69, 19)
	magicTree.Material = Enum.Material.Wood
	magicTree.Size = Vector3.new(2, 8, 2)
	magicTree.Position = pos + Vector3.new(0, 4, 0)
	-- Add glow
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 215, 0)
	light.Brightness = 1
	light.Range = 6
	light.Parent = magicTree
end

for i = 1, 3 do
	local pos = randomPointInRect(-285, -215, 215, 335)
	local herbNode = createResourceNode("HerbGatheringNode" .. i, pos, "🌿 Magic Herbs", ResourceNodes)
	herbNode.Color = Color3.fromRGB(50, 205, 50)
	herbNode.Material = Enum.Material.Grass
	herbNode.Size = Vector3.new(3, 1, 3)
	herbNode.Position = pos + Vector3.new(0, 0.5, 0)
end

-- Underground Ruins nodes
for i = 1, 6 do
	local pos = randomPointInRect(-85, 35, -435, -365)
	local ancientNode = createResourceNode("AncientOreMiningNode" .. i, pos, "⛏️ Ancient Ore", ResourceNodes)
	ancientNode.Color = Color3.fromRGB(139, 134, 130)
	ancientNode.Material = Enum.Material.Slate
end

-- Dragon's Nest nodes
for i = 1, 3 do
	local pos = randomPointInRect(15, 85, -485, -465)
	local dragonstoneNode = createResourceNode("DragonstoneMiningNode" .. i, pos, "⛏️ Dragonstone", ResourceNodes)
	dragonstoneNode.Color = Color3.fromRGB(139, 0, 0)
	dragonstoneNode.Material = Enum.Material.Neon
	dragonstoneNode.Transparency = 0.1
	-- Add dramatic lighting
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 0, 0)
	light.Brightness = 2
	light.Range = 8
	light.Parent = dragonstoneNode
end

print("[MapSetup5] All major new areas completed!")
print("[MapSetup5] Areas built:")
print("- 🏴‍☠️ Pirate Cove (300-400, -200 to -100): Wrecked ship, treasure, palm trees")
print("- 🗻 Frozen Peaks (-400 to -300, -300 to -200): Ice crystals, frozen waterfall, snow trees")
print("- 🌋 Volcanic Crater (300-400, -400 to -300): Lava pools, obsidian spikes, fire geysers")
print("- 🌺 Enchanted Garden (-300 to -200, 200-350): Giant flowers, fairy rings, rainbow bridge")
print("- 🏛️ Underground Ruins (-100 to 50, -450 to -350): Ancient pillars, treasure vault, river")
print("- 🐉 Dragon's Nest (0-100, -500 to -450): Massive skeleton, egg nest, treasure hoard")
print("- Resource nodes added for all areas with appropriate types")