---
name: roblox-npc-designer
description: Design and build NPCs for Roblox games. Covers humanoid body construction, facial features, accessories, dialog systems, shop functionality, quest giving, and visual identity.
---

# Roblox NPC Designer

Reference project: `workspace/projects/roblox-mmo/` (Roscape Runeblocks)
See also: `docs/team-lessons.md`, `docs/CODE-REVIEW-CHECKLIST.md`

## Critical Rules

- **Every NPC in NPC_DEFS MUST have a matching builder function AND entry in accessoryBuilders table** — without this, NPC spawns with plain body
- **ClickDetector on ALL parts** — not just Body, use addClickToAll pattern
- **Spawn timing: task.wait(12)** to ensure all map scripts have finished
- **pcall wrapper on spawn loop** so one NPC failure doesn't kill all NPCs
- **Y=0 for ground level**, calculate body part Y from dimensions
- **Dot notation on modules**, no Luau type annotations, requires at TOP

## NPC Body Construction

```lua
local function buildBody(origin, skinColor, clothingColor)
    local model = Instance.new("Model")
    model.Name = "NPCModel"

    local torsoSize = Vector3.new(2, 2.5, 1)
    local headSize = Vector3.new(1.6, 1.6, 1.6)
    local armSize = Vector3.new(1, 2.5, 1)
    local legSize = Vector3.new(1, 2.5, 1)

    -- Legs (feet at Y=0)
    local leftLeg = makePart("LeftLeg", legSize,
        origin + Vector3.new(-0.5, legSize.Y / 2, 0),
        clothingColor, Enum.Material.SmoothPlastic, model)
    local rightLeg = makePart("RightLeg", legSize,
        origin + Vector3.new(0.5, legSize.Y / 2, 0),
        clothingColor, Enum.Material.SmoothPlastic, model)

    -- Torso (on top of legs)
    local torsoY = legSize.Y + torsoSize.Y / 2
    local torso = makePart("Torso", torsoSize,
        origin + Vector3.new(0, torsoY, 0),
        clothingColor, Enum.Material.SmoothPlastic, model)

    -- Arms (at torso height)
    local leftArm = makePart("LeftArm", armSize,
        origin + Vector3.new(-torsoSize.X / 2 - armSize.X / 2, torsoY, 0),
        skinColor, Enum.Material.SmoothPlastic, model)
    local rightArm = makePart("RightArm", armSize,
        origin + Vector3.new(torsoSize.X / 2 + armSize.X / 2, torsoY, 0),
        skinColor, Enum.Material.SmoothPlastic, model)

    -- Head (on top of torso)
    local headY = legSize.Y + torsoSize.Y + headSize.Y / 2
    local head = makePart("Head", headSize,
        origin + Vector3.new(0, headY, 0),
        skinColor, Enum.Material.SmoothPlastic, model,
        {Shape = Enum.PartType.Ball})

    -- Weld all parts to torso
    weld(torso, leftLeg)
    weld(torso, rightLeg)
    weld(torso, leftArm)
    weld(torso, rightArm)
    weld(torso, head)

    model.PrimaryPart = torso
    return model, {torso = torso, head = head, leftArm = leftArm,
        rightArm = rightArm, leftLeg = leftLeg, rightLeg = rightLeg}
end

local function weld(part0, part1)
    local w = Instance.new("WeldConstraint")
    w.Part0 = part0
    w.Part1 = part1
    w.Parent = part1
end

local function makePart(name, size, position, color, material, parent, props)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.CanCollide = false
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Parent = parent
    if props then for k, v in pairs(props) do p[k] = v end end
    return p
end
```

## Face Building

```lua
local function buildFace(head, headSize)
    local faceZ = headSize.Z / 2 + 0.01  -- slightly in front

    -- Eyes (white)
    local eyeSize = Vector3.new(0.25, 0.15, 0.05)
    local leftEye = makePart("LeftEye", eyeSize,
        head.Position + Vector3.new(-0.25, 0.15, faceZ),
        Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, head)
    local rightEye = makePart("RightEye", eyeSize,
        head.Position + Vector3.new(0.25, 0.15, faceZ),
        Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, head)
    weld(head, leftEye)
    weld(head, rightEye)

    -- Pupils (black)
    local pupilSize = Vector3.new(0.12, 0.12, 0.05)
    local leftPupil = makePart("LeftPupil", pupilSize,
        leftEye.Position + Vector3.new(0.02, 0, 0.03),
        Color3.new(0, 0, 0), Enum.Material.SmoothPlastic, head)
    local rightPupil = makePart("RightPupil", pupilSize,
        rightEye.Position + Vector3.new(0.02, 0, 0.03),
        Color3.new(0, 0, 0), Enum.Material.SmoothPlastic, head)
    weld(head, leftPupil)
    weld(head, rightPupil)

    -- Mouth
    local mouth = makePart("Mouth", Vector3.new(0.3, 0.06, 0.05),
        head.Position + Vector3.new(0, -0.2, faceZ),
        Color3.fromRGB(180, 60, 60), Enum.Material.SmoothPlastic, head)
    weld(head, mouth)

    -- Eyebrows
    local browSize = Vector3.new(0.3, 0.06, 0.05)
    local leftBrow = makePart("LeftBrow", browSize,
        head.Position + Vector3.new(-0.25, 0.35, faceZ),
        Color3.fromRGB(60, 40, 20), Enum.Material.SmoothPlastic, head)
    local rightBrow = makePart("RightBrow", browSize,
        head.Position + Vector3.new(0.25, 0.35, faceZ),
        Color3.fromRGB(60, 40, 20), Enum.Material.SmoothPlastic, head)
    weld(head, leftBrow)
    weld(head, rightBrow)
end
```

## Accessory Building

```lua
-- Hat example
local function buildWizardHat(parts)
    local head = parts.head
    local hat = makePart("WizardHat", Vector3.new(1.8, 2, 1.8),
        head.Position + Vector3.new(0, 1.2, 0),
        Color3.fromRGB(40, 20, 80), Enum.Material.Fabric, head,
        {Shape = Enum.PartType.Cylinder})
    -- Brim
    local brim = makePart("HatBrim", Vector3.new(2.4, 0.15, 2.4),
        head.Position + Vector3.new(0, 0.5, 0),
        Color3.fromRGB(40, 20, 80), Enum.Material.Fabric, head)
    weld(head, hat)
    weld(head, brim)
end

-- Weapon example
local function buildSword(parts)
    local rightArm = parts.rightArm
    local blade = makePart("Blade", Vector3.new(0.2, 3, 0.1),
        rightArm.Position + Vector3.new(0, -2.5, 0),
        Color3.fromRGB(200, 200, 210), Enum.Material.Metal, rightArm)
    local handle = makePart("Handle", Vector3.new(0.15, 0.8, 0.15),
        rightArm.Position + Vector3.new(0, -0.8, 0),
        Color3.fromRGB(100, 60, 30), Enum.Material.Wood, rightArm)
    weld(rightArm, blade)
    weld(rightArm, handle)
end

-- Cape example
local function buildCape(parts)
    local torso = parts.torso
    local cape = makePart("Cape", Vector3.new(1.8, 3, 0.1),
        torso.Position + Vector3.new(0, -0.5, -0.6),
        Color3.fromRGB(150, 20, 20), Enum.Material.Fabric, torso)
    weld(torso, cape)
end
```

## CRITICAL: NPC_DEFS + accessoryBuilders Mapping

```lua
local NPC_DEFS = {
    {name = "Wizard Alaric", role = "Magic Tutor", position = Vector3.new(20, 0, 15)},
    {name = "Guard Captain", role = "Combat Trainer", position = Vector3.new(-10, 0, 5)},
    {name = "Healer Sera", role = "Healer", position = Vector3.new(0, 0, -20)},
}

-- EVERY entry in NPC_DEFS must have a matching key here!
local accessoryBuilders = {
    ["Wizard Alaric"] = function(parts) buildWizardHat(parts); buildStaff(parts) end,
    ["Guard Captain"] = function(parts) buildSword(parts); buildShield(parts); buildHelmet(parts) end,
    ["Healer Sera"] = function(parts) buildHealerRobes(parts); buildCirclet(parts) end,
}

-- Spawn loop with pcall protection
for _, def in ipairs(NPC_DEFS) do
    local ok, err = pcall(function()
        local model, parts = buildBody(def.position, skinColors[def.name], clothingColors[def.name])
        buildFace(parts.head, Vector3.new(1.6, 1.6, 1.6))

        local builder = accessoryBuilders[def.name]
        if builder then
            builder(parts)
        else
            warn("Missing accessoryBuilder for: " .. def.name)
        end

        addNametag(parts.head, def.name, def.role)
        addClickToAll(model, def.name)
        model.Parent = workspace.NPCs
    end)
    if not ok then
        warn("Failed to spawn NPC " .. def.name .. ": " .. tostring(err))
    end
end
```

## BillboardGui Nametag

```lua
local function addNametag(head, name, role)
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 150, 0, 40)
    bb.StudsOffset = Vector3.new(0, 2, 0)
    bb.Adornee = head
    bb.AlwaysOnTop = true
    bb.Parent = head

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(240, 192, 64)  -- gold
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Text = name
    nameLabel.Parent = bb

    local roleLabel = Instance.new("TextLabel")
    roleLabel.Size = UDim2.new(1, 0, 0.4, 0)
    roleLabel.Position = UDim2.new(0, 0, 0.6, 0)
    roleLabel.BackgroundTransparency = 1
    roleLabel.TextColor3 = Color3.new(1, 1, 1)
    roleLabel.Font = Enum.Font.Gotham
    roleLabel.TextSize = 11
    roleLabel.Text = role
    roleLabel.Parent = bb
end
```

## ClickDetector on ALL Parts (addClickToAll)

```lua
local function addClickToAll(model, npcName)
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local cd = Instance.new("ClickDetector")
            cd.MaxActivationDistance = 14
            cd.Parent = part
            cd.MouseClick:Connect(function(player)
                npcInteractRemote:FireClient(player, npcName)
            end)
        end
    end
end
```

## Dialog System Integration

```lua
-- Client: NPCDialog.client.lua
local dialogData = {
    ["Wizard Alaric"] = {
        {text = "Greetings, adventurer. I sense great potential in you.", choices = {
            {text = "Teach me magic", next = 2},
            {text = "Goodbye", next = nil},
        }},
        {text = "Magic requires patience and wisdom. Are you ready to begin?", choices = {
            {text = "Yes, I'm ready", action = "startMagicTraining"},
            {text = "Not yet", next = nil},
        }},
    },
}

npcInteractRemote.OnClientEvent:Connect(function(npcName)
    local dialog = dialogData[npcName]
    if not dialog then return end
    showDialog(npcName, dialog, 1)
end)

local function showDialog(npcName, dialog, index)
    local entry = dialog[index]
    if not entry then hideDialogUI(); return end

    dialogFrame.Visible = true
    nameLabel.Text = npcName
    typewriterEffect(textLabel, entry.text, 0.03)

    -- Show choices after text finishes
    task.wait(#entry.text * 0.03 + 0.5)
    showChoices(entry.choices, dialog, npcName)
end
```

## Shop NPC Pattern

```lua
-- Server: handle buy/sell
shopRemote.OnServerEvent:Connect(function(player, action, itemName, quantity)
    local data = DataManager.GetData(player)
    if not data then return end
    local item = ItemDatabase.GetItem(itemName)
    if not item then return end

    if action == "buy" then
        local cost = item.value * quantity
        if data.Gold < cost then return end
        if #data.Inventory >= 28 then return end
        data.Gold = data.Gold - cost
        table.insert(data.Inventory, {name = itemName, quantity = quantity})
    elseif action == "sell" then
        local sellPrice = math.floor(item.value * 0.6) * quantity
        if not removeFromInventory(data.Inventory, itemName, quantity) then return end
        data.Gold = data.Gold + sellPrice
    end
end)
```

## Quest Giver Pattern

```lua
local function handleQuestInteraction(player, npcName, questId)
    local data = DataManager.GetData(player)
    if not data then return end
    local quest = QUEST_DEFS[questId]
    if not quest then return end

    -- Check if already completed
    if data.Quests[questId] == "complete" then
        return "Already completed"
    end

    -- Check if in progress — try to turn in
    if data.Quests[questId] == "active" then
        if checkQuestObjectives(data, quest) then
            removeQuestItems(data, quest)
            giveQuestRewards(data, quest)
            data.Quests[questId] = "complete"
            return "Quest complete!"
        else
            return "You haven't finished yet."
        end
    end

    -- Check requirements
    if quest.requiredQuest and data.Quests[quest.requiredQuest] ~= "complete" then
        return "Come back later."
    end
    if quest.requiredLevel then
        local level = Config.GetLevelFromXP(data.Skills.Combat or 0)
        if level < quest.requiredLevel then return "You're not strong enough." end
    end

    -- Accept quest
    data.Quests[questId] = "active"
    return "Quest accepted!"
end
```

## Healer NPC Pattern

```lua
-- Server: Healer restores full HP
healerRemote.OnServerEvent:Connect(function(player)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Health = humanoid.MaxHealth
        healVisualRemote:FireClient(player)  -- green flash effect
    end
end)
```

## NPC Positioning in Buildings

```lua
-- Place NPC inside a building, verify:
-- 1. Position is between the building walls (not clipping through)
-- 2. Y = 0 (ground level)
-- 3. Facing toward the door (rotate torso CFrame)
-- 4. Enough space for player to stand nearby (ClickDetector range = 14)

local shopkeeperPos = Vector3.new(
    buildingOrigin.X,       -- centered X in building
    0,                      -- ALWAYS Y=0
    buildingOrigin.Z - 3    -- slightly back from center, facing door
)
```

## Skin & Clothing Colors

```lua
local SKIN_TONES = {
    light = Color3.fromRGB(255, 220, 185),
    medium = Color3.fromRGB(210, 170, 130),
    dark = Color3.fromRGB(140, 100, 70),
    pale = Color3.fromRGB(255, 235, 215),
}

> See also: **roblox-quest-system** for quest giver dialog, **roblox-map-builder** for NPC positioning in buildings, **roblox-economy-design** for shop pricing

local CLOTHING_COLORS = {
    guard = Color3.fromRGB(120, 120, 130),    -- steel grey
    wizard = Color3.fromRGB(60, 30, 120),     -- purple
    healer = Color3.fromRGB(220, 220, 240),   -- white-blue
    merchant = Color3.fromRGB(140, 100, 50),  -- brown
    priest = Color3.fromRGB(240, 240, 200),   -- cream
}
```
