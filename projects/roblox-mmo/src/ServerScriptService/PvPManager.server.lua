-- PvPManager.server.lua
-- Handles all PvP-related functionality including wilderness detection, combat, skulling, and death

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Wait for remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local PvPAttackRemote = Remotes:WaitForChild("PvPAttack", 5)
local PvPDeathRemote = Remotes:WaitForChild("PvPDeath", 5)
local SkullUpdateRemote = Remotes:WaitForChild("SkullUpdate", 5)
local WildernessWarningRemote = Remotes:WaitForChild("WildernessWarning", 5)
local ZoneChangedRemote = Remotes:WaitForChild("ZoneChanged", 5)
local DamageDealtRemote = Remotes:WaitForChild("DamageDealt", 5)
local InventoryUpdateRemote = Remotes:WaitForChild("InventoryUpdate", 5)
local EquipmentUpdateRemote = Remotes:WaitForChild("EquipmentUpdate", 5)

-- Get DataManager
local DataManager = require(ReplicatedStorage.Modules:WaitForChild("DataManager", 5))

-- PvP System Variables
local SAFE_ZONE_BOUNDARY = -100  -- z > -100 is safe zone
local SKULL_DURATION = 300  -- 5 minutes in seconds
local HAVEN_RESPAWN_POSITION = Vector3.new(0, 3, 50)

-- Player tracking
local playersInWilderness = {}
local skulledPlayers = {}
local combatTimers = {}
local recentAttackers = {}  -- Track who attacked who recently for self-defense

-- Utility Functions
local function isInWilderness(position)
    return position.Z < SAFE_ZONE_BOUNDARY
end

local function getWildernessLevel(position)
    if not isInWilderness(position) then return 0 end
    return math.floor(math.abs(position.Z + 100) / 20) + 1
end

local function getCombatLevel(playerData)
    if not playerData or not playerData.Skills then
        return 3  -- Default level
    end
    
    local attack = playerData.Skills.Attack or 1
    local strength = playerData.Skills.Strength or 1
    local defence = playerData.Skills.Defence or 1
    local hitpoints = playerData.Skills.Hitpoints or 10
    local ranged = playerData.Skills.Ranged or 1
    local magic = playerData.Skills.Magic or 1
    local prayer = playerData.Skills.Prayer or 1
    
    local combatLevel = (defence + hitpoints + math.floor(prayer / 2)) * 0.25 +
                       math.max(attack + strength, math.max(ranged * 1.5, magic * 1.5)) * 0.325
    
    return math.floor(combatLevel)
end

local function getEquipmentBonus(equipment, bonusType)
    local total = 0
    
    -- Equipment stat bonuses (simplified - you can expand this)
    local equipmentStats = {
        -- Weapons
        ["Bronze Sword"] = {attack = 5, accuracy = 0},
        ["Iron Sword"] = {attack = 10, accuracy = 5},
        ["Steel Sword"] = {attack = 15, accuracy = 10},
        ["Mithril Sword"] = {attack = 20, accuracy = 15},
        ["Adamant Sword"] = {attack = 25, accuracy = 20},
        ["Rune Sword"] = {attack = 35, accuracy = 30},
        
        -- Armor
        ["Bronze Helmet"] = {defence = 2},
        ["Iron Helmet"] = {defence = 5},
        ["Steel Helmet"] = {defence = 8},
        ["Bronze Platebody"] = {defence = 8},
        ["Iron Platebody"] = {defence = 15},
        ["Steel Platebody"] = {defence = 25},
        ["Bronze Platelegs"] = {defence = 6},
        ["Iron Platelegs"] = {defence = 12},
        ["Steel Platelegs"] = {defence = 20},
    }
    
    for slot, item in pairs(equipment) do
        if item and equipmentStats[item] then
            total = total + (equipmentStats[item][bonusType] or 0)
        end
    end
    
    return total
end

local function calculateDamage(attacker, defender, attackerData, defenderData)
    -- Get combat levels
    local attackerCombat = getCombatLevel(attackerData)
    local defenderCombat = getCombatLevel(defenderData)
    
    -- Get equipment bonuses
    local attackBonus = getEquipmentBonus(attackerData.Equipment or {}, "attack")
    local accuracyBonus = getEquipmentBonus(attackerData.Equipment or {}, "accuracy")
    local defenceBonus = getEquipmentBonus(defenderData.Equipment or {}, "defence")
    
    -- Calculate max damage based on weapon and strength
    local strengthLevel = attackerData.Skills.Strength or 1
    local maxDamage = math.floor((strengthLevel + attackBonus) * 0.5) + math.random(1, 5)
    
    -- Accuracy check (simplified)
    local accuracy = (attackerCombat + accuracyBonus) / (defenderCombat + defenceBonus + 1)
    local hitChance = math.min(0.95, math.max(0.05, accuracy * 0.8))
    
    if math.random() > hitChance then
        return 0  -- Miss
    end
    
    -- Apply defense reduction
    local damage = maxDamage - math.floor(defenceBonus * 0.3)
    return math.max(1, damage)  -- Minimum 1 damage on hit
end

local function createSkullIcon(player)
    local character = player.Character
    if not character or not character:FindFirstChild("Head") then return end
    
    local head = character.Head
    
    -- Remove existing skull icon
    local existingSkull = head:FindFirstChild("SkullIcon")
    if existingSkull then
        existingSkull:Destroy()
    end
    
    -- Create new skull icon
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "SkullIcon"
    billboardGui.Size = UDim2.new(0, 50, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.Parent = head
    
    local skullLabel = Instance.new("TextLabel")
    skullLabel.Size = UDim2.new(1, 0, 1, 0)
    skullLabel.BackgroundTransparency = 1
    skullLabel.Text = "☠️"
    skullLabel.TextScaled = true
    skullLabel.Font = Enum.Font.SourceSansBold
    skullLabel.TextColor3 = Color3.new(1, 0, 0)
    skullLabel.Parent = billboardGui
end

local function removeSkullIcon(player)
    local character = player.Character
    if not character or not character:FindFirstChild("Head") then return end
    
    local head = character.Head
    local skullIcon = head:FindFirstChild("SkullIcon")
    if skullIcon then
        skullIcon:Destroy()
    end
end

local function createCombatLevelDisplay(player)
    local character = player.Character
    if not character or not character:FindFirstChild("Head") then return end
    
    local head = character.Head
    
    -- Remove existing display
    local existingDisplay = head:FindFirstChild("CombatLevelDisplay")
    if existingDisplay then
        existingDisplay:Destroy()
    end
    
    local playerData = DataManager:GetData(player)
    local combatLevel = getCombatLevel(playerData)
    local isWilderness = playersInWilderness[player.UserId]
    
    -- Create combat level display
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "CombatLevelDisplay"
    billboardGui.Size = UDim2.new(0, 100, 0, 30)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.Parent = head
    
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Size = UDim2.new(1, 0, 1, 0)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Combat: " .. combatLevel
    levelLabel.TextScaled = true
    levelLabel.Font = Enum.Font.SourceSans
    levelLabel.TextColor3 = isWilderness and Color3.new(1, 0, 0) or Color3.new(1, 1, 1)
    levelLabel.TextStrokeTransparency = 0
    levelLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    levelLabel.Parent = billboardGui
end

local function updateCombatLevelColor(player)
    local character = player.Character
    if not character or not character:FindFirstChild("Head") then return end
    
    local head = character.Head
    local display = head:FindFirstChild("CombatLevelDisplay")
    if not display then return end
    
    local levelLabel = display:FindFirstChild("TextLabel")
    if not levelLabel then return end
    
    local isWilderness = playersInWilderness[player.UserId]
    levelLabel.TextColor3 = isWilderness and Color3.new(1, 0, 0) or Color3.new(1, 1, 1)
end

local function addSkull(player, duration)
    duration = duration or SKULL_DURATION
    
    skulledPlayers[player.UserId] = {
        player = player,
        endTime = tick() + duration,
        wildernessTimeOnly = true
    }
    
    createSkullIcon(player)
    SkullUpdateRemote:FireClient(player, true, duration)
    
    -- Notify all players
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            SkullUpdateRemote:FireClient(otherPlayer, true, duration, player)
        end
    end
end

local function removeSkull(player)
    if skulledPlayers[player.UserId] then
        skulledPlayers[player.UserId] = nil
        removeSkullIcon(player)
        SkullUpdateRemote:FireClient(player, false)
        
        -- Notify all players
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                SkullUpdateRemote:FireClient(otherPlayer, false, 0, player)
            end
        end
    end
end

local function isRecentlyAttacked(attacker, defender)
    local key = defender.UserId .. ":" .. attacker.UserId
    local attackTime = recentAttackers[key]
    return attackTime and (tick() - attackTime) < 60  -- 1 minute window for self-defense
end

local function recordAttack(attacker, defender)
    local key = attacker.UserId .. ":" .. defender.UserId
    recentAttackers[key] = tick()
end

local function getItemValue(itemName, quantity)
    -- Simple item value system - you can expand this
    local itemValues = {
        ["Coins"] = 1,
        ["Rune Sword"] = 5000,
        ["Adamant Sword"] = 2000,
        ["Mithril Sword"] = 1000,
        ["Steel Sword"] = 500,
        ["Iron Sword"] = 200,
        ["Bronze Sword"] = 50,
        ["Steel Platebody"] = 800,
        ["Iron Platebody"] = 300,
        ["Bronze Platebody"] = 100,
        -- Add more items as needed
    }
    
    return (itemValues[itemName] or 10) * (quantity or 1)
end

local function dropLoot(player, position, items, gold)
    -- Create loot bag/drops at position
    local lootFolder = workspace:FindFirstChild("LootDrops")
    if not lootFolder then
        lootFolder = Instance.new("Folder")
        lootFolder.Name = "LootDrops"
        lootFolder.Parent = workspace
    end
    
    -- Create individual item drops
    for _, item in pairs(items) do
        local dropPart = Instance.new("Part")
        dropPart.Name = "ItemDrop_" .. item.name
        dropPart.Size = Vector3.new(2, 0.5, 2)
        dropPart.Position = position + Vector3.new(math.random(-3, 3), 1, math.random(-3, 3))
        dropPart.Anchored = true
        dropPart.CanCollide = false
        dropPart.BrickColor = BrickColor.new("Bright yellow")
        dropPart.Parent = lootFolder
        
        -- Add pickup detector
        local clickDetector = Instance.new("ClickDetector")
        clickDetector.MaxActivationDistance = 10
        clickDetector.Parent = dropPart
        
        -- Store item data
        local stringValue = Instance.new("StringValue")
        stringValue.Name = "ItemData"
        stringValue.Value = item.name .. ":" .. item.quantity
        stringValue.Parent = dropPart
        
        -- Pickup function
        clickDetector.MouseClick:Connect(function(clickingPlayer)
            local playerData = DataManager:GetData(clickingPlayer)
            if playerData then
                DataManager.AddToInventory(playerData, item.name, item.quantity)
                InventoryUpdateRemote:FireClient(clickingPlayer, playerData.Inventory)
                dropPart:Destroy()
            end
        end)
        
        -- Auto-cleanup after 5 minutes
        task.delay(300, function()
            if dropPart and dropPart.Parent then
                dropPart:Destroy()
            end
        end)
    end
    
    -- Drop gold if any
    if gold > 0 then
        local goldDrop = Instance.new("Part")
        goldDrop.Name = "GoldDrop"
        goldDrop.Size = Vector3.new(1.5, 0.5, 1.5)
        goldDrop.Position = position + Vector3.new(0, 1, 0)
        goldDrop.Anchored = true
        goldDrop.CanCollide = false
        goldDrop.BrickColor = BrickColor.new("Bright yellow")
        goldDrop.Parent = lootFolder
        
        local clickDetector = Instance.new("ClickDetector")
        clickDetector.MaxActivationDistance = 10
        clickDetector.Parent = goldDrop
        
        local stringValue = Instance.new("StringValue")
        stringValue.Name = "GoldAmount"
        stringValue.Value = tostring(gold)
        stringValue.Parent = goldDrop
        
        clickDetector.MouseClick:Connect(function(clickingPlayer)
            local playerData = DataManager:GetData(clickingPlayer)
            if playerData then
                DataManager.AddGold(playerData, gold)
                goldDrop:Destroy()
            end
        end)
        
        task.delay(300, function()
            if goldDrop and goldDrop.Parent then
                goldDrop:Destroy()
            end
        end)
    end
end

local function handlePlayerDeath(deadPlayer, killer, position)
    local deadPlayerData = DataManager:GetData(deadPlayer)
    if not deadPlayerData then return end
    
    local isPlayerSkulled = skulledPlayers[deadPlayer.UserId] ~= nil
    local droppedItems = {}
    local keptItems = {}
    local goldDropped = math.floor(deadPlayerData.Gold * 0.5)  -- Drop 50% of gold
    
    if isPlayerSkulled then
        -- Skulled: Drop everything
        for _, item in pairs(deadPlayerData.Inventory) do
            table.insert(droppedItems, {name = item.name, quantity = item.quantity})
        end
        
        for slot, item in pairs(deadPlayerData.Equipment or {}) do
            if item and item ~= "" then
                table.insert(droppedItems, {name = item, quantity = 1})
                deadPlayerData.Equipment[slot] = ""
            end
        end
        
        deadPlayerData.Inventory = {}
    else
        -- Unskulled: Keep 3 most valuable items
        local allItems = {}
        
        -- Add inventory items
        for _, item in pairs(deadPlayerData.Inventory) do
            table.insert(allItems, {
                name = item.name,
                quantity = item.quantity,
                value = getItemValue(item.name, item.quantity),
                isEquipped = false
            })
        end
        
        -- Add equipped items
        for slot, item in pairs(deadPlayerData.Equipment or {}) do
            if item and item ~= "" then
                table.insert(allItems, {
                    name = item,
                    quantity = 1,
                    value = getItemValue(item, 1),
                    isEquipped = true,
                    slot = slot
                })
            end
        end
        
        -- Sort by value (highest first)
        table.sort(allItems, function(a, b) return a.value > b.value end)
        
        -- Keep top 3 most valuable
        for i, item in pairs(allItems) do
            if i <= 3 then
                table.insert(keptItems, item)
            else
                table.insert(droppedItems, {name = item.name, quantity = item.quantity})
                if item.isEquipped then
                    deadPlayerData.Equipment[item.slot] = ""
                end
            end
        end
        
        -- Update inventory with only kept items
        deadPlayerData.Inventory = {}
        for _, item in pairs(keptItems) do
            if not item.isEquipped then
                table.insert(deadPlayerData.Inventory, {name = item.name, quantity = item.quantity})
            end
        end
    end
    
    -- Remove gold
    DataManager.RemoveGold(deadPlayerData, goldDropped)
    
    -- Drop loot at death position
    dropLoot(deadPlayer, position, droppedItems, goldDropped)
    
    -- Remove skull if present
    removeSkull(deadPlayer)
    
    -- Send death notifications
    PvPDeathRemote:FireClient(deadPlayer, false, killer.Name, #droppedItems)
    PvPDeathRemote:FireClient(killer, true, deadPlayer.Name, #droppedItems)
    
    -- Notify nearby players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= deadPlayer and player ~= killer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local distance = (character.HumanoidRootPart.Position - position).Magnitude
                if distance < 100 then  -- Within 100 studs
                    PvPDeathRemote:FireClient(player, nil, killer.Name .. " has defeated " .. deadPlayer.Name)
                end
            end
        end
    end
    
    -- Respawn player in Haven
    task.wait(3)  -- Death screen delay
    if deadPlayer.Character and deadPlayer.Character:FindFirstChild("HumanoidRootPart") then
        deadPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(HAVEN_RESPAWN_POSITION)
    end
    
    -- Update client data
    InventoryUpdateRemote:FireClient(deadPlayer, deadPlayerData.Inventory)
    EquipmentUpdateRemote:FireClient(deadPlayer, deadPlayerData.Equipment)
end

-- Event Handlers
PvPAttackRemote.OnServerEvent:Connect(function(attacker, targetPlayer)
    -- Validate attack
    if not targetPlayer or targetPlayer == attacker then return end
    if not attacker.Character or not targetPlayer.Character then return end
    if not attacker.Character:FindFirstChild("HumanoidRootPart") then return end
    if not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local attackerPos = attacker.Character.HumanoidRootPart.Position
    local targetPos = targetPlayer.Character.HumanoidRootPart.Position
    
    -- Must be in wilderness
    if not isInWilderness(attackerPos) or not isInWilderness(targetPos) then
        return
    end
    
    -- Check distance (within 10 studs)
    if (attackerPos - targetPos).Magnitude > 10 then return end
    
    -- Get player data
    local attackerData = DataManager:GetData(attacker)
    local targetData = DataManager:GetData(targetPlayer)
    if not attackerData or not targetData then return end
    
    -- Check if this is self-defense
    local isSelfDefense = isRecentlyAttacked(attacker, targetPlayer)
    
    -- Apply skull if not self-defense
    if not isSelfDefense and not skulledPlayers[attacker.UserId] then
        addSkull(attacker)
    end
    
    -- Record the attack
    recordAttack(attacker, targetPlayer)
    
    -- Calculate and apply damage
    local damage = calculateDamage(attacker, targetPlayer, attackerData, targetData)
    local targetHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
    
    if targetHumanoid and damage > 0 then
        targetHumanoid.Health = math.max(0, targetHumanoid.Health - damage)
        DamageDealtRemote:FireClient(targetPlayer, damage)
        
        -- Check if target died
        if targetHumanoid.Health <= 0 then
            handlePlayerDeath(targetPlayer, attacker, targetPos)
        end
    end
end)

-- Track players entering/leaving wilderness
local function checkWildernessStatus()
    for _, player in pairs(Players:GetPlayers()) do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local position = character.HumanoidRootPart.Position
            local wasInWilderness = playersInWilderness[player.UserId]
            local nowInWilderness = isInWilderness(position)
            
            if wasInWilderness ~= nowInWilderness then
                playersInWilderness[player.UserId] = nowInWilderness
                
                if nowInWilderness then
                    WildernessWarningRemote:FireClient(player, true, getWildernessLevel(position))
                else
                    WildernessWarningRemote:FireClient(player, false)
                end
                
                ZoneChangedRemote:FireClient(player, nowInWilderness and "Wilderness" or "Safe Zone")
                updateCombatLevelColor(player)
            end
        end
    end
end

-- Update skull timers
local function updateSkullTimers()
    for userId, skullData in pairs(skulledPlayers) do
        local player = skullData.player
        local isInWild = playersInWilderness[userId]
        
        -- Only count down timer when in wilderness
        if isInWild then
            if tick() >= skullData.endTime then
                removeSkull(player)
            end
        end
    end
end

-- Player joined
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(1)  -- Wait for character to load
        createCombatLevelDisplay(player)
    end)
end)

-- Player leaving cleanup
Players.PlayerRemoving:Connect(function(player)
    playersInWilderness[player.UserId] = nil
    skulledPlayers[player.UserId] = nil
    combatTimers[player.UserId] = nil
end)

-- Main update loop
RunService.Heartbeat:Connect(function()
    checkWildernessStatus()
    updateSkullTimers()
end)

print("PvPManager loaded successfully!")
