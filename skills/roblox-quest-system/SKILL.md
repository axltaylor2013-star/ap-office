---
name: roblox-quest-system
description: Design and implement quest systems for Roblox games. Covers quest definitions, objective tracking, branching choices, NPC dialog integration, rewards, and quest journals.
---

# Roblox Quest System

Reference project: `workspace/projects/roblox-mmo/` (Roscape Runeblocks)

## Critical Rules

- **Server-authoritative**: Quest progress tracked on server only. Client displays.
- **Dot notation on modules**, no Luau type annotations, requires at TOP
- **Quest state stored in DataManager**: `data.Quests = {[questId] = {state, progress}}`

## Quest Database (ModuleScript)

```lua
-- src/ReplicatedStorage/Modules/QuestDatabase.lua
local QuestDatabase = {}

local quests = {
    ["goblin_slayer"] = {
        id = "goblin_slayer",
        name = "Goblin Menace",
        description = "Kill 5 goblins threatening Lumbridge.",
        giver = "Guard Captain",
        prerequisites = {},  -- quest IDs that must be completed first
        objectives = {
            {type = "kill", target = "Goblin", count = 5, desc = "Kill Goblins (0/5)"},
        },
        rewards = {
            gold = 100,
            xp = {Combat = 50},
            items = {{"Bronze Sword", 1}},
        },
    },
    ["miners_request"] = {
        id = "miners_request",
        name = "Miner's Request",
        description = "Gather 10 copper ore for the mining foreman.",
        giver = "Mining Foreman",
        prerequisites = {},
        objectives = {
            {type = "gather", item = "Copper Ore", count = 10, desc = "Gather Copper Ore (0/10)"},
        },
        rewards = {
            gold = 75,
            xp = {Mining = 80},
            items = {{"Bronze Pickaxe", 1}},
        },
    },
    ["the_lost_ring"] = {
        id = "the_lost_ring",
        name = "The Lost Ring",
        description = "Find the mayor's lost ring in the goblin cave.",
        giver = "Mayor",
        prerequisites = {"goblin_slayer"},  -- must complete goblin quest first
        objectives = {
            {type = "gather", item = "Mayor's Ring", count = 1, desc = "Find the Mayor's Ring"},
            {type = "talk", npc = "Mayor", desc = "Return ring to Mayor"},
        },
        rewards = {
            gold = 500,
            xp = {Combat = 100},
            items = {},
        },
        -- Branching: player can keep the ring or return it
        choices = {
            {text = "Return the ring", rewardMod = {gold = 500}},
            {text = "Keep the ring", rewardMod = {gold = 0, items = {{"Mayor's Ring", 1}}}},
        },
    },
}

function QuestDatabase.GetQuest(questId)
    return quests[questId]
end

function QuestDatabase.GetAllQuests()
    return quests
end

function QuestDatabase.GetQuestsForNPC(npcName)
    local result = {}
    for id, quest in pairs(quests) do
        if quest.giver == npcName then
            table.insert(result, quest)
        end
    end
    return result
end

return QuestDatabase
```

## Quest State in Player Data

```lua
-- In DataManager, player data.Quests structure:
-- data.Quests = {
--     ["goblin_slayer"] = {
--         state = "active",  -- "not_started" | "active" | "completed"
--         progress = {5},    -- matches objectives array indices
--         choice = nil,      -- index of chosen branch (if applicable)
--     },
-- }
```

## QuestManager (Server)

```lua
-- src/ServerScriptService/QuestManager.server.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(ReplicatedStorage.Modules.DataManager)
local QuestDatabase = require(ReplicatedStorage.Modules.QuestDatabase)
local ItemDatabase = require(ReplicatedStorage.Modules.ItemDatabase)

local QuestManager = {}

function QuestManager.CanAccept(player, questId)
    local data = DataManager.GetData(player)
    if not data then return false end
    local quest = QuestDatabase.GetQuest(questId)
    if not quest then return false end

    -- Already active or completed?
    local qState = data.Quests[questId]
    if qState and (qState.state == "active" or qState.state == "completed") then
        return false
    end

    -- Check prerequisites
    for _, prereqId in ipairs(quest.prerequisites) do
        local pState = data.Quests[prereqId]
        if not pState or pState.state ~= "completed" then
            return false
        end
    end
    return true
end

function QuestManager.AcceptQuest(player, questId)
    if not QuestManager.CanAccept(player, questId) then return false end
    local data = DataManager.GetData(player)
    local quest = QuestDatabase.GetQuest(questId)

    local progress = {}
    for i, obj in ipairs(quest.objectives) do
        progress[i] = 0
    end

    data.Quests[questId] = {
        state = "active",
        progress = progress,
        choice = nil,
    }
    return true
end

function QuestManager.ProgressObjective(player, questId, objIndex, amount)
    local data = DataManager.GetData(player)
    if not data then return end
    local qState = data.Quests[questId]
    if not qState or qState.state ~= "active" then return end

    local quest = QuestDatabase.GetQuest(questId)
    local obj = quest.objectives[objIndex]
    if not obj then return end

    qState.progress[objIndex] = math.min(
        (qState.progress[objIndex] or 0) + (amount or 1),
        obj.count or 1
    )

    -- Check if all objectives complete
    local allDone = true
    for i, o in ipairs(quest.objectives) do
        if (qState.progress[i] or 0) < (o.count or 1) then
            allDone = false
            break
        end
    end

    if allDone then
        QuestManager.CompleteQuest(player, questId)
    end
end

function QuestManager.CompleteQuest(player, questId, choiceIndex)
    local data = DataManager.GetData(player)
    local quest = QuestDatabase.GetQuest(questId)
    local qState = data.Quests[questId]
    if not qState then return end

    qState.state = "completed"
    qState.choice = choiceIndex

    -- Give rewards
    local rewards = quest.rewards
    if choiceIndex and quest.choices and quest.choices[choiceIndex] then
        local mod = quest.choices[choiceIndex].rewardMod
        if mod.gold then rewards = {gold = mod.gold, xp = rewards.xp, items = mod.items or rewards.items} end
    end

    if rewards.gold then data.Gold = data.Gold + rewards.gold end
    if rewards.xp then
        for skill, amount in pairs(rewards.xp) do
            data.Skills[skill] = (data.Skills[skill] or 0) + amount
        end
    end
    if rewards.items then
        for _, entry in ipairs(rewards.items) do
            DataManager.AddItem(player, entry[1], entry[2])
        end
    end
end
```

## Kill/Gather Tracking Hooks

```lua
-- In MonsterManager, when monster dies:
local function onMonsterKilled(player, monsterName)
    local data = DataManager.GetData(player)
    if not data then return end

    for questId, qState in pairs(data.Quests) do
        if qState.state == "active" then
            local quest = QuestDatabase.GetQuest(questId)
            for i, obj in ipairs(quest.objectives) do
                if obj.type == "kill" and obj.target == monsterName then
                    QuestManager.ProgressObjective(player, questId, i, 1)
                end
            end
        end
    end
end

-- In inventory/gathering, when item gained:
local function onItemGained(player, itemName, quantity)
    local data = DataManager.GetData(player)
    if not data then return end

    for questId, qState in pairs(data.Quests) do
        if qState.state == "active" then
            local quest = QuestDatabase.GetQuest(questId)
            for i, obj in ipairs(quest.objectives) do
                if obj.type == "gather" and obj.item == itemName then
                    QuestManager.ProgressObjective(player, questId, i, quantity)
                end
            end
        end
    end
end
```

## NPC Dialog Integration

```lua
-- When player talks to NPC quest giver:
local function getQuestDialog(player, npcName)
    local quests = QuestDatabase.GetQuestsForNPC(npcName)
    local data = DataManager.GetData(player)
    if not data then return {text = "..."} end

    for _, quest in ipairs(quests) do
        local qState = data.Quests[quest.id]

        -- Completed quest
        if qState and qState.state == "completed" then
            -- skip, show next quest or default dialog
        -- Active quest — check if ready to turn in
        elseif qState and qState.state == "active" then
            return {
                text = "How's the task going?",
                questId = quest.id,
                canTurnIn = false,  -- set true if all objectives met
            }
        -- Available quest
        elseif QuestManager.CanAccept(player, quest.id) then
            return {
                text = quest.description,
                questId = quest.id,
                canAccept = true,
            }
        end
    end

    return {text = "I have nothing for you right now."}
end
```

> See also: **roblox-npc-designer** for dialog system, **roblox-ui-builder** for quest journal UI, **roblox-data-persistence** for quest save schema

## Common Pitfalls

1. **Quest progress not hooked** — Kill/gather tracking requires hooks in MonsterManager and gathering code. If you add a new objective type, you MUST add the tracking hook.
2. **Prerequisite chains can deadlock** — If quest A requires B and B requires A, neither can start. Validate prerequisite graph has no cycles.
3. **Branching choice rewards** — When player makes a quest choice, the reward modifier REPLACES fields, not merges. Set ALL reward fields in the modifier.
4. **Quest items in inventory** — Gather-type quests check inventory count. If player drops the item, progress should reflect current count, not historical.

## Quest UI (Client)

```lua
-- Quest tracker on HUD: show active quest objectives
-- Journal panel: list all quests (active tab, completed tab)
-- Quest accept dialog: show description + rewards + Accept/Decline buttons
-- Objective format: "Kill Goblins (3/5)" with progress bar
-- Flash notification on quest complete: "Quest Complete: Goblin Menace!"
-- See roblox-ui-builder skill for UI construction patterns
```
