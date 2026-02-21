--[[
	MonsterDatabase.lua
	ModuleScript - ReplicatedStorage/Modules/MonsterDatabase

	Central registry of all monster definitions, drop tables, and visual configs.
	Drop items use DISPLAY NAMES (matching ItemDatabase keys).
]]

local MonsterDatabase = {}

MonsterDatabase.Monsters = {

	----------------------------------------------------------------------------
	-- SAFE ZONE
	----------------------------------------------------------------------------

	Chicken = {
		name        = "Chicken",
		hp          = 50,
		damage      = 3,
		level       = 1,
		xp          = 5,
		respawnTime = 15,
		zone        = "Safe",
		passive     = true,
		drops = {
			{ item = "Feather",      chance = 1.00, minQty = 1, maxQty = 2 },
			{ item = "Raw Chicken",  chance = 0.80, minQty = 1, maxQty = 1 },
		},
		model = {
			bodyColor = Color3.fromRGB(255, 250, 240),
			size = Vector3.new(1.5, 1.2, 2),
			headSize = 0.6,
			extras = {
				-- Original parts
				{ name = "Comb", shape = "Block", size = Vector3.new(0.3, 0.5, 0.6), offset = Vector3.new(0, 0.5, 0.3), color = Color3.fromRGB(220, 30, 30) },
				{ name = "Beak", shape = "Block", size = Vector3.new(0.3, 0.2, 0.5), offset = Vector3.new(0, 0, 0.6), color = Color3.fromRGB(255, 180, 50) },
				{ name = "LegL", shape = "Block", size = Vector3.new(0.2, 1, 0.2), offset = Vector3.new(-0.4, -1.1, 0), color = Color3.fromRGB(255, 180, 50), bodyRelative = true },
				{ name = "LegR", shape = "Block", size = Vector3.new(0.2, 1, 0.2), offset = Vector3.new(0.4, -1.1, 0), color = Color3.fromRGB(255, 180, 50), bodyRelative = true },
				{ name = "Tail", shape = "Block", size = Vector3.new(0.3, 1, 0.8), offset = Vector3.new(0, 0.3, -1.2), color = Color3.fromRGB(255, 250, 240), bodyRelative = true },
				-- Eyes
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.12, 0.12, 0.12), offset = Vector3.new(-0.18, 0.12, 0.32), color = Color3.fromRGB(20, 20, 20) },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.12, 0.12, 0.12), offset = Vector3.new(0.18, 0.12, 0.32), color = Color3.fromRGB(20, 20, 20) },
				-- Wattle under beak
				{ name = "Wattle", shape = "Block", size = Vector3.new(0.15, 0.3, 0.15), offset = Vector3.new(0, -0.25, 0.55), color = Color3.fromRGB(220, 30, 30) },
				-- Wing left
				{ name = "WingL", shape = "Block", size = Vector3.new(0.15, 0.7, 1.2), offset = Vector3.new(-0.85, 0.1, -0.1), color = Color3.fromRGB(245, 238, 220), bodyRelative = true },
				-- Wing right
				{ name = "WingR", shape = "Block", size = Vector3.new(0.15, 0.7, 1.2), offset = Vector3.new(0.85, 0.1, -0.1), color = Color3.fromRGB(245, 238, 220), bodyRelative = true },
				-- Wing tips (darker feathers)
				{ name = "WingTipL", shape = "Block", size = Vector3.new(0.1, 0.4, 0.6), offset = Vector3.new(-0.95, -0.15, -0.6), color = Color3.fromRGB(200, 190, 170), bodyRelative = true },
				{ name = "WingTipR", shape = "Block", size = Vector3.new(0.1, 0.4, 0.6), offset = Vector3.new(0.95, -0.15, -0.6), color = Color3.fromRGB(200, 190, 170), bodyRelative = true },
				-- Tail feather fan
				{ name = "TailFan1", shape = "Block", size = Vector3.new(0.5, 0.8, 0.1), offset = Vector3.new(0, 0.5, -1.4), color = Color3.fromRGB(240, 235, 215), bodyRelative = true },
				{ name = "TailFan2", shape = "Block", size = Vector3.new(0.4, 0.6, 0.1), offset = Vector3.new(-0.2, 0.6, -1.3), color = Color3.fromRGB(230, 225, 205), bodyRelative = true },
				-- Feet detail
				{ name = "FootL", shape = "Block", size = Vector3.new(0.4, 0.08, 0.5), offset = Vector3.new(-0.4, -1.65, 0.1), color = Color3.fromRGB(255, 180, 50), bodyRelative = true },
				{ name = "FootR", shape = "Block", size = Vector3.new(0.4, 0.08, 0.5), offset = Vector3.new(0.4, -1.65, 0.1), color = Color3.fromRGB(255, 180, 50), bodyRelative = true },
				-- Breast feather puff
				{ name = "Breast", shape = "Ball", size = Vector3.new(1.2, 0.8, 0.8), offset = Vector3.new(0, -0.2, 0.5), color = Color3.fromRGB(255, 252, 245), bodyRelative = true },
			},
		},
	},

	Cow = {
		name        = "Cow",
		hp          = 150,
		damage      = 9,
		level       = 3,
		xp          = 15,
		respawnTime = 20,
		zone        = "Safe",
		passive     = true,
		drops = {
			{ item = "Cowhide",  chance = 1.00, minQty = 1, maxQty = 1 },
			{ item = "Raw Beef", chance = 0.70, minQty = 1, maxQty = 1 },
			{ item = "Bones",    chance = 0.50, minQty = 1, maxQty = 1 },
			{ item = "Bowstring", chance = 0.10, minQty = 1, maxQty = 1 },
		},
		model = {
			bodyColor = Color3.fromRGB(255, 245, 235), -- base creamy white
			size = Vector3.new(3.5, 2.2, 4.8), -- proper rectangular body
			headSize = 1.0,
			extras = {
				-- PROPER COW HEAD with snout
				{ name = "Snout", shape = "Block", size = Vector3.new(0.8, 0.6, 1.0), offset = Vector3.new(0, -0.15, 0.75), color = Color3.fromRGB(255, 240, 225) },
				-- Nostrils on snout
				{ name = "NostrilL", shape = "Ball", size = Vector3.new(0.12, 0.1, 0.08), offset = Vector3.new(-0.15, -0.2, 1.2), color = Color3.fromRGB(40, 30, 25) },
				{ name = "NostrilR", shape = "Ball", size = Vector3.new(0.12, 0.1, 0.08), offset = Vector3.new(0.15, -0.2, 1.2), color = Color3.fromRGB(40, 30, 25) },
				-- Large cow eyes
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.28, 0.28, 0.28), offset = Vector3.new(-0.35, 0.2, 0.4), color = Color3.fromRGB(20, 15, 10) },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.28, 0.28, 0.28), offset = Vector3.new(0.35, 0.2, 0.4), color = Color3.fromRGB(20, 15, 10) },
				-- Curved horns
				{ name = "HornL", shape = "Block", size = Vector3.new(0.18, 0.9, 0.18), offset = Vector3.new(-0.4, 0.9, 0.1), color = Color3.fromRGB(210, 200, 180), rotation = Vector3.new(0, 0, -15) },
				{ name = "HornR", shape = "Block", size = Vector3.new(0.18, 0.9, 0.18), offset = Vector3.new(0.4, 0.9, 0.1), color = Color3.fromRGB(210, 200, 180), rotation = Vector3.new(0, 0, 15) },
				-- Large hanging ears
				{ name = "EarL", shape = "Block", size = Vector3.new(0.6, 0.8, 0.12), offset = Vector3.new(-0.7, 0.1, 0.2), color = Color3.fromRGB(255, 235, 215) },
				{ name = "EarR", shape = "Block", size = Vector3.new(0.6, 0.8, 0.12), offset = Vector3.new(0.7, 0.1, 0.2), color = Color3.fromRGB(255, 235, 215) },
				-- PROPER 4 LEGS with better proportions
				{ name = "LegFL", shape = "Block", size = Vector3.new(0.6, 2.4, 0.6), offset = Vector3.new(-1.2, -2.3, 1.6), color = Color3.fromRGB(255, 245, 235), bodyRelative = true },
				{ name = "LegFR", shape = "Block", size = Vector3.new(0.6, 2.4, 0.6), offset = Vector3.new(1.2, -2.3, 1.6), color = Color3.fromRGB(255, 245, 235), bodyRelative = true },
				{ name = "LegBL", shape = "Block", size = Vector3.new(0.6, 2.4, 0.6), offset = Vector3.new(-1.2, -2.3, -1.6), color = Color3.fromRGB(255, 245, 235), bodyRelative = true },
				{ name = "LegBR", shape = "Block", size = Vector3.new(0.6, 2.4, 0.6), offset = Vector3.new(1.2, -2.3, -1.6), color = Color3.fromRGB(255, 245, 235), bodyRelative = true },
				-- Black hooves
				{ name = "HoofFL", shape = "Block", size = Vector3.new(0.65, 0.25, 0.65), offset = Vector3.new(-1.2, -3.6, 1.6), color = Color3.fromRGB(35, 25, 20), bodyRelative = true },
				{ name = "HoofFR", shape = "Block", size = Vector3.new(0.65, 0.25, 0.65), offset = Vector3.new(1.2, -3.6, 1.6), color = Color3.fromRGB(35, 25, 20), bodyRelative = true },
				{ name = "HoofBL", shape = "Block", size = Vector3.new(0.65, 0.25, 0.65), offset = Vector3.new(-1.2, -3.6, -1.6), color = Color3.fromRGB(35, 25, 20), bodyRelative = true },
				{ name = "HoofBR", shape = "Block", size = Vector3.new(0.65, 0.25, 0.65), offset = Vector3.new(1.2, -3.6, -1.6), color = Color3.fromRGB(35, 25, 20), bodyRelative = true },
				-- DISTINCT BLACK SPOTS pattern
				{ name = "SpotMajor1", shape = "Block", size = Vector3.new(1.8, 1.2, 1.5), offset = Vector3.new(-0.5, 0.4, 0.8), color = Color3.fromRGB(30, 20, 15), bodyRelative = true },
				{ name = "SpotMajor2", shape = "Block", size = Vector3.new(1.4, 1.0, 1.2), offset = Vector3.new(1.0, 0.2, -0.8), color = Color3.fromRGB(25, 15, 10), bodyRelative = true },
				{ name = "SpotMajor3", shape = "Block", size = Vector3.new(1.2, 0.8, 1.0), offset = Vector3.new(-0.8, -0.3, -1.5), color = Color3.fromRGB(35, 25, 20), bodyRelative = true },
				-- Medium spots
				{ name = "SpotMed1", shape = "Ball", size = Vector3.new(0.8, 0.8, 0.8), offset = Vector3.new(1.3, 0.6, 1.2), color = Color3.fromRGB(40, 30, 25), bodyRelative = true },
				{ name = "SpotMed2", shape = "Ball", size = Vector3.new(0.6, 0.6, 0.6), offset = Vector3.new(-1.4, 0.8, 0.2), color = Color3.fromRGB(30, 20, 15), bodyRelative = true },
				{ name = "SpotMed3", shape = "Ball", size = Vector3.new(0.7, 0.7, 0.7), offset = Vector3.new(0.4, -0.6, 1.8), color = Color3.fromRGB(35, 25, 20), bodyRelative = true },
				-- Small spots for variety
				{ name = "SpotSmall1", shape = "Ball", size = Vector3.new(0.4, 0.4, 0.4), offset = Vector3.new(-1.6, 0.2, 1.0), color = Color3.fromRGB(25, 15, 10), bodyRelative = true },
				{ name = "SpotSmall2", shape = "Ball", size = Vector3.new(0.35, 0.35, 0.35), offset = Vector3.new(1.5, 0.9, -1.2), color = Color3.fromRGB(30, 20, 15), bodyRelative = true },
				{ name = "SpotSmall3", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.3), offset = Vector3.new(0.8, -0.4, -0.3), color = Color3.fromRGB(40, 30, 25), bodyRelative = true },
				-- UDDER (female variant)
				{ name = "Udder", shape = "Ball", size = Vector3.new(1.2, 0.8, 1.0), offset = Vector3.new(0, -1.6, -0.5), color = Color3.fromRGB(255, 210, 190), bodyRelative = true },
				{ name = "Teat1", shape = "Ball", size = Vector3.new(0.15, 0.25, 0.15), offset = Vector3.new(-0.3, -2.1, -0.3), color = Color3.fromRGB(240, 190, 170), bodyRelative = true },
				{ name = "Teat2", shape = "Ball", size = Vector3.new(0.15, 0.25, 0.15), offset = Vector3.new(0.3, -2.1, -0.3), color = Color3.fromRGB(240, 190, 170), bodyRelative = true },
				{ name = "Teat3", shape = "Ball", size = Vector3.new(0.15, 0.25, 0.15), offset = Vector3.new(-0.3, -2.1, -0.8), color = Color3.fromRGB(240, 190, 170), bodyRelative = true },
				{ name = "Teat4", shape = "Ball", size = Vector3.new(0.15, 0.25, 0.15), offset = Vector3.new(0.3, -2.1, -0.8), color = Color3.fromRGB(240, 190, 170), bodyRelative = true },
				-- TAIL with proper tuft
				{ name = "TailBase", shape = "Block", size = Vector3.new(0.25, 0.8, 0.25), offset = Vector3.new(0, 0.3, -2.6), color = Color3.fromRGB(255, 245, 235), bodyRelative = true },
				{ name = "TailMid", shape = "Block", size = Vector3.new(0.2, 0.6, 0.2), offset = Vector3.new(0, 0.1, -3.2), color = Color3.fromRGB(250, 240, 230), bodyRelative = true },
				{ name = "TailTuft", shape = "Ball", size = Vector3.new(0.6, 0.8, 0.6), offset = Vector3.new(0, 0, -3.8), color = Color3.fromRGB(30, 20, 15), bodyRelative = true },
				-- Cow bell with strap
				{ name = "BellStrap", shape = "Block", size = Vector3.new(1.6, 0.18, 0.18), offset = Vector3.new(0, -0.4, 0.3), color = Color3.fromRGB(120, 70, 30) },
				{ name = "Bell", shape = "Ball", size = Vector3.new(0.4, 0.5, 0.4), offset = Vector3.new(0, -0.7, 0.3), color = Color3.fromRGB(200, 160, 40), material = Enum.Material.Metal },
				-- Mouth line
				{ name = "Mouth", shape = "Block", size = Vector3.new(0.4, 0.08, 0.1), offset = Vector3.new(0, -0.35, 1.15), color = Color3.fromRGB(60, 50, 45) },
			},
		},
	},

	Goblin = {
		name        = "Goblin",
		hp          = 250,
		damage      = 15,
		level       = 5,
		xp          = 25,
		respawnTime = 25,
		zone        = "Safe",
		passive     = false,
		drops = {
			{ item = "Goblin Mail",   chance = 0.30, minQty = 1, maxQty = 1  },
			{ item = "Bronze Coins",  chance = 1.00, minQty = 5, maxQty = 15 },
			{ item = "Copper Sword",  chance = 0.10, minQty = 1, maxQty = 1 },
			{ item = "Bones",         chance = 0.80, minQty = 1, maxQty = 1 },
			{ item = "Bronze Arrows", chance = 0.30, minQty = 5, maxQty = 15 },
			{ item = "Oak Shortbow",  chance = 0.05, minQty = 1, maxQty = 1 },
		},
		model = {
			bodyColor = Color3.fromRGB(80, 160, 60),
			size = Vector3.new(1.8, 2.5, 1.2),
			headSize = 1.0,
			extras = {
				-- Original parts
				{ name = "EarL", shape = "Block", size = Vector3.new(0.8, 0.3, 0.2), offset = Vector3.new(-0.8, 0.2, 0), color = Color3.fromRGB(80, 160, 60) },
				{ name = "EarR", shape = "Block", size = Vector3.new(0.8, 0.3, 0.2), offset = Vector3.new(0.8, 0.2, 0), color = Color3.fromRGB(80, 160, 60) },
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.3), offset = Vector3.new(-0.25, 0.15, 0.5), color = Color3.fromRGB(255, 50, 50), material = Enum.Material.Neon },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.3), offset = Vector3.new(0.25, 0.15, 0.5), color = Color3.fromRGB(255, 50, 50), material = Enum.Material.Neon },
				{ name = "Armor", shape = "Block", size = Vector3.new(2, 1.2, 1.4), offset = Vector3.new(0, 0.2, 0), color = Color3.fromRGB(100, 80, 40), bodyRelative = true, material = Enum.Material.Slate },
				{ name = "LegL", shape = "Block", size = Vector3.new(0.5, 1.5, 0.5), offset = Vector3.new(-0.4, -2, 0), color = Color3.fromRGB(80, 160, 60), bodyRelative = true },
				{ name = "LegR", shape = "Block", size = Vector3.new(0.5, 1.5, 0.5), offset = Vector3.new(0.4, -2, 0), color = Color3.fromRGB(80, 160, 60), bodyRelative = true },
				{ name = "Club", shape = "Block", size = Vector3.new(0.3, 2, 0.3), offset = Vector3.new(1.2, -0.5, 0), color = Color3.fromRGB(120, 90, 50), bodyRelative = true, material = Enum.Material.Wood },
				-- Pointed nose
				{ name = "Nose", shape = "Block", size = Vector3.new(0.2, 0.2, 0.5), offset = Vector3.new(0, -0.05, 0.65), color = Color3.fromRGB(70, 145, 50) },
				-- Pupils (small dark centers)
				{ name = "PupilL", shape = "Ball", size = Vector3.new(0.12, 0.12, 0.12), offset = Vector3.new(-0.25, 0.15, 0.63), color = Color3.fromRGB(30, 10, 10) },
				{ name = "PupilR", shape = "Ball", size = Vector3.new(0.12, 0.12, 0.12), offset = Vector3.new(0.25, 0.15, 0.63), color = Color3.fromRGB(30, 10, 10) },
				-- War paint stripes on face
				{ name = "PaintL", shape = "Block", size = Vector3.new(0.08, 0.4, 0.1), offset = Vector3.new(-0.35, -0.05, 0.48), color = Color3.fromRGB(180, 30, 30) },
				{ name = "PaintR", shape = "Block", size = Vector3.new(0.08, 0.4, 0.1), offset = Vector3.new(0.35, -0.05, 0.48), color = Color3.fromRGB(180, 30, 30) },
				{ name = "PaintC", shape = "Block", size = Vector3.new(0.06, 0.3, 0.1), offset = Vector3.new(0, 0.35, 0.48), color = Color3.fromRGB(180, 30, 30) },
				-- Loincloth
				{ name = "Loincloth", shape = "Block", size = Vector3.new(1.2, 1.0, 0.15), offset = Vector3.new(0, -1.5, -0.55), color = Color3.fromRGB(80, 60, 30), bodyRelative = true },
				{ name = "LoinclothF", shape = "Block", size = Vector3.new(1.0, 0.8, 0.15), offset = Vector3.new(0, -1.5, 0.55), color = Color3.fromRGB(80, 60, 30), bodyRelative = true },
				-- Crude shield in left hand
				{ name = "Shield", shape = "Block", size = Vector3.new(0.15, 1.2, 1.0), offset = Vector3.new(-1.3, -0.3, 0), color = Color3.fromRGB(90, 70, 35), bodyRelative = true, material = Enum.Material.Wood },
				{ name = "ShieldBoss", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.3), offset = Vector3.new(-1.4, -0.3, 0), color = Color3.fromRGB(130, 110, 70), bodyRelative = true },
				-- Club knob
				{ name = "ClubKnob", shape = "Ball", size = Vector3.new(0.5, 0.5, 0.5), offset = Vector3.new(1.2, -1.7, 0), color = Color3.fromRGB(100, 75, 40), bodyRelative = true, material = Enum.Material.Wood },
				-- Belt
				{ name = "Belt", shape = "Block", size = Vector3.new(2.1, 0.25, 1.3), offset = Vector3.new(0, -0.8, 0), color = Color3.fromRGB(70, 50, 25), bodyRelative = true },
				-- Teeth (two fangs)
				{ name = "FangL", shape = "Block", size = Vector3.new(0.08, 0.15, 0.08), offset = Vector3.new(-0.12, -0.28, 0.48), color = Color3.fromRGB(230, 220, 190) },
				{ name = "FangR", shape = "Block", size = Vector3.new(0.08, 0.15, 0.08), offset = Vector3.new(0.12, -0.28, 0.48), color = Color3.fromRGB(230, 220, 190) },
			},
		},
	},

	GuardDog = {
		name        = "Guard Dog",
		hp          = 200,
		damage      = 21,
		level       = 4,
		xp          = 20,
		respawnTime = 20,
		zone        = "Safe",
		passive     = false,
		drops = {
			{ item = "Bones",   chance = 1.00, minQty = 1, maxQty = 1 },
			{ item = "Dog Tag", chance = 0.10, minQty = 1, maxQty = 1 },
			{ item = "Raw Beef", chance = 0.30, minQty = 1, maxQty = 1 },
		},
		model = {
			bodyColor = Color3.fromRGB(139, 90, 43),
			size = Vector3.new(1.8, 1.8, 3.2),
			headSize = 0.9,
			extras = {
				-- Original parts
				{ name = "Snout", shape = "Block", size = Vector3.new(0.55, 0.45, 0.7), offset = Vector3.new(0, -0.15, 0.7), color = Color3.fromRGB(120, 75, 35) },
				{ name = "EarL", shape = "Block", size = Vector3.new(0.5, 0.6, 0.2), offset = Vector3.new(-0.5, 0.5, -0.1), color = Color3.fromRGB(100, 65, 30) },
				{ name = "EarR", shape = "Block", size = Vector3.new(0.5, 0.6, 0.2), offset = Vector3.new(0.5, 0.5, -0.1), color = Color3.fromRGB(100, 65, 30) },
				{ name = "LegFL", shape = "Block", size = Vector3.new(0.45, 1.6, 0.45), offset = Vector3.new(-0.6, -1.7, 1.1), color = Color3.fromRGB(139, 90, 43), bodyRelative = true },
				{ name = "LegFR", shape = "Block", size = Vector3.new(0.45, 1.6, 0.45), offset = Vector3.new(0.6, -1.7, 1.1), color = Color3.fromRGB(139, 90, 43), bodyRelative = true },
				{ name = "LegBL", shape = "Block", size = Vector3.new(0.45, 1.6, 0.45), offset = Vector3.new(-0.6, -1.7, -1.1), color = Color3.fromRGB(139, 90, 43), bodyRelative = true },
				{ name = "LegBR", shape = "Block", size = Vector3.new(0.45, 1.6, 0.45), offset = Vector3.new(0.6, -1.7, -1.1), color = Color3.fromRGB(139, 90, 43), bodyRelative = true },
				{ name = "Tail", shape = "Block", size = Vector3.new(0.2, 0.2, 1.5), offset = Vector3.new(0, 0.5, -2.2), color = Color3.fromRGB(139, 90, 43), bodyRelative = true },
				-- Eyes (fierce)
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.2, 0.2, 0.2), offset = Vector3.new(-0.25, 0.15, 0.4), color = Color3.fromRGB(200, 160, 30) },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.2, 0.2, 0.2), offset = Vector3.new(0.25, 0.15, 0.4), color = Color3.fromRGB(200, 160, 30) },
				{ name = "PupilL", shape = "Ball", size = Vector3.new(0.1, 0.1, 0.1), offset = Vector3.new(-0.25, 0.15, 0.48), color = Color3.fromRGB(10, 10, 10) },
				{ name = "PupilR", shape = "Ball", size = Vector3.new(0.1, 0.1, 0.1), offset = Vector3.new(0.25, 0.15, 0.48), color = Color3.fromRGB(10, 10, 10) },
				-- Nose
				{ name = "Nose", shape = "Ball", size = Vector3.new(0.2, 0.15, 0.15), offset = Vector3.new(0, -0.05, 1.05), color = Color3.fromRGB(30, 20, 15) },
				-- Teeth showing
				{ name = "ToothL", shape = "Block", size = Vector3.new(0.06, 0.12, 0.06), offset = Vector3.new(-0.12, -0.3, 0.9), color = Color3.fromRGB(240, 235, 220) },
				{ name = "ToothR", shape = "Block", size = Vector3.new(0.06, 0.12, 0.06), offset = Vector3.new(0.12, -0.3, 0.9), color = Color3.fromRGB(240, 235, 220) },
				{ name = "ToothMidL", shape = "Block", size = Vector3.new(0.05, 0.08, 0.05), offset = Vector3.new(-0.2, -0.28, 0.85), color = Color3.fromRGB(240, 235, 220) },
				{ name = "ToothMidR", shape = "Block", size = Vector3.new(0.05, 0.08, 0.05), offset = Vector3.new(0.2, -0.28, 0.85), color = Color3.fromRGB(240, 235, 220) },
				-- Collar
				{ name = "Collar", shape = "Block", size = Vector3.new(1.9, 0.25, 0.25), offset = Vector3.new(0, -0.05, 1.3), color = Color3.fromRGB(180, 30, 30), bodyRelative = true },
				{ name = "CollarTag", shape = "Ball", size = Vector3.new(0.2, 0.25, 0.1), offset = Vector3.new(0, -0.22, 1.4), color = Color3.fromRGB(210, 180, 50), bodyRelative = true, material = Enum.Material.Metal },
				-- Muscular chest
				{ name = "Chest", shape = "Ball", size = Vector3.new(1.6, 1.4, 1.0), offset = Vector3.new(0, 0.1, 0.8), color = Color3.fromRGB(150, 100, 50), bodyRelative = true },
				-- Dark muzzle markings
				{ name = "MuzzleTop", shape = "Block", size = Vector3.new(0.45, 0.1, 0.5), offset = Vector3.new(0, 0.05, 0.85), color = Color3.fromRGB(80, 50, 25) },
				-- Paws
				{ name = "PawFL", shape = "Block", size = Vector3.new(0.5, 0.15, 0.55), offset = Vector3.new(-0.6, -2.55, 1.1), color = Color3.fromRGB(110, 70, 35), bodyRelative = true },
				{ name = "PawFR", shape = "Block", size = Vector3.new(0.5, 0.15, 0.55), offset = Vector3.new(0.6, -2.55, 1.1), color = Color3.fromRGB(110, 70, 35), bodyRelative = true },
				{ name = "PawBL", shape = "Block", size = Vector3.new(0.5, 0.15, 0.55), offset = Vector3.new(-0.6, -2.55, -1.1), color = Color3.fromRGB(110, 70, 35), bodyRelative = true },
				{ name = "PawBR", shape = "Block", size = Vector3.new(0.5, 0.15, 0.55), offset = Vector3.new(0.6, -2.55, -1.1), color = Color3.fromRGB(110, 70, 35), bodyRelative = true },
			},
		},
	},

	GiantRat = {
		name        = "Giant Rat",
		hp          = 125,
		damage      = 12,
		level       = 2,
		xp          = 12,
		respawnTime = 15,
		zone        = "Safe",
		passive     = true,
		drops = {
			{ item = "Rat Tail",      chance = 0.50, minQty = 1, maxQty = 1 },
			{ item = "Raw Rat Meat",  chance = 0.80, minQty = 1, maxQty = 1 },
			{ item = "Bones",         chance = 0.30, minQty = 1, maxQty = 1 },
		},
		model = {
			bodyColor = Color3.fromRGB(100, 80, 60),
			size = Vector3.new(1.2, 1, 2.5),
			headSize = 0.6,
			extras = {
				-- Original parts
				{ name = "Nose", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.3), offset = Vector3.new(0, -0.1, 0.5), color = Color3.fromRGB(200, 100, 100) },
				{ name = "EarL", shape = "Ball", size = Vector3.new(0.5, 0.5, 0.12), offset = Vector3.new(-0.3, 0.45, 0), color = Color3.fromRGB(200, 150, 150) },
				{ name = "EarR", shape = "Ball", size = Vector3.new(0.5, 0.5, 0.12), offset = Vector3.new(0.3, 0.45, 0), color = Color3.fromRGB(200, 150, 150) },
				{ name = "Tail", shape = "Block", size = Vector3.new(0.15, 0.15, 3), offset = Vector3.new(0, 0, -2.8), color = Color3.fromRGB(180, 140, 120), bodyRelative = true },
				{ name = "LegFL", shape = "Block", size = Vector3.new(0.3, 0.8, 0.3), offset = Vector3.new(-0.4, -0.9, 0.8), color = Color3.fromRGB(100, 80, 60), bodyRelative = true },
				{ name = "LegFR", shape = "Block", size = Vector3.new(0.3, 0.8, 0.3), offset = Vector3.new(0.4, -0.9, 0.8), color = Color3.fromRGB(100, 80, 60), bodyRelative = true },
				{ name = "LegBL", shape = "Block", size = Vector3.new(0.3, 0.8, 0.3), offset = Vector3.new(-0.4, -0.9, -0.8), color = Color3.fromRGB(100, 80, 60), bodyRelative = true },
				{ name = "LegBR", shape = "Block", size = Vector3.new(0.3, 0.8, 0.3), offset = Vector3.new(0.4, -0.9, -0.8), color = Color3.fromRGB(100, 80, 60), bodyRelative = true },
				-- Eyes (beady)
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.15, 0.15, 0.15), offset = Vector3.new(-0.18, 0.1, 0.3), color = Color3.fromRGB(200, 30, 30) },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.15, 0.15, 0.15), offset = Vector3.new(0.18, 0.1, 0.3), color = Color3.fromRGB(200, 30, 30) },
				-- Whiskers
				{ name = "WhiskerL1", shape = "Block", size = Vector3.new(0.6, 0.03, 0.03), offset = Vector3.new(-0.35, -0.05, 0.45), color = Color3.fromRGB(160, 130, 110) },
				{ name = "WhiskerL2", shape = "Block", size = Vector3.new(0.55, 0.03, 0.03), offset = Vector3.new(-0.33, -0.1, 0.45), color = Color3.fromRGB(160, 130, 110) },
				{ name = "WhiskerR1", shape = "Block", size = Vector3.new(0.6, 0.03, 0.03), offset = Vector3.new(0.35, -0.05, 0.45), color = Color3.fromRGB(160, 130, 110) },
				{ name = "WhiskerR2", shape = "Block", size = Vector3.new(0.55, 0.03, 0.03), offset = Vector3.new(0.33, -0.1, 0.45), color = Color3.fromRGB(160, 130, 110) },
				-- Matted fur texture patches (Fabric material)
				{ name = "FurPatch1", shape = "Block", size = Vector3.new(0.8, 0.5, 1.2), offset = Vector3.new(0.2, 0.3, 0.3), color = Color3.fromRGB(85, 65, 45), bodyRelative = true, material = Enum.Material.Fabric },
				{ name = "FurPatch2", shape = "Block", size = Vector3.new(0.6, 0.4, 0.9), offset = Vector3.new(-0.3, 0.25, -0.6), color = Color3.fromRGB(90, 70, 50), bodyRelative = true, material = Enum.Material.Fabric },
				{ name = "FurPatch3", shape = "Block", size = Vector3.new(0.5, 0.3, 0.7), offset = Vector3.new(0.1, 0.35, -1.0), color = Color3.fromRGB(80, 60, 40), bodyRelative = true, material = Enum.Material.Fabric },
				-- Ear inner pink
				{ name = "EarInnerL", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.05), offset = Vector3.new(-0.3, 0.45, -0.04), color = Color3.fromRGB(220, 170, 170) },
				{ name = "EarInnerR", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.05), offset = Vector3.new(0.3, 0.45, -0.04), color = Color3.fromRGB(220, 170, 170) },
				-- Teeth
				{ name = "ToothL", shape = "Block", size = Vector3.new(0.05, 0.1, 0.05), offset = Vector3.new(-0.06, -0.22, 0.45), color = Color3.fromRGB(230, 220, 200) },
				{ name = "ToothR", shape = "Block", size = Vector3.new(0.05, 0.1, 0.05), offset = Vector3.new(0.06, -0.22, 0.45), color = Color3.fromRGB(230, 220, 200) },
				-- Claws on front feet
				{ name = "ClawFL", shape = "Block", size = Vector3.new(0.15, 0.05, 0.15), offset = Vector3.new(-0.4, -1.35, 0.95), color = Color3.fromRGB(60, 45, 30), bodyRelative = true },
				{ name = "ClawFR", shape = "Block", size = Vector3.new(0.15, 0.05, 0.15), offset = Vector3.new(0.4, -1.35, 0.95), color = Color3.fromRGB(60, 45, 30), bodyRelative = true },
			},
		},
	},

	TrainingDummy = {
		name        = "Training Dummy",
		hp          = 999999,
		damage      = 0,
		level       = 0,
		xp          = 2,
		respawnTime = 5,
		zone        = "Safe",
		passive     = true,
		stationary  = true,
		immortal    = true,
		drops       = {},
		model = {
			bodyColor = Color3.fromRGB(180, 140, 80),
			size = Vector3.new(2, 4, 1),
			headSize = 1.0,
			extras = {
				-- Original parts
				{ name = "Arms", shape = "Block", size = Vector3.new(5, 0.5, 0.5), offset = Vector3.new(0, 0.5, 0), color = Color3.fromRGB(180, 140, 80), bodyRelative = true, material = Enum.Material.Wood },
				{ name = "Target", shape = "Block", size = Vector3.new(1.5, 1.5, 0.3), offset = Vector3.new(0, 0.5, 0.5), color = Color3.fromRGB(200, 50, 50), bodyRelative = true },
				{ name = "Post", shape = "Block", size = Vector3.new(0.5, 2, 0.5), offset = Vector3.new(0, -3, 0), color = Color3.fromRGB(120, 90, 50), bodyRelative = true, material = Enum.Material.Wood },
				-- Eyes (painted on - flat circles)
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.2, 0.2, 0.1), offset = Vector3.new(-0.25, 0.1, 0.48), color = Color3.fromRGB(30, 30, 30) },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.2, 0.2, 0.1), offset = Vector3.new(0.25, 0.1, 0.48), color = Color3.fromRGB(30, 30, 30) },
				-- X mouth (painted)
				{ name = "MouthX1", shape = "Block", size = Vector3.new(0.3, 0.05, 0.05), offset = Vector3.new(0, -0.15, 0.5), color = Color3.fromRGB(30, 30, 30), rotation = Vector3.new(0, 0, 30) },
				{ name = "MouthX2", shape = "Block", size = Vector3.new(0.3, 0.05, 0.05), offset = Vector3.new(0, -0.15, 0.5), color = Color3.fromRGB(30, 30, 30), rotation = Vector3.new(0, 0, -30) },
				-- Target ring
				{ name = "TargetRing", shape = "Block", size = Vector3.new(0.8, 0.8, 0.32), offset = Vector3.new(0, 0.5, 0.5), color = Color3.fromRGB(240, 240, 220), bodyRelative = true },
				{ name = "TargetBull", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.15), offset = Vector3.new(0, 0.5, 0.52), color = Color3.fromRGB(200, 50, 50), bodyRelative = true },
				-- Straw stuffing poking out
				{ name = "StrawTop", shape = "Block", size = Vector3.new(0.4, 0.6, 0.3), offset = Vector3.new(0.3, 2.1, 0.1), color = Color3.fromRGB(220, 200, 100), bodyRelative = true },
				{ name = "StrawL", shape = "Block", size = Vector3.new(0.3, 0.5, 0.2), offset = Vector3.new(-1.1, 0.7, 0.2), color = Color3.fromRGB(220, 200, 100), bodyRelative = true },
				{ name = "StrawR", shape = "Block", size = Vector3.new(0.3, 0.5, 0.2), offset = Vector3.new(1.1, 0.7, 0.2), color = Color3.fromRGB(220, 200, 100), bodyRelative = true },
				{ name = "StrawMid", shape = "Block", size = Vector3.new(0.2, 0.4, 0.3), offset = Vector3.new(-0.2, -0.5, 0.4), color = Color3.fromRGB(210, 190, 90), bodyRelative = true },
				-- Rope bindings
				{ name = "RopeTop", shape = "Block", size = Vector3.new(2.2, 0.15, 1.15), offset = Vector3.new(0, 1.3, 0), color = Color3.fromRGB(160, 130, 80), bodyRelative = true },
				{ name = "RopeMid", shape = "Block", size = Vector3.new(2.2, 0.15, 1.15), offset = Vector3.new(0, 0, 0), color = Color3.fromRGB(160, 130, 80), bodyRelative = true },
				{ name = "RopeBot", shape = "Block", size = Vector3.new(2.2, 0.15, 1.15), offset = Vector3.new(0, -1.2, 0), color = Color3.fromRGB(160, 130, 80), bodyRelative = true },
				-- Wear marks (darker scratches)
				{ name = "Scratch1", shape = "Block", size = Vector3.new(0.08, 1.2, 0.05), offset = Vector3.new(0.4, 0, 0.52), color = Color3.fromRGB(100, 70, 35), bodyRelative = true },
				{ name = "Scratch2", shape = "Block", size = Vector3.new(0.08, 0.8, 0.05), offset = Vector3.new(-0.3, 0.3, 0.52), color = Color3.fromRGB(100, 70, 35), bodyRelative = true },
				{ name = "Scratch3", shape = "Block", size = Vector3.new(0.06, 0.6, 0.05), offset = Vector3.new(0.1, -0.5, 0.52), color = Color3.fromRGB(110, 75, 40), bodyRelative = true },
				-- Wooden body texture
				{ name = "WoodGrain1", shape = "Block", size = Vector3.new(0.04, 3.5, 0.05), offset = Vector3.new(-0.5, 0, -0.52), color = Color3.fromRGB(160, 120, 65), bodyRelative = true },
				{ name = "WoodGrain2", shape = "Block", size = Vector3.new(0.04, 3.5, 0.05), offset = Vector3.new(0.5, 0, -0.52), color = Color3.fromRGB(160, 120, 65), bodyRelative = true },
				-- Post base
				{ name = "PostBase", shape = "Block", size = Vector3.new(1.5, 0.3, 1.5), offset = Vector3.new(0, -4.1, 0), color = Color3.fromRGB(100, 75, 40), bodyRelative = true, material = Enum.Material.Wood },
			},
		},
	},

	----------------------------------------------------------------------------
	-- WILDERNESS
	----------------------------------------------------------------------------

	Skeleton = {
		name        = "Skeleton",
		hp          = 400,
		damage      = 36,
		level       = 20,
		xp          = 50,
		respawnTime = 40,
		zone        = "Wilderness",
		passive     = false,
		drops = {
			{ item = "Bones",      chance = 1.00, minQty = 1, maxQty = 2 },
			{ item = "Iron Sword", chance = 0.08, minQty = 1, maxQty = 1 },
			{ item = "Iron Ore",   chance = 0.30, minQty = 1, maxQty = 3 },
			{ item = "Copper Sword", chance = 0.15, minQty = 1, maxQty = 1 },
			{ item = "Iron Arrows",  chance = 0.25, minQty = 10, maxQty = 20 },
			{ item = "Iron Crossbow", chance = 0.05, minQty = 1, maxQty = 1 },
			{ item = "Iron Shield",  chance = 0.08, minQty = 1, maxQty = 1 },
		},
		model = {
			bodyColor = Color3.fromRGB(230, 225, 210),
			size = Vector3.new(1.5, 4, 1),
			headSize = 1.0,
			extras = {
				-- Original parts
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.25, 0.25, 0.25), offset = Vector3.new(-0.25, 0.1, 0.45), color = Color3.fromRGB(255, 50, 50), material = Enum.Material.Neon },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.25, 0.25, 0.25), offset = Vector3.new(0.25, 0.1, 0.45), color = Color3.fromRGB(255, 50, 50), material = Enum.Material.Neon },
				{ name = "Rib1", shape = "Block", size = Vector3.new(2, 0.15, 0.8), offset = Vector3.new(0, 0.8, 0), color = Color3.fromRGB(220, 215, 200), bodyRelative = true },
				{ name = "Rib2", shape = "Block", size = Vector3.new(2, 0.15, 0.8), offset = Vector3.new(0, 0.4, 0), color = Color3.fromRGB(220, 215, 200), bodyRelative = true },
				{ name = "Rib3", shape = "Block", size = Vector3.new(2, 0.15, 0.8), offset = Vector3.new(0, 0, 0), color = Color3.fromRGB(220, 215, 200), bodyRelative = true },
				{ name = "ArmL", shape = "Block", size = Vector3.new(0.3, 3, 0.3), offset = Vector3.new(-1.1, -0.5, 0), color = Color3.fromRGB(230, 225, 210), bodyRelative = true },
				{ name = "ArmR", shape = "Block", size = Vector3.new(0.3, 3, 0.3), offset = Vector3.new(1.1, -0.5, 0), color = Color3.fromRGB(230, 225, 210), bodyRelative = true },
				{ name = "Sword", shape = "Block", size = Vector3.new(0.2, 3, 0.5), offset = Vector3.new(1.5, -1.5, 0), color = Color3.fromRGB(180, 180, 180), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "LegL", shape = "Block", size = Vector3.new(0.4, 2.5, 0.4), offset = Vector3.new(-0.4, -3.2, 0), color = Color3.fromRGB(230, 225, 210), bodyRelative = true },
				{ name = "LegR", shape = "Block", size = Vector3.new(0.4, 2.5, 0.4), offset = Vector3.new(0.4, -3.2, 0), color = Color3.fromRGB(230, 225, 210), bodyRelative = true },
				-- Jaw (separate mandible)
				{ name = "Jaw", shape = "Block", size = Vector3.new(0.7, 0.2, 0.6), offset = Vector3.new(0, -0.35, 0.1), color = Color3.fromRGB(220, 215, 200) },
				-- Teeth
				{ name = "TeethUpper", shape = "Block", size = Vector3.new(0.5, 0.1, 0.08), offset = Vector3.new(0, -0.18, 0.5), color = Color3.fromRGB(210, 205, 190) },
				{ name = "TeethLower", shape = "Block", size = Vector3.new(0.5, 0.1, 0.08), offset = Vector3.new(0, -0.3, 0.5), color = Color3.fromRGB(210, 205, 190) },
				-- Nose cavity
				{ name = "NoseCavity", shape = "Block", size = Vector3.new(0.15, 0.15, 0.1), offset = Vector3.new(0, -0.05, 0.48), color = Color3.fromRGB(50, 40, 35) },
				-- Shield in left hand
				{ name = "Shield", shape = "Block", size = Vector3.new(0.15, 1.8, 1.4), offset = Vector3.new(-1.5, -0.8, 0), color = Color3.fromRGB(100, 90, 80), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "ShieldBoss", shape = "Ball", size = Vector3.new(0.4, 0.4, 0.4), offset = Vector3.new(-1.6, -0.8, 0), color = Color3.fromRGB(140, 130, 110), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "ShieldRim", shape = "Block", size = Vector3.new(0.18, 1.9, 0.15), offset = Vector3.new(-1.5, -0.8, 0.7), color = Color3.fromRGB(120, 110, 100), bodyRelative = true, material = Enum.Material.Metal },
				-- Tattered cloth on shoulders
				{ name = "ClothL", shape = "Block", size = Vector3.new(0.8, 1.5, 0.6), offset = Vector3.new(-0.5, 1.2, 0), color = Color3.fromRGB(80, 70, 55), bodyRelative = true, material = Enum.Material.Fabric, transparency = 0.2 },
				{ name = "ClothR", shape = "Block", size = Vector3.new(0.6, 1.0, 0.5), offset = Vector3.new(0.5, 1.0, 0), color = Color3.fromRGB(75, 65, 50), bodyRelative = true, material = Enum.Material.Fabric, transparency = 0.3 },
				-- Bone crown
				{ name = "CrownBase", shape = "Block", size = Vector3.new(1.1, 0.15, 1.1), offset = Vector3.new(0, 0.5, 0), color = Color3.fromRGB(210, 200, 180) },
				{ name = "CrownSpike1", shape = "Block", size = Vector3.new(0.1, 0.4, 0.1), offset = Vector3.new(0, 0.75, 0.4), color = Color3.fromRGB(210, 200, 180) },
				{ name = "CrownSpike2", shape = "Block", size = Vector3.new(0.1, 0.35, 0.1), offset = Vector3.new(0.35, 0.7, 0.2), color = Color3.fromRGB(210, 200, 180) },
				{ name = "CrownSpike3", shape = "Block", size = Vector3.new(0.1, 0.3, 0.1), offset = Vector3.new(-0.35, 0.7, 0.2), color = Color3.fromRGB(210, 200, 180) },
				-- Spectral wisps
				{ name = "Wisp1", shape = "Ball", size = Vector3.new(0.5, 0.8, 0.5), offset = Vector3.new(0.7, 0.5, 0.5), color = Color3.fromRGB(100, 200, 150), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.6 },
				{ name = "Wisp2", shape = "Ball", size = Vector3.new(0.4, 0.6, 0.4), offset = Vector3.new(-0.8, -0.3, -0.3), color = Color3.fromRGB(100, 200, 150), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.7 },
				{ name = "Wisp3", shape = "Ball", size = Vector3.new(0.3, 0.5, 0.3), offset = Vector3.new(0.2, -2.5, 0.4), color = Color3.fromRGB(120, 220, 170), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.65 },
				-- Sword crossguard
				{ name = "SwordGuard", shape = "Block", size = Vector3.new(0.1, 0.15, 0.8), offset = Vector3.new(1.5, 0, 0), color = Color3.fromRGB(140, 130, 110), bodyRelative = true, material = Enum.Material.Metal },
				-- Hand bones (knuckles)
				{ name = "HandL", shape = "Block", size = Vector3.new(0.35, 0.3, 0.35), offset = Vector3.new(-1.1, -2.2, 0), color = Color3.fromRGB(225, 220, 205), bodyRelative = true },
				{ name = "HandR", shape = "Block", size = Vector3.new(0.35, 0.3, 0.35), offset = Vector3.new(1.1, -2.2, 0), color = Color3.fromRGB(225, 220, 205), bodyRelative = true },
				-- Foot bones
				{ name = "FootL", shape = "Block", size = Vector3.new(0.5, 0.15, 0.6), offset = Vector3.new(-0.4, -4.5, 0.1), color = Color3.fromRGB(225, 220, 205), bodyRelative = true },
				{ name = "FootR", shape = "Block", size = Vector3.new(0.5, 0.15, 0.6), offset = Vector3.new(0.4, -4.5, 0.1), color = Color3.fromRGB(225, 220, 205), bodyRelative = true },
				-- Pelvis
				{ name = "Pelvis", shape = "Block", size = Vector3.new(1.3, 0.4, 0.8), offset = Vector3.new(0, -1.5, 0), color = Color3.fromRGB(225, 220, 205), bodyRelative = true },
			},
		},
	},

	DarkWizard = {
		name        = "Dark Wizard",
		hp          = 600,
		damage      = 54,
		level       = 35,
		xp          = 80,
		respawnTime = 50,
		zone        = "Wilderness",
		passive     = false,
		drops = {
			{ item = "Wizard Robe", chance = 0.10, minQty = 1, maxQty = 1 },
			{ item = "Magic Log",   chance = 0.20, minQty = 1, maxQty = 1 },
			{ item = "Gold Ore",    chance = 0.40, minQty = 2, maxQty = 4 },
			{ item = "Iron Sword",  chance = 0.12, minQty = 1, maxQty = 1 },
			{ item = "Gold Sword",  chance = 0.03, minQty = 1, maxQty = 1 },
			{ item = "Yew Shortbow", chance = 0.05, minQty = 1, maxQty = 1 },
			{ item = "Gold Arrows", chance = 0.15, minQty = 10, maxQty = 25 },
		},
		model = {
			bodyColor = Color3.fromRGB(40, 15, 70),
			size = Vector3.new(2, 5, 1.5),
			headSize = 1.0,
			extras = {
				-- Original parts
				{ name = "Hood", shape = "Block", size = Vector3.new(1.4, 0.8, 1.4), offset = Vector3.new(0, 1.2, -0.1), color = Color3.fromRGB(30, 10, 55) },
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.2, 0.2, 0.2), offset = Vector3.new(-0.2, 0.1, 0.45), color = Color3.fromRGB(180, 50, 255), material = Enum.Material.Neon },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.2, 0.2, 0.2), offset = Vector3.new(0.2, 0.1, 0.45), color = Color3.fromRGB(180, 50, 255), material = Enum.Material.Neon },
				{ name = "Robe", shape = "Block", size = Vector3.new(2.5, 3, 2), offset = Vector3.new(0, -1.5, 0), color = Color3.fromRGB(40, 15, 70), bodyRelative = true },
				{ name = "Staff", shape = "Block", size = Vector3.new(0.3, 6, 0.3), offset = Vector3.new(1.5, 0, 0), color = Color3.fromRGB(80, 50, 30), bodyRelative = true, material = Enum.Material.Wood },
				{ name = "StaffOrb", shape = "Ball", size = Vector3.new(0.8, 0.8, 0.8), offset = Vector3.new(1.5, 3.2, 0), color = Color3.fromRGB(180, 50, 255), bodyRelative = true, material = Enum.Material.Neon },
				{ name = "HandL", shape = "Ball", size = Vector3.new(0.5, 0.5, 0.5), offset = Vector3.new(-1.3, 0, 0.5), color = Color3.fromRGB(150, 40, 200), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.3 },
				-- Longer robe skirt
				{ name = "RobeSkirt", shape = "Block", size = Vector3.new(2.8, 2, 2.3), offset = Vector3.new(0, -3.2, 0), color = Color3.fromRGB(35, 12, 60), bodyRelative = true },
				{ name = "RobeHem", shape = "Block", size = Vector3.new(3.0, 0.2, 2.5), offset = Vector3.new(0, -4.2, 0), color = Color3.fromRGB(25, 8, 45), bodyRelative = true },
				-- Hood peak (taller hood)
				{ name = "HoodPeak", shape = "Block", size = Vector3.new(0.8, 0.6, 0.8), offset = Vector3.new(0, 1.1, -0.2), color = Color3.fromRGB(25, 8, 50) },
				-- Spell book in left hand
				{ name = "Book", shape = "Block", size = Vector3.new(0.6, 0.8, 0.15), offset = Vector3.new(-1.5, -0.5, 0.4), color = Color3.fromRGB(60, 20, 20), bodyRelative = true },
				{ name = "BookPages", shape = "Block", size = Vector3.new(0.55, 0.75, 0.08), offset = Vector3.new(-1.5, -0.5, 0.48), color = Color3.fromRGB(230, 220, 180), bodyRelative = true },
				{ name = "BookClasp", shape = "Block", size = Vector3.new(0.1, 0.1, 0.18), offset = Vector3.new(-1.5, -0.15, 0.4), color = Color3.fromRGB(180, 150, 50), bodyRelative = true, material = Enum.Material.Metal },
				-- Floating magic orbs
				{ name = "FloatOrb1", shape = "Ball", size = Vector3.new(0.35, 0.35, 0.35), offset = Vector3.new(-0.8, 2.5, -0.5), color = Color3.fromRGB(160, 40, 220), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.3 },
				{ name = "FloatOrb2", shape = "Ball", size = Vector3.new(0.25, 0.25, 0.25), offset = Vector3.new(0.5, 2.8, 0.3), color = Color3.fromRGB(140, 30, 200), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.4 },
				{ name = "FloatOrb3", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.3), offset = Vector3.new(-0.3, 3.0, 0.6), color = Color3.fromRGB(170, 60, 240), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.35 },
				-- Rune circle at feet
				{ name = "RuneCircle", shape = "Block", size = Vector3.new(4, 0.05, 4), offset = Vector3.new(0, -4.5, 0), color = Color3.fromRGB(120, 30, 180), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.5 },
				{ name = "RuneInner", shape = "Ball", size = Vector3.new(2.5, 0.08, 2.5), offset = Vector3.new(0, -4.48, 0), color = Color3.fromRGB(100, 20, 160), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.6 },
				-- Rune symbols floating
				{ name = "RuneFloat1", shape = "Block", size = Vector3.new(0.3, 0.3, 0.05), offset = Vector3.new(1.5, -4.3, 1.5), color = Color3.fromRGB(180, 50, 255), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.4 },
				{ name = "RuneFloat2", shape = "Block", size = Vector3.new(0.3, 0.3, 0.05), offset = Vector3.new(-1.5, -4.3, -1.5), color = Color3.fromRGB(180, 50, 255), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.4 },
				{ name = "RuneFloat3", shape = "Block", size = Vector3.new(0.3, 0.3, 0.05), offset = Vector3.new(-1.5, -4.3, 1.5), color = Color3.fromRGB(180, 50, 255), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.4 },
				{ name = "RuneFloat4", shape = "Block", size = Vector3.new(0.3, 0.3, 0.05), offset = Vector3.new(1.5, -4.3, -1.5), color = Color3.fromRGB(180, 50, 255), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.4 },
				-- Belt/sash
				{ name = "Sash", shape = "Block", size = Vector3.new(2.3, 0.2, 1.6), offset = Vector3.new(0, -0.3, 0), color = Color3.fromRGB(80, 30, 120), bodyRelative = true },
				-- Robe trim
				{ name = "TrimFront", shape = "Block", size = Vector3.new(0.15, 4.5, 0.1), offset = Vector3.new(0, -1.5, -1.0), color = Color3.fromRGB(100, 40, 150), bodyRelative = true },
				-- Staff glow ring
				{ name = "StaffRing", shape = "Block", size = Vector3.new(0.5, 0.1, 0.5), offset = Vector3.new(1.5, 2.6, 0), color = Color3.fromRGB(150, 40, 220), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.3 },
				-- Dark energy hand glow (right)
				{ name = "HandR", shape = "Ball", size = Vector3.new(0.4, 0.4, 0.4), offset = Vector3.new(1.3, 0, 0.5), color = Color3.fromRGB(150, 40, 200), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.4 },
			},
		},
	},

	Demon = {
		name        = "Demon",
		hp          = 1000,
		damage      = 75,
		level       = 50,
		xp          = 150,
		respawnTime = 70,
		zone        = "Wilderness",
		passive     = false,
		drops = {
			{ item = "Demon Heart",  chance = 0.15, minQty = 1, maxQty = 1 },
			{ item = "Gold Sword",   chance = 0.05, minQty = 1, maxQty = 1 },
			{ item = "Runite Ore",   chance = 0.25, minQty = 1, maxQty = 3 },
			{ item = "Gold Ore",     chance = 0.40, minQty = 2, maxQty = 5 },
			{ item = "Bones",        chance = 1.00, minQty = 2, maxQty = 3 },
			{ item = "Gold Crossbow", chance = 0.04, minQty = 1, maxQty = 1 },
			{ item = "Runite Arrows", chance = 0.10, minQty = 5, maxQty = 15 },
			{ item = "Gold Shield",  chance = 0.08, minQty = 1, maxQty = 1 },
		},
		model = {
			bodyColor = Color3.fromRGB(120, 20, 20), -- darker red-black
			size = Vector3.new(2.8, 4.5, 2.0), -- muscular humanoid proportions
			headSize = 1.2,
			extras = {
				-- === MUSCULAR HUMANOID DEMON ===
				-- MASSIVE curved horns (demonic)
				{ name = "HornL", shape = "Block", size = Vector3.new(0.35, 2.0, 0.35), offset = Vector3.new(-0.5, 1.4, 0.2), color = Color3.fromRGB(30, 5, 5), rotation = Vector3.new(0, 15, -25) },
				{ name = "HornR", shape = "Block", size = Vector3.new(0.35, 2.0, 0.35), offset = Vector3.new(0.5, 1.4, 0.2), color = Color3.fromRGB(30, 5, 5), rotation = Vector3.new(0, -15, 25) },
				-- Horn tips (wickedly sharp)
				{ name = "HornTipL", shape = "Block", size = Vector3.new(0.2, 0.8, 0.2), offset = Vector3.new(-0.8, 2.8, 0.4), color = Color3.fromRGB(20, 3, 3), rotation = Vector3.new(0, 15, -35) },
				{ name = "HornTipR", shape = "Block", size = Vector3.new(0.2, 0.8, 0.2), offset = Vector3.new(0.8, 2.8, 0.4), color = Color3.fromRGB(20, 3, 3), rotation = Vector3.new(0, -15, 35) },
				-- Glowing demonic eyes
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.4, 0.4, 0.4), offset = Vector3.new(-0.3, 0.2, 0.65), color = Color3.fromRGB(255, 50, 0), material = Enum.Material.Neon },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.4, 0.4, 0.4), offset = Vector3.new(0.3, 0.2, 0.65), color = Color3.fromRGB(255, 50, 0), material = Enum.Material.Neon },
				{ name = "PupilL", shape = "Block", size = Vector3.new(0.1, 0.3, 0.1), offset = Vector3.new(-0.3, 0.2, 0.8), color = Color3.fromRGB(10, 0, 0) },
				{ name = "PupilR", shape = "Block", size = Vector3.new(0.1, 0.3, 0.1), offset = Vector3.new(0.3, 0.2, 0.8), color = Color3.fromRGB(10, 0, 0) },
				-- MUSCULAR CHEST & TORSO
				{ name = "PectoralL", shape = "Ball", size = Vector3.new(1.2, 1.0, 0.8), offset = Vector3.new(-0.7, 1.5, 0.6), color = Color3.fromRGB(130, 25, 25), bodyRelative = true },
				{ name = "PectoralR", shape = "Ball", size = Vector3.new(1.2, 1.0, 0.8), offset = Vector3.new(0.7, 1.5, 0.6), color = Color3.fromRGB(130, 25, 25), bodyRelative = true },
				{ name = "AbMuscles", shape = "Block", size = Vector3.new(1.8, 1.5, 0.8), offset = Vector3.new(0, 0.2, 0.8), color = Color3.fromRGB(110, 20, 20), bodyRelative = true },
				-- Glowing core/heart
				{ name = "DemonicHeart", shape = "Ball", size = Vector3.new(0.6, 0.8, 0.4), offset = Vector3.new(0, 0.8, 1.2), color = Color3.fromRGB(255, 30, 0), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.3 },
				-- MUSCULAR ARMS (humanoid)
				{ name = "ShoulderL", shape = "Ball", size = Vector3.new(0.8, 0.8, 0.8), offset = Vector3.new(-1.8, 1.8, 0), color = Color3.fromRGB(125, 22, 22), bodyRelative = true },
				{ name = "ShoulderR", shape = "Ball", size = Vector3.new(0.8, 0.8, 0.8), offset = Vector3.new(1.8, 1.8, 0), color = Color3.fromRGB(125, 22, 22), bodyRelative = true },
				{ name = "BicepL", shape = "Block", size = Vector3.new(0.7, 1.8, 0.7), offset = Vector3.new(-1.8, 0.5, 0), color = Color3.fromRGB(120, 20, 20), bodyRelative = true },
				{ name = "BicepR", shape = "Block", size = Vector3.new(0.7, 1.8, 0.7), offset = Vector3.new(1.8, 0.5, 0), color = Color3.fromRGB(120, 20, 20), bodyRelative = true },
				{ name = "ForearmL", shape = "Block", size = Vector3.new(0.6, 1.5, 0.6), offset = Vector3.new(-1.8, -1.0, 0), color = Color3.fromRGB(115, 18, 18), bodyRelative = true },
				{ name = "ForearmR", shape = "Block", size = Vector3.new(0.6, 1.5, 0.6), offset = Vector3.new(1.8, -1.0, 0), color = Color3.fromRGB(115, 18, 18), bodyRelative = true },
				-- CLAWED HANDS wreathed in fire
				{ name = "HandL", shape = "Block", size = Vector3.new(0.8, 0.4, 1.0), offset = Vector3.new(-1.8, -2.0, 0), color = Color3.fromRGB(100, 15, 15), bodyRelative = true },
				{ name = "HandR", shape = "Block", size = Vector3.new(0.8, 0.4, 1.0), offset = Vector3.new(1.8, -2.0, 0), color = Color3.fromRGB(100, 15, 15), bodyRelative = true },
				-- Individual claws
				{ name = "ClawL1", shape = "Block", size = Vector3.new(0.1, 0.5, 0.1), offset = Vector3.new(-2.0, -2.3, 0.4), color = Color3.fromRGB(20, 3, 3), bodyRelative = true },
				{ name = "ClawL2", shape = "Block", size = Vector3.new(0.1, 0.6, 0.1), offset = Vector3.new(-1.9, -2.4, 0.2), color = Color3.fromRGB(20, 3, 3), bodyRelative = true },
				{ name = "ClawL3", shape = "Block", size = Vector3.new(0.1, 0.5, 0.1), offset = Vector3.new(-1.8, -2.3, 0), color = Color3.fromRGB(20, 3, 3), bodyRelative = true },
				{ name = "ClawR1", shape = "Block", size = Vector3.new(0.1, 0.5, 0.1), offset = Vector3.new(2.0, -2.3, 0.4), color = Color3.fromRGB(20, 3, 3), bodyRelative = true },
				{ name = "ClawR2", shape = "Block", size = Vector3.new(0.1, 0.6, 0.1), offset = Vector3.new(1.9, -2.4, 0.2), color = Color3.fromRGB(20, 3, 3), bodyRelative = true },
				{ name = "ClawR3", shape = "Block", size = Vector3.new(0.1, 0.5, 0.1), offset = Vector3.new(1.8, -2.3, 0), color = Color3.fromRGB(20, 3, 3), bodyRelative = true },
				-- Fire wreathing hands
				{ name = "FireHandL", shape = "Ball", size = Vector3.new(1.2, 1.0, 1.2), offset = Vector3.new(-1.8, -2.0, 0), color = Color3.fromRGB(255, 80, 0), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.5 },
				{ name = "FireHandR", shape = "Ball", size = Vector3.new(1.2, 1.0, 1.2), offset = Vector3.new(1.8, -2.0, 0), color = Color3.fromRGB(255, 80, 0), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.5 },
				-- MUSCULAR LEGS (humanoid stance)
				{ name = "ThighL", shape = "Block", size = Vector3.new(0.9, 2.0, 0.9), offset = Vector3.new(-0.7, -3.2, 0), color = Color3.fromRGB(115, 20, 20), bodyRelative = true },
				{ name = "ThighR", shape = "Block", size = Vector3.new(0.9, 2.0, 0.9), offset = Vector3.new(0.7, -3.2, 0), color = Color3.fromRGB(115, 20, 20), bodyRelative = true },
				{ name = "CalfL", shape = "Block", size = Vector3.new(0.7, 1.8, 0.7), offset = Vector3.new(-0.7, -5.1, 0), color = Color3.fromRGB(110, 18, 18), bodyRelative = true },
				{ name = "CalfR", shape = "Block", size = Vector3.new(0.7, 1.8, 0.7), offset = Vector3.new(0.7, -5.1, 0), color = Color3.fromRGB(110, 18, 18), bodyRelative = true },
				-- Hooved feet
				{ name = "HoofL", shape = "Block", size = Vector3.new(0.9, 0.3, 1.2), offset = Vector3.new(-0.7, -6.1, 0.1), color = Color3.fromRGB(15, 2, 2), bodyRelative = true },
				{ name = "HoofR", shape = "Block", size = Vector3.new(0.9, 0.3, 1.2), offset = Vector3.new(0.7, -6.1, 0.1), color = Color3.fromRGB(15, 2, 2), bodyRelative = true },
				-- Menacing face features
				{ name = "Jaw", shape = "Block", size = Vector3.new(0.8, 0.4, 0.6), offset = Vector3.new(0, -0.4, 0.3), color = Color3.fromRGB(100, 15, 15) },
				{ name = "FangL", shape = "Block", size = Vector3.new(0.12, 0.4, 0.12), offset = Vector3.new(-0.2, -0.6, 0.6), color = Color3.fromRGB(240, 230, 200) },
				{ name = "FangR", shape = "Block", size = Vector3.new(0.12, 0.4, 0.12), offset = Vector3.new(0.2, -0.6, 0.6), color = Color3.fromRGB(240, 230, 200) },
				-- Small demonic wings (not dragon wings)
				{ name = "WingL", shape = "Block", size = Vector3.new(0.15, 1.8, 1.5), offset = Vector3.new(-1.6, 1.2, -0.8), color = Color3.fromRGB(60, 10, 10), bodyRelative = true, rotation = Vector3.new(0, 20, -30) },
				{ name = "WingR", shape = "Block", size = Vector3.new(0.15, 1.8, 1.5), offset = Vector3.new(1.6, 1.2, -0.8), color = Color3.fromRGB(60, 10, 10), bodyRelative = true, rotation = Vector3.new(0, -20, 30) },
				-- Spaded tail
				{ name = "TailBase", shape = "Block", size = Vector3.new(0.3, 0.3, 1.5), offset = Vector3.new(0, -1.5, -1.5), color = Color3.fromRGB(110, 18, 18), bodyRelative = true },
				{ name = "TailMid", shape = "Block", size = Vector3.new(0.25, 0.25, 1.2), offset = Vector3.new(0, -1.5, -2.9), color = Color3.fromRGB(105, 16, 16), bodyRelative = true },
				{ name = "TailSpade", shape = "Block", size = Vector3.new(0.8, 0.1, 0.6), offset = Vector3.new(0, -1.5, -3.8), color = Color3.fromRGB(80, 12, 12), bodyRelative = true },
				-- Demonic armor/scarring
				{ name = "ChestScar1", shape = "Block", size = Vector3.new(1.2, 0.08, 0.1), offset = Vector3.new(0, 1.0, 1.1), color = Color3.fromRGB(80, 10, 10), bodyRelative = true },
				{ name = "ChestScar2", shape = "Block", size = Vector3.new(0.8, 0.08, 0.1), offset = Vector3.new(0.3, 0.5, 1.1), color = Color3.fromRGB(80, 10, 10), bodyRelative = true },
				-- Shoulder spikes
				{ name = "SpikeL", shape = "Block", size = Vector3.new(0.25, 0.8, 0.25), offset = Vector3.new(-1.8, 2.5, 0), color = Color3.fromRGB(40, 6, 6), bodyRelative = true },
				{ name = "SpikeR", shape = "Block", size = Vector3.new(0.25, 0.8, 0.25), offset = Vector3.new(1.8, 2.5, 0), color = Color3.fromRGB(40, 6, 6), bodyRelative = true },
			},
		},
	},

	ShadowDragon = {
		name        = "Shadow Dragon",
		hp          = 5000,
		damage      = 120,
		level       = 80,
		xp          = 500,
		respawnTime = 180,
		zone        = "Wilderness",
		passive     = false,
		boss        = true,
		drops = {
			{ item = "Dragon Scale",  chance = 1.00, minQty = 1, maxQty = 3 },
			{ item = "Dragon Sword",  chance = 0.05, minQty = 1, maxQty = 1 },
			{ item = "Shadow Gem",    chance = 0.10, minQty = 1, maxQty = 1 },
			{ item = "Runite Ore",    chance = 0.50, minQty = 3, maxQty = 5 },
			{ item = "Gold Sword",    chance = 0.15, minQty = 1, maxQty = 1 },
			{ item = "Demon Heart",   chance = 0.20, minQty = 1, maxQty = 1 },
			{ item = "Dragon Crossbow", chance = 0.02, minQty = 1, maxQty = 1 },
			{ item = "Dragon Shield", chance = 0.03, minQty = 1, maxQty = 1 },
			{ item = "Magic Bowstring", chance = 0.15, minQty = 1, maxQty = 1 },
		},
		model = {
			bodyColor = Color3.fromRGB(30, 10, 55),
			size = Vector3.new(4, 3, 6), -- SMALL core torso, dragon built from extras
			elevation = 7, -- raise body so legs reach the ground properly
			headSize = 1.8, -- smaller head ball, snout extends it
			extras = {
				-- === SHADOW DRAGON - shaped from parts, not one big box ===
				-- TORSO SHAPING: rounded belly and back to hide the box
				{ name = "Chest", shape = "Ball", size = Vector3.new(5, 4, 7), offset = Vector3.new(0, 0, 0), color = Color3.fromRGB(35, 12, 60), bodyRelative = true },
				{ name = "Haunches", shape = "Ball", size = Vector3.new(4.5, 3.5, 5), offset = Vector3.new(0, -0.3, -3), color = Color3.fromRGB(30, 10, 55), bodyRelative = true },
				-- LONG NECK: multiple segments reaching up and forward
				{ name = "Neck1", shape = "Block", size = Vector3.new(2.0, 2.0, 3.0), offset = Vector3.new(0, 1.5, 4.5), color = Color3.fromRGB(30, 10, 55), bodyRelative = true },
				{ name = "Neck2", shape = "Block", size = Vector3.new(1.6, 1.6, 3.0), offset = Vector3.new(0, 3.0, 6.5), color = Color3.fromRGB(35, 12, 60), bodyRelative = true },
				{ name = "Neck3", shape = "Block", size = Vector3.new(1.3, 1.3, 2.5), offset = Vector3.new(0, 4.5, 8.0), color = Color3.fromRGB(38, 14, 65), bodyRelative = true },
				-- HEAD: snout, jaw, brow ridges (offset from head ball via neck)
				{ name = "Snout", shape = "Block", size = Vector3.new(1.4, 1.0, 2.5), offset = Vector3.new(0, -0.3, 2.0), color = Color3.fromRGB(30, 10, 55) },
				{ name = "Jaw", shape = "Block", size = Vector3.new(1.2, 0.5, 2.0), offset = Vector3.new(0, -0.9, 1.5), color = Color3.fromRGB(25, 8, 48) },
				{ name = "BrowL", shape = "Block", size = Vector3.new(0.6, 0.25, 0.5), offset = Vector3.new(-0.6, 0.6, 1.0), color = Color3.fromRGB(28, 10, 50) },
				{ name = "BrowR", shape = "Block", size = Vector3.new(0.6, 0.25, 0.5), offset = Vector3.new(0.6, 0.6, 1.0), color = Color3.fromRGB(28, 10, 50) },
				-- EYES: glowing purple
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.5, 0.5, 0.5), offset = Vector3.new(-0.6, 0.3, 1.0), color = Color3.fromRGB(200, 50, 255), material = Enum.Material.Neon },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.5, 0.5, 0.5), offset = Vector3.new(0.6, 0.3, 1.0), color = Color3.fromRGB(200, 50, 255), material = Enum.Material.Neon },
				{ name = "PupilL", shape = "Block", size = Vector3.new(0.08, 0.35, 0.08), offset = Vector3.new(-0.6, 0.3, 1.25), color = Color3.fromRGB(10, 0, 15) },
				{ name = "PupilR", shape = "Block", size = Vector3.new(0.08, 0.35, 0.08), offset = Vector3.new(0.6, 0.3, 1.25), color = Color3.fromRGB(10, 0, 15) },
				-- HORNS: swept back
				{ name = "HornL", shape = "Block", size = Vector3.new(0.35, 2.0, 0.35), offset = Vector3.new(-0.7, 1.5, -0.3), color = Color3.fromRGB(60, 15, 80), rotation = Vector3.new(0, 0, -20) },
				{ name = "HornR", shape = "Block", size = Vector3.new(0.35, 2.0, 0.35), offset = Vector3.new(0.7, 1.5, -0.3), color = Color3.fromRGB(60, 15, 80), rotation = Vector3.new(0, 0, 20) },
				-- FANGS
				{ name = "FangL", shape = "Block", size = Vector3.new(0.15, 0.5, 0.15), offset = Vector3.new(-0.4, -0.8, 2.8), color = Color3.fromRGB(230, 220, 200) },
				{ name = "FangR", shape = "Block", size = Vector3.new(0.15, 0.5, 0.15), offset = Vector3.new(0.4, -0.8, 2.8), color = Color3.fromRGB(230, 220, 200) },
				-- NECK SPINES
				{ name = "NeckSpine1", shape = "Block", size = Vector3.new(0.35, 1.2, 0.35), offset = Vector3.new(0, 2.8, 5.0), color = Color3.fromRGB(50, 10, 70), bodyRelative = true },
				{ name = "NeckSpine2", shape = "Block", size = Vector3.new(0.3, 1.0, 0.3), offset = Vector3.new(0, 4.0, 7.0), color = Color3.fromRGB(50, 10, 70), bodyRelative = true },
				-- WINGS: angled out and up like real dragon wings
				{ name = "WingArmL", shape = "Block", size = Vector3.new(0.5, 6, 1.0), offset = Vector3.new(-3.5, 4, 0), color = Color3.fromRGB(20, 4, 40), bodyRelative = true, rotation = Vector3.new(0, 0, -35) },
				{ name = "WingArmR", shape = "Block", size = Vector3.new(0.5, 6, 1.0), offset = Vector3.new(3.5, 4, 0), color = Color3.fromRGB(20, 4, 40), bodyRelative = true, rotation = Vector3.new(0, 0, 35) },
				{ name = "WingMemL", shape = "Block", size = Vector3.new(0.1, 5, 6), offset = Vector3.new(-6, 5, -1), color = Color3.fromRGB(40, 15, 65), bodyRelative = true, transparency = 0.2 },
				{ name = "WingMemR", shape = "Block", size = Vector3.new(0.1, 5, 6), offset = Vector3.new(6, 5, -1), color = Color3.fromRGB(40, 15, 65), bodyRelative = true, transparency = 0.2 },
				{ name = "WingFingerL1", shape = "Block", size = Vector3.new(0.08, 4.5, 0.15), offset = Vector3.new(-6.5, 5, 1), color = Color3.fromRGB(40, 15, 68), bodyRelative = true },
				{ name = "WingFingerL2", shape = "Block", size = Vector3.new(0.08, 4.0, 0.15), offset = Vector3.new(-7, 5, -2), color = Color3.fromRGB(40, 15, 68), bodyRelative = true },
				{ name = "WingFingerR1", shape = "Block", size = Vector3.new(0.08, 4.5, 0.15), offset = Vector3.new(6.5, 5, 1), color = Color3.fromRGB(40, 15, 68), bodyRelative = true },
				{ name = "WingFingerR2", shape = "Block", size = Vector3.new(0.08, 4.0, 0.15), offset = Vector3.new(7, 5, -2), color = Color3.fromRGB(40, 15, 68), bodyRelative = true },
				-- BACK SPINES
				{ name = "BackSpine1", shape = "Block", size = Vector3.new(0.4, 1.5, 0.4), offset = Vector3.new(0, 2.5, 1), color = Color3.fromRGB(55, 12, 75), bodyRelative = true },
				{ name = "BackSpine2", shape = "Block", size = Vector3.new(0.35, 1.3, 0.35), offset = Vector3.new(0, 2.3, -1), color = Color3.fromRGB(55, 12, 75), bodyRelative = true },
				{ name = "BackSpine3", shape = "Block", size = Vector3.new(0.3, 1.1, 0.3), offset = Vector3.new(0, 2.1, -3), color = Color3.fromRGB(55, 12, 75), bodyRelative = true },
				{ name = "BackSpine4", shape = "Block", size = Vector3.new(0.25, 0.9, 0.25), offset = Vector3.new(0, 1.9, -5), color = Color3.fromRGB(55, 12, 75), bodyRelative = true },
				-- LEGS: strong, dinosaur-like
				{ name = "LegFL", shape = "Block", size = Vector3.new(1.2, 4, 1.2), offset = Vector3.new(-2, -3.5, 3), color = Color3.fromRGB(30, 10, 55), bodyRelative = true },
				{ name = "LegFR", shape = "Block", size = Vector3.new(1.2, 4, 1.2), offset = Vector3.new(2, -3.5, 3), color = Color3.fromRGB(30, 10, 55), bodyRelative = true },
				{ name = "LegBL", shape = "Block", size = Vector3.new(1.4, 4.5, 1.4), offset = Vector3.new(-2, -3.8, -3), color = Color3.fromRGB(30, 10, 55), bodyRelative = true },
				{ name = "LegBR", shape = "Block", size = Vector3.new(1.4, 4.5, 1.4), offset = Vector3.new(2, -3.8, -3), color = Color3.fromRGB(30, 10, 55), bodyRelative = true },
				-- CLAWS
				{ name = "ClawFL", shape = "Block", size = Vector3.new(0.2, 0.5, 0.6), offset = Vector3.new(-2, -5.7, 3.5), color = Color3.fromRGB(20, 6, 35), bodyRelative = true },
				{ name = "ClawFR", shape = "Block", size = Vector3.new(0.2, 0.5, 0.6), offset = Vector3.new(2, -5.7, 3.5), color = Color3.fromRGB(20, 6, 35), bodyRelative = true },
				{ name = "ClawBL", shape = "Block", size = Vector3.new(0.2, 0.5, 0.6), offset = Vector3.new(-2, -6.2, -2.5), color = Color3.fromRGB(20, 6, 35), bodyRelative = true },
				{ name = "ClawBR", shape = "Block", size = Vector3.new(0.2, 0.5, 0.6), offset = Vector3.new(2, -6.2, -2.5), color = Color3.fromRGB(20, 6, 35), bodyRelative = true },
				-- TAIL: long, tapering, with blade tip
				{ name = "Tail1", shape = "Block", size = Vector3.new(1.2, 1.2, 5), offset = Vector3.new(0, 0, -8), color = Color3.fromRGB(30, 10, 55), bodyRelative = true },
				{ name = "Tail2", shape = "Block", size = Vector3.new(0.9, 0.9, 4), offset = Vector3.new(0, 0, -12.5), color = Color3.fromRGB(12, 2, 30), bodyRelative = true },
				{ name = "Tail3", shape = "Block", size = Vector3.new(0.6, 0.6, 3), offset = Vector3.new(0, 0, -16), color = Color3.fromRGB(28, 10, 50), bodyRelative = true },
				{ name = "TailBlade", shape = "Block", size = Vector3.new(1.5, 0.4, 2.0), offset = Vector3.new(0, 0, -18.5), color = Color3.fromRGB(150, 40, 200), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.2 },
				-- TAIL SPINES
				{ name = "TailSpine1", shape = "Block", size = Vector3.new(0.2, 0.6, 0.2), offset = Vector3.new(0, 0.8, -9), color = Color3.fromRGB(55, 12, 75), bodyRelative = true },
				{ name = "TailSpine2", shape = "Block", size = Vector3.new(0.18, 0.5, 0.18), offset = Vector3.new(0, 0.6, -12), color = Color3.fromRGB(55, 12, 75), bodyRelative = true },
				-- SHADOW AURA
				{ name = "ShadowAura", shape = "Ball", size = Vector3.new(10, 4, 14), offset = Vector3.new(0, -1, -2), color = Color3.fromRGB(22, 8, 42), bodyRelative = true, transparency = 0.75 },
				-- BREATH: purple fire wisps from mouth
				{ name = "Breath1", shape = "Ball", size = Vector3.new(1.0, 0.7, 1.0), offset = Vector3.new(0, -0.6, 3.5), color = Color3.fromRGB(150, 30, 200), material = Enum.Material.Neon, transparency = 0.4 },
				{ name = "Breath2", shape = "Ball", size = Vector3.new(1.5, 1.0, 1.5), offset = Vector3.new(0, -0.7, 4.5), color = Color3.fromRGB(100, 15, 160), material = Enum.Material.Neon, transparency = 0.55 },
			},
		},
	},

	-- NEW SAFE ZONE BOSSES --
	["King Rooster"] = {
		name        = "King Rooster",
		hp          = 300,
		damage      = 15,
		level       = 20,
		xp          = 300, -- level * 15
		respawnTime = 120,
		zone        = "Safe",
		passive     = false,
		boss        = true,
		drops = {
			{ item = "Golden Feather", chance = 0.80, minQty = 1, maxQty = 1 },
			{ item = "King's Crest", chance = 0.60, minQty = 1, maxQty = 1 },
			{ item = "Raw Chicken", chance = 1.00, minQty = 3, maxQty = 3 },
		},
		model = {
			bodyColor = Color3.fromRGB(220, 180, 50),
			size = Vector3.new(3.5, 2.8, 4), -- larger than regular chicken
			headSize = 1.2,
			extras = {
				-- Giant golden comb
				{ name = "KingComb", shape = "Block", size = Vector3.new(0.8, 1.5, 1.2), offset = Vector3.new(0, 1.0, 0.6), color = Color3.fromRGB(255, 215, 0) },
				-- Large beak
				{ name = "KingBeak", shape = "Block", size = Vector3.new(0.6, 0.4, 1.0), offset = Vector3.new(0, 0, 1.2), color = Color3.fromRGB(255, 180, 0) },
				-- Thick legs
				{ name = "LegL", shape = "Block", size = Vector3.new(0.4, 2.0, 0.4), offset = Vector3.new(-0.8, -2.4, 0), color = Color3.fromRGB(255, 180, 0), bodyRelative = true },
				{ name = "LegR", shape = "Block", size = Vector3.new(0.4, 2.0, 0.4), offset = Vector3.new(0.8, -2.4, 0), color = Color3.fromRGB(255, 180, 0), bodyRelative = true },
				-- Majestic tail feathers
				{ name = "TailMain", shape = "Block", size = Vector3.new(0.6, 2.5, 1.8), offset = Vector3.new(0, 0.8, -2.5), color = Color3.fromRGB(200, 150, 30), bodyRelative = true },
				-- Eyes - fierce red
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.25, 0.25, 0.25), offset = Vector3.new(-0.35, 0.2, 0.6), color = Color3.fromRGB(200, 20, 20) },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.25, 0.25, 0.25), offset = Vector3.new(0.35, 0.2, 0.6), color = Color3.fromRGB(200, 20, 20) },
				-- Golden wattle
				{ name = "KingWattle", shape = "Block", size = Vector3.new(0.3, 0.6, 0.3), offset = Vector3.new(0, -0.4, 1.1), color = Color3.fromRGB(255, 215, 0) },
				-- Large wings
				{ name = "WingL", shape = "Block", size = Vector3.new(0.3, 1.4, 2.8), offset = Vector3.new(-2.0, 0.2, -0.2), color = Color3.fromRGB(200, 160, 40), bodyRelative = true },
				{ name = "WingR", shape = "Block", size = Vector3.new(0.3, 1.4, 2.8), offset = Vector3.new(2.0, 0.2, -0.2), color = Color3.fromRGB(200, 160, 40), bodyRelative = true },
			},
		},
	},

	["Elder Treant"] = {
		name        = "Elder Treant",
		hp          = 600,
		damage      = 25,
		level       = 35,
		xp          = 525, -- level * 15
		respawnTime = 180,
		zone        = "Safe",
		passive     = false,
		boss        = true,
		drops = {
			{ item = "Heartwood", chance = 0.70, minQty = 1, maxQty = 1 },
			{ item = "Ancient Bark", chance = 1.00, minQty = 5, maxQty = 5 },
			{ item = "Magic Logs", chance = 0.90, minQty = 3, maxQty = 3 },
			{ item = "Elder Seed", chance = 0.40, minQty = 1, maxQty = 1 },
		},
		model = {
			bodyColor = Color3.fromRGB(101, 67, 33),
			size = Vector3.new(4, 5, 4), -- massive tree trunk
			headSize = 1.5,
			extras = {
				-- Tree bark texture blocks
				{ name = "BarkLayer1", shape = "Block", size = Vector3.new(4.2, 5.2, 4.2), offset = Vector3.new(0, 0, 0), color = Color3.fromRGB(85, 55, 25), bodyRelative = true, material = Enum.Material.Wood },
				-- Branch arms (thick)
				{ name = "BranchL", shape = "Block", size = Vector3.new(1.2, 0.8, 3.5), offset = Vector3.new(-3.0, 1.5, 0), color = Color3.fromRGB(90, 60, 30), bodyRelative = true },
				{ name = "BranchR", shape = "Block", size = Vector3.new(1.2, 0.8, 3.5), offset = Vector3.new(3.0, 1.5, 0), color = Color3.fromRGB(90, 60, 30), bodyRelative = true },
				-- Root legs
				{ name = "RootL", shape = "Block", size = Vector3.new(1.0, 3.0, 1.0), offset = Vector3.new(-1.5, -4.0, 0), color = Color3.fromRGB(80, 50, 25), bodyRelative = true },
				{ name = "RootR", shape = "Block", size = Vector3.new(1.0, 3.0, 1.0), offset = Vector3.new(1.5, -4.0, 0), color = Color3.fromRGB(80, 50, 25), bodyRelative = true },
				-- Glowing eyes in bark
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.3), offset = Vector3.new(-0.5, 0.3, 0.8), color = Color3.fromRGB(0, 255, 100), material = Enum.Material.Neon },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.3), offset = Vector3.new(0.5, 0.3, 0.8), color = Color3.fromRGB(0, 255, 100), material = Enum.Material.Neon },
				-- Leaves on top
				{ name = "LeafCanopy", shape = "Ball", size = Vector3.new(6, 3, 6), offset = Vector3.new(0, 4.0, 0), color = Color3.fromRGB(34, 139, 34), bodyRelative = true },
				-- Moss patches
				{ name = "Moss1", shape = "Block", size = Vector3.new(1.0, 0.8, 0.2), offset = Vector3.new(1.5, 0.5, 2.2), color = Color3.fromRGB(107, 142, 35), bodyRelative = true },
				{ name = "Moss2", shape = "Block", size = Vector3.new(0.8, 1.2, 0.2), offset = Vector3.new(-1.8, -0.5, 2.2), color = Color3.fromRGB(107, 142, 35), bodyRelative = true },
			},
		},
	},

	["Iron Golem"] = {
		name        = "Iron Golem",
		hp          = 1000,
		damage      = 35,
		level       = 50,
		xp          = 750, -- level * 15
		respawnTime = 240,
		zone        = "Safe",
		passive     = false,
		boss        = true,
		drops = {
			{ item = "Golem Core", chance = 0.50, minQty = 1, maxQty = 1 },
			{ item = "Iron Bar", chance = 1.00, minQty = 10, maxQty = 10 },
			{ item = "Runite Ore", chance = 0.80, minQty = 3, maxQty = 3 },
			{ item = "Golem Shield", chance = 0.60, minQty = 1, maxQty = 1 },
		},
		model = {
			bodyColor = Color3.fromRGB(105, 105, 105),
			size = Vector3.new(4, 6, 3), -- massive iron body
			headSize = 1.8,
			extras = {
				-- Iron plating
				{ name = "ChestPlate", shape = "Block", size = Vector3.new(4.2, 3, 3.2), offset = Vector3.new(0, 1.5, 0), color = Color3.fromRGB(95, 95, 95), bodyRelative = true, material = Enum.Material.Metal },
				-- Massive arms
				{ name = "ArmL", shape = "Block", size = Vector3.new(1.5, 1.2, 4.5), offset = Vector3.new(-3.5, 2.0, 0), color = Color3.fromRGB(100, 100, 100), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "ArmR", shape = "Block", size = Vector3.new(1.5, 1.2, 4.5), offset = Vector3.new(3.5, 2.0, 0), color = Color3.fromRGB(100, 100, 100), bodyRelative = true, material = Enum.Material.Metal },
				-- Iron legs
				{ name = "LegL", shape = "Block", size = Vector3.new(1.2, 4.0, 1.2), offset = Vector3.new(-1.0, -5.0, 0), color = Color3.fromRGB(90, 90, 90), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "LegR", shape = "Block", size = Vector3.new(1.2, 4.0, 1.2), offset = Vector3.new(1.0, -5.0, 0), color = Color3.fromRGB(90, 90, 90), bodyRelative = true, material = Enum.Material.Metal },
				-- Glowing core in chest
				{ name = "Core", shape = "Ball", size = Vector3.new(0.8, 0.8, 0.8), offset = Vector3.new(0, 1.0, 1.8), color = Color3.fromRGB(255, 100, 0), material = Enum.Material.Neon, bodyRelative = true },
				-- Glowing eyes
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.35, 0.35, 0.35), offset = Vector3.new(-0.6, 0.4, 1.0), color = Color3.fromRGB(255, 0, 0), material = Enum.Material.Neon },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.35, 0.35, 0.35), offset = Vector3.new(0.6, 0.4, 1.0), color = Color3.fromRGB(255, 0, 0), material = Enum.Material.Neon },
				-- Shoulder spikes
				{ name = "SpikeL", shape = "Block", size = Vector3.new(0.4, 1.0, 0.4), offset = Vector3.new(-2.5, 3.5, 0), color = Color3.fromRGB(80, 80, 80), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "SpikeR", shape = "Block", size = Vector3.new(0.4, 1.0, 0.4), offset = Vector3.new(2.5, 3.5, 0), color = Color3.fromRGB(80, 80, 80), bodyRelative = true, material = Enum.Material.Metal },
			},
		},
	},

	["Lake Serpent"] = {
		name        = "Lake Serpent",
		hp          = 1500,
		damage      = 45,
		level       = 65,
		xp          = 975, -- level * 15
		respawnTime = 270,
		zone        = "Safe",
		passive     = false,
		boss        = true,
		drops = {
			{ item = "Serpent Scale", chance = 0.60, minQty = 1, maxQty = 1 },
			{ item = "Sea Fang", chance = 0.50, minQty = 1, maxQty = 1 },
			{ item = "Raw Swordfish", chance = 1.00, minQty = 5, maxQty = 5 },
			{ item = "Serpent's Eye", chance = 0.30, minQty = 1, maxQty = 1 },
		},
		model = {
			bodyColor = Color3.fromRGB(0, 100, 120),
			size = Vector3.new(3, 2.5, 8), -- long serpentine body
			headSize = 2.0,
			extras = {
				-- Serpent scales
				{ name = "ScaleLayer", shape = "Block", size = Vector3.new(3.2, 2.7, 8.2), offset = Vector3.new(0, 0, 0), color = Color3.fromRGB(0, 85, 100), bodyRelative = true, material = Enum.Material.SmoothPlastic },
				-- Long tail
				{ name = "Tail1", shape = "Block", size = Vector3.new(2.5, 2.0, 6), offset = Vector3.new(0, 0, -7.0), color = Color3.fromRGB(0, 95, 110), bodyRelative = true },
				{ name = "Tail2", shape = "Block", size = Vector3.new(2.0, 1.5, 4), offset = Vector3.new(0, 0, -11.0), color = Color3.fromRGB(0, 90, 105), bodyRelative = true },
				{ name = "TailEnd", shape = "Block", size = Vector3.new(1.5, 1.0, 2), offset = Vector3.new(0, 0, -13.5), color = Color3.fromRGB(0, 85, 100), bodyRelative = true },
				-- Fins
				{ name = "FinL", shape = "Block", size = Vector3.new(0.2, 1.5, 3.0), offset = Vector3.new(-1.8, 0, -2.0), color = Color3.fromRGB(0, 120, 140), bodyRelative = true },
				{ name = "FinR", shape = "Block", size = Vector3.new(0.2, 1.5, 3.0), offset = Vector3.new(1.8, 0, -2.0), color = Color3.fromRGB(0, 120, 140), bodyRelative = true },
				-- Large serpent eyes
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.6, 0.6, 0.6), offset = Vector3.new(-0.8, 0.5, 1.2), color = Color3.fromRGB(255, 255, 0), material = Enum.Material.Neon },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.6, 0.6, 0.6), offset = Vector3.new(0.8, 0.5, 1.2), color = Color3.fromRGB(255, 255, 0), material = Enum.Material.Neon },
				-- Fangs
				{ name = "FangL", shape = "Block", size = Vector3.new(0.15, 0.8, 0.15), offset = Vector3.new(-0.4, -0.3, 1.8), color = Color3.fromRGB(245, 245, 245) },
				{ name = "FangR", shape = "Block", size = Vector3.new(0.15, 0.8, 0.15), offset = Vector3.new(0.4, -0.3, 1.8), color = Color3.fromRGB(245, 245, 245) },
				-- Dorsal spines
				{ name = "Spine1", shape = "Block", size = Vector3.new(0.3, 1.0, 0.3), offset = Vector3.new(0, 1.5, 2.0), color = Color3.fromRGB(0, 70, 90), bodyRelative = true },
				{ name = "Spine2", shape = "Block", size = Vector3.new(0.3, 1.2, 0.3), offset = Vector3.new(0, 1.6, 0), color = Color3.fromRGB(0, 70, 90), bodyRelative = true },
				{ name = "Spine3", shape = "Block", size = Vector3.new(0.3, 1.0, 0.3), offset = Vector3.new(0, 1.5, -2.0), color = Color3.fromRGB(0, 70, 90), bodyRelative = true },
			},
		},
	},

	["Corrupted Guardian"] = {
		name        = "Corrupted Guardian",
		hp          = 2500,
		damage      = 60,
		level       = 80,
		xp          = 1200, -- level * 15
		respawnTime = 300,
		zone        = "Safe",
		passive     = false,
		boss        = true,
		drops = {
			{ item = "Guardian's Blessing", chance = 0.25, minQty = 1, maxQty = 1 },
			{ item = "Corrupted Plate", chance = 0.40, minQty = 1, maxQty = 1 },
			{ item = "Gold Bar", chance = 1.00, minQty = 10, maxQty = 10 },
			{ item = "Ancient Key", chance = 0.50, minQty = 1, maxQty = 1 },
		},
		model = {
			bodyColor = Color3.fromRGB(60, 60, 80),
			size = Vector3.new(4.5, 7, 3.5), -- massive corrupted guardian
			headSize = 2.2,
			extras = {
				-- Corrupted armor plating
				{ name = "CorruptedPlate", shape = "Block", size = Vector3.new(4.7, 4, 3.7), offset = Vector3.new(0, 1.5, 0), color = Color3.fromRGB(45, 45, 65), bodyRelative = true, material = Enum.Material.Metal },
				-- Massive corrupted arms
				{ name = "ArmL", shape = "Block", size = Vector3.new(1.8, 1.5, 5.5), offset = Vector3.new(-4.0, 2.5, 0), color = Color3.fromRGB(50, 50, 70), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "ArmR", shape = "Block", size = Vector3.new(1.8, 1.5, 5.5), offset = Vector3.new(4.0, 2.5, 0), color = Color3.fromRGB(50, 50, 70), bodyRelative = true, material = Enum.Material.Metal },
				-- Corrupted legs
				{ name = "LegL", shape = "Block", size = Vector3.new(1.5, 5.0, 1.5), offset = Vector3.new(-1.2, -6.0, 0), color = Color3.fromRGB(40, 40, 60), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "LegR", shape = "Block", size = Vector3.new(1.5, 5.0, 1.5), offset = Vector3.new(1.2, -6.0, 0), color = Color3.fromRGB(40, 40, 60), bodyRelative = true, material = Enum.Material.Metal },
				-- Corrupted glow core
				{ name = "CorruptedCore", shape = "Ball", size = Vector3.new(1.2, 1.2, 1.2), offset = Vector3.new(0, 1.5, 2.0), color = Color3.fromRGB(120, 0, 120), material = Enum.Material.Neon, bodyRelative = true },
				-- Glowing corrupted eyes
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.4, 0.4, 0.4), offset = Vector3.new(-0.7, 0.6, 1.2), color = Color3.fromRGB(120, 0, 120), material = Enum.Material.Neon },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.4, 0.4, 0.4), offset = Vector3.new(0.7, 0.6, 1.2), color = Color3.fromRGB(120, 0, 120), material = Enum.Material.Neon },
				-- Shoulder corruption spikes
				{ name = "CorruptSpikeL", shape = "Block", size = Vector3.new(0.5, 1.5, 0.5), offset = Vector3.new(-3.0, 4.0, 0), color = Color3.fromRGB(30, 0, 30), bodyRelative = true, material = Enum.Material.Neon },
				{ name = "CorruptSpikeR", shape = "Block", size = Vector3.new(0.5, 1.5, 0.5), offset = Vector3.new(3.0, 4.0, 0), color = Color3.fromRGB(30, 0, 30), bodyRelative = true, material = Enum.Material.Neon },
				-- Corrupted energy tendrils
				{ name = "Tendril1", shape = "Ball", size = Vector3.new(0.8, 0.3, 1.5), offset = Vector3.new(2.0, 0.5, 0), color = Color3.fromRGB(80, 0, 80), material = Enum.Material.Neon, transparency = 0.4, bodyRelative = true },
				{ name = "Tendril2", shape = "Ball", size = Vector3.new(0.6, 0.4, 1.2), offset = Vector3.new(-2.2, 0.8, 0), color = Color3.fromRGB(80, 0, 80), material = Enum.Material.Neon, transparency = 0.4, bodyRelative = true },
			},
		},
	},

	----------------------------------------------------------------------------
	-- NEW AREA MONSTERS (MapSetup5)
	----------------------------------------------------------------------------

	["Pirate Ghost"] = {
		name        = "Pirate Ghost",
		hp          = 200,
		damage      = 18,
		level       = 25,
		xp          = 150,
		respawnTime = 30,
		zone        = "Safe",
		passive     = false,
		drops = {
			{ item = "Ghost Doubloon", chance = 0.30, minQty = 1, maxQty = 3 },
			{ item = "Pirate Cutlass", chance = 0.05, minQty = 1, maxQty = 1 },
			{ item = "Spectral Cloth", chance = 0.20, minQty = 1, maxQty = 2 },
		},
		model = {
			bodyColor = Color3.fromRGB(200, 220, 255),
			size = Vector3.new(2, 4, 1.5),
			headSize = 1.2,
			extras = {
				-- Ghostly transparency
				{ name = "GhostAura", shape = "Block", size = Vector3.new(2.2, 4.2, 1.7), offset = Vector3.new(0, 0, 0), color = Color3.fromRGB(180, 200, 255), bodyRelative = true, transparency = 0.4, material = Enum.Material.ForceField },
				-- Tricorn hat
				{ name = "TricornHat", shape = "Block", size = Vector3.new(2, 0.5, 2), offset = Vector3.new(0, 0.8, 0), color = Color3.fromRGB(40, 40, 40), transparency = 0.3 },
				{ name = "HatBrim", shape = "Block", size = Vector3.new(2.5, 0.2, 2.5), offset = Vector3.new(0, 0.5, 0), color = Color3.fromRGB(30, 30, 30), transparency = 0.3 },
				-- Sword arm (right)
				{ name = "SwordArm", shape = "Block", size = Vector3.new(0.6, 0.6, 3), offset = Vector3.new(1.5, 0.5, 0), color = Color3.fromRGB(180, 180, 180), bodyRelative = true, transparency = 0.2, material = Enum.Material.Metal },
				{ name = "SwordBlade", shape = "Block", size = Vector3.new(0.3, 0.3, 4), offset = Vector3.new(1.5, 0.5, 2), color = Color3.fromRGB(200, 200, 200), bodyRelative = true, transparency = 0.1, material = Enum.Material.Metal },
				-- Glowing eyes
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.2, 0.2, 0.2), offset = Vector3.new(-0.25, 0.15, 0.65), color = Color3.fromRGB(100, 200, 255), material = Enum.Material.Neon, transparency = 0.2 },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.2, 0.2, 0.2), offset = Vector3.new(0.25, 0.15, 0.65), color = Color3.fromRGB(100, 200, 255), material = Enum.Material.Neon, transparency = 0.2 },
				-- Ghostly coat
				{ name = "PirateCoat", shape = "Block", size = Vector3.new(2.2, 3, 1.6), offset = Vector3.new(0, -0.5, 0), color = Color3.fromRGB(60, 40, 80), bodyRelative = true, transparency = 0.5 },
				-- Belt with skull buckle
				{ name = "PirateBelt", shape = "Block", size = Vector3.new(2.3, 0.3, 1.7), offset = Vector3.new(0, -0.5, 0), color = Color3.fromRGB(80, 60, 40), bodyRelative = true, transparency = 0.3 },
				{ name = "SkullBuckle", shape = "Ball", size = Vector3.new(0.4, 0.4, 0.2), offset = Vector3.new(0, -0.5, 0.9), color = Color3.fromRGB(220, 220, 200), bodyRelative = true, transparency = 0.2 },
				-- Ghostly beard
				{ name = "GhostBeard", shape = "Block", size = Vector3.new(0.8, 0.6, 0.4), offset = Vector3.new(0, -0.3, 0.5), color = Color3.fromRGB(150, 150, 150), transparency = 0.5 },
				-- Spectral particles
				{ name = "SpectralMist1", shape = "Ball", size = Vector3.new(0.8, 0.8, 0.8), offset = Vector3.new(-0.5, -2, -0.3), color = Color3.fromRGB(120, 180, 255), bodyRelative = true, transparency = 0.7, material = Enum.Material.Neon },
				{ name = "SpectralMist2", shape = "Ball", size = Vector3.new(0.6, 0.6, 0.6), offset = Vector3.new(0.7, -1.5, 0.2), color = Color3.fromRGB(100, 160, 235), bodyRelative = true, transparency = 0.8, material = Enum.Material.Neon },
			},
		},
	},

	["Ice Elemental"] = {
		name        = "Ice Elemental",
		hp          = 500,
		damage      = 28,
		level       = 40,
		xp          = 300,
		respawnTime = 45,
		zone        = "Safe",
		passive     = false,
		drops = {
			{ item = "Frozen Shard", chance = 0.40, minQty = 1, maxQty = 3 },
			{ item = "Ice Crystal", chance = 0.15, minQty = 1, maxQty = 1 },
			{ item = "Frost Essence", chance = 0.10, minQty = 1, maxQty = 1 },
			{ item = "Permafrost Ore", chance = 0.25, minQty = 1, maxQty = 2 },
		},
		model = {
			bodyColor = Color3.fromRGB(173, 216, 230),
			size = Vector3.new(2.5, 4, 2.5),
			headSize = 1.3,
			extras = {
				-- Crystalline body
				{ name = "CrystalCore", shape = "Block", size = Vector3.new(2.7, 4.2, 2.7), offset = Vector3.new(0, 0, 0), color = Color3.fromRGB(150, 200, 255), bodyRelative = true, transparency = 0.3, material = Enum.Material.Ice },
				-- Ice shards orbiting (small neon cyan parts)
				{ name = "IceShard1", shape = "Block", size = Vector3.new(0.4, 1.2, 0.4), offset = Vector3.new(2.5, 1, 0), color = Color3.fromRGB(0, 255, 255), bodyRelative = true, transparency = 0.2, material = Enum.Material.Neon },
				{ name = "IceShard2", shape = "Block", size = Vector3.new(0.4, 1, 0.4), offset = Vector3.new(-2.3, 0.5, 1), color = Color3.fromRGB(100, 255, 255), bodyRelative = true, transparency = 0.2, material = Enum.Material.Neon },
				{ name = "IceShard3", shape = "Block", size = Vector3.new(0.4, 1.1, 0.4), offset = Vector3.new(1, 2, 2.2), color = Color3.fromRGB(50, 255, 255), bodyRelative = true, transparency = 0.2, material = Enum.Material.Neon },
				{ name = "IceShard4", shape = "Block", size = Vector3.new(0.4, 0.9, 0.4), offset = Vector3.new(-1.5, -1, -2.5), color = Color3.fromRGB(0, 200, 255), bodyRelative = true, transparency = 0.2, material = Enum.Material.Neon },
				{ name = "IceShard5", shape = "Block", size = Vector3.new(0.4, 1.3, 0.4), offset = Vector3.new(0.5, -2, 1.8), color = Color3.fromRGB(70, 220, 255), bodyRelative = true, transparency = 0.2, material = Enum.Material.Neon },
				-- Cold mist base
				{ name = "ColdMist", shape = "Ball", size = Vector3.new(4, 1, 4), offset = Vector3.new(0, -2.2, 0), color = Color3.fromRGB(200, 230, 255), bodyRelative = true, transparency = 0.6, material = Enum.Material.ForceField },
				-- Jagged ice crown
				{ name = "IceCrown", shape = "Block", size = Vector3.new(1.8, 1.5, 1.8), offset = Vector3.new(0, 1, 0), color = Color3.fromRGB(180, 220, 255), transparency = 0.2, material = Enum.Material.Ice },
				{ name = "CrownSpike1", shape = "Block", size = Vector3.new(0.3, 1, 0.3), offset = Vector3.new(0, 1.8, 0.6), color = Color3.fromRGB(150, 200, 255), transparency = 0.1 },
				{ name = "CrownSpike2", shape = "Block", size = Vector3.new(0.3, 0.8, 0.3), offset = Vector3.new(-0.5, 1.7, 0.3), color = Color3.fromRGB(150, 200, 255), transparency = 0.1 },
				{ name = "CrownSpike3", shape = "Block", size = Vector3.new(0.3, 0.9, 0.3), offset = Vector3.new(0.5, 1.7, 0.3), color = Color3.fromRGB(150, 200, 255), transparency = 0.1 },
				-- Glowing eyes
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.3), offset = Vector3.new(-0.3, 0.2, 0.7), color = Color3.fromRGB(0, 255, 255), material = Enum.Material.Neon },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.3), offset = Vector3.new(0.3, 0.2, 0.7), color = Color3.fromRGB(0, 255, 255), material = Enum.Material.Neon },
			},
		},
	},

	["Lava Golem"] = {
		name        = "Lava Golem",
		hp          = 900,
		damage      = 38,
		level       = 55,
		xp          = 500,
		respawnTime = 60,
		zone        = "Wilderness",
		passive     = false,
		drops = {
			{ item = "Magma Core", chance = 0.20, minQty = 1, maxQty = 1 },
			{ item = "Obsidian Shard", chance = 0.35, minQty = 1, maxQty = 3 },
			{ item = "Volcanic Ash", chance = 0.50, minQty = 2, maxQty = 5 },
			{ item = "Lava Blade", chance = 0.03, minQty = 1, maxQty = 1 },
		},
		model = {
			bodyColor = Color3.fromRGB(80, 40, 40),
			size = Vector3.new(3.5, 5, 3),
			headSize = 1.8,
			extras = {
				-- Large dark rock body
				{ name = "RockBody", shape = "Block", size = Vector3.new(3.7, 5.2, 3.2), offset = Vector3.new(0, 0, 0), color = Color3.fromRGB(60, 30, 30), bodyRelative = true, material = Enum.Material.Rock },
				-- Lava cracks (neon orange lines/parts)
				{ name = "LavaCrack1", shape = "Block", size = Vector3.new(0.2, 4, 0.2), offset = Vector3.new(1, 0, 1.7), color = Color3.fromRGB(255, 100, 0), bodyRelative = true, transparency = 0.2, material = Enum.Material.Neon },
				{ name = "LavaCrack2", shape = "Block", size = Vector3.new(0.2, 3.5, 0.2), offset = Vector3.new(-0.8, 0.5, 1.7), color = Color3.fromRGB(255, 69, 0), bodyRelative = true, transparency = 0.2, material = Enum.Material.Neon },
				{ name = "LavaCrack3", shape = "Block", size = Vector3.new(3.2, 0.2, 0.2), offset = Vector3.new(0, -1, 1.7), color = Color3.fromRGB(255, 140, 0), bodyRelative = true, transparency = 0.3, material = Enum.Material.Neon },
				{ name = "LavaCrack4", shape = "Block", size = Vector3.new(2.8, 0.2, 0.2), offset = Vector3.new(0, 1.5, 1.7), color = Color3.fromRGB(255, 100, 0), bodyRelative = true, transparency = 0.2, material = Enum.Material.Neon },
				-- Magma dripping arms
				{ name = "ArmL", shape = "Block", size = Vector3.new(1.2, 4, 1.2), offset = Vector3.new(-3, -0.5, 0), color = Color3.fromRGB(70, 35, 35), bodyRelative = true, material = Enum.Material.Rock },
				{ name = "ArmR", shape = "Block", size = Vector3.new(1.2, 4, 1.2), offset = Vector3.new(3, -0.5, 0), color = Color3.fromRGB(70, 35, 35), bodyRelative = true, material = Enum.Material.Rock },
				{ name = "MagmaDripL", shape = "Ball", size = Vector3.new(0.6, 0.8, 0.6), offset = Vector3.new(-3, -2.8, 0), color = Color3.fromRGB(255, 69, 0), bodyRelative = true, transparency = 0.3, material = Enum.Material.Neon },
				{ name = "MagmaDripR", shape = "Ball", size = Vector3.new(0.6, 0.8, 0.6), offset = Vector3.new(3, -2.8, 0), color = Color3.fromRGB(255, 69, 0), bodyRelative = true, transparency = 0.3, material = Enum.Material.Neon },
				-- Fire eyes
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.4, 0.4, 0.4), offset = Vector3.new(-0.4, 0.3, 1.0), color = Color3.fromRGB(255, 50, 0), material = Enum.Material.Neon },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.4, 0.4, 0.4), offset = Vector3.new(0.4, 0.3, 1.0), color = Color3.fromRGB(255, 50, 0), material = Enum.Material.Neon },
				-- Obsidian horns
				{ name = "HornL", shape = "Block", size = Vector3.new(0.4, 1.5, 0.4), offset = Vector3.new(-0.6, 1.2, 0), color = Color3.fromRGB(20, 20, 20), material = Enum.Material.Glass },
				{ name = "HornR", shape = "Block", size = Vector3.new(0.4, 1.5, 0.4), offset = Vector3.new(0.6, 1.2, 0), color = Color3.fromRGB(20, 20, 20), material = Enum.Material.Glass },
				-- Legs
				{ name = "LegL", shape = "Block", size = Vector3.new(1.5, 3, 1.5), offset = Vector3.new(-1, -4, 0), color = Color3.fromRGB(60, 30, 30), bodyRelative = true, material = Enum.Material.Rock },
				{ name = "LegR", shape = "Block", size = Vector3.new(1.5, 3, 1.5), offset = Vector3.new(1, -4, 0), color = Color3.fromRGB(60, 30, 30), bodyRelative = true, material = Enum.Material.Rock },
			},
		},
	},

	["Fairy Dragon"] = {
		name        = "Fairy Dragon",
		hp          = 350,
		damage      = 20,
		level       = 30,
		xp          = 200,
		respawnTime = 35,
		zone        = "Safe",
		passive     = false,
		drops = {
			{ item = "Fairy Dust", chance = 0.40, minQty = 1, maxQty = 5 },
			{ item = "Dragon Scale", chance = 0.15, minQty = 1, maxQty = 1 },
			{ item = "Enchanted Petal", chance = 0.30, minQty = 1, maxQty = 3 },
			{ item = "Rainbow Gem", chance = 0.05, minQty = 1, maxQty = 1 },
		},
		model = {
			bodyColor = Color3.fromRGB(255, 20, 147),
			size = Vector3.new(2, 3, 4),
			headSize = 1.0,
			extras = {
				-- Small colorful body (pink/purple)
				{ name = "FairyBody", shape = "Block", size = Vector3.new(2.2, 3.2, 4.2), offset = Vector3.new(0, 0, 0), color = Color3.fromRGB(238, 130, 238), bodyRelative = true },
				-- Butterfly wings (thin transparent rainbow parts)
				{ name = "WingLUpper", shape = "Block", size = Vector3.new(0.1, 2.5, 3), offset = Vector3.new(-2.2, 0.5, -1), color = Color3.fromRGB(255, 0, 255), bodyRelative = true, transparency = 0.3, material = Enum.Material.Neon },
				{ name = "WingRUpper", shape = "Block", size = Vector3.new(0.1, 2.5, 3), offset = Vector3.new(2.2, 0.5, -1), color = Color3.fromRGB(255, 0, 255), bodyRelative = true, transparency = 0.3, material = Enum.Material.Neon },
				{ name = "WingLLower", shape = "Block", size = Vector3.new(0.1, 1.8, 2), offset = Vector3.new(-2.0, -1, -0.5), color = Color3.fromRGB(0, 255, 255), bodyRelative = true, transparency = 0.3, material = Enum.Material.Neon },
				{ name = "WingRLower", shape = "Block", size = Vector3.new(0.1, 1.8, 2), offset = Vector3.new(2.0, -1, -0.5), color = Color3.fromRGB(0, 255, 255), bodyRelative = true, transparency = 0.3, material = Enum.Material.Neon },
				-- Sparkle trail
				{ name = "Sparkle1", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.3), offset = Vector3.new(-0.5, 0.5, -2.5), color = Color3.fromRGB(255, 255, 0), bodyRelative = true, transparency = 0.2, material = Enum.Material.Neon },
				{ name = "Sparkle2", shape = "Ball", size = Vector3.new(0.4, 0.4, 0.4), offset = Vector3.new(0.3, -0.3, -3), color = Color3.fromRGB(255, 0, 255), bodyRelative = true, transparency = 0.3, material = Enum.Material.Neon },
				{ name = "Sparkle3", shape = "Ball", size = Vector3.new(0.2, 0.2, 0.2), offset = Vector3.new(0, 1, -2), color = Color3.fromRGB(0, 255, 255), bodyRelative = true, transparency = 0.4, material = Enum.Material.Neon },
				-- Cute face
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.3), offset = Vector3.new(-0.25, 0.2, 0.6), color = Color3.fromRGB(0, 255, 0), material = Enum.Material.Neon },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.3), offset = Vector3.new(0.25, 0.2, 0.6), color = Color3.fromRGB(0, 255, 0), material = Enum.Material.Neon },
				-- Small horns
				{ name = "HornL", shape = "Block", size = Vector3.new(0.2, 0.6, 0.2), offset = Vector3.new(-0.3, 0.7, 0.2), color = Color3.fromRGB(255, 215, 0) },
				{ name = "HornR", shape = "Block", size = Vector3.new(0.2, 0.6, 0.2), offset = Vector3.new(0.3, 0.7, 0.2), color = Color3.fromRGB(255, 215, 0) },
				-- Tail
				{ name = "Tail", shape = "Block", size = Vector3.new(0.8, 0.8, 3), offset = Vector3.new(0, 0, -3.5), color = Color3.fromRGB(255, 105, 180), bodyRelative = true },
				{ name = "TailTip", shape = "Ball", size = Vector3.new(0.6, 0.6, 0.6), offset = Vector3.new(0, 0, -5.2), color = Color3.fromRGB(255, 255, 0), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.2 },
			},
		},
	},

	["Ancient Guardian"] = {
		name        = "Ancient Guardian",
		hp          = 2000,
		damage      = 50,
		level       = 70,
		xp          = 800,
		respawnTime = 90,
		zone        = "Wilderness",
		passive     = false,
		boss        = true,
		drops = {
			{ item = "Ancient Relic", chance = 0.25, minQty = 1, maxQty = 1 },
			{ item = "Guardian Essence", chance = 0.15, minQty = 1, maxQty = 1 },
			{ item = "Rune of Power", chance = 0.05, minQty = 1, maxQty = 1 },
			{ item = "Ancient Armor", chance = 0.03, minQty = 1, maxQty = 1 },
		},
		model = {
			bodyColor = Color3.fromRGB(105, 105, 105),
			size = Vector3.new(6, 8, 4), -- MASSIVE size (4x normal)
			headSize = 2.5,
			extras = {
				-- MASSIVE stone construct
				{ name = "StoneBody", shape = "Block", size = Vector3.new(6.5, 8.5, 4.5), offset = Vector3.new(0, 0, 0), color = Color3.fromRGB(85, 85, 85), bodyRelative = true, material = Enum.Material.Cobblestone },
				-- Glowing rune eyes (neon green)
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.8, 0.8, 0.8), offset = Vector3.new(-0.8, 0.5, 1.4), color = Color3.fromRGB(0, 255, 0), material = Enum.Material.Neon },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.8, 0.8, 0.8), offset = Vector3.new(0.8, 0.5, 1.4), color = Color3.fromRGB(0, 255, 0), material = Enum.Material.Neon },
				-- Cracked stone texture
				{ name = "Crack1", shape = "Block", size = Vector3.new(0.3, 6, 0.3), offset = Vector3.new(1.5, 0, 2.4), color = Color3.fromRGB(40, 40, 40), bodyRelative = true },
				{ name = "Crack2", shape = "Block", size = Vector3.new(5, 0.3, 0.3), offset = Vector3.new(0, 2, 2.4), color = Color3.fromRGB(40, 40, 40), bodyRelative = true },
				{ name = "Crack3", shape = "Block", size = Vector3.new(0.3, 5, 0.3), offset = Vector3.new(-2, -1, 2.4), color = Color3.fromRGB(40, 40, 40), bodyRelative = true },
				-- Floating stone pieces orbiting
				{ name = "FloatStone1", shape = "Ball", size = Vector3.new(1.2, 1.2, 1.2), offset = Vector3.new(4, 2, 1), color = Color3.fromRGB(120, 120, 120), bodyRelative = true, material = Enum.Material.Rock, transparency = 0.1 },
				{ name = "FloatStone2", shape = "Ball", size = Vector3.new(1, 1, 1), offset = Vector3.new(-4.5, 1, -1), color = Color3.fromRGB(110, 110, 110), bodyRelative = true, material = Enum.Material.Rock, transparency = 0.1 },
				{ name = "FloatStone3", shape = "Ball", size = Vector3.new(0.8, 0.8, 0.8), offset = Vector3.new(2, 4, -2), color = Color3.fromRGB(100, 100, 100), bodyRelative = true, material = Enum.Material.Rock, transparency = 0.1 },
				{ name = "FloatStone4", shape = "Ball", size = Vector3.new(1.1, 1.1, 1.1), offset = Vector3.new(-3, -3, 2), color = Color3.fromRGB(130, 130, 130), bodyRelative = true, material = Enum.Material.Rock, transparency = 0.1 },
				-- Ancient weapon arms
				{ name = "WeaponArmL", shape = "Block", size = Vector3.new(1.8, 1.8, 6), offset = Vector3.new(-4.5, 1, 0), color = Color3.fromRGB(80, 80, 80), bodyRelative = true, material = Enum.Material.Cobblestone },
				{ name = "WeaponArmR", shape = "Block", size = Vector3.new(1.8, 1.8, 6), offset = Vector3.new(4.5, 1, 0), color = Color3.fromRGB(80, 80, 80), bodyRelative = true, material = Enum.Material.Cobblestone },
				{ name = "AncientMaceL", shape = "Ball", size = Vector3.new(2.5, 2.5, 2.5), offset = Vector3.new(-4.5, 1, 4), color = Color3.fromRGB(60, 60, 60), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "AncientMaceR", shape = "Ball", size = Vector3.new(2.5, 2.5, 2.5), offset = Vector3.new(4.5, 1, 4), color = Color3.fromRGB(60, 60, 60), bodyRelative = true, material = Enum.Material.Metal },
				-- Ancient legs
				{ name = "LegL", shape = "Block", size = Vector3.new(2, 6, 2), offset = Vector3.new(-1.5, -7, 0), color = Color3.fromRGB(90, 90, 90), bodyRelative = true, material = Enum.Material.Cobblestone },
				{ name = "LegR", shape = "Block", size = Vector3.new(2, 6, 2), offset = Vector3.new(1.5, -7, 0), color = Color3.fromRGB(90, 90, 90), bodyRelative = true, material = Enum.Material.Cobblestone },
				-- Runes on body
				{ name = "BodyRune1", shape = "Block", size = Vector3.new(1, 1, 0.2), offset = Vector3.new(0, 1, 2.4), color = Color3.fromRGB(0, 255, 0), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.3 },
				{ name = "BodyRune2", shape = "Block", size = Vector3.new(0.8, 0.8, 0.2), offset = Vector3.new(-1.5, -1, 2.4), color = Color3.fromRGB(0, 200, 0), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.4 },
				{ name = "BodyRune3", shape = "Ball", size = Vector3.new(1.2, 1.2, 0.2), offset = Vector3.new(1.8, 0, 2.4), color = Color3.fromRGB(50, 255, 50), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.2 },
			},
		},
	},

	["Frost Wyrm"] = {
		name        = "Frost Wyrm",
		hp          = 1200,
		damage      = 42,
		level       = 60,
		xp          = 600,
		respawnTime = 80,
		zone        = "Safe",
		passive     = false,
		boss        = true,
		drops = {
			{ item = "Wyrm Scale", chance = 0.30, minQty = 1, maxQty = 3 },
			{ item = "Frozen Heart", chance = 0.10, minQty = 1, maxQty = 1 },
			{ name = "Ice Fang", chance = 0.05, minQty = 1, maxQty = 1 },
			{ item = "Frost Armor", chance = 0.08, minQty = 1, maxQty = 1 },
		},
		model = {
			bodyColor = Color3.fromRGB(173, 216, 230),
			size = Vector3.new(3, 3, 8), -- long serpentine body
			headSize = 1.8,
			extras = {
				-- Long serpentine body (multiple connected light blue parts)
				{ name = "WyrmSegment1", shape = "Block", size = Vector3.new(2.8, 2.8, 6), offset = Vector3.new(0, 0, -7), color = Color3.fromRGB(150, 200, 255), bodyRelative = true, material = Enum.Material.Ice, transparency = 0.1 },
				{ name = "WyrmSegment2", shape = "Block", size = Vector3.new(2.5, 2.5, 5), offset = Vector3.new(0, 0, -12.5), color = Color3.fromRGB(140, 190, 245), bodyRelative = true, material = Enum.Material.Ice, transparency = 0.1 },
				{ name = "WyrmSegment3", shape = "Block", size = Vector3.new(2.2, 2.2, 4), offset = Vector3.new(0, 0, -17), color = Color3.fromRGB(130, 180, 235), bodyRelative = true, material = Enum.Material.Ice, transparency = 0.1 },
				{ name = "WyrmTail", shape = "Block", size = Vector3.new(1.8, 1.8, 3), offset = Vector3.new(0, 0, -20.5), color = Color3.fromRGB(120, 170, 225), bodyRelative = true, material = Enum.Material.Ice, transparency = 0.1 },
				-- Ice horns
				{ name = "IceHornL", shape = "Block", size = Vector3.new(0.5, 2, 0.5), offset = Vector3.new(-0.7, 1.5, 0.3), color = Color3.fromRGB(200, 230, 255), material = Enum.Material.Ice, transparency = 0.1 },
				{ name = "IceHornR", shape = "Block", size = Vector3.new(0.5, 2, 0.5), offset = Vector3.new(0.7, 1.5, 0.3), color = Color3.fromRGB(200, 230, 255), material = Enum.Material.Ice, transparency = 0.1 },
				-- Frost breath particles
				{ name = "FrostBreath1", shape = "Ball", size = Vector3.new(1.5, 1, 1.5), offset = Vector3.new(-0.3, -0.2, 2.5), color = Color3.fromRGB(220, 240, 255), material = Enum.Material.Neon, transparency = 0.5 },
				{ name = "FrostBreath2", shape = "Ball", size = Vector3.new(1.2, 0.8, 1.2), offset = Vector3.new(0.2, 0.1, 3.2), color = Color3.fromRGB(200, 220, 255), material = Enum.Material.Neon, transparency = 0.6 },
				{ name = "FrostBreath3", shape = "Ball", size = Vector3.new(0.8, 0.6, 0.8), offset = Vector3.new(0, -0.3, 4), color = Color3.fromRGB(180, 200, 255), material = Enum.Material.Neon, transparency = 0.7 },
				-- Crystal scales
				{ name = "CrystalScale1", shape = "Block", size = Vector3.new(0.6, 0.6, 0.3), offset = Vector3.new(1.2, 0.8, 1), color = Color3.fromRGB(180, 220, 255), material = Enum.Material.Ice, transparency = 0.2 },
				{ name = "CrystalScale2", shape = "Block", size = Vector3.new(0.5, 0.5, 0.3), offset = Vector3.new(-1.3, 0.9, -1), color = Color3.fromRGB(170, 210, 245), material = Enum.Material.Ice, transparency = 0.2 },
				{ name = "CrystalScale3", shape = "Block", size = Vector3.new(0.7, 0.7, 0.3), offset = Vector3.new(0, 1.2, -3), color = Color3.fromRGB(190, 230, 255), material = Enum.Material.Ice, transparency = 0.2 },
				-- Ice tail spike
				{ name = "TailSpike", shape = "Block", size = Vector3.new(1, 1, 2.5), offset = Vector3.new(0, 0, -22.7), color = Color3.fromRGB(150, 190, 230), bodyRelative = true, material = Enum.Material.Ice, transparency = 0.1 },
				-- Glowing eyes
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.4, 0.4, 0.4), offset = Vector3.new(-0.5, 0.3, 1.0), color = Color3.fromRGB(100, 200, 255), material = Enum.Material.Neon },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.4, 0.4, 0.4), offset = Vector3.new(0.5, 0.3, 1.0), color = Color3.fromRGB(100, 200, 255), material = Enum.Material.Neon },
			},
		},
	},
	["Lich King Malachar"] = {
		name        = "Lich King Malachar",
		hp          = 4000,
		damage      = 75,
		level       = 90,
		xp          = 1350,
		respawnTime = 600,
		zone        = "Wilderness",
		passive     = false,
		boss        = true,
		drops = {
			{ item = "Lich Crown",     chance = 0.03, minQty = 1, maxQty = 1 },
			{ item = "Soul Staff",     chance = 0.02, minQty = 1, maxQty = 1 },
			{ item = "Dark Essence",   chance = 0.15, minQty = 1, maxQty = 1 },
			{ item = "Necrotic Robe",  chance = 0.05, minQty = 1, maxQty = 1 },
			{ item = "Bone Dust",      chance = 0.40, minQty = 5, maxQty = 5 },
			{ item = "Shadow Gem",     chance = 0.10, minQty = 1, maxQty = 1 },
		},
		model = {
			bodyColor = Color3.fromRGB(20, 20, 30),
			size = Vector3.new(3, 6, 2),
			headSize = 1.5,
			extras = {
				-- SKELETAL BODY: Gaunt undead form visible through robes
				{ name = "Ribcage", shape = "Block", size = Vector3.new(2.5, 3, 1.5), offset = Vector3.new(0, 1, 0), color = Color3.fromRGB(200, 195, 180), bodyRelative = true },
				{ name = "Rib1", shape = "Block", size = Vector3.new(2.8, 0.12, 0.8), offset = Vector3.new(0, 2.0, 0), color = Color3.fromRGB(210, 205, 190), bodyRelative = true },
				{ name = "Rib2", shape = "Block", size = Vector3.new(2.8, 0.12, 0.8), offset = Vector3.new(0, 1.5, 0), color = Color3.fromRGB(210, 205, 190), bodyRelative = true },
				{ name = "Rib3", shape = "Block", size = Vector3.new(2.8, 0.12, 0.8), offset = Vector3.new(0, 1.0, 0), color = Color3.fromRGB(210, 205, 190), bodyRelative = true },
				{ name = "Spine", shape = "Block", size = Vector3.new(0.4, 5, 0.4), offset = Vector3.new(0, 0, 0), color = Color3.fromRGB(200, 195, 180), bodyRelative = true },
				-- DARK ROBES: Flowing tattered robes
				{ name = "RobeUpper", shape = "Block", size = Vector3.new(3.5, 4, 2.5), offset = Vector3.new(0, 0, 0), color = Color3.fromRGB(15, 10, 25), bodyRelative = true, material = Enum.Material.Fabric },
				{ name = "RobeSkirt", shape = "Block", size = Vector3.new(4, 3, 3), offset = Vector3.new(0, -3.5, 0), color = Color3.fromRGB(12, 8, 20), bodyRelative = true, material = Enum.Material.Fabric },
				{ name = "RobeHem", shape = "Block", size = Vector3.new(4.5, 0.3, 3.5), offset = Vector3.new(0, -5, 0), color = Color3.fromRGB(8, 5, 15), bodyRelative = true, material = Enum.Material.Fabric },
				{ name = "RobeTrim", shape = "Block", size = Vector3.new(0.15, 5, 0.1), offset = Vector3.new(0, -2, 1.3), color = Color3.fromRGB(60, 0, 80), bodyRelative = true },
				-- HOOD: Oversized dark hood
				{ name = "Hood", shape = "Block", size = Vector3.new(2.0, 1.2, 1.8), offset = Vector3.new(0, 0.8, -0.2), color = Color3.fromRGB(12, 8, 22) },
				{ name = "HoodPeak", shape = "Block", size = Vector3.new(1.2, 0.8, 1.0), offset = Vector3.new(0, 1.5, -0.3), color = Color3.fromRGB(8, 5, 18) },
				-- SKULL FACE: Skeletal head with glowing green eyes
				{ name = "SkullFace", shape = "Block", size = Vector3.new(1.0, 1.0, 0.6), offset = Vector3.new(0, 0, 0.5), color = Color3.fromRGB(220, 215, 200) },
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.35, 0.35, 0.35), offset = Vector3.new(-0.3, 0.2, 0.8), color = Color3.fromRGB(0, 255, 80), material = Enum.Material.Neon },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.35, 0.35, 0.35), offset = Vector3.new(0.3, 0.2, 0.8), color = Color3.fromRGB(0, 255, 80), material = Enum.Material.Neon },
				{ name = "JawBone", shape = "Block", size = Vector3.new(0.8, 0.25, 0.5), offset = Vector3.new(0, -0.4, 0.5), color = Color3.fromRGB(210, 205, 190) },
				-- CROWN OF BONES: Jagged bone crown
				{ name = "CrownBase", shape = "Block", size = Vector3.new(1.6, 0.2, 1.6), offset = Vector3.new(0, 0.6, 0), color = Color3.fromRGB(200, 195, 175) },
				{ name = "CrownSpike1", shape = "Block", size = Vector3.new(0.12, 0.8, 0.12), offset = Vector3.new(0, 1.1, 0.6), color = Color3.fromRGB(200, 195, 175) },
				{ name = "CrownSpike2", shape = "Block", size = Vector3.new(0.12, 1.0, 0.12), offset = Vector3.new(0.5, 1.2, 0.3), color = Color3.fromRGB(200, 195, 175) },
				{ name = "CrownSpike3", shape = "Block", size = Vector3.new(0.12, 0.9, 0.12), offset = Vector3.new(-0.5, 1.15, 0.3), color = Color3.fromRGB(200, 195, 175) },
				{ name = "CrownSpike4", shape = "Block", size = Vector3.new(0.12, 0.7, 0.12), offset = Vector3.new(0.5, 1.0, -0.3), color = Color3.fromRGB(200, 195, 175) },
				{ name = "CrownSpike5", shape = "Block", size = Vector3.new(0.12, 0.85, 0.12), offset = Vector3.new(-0.5, 1.1, -0.3), color = Color3.fromRGB(200, 195, 175) },
				{ name = "CrownGem", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.3), offset = Vector3.new(0, 1.15, 0.65), color = Color3.fromRGB(0, 255, 80), material = Enum.Material.Neon },
				-- STAFF WITH SKULL: Held in right hand
				{ name = "Staff", shape = "Block", size = Vector3.new(0.3, 7, 0.3), offset = Vector3.new(2.0, 0.5, 0), color = Color3.fromRGB(40, 20, 15), bodyRelative = true, material = Enum.Material.Wood },
				{ name = "StaffSkull", shape = "Ball", size = Vector3.new(0.8, 0.8, 0.8), offset = Vector3.new(2.0, 4.3, 0), color = Color3.fromRGB(220, 215, 200), bodyRelative = true },
				{ name = "StaffSkullGlow", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.3), offset = Vector3.new(2.0, 4.3, 0.4), color = Color3.fromRGB(0, 255, 80), bodyRelative = true, material = Enum.Material.Neon },
				{ name = "StaffRing1", shape = "Block", size = Vector3.new(0.5, 0.1, 0.5), offset = Vector3.new(2.0, 3.5, 0), color = Color3.fromRGB(80, 60, 30), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "StaffRing2", shape = "Block", size = Vector3.new(0.5, 0.1, 0.5), offset = Vector3.new(2.0, 2.5, 0), color = Color3.fromRGB(80, 60, 30), bodyRelative = true, material = Enum.Material.Metal },
				-- FLOATING SPELL BOOK: In left hand, open and glowing
				{ name = "SpellBookL", shape = "Block", size = Vector3.new(0.08, 1.0, 0.8), offset = Vector3.new(-2.0, 0.5, 0.5), color = Color3.fromRGB(40, 15, 15), bodyRelative = true },
				{ name = "SpellBookR", shape = "Block", size = Vector3.new(0.08, 1.0, 0.8), offset = Vector3.new(-1.85, 0.5, 0.5), color = Color3.fromRGB(40, 15, 15), bodyRelative = true },
				{ name = "SpellBookPages", shape = "Block", size = Vector3.new(0.03, 0.9, 0.75), offset = Vector3.new(-1.93, 0.5, 0.5), color = Color3.fromRGB(0, 200, 60), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.3 },
				-- SOUL ORBS: 3 orbiting spectral green orbs
				{ name = "SoulOrb1", shape = "Ball", size = Vector3.new(0.7, 0.7, 0.7), offset = Vector3.new(2.5, 3, 1.5), color = Color3.fromRGB(0, 255, 80), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.3 },
				{ name = "SoulOrb2", shape = "Ball", size = Vector3.new(0.6, 0.6, 0.6), offset = Vector3.new(-2.8, 2, -1), color = Color3.fromRGB(0, 220, 60), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.35 },
				{ name = "SoulOrb3", shape = "Ball", size = Vector3.new(0.5, 0.5, 0.5), offset = Vector3.new(0.5, 4, -0.5), color = Color3.fromRGB(0, 200, 50), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.4 },
				{ name = "SoulTrail1", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.8), offset = Vector3.new(2.0, 2.8, 1.0), color = Color3.fromRGB(0, 180, 50), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.6 },
				{ name = "SoulTrail2", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.6), offset = Vector3.new(-2.3, 1.8, -0.5), color = Color3.fromRGB(0, 180, 50), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.65 },
				-- SKELETAL ARMS: Bony arms reaching from robes
				{ name = "ArmL", shape = "Block", size = Vector3.new(0.3, 3.5, 0.3), offset = Vector3.new(-1.8, -0.5, 0), color = Color3.fromRGB(200, 195, 180), bodyRelative = true },
				{ name = "ArmR", shape = "Block", size = Vector3.new(0.3, 3.5, 0.3), offset = Vector3.new(1.8, -0.5, 0), color = Color3.fromRGB(200, 195, 180), bodyRelative = true },
				{ name = "HandL", shape = "Block", size = Vector3.new(0.4, 0.3, 0.4), offset = Vector3.new(-1.8, -2.5, 0.3), color = Color3.fromRGB(200, 195, 180), bodyRelative = true },
				{ name = "HandR", shape = "Block", size = Vector3.new(0.4, 0.3, 0.4), offset = Vector3.new(1.8, -2.5, 0.3), color = Color3.fromRGB(200, 195, 180), bodyRelative = true },
				-- NECROTIC ENERGY: Green magic circle at feet
				{ name = "MagicCircle", shape = "Block", size = Vector3.new(6, 0.05, 6), offset = Vector3.new(0, -5.2, 0), color = Color3.fromRGB(0, 180, 50), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.4 },
				{ name = "MagicInner", shape = "Ball", size = Vector3.new(4, 0.08, 4), offset = Vector3.new(0, -5.18, 0), color = Color3.fromRGB(0, 150, 40), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.5 },
				-- DEATH MIST: Swirling dark green fog
				{ name = "DeathMist1", shape = "Ball", size = Vector3.new(3, 1.5, 3), offset = Vector3.new(1, -4, 1), color = Color3.fromRGB(0, 80, 30), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.7 },
				{ name = "DeathMist2", shape = "Ball", size = Vector3.new(2.5, 1, 2.5), offset = Vector3.new(-1.5, -4.5, -1), color = Color3.fromRGB(0, 60, 20), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.75 },
				-- SHOULDER PAULDRONS: Dark armor on shoulders
				{ name = "PauldronL", shape = "Block", size = Vector3.new(1.2, 0.6, 1.2), offset = Vector3.new(-2.2, 2.5, 0), color = Color3.fromRGB(30, 20, 40), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "PauldronR", shape = "Block", size = Vector3.new(1.2, 0.6, 1.2), offset = Vector3.new(2.2, 2.5, 0), color = Color3.fromRGB(30, 20, 40), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "PauldronSpikeL", shape = "Block", size = Vector3.new(0.15, 0.6, 0.15), offset = Vector3.new(-2.2, 3.2, 0), color = Color3.fromRGB(200, 195, 175), bodyRelative = true },
				{ name = "PauldronSpikeR", shape = "Block", size = Vector3.new(0.15, 0.6, 0.15), offset = Vector3.new(2.2, 3.2, 0), color = Color3.fromRGB(200, 195, 175), bodyRelative = true },
			},
		},
	},
	----------------------------------------------------------------------------
	-- CRIMSON WARLORD — Mid-tier Safe Zone Centerpiece Boss (Lv55)
	-- A towering armored warrior king wielding a massive greatsword.
	-- Crimson/black armor with glowing red accents, battle-worn cape,
	-- horned crown, and a burning aura. THE mid-game boss to farm.
	----------------------------------------------------------------------------
	["Crimson Warlord"] = {
		name        = "Crimson Warlord",
		hp          = 1800,
		damage      = 45,
		level       = 55,
		xp          = 825,
		respawnTime = 180,
		zone        = "Safe",
		passive     = false,
		boss        = true,
		drops = {
			-- Signature drops — powerful Lv50 gear
			{ item = "Warlord's Greatsword",  chance = 0.20, minQty = 1, maxQty = 1 },
			{ item = "Crimson Platebody",     chance = 0.18, minQty = 1, maxQty = 1 },
			{ item = "Crimson Platelegs",     chance = 0.22, minQty = 1, maxQty = 1 },
			{ item = "Warlord's Helm",        chance = 0.15, minQty = 1, maxQty = 1 },
			{ item = "Crimson Cape",          chance = 0.08, minQty = 1, maxQty = 1 },
			{ item = "Warlord's Shield",      chance = 0.12, minQty = 1, maxQty = 1 },
			-- Common drops
			{ item = "Gold Bar",              chance = 1.00, minQty = 5, maxQty = 12 },
			{ item = "Lobster",               chance = 0.80, minQty = 3, maxQty = 5 },
			{ item = "Iron Ore",              chance = 0.60, minQty = 5, maxQty = 10 },
			{ item = "Blood Rune",            chance = 0.35, minQty = 1, maxQty = 3 },
		},
		model = {
			bodyColor = Color3.fromRGB(100, 20, 20),
			size = Vector3.new(4, 5.5, 3),
			headSize = 1.8,
			elevation = 3,
			extras = {
				-- === ARMOR PLATING (layered over body) ===
				{ name = "ChestPlate", shape = "Block", size = Vector3.new(4.3, 4, 3.3), offset = Vector3.new(0, 0.5, 0), color = Color3.fromRGB(40, 8, 8), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "AbdomenPlate", shape = "Block", size = Vector3.new(3.8, 2, 2.8), offset = Vector3.new(0, -1.5, 0), color = Color3.fromRGB(30, 5, 5), bodyRelative = true, material = Enum.Material.Metal },

				-- === MASSIVE LEGS ===
				-- Upper legs (thighs)
				{ name = "ThighL", shape = "Block", size = Vector3.new(1.6, 3, 1.6), offset = Vector3.new(-1.2, -4.5, 0), color = Color3.fromRGB(35, 8, 8), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "ThighR", shape = "Block", size = Vector3.new(1.6, 3, 1.6), offset = Vector3.new(1.2, -4.5, 0), color = Color3.fromRGB(35, 8, 8), bodyRelative = true, material = Enum.Material.Metal },
				-- Lower legs (greaves)
				{ name = "GreaveL", shape = "Block", size = Vector3.new(1.4, 3, 1.4), offset = Vector3.new(-1.2, -7.5, 0), color = Color3.fromRGB(50, 12, 12), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "GreaveR", shape = "Block", size = Vector3.new(1.4, 3, 1.4), offset = Vector3.new(1.2, -7.5, 0), color = Color3.fromRGB(50, 12, 12), bodyRelative = true, material = Enum.Material.Metal },
				-- Boots (wide base)
				{ name = "BootL", shape = "Block", size = Vector3.new(1.6, 1, 2), offset = Vector3.new(-1.2, -9.5, 0.2), color = Color3.fromRGB(25, 5, 5), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "BootR", shape = "Block", size = Vector3.new(1.6, 1, 2), offset = Vector3.new(1.2, -9.5, 0.2), color = Color3.fromRGB(25, 5, 5), bodyRelative = true, material = Enum.Material.Metal },

				-- === MASSIVE ARMS ===
				-- Shoulder pauldrons (huge spiked)
				{ name = "PauldronL", shape = "Block", size = Vector3.new(2.2, 1.2, 2.2), offset = Vector3.new(-3.2, 2.5, 0), color = Color3.fromRGB(50, 10, 10), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "PauldronR", shape = "Block", size = Vector3.new(2.2, 1.2, 2.2), offset = Vector3.new(3.2, 2.5, 0), color = Color3.fromRGB(50, 10, 10), bodyRelative = true, material = Enum.Material.Metal },
				-- Pauldron spikes
				{ name = "SpikeL1", shape = "Block", size = Vector3.new(0.3, 1.5, 0.3), offset = Vector3.new(-3.5, 3.8, 0), color = Color3.fromRGB(180, 30, 30), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "SpikeR1", shape = "Block", size = Vector3.new(0.3, 1.5, 0.3), offset = Vector3.new(3.5, 3.8, 0), color = Color3.fromRGB(180, 30, 30), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "SpikeL2", shape = "Block", size = Vector3.new(0.2, 1.0, 0.2), offset = Vector3.new(-3.8, 3.5, 0.5), color = Color3.fromRGB(160, 25, 25), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "SpikeR2", shape = "Block", size = Vector3.new(0.2, 1.0, 0.2), offset = Vector3.new(3.8, 3.5, 0.5), color = Color3.fromRGB(160, 25, 25), bodyRelative = true, material = Enum.Material.Metal },
				-- Upper arms
				{ name = "ArmUpL", shape = "Block", size = Vector3.new(1.4, 2.5, 1.4), offset = Vector3.new(-3.2, 0, 0), color = Color3.fromRGB(40, 8, 8), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "ArmUpR", shape = "Block", size = Vector3.new(1.4, 2.5, 1.4), offset = Vector3.new(3.2, 0, 0), color = Color3.fromRGB(40, 8, 8), bodyRelative = true, material = Enum.Material.Metal },
				-- Gauntlets (forearms)
				{ name = "GauntletL", shape = "Block", size = Vector3.new(1.2, 2.5, 1.2), offset = Vector3.new(-3.2, -2.5, 0.5), color = Color3.fromRGB(55, 12, 12), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "GauntletR", shape = "Block", size = Vector3.new(1.2, 2.5, 1.2), offset = Vector3.new(3.2, -2.5, 0.5), color = Color3.fromRGB(55, 12, 12), bodyRelative = true, material = Enum.Material.Metal },

				-- === THE GREATSWORD (right hand, massive) ===
				-- Handle
				{ name = "SwordHandle", shape = "Block", size = Vector3.new(0.3, 2.5, 0.3), offset = Vector3.new(3.5, -4.5, 1.5), color = Color3.fromRGB(60, 30, 15), bodyRelative = true, material = Enum.Material.Wood },
				-- Crossguard
				{ name = "SwordGuard", shape = "Block", size = Vector3.new(2.5, 0.4, 0.5), offset = Vector3.new(3.5, -3.0, 1.5), color = Color3.fromRGB(180, 30, 30), bodyRelative = true, material = Enum.Material.Metal },
				-- Blade (long and wide)
				{ name = "SwordBlade", shape = "Block", size = Vector3.new(0.8, 6, 0.15), offset = Vector3.new(3.5, 0.5, 1.5), color = Color3.fromRGB(200, 200, 210), bodyRelative = true, material = Enum.Material.Metal },
				-- Blade edge glow
				{ name = "SwordGlow", shape = "Block", size = Vector3.new(0.4, 5.5, 0.08), offset = Vector3.new(3.5, 0.5, 1.58), color = Color3.fromRGB(255, 40, 40), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.3 },
				-- Blade tip
				{ name = "SwordTip", shape = "Block", size = Vector3.new(0.5, 1, 0.15), offset = Vector3.new(3.5, 3.8, 1.5), color = Color3.fromRGB(200, 200, 210), bodyRelative = true, material = Enum.Material.Metal, rotation = Vector3.new(0, 0, 15) },

				-- === SHIELD (left hand) ===
				{ name = "ShieldFace", shape = "Block", size = Vector3.new(0.4, 3.5, 2.5), offset = Vector3.new(-3.8, -2, 1), color = Color3.fromRGB(40, 8, 8), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "ShieldBoss", shape = "Ball", size = Vector3.new(0.8, 0.8, 0.8), offset = Vector3.new(-4.1, -1.5, 1), color = Color3.fromRGB(180, 30, 30), bodyRelative = true, material = Enum.Material.Metal },
				{ name = "ShieldRim", shape = "Block", size = Vector3.new(0.1, 3.8, 2.8), offset = Vector3.new(-4.2, -2, 1), color = Color3.fromRGB(180, 30, 30), bodyRelative = true, material = Enum.Material.Metal },

				-- === HORNED CROWN ===
				{ name = "CrownBase", shape = "Block", size = Vector3.new(2.2, 0.6, 2.2), offset = Vector3.new(0, 1.5, 0), color = Color3.fromRGB(180, 30, 30), material = Enum.Material.Metal },
				{ name = "CrownHornL", shape = "Block", size = Vector3.new(0.25, 1.8, 0.25), offset = Vector3.new(-0.8, 2.8, 0), color = Color3.fromRGB(30, 5, 5), material = Enum.Material.Metal, rotation = Vector3.new(0, 0, -15) },
				{ name = "CrownHornR", shape = "Block", size = Vector3.new(0.25, 1.8, 0.25), offset = Vector3.new(0.8, 2.8, 0), color = Color3.fromRGB(30, 5, 5), material = Enum.Material.Metal, rotation = Vector3.new(0, 0, 15) },
				{ name = "CrownGem", shape = "Ball", size = Vector3.new(0.5, 0.5, 0.5), offset = Vector3.new(0, 1.8, 1.0), color = Color3.fromRGB(255, 20, 20), material = Enum.Material.Neon },

				-- === GLOWING RED EYES ===
				{ name = "EyeL", shape = "Ball", size = Vector3.new(0.4, 0.4, 0.4), offset = Vector3.new(-0.5, 0.4, 1.0), color = Color3.fromRGB(255, 0, 0), material = Enum.Material.Neon },
				{ name = "EyeR", shape = "Ball", size = Vector3.new(0.4, 0.4, 0.4), offset = Vector3.new(0.5, 0.4, 1.0), color = Color3.fromRGB(255, 0, 0), material = Enum.Material.Neon },

				-- === BATTLE CAPE (flowing behind) ===
				{ name = "CapeTop", shape = "Block", size = Vector3.new(3.5, 2, 0.2), offset = Vector3.new(0, 1, -1.8), color = Color3.fromRGB(120, 15, 15), bodyRelative = true, material = Enum.Material.Fabric },
				{ name = "CapeMid", shape = "Block", size = Vector3.new(3.2, 3, 0.15), offset = Vector3.new(0, -1.5, -2.2), color = Color3.fromRGB(100, 12, 12), bodyRelative = true, material = Enum.Material.Fabric },
				{ name = "CapeBottom", shape = "Block", size = Vector3.new(2.8, 2, 0.1), offset = Vector3.new(0, -4, -2.5), color = Color3.fromRGB(80, 10, 10), bodyRelative = true, material = Enum.Material.Fabric },
				-- Cape trim (gold)
				{ name = "CapeTrimBottom", shape = "Block", size = Vector3.new(3.0, 0.15, 0.12), offset = Vector3.new(0, -5, -2.5), color = Color3.fromRGB(255, 200, 50), bodyRelative = true, material = Enum.Material.Metal },

				-- === CRIMSON AURA (ground effect) ===
				{ name = "AuraRing", shape = "Block", size = Vector3.new(8, 0.1, 8), offset = Vector3.new(0, -9.8, 0), color = Color3.fromRGB(180, 0, 0), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.5 },
				{ name = "AuraInner", shape = "Ball", size = Vector3.new(6, 0.15, 6), offset = Vector3.new(0, -9.75, 0), color = Color3.fromRGB(255, 30, 30), bodyRelative = true, material = Enum.Material.Neon, transparency = 0.6 },
				-- Floating embers around body
				{ name = "Ember1", shape = "Ball", size = Vector3.new(0.3, 0.3, 0.3), offset = Vector3.new(2, 3.5, 1.5), color = Color3.fromRGB(255, 100, 0), bodyRelative = true, material = Enum.Material.Neon },
				{ name = "Ember2", shape = "Ball", size = Vector3.new(0.25, 0.25, 0.25), offset = Vector3.new(-1.5, 4, -1), color = Color3.fromRGB(255, 60, 0), bodyRelative = true, material = Enum.Material.Neon },
				{ name = "Ember3", shape = "Ball", size = Vector3.new(0.2, 0.2, 0.2), offset = Vector3.new(0.5, 5, 0.8), color = Color3.fromRGB(255, 150, 30), bodyRelative = true, material = Enum.Material.Neon },

				-- === BELT WITH SKULL BUCKLE ===
				{ name = "Belt", shape = "Block", size = Vector3.new(4.1, 0.5, 3.1), offset = Vector3.new(0, -0.8, 0), color = Color3.fromRGB(60, 30, 15), bodyRelative = true, material = Enum.Material.Leather },
				{ name = "BeltBuckle", shape = "Ball", size = Vector3.new(0.7, 0.7, 0.7), offset = Vector3.new(0, -0.8, 1.6), color = Color3.fromRGB(255, 200, 50), bodyRelative = true, material = Enum.Material.Metal },
			},
		},
	},
}

return MonsterDatabase
