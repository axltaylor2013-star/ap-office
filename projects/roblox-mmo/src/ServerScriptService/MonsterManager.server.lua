--[[
	MonsterManager.server.lua
	ServerScriptService

	Spawns all monsters in the world, runs their AI (wander / aggro / attack),
	handles death, loot bags, respawning, and XP awards.
]]

--------------------------------------------------------------------------------
-- SERVICES & MODULES
--------------------------------------------------------------------------------
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")

-- Wait for map to finish building
task.wait(4)

local MonsterDatabase = require(ReplicatedStorage.Modules.MonsterDatabase)
local DataManager     = require(ReplicatedStorage.Modules.DataManager)
local ItemDatabase    = require(ReplicatedStorage.Modules.ItemDatabase)
local ItemVisuals     = require(ReplicatedStorage.Modules.ItemVisuals)

--------------------------------------------------------------------------------
-- REMOTE EVENTS (from Remotes folder in project.json)
--------------------------------------------------------------------------------
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local TweenService = game:GetService("TweenService")

local MonsterDamageEvent = Remotes:WaitForChild("MonsterDamage", 10)
local MonsterDeathEvent  = Remotes:WaitForChild("MonsterDeath", 10)
local MonsterLootEvent   = Remotes:WaitForChild("MonsterLoot", 10)
local XPPopupEvent       = Remotes:WaitForChild("XPPopup", 10)

--------------------------------------------------------------------------------
-- CONSTANTS
--------------------------------------------------------------------------------
local WANDER_RADIUS        = 15
local AGGRO_RANGE_DEFAULT  = 20
local AGGRO_RANGE_PASSIVE  = 10
local AGGRO_RANGE_BOSS     = 40
local DEAGGRO_RANGE        = 40
local LEASH_RANGE          = 80  -- max distance from spawn before forced deaggro
local ATTACK_RANGE         = 7
local ATTACK_COOLDOWN      = 2
local LOOT_DESPAWN_TIME    = 30
local WANDER_INTERVAL      = 3   -- seconds between wander moves
local MOVE_SPEED           = 12  -- studs/sec for normal monsters
local MOVE_SPEED_BOSS      = 8

--------------------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------------------
local activeMonsters = {}  -- model -> state table
local totalSpawned = 0

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------
local RNG = Random.new()

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function randomInRange(min, max)
	return lerp(min, max, RNG:NextNumber())
end

--- Pick a random point within a rectangle defined by min/max x/z, at ground level
local function randomPointInRect(xMin, xMax, zMin, zMax)
	return Vector3.new(
		randomInRange(xMin, xMax),
		0,
		randomInRange(zMin, zMax)
	)
end

--- Distance between two Vector3 (XZ plane only)
local function distXZ(a, b)
	local dx = a.X - b.X
	local dz = a.Z - b.Z
	return math.sqrt(dx * dx + dz * dz)
end

--------------------------------------------------------------------------------
-- MONSTER MODEL BUILDER
--------------------------------------------------------------------------------
local function buildMonsterModel(def, position)
	local model = Instance.new("Model")
	model.Name = def.name

	local m = def.model

	-- Body
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Shape = Enum.PartType.Block
	body.Size = m.size
	body.Color = m.bodyColor
	body.Anchored = true
	body.CanCollide = true
	-- Auto-calculate elevation: find the lowest bodyRelative extra so nothing clips underground
	local lowestY = 0
	if m.extras then
		for _, extra in ipairs(m.extras) do
			if extra.bodyRelative and extra.offset then
				local partBottom = extra.offset.Y - (extra.size and extra.size.Y / 2 or 0)
				if partBottom < lowestY then
					lowestY = partBottom
				end
			end
		end
	end
	-- Body center Y: must be high enough that lowest extra touches ground (Y=0)
	local autoElevation = math.abs(lowestY)
	local bodyY = math.max(m.size.Y / 2, m.elevation or 0, autoElevation)
	body.Position = Vector3.new(position.X, bodyY, position.Z)
	body.Parent = model

	-- Head (ball on top of body)
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(m.headSize, m.headSize, m.headSize) * 2
	head.Color = m.bodyColor
	head.Anchored = true
	head.CanCollide = false
	head.Position = Vector3.new(position.X, bodyY + m.size.Y / 2 + m.headSize, position.Z)
	head.Parent = model

	-- Humanoid (for health tracking)
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = def.hp
	humanoid.Health = def.hp
	humanoid.Parent = model

	-- PrimaryPart
	model.PrimaryPart = body

	-- BillboardGui Ã¢â'¬" name, level, HP bar
	local bbg = Instance.new("BillboardGui")
	bbg.Name = "OverheadGui"
	bbg.Size = UDim2.new(4, 0, 1.5, 0)
	bbg.StudsOffset = Vector3.new(0, m.size.Y / 2 + m.headSize * 2 + 1, 0)
	bbg.AlwaysOnTop = true
	bbg.Adornee = body
	bbg.Parent = model

	-- Name label
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = def.name .. (def.level > 0 and (" [Lv." .. def.level .. "]") or "")
	nameLabel.TextColor3 = def.boss and Color3.fromRGB(255, 50, 50) or
	                        def.zone == "Wilderness" and Color3.fromRGB(255, 170, 50) or
	                        Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = bbg

	-- HP bar background
	local hpBg = Instance.new("Frame")
	hpBg.Name = "HPBarBG"
	hpBg.Size = UDim2.new(0.8, 0, 0.15, 0)
	hpBg.Position = UDim2.new(0.1, 0, 0.45, 0)
	hpBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	hpBg.BorderSizePixel = 0
	hpBg.Parent = bbg

	local hpFill = Instance.new("Frame")
	hpFill.Name = "HPFill"
	hpFill.Size = UDim2.new(1, 0, 1, 0)
	hpFill.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	hpFill.BorderSizePixel = 0
	hpFill.Parent = hpBg

	-- HP text
	local hpText = Instance.new("TextLabel")
	hpText.Name = "HPText"
	hpText.Size = UDim2.new(1, 0, 0.3, 0)
	hpText.Position = UDim2.new(0, 0, 0.65, 0)
	hpText.BackgroundTransparency = 1
	hpText.Text = def.hp .. " / " .. def.hp
	hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
	hpText.TextScaled = true
	hpText.Font = Enum.Font.Gotham
	hpText.Parent = bbg

	-- ClickDetector for targeting - ADD TO ALL PARTS
	local function addClickDetectorToAllParts()
		for _, child in ipairs(model:GetChildren()) do
			if child:IsA("BasePart") then
				local click = Instance.new("ClickDetector")
				click.Name = "TargetClick"
				click.MaxActivationDistance = 30
				click.Parent = child
			end
		end
	end

	-- === EXTRA PARTS (legs, arms, horns, eyes, etc.) ===
	if m.extras then
		for _, extra in ipairs(m.extras) do
			local part = Instance.new("Part")
			part.Name = extra.name
			part.Anchored = true
			part.CanCollide = false
			part.Size = extra.size
			part.Color = extra.color
			part.Material = extra.material or Enum.Material.SmoothPlastic
			if extra.transparency then
				part.Transparency = extra.transparency
			end

			if extra.shape == "Ball" then
				part.Shape = Enum.PartType.Ball
			else
				part.Shape = Enum.PartType.Block
			end

			-- Position relative to body or head
			if extra.bodyRelative then
				part.Position = body.Position + extra.offset
			else
				-- Relative to head
				part.Position = head.Position + extra.offset
			end

			if extra.rotation then
				part.Orientation = extra.rotation
			end

			-- Add glow for neon parts
			if extra.material == Enum.Material.Neon then
				local light = Instance.new("PointLight")
				light.Color = extra.color
				light.Brightness = 1
				light.Range = 6
				light.Parent = part
			end

			part.Parent = model
		end
	end

	-- Add ClickDetectors to all parts
	addClickDetectorToAllParts()

	return model
end

--------------------------------------------------------------------------------
-- HP BAR UPDATE
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- MONSTER DEATH ANIMATION
--------------------------------------------------------------------------------
local function playDeathAnimation(model, deathPos)
	-- Dust/smoke puff at death location
	for i = 1, 6 do
		local puff = Instance.new("Part")
		puff.Name = "DeathPuff"
		puff.Shape = Enum.PartType.Ball
		puff.Size = Vector3.new(1, 1, 1)
		puff.Position = deathPos + Vector3.new(math.random(-2, 2), math.random(0, 2), math.random(-2, 2))
		puff.Color = Color3.fromRGB(180, 170, 150)
		puff.Material = Enum.Material.SmoothPlastic
		puff.Anchored = true
		puff.CanCollide = false
		puff.Transparency = 0.3
		puff.Parent = workspace

		TweenService:Create(puff, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(3, 3, 3),
			Transparency = 1,
			Position = puff.Position + Vector3.new(0, 3, 0),
		}):Play()

		task.delay(1.3, function()
			if puff and puff.Parent then puff:Destroy() end
		end)
	end

	-- Body falls to the side and fades out
	local body = model.PrimaryPart
	if body then
		-- Tilt the body to fall over
		local fallCF = body.CFrame * CFrame.Angles(0, 0, math.rad(90))
		TweenService:Create(body, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = fallCF,
		}):Play()
	end

	-- Fade all parts
	for _, child in model:GetDescendants() do
		if child:IsA("BasePart") then
			TweenService:Create(child, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {
				Transparency = 1,
			}):Play()
		elseif child:IsA("BillboardGui") then
			child.Enabled = false
		end
	end

	-- Destroy after fade completes
	task.delay(2, function()
		if model and model.Parent then
			model:Destroy()
		end
	end)
end

local function updateHPBar(model, currentHP, maxHP)
	local bbg = model:FindFirstChild("OverheadGui")
	if not bbg then return end
	local bg = bbg:FindFirstChild("HPBarBG")
	if bg then
		local fill = bg:FindFirstChild("HPFill")
		if fill then
			local pct = math.clamp(currentHP / maxHP, 0, 1)
			fill.Size = UDim2.new(pct, 0, 1, 0)
			-- Color: green Ã¢â€ ' yellow Ã¢â€ ' red
			if pct > 0.5 then
				fill.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
			elseif pct > 0.25 then
				fill.BackgroundColor3 = Color3.fromRGB(220, 200, 30)
			else
				fill.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
			end
		end
	end
	local hpLabel = bbg:FindFirstChild("HPText")
	if hpLabel then
		hpLabel.Text = math.max(0, math.floor(currentHP)) .. " / " .. maxHP
	end
end

--------------------------------------------------------------------------------
-- LOOT BAG
--------------------------------------------------------------------------------
local function rollDrops(def)
	local results = {}
	for _, drop in def.drops do
		if RNG:NextNumber() <= drop.chance then
			local qty = RNG:NextInteger(drop.minQty, drop.maxQty)
			table.insert(results, { item = drop.item, qty = qty })
		end
	end
	return results
end

-- Rarity colors for loot items
local RARITY_COLORS = {
	common = Color3.fromRGB(157, 157, 157),
	uncommon = Color3.fromRGB(30, 255, 0),
	rare = Color3.fromRGB(0, 112, 221),
	epic = Color3.fromRGB(163, 53, 238),
	legendary = Color3.fromRGB(255, 128, 0),
}

local function createLootDrops(position, drops, killerPlayer)
	if #drops == 0 then return end

	-- Spread items in a circle around death position
	local angleStep = (2 * math.pi) / math.max(#drops, 1)
	local spreadRadius = 2.5

	for i, drop in ipairs(drops) do
		local angle = angleStep * (i - 1) + (math.random() * 0.5)
		local offsetX = math.cos(angle) * spreadRadius
		local offsetZ = math.sin(angle) * spreadRadius

		-- Get item visuals
		local visual = ItemVisuals.GetVisual(drop.item)
		local itemDef = ItemDatabase and ItemDatabase.Items and ItemDatabase.Items[drop.item]
		local rarity = (itemDef and itemDef.rarity) or "common"
		local rarityColor = RARITY_COLORS[rarity] or RARITY_COLORS.common

		-- Create different shapes based on item type
		local itemPart
		local dropSize = Vector3.new(1.2, 1.2, 1.2)
		
		if visual.shape == "sword" then
			-- Swords: elongated thin part
			dropSize = Vector3.new(0.3, 2.5, 0.3)
		elseif visual.shape == "shield" then
			-- Shields: flat wide part
			dropSize = Vector3.new(2.0, 0.3, 1.5)
		elseif visual.shape == "ore" or visual.shape == "bar" then
			-- Ores/bars: small cube
			dropSize = Vector3.new(0.8, 0.8, 0.8)
		elseif visual.shape == "log" then
			-- Logs: cylinder-shaped (elongated block)
			itemPart = Instance.new("Part")
			itemPart.Size = Vector3.new(0.6, 0.6, 2.0)
			itemPart.Shape = Enum.PartType.Cylinder
		elseif visual.shape == "fish" then
			-- Fish: flat oval
			dropSize = Vector3.new(1.0, 0.4, 1.8)
		elseif visual.shape == "food" then
			-- Food: small round
			itemPart = Instance.new("Part")
			itemPart.Size = Vector3.new(0.8, 0.8, 0.8)
			itemPart.Shape = Enum.PartType.Ball
		elseif visual.shape == "arrow" then
			-- Arrows: very thin long
			dropSize = Vector3.new(0.1, 0.1, 2.2)
		elseif visual.shape == "gem" then
			-- Gems: small wedge for crystalline look
			itemPart = Instance.new("WedgePart")
			itemPart.Size = Vector3.new(0.6, 0.8, 0.6)
		elseif visual.shape == "bone" then
			-- Bones: thin cylindrical
			itemPart = Instance.new("Part")
			itemPart.Size = Vector3.new(0.3, 0.3, 1.5)
			itemPart.Shape = Enum.PartType.Cylinder
		elseif visual.shape == "feather" then
			-- Feathers: thin flat
			dropSize = Vector3.new(0.8, 0.1, 1.2)
		elseif visual.shape == "bow" then
			-- Bows: elongated curved (approximated with block)
			dropSize = Vector3.new(0.4, 1.8, 0.2)
		else
			-- Default: small cube for misc items
			dropSize = Vector3.new(1.0, 1.0, 1.0)
		end
		
		-- Create part if not already created
		if not itemPart then
			itemPart = Instance.new("Part")
			itemPart.Size = dropSize
			itemPart.Shape = Enum.PartType.Block
		end

		itemPart.Name = "LootDrop_" .. drop.item
		itemPart.Anchored = true
		itemPart.CanCollide = false
		itemPart.Position = position + Vector3.new(offsetX, 0.6, offsetZ)
		itemPart.Material = Enum.Material.SmoothPlastic
		
		-- Use item's unique color from ItemVisuals
		itemPart.Color = visual.color
		
		-- Add glow effect for special items
		if visual.glowColor then
			local glow = Instance.new("PointLight")
			glow.Color = visual.glowColor
			glow.Brightness = 2
			glow.Range = 8
			glow.Parent = itemPart
		end

		itemPart.Parent = workspace

		-- Floating label with item emoji and name
		local bbg = Instance.new("BillboardGui")
		bbg.Size = UDim2.new(5, 0, 1, 0)
		bbg.StudsOffset = Vector3.new(0, 1.5, 0)
		bbg.AlwaysOnTop = true
		bbg.Adornee = itemPart
		bbg.Parent = itemPart

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		
		-- Display emoji + name + quantity
		local displayText = visual.emoji .. " " .. drop.item
		if drop.qty > 1 then
			displayText = displayText .. " x" .. drop.qty
		end
		
		label.Text = displayText
		label.TextColor3 = rarityColor
		label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		label.TextStrokeTransparency = 0
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Parent = bbg

		-- Click to pick up
		local click = Instance.new("ClickDetector")
		click.MaxActivationDistance = 14
		click.Parent = itemPart

		local picked = false
		click.MouseClick:Connect(function(player)
			if picked then return end
			picked = true

			local ok, err = pcall(function()
				DataManager.AddItem(player, drop.item, drop.qty)
			end)
			if not ok then
				warn("[MonsterManager] Failed to give item:", err)
			end

			-- Notify client
			MonsterLootEvent:FireClient(player, {{item = drop.item, qty = drop.qty}})

			-- Pick up effect: shrink and vanish
			local TweenService = game:GetService("TweenService")
			local tween = TweenService:Create(itemPart, TweenInfo.new(0.3), {
				Size = Vector3.new(0.1, 0.1, 0.1),
				Transparency = 1,
			})
			tween:Play()
			tween.Completed:Once(function()
				itemPart:Destroy()
			end)
		end)

		-- Gentle bobbing animation (with race condition protection)
		task.spawn(function()
			if not itemPart or not itemPart.Parent then return end
			local startY = itemPart.Position.Y
			local t = math.random() * math.pi * 2 -- random phase so items don't bob in sync
			while true do
				-- Double-check every iteration to prevent race condition
				if not itemPart or not itemPart.Parent then break end
				t = t + 0.05
				
				-- Protect the Position assignment
				local success, err = pcall(function()
					if itemPart and itemPart.Parent then
						itemPart.Position = Vector3.new(
							itemPart.Position.X,
							startY + math.sin(t) * 0.3,
							itemPart.Position.Z
						)
					end
				end)
				if not success then break end -- Exit loop if casting error occurs
				
				task.wait(0.03)
			end
		end)

		-- Auto-despawn
		task.delay(LOOT_DESPAWN_TIME, function()
			if itemPart and itemPart.Parent then
				itemPart:Destroy()
			end
		end)
	end
end

--------------------------------------------------------------------------------
-- MOVEMENT HELPERS
--------------------------------------------------------------------------------
local function moveModelTo(model, targetPos, dt, speed)
	local body = model.PrimaryPart
	if not body then return end
	local current = body.Position
	local dir = (targetPos - current) * Vector3.new(1, 0, 1) -- XZ only
	local dist = dir.Magnitude
	if dist < 0.5 then return end

	local step = math.min(speed * dt, dist)
	local offset = dir.Unit * step
	local newPos = current + offset

	-- Keep Y stable
	newPos = Vector3.new(newPos.X, current.Y, newPos.Z)

	-- Face movement direction and move entire model atomically
	local newCF = CFrame.new(newPos, newPos + dir.Unit)
	model:PivotTo(newCF)
end

local function teleportModel(model, pos)
	local body = model.PrimaryPart
	if not body then return end
	-- Keep current rotation, just change position
	local oldCF = body.CFrame
	local newCF = CFrame.new(pos) * (oldCF - oldCF.Position)
	model:PivotTo(newCF)
end

--------------------------------------------------------------------------------
-- FIND NEAREST PLAYER (alive, with character)
--------------------------------------------------------------------------------
local function findNearestPlayer(position, maxRange)
	local nearest= nil
	local nearestDist = math.huge
	for _, player in Players:GetPlayers() do
		local char = player.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hrp and hum and hum.Health > 0 then
				local d = distXZ(position, hrp.Position)
				if d < nearestDist and d <= maxRange then
					nearestDist = d
					nearest = player
				end
			end
		end
	end
	return nearest, nearestDist
end

--------------------------------------------------------------------------------
-- SPAWN A SINGLE MONSTER
--------------------------------------------------------------------------------
local function spawnMonster(defKey, position)
	local def = MonsterDatabase.Monsters[defKey]
	if not def then
		warn("[MonsterManager] Unknown monster key:", defKey)
		return
	end

	local model = buildMonsterModel(def, position)
	model.Parent = workspace

	-- State
	local state = {
		defKey       = defKey,
		def          = def,
		model        = model,
		spawnPos     = position,
		currentHP    = def.hp,
		maxHP        = def.hp,
		alive        = true,
		aiState      = "idle",   -- idle | wander | chase | returning
		wanderTarget = nil,
		wanderTimer  = RNG:NextNumber() * WANDER_INTERVAL, -- stagger initial wander
		attackTimer  = 0,
		targetPlayer = nil,
	}

	activeMonsters[model] = state

	-- ClickDetector: player attacks monster (connect ALL ClickDetectors)
	local function onMonsterClicked(player)
			if not state.alive then return end

			local char = player.Character
			if not char then return end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end

			-- Must be close enough to attack
			if distXZ(hrp.Position, model.PrimaryPart.Position) > ATTACK_RANGE * 3 then return end

			-- Player deals damage (base + weapon + level bonus)
			local playerLevel = 1
			pcall(function()
				playerLevel = DataManager.GetCombatLevel(player) or 1
			end)
			-- Check equipped weapon damage
			local weaponDmg = 0
			pcall(function()
				local data = DataManager:GetData(player)
				if data and data.Equipment and data.Equipment.Weapon and data.Equipment.Weapon ~= "" then
					local weaponInfo = ItemDatabase.GetItem(data.Equipment.Weapon)
					if weaponInfo and weaponInfo.damage then
						weaponDmg = weaponInfo.damage
					end
				end
			end)
			local baseDmg = math.max(5, weaponDmg)
			local dmg = baseDmg + math.floor(playerLevel * 1.5)
			-- Random variance 80-120%
			dmg = math.floor(dmg * (0.8 + math.random() * 0.4))

			state.currentHP = state.currentHP - dmg
			updateHPBar(model, state.currentHP, state.maxHP)

			-- Fire to all clients for hit effects (include attacker for animation trigger)
			MonsterDamageEvent:FireAllClients(model, dmg, state.currentHP, state.maxHP, player)

			-- Determine weapon type for animation
			local weaponTypeForAnim = "unarmed"
			pcall(function()
				local data = DataManager:GetData(player)
				if data and data.Equipment and data.Equipment.Weapon and data.Equipment.Weapon ~= "" then
					local wName = data.Equipment.Weapon:lower()
					if wName:find("bow") or wName:find("crossbow") then
						weaponTypeForAnim = "ranged"
					else
						weaponTypeForAnim = "melee"
					end
				end
			end)

			-- Broadcast player attack visual to nearby clients
			if shared.AttackVisualHandler then
				shared.AttackVisualHandler.BroadcastPlayerAttack(player, model, weaponTypeForAnim, dmg >= (state.maxHP * 0.2))
			end

			-- Aggro onto attacker
			if state.aiState ~= "chase" then
				state.aiState = "chase"
				state.targetPlayer = player
			end

			-- Death check
			if state.currentHP <= 0 and not def.immortal then
				state.alive = false
				state.currentHP = 0
				updateHPBar(model, 0, state.maxHP)

				-- Award XP
				pcall(function()
					DataManager.AddSkillXP(player, "Strength", def.xp)
				end)

				-- Roll & drop loot
				local drops = rollDrops(def)
				local deathPos = model.PrimaryPart.Position
				MonsterDeathEvent:FireAllClients(model, player, drops)

				-- Send XP popup to killer
				XPPopupEvent:FireClient(player, deathPos, def.xp, def.name)

				-- Remove from active tracking immediately (stop AI)
				activeMonsters[model] = nil

				-- Play death animation (delays destroy by 2s)
				playDeathAnimation(model, deathPos)

				-- Drop individual loot items
				createLootDrops(deathPos, drops, player)

				-- Respawn after delay (add 2s for death anim)
				task.delay(def.respawnTime + 2, function()
					spawnMonster(defKey, position)
				end)
			end
	end

	-- Connect all ClickDetectors in the model to the click handler
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("ClickDetector") and desc.Name == "TargetClick" then
			desc.MouseClick:Connect(onMonsterClicked)
		end
	end

	totalSpawned += 1
end

--------------------------------------------------------------------------------
-- AI LOOP (runs every Heartbeat)
--------------------------------------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
	for model, state in activeMonsters do
		if not state.alive then continue end
		if state.def.stationary then continue end
		if not model.PrimaryPart then continue end

		local pos = model.PrimaryPart.Position
		local aggroRange = state.def.boss and AGGRO_RANGE_BOSS
		                   or state.def.passive and AGGRO_RANGE_PASSIVE
		                   or AGGRO_RANGE_DEFAULT
		local speed = state.def.boss and MOVE_SPEED_BOSS or MOVE_SPEED

		--------------------------------------------------------------------
		-- ATTACK TIMER (deal damage while chasing & in range)
		--------------------------------------------------------------------
		if state.aiState == "chase" and state.targetPlayer then
			state.attackTimer -= dt
			local char = state.targetPlayer.Character
			if char then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hrp and hum and hum.Health > 0 then
					local d = distXZ(pos, hrp.Position)
					local distFromSpawn = distXZ(pos, state.spawnPos)

					-- De-aggro if player too far OR monster too far from spawn (leash)
					if d > DEAGGRO_RANGE or distFromSpawn > LEASH_RANGE then
						state.aiState = "returning"
						state.targetPlayer = nil
					else
						-- Move toward player
						moveModelTo(model, hrp.Position, dt, speed)

						-- Attack if close enough
						if d <= ATTACK_RANGE and state.attackTimer <= 0 then
							state.attackTimer = ATTACK_COOLDOWN
							hum:TakeDamage(state.def.damage)

							-- Broadcast monster attack visual
							if shared.AttackVisualHandler then
								shared.AttackVisualHandler.BroadcastMonsterAttack(model, state.targetPlayer, state.def.name)
								-- Send hit effect to target player
								if hrp then
									shared.AttackVisualHandler.BroadcastHitEffect(
										hrp.Position,
										state.def.damage,
										"damage_taken",
										state.def.damage >= 50,
										state.targetPlayer
									)
								end
							end
						end
					end
				else
					-- Player dead or gone
					state.aiState = "returning"
					state.targetPlayer = nil
				end
			else
				state.aiState = "returning"
				state.targetPlayer = nil
			end

		--------------------------------------------------------------------
		-- RETURNING TO SPAWN
		--------------------------------------------------------------------
		elseif state.aiState == "returning" then
			local d = distXZ(pos, state.spawnPos)
			if d < 2 then
				state.aiState = "idle"
				state.wanderTimer = WANDER_INTERVAL
			else
				moveModelTo(model, state.spawnPos, dt, speed)
			end

			-- Heal while returning
			if state.currentHP < state.maxHP then
				state.currentHP = math.min(state.maxHP, state.currentHP + state.maxHP * 0.05 * dt)
				updateHPBar(model, state.currentHP, state.maxHP)
			end

		--------------------------------------------------------------------
		-- IDLE / WANDER
		--------------------------------------------------------------------
		else
			-- Check for nearby player to aggro
			local nearPlayer, nearDist = findNearestPlayer(pos, aggroRange)
			if nearPlayer then
				state.aiState = "chase"
				state.targetPlayer = nearPlayer
				state.attackTimer = 0
			else
				-- Wander logic
				state.wanderTimer -= dt
				if state.wanderTimer <= 0 then
					state.wanderTimer = WANDER_INTERVAL + RNG:NextNumber() * 2
					-- Pick random point near spawn
					local angle = RNG:NextNumber() * math.pi * 2
					local radius = RNG:NextNumber() * WANDER_RADIUS
					state.wanderTarget = state.spawnPos + Vector3.new(
						math.cos(angle) * radius,
						0,
						math.sin(angle) * radius
					)
					state.aiState = "wander"
				end

				if state.aiState == "wander" and state.wanderTarget then
					local d = distXZ(pos, state.wanderTarget)
					if d < 1 then
						state.aiState = "idle"
					else
						moveModelTo(model, state.wanderTarget, dt, speed * 0.4) -- slow wander
					end
				end
			end
		end
	end
end)

--------------------------------------------------------------------------------
-- SPAWN DEFINITIONS Ã¢â'¬" where each monster type appears in the world
--------------------------------------------------------------------------------
local spawnTable = {
	-- SAFE ZONE
	{ key = "Chicken",       count = 5, xMin = 120,  xMax = 180,  zMin = 120,  zMax = 160  },
	{ key = "Cow",           count = 4, xMin = 160,  xMax = 220,  zMin = 140,  zMax = 180  },
	{ key = "Goblin",        count = 4, xMin = -30,  xMax = 30,   zMin = 170,  zMax = 200  },
	{ key = "GuardDog",      count = 3, xMin = 160,  xMax = 200,  zMin = 0,    zMax = 40   },
	{ key = "GiantRat",      count = 5, xMin = -110, xMax = -80,  zMin = 20,   zMax = 40   },
	{ key = "TrainingDummy", count = 3, xMin = 170,  xMax = 210,  zMin = 10,   zMax = 40   },

	-- SAFE ZONE BOSSES
	{ key = "King Rooster",       count = 1, xMin = 140,  xMax = 160,  zMin = 130,  zMax = 150  },
	{ key = "Elder Treant",       count = 1, xMin = -200, xMax = -150, zMin = -30,  zMax = 30   },
	{ key = "Iron Golem",         count = 1, xMin = 190,  xMax = 220,  zMin = 20,   zMax = 50   },
	{ key = "Lake Serpent",       count = 1, xMin = -170, xMax = -130, zMin = 140,  zMax = 180  },
	{ key = "Corrupted Guardian", count = 1, xMin = 210,  xMax = 230,  zMin = -75,  zMax = -55  },

	-- WILDERNESS
	{ key = "Skeleton",      count = 5, xMin = -50,  xMax = -20,  zMin = -160, zMax = -140 },
	{ key = "DarkWizard",    count = 3, xMin = 50,   xMax = 70,   zMin = -180, zMax = -170 },
	{ key = "Demon",         count = 3, xMin = -20,  xMax = 20,   zMin = -320, zMax = -280 },

	-- NEW AREA MONSTERS (MapSetup5)
	-- Pirate Cove (X: 300-400, Z: -200 to -100) - Safe Zone
	{ key = "Pirate Ghost",  count = 4, xMin = 310,  xMax = 390,  zMin = -190, zMax = -110 },
	
	-- Frozen Peaks (X: -400 to -300, Z: -300 to -200) - Safe Zone  
	{ key = "Ice Elemental", count = 3, xMin = -390, xMax = -310, zMin = -290, zMax = -210 },
	{ key = "Frost Wyrm",    count = 1, xMin = -380, xMax = -320, zMin = -280, zMax = -220 }, -- boss
	
	-- Volcanic Crater (X: 300-400, Z: -400 to -300) - Wilderness
	{ key = "Lava Golem",    count = 3, xMin = 310,  xMax = 390,  zMin = -390, zMax = -310 },
	
	-- Enchanted Garden (X: -300 to -200, Z: 200-350) - Safe Zone
	{ key = "Fairy Dragon",  count = 5, xMin = -290, xMax = -210, zMin = 210,  zMax = 340  },
	
	-- Underground Ruins (X: -100 to 50, Z: -450 to -350) - Wilderness
	{ key = "Ancient Guardian", count = 1, xMin = -90, xMax = 40,   zMin = -440, zMax = -360 }, -- boss
	
	-- Dragon's Nest (X: 0-100, Z: -500 to -450) - no regular spawns (just boss area)
}

-- Spawn all regular monsters
for _, entry in spawnTable do
	for i = 1, entry.count do
		local pos = randomPointInRect(entry.xMin, entry.xMax, entry.zMin, entry.zMax)
		spawnMonster(entry.key, pos)
	end
end

-- Crimson Warlord BOSS — mid-tier safe zone centerpiece, Battle Arena
spawnMonster("Crimson Warlord", Vector3.new(0, 0, 250))

-- Shadow Dragon BOSS — single fixed spawn (center of Dragon's Nest, accessible from all sides)
spawnMonster("ShadowDragon", Vector3.new(50, 0, -475))

-- Lich King Malachar BOSS — deep wilderness undead sorcerer
spawnMonster("Lich King Malachar", Vector3.new(-50, 0, -400))

print("[MonsterManager] Spawned " .. totalSpawned .. " monsters!")

