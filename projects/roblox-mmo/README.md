# Wilderness — Roblox MMO Project

**Genre:** RuneScape-inspired MMO with full-loot PvP wilderness
**Engine:** Roblox Studio (Luau)
**Started:** 2026-02-16

## Core Concept
- Skill grinding in safe zones (mining, smithing, combat, woodcutting, cooking)
- Bank your valuables in town
- Enter the Wilderness for rare resources — but PvP is enabled
- Die = lose everything you're carrying
- Clan wars for territory control

## MVP Features (Phase 1)
1. Safe town hub with bank NPC
2. 3 gathering skills (mining, woodcutting, fishing)
3. 2 crafting skills (smithing, cooking)
4. Combat system (melee + ranged)
5. Inventory system with bank storage
6. Wilderness zone — PvP enabled, rare resources
7. Full-loot death mechanic
8. DataStore for saving progress
9. Basic UI (inventory, skills panel, minimap)

## Architecture
```
ServerScriptService/
  GameManager.lua          -- Core game state
  DataManager.lua          -- Player data (ProfileService)
  CombatManager.lua        -- Server-authoritative combat
  SkillManager.lua         -- Skill XP and leveling
  LootManager.lua          -- Death/loot mechanics
  WildernessManager.lua    -- PvP zone detection

ReplicatedStorage/
  Modules/
    ItemDatabase.lua        -- All item definitions
    SkillDatabase.lua       -- Skill configs and XP tables
    Config.lua              -- Game constants
  Remotes/                  -- RemoteEvents/Functions

StarterGui/
  InventoryUI
  SkillsUI
  MinimapUI
  BankUI

StarterPlayerScripts/
  UIController.lua
  InputHandler.lua
  CameraController.lua

Workspace/
  SafeZone/               -- Town, bank, shops
  Wilderness/             -- PvP zone with resources
  ResourceNodes/          -- Mining rocks, trees, fishing spots
```

## Phase 2 (Post-MVP)
- Clan system + clan wars
- More skills (fletching, herblore, magic)
- Wilderness bosses
- Trading system
- Game passes (cosmetics, 2x XP, bank space)
- Quests
