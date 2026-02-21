local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataManager = require(ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("DataManager", 5))

-- Create a BindableEvent for other scripts to signal equipment changes
local equipChanged = Instance.new("BindableEvent")
equipChanged.Name = "EquipmentChanged"
equipChanged.Parent = ReplicatedStorage

-- Also listen to the equip/unequip remotes directly
local equipItemEvent = ReplicatedStorage:FindFirstChild("EquipItem") or (ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("EquipItem"))
local unequipItemEvent = ReplicatedStorage:FindFirstChild("UnequipItem") or (ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("UnequipItem"))

if not equipItemEvent then
	equipItemEvent = ReplicatedStorage:WaitForChild("EquipItem", 15)
end
if not unequipItemEvent then
	unequipItemEvent = ReplicatedStorage:WaitForChild("UnequipItem", 15)
end

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function clearVisual(character, tag)
	for _, child in ipairs(character:GetChildren()) do
		if child.Name == tag then
			child:Destroy()
		end
	end
end

local function clearBodyColors(character, partNames)
	for _, name in ipairs(partNames) do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			local orig = part:FindFirstChild("_OriginalColor")
			if orig then
				part.Color = Color3.new(orig.Value.X, orig.Value.Y, orig.Value.Z)
			end
		end
	end
end

local function saveOriginalColor(part)
	if not part:FindFirstChild("_OriginalColor") then
		local v = Instance.new("Vector3Value")
		v.Name = "_OriginalColor"
		v.Value = Vector3.new(part.Color.R, part.Color.G, part.Color.B)
		v.Parent = part
	end
end

local function createAttachedPart(character, attachTo, tag, size, color, offset)
	clearVisual(character, tag)
	local limb = character:FindFirstChild(attachTo)
	if not limb then return nil end

	local part = Instance.new("Part")
	part.Name = tag
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.CanCollide = false
	part.Massless = true
	part.Anchored = false
	part.CFrame = limb.CFrame * offset
	part.Parent = character

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = limb
	weld.Part1 = part
	weld.Parent = part

	return part
end

-- Create a part welded to another part (not the limb directly)
local function createSubPart(parent, rootPart, name, size, color, offset, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.CanCollide = false
	part.Massless = true
	part.Anchored = false
	part.CFrame = rootPart.CFrame * offset
	part.Parent = parent

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = rootPart
	weld.Part1 = part
	weld.Parent = part

	return part
end

-- Create a multi-part model welded to a limb, tagged with tag
local function createModelOnLimb(character, attachTo, tag, builderFn, skipFlip)
	clearVisual(character, tag)
	local limb = character:FindFirstChild(attachTo)
	if not limb then return nil end

	local model = Instance.new("Model")
	model.Name = tag
	model.Parent = character

	local rootPart = builderFn(model, limb)
	if rootPart then
		if skipFlip then
			-- Helmets/shields: position directly on limb without weapon flip
			rootPart.CFrame = limb.CFrame * rootPart.CFrame
		else
			-- Weapons: Flip 180 on Z so blade points UP (away from hand), not down
			rootPart.CFrame = limb.CFrame * CFrame.Angles(0, 0, math.rad(180)) * rootPart.CFrame
		end
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = limb
		weld.Part1 = rootPart
		weld.Parent = rootPart
	end

	return model
end

-- Utility: add PointLight to a part
local function addGlow(part, color, brightness, range)
	local light = Instance.new("PointLight")
	light.Color = color or part.Color
	light.Brightness = brightness or 1.5
	light.Range = range or 8
	light.Parent = part
end

-- Utility: add fire effect
local function addFire(part, color, secondColor, size)
	local fire = Instance.new("Fire")
	fire.Color = color or Color3.fromRGB(255, 80, 20)
	fire.SecondaryColor = secondColor or Color3.fromRGB(255, 160, 40)
	fire.Size = size or 3
	fire.Heat = 5
	fire.Parent = part
end

-- Utility: add sparkle/particle
local function addSparkles(part, color)
	local sparkle = Instance.new("Sparkles")
	sparkle.SparkleColor = color or part.Color
	sparkle.Parent = part
end

--------------------------------------------------------------------------------
-- WEAPON BUILDERS (multi-part swords)
--------------------------------------------------------------------------------

local function buildCopperSword(model, limb)
	-- Handle at hand position, blade extends downward
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.18, 0.9, 0.18)
	handle.Color = Color3.fromRGB(90, 55, 20)
	handle.Material = Enum.Material.Wood
	handle.CanCollide = false
	handle.Massless = true
	handle.Anchored = false
	handle.CFrame = CFrame.new(0, 0, 0)
	handle.Parent = model

	-- Pommel (top of handle, above hand)
	local pommel = createSubPart(model, handle, "Pommel",
		Vector3.new(0.25, 0.2, 0.25), Color3.fromRGB(160, 90, 35),
		CFrame.new(0, 0.55, 0), Enum.Material.Metal)

	-- Crossguard (below hand)
	local guard = createSubPart(model, handle, "Crossguard",
		Vector3.new(0.7, 0.15, 0.25), Color3.fromRGB(160, 90, 35),
		CFrame.new(0, -0.5, 0), Enum.Material.Metal)

	-- Blade (extends down from crossguard)
	local blade = createSubPart(model, handle, "Blade",
		Vector3.new(0.22, 2.2, 0.1), Color3.fromRGB(190, 115, 50),
		CFrame.new(0, -1.7, 0), Enum.Material.Metal)
	blade.Reflectance = 0.15

	return handle
end

local function buildIronSword(model, limb)
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.18, 1.0, 0.18)
	handle.Color = Color3.fromRGB(70, 45, 20)
	handle.Material = Enum.Material.Fabric
	handle.CanCollide = false
	handle.Massless = true
	handle.Anchored = false
	handle.CFrame = CFrame.new(0, 0, 0)
	handle.Parent = model

	local pommel = createSubPart(model, handle, "Pommel",
		Vector3.new(0.28, 0.22, 0.28), Color3.fromRGB(140, 140, 150),
		CFrame.new(0, 0.6, 0), Enum.Material.Metal)

	local guard = createSubPart(model, handle, "Crossguard",
		Vector3.new(0.9, 0.16, 0.28), Color3.fromRGB(160, 160, 170),
		CFrame.new(0, -0.55, 0), Enum.Material.Metal)

	local blade = createSubPart(model, handle, "Blade",
		Vector3.new(0.28, 2.8, 0.1), Color3.fromRGB(190, 190, 200),
		CFrame.new(0, -2.0, 0), Enum.Material.Metal)
	blade.Reflectance = 0.25

	return handle
end

local function buildSteelSword(model, limb)
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.18, 1.0, 0.18)
	handle.Color = Color3.fromRGB(60, 40, 22)
	handle.Material = Enum.Material.Fabric
	handle.CanCollide = false
	handle.Massless = true
	handle.Anchored = false
	handle.CFrame = CFrame.new(0, 0, 0)
	handle.Parent = model

	local pommel = createSubPart(model, handle, "Pommel",
		Vector3.new(0.3, 0.22, 0.3), Color3.fromRGB(130, 130, 145),
		CFrame.new(0, 0.6, 0), Enum.Material.Metal)

	local guard = createSubPart(model, handle, "Crossguard",
		Vector3.new(1.0, 0.18, 0.3), Color3.fromRGB(140, 140, 155),
		CFrame.new(0, -0.55, 0), Enum.Material.Metal)

	local blade = createSubPart(model, handle, "Blade",
		Vector3.new(0.3, 3.0, 0.1), Color3.fromRGB(170, 170, 185),
		CFrame.new(0, -2.1, 0), Enum.Material.Metal)
	blade.Reflectance = 0.4

	-- Fuller (groove detail)
	local fuller = createSubPart(model, blade, "Fuller",
		Vector3.new(0.1, 2.4, 0.12), Color3.fromRGB(130, 130, 145),
		CFrame.new(0, 0.1, 0), Enum.Material.Metal)
	fuller.Reflectance = 0.2

	return handle
end

local function buildGoldSword(model, limb)
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.2, 1.0, 0.2)
	handle.Color = Color3.fromRGB(80, 40, 15)
	handle.Material = Enum.Material.Fabric
	handle.CanCollide = false
	handle.Massless = true
	handle.Anchored = false
	handle.CFrame = CFrame.new(0, 0, 0)
	handle.Parent = model

	-- Pommel with gem (above hand)
	local pommel = createSubPart(model, handle, "Pommel",
		Vector3.new(0.35, 0.25, 0.35), Color3.fromRGB(255, 200, 50),
		CFrame.new(0, 0.62, 0), Enum.Material.Metal)
	pommel.Reflectance = 0.3

	local gem = createSubPart(model, pommel, "Gem",
		Vector3.new(0.15, 0.15, 0.15), Color3.fromRGB(200, 20, 20),
		CFrame.new(0, 0.1, 0), Enum.Material.Neon)

	local guard = createSubPart(model, handle, "Crossguard",
		Vector3.new(1.2, 0.2, 0.32), Color3.fromRGB(255, 200, 50),
		CFrame.new(0, -0.55, 0), Enum.Material.Metal)
	guard.Reflectance = 0.3

	local blade = createSubPart(model, handle, "Blade",
		Vector3.new(0.32, 3.0, 0.12), Color3.fromRGB(255, 210, 70),
		CFrame.new(0, -2.1, 0), Enum.Material.Metal)
	blade.Reflectance = 0.35

	return handle
end

local function buildRuniteSword(model, limb)
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.2, 1.1, 0.2)
	handle.Color = Color3.fromRGB(30, 80, 80)
	handle.Material = Enum.Material.Fabric
	handle.CanCollide = false
	handle.Massless = true
	handle.Anchored = false
	handle.CFrame = CFrame.new(0, 0, 0)
	handle.Parent = model

	local pommel = createSubPart(model, handle, "Pommel",
		Vector3.new(0.32, 0.25, 0.32), Color3.fromRGB(0, 180, 180),
		CFrame.new(0, 0.65, 0), Enum.Material.Glass)
	pommel.Transparency = 0.3

	local guard = createSubPart(model, handle, "Crossguard",
		Vector3.new(1.1, 0.2, 0.3), Color3.fromRGB(0, 200, 200),
		CFrame.new(0, -0.6, 0), Enum.Material.Glass)
	guard.Transparency = 0.2

	local blade = createSubPart(model, handle, "Blade",
		Vector3.new(0.32, 3.2, 0.12), Color3.fromRGB(0, 210, 210),
		CFrame.new(0, -2.3, 0), Enum.Material.Glass)
	blade.Transparency = 0.15
	blade.Reflectance = 0.3
	addGlow(blade, Color3.fromRGB(0, 220, 220), 2, 12)
	addSparkles(blade, Color3.fromRGB(0, 255, 255))

	return handle
end

local function buildDragonSword(model, limb)
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.22, 1.2, 0.22)
	handle.Color = Color3.fromRGB(30, 10, 10)
	handle.Material = Enum.Material.Fabric
	handle.CanCollide = false
	handle.Massless = true
	handle.Anchored = false
	handle.CFrame = CFrame.new(0, 0, 0)
	handle.Parent = model

	local pommel = createSubPart(model, handle, "Pommel",
		Vector3.new(0.35, 0.28, 0.35), Color3.fromRGB(200, 30, 30),
		CFrame.new(0, 0.7, 0), Enum.Material.Metal)

	local guard = createSubPart(model, handle, "Crossguard",
		Vector3.new(1.3, 0.22, 0.35), Color3.fromRGB(180, 20, 20),
		CFrame.new(0, -0.65, 0), Enum.Material.Metal)

	-- Main blade (extends downward)
	local blade = createSubPart(model, handle, "Blade",
		Vector3.new(0.35, 3.6, 0.14), Color3.fromRGB(210, 30, 30),
		CFrame.new(0, -2.5, 0), Enum.Material.Metal)
	blade.Reflectance = 0.2

	-- Serrated edges (jagged shapes on both sides)
	for i = 0, 4 do
		local side = (i % 2 == 0) and 1 or -1
		local tooth = createSubPart(model, blade, "Serration" .. i,
			Vector3.new(0.15, 0.3, 0.14), Color3.fromRGB(60, 10, 10),
			CFrame.new(side * 0.2, 1.2 - i * 0.6, 0) * CFrame.Angles(0, 0, math.rad(side * 30)),
			Enum.Material.Metal)
	end

	addGlow(blade, Color3.fromRGB(255, 50, 20), 1.5, 10)
	addFire(blade, Color3.fromRGB(255, 50, 20), Color3.fromRGB(255, 140, 30), 2)

	return handle
end

local WEAPON_BUILDERS = {
	["Copper Sword"] = buildCopperSword,
	["Iron Sword"] = buildIronSword,
	["Steel Sword"] = buildSteelSword,
	["Gold Sword"] = buildGoldSword,
	["Runite Sword"] = buildRuniteSword,
	["Dragon Sword"] = buildDragonSword,
}

--------------------------------------------------------------------------------
-- BOW BUILDERS (attach to back)
--------------------------------------------------------------------------------

local function buildBow(model, limb, limbWidth, color, material, stringColor, stringGlow, height)
	-- Bow grip (center handle)
	local grip = Instance.new("Part")
	grip.Name = "BowGrip"
	grip.Size = Vector3.new(0.18, height * 0.25, 0.35)
	grip.Color = Color3.fromRGB(90, 55, 30) -- darker wood for grip
	grip.Material = Enum.Material.Wood
	grip.CanCollide = false
	grip.Massless = true
	grip.Anchored = false
	grip.CFrame = CFrame.new(0.6, 0, -0.5)
	grip.Parent = model

	-- Upper limb (curved outward)
	local upperLimb = createSubPart(model, grip, "UpperLimb",
		Vector3.new(0.15, height * 0.35, 0.18), color,
		CFrame.new(0, height * 0.3, -0.2) * CFrame.Angles(math.rad(-20), 0, 0),
		material or Enum.Material.Wood)

	-- Lower limb (curved outward)
	local lowerLimb = createSubPart(model, grip, "LowerLimb",
		Vector3.new(0.15, height * 0.35, 0.18), color,
		CFrame.new(0, -height * 0.3, -0.2) * CFrame.Angles(math.rad(20), 0, 0),
		material or Enum.Material.Wood)

	-- Upper limb tip (curves back)
	local upperTip = createSubPart(model, upperLimb, "UpperTip",
		Vector3.new(0.12, height * 0.15, 0.12), color,
		CFrame.new(0, height * 0.2, -0.1) * CFrame.Angles(math.rad(-10), 0, 0),
		material or Enum.Material.Wood)

	-- Lower limb tip (curves back)
	local lowerTip = createSubPart(model, lowerLimb, "LowerTip",
		Vector3.new(0.12, height * 0.15, 0.12), color,
		CFrame.new(0, -height * 0.2, -0.1) * CFrame.Angles(math.rad(10), 0, 0),
		material or Enum.Material.Wood)

	-- Bowstring (connects the tips)
	local str = createSubPart(model, grip, "String",
		Vector3.new(0.03, height * 0.9, 0.03), stringColor or Color3.fromRGB(200, 190, 170),
		CFrame.new(0, 0, -0.25), Enum.Material.Fabric)
	
	-- String nocks (small notches at bow tips)
	local upperNock = createSubPart(model, upperTip, "UpperNock",
		Vector3.new(0.08, 0.1, 0.08), Color3.fromRGB(160, 120, 80),
		CFrame.new(0, height * 0.08, -0.05), Enum.Material.Wood)
	local lowerNock = createSubPart(model, lowerTip, "LowerNock",
		Vector3.new(0.08, 0.1, 0.08), Color3.fromRGB(160, 120, 80),
		CFrame.new(0, -height * 0.08, -0.05), Enum.Material.Wood)

	if stringGlow then
		str.Material = Enum.Material.Neon
		addGlow(str, stringColor, 1, 6)
	end

	return grip
end

local BOW_BUILDERS = {
	["Oak Shortbow"] = function(model, limb)
		return buildBow(model, limb, 0, Color3.fromRGB(160, 120, 60), Enum.Material.Wood, nil, false, 2.5)
	end,
	["Willow Longbow"] = function(model, limb)
		return buildBow(model, limb, 0, Color3.fromRGB(140, 110, 50), Enum.Material.Wood, nil, false, 3.5)
	end,
	["Yew Longbow"] = function(model, limb)
		return buildBow(model, limb, 0, Color3.fromRGB(90, 55, 30), Enum.Material.Wood, nil, false, 3.8)
	end,
	["Magic Longbow"] = function(model, limb)
		return buildBow(model, limb, 0, Color3.fromRGB(100, 30, 140), Enum.Material.Wood,
			Color3.fromRGB(180, 80, 255), true, 4.0)
	end,
	["Dragon Crossbow"] = function(model, limb)
		-- Crossbow stock (main body)
		local stock = Instance.new("Part")
		stock.Name = "Stock"
		stock.Size = Vector3.new(0.25, 2.2, 0.4)
		stock.Color = Color3.fromRGB(80, 40, 20) -- dark wood
		stock.Material = Enum.Material.Wood
		stock.CanCollide = false
		stock.Massless = true
		stock.Anchored = false
		stock.CFrame = CFrame.new(0.6, 0, -0.5)
		stock.Parent = model

		-- Shoulder rest (buttstock)
		local buttstock = createSubPart(model, stock, "Buttstock",
			Vector3.new(0.4, 0.6, 0.5), Color3.fromRGB(70, 35, 15),
			CFrame.new(0, -0.8, -0.2), Enum.Material.Wood)

		-- Prod (horizontal crossbow limb)
		local prod = createSubPart(model, stock, "Prod",
			Vector3.new(2.4, 0.15, 0.3), Color3.fromRGB(180, 20, 20),
			CFrame.new(0, 1.0, -0.1), Enum.Material.Metal)

		-- Prod tips (reinforced ends)
		local prodTipL = createSubPart(model, prod, "ProdTipL",
			Vector3.new(0.2, 0.2, 0.35), Color3.fromRGB(160, 15, 15),
			CFrame.new(-1.1, 0, 0), Enum.Material.Metal)
		local prodTipR = createSubPart(model, prod, "ProdTipR",
			Vector3.new(0.2, 0.2, 0.35), Color3.fromRGB(160, 15, 15),
			CFrame.new(1.1, 0, 0), Enum.Material.Metal)

		-- String (connects the prod tips)
		local str = createSubPart(model, prod, "String",
			Vector3.new(2.0, 0.04, 0.04), Color3.fromRGB(100, 15, 15),
			CFrame.new(0, -0.05, 0.15), Enum.Material.Fabric)

		-- Trigger mechanism
		local trigger = createSubPart(model, stock, "Trigger",
			Vector3.new(0.15, 0.3, 0.2), Color3.fromRGB(50, 10, 10),
			CFrame.new(0, 0.3, 0.25), Enum.Material.Metal)

		-- Bolt rail (where bolt sits)
		local rail = createSubPart(model, stock, "BoltRail",
			Vector3.new(0.1, 1.5, 0.15), Color3.fromRGB(140, 130, 120),
			CFrame.new(0, 0.6, 0.18), Enum.Material.Metal)

		-- Stirrup (foot loop for cocking)
		local stirrup = createSubPart(model, stock, "Stirrup",
			Vector3.new(0.8, 0.08, 0.08), Color3.fromRGB(40, 8, 8),
			CFrame.new(0, 1.15, 0.1), Enum.Material.Metal)

		-- Dragon decorative elements
		local dragonHead = createSubPart(model, stock, "DragonHead",
			Vector3.new(0.3, 0.4, 0.3), Color3.fromRGB(200, 30, 30),
			CFrame.new(0, 0.8, 0.22), Enum.Material.Metal)
		
		-- Dragon eyes (glowing)
		local eyeL = createSubPart(model, dragonHead, "DragonEyeL",
			Vector3.new(0.08, 0.08, 0.08), Color3.fromRGB(255, 80, 20),
			CFrame.new(-0.08, 0.05, 0.12), Enum.Material.Neon)
		local eyeR = createSubPart(model, dragonHead, "DragonEyeR",
			Vector3.new(0.08, 0.08, 0.08), Color3.fromRGB(255, 80, 20),
			CFrame.new(0.08, 0.05, 0.12), Enum.Material.Neon)

		addGlow(dragonHead, Color3.fromRGB(255, 40, 20), 0.8, 5)

		return stock
	end,
}

--------------------------------------------------------------------------------
-- SHIELD BUILDERS
--------------------------------------------------------------------------------

local function buildWoodenShield(model, limb)
	-- Main round body (approximate with a slightly wider part)
	local body = Instance.new("Part")
	body.Name = "ShieldBody"
	body.Size = Vector3.new(0.25, 2.0, 1.8)
	body.Color = Color3.fromRGB(150, 100, 45)
	body.Material = Enum.Material.Wood
	body.CanCollide = false
	body.Massless = true
	body.Anchored = false
	body.CFrame = CFrame.new(-0.8, 0, 0)
	body.Parent = model

	-- Iron rim (top)
	local rimTop = createSubPart(model, body, "RimTop",
		Vector3.new(0.27, 0.12, 1.85), Color3.fromRGB(140, 140, 150),
		CFrame.new(0, 1.0, 0), Enum.Material.Metal)
	-- Iron rim (bottom)
	local rimBot = createSubPart(model, body, "RimBot",
		Vector3.new(0.27, 0.12, 1.85), Color3.fromRGB(140, 140, 150),
		CFrame.new(0, -1.0, 0), Enum.Material.Metal)

	-- Boss (center bump)
	local boss = createSubPart(model, body, "Boss",
		Vector3.new(0.3, 0.5, 0.5), Color3.fromRGB(130, 130, 140),
		CFrame.new(-0.15, 0, 0), Enum.Material.Metal)

	return body
end

local function buildIronShield(model, limb)
	-- Kite/heater shape - taller
	local body = Instance.new("Part")
	body.Name = "ShieldBody"
	body.Size = Vector3.new(0.22, 2.5, 1.7)
	body.Color = Color3.fromRGB(180, 180, 190)
	body.Material = Enum.Material.Metal
	body.CanCollide = false
	body.Massless = true
	body.Anchored = false
	body.CFrame = CFrame.new(-0.8, 0, 0)
	body.Parent = model
	body.Reflectance = 0.15

	-- Darker trim border (top and sides)
	local trim = createSubPart(model, body, "Trim",
		Vector3.new(0.24, 2.55, 1.75), Color3.fromRGB(100, 100, 110),
		CFrame.new(-0.02, 0, 0), Enum.Material.Metal)

	-- Boss
	local boss = createSubPart(model, body, "Boss",
		Vector3.new(0.3, 0.55, 0.55), Color3.fromRGB(160, 160, 170),
		CFrame.new(-0.15, 0, 0), Enum.Material.Metal)
	boss.Reflectance = 0.2

	return body
end

local function buildGoldShield(model, limb)
	local body = Instance.new("Part")
	body.Name = "ShieldBody"
	body.Size = Vector3.new(0.22, 2.5, 1.8)
	body.Color = Color3.fromRGB(255, 210, 60)
	body.Material = Enum.Material.Metal
	body.CanCollide = false
	body.Massless = true
	body.Anchored = false
	body.CFrame = CFrame.new(-0.8, 0, 0)
	body.Reflectance = 0.3
	body.Parent = model

	-- Golden trim
	local trim = createSubPart(model, body, "Trim",
		Vector3.new(0.24, 2.55, 1.85), Color3.fromRGB(200, 160, 30),
		CFrame.new(-0.02, 0, 0), Enum.Material.Metal)
	trim.Reflectance = 0.25

	-- Embossed cross pattern
	local cross1 = createSubPart(model, body, "Emboss1",
		Vector3.new(0.25, 2.0, 0.15), Color3.fromRGB(220, 175, 40),
		CFrame.new(-0.03, 0, 0), Enum.Material.Metal)
	local cross2 = createSubPart(model, body, "Emboss2",
		Vector3.new(0.25, 0.15, 1.3), Color3.fromRGB(220, 175, 40),
		CFrame.new(-0.03, 0, 0), Enum.Material.Metal)

	-- Boss with gem
	local boss = createSubPart(model, body, "Boss",
		Vector3.new(0.3, 0.5, 0.5), Color3.fromRGB(255, 220, 80),
		CFrame.new(-0.15, 0, 0), Enum.Material.Metal)
	boss.Reflectance = 0.35

	return body
end

local function buildRuniteShield(model, limb)
	local body = Instance.new("Part")
	body.Name = "ShieldBody"
	body.Size = Vector3.new(0.22, 2.6, 1.8)
	body.Color = Color3.fromRGB(0, 190, 190)
	body.Material = Enum.Material.Glass
	body.CanCollide = false
	body.Massless = true
	body.Anchored = false
	body.Transparency = 0.2
	body.CFrame = CFrame.new(-0.8, 0, 0)
	body.Parent = model

	local trim = createSubPart(model, body, "Trim",
		Vector3.new(0.24, 2.65, 1.85), Color3.fromRGB(0, 140, 140),
		CFrame.new(-0.02, 0, 0), Enum.Material.Glass)
	trim.Transparency = 0.4

	addGlow(body, Color3.fromRGB(0, 220, 220), 2, 10)
	addSparkles(body, Color3.fromRGB(0, 255, 255))

	return body
end

local function buildDragonShield(model, limb)
	local body = Instance.new("Part")
	body.Name = "ShieldBody"
	body.Size = Vector3.new(0.25, 2.7, 2.0)
	body.Color = Color3.fromRGB(200, 25, 25)
	body.Material = Enum.Material.Metal
	body.CanCollide = false
	body.Massless = true
	body.Anchored = false
	body.CFrame = CFrame.new(-0.8, 0, 0)
	body.Reflectance = 0.15
	body.Parent = model

	-- Black border
	local trim = createSubPart(model, body, "Trim",
		Vector3.new(0.27, 2.75, 2.05), Color3.fromRGB(30, 10, 10),
		CFrame.new(-0.02, 0, 0), Enum.Material.Metal)

	-- Spikes on edges
	for i = -1, 1, 1 do
		local spike = createSubPart(model, body, "Spike" .. i,
			Vector3.new(0.15, 0.5, 0.15), Color3.fromRGB(40, 10, 10),
			CFrame.new(-0.15, i * 0.9, 1.0) * CFrame.Angles(0, 0, math.rad(45)),
			Enum.Material.Metal)
		local spike2 = createSubPart(model, body, "SpikeR" .. i,
			Vector3.new(0.15, 0.5, 0.15), Color3.fromRGB(40, 10, 10),
			CFrame.new(-0.15, i * 0.9, -1.0) * CFrame.Angles(0, 0, math.rad(-45)),
			Enum.Material.Metal)
	end

	-- Dragon emblem (contrasting center piece)
	local emblem = createSubPart(model, body, "Emblem",
		Vector3.new(0.28, 1.0, 0.8), Color3.fromRGB(30, 10, 10),
		CFrame.new(-0.04, 0, 0), Enum.Material.Metal)

	addGlow(body, Color3.fromRGB(255, 40, 20), 1, 8)

	return body
end

local SHIELD_BUILDERS = {
	["Wooden Shield"] = buildWoodenShield,
	["Iron Shield"] = buildIronShield,
	["Gold Shield"] = buildGoldShield,
	["Runite Shield"] = buildRuniteShield,
	["Dragon Shield"] = buildDragonShield,
}

--------------------------------------------------------------------------------
-- HELMET BUILDERS
--------------------------------------------------------------------------------

local function buildBronzeHelmet(model, limb)
	local base = Instance.new("Part")
	base.Name = "HelmetBase"
	base.Size = Vector3.new(1.25, 0.7, 1.25)
	base.Color = Color3.fromRGB(170, 115, 55)
	base.Material = Enum.Material.Metal
	base.CanCollide = false
	base.Massless = true
	base.Anchored = false
	base.CFrame = CFrame.new(0, 0.85, 0)
	base.Parent = model

	-- Nose guard
	local nose = createSubPart(model, base, "NoseGuard",
		Vector3.new(0.1, 0.7, 0.12), Color3.fromRGB(160, 105, 45),
		CFrame.new(0, -0.5, -0.6), Enum.Material.Metal)

	return base
end

local function buildIronHelmet(model, limb)
	local base = Instance.new("Part")
	base.Name = "HelmetBase"
	base.Size = Vector3.new(1.3, 0.8, 1.3)
	base.Color = Color3.fromRGB(180, 180, 190)
	base.Material = Enum.Material.Metal
	base.CanCollide = false
	base.Massless = true
	base.Anchored = false
	base.CFrame = CFrame.new(0, 0.85, 0)
	base.Reflectance = 0.15
	base.Parent = model

	-- Cheek guards
	local cheekL = createSubPart(model, base, "CheekL",
		Vector3.new(0.15, 0.6, 0.5), Color3.fromRGB(165, 165, 175),
		CFrame.new(-0.65, -0.45, -0.2), Enum.Material.Metal)
	local cheekR = createSubPart(model, base, "CheekR",
		Vector3.new(0.15, 0.6, 0.5), Color3.fromRGB(165, 165, 175),
		CFrame.new(0.65, -0.45, -0.2), Enum.Material.Metal)

	-- Nose guard
	local nose = createSubPart(model, base, "NoseGuard",
		Vector3.new(0.1, 0.5, 0.12), Color3.fromRGB(170, 170, 180),
		CFrame.new(0, -0.45, -0.6), Enum.Material.Metal)

	return base
end

local function buildGoldHelmet(model, limb)
	local base = Instance.new("Part")
	base.Name = "HelmetBase"
	base.Size = Vector3.new(1.3, 0.6, 1.3)
	base.Color = Color3.fromRGB(255, 205, 55)
	base.Material = Enum.Material.Metal
	base.CanCollide = false
	base.Massless = true
	base.Anchored = false
	base.CFrame = CFrame.new(0, 0.82, 0)
	base.Reflectance = 0.3
	base.Parent = model

	-- Crown points
	for i = 0, 4 do
		local angle = math.rad(i * 72)
		local px = math.cos(angle) * 0.5
		local pz = math.sin(angle) * 0.5
		local point = createSubPart(model, base, "Crown" .. i,
			Vector3.new(0.15, 0.4, 0.15), Color3.fromRGB(255, 210, 60),
			CFrame.new(px, 0.45, pz), Enum.Material.Metal)
		point.Reflectance = 0.3
	end

	-- Gem in front
	local gem = createSubPart(model, base, "Gem",
		Vector3.new(0.18, 0.18, 0.18), Color3.fromRGB(200, 20, 20),
		CFrame.new(0, 0.15, -0.65), Enum.Material.Neon)

	return base
end

local function buildRuniteHelmet(model, limb)
	local base = Instance.new("Part")
	base.Name = "HelmetBase"
	base.Size = Vector3.new(1.35, 0.9, 1.35)
	base.Color = Color3.fromRGB(0, 185, 185)
	base.Material = Enum.Material.Glass
	base.CanCollide = false
	base.Massless = true
	base.Anchored = false
	base.Transparency = 0.15
	base.CFrame = CFrame.new(0, 0.85, 0)
	base.Parent = model

	-- Full face plate
	local face = createSubPart(model, base, "FacePlate",
		Vector3.new(1.1, 0.8, 0.12), Color3.fromRGB(0, 160, 160),
		CFrame.new(0, -0.3, -0.65), Enum.Material.Glass)
	face.Transparency = 0.3

	-- Visor slit (glowing)
	local visor = createSubPart(model, face, "Visor",
		Vector3.new(0.8, 0.1, 0.14), Color3.fromRGB(0, 255, 255),
		CFrame.new(0, 0.1, -0.02), Enum.Material.Neon)
	addGlow(visor, Color3.fromRGB(0, 255, 255), 2, 8)

	return base
end

local function buildDragonHelmet(model, limb)
	local base = Instance.new("Part")
	base.Name = "HelmetBase"
	base.Size = Vector3.new(1.35, 0.9, 1.35)
	base.Color = Color3.fromRGB(200, 25, 25)
	base.Material = Enum.Material.Metal
	base.CanCollide = false
	base.Massless = true
	base.Anchored = false
	base.CFrame = CFrame.new(0, 0.85, 0)
	base.Reflectance = 0.1
	base.Parent = model

	-- Face plate
	local face = createSubPart(model, base, "FacePlate",
		Vector3.new(1.15, 0.85, 0.12), Color3.fromRGB(40, 10, 10),
		CFrame.new(0, -0.3, -0.65), Enum.Material.Metal)

	-- Menacing visor slit
	local visor = createSubPart(model, face, "Visor",
		Vector3.new(0.85, 0.08, 0.14), Color3.fromRGB(255, 40, 20),
		CFrame.new(0, 0.1, -0.02), Enum.Material.Neon)
	addGlow(visor, Color3.fromRGB(255, 40, 20), 1.5, 6)

	-- Horns
	local hornL = createSubPart(model, base, "HornL",
		Vector3.new(0.15, 0.8, 0.15), Color3.fromRGB(50, 10, 10),
		CFrame.new(-0.5, 0.6, -0.2) * CFrame.Angles(math.rad(-20), 0, math.rad(-25)),
		Enum.Material.Metal)
	local hornR = createSubPart(model, base, "HornR",
		Vector3.new(0.15, 0.8, 0.15), Color3.fromRGB(50, 10, 10),
		CFrame.new(0.5, 0.6, -0.2) * CFrame.Angles(math.rad(-20), 0, math.rad(25)),
		Enum.Material.Metal)

	return base
end

local HELMET_BUILDERS = {
	["Bronze Helmet"] = buildBronzeHelmet,
	["Iron Helmet"] = buildIronHelmet,
	["Gold Helmet"] = buildGoldHelmet,
	["Runite Helmet"] = buildRuniteHelmet,
	["Dragon Helmet"] = buildDragonHelmet,
}

--------------------------------------------------------------------------------
-- BODY ARMOR VISUALS (color + overlay parts)
--------------------------------------------------------------------------------

local BODY_VISUALS = {
	["Goblin Mail"] = { color = Color3.fromRGB(50, 100, 40) },
	["Wizard Robe"] = { color = Color3.fromRGB(120, 40, 160) },
	["Iron Platebody"] = { color = Color3.fromRGB(180, 180, 190) },
	["Gold Platebody"] = { color = Color3.fromRGB(255, 200, 50) },
	["Runite Platebody"] = { color = Color3.fromRGB(0, 180, 180) },
	["Dragon Platebody"] = { color = Color3.fromRGB(200, 30, 30) },
}

-- Overlay builders for body armor (create extra parts on torso)
local function buildBodyOverlay(character, bodyName)
	clearVisual(character, "VisualEquip_BodyOverlay")
	local torsoName = character:FindFirstChild("UpperTorso") and "UpperTorso" or "Torso"
	local torso = character:FindFirstChild(torsoName)
	if not torso then return end

	local model = Instance.new("Model")
	model.Name = "VisualEquip_BodyOverlay"
	model.Parent = character

	if bodyName == "Goblin Mail" then
		-- Chain mail overlay with tattered bottom
		local chain = Instance.new("Part")
		chain.Name = "ChainBody"
		chain.Size = Vector3.new(2.05, 1.6, 1.05)
		chain.Color = Color3.fromRGB(60, 110, 45)
		chain.Material = Enum.Material.Fabric
		chain.Transparency = 0.1
		chain.CanCollide = false
		chain.Massless = true
		chain.Anchored = false
		chain.CFrame = torso.CFrame * CFrame.new(0, -0.1, 0)
		chain.Parent = model
		local w = Instance.new("WeldConstraint")
		w.Part0 = torso
		w.Part1 = chain
		w.Parent = chain

		-- Tattered bottom strip
		local tatter = createSubPart(model, chain, "Tatter",
			Vector3.new(1.8, 0.3, 0.9), Color3.fromRGB(45, 85, 35),
			CFrame.new(0, -0.9, 0), Enum.Material.Fabric)

	elseif bodyName == "Wizard Robe" then
		local robe = Instance.new("Part")
		robe.Name = "RobeBody"
		robe.Size = Vector3.new(2.1, 1.65, 1.1)
		robe.Color = Color3.fromRGB(120, 40, 160)
		robe.Material = Enum.Material.Fabric
		robe.CanCollide = false
		robe.Massless = true
		robe.Anchored = false
		robe.CFrame = torso.CFrame * CFrame.new(0, -0.1, 0)
		robe.Parent = model
		local w = Instance.new("WeldConstraint")
		w.Part0 = torso
		w.Part1 = robe
		w.Parent = robe

		-- Gold trim line
		local trimFront = createSubPart(model, robe, "TrimFront",
			Vector3.new(0.08, 1.6, 0.08), Color3.fromRGB(255, 200, 50),
			CFrame.new(0, 0, -0.55), Enum.Material.Neon)
		local trimBottom = createSubPart(model, robe, "TrimBottom",
			Vector3.new(2.0, 0.06, 1.0), Color3.fromRGB(255, 200, 50),
			CFrame.new(0, -0.8, 0), Enum.Material.Neon)

		-- Hood piece on head
		local head = character:FindFirstChild("Head")
		if head then
			local hood = Instance.new("Part")
			hood.Name = "VisualEquip_BodyOverlay"
			hood.Size = Vector3.new(1.4, 0.8, 1.4)
			hood.Color = Color3.fromRGB(110, 35, 145)
			hood.Material = Enum.Material.Fabric
			hood.CanCollide = false
			hood.Massless = true
			hood.Anchored = false
			hood.CFrame = head.CFrame * CFrame.new(0, 0.5, 0.1)
			hood.Parent = character  -- separate part, same tag for cleanup
			local hw = Instance.new("WeldConstraint")
			hw.Part0 = head
			hw.Part1 = hood
			hw.Parent = hood
		end

	elseif bodyName == "Iron Platebody" then
		local plate = Instance.new("Part")
		plate.Name = "PlateBody"
		plate.Size = Vector3.new(2.08, 1.65, 1.08)
		plate.Color = Color3.fromRGB(185, 185, 195)
		plate.Material = Enum.Material.Metal
		plate.Reflectance = 0.2
		plate.CanCollide = false
		plate.Massless = true
		plate.Anchored = false
		plate.CFrame = torso.CFrame
		plate.Parent = model
		local w = Instance.new("WeldConstraint")
		w.Part0 = torso
		w.Part1 = plate
		w.Parent = plate

		-- Shoulder pads
		local shoulderL = createSubPart(model, plate, "ShoulderL",
			Vector3.new(0.6, 0.3, 0.8), Color3.fromRGB(170, 170, 180),
			CFrame.new(-1.1, 0.7, 0), Enum.Material.Metal)
		local shoulderR = createSubPart(model, plate, "ShoulderR",
			Vector3.new(0.6, 0.3, 0.8), Color3.fromRGB(170, 170, 180),
			CFrame.new(1.1, 0.7, 0), Enum.Material.Metal)

	elseif bodyName == "Gold Platebody" then
		local plate = Instance.new("Part")
		plate.Name = "PlateBody"
		plate.Size = Vector3.new(2.08, 1.65, 1.08)
		plate.Color = Color3.fromRGB(255, 210, 60)
		plate.Material = Enum.Material.Metal
		plate.Reflectance = 0.3
		plate.CanCollide = false
		plate.Massless = true
		plate.Anchored = false
		plate.CFrame = torso.CFrame
		plate.Parent = model
		local w = Instance.new("WeldConstraint")
		w.Part0 = torso
		w.Part1 = plate
		w.Parent = plate

		local shoulderL = createSubPart(model, plate, "ShoulderL",
			Vector3.new(0.65, 0.35, 0.85), Color3.fromRGB(240, 190, 40),
			CFrame.new(-1.1, 0.7, 0), Enum.Material.Metal)
		shoulderL.Reflectance = 0.3
		local shoulderR = createSubPart(model, plate, "ShoulderR",
			Vector3.new(0.65, 0.35, 0.85), Color3.fromRGB(240, 190, 40),
			CFrame.new(1.1, 0.7, 0), Enum.Material.Metal)
		shoulderR.Reflectance = 0.3

		-- Chest emblem
		local emblem = createSubPart(model, plate, "Emblem",
			Vector3.new(0.1, 0.5, 0.5), Color3.fromRGB(200, 155, 25),
			CFrame.new(0, 0.1, -0.55), Enum.Material.Metal)

	elseif bodyName == "Runite Platebody" then
		local plate = Instance.new("Part")
		plate.Name = "PlateBody"
		plate.Size = Vector3.new(2.1, 1.68, 1.1)
		plate.Color = Color3.fromRGB(0, 190, 190)
		plate.Material = Enum.Material.Glass
		plate.Transparency = 0.15
		plate.CanCollide = false
		plate.Massless = true
		plate.Anchored = false
		plate.CFrame = torso.CFrame
		plate.Parent = model
		local w = Instance.new("WeldConstraint")
		w.Part0 = torso
		w.Part1 = plate
		w.Parent = plate
		addGlow(plate, Color3.fromRGB(0, 220, 220), 1, 8)

		local shoulderL = createSubPart(model, plate, "ShoulderL",
			Vector3.new(0.65, 0.35, 0.85), Color3.fromRGB(0, 160, 160),
			CFrame.new(-1.1, 0.7, 0), Enum.Material.Glass)
		shoulderL.Transparency = 0.2
		local shoulderR = createSubPart(model, plate, "ShoulderR",
			Vector3.new(0.65, 0.35, 0.85), Color3.fromRGB(0, 160, 160),
			CFrame.new(1.1, 0.7, 0), Enum.Material.Glass)
		shoulderR.Transparency = 0.2

	elseif bodyName == "Dragon Platebody" then
		local plate = Instance.new("Part")
		plate.Name = "PlateBody"
		plate.Size = Vector3.new(2.12, 1.7, 1.12)
		plate.Color = Color3.fromRGB(200, 25, 25)
		plate.Material = Enum.Material.Metal
		plate.Reflectance = 0.15
		plate.CanCollide = false
		plate.Massless = true
		plate.Anchored = false
		plate.CFrame = torso.CFrame
		plate.Parent = model
		local w = Instance.new("WeldConstraint")
		w.Part0 = torso
		w.Part1 = plate
		w.Parent = plate

		-- Black trim
		local trimBottom = createSubPart(model, plate, "TrimBottom",
			Vector3.new(2.15, 0.1, 1.15), Color3.fromRGB(30, 10, 10),
			CFrame.new(0, -0.82, 0), Enum.Material.Metal)

		-- Spiked shoulders
		local shoulderL = createSubPart(model, plate, "ShoulderL",
			Vector3.new(0.7, 0.4, 0.9), Color3.fromRGB(180, 20, 20),
			CFrame.new(-1.1, 0.7, 0), Enum.Material.Metal)
		local spikeL = createSubPart(model, shoulderL, "SpikeL",
			Vector3.new(0.15, 0.5, 0.15), Color3.fromRGB(40, 10, 10),
			CFrame.new(0, 0.35, 0), Enum.Material.Metal)
		local shoulderR = createSubPart(model, plate, "ShoulderR",
			Vector3.new(0.7, 0.4, 0.9), Color3.fromRGB(180, 20, 20),
			CFrame.new(1.1, 0.7, 0), Enum.Material.Metal)
		local spikeR = createSubPart(model, shoulderR, "SpikeR",
			Vector3.new(0.15, 0.5, 0.15), Color3.fromRGB(40, 10, 10),
			CFrame.new(0, 0.35, 0), Enum.Material.Metal)

		addGlow(plate, Color3.fromRGB(255, 40, 20), 0.8, 6)
	end
end

--------------------------------------------------------------------------------
-- LEGS VISUALS
--------------------------------------------------------------------------------

local LEGS_VISUALS = {
	["Iron Legs"] = { color = Color3.fromRGB(180, 180, 190) },
	["Gold Legs"] = { color = Color3.fromRGB(255, 200, 50) },
	["Runite Legs"] = { color = Color3.fromRGB(0, 180, 180) },
	["Dragon Legs"] = { color = Color3.fromRGB(200, 30, 30) },
}

--------------------------------------------------------------------------------
-- TOOL BUILDERS (pickaxes, axes, fishing rods)
--------------------------------------------------------------------------------

local TOOL_TIER_COLORS = {
	["Copper"] = Color3.fromRGB(180, 100, 40),
	["Iron"] = Color3.fromRGB(180, 180, 190),
	["Steel"] = Color3.fromRGB(140, 140, 155),
	["Gold"] = Color3.fromRGB(255, 200, 50),
	["Runite"] = Color3.fromRGB(0, 180, 180),
	["Dragon"] = Color3.fromRGB(200, 30, 30),
}

local function getToolTierColor(toolName)
	for tier, col in pairs(TOOL_TIER_COLORS) do
		if string.find(toolName, tier) then
			return col
		end
	end
	return Color3.fromRGB(140, 100, 50)
end

local function buildPickaxe(model, limb, toolName)
	local tierColor = getToolTierColor(toolName)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.2, 2.8, 0.2)
	handle.Color = Color3.fromRGB(120, 80, 35)
	handle.Material = Enum.Material.Wood
	handle.CanCollide = false
	handle.Massless = true
	handle.Anchored = false
	handle.CFrame = CFrame.new(0.7, 0, 0.5) * CFrame.Angles(0, 0, math.rad(30))
	handle.Parent = model

	-- Pickaxe head (wedge-like)
	local head = createSubPart(model, handle, "PickHead",
		Vector3.new(0.15, 0.3, 1.2), tierColor,
		CFrame.new(0, 1.3, 0.3), Enum.Material.Metal)
	head.Reflectance = 0.15

	-- Back spike
	local spike = createSubPart(model, handle, "BackSpike",
		Vector3.new(0.12, 0.2, 0.6), tierColor,
		CFrame.new(0, 1.3, -0.3), Enum.Material.Metal)

	if string.find(toolName, "Runite") then addGlow(head, tierColor, 1, 5) end
	if string.find(toolName, "Dragon") then addGlow(head, tierColor, 0.8, 4) end

	return handle
end

local function buildAxe(model, limb, toolName)
	local tierColor = getToolTierColor(toolName)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.2, 2.5, 0.2)
	handle.Color = Color3.fromRGB(120, 80, 35)
	handle.Material = Enum.Material.Wood
	handle.CanCollide = false
	handle.Massless = true
	handle.Anchored = false
	handle.CFrame = CFrame.new(0.7, 0, 0.5) * CFrame.Angles(0, 0, math.rad(30))
	handle.Parent = model

	-- Axe head (flat blade)
	local head = createSubPart(model, handle, "AxeHead",
		Vector3.new(0.12, 0.8, 0.9), tierColor,
		CFrame.new(0, 1.1, 0.35), Enum.Material.Metal)
	head.Reflectance = 0.15

	if string.find(toolName, "Runite") then addGlow(head, tierColor, 1, 5) end
	if string.find(toolName, "Dragon") then addGlow(head, tierColor, 0.8, 4) end

	return handle
end

local function buildFishingRod(model, limb, toolName)
	local tierColor = getToolTierColor(toolName)

	local rod = Instance.new("Part")
	rod.Name = "Rod"
	rod.Size = Vector3.new(0.1, 3.5, 0.1)
	rod.Color = tierColor
	rod.Material = Enum.Material.Wood
	rod.CanCollide = false
	rod.Massless = true
	rod.Anchored = false
	rod.CFrame = CFrame.new(0.7, 0.3, 0.5) * CFrame.Angles(0, 0, math.rad(15))
	rod.Parent = model

	-- Reel
	local reel = createSubPart(model, rod, "Reel",
		Vector3.new(0.2, 0.25, 0.25), Color3.fromRGB(100, 100, 110),
		CFrame.new(0.1, -1.0, 0), Enum.Material.Metal)

	-- Fishing line (thin neon)
	local line = createSubPart(model, rod, "Line",
		Vector3.new(0.03, 1.2, 0.03), Color3.fromRGB(220, 220, 230),
		CFrame.new(0, 2.2, 0), Enum.Material.Neon)

	return rod
end

local function buildTool(character, toolName)
	clearVisual(character, "VisualEquip_Tool")
	local torsoName = character:FindFirstChild("UpperTorso") and "UpperTorso" or "Torso"
	local torso = character:FindFirstChild(torsoName)
	if not torso then return end

	local model = Instance.new("Model")
	model.Name = "VisualEquip_Tool"
	model.Parent = character

	local rootPart
	if string.find(toolName, "Pickaxe") or string.find(toolName, "pickaxe") then
		rootPart = buildPickaxe(model, torso, toolName)
	elseif string.find(toolName, "Axe") or string.find(toolName, "axe") then
		rootPart = buildAxe(model, torso, toolName)
	elseif string.find(toolName, "Rod") or string.find(toolName, "rod") or string.find(toolName, "Fishing") then
		rootPart = buildFishingRod(model, torso, toolName)
	else
		-- Generic tool (stick)
		rootPart = Instance.new("Part")
		rootPart.Name = "ToolGeneric"
		rootPart.Size = Vector3.new(0.25, 2.5, 0.25)
		rootPart.Color = getToolTierColor(toolName)
		rootPart.Material = Enum.Material.Wood
		rootPart.CanCollide = false
		rootPart.Massless = true
		rootPart.Anchored = false
		rootPart.CFrame = CFrame.new(0.7, 0, 0.5) * CFrame.Angles(0, 0, math.rad(30))
		rootPart.Parent = model
	end

	if rootPart then
		rootPart.CFrame = torso.CFrame * rootPart.CFrame
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = torso
		weld.Part1 = rootPart
		weld.Parent = rootPart
	end
end

--------------------------------------------------------------------------------
-- Apply visuals for a single player
--------------------------------------------------------------------------------

local function applyVisuals(player)
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	local data = DataManager:GetData(player)
	if not data or not data.Equipment then return end

	local equip = data.Equipment

	-- WEAPON (Right Arm / RightHand) or BOW (back)
	local weaponName = equip.Weapon
	clearVisual(character, "VisualEquip_Weapon")
	if weaponName and weaponName ~= "" then
		local builder = WEAPON_BUILDERS[weaponName]
		local bowBuilder = BOW_BUILDERS[weaponName]

		if builder then
			-- Multi-part sword
			local attachTo = character:FindFirstChild("RightHand") and "RightHand" or "Right Arm"
			createModelOnLimb(character, attachTo, "VisualEquip_Weapon", function(model, limb)
				return builder(model, limb)
			end)
			print("[VisualEquip] Weapon attached: " .. weaponName .. " to " .. attachTo)
		elseif bowBuilder then
			-- Bows go on back
			local attachTo = character:FindFirstChild("UpperTorso") and "UpperTorso" or "Torso"
			createModelOnLimb(character, attachTo, "VisualEquip_Weapon", function(model, limb)
				return bowBuilder(model, limb)
			end)
			print("[VisualEquip] Bow attached: " .. weaponName .. " to back")
		else
			-- Fallback: basic blade
			local attachTo = character:FindFirstChild("RightHand") and "RightHand" or "Right Arm"
			local offset = CFrame.new(0, -2.0, 0)
			local part = createAttachedPart(character, attachTo, "VisualEquip_Weapon",
				Vector3.new(0.3, 3, 0.15), Color3.fromRGB(180, 180, 180), offset)
			if part then
				part.Material = Enum.Material.Metal
			end
		end
	end

	-- HEAD
	local headName = equip.Head
	clearVisual(character, "VisualEquip_Head")
	if headName and headName ~= "" then
		local builder = HELMET_BUILDERS[headName]
		if builder then
			createModelOnLimb(character, "Head", "VisualEquip_Head", function(model, limb)
				return builder(model, limb)
			end, true)
		else
			-- Fallback: simple block
			local offset = CFrame.new(0, 0.8, 0)
			createAttachedPart(character, "Head", "VisualEquip_Head",
				Vector3.new(1.3, 0.8, 1.3), Color3.fromRGB(180, 180, 180), offset)
		end
	end

	-- BODY (color torso + overlay parts)
	local torsoName = character:FindFirstChild("UpperTorso") and "UpperTorso" or "Torso"
	local lowerTorso = character:FindFirstChild("LowerTorso")
	local bodyParts = { torsoName }
	if lowerTorso then table.insert(bodyParts, "LowerTorso") end

	local bodyName = equip.Body
	clearBodyColors(character, bodyParts)
	clearVisual(character, "VisualEquip_BodyOverlay")
	if bodyName and bodyName ~= "" then
		local vis = BODY_VISUALS[bodyName]
		if vis then
			for _, pName in ipairs(bodyParts) do
				local part = character:FindFirstChild(pName)
				if part and part:IsA("BasePart") then
					saveOriginalColor(part)
					part.Color = vis.color
				end
			end
		end
		-- Build overlay parts
		buildBodyOverlay(character, bodyName)
	end

	-- LEGS (color legs)
	local legParts = {}
	for _, name in ipairs({"Left Leg", "Right Leg", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot"}) do
		if character:FindFirstChild(name) then
			table.insert(legParts, name)
		end
	end

	local legsName = equip.Legs
	clearBodyColors(character, legParts)
	if legsName and LEGS_VISUALS[legsName] then
		local vis = LEGS_VISUALS[legsName]
		for _, pName in ipairs(legParts) do
			local part = character:FindFirstChild(pName)
			if part and part:IsA("BasePart") then
				saveOriginalColor(part)
				part.Color = vis.color
			end
		end
	end

	-- SHIELD (Left Arm)
	local shieldName = equip.Shield
	clearVisual(character, "VisualEquip_Shield")
	if shieldName and shieldName ~= "" then
		local builder = SHIELD_BUILDERS[shieldName]
		if builder then
			local attachTo = character:FindFirstChild("LeftHand") and "LeftLowerArm" or "Left Arm"
			createModelOnLimb(character, attachTo, "VisualEquip_Shield", function(model, limb)
				return builder(model, limb)
			end, true)
		else
			-- Fallback
			local attachTo = character:FindFirstChild("LeftHand") and "LeftLowerArm" or "Left Arm"
			local offset = CFrame.new(-0.8, 0, 0)
			createAttachedPart(character, attachTo, "VisualEquip_Shield",
				Vector3.new(0.3, 2.2, 1.6), Color3.fromRGB(140, 90, 40), offset)
		end
	end

	-- TOOL (visual on back)
	local toolName = equip.Tool
	clearVisual(character, "VisualEquip_Tool")
	if toolName and toolName ~= "" then
		buildTool(character, toolName)
	end

	print("[VisualEquip] Applied visuals for " .. player.Name .. " | Weapon=" .. tostring(equip.Weapon) .. " Head=" .. tostring(equip.Head) .. " Shield=" .. tostring(equip.Shield))
end

--------------------------------------------------------------------------------
-- Connections
--------------------------------------------------------------------------------

local function setupPlayer(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid", 5)
		task.wait(0.5)
		applyVisuals(player)
	end)

	if player.Character then
		applyVisuals(player)
	end
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

equipChanged.Event:Connect(function(player)
	if player and player:IsA("Player") then
		task.wait(0.1)
		applyVisuals(player)
	end
end)

if equipItemEvent then
	equipItemEvent.OnServerEvent:Connect(function(player)
		task.wait(0.2)
		applyVisuals(player)
	end)
end

if unequipItemEvent then
	unequipItemEvent.OnServerEvent:Connect(function(player)
		task.wait(0.2)
		applyVisuals(player)
	end)
end
