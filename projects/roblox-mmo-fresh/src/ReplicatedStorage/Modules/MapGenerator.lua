-- MapGenerator.lua
-- Comprehensive terrain and world generation system

local MapGenerator = {}

-- Dependencies
local Config = require(script.Parent.Config)

-- Helper functions
local function createPart(name, size, position, color, material, parent, properties)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.CanCollide = true
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Parent = parent
	
	-- Apply additional properties if provided
	if properties then
		for key, value in pairs(properties) do
			part[key] = value
		end
	end
	
	return part
end

local function createWedge(name, size, position, color, material, parent)
	local wedge = Instance.new("WedgePart")
	wedge.Name = name
	wedge.Size = size
	wedge.Position = position
	wedge.Anchored = true
	wedge.CanCollide = true
	wedge.Color = color
	wedge.Material = material or Enum.Material.SmoothPlastic
	wedge.Parent = parent
	return wedge
end

local function createTerrainVoxel(position, size, material, color)
	-- This would use Roblox's Terrain API in a real implementation
	-- For now, we'll use parts
	return createPart("TerrainVoxel", size, position, color, material, workspace)
end

local function addDecal(part, texture, face)
	local decal = Instance.new("Decal")
	decal.Texture = texture
	decal.Face = face
	decal.Parent = part
	return decal
end

local function createTree(position, treeType, parent)
	local config = Config.RESOURCES.TREES[treeType]
	if not config then config = Config.RESOURCES.TREES.OAK end
	
	-- Trunk
	local trunk = createPart(
		treeType .. "Trunk",
		Vector3.new(config.trunkRadius * 2, config.height, config.trunkRadius * 2),
		position,
		config.color,
		Enum.Material.Wood,
		parent
	)
	
	-- Leaves (sphere approximation with parts)
	local leavesRadius = config.trunkRadius * 3
	for x = -1, 1 do
		for y = -1, 1 do
			for z = -1, 1 do
				if math.random(1, 3) > 1 then -- 66% chance for each leaf cluster
					local leafPos = position + Vector3.new(
						x * leavesRadius * 0.8,
						config.height/2 + y * leavesRadius * 0.6,
						z * leavesRadius * 0.8
					)
					
					local leaves = createPart(
						treeType .. "Leaves",
						Vector3.new(leavesRadius, leavesRadius, leavesRadius),
						leafPos,
						Color3.fromRGB(34, 139, 34),
						Enum.Material.Neon,
						parent
					)
					leaves.Transparency = 0.3
				end
			end
		end
	end
	
	return trunk
end

local function createRock(position, rockType, parent)
	local config = Config.RESOURCES.ROCKS[rockType]
	if not config then config = Config.RESOURCES.ROCKS.COAL end
	
	local rock = createPart(
		rockType .. "Rock",
		config.size,
		position,
		config.color,
		Enum.Material.Slate,
		parent
	)
	
	-- Make it look more natural
	rock.Material = Enum.Material.Cobblestone
	rock.Size = config.size + Vector3.new(
		math.random(-1, 1),
		math.random(-0.5, 0.5),
		math.random(-1, 1)
	)
	
	return rock
end

local function createWater(position, size, parent)
	local water = createPart(
		"Water",
		size,
		position,
		Color3.fromRGB(64, 164, 223),
		Enum.Material.Water,
		parent,
		{Transparency = 0.3}
	)
	
	-- Add wave effect
	water.Material = Enum.Material.Water
	water.Transparency = 0.5
	water.Reflectance = 0.3
	
	return water
end

local function createBuilding(position, size, color, material, roofColor, parent)
	-- Main building
	local building = createPart("Building", size, position, color, material, parent)
	
	-- Roof (pyramid style)
	local roofHeight = size.Y / 3
	for i = 1, 4 do
		local wedgeSize = Vector3.new(size.X, roofHeight, size.Z)
		local wedge = createWedge(
			"RoofWedge" .. i,
			wedgeSize,
			position + Vector3.new(0, size.Y/2 + roofHeight/2, 0),
			roofColor,
			material,
			parent
		)
		
		-- Rotate each wedge to form pyramid
		local angle = (i-1) * 90
		wedge.CFrame = CFrame.new(wedge.Position) * CFrame.Angles(0, math.rad(angle), math.rad(90))
	end
	
	-- Door
	local door = createPart(
		"Door",
		Vector3.new(4, 8, 1),
		position + Vector3.new(0, -size.Y/2 + 4, size.Z/2 + 0.5),
		Color3.fromRGB(139, 69, 19),
		Enum.Material.Wood,
		parent
	)
	
	-- Windows
	for x = -1, 1, 2 do
		for y = 0, 1 do
			local window = createPart(
				"Window",
				Vector3.new(3, 3, 1),
				position + Vector3.new(x * size.X/3, y * 6 - 2, size.Z/2 + 0.5),
				Color3.fromRGB(200, 230, 255),
				Enum.Material.Glass,
				parent,
				{Transparency = 0.7}
			)
		end
	end
	
	return building
end

local function createRoad(startPos, endPos, width, parent)
	local direction = (endPos - startPos)
	local length = direction.Magnitude
	local center = startPos + direction/2
	
	local road = createPart(
		"Road",
		Vector3.new(width, 1, length),
		center,
		Color3.fromRGB(100, 100, 100),
		Enum.Material.Asphalt,
		parent
	)
	
	-- Rotate to face the right direction
	road.CFrame = CFrame.new(center, endPos) * CFrame.new(0, 0, -length/2)
	
	-- Add road markings
	if length > 30 then
		local markingCount = math.floor(length / 15)
		for i = 1, markingCount do
			local t = i / (markingCount + 1)
			local markingPos = startPos + direction * t
			
			local marking = createPart(
				"RoadMarking",
				Vector3.new(0.5, 0.2, 2),
				markingPos + Vector3.new(0, 0.6, 0),
				Color3.fromRGB(255, 255, 255),
				Enum.Material.Neon,
				parent
			)
			marking.CFrame = CFrame.new(marking.Position, endPos)
		end
	end
	
	return road
end

local function createWall(startPos, endPos, height, parent)
	local direction = (endPos - startPos)
	local length = direction.Magnitude
	local center = startPos + direction/2
	
	local wall = createPart(
		"Wall",
		Vector3.new(3, height, length),
		center + Vector3.new(0, height/2, 0),
		Color3.fromRGB(150, 150, 150),
		Enum.Material.Concrete,
		parent
	)
	
	-- Rotate to face the right direction
	wall.CFrame = CFrame.new(center, endPos) * CFrame.new(0, height/2, -length/2)
	
	-- Add battlements
	if height > 10 then
		local battlementCount = math.floor(length / 8)
		for i = 0, battlementCount do
			local t = i / battlementCount
			local battlementPos = startPos + direction * t
			
			local battlement = createPart(
				"Battlement",
				Vector3.new(4, 3, 4),
				battlementPos + Vector3.new(0, height + 1.5, 0),
				Color3.fromRGB(120, 120, 120),
				Enum.Material.Concrete,
				parent
			)
			battlement.CFrame = CFrame.new(battlement.Position, endPos)
		end
	end
	
	return wall
end

-- Public API
function MapGenerator.GenerateHavenCity(parent)
	print("[MapGenerator] Generating Haven City...")
	
	local cityFolder = Instance.new("Folder")
	cityFolder.Name = "HavenCity"
	cityFolder.Parent = parent
	
	-- Create central plaza
	local plaza = createPart(
		"CentralPlaza",
		Config.HAVEN_CITY.PLAZA_SIZE,
		Config.HAVEN_CITY.PLAZA_POSITION,
		Color3.fromRGB(200, 200, 180),
		Enum.Material.Cobblestone,
		cityFolder
	)
	
	-- Add plaza fountain
	local fountain = createPart(
		"Fountain",
		Vector3.new(10, 2, 10),
		Config.HAVEN_CITY.PLAZA_POSITION + Vector3.new(0, 3, 0),
		Color3.fromRGB(180, 220, 255),
		Enum.Material.Marble,
		cityFolder
	)
	
	local fountainWater = createWater(
		Config.HAVEN_CITY.PLAZA_POSITION + Vector3.new(0, 4.5, 0),
		Vector3.new(8, 1, 8),
		cityFolder
	)
	
	-- Create market district buildings
	local marketBuildings = {}
	for i = 1, 6 do
		local angle = (i-1) * 60
		local radius = 50
		local pos = Vector3.new(
			math.cos(math.rad(angle)) * radius,
			5,
			math.sin(math.rad(angle)) * radius
		)
		
		local building = createBuilding(
			pos,
			Vector3.new(12, Config.HAVEN_CITY.BUILDING_HEIGHTS.SHOP, 12),
			Color3.fromRGB(220, 180, 140),
			Enum.Material.Brick,
			Color3.fromRGB(180, 140, 100),
			cityFolder
		)
		table.insert(marketBuildings, building)
	end
	
	-- Create residential district
	for x = -60, -20, 20 do
		for z = 20, 60, 20 do
			createBuilding(
				Vector3.new(x, 5, z),
				Vector3.new(10, Config.HAVEN_CITY.BUILDING_HEIGHTS.HOUSE, 10),
				Color3.fromRGB(200, 200, 200),
				Enum.Material.WoodPlanks,
				Color3.fromRGB(150, 100, 50),
				cityFolder
			)
		end
	end
	
	-- Create guard towers
	local towerPositions = {
		Vector3.new(60, 10, 60),
		Vector3.new(60, 10, -60),
		Vector3.new(-60, 10, 60),
		Vector3.new(-60, 10, -60)
	}
	
	for _, pos in ipairs(towerPositions) do
		local tower = createPart(
			"GuardTower",
			Vector3.new(8, Config.HAVEN_CITY.BUILDING_HEIGHTS.TOWER, 8),
			pos,
			Color3.fromRGB(120, 120, 120),
			Enum.Material.Concrete,
			cityFolder
		)
		
		-- Tower top
		local towerTop = createPart(
			"TowerTop",
			Vector3.new(12, 4, 12),
			pos + Vector3.new(0, Config.HAVEN_CITY.BUILDING_HEIGHTS.TOWER/2 + 2, 0),
			Color3.fromRGB(100, 100, 100),
			Enum.Material.Metal,
			cityFolder
		)
	end
	
	-- Create city walls
	createWall(Vector3.new(-80, 5, -80), Vector3.new(80, 5, -80), Config.HAVEN_CITY.BUILDING_HEIGHTS.WALL, cityFolder)
	createWall(Vector3.new(80, 5, -80), Vector3.new(80, 5, 80), Config.HAVEN_CITY.BUILDING_HEIGHTS.WALL, cityFolder)
	createWall(Vector3.new(80, 5, 80), Vector3.new(-80, 5, 80), Config.HAVEN_CITY.BUILDING_HEIGHTS.WALL, cityFolder)
	createWall(Vector3.new(-80, 5, 80), Vector3.new(-80, 5, -80), Config.HAVEN_CITY.BUILDING_HEIGHTS.WALL, cityFolder)
	
	-- Create gates
	local gate = createPart(
		"CityGate",
		Vector3.new(20, 20, 5),
		Vector3.new(0, 10, -80),
		Color3.fromRGB(150, 120, 90),
		Enum.Material.Wood,
		cityFolder
	)
	
	-- Create roads
	createRoad(Vector3.new(0, 1, -60), Vector3.new(0, 1, 60), Config.HAVEN_CITY.STREET_WIDTH, cityFolder)
	createRoad(Vector3.new(-60, 1, 0), Vector3.new(60, 1, 0), Config.HAVEN_CITY.STREET_WIDTH, cityFolder)
	
	-- Create sidewalks
	for x = -70, 70, 140 do
		createRoad(Vector3.new(x, 1, -70), Vector3.new(x, 1, 70), Config.HAVEN_CITY.SIDEWALK_WIDTH, cityFolder)
	end
	for z = -70, 70, 140 do
		createRoad(Vector3.new(-70, 1, z), Vector3.new(70, 1, z), Config.HAVEN_CITY.SIDEWALK_WIDTH, cityFolder)
	end
	
	print("[MapGenerator] Haven City generated with " .. #marketBuildings .. " market buildings")
	return cityFolder
end

function MapGenerator.GenerateForest(parent)
	print("[MapGenerator] Generating Forest...")
	
	local forestFolder = Instance.new("Folder")
	forestFolder.Name = "Forest"
	forestFolder.Parent = parent
	
	-- Create varied terrain
	for x = -100, 100, 40 do
		for z = -100, 100, 40 do
			local height = math.random(5, 30)
			local hill = createPart(
				"ForestHill",
				Vector3.new(35, height, 35),
				Vector3.new(250 + x, height/2, z),
				Color3.fromRGB(34, 139, 34),
				Enum.Material.Grass,
				forestFolder
			)
			
			-- Add trees on hills
			if math.random(1, 3) > 1 then
				local treeType = math.random(1, 3)
				local treeTypes = {"OAK", "PINE", "WILLOW"}
				createTree(
					Vector3.new(250 + x + math.random(-10, 10), height + 5, z + math.random(-10, 10)),
					treeTypes[treeType],
					forestFolder
				)
			end
		end
	end
	
	-- Create forest paths
	createRoad(Vector3.new(150, 5, 0), Vector3.new(350, 5, 0), 10, forestFolder)
	createRoad(Vector3.new(250, 5, -100), Vector3.new(250, 5, 100), 10, forestFolder)
	
	-- Add some rocks
	for i = 1, 20 do
		createRock(
			Vector3.new(250 + math.random(-80, 80), 5, math.random(-80, 80)),
			"COAL",
			forestFolder
		)
	end
	
	print("[MapGenerator] Forest generated with hills and trees")
	return forestFolder
end

function MapGenerator.GenerateMountains(parent)
	print("[MapGenerator] Generating Mountains...")
	
	local mountainsFolder = Instance.new("Folder")
	mountainsFolder.Name = "Mountains"
	mountainsFolder.Parent = parent
	
	-- Create mountain range
	for i = 1, 5 do
		local xPos = -400 + (i-1) * 80
		local height = math.random(50, 100)
		local width = math.random(60, 100)
		
		local mountain = createPart(
			"Mountain" .. i,
			Vector3.new(width, height, width),
			Vector3.new(xPos, height/2, -200),
			Color3.fromRGB(120, 120, 120),
			Enum.Material.Slate,
			mountainsFolder
		)
		
		-- Add snow caps to tall mountains
		if height > 80 then
			local snow = createPart(
				"SnowCap" .. i,
				Vector3.new(width * 0.7, 10, width * 0.7),
				Vector3.new(xPos, height + 5, -200),
				Color3.fromRGB(255, 255, 255),
				Enum.Material.Snow,
				mountainsFolder
			)
		end
		
		-- Add mining rocks
		for j = 1, math.random(3, 8) do
			local rockX = xPos + math.random(-width/3, width/3)
			local rockZ = -200 + math.random(-width/3, width/3)
			local rockY = height/2 + math.random(-10, 10)
			
			local rockTypes = {"COPPER", "IRON", "COAL"}
			local rockType = rockTypes[math.random(1, 3)]
			createRock(
				Vector3.new(rockX, rockY, rockZ),
				rockType,
				mountainsFolder
			)
		end
	end
	
	-- Create mountain pass
	createRoad(Vector3.new(-400, 30, -250), Vector3.new(-200, 30, -150), 15, mountainsFolder)
	
	print("[MapGenerator] Mountain range generated with 5 peaks")
	return mountainsFolder
end

function MapGenerator.GenerateLakes(parent)
	print("[MapGenerator] Generating Lakes...")
	
	local lakesFolder = Instance.new("Folder")
	lakesFolder.Name = "Lakes"
	lakesFolder.Parent = parent
	
	-- Create main lake
	local lakeCenter = Vector3.new(-200, -5, 400)
	local lakeRadius = Config.RESOURCES.WATER.POND.radius
	
	local lakeBed = createPart(
		"LakeBed",
		Vector3.new(lakeRadius * 2, 5, lakeRadius * 2),
		lakeCenter - Vector3.new(0, 5, 0),
		Color3.fromRGB(80, 60, 40),
		Enum.Material.Mud,
		lakesFolder
	)
	
	local lakeWater = createWater(
		lakeCenter,
		Vector3.new(lakeRadius * 2, Config.RESOURCES.WATER.POND.depth, lakeRadius * 2),
		lakesFolder
	)
	
	-- Create smaller ponds around
	for i = 1, 4 do
		local angle = (i-1) * 90
		local pondRadius = math.random(10, 20)
		local pondPos = lakeCenter + Vector3.new(
			math.cos(math.rad(angle)) * (lakeRadius + pondRadius + 20),
			-3,
			math.sin(math.rad(angle)) * (lakeRadius + pondRadius + 20)
		)
		
		createWater(
			pondPos,
			Vector3.new(pondRadius * 2, 8, pondRadius * 2),
			lakesFolder
		)
		
		-- Add trees around ponds
		for j = 1, 8 do
			local treeAngle = j * 45
			local treeDist = pondRadius + 5
			local treePos = pondPos + Vector3.new(
				math.cos(math.rad(treeAngle)) * treeDist,
				5,
				math.sin(math.rad(treeAngle)) * treeDist
			)
			
			createTree(treePos, "WILLOW", lakesFolder)
		end
	end
	
	-- Create fishing docks
	for i = 1, 3 do
		local dockAngle = 30 + (i-1) * 40
		local dockPos = lakeCenter + Vector3.new(
			math.cos(math.rad(dockAngle)) * (lakeRadius - 5),
			1,
			math.sin(math.rad(dockAngle)) * (lakeRadius - 5)
		)
		
		local dock = createPart(
			"FishingDock" .. i,
			Vector3.new(10, 1, 5),
			dockPos,
			Color3.fromRGB(139, 69, 19),
			Enum.Material.Wood,
			lakesFolder
		)
		
		-- Rotate dock to face lake center
		dock.CFrame = CFrame.new(dockPos, lakeCenter) * CFrame.new(0, 0, -2.5)
	end
	
	print("[MapGenerator] Lake area generated with fishing docks")
	return lakesFolder
end

function MapGenerator.GenerateSwamp(parent)
	print("[MapGenerator] Generating Swamp...")
	
	local swampFolder = Instance.new("Folder")
	swampFolder.Name = "Swamp"
	swampFolder.Parent = parent
	
	-- Create swamp water area
	local swampCenter = Vector3.new(200, 0, 400)
	
	for x = -50, 50, 25 do
		for z = -50, 50, 25 do
			if math.random(1, 3) > 1 then -- 66% chance for water patch
				local waterPatch = createWater(
					swampCenter + Vector3.new(x, -2, z),
					Vector3.new(20, 4, 20),
					swampFolder
				)
				waterPatch.Color = Color3.fromRGB(60, 100, 60) -- Greenish swamp water
			else
				-- Create small islands
				local island = createPart(
					"SwampIsland",
					Vector3.new(15, 3, 15),
					swampCenter + Vector3.new(x, 1.5, z),
					Color3.fromRGB(80, 70, 50),
					Enum.Material.Mud,
					swampFolder
				)
				
				-- Add swamp trees
				if math.random(1, 2) == 1 then
					createTree(
						swampCenter + Vector3.new(x, 4, z),
						"WILLOW",
						swampFolder
					)
				end
			end
		end
	end
	
	-- Create winding paths through swamp
	local pathPoints = {
		Vector3.new(150, 2, 350),
		Vector3.new(180, 2, 380),
		Vector3.new(200, 2, 400),
		Vector3.new(220, 2, 420),
		Vector3.new(250, 2, 450)
	}
	
	for i = 1, #pathPoints - 1 do
		createRoad(pathPoints[i], pathPoints[i+1], 8, swampFolder)
	end
	
	-- Add lily pads
	for i = 1, 30 do
		local lilyPad = createPart(
			"LilyPad",
			Vector3.new(4, 0.2, 4),
			swampCenter + Vector3.new(math.random(-60, 60), 0.1, math.random(-60, 60)),
			Color3.fromRGB(60, 140, 60),
			Enum.Material.Neon,
			swampFolder
		)
		lilyPad.Transparency = 0.5
	end
	
	print("[MapGenerator] Swamp generated with winding paths")
	return swampFolder
end

function MapGenerator.GenerateDesert(parent)
	print("[MapGenerator] Generating Desert...")
	
	local desertFolder = Instance.new("Folder")
	desertFolder.Name = "Desert"
	desertFolder.Parent = parent
	
	-- Create sand dunes
	for i = 1, 15 do
		local duneHeight = math.random(5, 20)
		local duneWidth = math.random(30, 60)
		local dunePos = Vector3.new(
			-400 + math.random(-100, 100),
			duneHeight/2,
			400 + math.random(-100, 100)
		)
		
		local dune = createPart(
			"SandDune" .. i,
			Vector3.new(duneWidth, duneHeight, duneWidth),
			dunePos,
			Color3.fromRGB(240, 230, 140),
			Enum.Material.Sand,
			desertFolder
		)
		
		-- Add occasional cactus
		if math.random(1, 4) == 1 then
			local cactus = createPart(
				"Cactus",
				Vector3.new(2, math.random(8, 15), 2),
				dunePos + Vector3.new(0, duneHeight/2 + 5, 0),
				Color3.fromRGB(60, 140, 60),
				Enum.Material.Neon,
				desertFolder
			)
		end
	end
	
	-- Create oasis
	local oasisCenter = Vector3.new(-400, 0, 400)
	local oasisWater = createWater(
		oasisCenter,
		Vector3.new(30, 8, 30),
		desertFolder
	)
	
	-- Add palm trees around oasis
	for i = 1, 8 do
		local angle = i * 45
		local treePos = oasisCenter + Vector3.new(
			math.cos(math.rad(angle)) * 25,
			5,
			math.sin(math.rad(angle)) * 25
		)
		
		-- Palm tree trunk
		local trunk = createPart(
			"PalmTrunk",
			Vector3.new(2, 15, 2),
			treePos,
			Color3.fromRGB(139, 90, 43),
			Enum.Material.Wood,
			desertFolder
		)
		
		-- Palm leaves
		for j = 1, 4 do
			local leafAngle = j * 90
			local leaf = createPart(
				"PalmLeaf",
				Vector3.new(8, 1, 2),
				treePos + Vector3.new(0, 10, 0),
				Color3.fromRGB(60, 180, 60),
				Enum.Material.Neon,
				desertFolder
			)
			leaf.CFrame = CFrame.new(leaf.Position) * CFrame.Angles(0, math.rad(leafAngle), math.rad(45))
		end
	end
	
	print("[MapGenerator] Desert generated with dunes and oasis")
	return desertFolder
end

function MapGenerator.GenerateVolcano(parent)
	print("[MapGenerator] Generating Volcano...")
	
	local volcanoFolder = Instance.new("Folder")
	volcanoFolder.Name = "Volcano"
	volcanoFolder.Parent = parent
	
	-- Create volcano cone
	local volcanoHeight = 120
	local volcanoBase = 80
	
	local volcano = createPart(
		"Volcano",
		Vector3.new(volcanoBase, volcanoHeight, volcanoBase),
		Vector3.new(400, volcanoHeight/2, 400),
		Color3.fromRGB(80, 40, 40),
		Enum.Material.Basalt,
		volcanoFolder
	)
	
	-- Create crater
	local crater = createPart(
		"Crater",
		Vector3.new(40, 20, 40),
		Vector3.new(400, volcanoHeight + 10, 400),
		Color3.fromRGB(120, 60, 60),
		Enum.Material.Basalt,
		volcanoFolder
	)
	
	-- Add lava in crater
	local lava = createPart(
		"Lava",
		Vector3.new(30, 5, 30),
		Vector3.new(400, volcanoHeight + 15, 400),
		Color3.fromRGB(255, 100, 0),
		Enum.Material.Neon,
		volcanoFolder
	)
	lava.Material = Enum.Material.Neon
	lava.PointLight = Instance.new("PointLight")
	lava.PointLight.Color = Color3.fromRGB(255, 100, 0)
	lava.PointLight.Brightness = 2
	lava.PointLight.Range = 30
	lava.PointLight.Parent = lava
	
	-- Create lava flows down sides
	for i = 1, 4 do
		local angle = (i-1) * 90
		local flowLength = 60
		
		for j = 1, 5 do
			local t = j / 5
			local flowPos = Vector3.new(
				400 + math.cos(math.rad(angle)) * (volcanoBase/2 * t),
				volcanoHeight/2 * (1 - t) + 10,
				400 + math.sin(math.rad(angle)) * (volcanoBase/2 * t)
			)
			
			local lavaFlow = createPart(
				"LavaFlow" .. i .. "_" .. j,
				Vector3.new(8, 3, 8),
				flowPos,
				Color3.fromRGB(255, 80, 0),
				Enum.Material.Neon,
				volcanoFolder
			)
			
			-- Add glow
			local light = Instance.new("PointLight")
			light.Color = Color3.fromRGB(255, 80, 0)
			light.Brightness = 1
			light.Range = 15
			light.Parent = lavaFlow
		end
	end
	
	-- Create rocky terrain around volcano
	for i = 1, 30 do
		local rockPos = Vector3.new(
			400 + math.random(-100, 100),
			math.random(5, 20),
			400 + math.random(-100, 100)
		)
		
		createRock(rockPos, "COAL", volcanoFolder)
	end
	
	print("[MapGenerator] Volcano generated with lava flows")
	return volcanoFolder
end

function MapGenerator.GenerateWilderness(parent)
	print("[MapGenerator] Generating Wilderness...")
	
	local wildernessFolder = Instance.new("Folder")
	wildernessFolder.Name = "Wilderness"
	wildernessFolder.Parent = parent
	
	-- Create varied wilderness terrain
	local terrainPatches = {
		{pos = Vector3.new(-600, 10, -600), size = Vector3.new(200, 20, 200), color = Color3.fromRGB(60, 100, 60)},
		{pos = Vector3.new(-600, 15, -200), size = Vector3.new(200, 30, 200), color = Color3.fromRGB(80, 80, 60)},
		{pos = Vector3.new(-200, 25, -600), size = Vector3.new(200, 50, 200), color = Color3.fromRGB(100, 80, 60)},
		{pos = Vector3.new(200, 20, -600), size = Vector3.new(200, 40, 200), color = Color3.fromRGB(70, 90, 60)},
		{pos = Vector3.new(600, 30, -600), size = Vector3.new(200, 60, 200), color = Color3.fromRGB(90, 70, 50)},
		{pos = Vector3.new(-600, 35, 200), size = Vector3.new(200, 70, 200), color = Color3.fromRGB(80, 60, 40)},
		{pos = Vector3.new(-200, 40, 200), size = Vector3.new(200, 80, 200), color = Color3.fromRGB(70, 50, 30)},
		{pos = Vector3.new(200, 45, 200), size = Vector3.new(200, 90, 200), color = Color3.fromRGB(60, 40, 20)},
		{pos = Vector3.new(600, 50, 200), size = Vector3.new(200, 100, 200), color = Color3.fromRGB(50, 30, 10)}
	}
	
	for _, patch in ipairs(terrainPatches) do
		local terrain = createPart(
			"WildernessTerrain",
			patch.size,
			patch.pos,
			patch.color,
			Enum.Material.Grass,
			wildernessFolder
		)
		
		-- Add resources based on terrain type
		local resourceCount = math.random(5, 15)
		for i = 1, resourceCount do
			local resourcePos = patch.pos + Vector3.new(
				math.random(-patch.size.X/2, patch.size.X/2),
				patch.size.Y/2 + 5,
				math.random(-patch.size.Z/2, patch.size.Z/2)
			)
			
			if math.random(1, 3) == 1 then
				-- Add tree
				local treeTypes = {"OAK", "PINE", "WILLOW"}
				createTree(resourcePos, treeTypes[math.random(1, 3)], wildernessFolder)
			else
				-- Add rock
				local rockTypes = {"COPPER", "IRON", "COAL"}
				createRock(resourcePos, rockTypes[math.random(1, 3)], wildernessFolder)
			end
		end
	end
	
	-- Create winding wilderness paths
	local mainPath = {
		Vector3.new(-700, 20, -700),
		Vector3.new(-500, 25, -500),
		Vector3.new(-300, 30, -300),
		Vector3.new(-100, 35, -100),
		Vector3.new(100, 40, 100),
		Vector3.new(300, 45, 300),
		Vector3.new(500, 50, 500),
		Vector3.new(700, 55, 700)
	}
	
	for i = 1, #mainPath - 1 do
		createRoad(mainPath[i], mainPath[i+1], 12, wildernessFolder)
	end
	
	print("[MapGenerator] Wilderness generated with varied terrain")
	return wildernessFolder
end

function MapGenerator.SetupLighting()
	print("[MapGenerator] Setting up lighting...")
	
	local Lighting = game:GetService("Lighting")
	
	-- Clear existing effects
	for _, child in ipairs(Lighting:GetChildren()) do
		if child:IsA("PostEffect") then
			child:Destroy()
		end
	end
	
	-- Basic lighting
	Lighting.Brightness = Config.LIGHTING.BRIGHTNESS
	Lighting.GlobalShadows = true
	Lighting.OutdoorAmbient = Config.LIGHTING.OUTDOOR_AMBIENT
	Lighting.ClockTime = Config.LIGHTING.TIME
	Lighting.ExposureCompensation = Config.LIGHTING.EXPOSURE
	
	-- Fog
	Lighting.FogColor = Config.LIGHTING.FOG_COLOR
	Lighting.FogStart = Config.LIGHTING.FOG_START
	Lighting.FogEnd = Config.LIGHTING.FOG_END
	
	-- Sun
	local sunRays = Instance.new("SunRaysEffect")
	sunRays.Intensity = 0.1
	sunRays.Spread = 0.5
	sunRays.Parent = Lighting
	
	-- Bloom
	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.2
	bloom.Size = 24
	bloom.Threshold = 0.8
	bloom.Parent = Lighting
	
	-- Color correction
	local colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Brightness = 0.05
	colorCorrection.Contrast = 0.1
	colorCorrection.Saturation = 0.1
	colorCorrection.Parent = Lighting
	
	print("[MapGenerator] Lighting configured")
end

function MapGenerator.CreateSpawnSystem(parent)
	print("[MapGenerator] Creating spawn system...")
	
	-- Main spawn in Haven City
	local spawnPlatform = createPart(
		"SpawnPlatform",
		Vector3.new(20, 2, 20),
		Config.SPAWN.HAVEN_SPAWN - Vector3.new(0, 1, 0),
		Color3.fromRGB(200, 200, 200),
		Enum.Material.Marble,
		parent
	)
	
	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "SpawnLocation"
	spawnLocation.Size = Vector3.new(15, 1, 15)
	spawnLocation.Position = Config.SPAWN.HAVEN_SPAWN
	spawnLocation.Anchored = true
	spawnLocation.CanCollide = true
	spawnLocation.Color = Color3.fromRGB(0, 255, 0)
	spawnLocation.Material = Enum.Material.Neon
	spawnLocation.Transparency = 0.7
	spawnLocation.Parent = parent
	
	-- Add welcome sign
	local sign = createPart(
		"WelcomeSign",
		Vector3.new(6, 4, 1),
		Config.SPAWN.HAVEN_SPAWN + Vector3.new(0, 5, 12),
		Color3.fromRGB(240, 192, 64),
		Enum.Material.Neon,
		parent
	)
	
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(6, 0, 2, 0)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.Parent = sign
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "WELCOME TO\nHAVEN CITY"
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 24
	textLabel.TextStrokeTransparency = 0.3
	textLabel.Parent = billboard
	
	print("[MapGenerator] Spawn system created at:", Config.SPAWN.HAVEN_SPAWN)
	return spawnLocation
end

function MapGenerator.GenerateCompleteWorld()
	print("[MapGenerator] =========================================")
	print("[MapGenerator] GENERATING COMPLETE WILDERNESS WORLD")
	print("[MapGenerator] =========================================")
	
	local workspace = game:GetService("Workspace")
	
	-- Create main world folder
	local worldFolder = Instance.new("Folder")
	worldFolder.Name = "WildernessWorld"
	worldFolder.Parent = workspace
	
	-- Setup lighting first
	MapGenerator.SetupLighting()
	
	-- Generate all regions
	local regions = {}
	
	regions.HavenCity = MapGenerator.GenerateHavenCity(worldFolder)
	regions.Forest = MapGenerator.GenerateForest(worldFolder)
	regions.Mountains = MapGenerator.GenerateMountains(worldFolder)
	regions.Lakes = MapGenerator.GenerateLakes(worldFolder)
	regions.Swamp = MapGenerator.GenerateSwamp(worldFolder)
	regions.Desert = MapGenerator.GenerateDesert(worldFolder)
	regions.Volcano = MapGenerator.GenerateVolcano(worldFolder)
	regions.Wilderness = MapGenerator.GenerateWilderness(worldFolder)
	
	-- Create spawn system
	regions.Spawn = MapGenerator.CreateSpawnSystem(worldFolder)
	
	-- Create connections between regions
	print("[MapGenerator] Creating region connections...")
	
	-- Haven City to Forest
	createRoad(Vector3.new(80, 5, 0), Vector3.new(150, 5, 0), 15, worldFolder)
	
	-- Haven City to Mountains
	createRoad(Vector3.new(-80, 5, 0), Vector3.new(-150, 5, 0), 15, worldFolder)
	
	-- Haven City to Lakes
	createRoad(Vector3.new(0, 5, 80), Vector3.new(0, 5, 150), 15, worldFolder)
	
	-- Forest to Swamp
	createRoad(Vector3.new(350, 5, 0), Vector3.new(350, 5, 150), 15, worldFolder)
	
	-- Mountains to Desert
	createRoad(Vector3.new(-350, 30, 0), Vector3.new(-350, 30, 150), 15, worldFolder)
	
	-- Create boundary markers
	for x = -800, 800, 400 do
		for z = -800, 800, 400 do
			if math.abs(x) == 800 or math.abs(z) == 800 then
				local marker = createPart(
					"BoundaryMarker",
					Vector3.new(5, 10, 5),
					Vector3.new(x, 5, z),
					Color3.fromRGB(255, 0, 0),
					Enum.Material.Neon,
					worldFolder
				)
				
				local markerBillboard = Instance.new("BillboardGui")
				markerBillboard.Size = UDim2.new(4, 0, 2, 0)
				markerBillboard.StudsOffset = Vector3.new(0, 8, 0)
				markerBillboard.Parent = marker
				
				local markerText = Instance.new("TextLabel")
				markerText.Size = UDim2.new(1, 0, 1, 0)
				markerText.BackgroundTransparency = 1
				markerText.Text = "WORLD\nBOUNDARY"
				markerText.TextColor3 = Color3.fromRGB(255, 255, 255)
				markerText.Font = Enum.Font.GothamBold
				markerText.TextSize = 14
				markerText.TextStrokeTransparency = 0.3
				markerText.Parent = markerBillboard
			end
		end
	end
	
	print("[MapGenerator] =========================================")
	print("[MapGenerator] WORLD GENERATION COMPLETE")
	print("[MapGenerator] Regions generated: " .. tostring(#worldFolder:GetChildren()))
	print("[MapGenerator] Spawn location: " .. tostring(Config.SPAWN.HAVEN_SPAWN))
	print("[MapGenerator] =========================================")
	
	return worldFolder
end

return MapGenerator