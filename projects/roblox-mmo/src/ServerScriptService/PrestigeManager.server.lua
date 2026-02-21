-- PrestigeManager.server.lua
-- Handles prestige resets when all skills reach 99

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules", 5)
local Config = require(Modules:WaitForChild("Config", 5))
local DataManager = require(Modules:WaitForChild("DataManager", 5))
local ItemDatabase = require(Modules:WaitForChild("ItemDatabase", 5))
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)

local PrestigeRemote = Remotes:WaitForChild("Prestige", 5)
local PrestigeInfo = Remotes:WaitForChild("GetPrestigeInfo", 5)

-- All skills that must be 99
local ALL_SKILLS = {"Mining", "Woodcutting", "Fishing", "Smithing", "Cooking", "Strength", "Defense", "Ranged", "Fletching", "Prayer"}

-- Cape names by prestige level
local PRESTIGE_CAPES = {
    "Prestige Cape I", "Prestige Cape II", "Prestige Cape III",
    "Prestige Cape IV", "Prestige Cape V", "Prestige Cape VI",
    "Prestige Cape VII", "Prestige Cape VIII", "Prestige Cape IX",
    "Prestige Cape X",
}

local function canPrestige(data)
    for _, skill in ipairs(ALL_SKILLS) do
        local xp = data.Skills[skill] or 0
        local level = Config.GetLevelFromXP(xp)
        if level < 99 then
            return false
        end
    end
    return true
end

local function doPrestige(player)
    local data = DataManager:GetData(player)
    if not data then return false, "No data" end
    if not canPrestige(data) then return false, "Not all skills are 99" end
    
    local currentPrestige = data.Prestige or 0
    if currentPrestige >= 10 then return false, "Max prestige reached" end
    
    local newPrestige = currentPrestige + 1
    
    -- Reset all skills to 0
    for _, skill in ipairs(ALL_SKILLS) do
        data.Skills[skill] = 0
    end
    
    -- Set new prestige level
    data.Prestige = newPrestige
    
    -- Remove old prestige cape if equipped
    if data.Equipment.Cape and data.Equipment.Cape ~= "" then
        -- Unequip old cape
        data.Equipment.Cape = ""
    end
    
    -- Remove any old prestige capes from inventory
    local newInventory = {}
    for _, item in ipairs(data.Inventory) do
        local isPrestigeCape = false
        for _, capeName in ipairs(PRESTIGE_CAPES) do
            if item.name == capeName then
                isPrestigeCape = true
                break
            end
        end
        if not isPrestigeCape then
            table.insert(newInventory, item)
        end
    end
    data.Inventory = newInventory
    
    -- Grant new prestige cape
    local capeName = PRESTIGE_CAPES[newPrestige]
    if capeName then
        table.insert(data.Inventory, {name = capeName, quantity = 1})
        -- Auto-equip the new cape
        data.Equipment.Cape = capeName
    end
    
    -- Fire updates to client
    Remotes.InventoryUpdate:FireClient(player, data.Inventory)
    Remotes.XPUpdate:FireClient(player, data.Skills)
    
    print("[PrestigeManager] " .. player.Name .. " prestiged to level " .. newPrestige .. "!")
    return true, newPrestige
end

-- Handle prestige request from client
PrestigeRemote.OnServerEvent:Connect(function(player)
    local success, result = doPrestige(player)
    if success then
        -- Announce to all players
        for _, p in ipairs(Players:GetPlayers()) do
            Remotes.LevelUp:FireClient(p, player.Name .. " has reached Prestige " .. tostring(result) .. "!")
        end
    end
end)

-- Handle prestige info request
PrestigeInfo.OnServerInvoke = function(player)
    local data = DataManager:GetData(player)
    if not data then return {prestige = 0, canPrestige = false, skills = {}} end
    
    local skillLevels = {}
    for _, skill in ipairs(ALL_SKILLS) do
        local xp = data.Skills[skill] or 0
        skillLevels[skill] = Config.GetLevelFromXP(xp)
    end
    
    return {
        prestige = data.Prestige or 0,
        canPrestige = canPrestige(data),
        skills = skillLevels,
        maxPrestige = 10,
    }
end

print("[PrestigeManager] Loaded — 10 prestige levels, cape rewards")
