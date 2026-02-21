-- Config.lua
-- Game configuration and constants for the Wilderness world

local Config = {}

-- Map dimensions and regions
Config.MAP = {
	WIDTH = 1000,  -- Total map width in studs
	HEIGHT = 1000, -- Total map height in studs
	
	-- Region definitions (in grid coordinates)
	REGIONS = {
		HAVEN_CITY = {x1 = -200, z1 = -200, x2 = 200, z2 = 200}, -- Center
		FOREST = {x1 = 200, z1 = -400, x2 = 600, z2 = 0},       -- East
		MOUNTAINS = {x1 = -600, z1 = -400, x2 = -200, z2 = 0},  -- West
		LAKES = {x1 = -400, z1 = 200, x2 = 0, z2 = 600},        -- North-West
		SWAMP = {x1 = 0, z1 = 200, x2 = 400, z2 = 600},         -- North-East
		DESERT = {x1 = -600, z1 = 200, x2 = -200, z2 = 600},    -- Far West
		VOLCANO = {x1 = 200, z1 = 200, x2 = 600, z2 = 600},     -- Far East
		WILDERNESS = {x1 = -800, z1 = -800, x2 = 800, z2 = 800} -- Outer ring
	},
	
	-- Terrain height ranges per region
	TERRAIN_HEIGHTS = {
		HAVEN_CITY = {min = 0, max = 5},
		FOREST = {min = 5, max = 30},
		MOUNTAINS = {min = 20, max = 100},
		LAKES = {min = -10, max = 5},
		SWAMP = {min = -5, max = 10},
		DESERT = {min = 0, max = 20},
		VOLCANO = {min = 50, max = 150},
		WILDERNESS = {min = 10, max = 60}
	}
}

-- Haven City layout
Config.HAVEN_CITY = {
	-- Main plaza at center
	PLAZA_SIZE = Vector3.new(80, 2, 80),
	PLAZA_POSITION = Vector3.new(0, 1, 0),
	
	-- Building dimensions
	BUILDING_HEIGHTS = {
		SHOP = 12,
		HOUSE = 8,
		TOWER = 25,
		WALL = 15
	},
	
	-- Street layout
	STREET_WIDTH = 20,
	SIDEWALK_WIDTH = 5,
	
	-- Districts
	DISTRICTS = {
		MARKET = {x1 = -80, z1 = -80, x2 = 80, z2 = 0},
		RESIDENTIAL = {x1 = -80, z1 = 0, x2 = 0, z2 = 80},
		GUARD = {x1 = 0, z1 = 0, x2 = 80, z2 = 80},
		TEMPLE = {x1 = -80, z1 = 80, x2 = 0, z2 = 160}
	}
}

-- Resource node configurations
Config.RESOURCES = {
	TREES = {
		OAK = {height = 15, trunkRadius = 2, color = Color3.fromRGB(101, 67, 33)},
		PINE = {height = 25, trunkRadius = 1.5, color = Color3.fromRGB(85, 107, 47)},
		WILLOW = {height = 12, trunkRadius = 1.8, color = Color3.fromRGB(139, 115, 85)}
	},
	
	ROCKS = {
		COPPER = {size = Vector3.new(4, 3, 4), color = Color3.fromRGB(184, 115, 51)},
		IRON = {size = Vector3.new(5, 4, 5), color = Color3.fromRGB(165, 165, 165)},
		COAL = {size = Vector3.new(4, 3, 4), color = Color3.fromRGB(40, 40, 40)}
	},
	
	WATER = {
		POND = {radius = 20, depth = 10},
		RIVER = {width = 15, depth = 5}
	}
}

-- Lighting configuration
Config.LIGHTING = {
	BRIGHTNESS = 2,
	OUTDOOR_AMBIENT = Color3.fromRGB(128, 128, 128),
	FOG_COLOR = Color3.fromRGB(191, 191, 191),
	FOG_START = 100,
	FOG_END = 1000,
	
	-- Time of day
	TIME = 14, -- 2 PM
	EXPOSURE = 1.5
}

-- Spawn system
Config.SPAWN = {
	HAVEN_SPAWN = Vector3.new(0, 5, 0),
	RESPAWN_HEIGHT = 50 -- Height to check for safe respawn
}

return Config