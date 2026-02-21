-- ItemVisuals.lua (ModuleScript in ReplicatedStorage/Modules)
-- Unique visual representations for every item in the game

local ItemVisuals = {}

ItemVisuals.Items = {
	-- === ORES (Mining) ===
	["Copper Ore"] = { emoji = "🪨", color = Color3.fromRGB(184, 115, 51), shape = "ore", glowColor = nil },
	["Iron Ore"] = { emoji = "⛏️", color = Color3.fromRGB(169, 169, 169), shape = "ore", glowColor = nil },
	["Gold Ore"] = { emoji = "💎", color = Color3.fromRGB(255, 215, 0), shape = "ore", glowColor = Color3.fromRGB(255, 255, 0) },
	["Runite Ore"] = { emoji = "💠", color = Color3.fromRGB(0, 139, 139), shape = "ore", glowColor = Color3.fromRGB(0, 255, 255) },

	-- === LOGS (Woodcutting) ===
	["Oak Log"] = { emoji = "🪵", color = Color3.fromRGB(139, 90, 43), shape = "log", glowColor = nil },
	["Willow Log"] = { emoji = "🌿", color = Color3.fromRGB(85, 107, 47), shape = "log", glowColor = nil },
	["Yew Log"] = { emoji = "🌲", color = Color3.fromRGB(34, 139, 34), shape = "log", glowColor = nil },
	["Magic Log"] = { emoji = "✨", color = Color3.fromRGB(138, 43, 226), shape = "log", glowColor = Color3.fromRGB(255, 0, 255) },

	-- === FISH (Fishing) ===
	["Shrimp"] = { emoji = "🦐", color = Color3.fromRGB(255, 160, 122), shape = "fish", glowColor = nil },
	["Trout"] = { emoji = "🐟", color = Color3.fromRGB(105, 105, 105), shape = "fish", glowColor = nil },
	["Lobster"] = { emoji = "🦞", color = Color3.fromRGB(220, 20, 60), shape = "fish", glowColor = nil },
	["Dark Crab"] = { emoji = "🦀", color = Color3.fromRGB(75, 0, 130), shape = "fish", glowColor = Color3.fromRGB(138, 43, 226) },

	-- === BARS (Smithing) ===
	["Copper Bar"] = { emoji = "⚱️", color = Color3.fromRGB(184, 115, 51), shape = "bar", glowColor = nil },
	["Iron Bar"] = { emoji = "🔩", color = Color3.fromRGB(169, 169, 169), shape = "bar", glowColor = nil },
	["Gold Bar"] = { emoji = "🥇", color = Color3.fromRGB(255, 215, 0), shape = "bar", glowColor = Color3.fromRGB(255, 255, 0) },

	-- === WEAPONS ===
	["Copper Sword"] = { emoji = "⚔️", color = Color3.fromRGB(184, 115, 51), shape = "sword", glowColor = nil },
	["Iron Sword"] = { emoji = "⚔️", color = Color3.fromRGB(180, 180, 190), shape = "sword", glowColor = nil },
	["Gold Sword"] = { emoji = "🗡️", color = Color3.fromRGB(255, 215, 0), shape = "sword", glowColor = Color3.fromRGB(255, 255, 0) },
	["Runite Sword"] = { emoji = "🗡️", color = Color3.fromRGB(0, 139, 139), shape = "sword", glowColor = Color3.fromRGB(0, 255, 255) },
	["Dragon Sword"] = { emoji = "⚔️", color = Color3.fromRGB(255, 69, 0), shape = "sword", glowColor = Color3.fromRGB(255, 140, 0) },

	-- === COOKED FOOD ===
	["Cooked Shrimp"] = { emoji = "🍤", color = Color3.fromRGB(255, 182, 193), shape = "food", glowColor = nil },
	["Cooked Trout"] = { emoji = "🐟", color = Color3.fromRGB(160, 82, 45), shape = "food", glowColor = nil },
	["Cooked Lobster"] = { emoji = "🦞", color = Color3.fromRGB(255, 99, 71), shape = "food", glowColor = nil },
	["Cooked Dark Crab"] = { emoji = "🦀", color = Color3.fromRGB(128, 0, 128), shape = "food", glowColor = Color3.fromRGB(255, 0, 255) },

	-- === RAW FOOD ===
	["Raw Chicken"] = { emoji = "🐔", color = Color3.fromRGB(255, 182, 193), shape = "food", glowColor = nil },
	["Cooked Chicken"] = { emoji = "🍗", color = Color3.fromRGB(210, 180, 140), shape = "food", glowColor = nil },
	["Raw Beef"] = { emoji = "🥩", color = Color3.fromRGB(139, 69, 19), shape = "food", glowColor = nil },
	["Cooked Beef"] = { emoji = "🥩", color = Color3.fromRGB(160, 82, 45), shape = "food", glowColor = nil },
	["Raw Rat Meat"] = { emoji = "🐭", color = Color3.fromRGB(105, 105, 105), shape = "food", glowColor = nil },
	["Cooked Rat Meat"] = { emoji = "🍖", color = Color3.fromRGB(139, 69, 19), shape = "food", glowColor = nil },

	-- === MONSTER DROPS ===
	["Feather"] = { emoji = "🪶", color = Color3.fromRGB(245, 245, 220), shape = "feather", glowColor = nil },
	["Cowhide"] = { emoji = "🐄", color = Color3.fromRGB(160, 82, 45), shape = "misc", glowColor = nil },
	["Goblin Mail"] = { emoji = "👕", color = Color3.fromRGB(85, 107, 47), shape = "misc", glowColor = nil },
	["Bones"] = { emoji = "💀", color = Color3.fromRGB(255, 248, 220), shape = "bone", glowColor = nil },
	["Dog Tag"] = { emoji = "🏷️", color = Color3.fromRGB(192, 192, 192), shape = "misc", glowColor = nil },
	["Rat Tail"] = { emoji = "🐀", color = Color3.fromRGB(105, 105, 105), shape = "misc", glowColor = nil },
	["Wizard Robe"] = { emoji = "🧙", color = Color3.fromRGB(75, 0, 130), shape = "misc", glowColor = Color3.fromRGB(138, 43, 226) },
	["Demon Heart"] = { emoji = "💜", color = Color3.fromRGB(139, 0, 0), shape = "gem", glowColor = Color3.fromRGB(255, 0, 0) },
	["Dragon Scale"] = { emoji = "🐲", color = Color3.fromRGB(255, 69, 0), shape = "misc", glowColor = Color3.fromRGB(255, 140, 0) },
	["Shadow Gem"] = { emoji = "💎", color = Color3.fromRGB(75, 0, 130), shape = "gem", glowColor = Color3.fromRGB(138, 43, 226) },
	["Bronze Coins"] = { emoji = "🪙", color = Color3.fromRGB(205, 127, 50), shape = "misc", glowColor = nil },

	-- === ARMOR ===
	["Bronze Helmet"] = { emoji = "⛑️", color = Color3.fromRGB(205, 127, 50), shape = "misc", glowColor = nil },
	["Iron Legs"] = { emoji = "🦵", color = Color3.fromRGB(169, 169, 169), shape = "misc", glowColor = nil },
	["Wooden Shield"] = { emoji = "🛡️", color = Color3.fromRGB(160, 82, 45), shape = "shield", glowColor = nil },
	["Iron Shield"] = { emoji = "🛡️", color = Color3.fromRGB(169, 169, 169), shape = "shield", glowColor = nil },
	["Gold Shield"] = { emoji = "🛡️", color = Color3.fromRGB(255, 215, 0), shape = "shield", glowColor = Color3.fromRGB(255, 255, 0) },
	["Runite Shield"] = { emoji = "🛡️", color = Color3.fromRGB(0, 139, 139), shape = "shield", glowColor = Color3.fromRGB(0, 255, 255) },
	["Dragon Shield"] = { emoji = "🛡️", color = Color3.fromRGB(255, 69, 0), shape = "shield", glowColor = Color3.fromRGB(255, 140, 0) },

	-- === RANGED WEAPONS ===
	["Oak Shortbow"] = { emoji = "🏹", color = Color3.fromRGB(139, 90, 43), shape = "bow", glowColor = nil },
	["Oak Longbow"] = { emoji = "🏹", color = Color3.fromRGB(139, 90, 43), shape = "bow", glowColor = nil },
	["Willow Shortbow"] = { emoji = "🏹", color = Color3.fromRGB(85, 107, 47), shape = "bow", glowColor = nil },
	["Iron Crossbow"] = { emoji = "🏹", color = Color3.fromRGB(169, 169, 169), shape = "bow", glowColor = nil },
	["Willow Longbow"] = { emoji = "🏹", color = Color3.fromRGB(85, 107, 47), shape = "bow", glowColor = nil },
	["Yew Shortbow"] = { emoji = "🏹", color = Color3.fromRGB(34, 139, 34), shape = "bow", glowColor = nil },
	["Gold Crossbow"] = { emoji = "🏹", color = Color3.fromRGB(255, 215, 0), shape = "bow", glowColor = Color3.fromRGB(255, 255, 0) },
	["Yew Longbow"] = { emoji = "🏹", color = Color3.fromRGB(34, 139, 34), shape = "bow", glowColor = nil },
	["Magic Shortbow"] = { emoji = "🏹", color = Color3.fromRGB(138, 43, 226), shape = "bow", glowColor = Color3.fromRGB(255, 0, 255) },
	["Dragon Crossbow"] = { emoji = "🏹", color = Color3.fromRGB(255, 69, 0), shape = "bow", glowColor = Color3.fromRGB(255, 140, 0) },

	-- === AMMUNITION ===
	["Bronze Arrows"] = { emoji = "➤", color = Color3.fromRGB(205, 127, 50), shape = "arrow", glowColor = nil },
	["Iron Arrows"] = { emoji = "➤", color = Color3.fromRGB(169, 169, 169), shape = "arrow", glowColor = nil },
	["Gold Arrows"] = { emoji = "➤", color = Color3.fromRGB(255, 215, 0), shape = "arrow", glowColor = Color3.fromRGB(255, 255, 0) },
	["Runite Arrows"] = { emoji = "➤", color = Color3.fromRGB(0, 139, 139), shape = "arrow", glowColor = Color3.fromRGB(0, 255, 255) },
	["Iron Bolts"] = { emoji = "⇨", color = Color3.fromRGB(169, 169, 169), shape = "arrow", glowColor = nil },
	["Gold Bolts"] = { emoji = "⇨", color = Color3.fromRGB(255, 215, 0), shape = "arrow", glowColor = Color3.fromRGB(255, 255, 0) },
	["Runite Bolts"] = { emoji = "⇨", color = Color3.fromRGB(0, 139, 139), shape = "arrow", glowColor = Color3.fromRGB(0, 255, 255) },
	["Bowstring"] = { emoji = "🧵", color = Color3.fromRGB(245, 245, 220), shape = "misc", glowColor = nil },
	["Arrow Shafts"] = { emoji = "🪵", color = Color3.fromRGB(139, 90, 43), shape = "misc", glowColor = nil },
	["Magic Bowstring"] = { emoji = "✨", color = Color3.fromRGB(138, 43, 226), shape = "misc", glowColor = Color3.fromRGB(255, 0, 255) },

	-- === TOOLS ===
	["Bronze Pickaxe"] = { emoji = "⛏️", color = Color3.fromRGB(205, 127, 50), shape = "misc", glowColor = nil },
	["Iron Pickaxe"] = { emoji = "⛏️", color = Color3.fromRGB(169, 169, 169), shape = "misc", glowColor = nil },
	["Gold Pickaxe"] = { emoji = "⛏️", color = Color3.fromRGB(255, 215, 0), shape = "misc", glowColor = Color3.fromRGB(255, 255, 0) },
	["Runite Pickaxe"] = { emoji = "⛏️", color = Color3.fromRGB(0, 139, 139), shape = "misc", glowColor = Color3.fromRGB(0, 255, 255) },
	["Dragon Pickaxe"] = { emoji = "⛏️", color = Color3.fromRGB(255, 69, 0), shape = "misc", glowColor = Color3.fromRGB(255, 140, 0) },
	["Bronze Axe"] = { emoji = "🪓", color = Color3.fromRGB(205, 127, 50), shape = "misc", glowColor = nil },
	["Iron Axe"] = { emoji = "🪓", color = Color3.fromRGB(169, 169, 169), shape = "misc", glowColor = nil },
	["Gold Axe"] = { emoji = "🪓", color = Color3.fromRGB(255, 215, 0), shape = "misc", glowColor = Color3.fromRGB(255, 255, 0) },
	["Runite Axe"] = { emoji = "🪓", color = Color3.fromRGB(0, 139, 139), shape = "misc", glowColor = Color3.fromRGB(0, 255, 255) },
	["Dragon Axe"] = { emoji = "🪓", color = Color3.fromRGB(255, 69, 0), shape = "misc", glowColor = Color3.fromRGB(255, 140, 0) },
	["Wooden Rod"] = { emoji = "🎣", color = Color3.fromRGB(139, 90, 43), shape = "misc", glowColor = nil },
	["Iron Rod"] = { emoji = "🎣", color = Color3.fromRGB(169, 169, 169), shape = "misc", glowColor = nil },
	["Gold Rod"] = { emoji = "🎣", color = Color3.fromRGB(255, 215, 0), shape = "misc", glowColor = Color3.fromRGB(255, 255, 0) },
	["Runite Rod"] = { emoji = "🎣", color = Color3.fromRGB(0, 139, 139), shape = "misc", glowColor = Color3.fromRGB(0, 255, 255) },
	["Dragon Rod"] = { emoji = "🎣", color = Color3.fromRGB(255, 69, 0), shape = "misc", glowColor = Color3.fromRGB(255, 140, 0) },

	-- === NEW BOSS DROP ITEMS ===
	["Golden Feather"] = { emoji = "🪶", color = Color3.fromRGB(255, 215, 0), shape = "feather", glowColor = Color3.fromRGB(255, 255, 0) },
	["King's Crest"] = { emoji = "👑", color = Color3.fromRGB(255, 215, 0), shape = "gem", glowColor = Color3.fromRGB(255, 255, 0) },
	["Heartwood"] = { emoji = "💚", color = Color3.fromRGB(34, 139, 34), shape = "misc", glowColor = Color3.fromRGB(0, 255, 0) },
	["Ancient Bark"] = { emoji = "🌳", color = Color3.fromRGB(139, 90, 43), shape = "misc", glowColor = nil },
	["Elder Seed"] = { emoji = "🌰", color = Color3.fromRGB(34, 139, 34), shape = "gem", glowColor = Color3.fromRGB(0, 255, 0) },
	["Golem Core"] = { emoji = "💎", color = Color3.fromRGB(169, 169, 169), shape = "gem", glowColor = Color3.fromRGB(255, 255, 255) },
	["Golem Shield"] = { emoji = "🛡️", color = Color3.fromRGB(169, 169, 169), shape = "shield", glowColor = Color3.fromRGB(255, 255, 255) },
	["Serpent Scale"] = { emoji = "🐍", color = Color3.fromRGB(0, 128, 128), shape = "misc", glowColor = Color3.fromRGB(0, 255, 255) },
	["Sea Fang"] = { emoji = "🦷", color = Color3.fromRGB(255, 248, 220), shape = "sword", glowColor = nil },
	["Serpent's Eye"] = { emoji = "👁️", color = Color3.fromRGB(0, 128, 128), shape = "gem", glowColor = Color3.fromRGB(0, 255, 255) },
	["Guardian's Blessing"] = { emoji = "✨", color = Color3.fromRGB(255, 248, 220), shape = "gem", glowColor = Color3.fromRGB(255, 255, 255) },
	["Corrupted Plate"] = { emoji = "🛡️", color = Color3.fromRGB(75, 0, 130), shape = "shield", glowColor = Color3.fromRGB(138, 43, 226) },
	["Ancient Key"] = { emoji = "🗝️", color = Color3.fromRGB(255, 215, 0), shape = "misc", glowColor = Color3.fromRGB(255, 255, 0) },

	-- === PLATELEGS ===
	["Bronze Platelegs"] = { emoji = "🦿", color = Color3.fromRGB(176, 141, 87), shape = "shield", glowColor = nil },
	["Iron Platelegs"] = { emoji = "🦿", color = Color3.fromRGB(169, 169, 169), shape = "shield", glowColor = nil },
	["Gold Platelegs"] = { emoji = "🦿", color = Color3.fromRGB(255, 215, 0), shape = "shield", glowColor = Color3.fromRGB(255, 255, 0) },
	["Runite Platelegs"] = { emoji = "🦿", color = Color3.fromRGB(0, 139, 139), shape = "shield", glowColor = Color3.fromRGB(0, 255, 255) },
	["Dragon Platelegs"] = { emoji = "🦿", color = Color3.fromRGB(178, 34, 34), shape = "shield", glowColor = Color3.fromRGB(255, 0, 0) },

	-- === PLATEBODIES ===
	["Bronze Platebody"] = { emoji = "🛡️", color = Color3.fromRGB(176, 141, 87), shape = "shield", glowColor = nil },
	["Iron Platebody"] = { emoji = "🛡️", color = Color3.fromRGB(169, 169, 169), shape = "shield", glowColor = nil },
	["Gold Platebody"] = { emoji = "🛡️", color = Color3.fromRGB(255, 215, 0), shape = "shield", glowColor = Color3.fromRGB(255, 255, 0) },
	["Runite Platebody"] = { emoji = "🛡️", color = Color3.fromRGB(0, 139, 139), shape = "shield", glowColor = Color3.fromRGB(0, 255, 255) },
	["Dragon Platebody"] = { emoji = "🛡️", color = Color3.fromRGB(178, 34, 34), shape = "shield", glowColor = Color3.fromRGB(255, 0, 0) },

	-- === CHAINMAIL ===
	["Iron Chainbody"] = { emoji = "⛓️", color = Color3.fromRGB(169, 169, 169), shape = "shield", glowColor = nil },
	["Gold Chainbody"] = { emoji = "⛓️", color = Color3.fromRGB(255, 215, 0), shape = "shield", glowColor = nil },
	["Runite Chainbody"] = { emoji = "⛓️", color = Color3.fromRGB(0, 139, 139), shape = "shield", glowColor = nil },

	-- === LEATHER/RANGER ARMOR ===
	["Leather Body"] = { emoji = "👕", color = Color3.fromRGB(139, 90, 43), shape = "shield", glowColor = nil },
	["Leather Chaps"] = { emoji = "👖", color = Color3.fromRGB(139, 90, 43), shape = "shield", glowColor = nil },
	["Studded Body"] = { emoji = "👕", color = Color3.fromRGB(101, 67, 33), shape = "shield", glowColor = nil },
	["Studded Chaps"] = { emoji = "👖", color = Color3.fromRGB(101, 67, 33), shape = "shield", glowColor = nil },
	["Dragonhide Body"] = { emoji = "👕", color = Color3.fromRGB(0, 100, 0), shape = "shield", glowColor = Color3.fromRGB(0, 255, 0) },
	["Dragonhide Chaps"] = { emoji = "👖", color = Color3.fromRGB(0, 100, 0), shape = "shield", glowColor = Color3.fromRGB(0, 255, 0) },

	-- === NEW AREA MONSTER DROPS (MapSetup5) ===
	
	-- Pirate Ghost drops
	["Ghost Doubloon"] = { emoji = "👻", color = Color3.fromRGB(200, 220, 255), shape = "misc", glowColor = Color3.fromRGB(100, 200, 255) },
	["Pirate Cutlass"] = { emoji = "⚔️", color = Color3.fromRGB(192, 192, 192), shape = "sword", glowColor = Color3.fromRGB(100, 200, 255) },
	["Spectral Cloth"] = { emoji = "🕸️", color = Color3.fromRGB(240, 248, 255), shape = "misc", glowColor = Color3.fromRGB(200, 220, 255) },
	
	-- Ice Elemental drops
	["Frozen Shard"] = { emoji = "❄️", color = Color3.fromRGB(173, 216, 230), shape = "gem", glowColor = Color3.fromRGB(0, 255, 255) },
	["Ice Crystal"] = { emoji = "💎", color = Color3.fromRGB(173, 216, 230), shape = "gem", glowColor = Color3.fromRGB(100, 200, 255) },
	["Frost Essence"] = { emoji = "🧊", color = Color3.fromRGB(240, 248, 255), shape = "gem", glowColor = Color3.fromRGB(200, 230, 255) },
	["Permafrost Ore"] = { emoji = "🧊", color = Color3.fromRGB(173, 216, 230), shape = "ore", glowColor = Color3.fromRGB(0, 255, 255) },
	
	-- Lava Golem drops
	["Magma Core"] = { emoji = "🌋", color = Color3.fromRGB(255, 69, 0), shape = "gem", glowColor = Color3.fromRGB(255, 140, 0) },
	["Obsidian Shard"] = { emoji = "🖤", color = Color3.fromRGB(20, 20, 20), shape = "gem", glowColor = nil },
	["Volcanic Ash"] = { emoji = "🌋", color = Color3.fromRGB(64, 64, 64), shape = "misc", glowColor = nil },
	["Lava Blade"] = { emoji = "🔥", color = Color3.fromRGB(255, 69, 0), shape = "sword", glowColor = Color3.fromRGB(255, 140, 0) },
	
	-- Fairy Dragon drops
	["Fairy Dust"] = { emoji = "✨", color = Color3.fromRGB(255, 192, 203), shape = "misc", glowColor = Color3.fromRGB(255, 20, 147) },
	["Dragon Scale"] = { emoji = "🐲", color = Color3.fromRGB(255, 69, 0), shape = "misc", glowColor = Color3.fromRGB(255, 140, 0) },
	["Enchanted Petal"] = { emoji = "🌸", color = Color3.fromRGB(255, 182, 193), shape = "misc", glowColor = Color3.fromRGB(255, 20, 147) },
	["Rainbow Gem"] = { emoji = "🌈", color = Color3.fromRGB(255, 255, 255), shape = "gem", glowColor = Color3.fromRGB(255, 0, 255) },
	
	-- Ancient Guardian drops
	["Ancient Relic"] = { emoji = "🏺", color = Color3.fromRGB(139, 134, 130), shape = "misc", glowColor = Color3.fromRGB(0, 255, 0) },
	["Guardian Essence"] = { emoji = "💚", color = Color3.fromRGB(0, 255, 0), shape = "gem", glowColor = Color3.fromRGB(50, 255, 50) },
	["Rune of Power"] = { emoji = "🔮", color = Color3.fromRGB(138, 43, 226), shape = "gem", glowColor = Color3.fromRGB(180, 50, 255) },
	["Ancient Armor"] = { emoji = "🛡️", color = Color3.fromRGB(139, 134, 130), shape = "shield", glowColor = Color3.fromRGB(0, 255, 0) },
	
	-- Frost Wyrm drops
	["Wyrm Scale"] = { emoji = "🐍", color = Color3.fromRGB(173, 216, 230), shape = "misc", glowColor = Color3.fromRGB(100, 200, 255) },
	["Frozen Heart"] = { emoji = "💙", color = Color3.fromRGB(173, 216, 230), shape = "gem", glowColor = Color3.fromRGB(0, 255, 255) },
	["Ice Fang"] = { emoji = "🧊", color = Color3.fromRGB(240, 248, 255), shape = "sword", glowColor = Color3.fromRGB(100, 200, 255) },
	["Frost Armor"] = { emoji = "🧊", color = Color3.fromRGB(173, 216, 230), shape = "shield", glowColor = Color3.fromRGB(0, 255, 255) },

	-- === LICH KING MALACHAR DROPS ===
	["Lich Crown"] = { emoji = "👑", color = Color3.fromRGB(200, 195, 175), shape = "default", glowColor = Color3.fromRGB(0, 255, 80) },
	["Soul Staff"] = { emoji = "🔮", color = Color3.fromRGB(40, 20, 15), shape = "sword", glowColor = Color3.fromRGB(0, 255, 80) },
	["Dark Essence"] = { emoji = "💀", color = Color3.fromRGB(20, 20, 30), shape = "gem", glowColor = Color3.fromRGB(0, 200, 60) },
	["Necrotic Robe"] = { emoji = "🧥", color = Color3.fromRGB(15, 10, 25), shape = "default", glowColor = Color3.fromRGB(0, 180, 50) },
	["Bone Dust"] = { emoji = "💨", color = Color3.fromRGB(220, 215, 200), shape = "default", glowColor = nil },

	-- === PRESTIGE CAPES ===
	["Prestige Cape I"] = { emoji = "🎖️", color = Color3.fromRGB(192, 192, 192), shape = "misc", glowColor = nil },
	["Prestige Cape II"] = { emoji = "🎖️", color = Color3.fromRGB(200, 200, 220), shape = "misc", glowColor = Color3.fromRGB(180, 180, 255) },
	["Prestige Cape III"] = { emoji = "🏅", color = Color3.fromRGB(0, 120, 215), shape = "misc", glowColor = Color3.fromRGB(0, 180, 255) },
	["Prestige Cape IV"] = { emoji = "🏅", color = Color3.fromRGB(0, 180, 0), shape = "misc", glowColor = Color3.fromRGB(0, 255, 100) },
	["Prestige Cape V"] = { emoji = "⭐", color = Color3.fromRGB(255, 215, 0), shape = "misc", glowColor = Color3.fromRGB(255, 255, 0) },
	["Prestige Cape VI"] = { emoji = "⭐", color = Color3.fromRGB(255, 100, 0), shape = "misc", glowColor = Color3.fromRGB(255, 160, 0) },
	["Prestige Cape VII"] = { emoji = "💎", color = Color3.fromRGB(220, 20, 60), shape = "misc", glowColor = Color3.fromRGB(255, 50, 50) },
	["Prestige Cape VIII"] = { emoji = "💎", color = Color3.fromRGB(138, 43, 226), shape = "misc", glowColor = Color3.fromRGB(200, 100, 255) },
	["Prestige Cape IX"] = { emoji = "👑", color = Color3.fromRGB(20, 20, 20), shape = "misc", glowColor = Color3.fromRGB(255, 0, 0) },
	["Prestige Cape X"] = { emoji = "👑", color = Color3.fromRGB(25, 0, 50), shape = "misc", glowColor = Color3.fromRGB(255, 215, 0) },

	-- === PREMIUM GEAR VISUALS - STARWEAVE SET ===
	["Starweave Sword"] = { emoji = "⚔️", color = Color3.fromRGB(192, 210, 235), shape = "sword", glowColor = Color3.fromRGB(100, 180, 255) },
	["Starweave Helm"] = { emoji = "⛑️", color = Color3.fromRGB(192, 210, 235), shape = "misc", glowColor = Color3.fromRGB(100, 180, 255) },
	["Starweave Platebody"] = { emoji = "🛡️", color = Color3.fromRGB(192, 210, 235), shape = "misc", glowColor = Color3.fromRGB(100, 180, 255) },
	["Starweave Platelegs"] = { emoji = "🦿", color = Color3.fromRGB(192, 210, 235), shape = "misc", glowColor = Color3.fromRGB(100, 180, 255) },
	["Starweave Shield"] = { emoji = "🛡️", color = Color3.fromRGB(192, 210, 235), shape = "shield", glowColor = Color3.fromRGB(100, 180, 255) },

	-- === PREMIUM GEAR VISUALS - EMBERFROST SET ===
	["Emberfrost Blade"] = { emoji = "⚔️", color = Color3.fromRGB(255, 140, 50), shape = "sword", glowColor = Color3.fromRGB(0, 255, 255) },
	["Emberfrost Crown"] = { emoji = "👑", color = Color3.fromRGB(255, 140, 50), shape = "misc", glowColor = Color3.fromRGB(0, 255, 255) },
	["Emberfrost Platebody"] = { emoji = "🛡️", color = Color3.fromRGB(255, 140, 50), shape = "misc", glowColor = Color3.fromRGB(0, 255, 255) },
	["Emberfrost Platelegs"] = { emoji = "🦿", color = Color3.fromRGB(255, 140, 50), shape = "misc", glowColor = Color3.fromRGB(0, 255, 255) },
	["Emberfrost Bulwark"] = { emoji = "🛡️", color = Color3.fromRGB(255, 140, 50), shape = "shield", glowColor = Color3.fromRGB(0, 255, 255) },

	-- === PREMIUM GEAR VISUALS - VOIDBORN SET ===
	["Voidborn Greatsword"] = { emoji = "⚔️", color = Color3.fromRGB(80, 0, 160), shape = "sword", glowColor = Color3.fromRGB(255, 215, 0) },
	["Voidborn Visage"] = { emoji = "👹", color = Color3.fromRGB(80, 0, 160), shape = "misc", glowColor = Color3.fromRGB(255, 215, 0) },
	["Voidborn Platebody"] = { emoji = "🛡️", color = Color3.fromRGB(80, 0, 160), shape = "misc", glowColor = Color3.fromRGB(255, 215, 0) },
	["Voidborn Platelegs"] = { emoji = "🦿", color = Color3.fromRGB(80, 0, 160), shape = "misc", glowColor = Color3.fromRGB(255, 215, 0) },
	["Voidborn Aegis"] = { emoji = "🛡️", color = Color3.fromRGB(80, 0, 160), shape = "shield", glowColor = Color3.fromRGB(255, 215, 0) },
}

-- Helper function to get item visuals by name
function ItemVisuals.GetVisual(itemName)
	return ItemVisuals.Items[itemName] or {
		emoji = "❓",
		color = Color3.fromRGB(128, 128, 128),
		shape = "misc",
		glowColor = nil
	}
end

-- Helper function to get item color
function ItemVisuals.GetColor(itemName)
	local visual = ItemVisuals.GetVisual(itemName)
	return visual.color
end

-- Helper function to get item emoji
function ItemVisuals.GetEmoji(itemName)
	local visual = ItemVisuals.GetVisual(itemName)
	return visual.emoji
end

-- Helper function to get item shape for 3D drops
function ItemVisuals.GetShape(itemName)
	local visual = ItemVisuals.GetVisual(itemName)
	return visual.shape
end

-- Helper function to get glow color (if any)
function ItemVisuals.GetGlowColor(itemName)
	local visual = ItemVisuals.GetVisual(itemName)
	return visual.glowColor
end

return ItemVisuals