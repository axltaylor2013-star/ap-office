---
name: roblox-qa-tester
description: Testing and quality assurance procedures for Roblox games. Covers TEST_MODE configuration, build verification, common bug patterns, performance checks, and playtesting checklists.
---

# Roblox QA Tester

Reference project: `workspace/projects/roblox-mmo/` (Roscape Runeblocks)
See also: `docs/team-lessons.md`, `docs/CODE-REVIEW-CHECKLIST.md`

## TEST_MODE Pattern

In GameInit.server.lua, configure a test mode for rapid iteration:

```lua
local TEST_MODE = true  -- Set false for production

if TEST_MODE then
    local testConfig = {
        startLevel = 50,
        startGold = 99999,
        startGear = {"Dragon Sword", "Dragon Platebody", "Dragon Platelegs", "Dragon Helm"},
        startTools = {"Dragon Pickaxe", "Dragon Axe", "Dragon Rod"},
        allSkillsXP = 50000,  -- ~level 50 in all skills
        unlockAllQuests = false,
        godMode = false,
    }

    -- Apply on PlayerAdded
    game.Players.PlayerAdded:Connect(function(player)
        task.wait(2)  -- wait for DataManager init
        local data = DataManager.GetData(player)
        if not data then return end
        data.Gold = testConfig.startGold
        for skill, _ in pairs(data.Skills) do
            data.Skills[skill] = testConfig.allSkillsXP
        end
        for _, itemName in ipairs(testConfig.startGear) do
            local item = ItemDatabase.GetItem(itemName)
            if item and item.equipSlot then
                data.Equipment[item.equipSlot] = itemName
            end
        end
        for _, toolName in ipairs(testConfig.startTools) do
            table.insert(data.Inventory, {name = toolName, quantity = 1})
        end
    end)
end
```

## Pre-Build Checklist

Run EVERY time before telling the user to test:

1. **Strip BOM from ALL .lua files**:
```powershell
Get-ChildItem "src" -Recurse -Filter "*.lua" | ForEach-Object {
  $b=[System.IO.File]::ReadAllBytes($_.FullName)
  if($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF){
    [System.IO.File]::WriteAllBytes($_.FullName,$b[3..($b.Length-1)])
  }
}
```

2. **Run Rojo build**:
```powershell
C:\Users\alfre\bin\rojo.exe build -o Game.rbxlx
```

3. **Verify build output** says "Built project to..." with no errors

4. **Remind user**: Close and reopen the .rbxlx file (stale file trap!)

5. **Verify file sizes > 0** (empty writes = broken scripts)

## Post-Build Verification

After user clicks Play in Studio, check:

- [ ] **Output console** (View → Output, Ctrl+Shift+Y): No red errors on startup
- [ ] **NPC spawn count**: Expected number of NPCs visible in town
- [ ] **Monster spawn**: Monsters appear in wilderness after ~4 seconds
- [ ] **UI toggle keys**: B (stats), K (skill tree), P (prayer), M (minimap), J (quests)
- [ ] **Health bar**: Visible above player head
- [ ] **Hotbar**: Visible at bottom of screen, 1-9 keys work
- [ ] **Click interactions**: Can click NPCs, monsters, resource nodes

## Common Bug Patterns & Fixes

### 1. BOM Kills Scripts
**Symptom**: Script silently fails. No output, no errors. Line 1 parse error.
**Cause**: Windows UTF-8 BOM (EF BB BF) at start of .lua file.
**Fix**: Always strip BOM after every file write. No exceptions.

### 2. DataStore Requires Published Place
**Symptom**: Crash with "must publish to access DataStore".
**Cause**: Running in unpublished local place file.
**Fix**: Always wrap DataStore calls in pcall with in-memory fallback:
```lua
local success, store = pcall(function()
    return DataStoreService:GetDataStore("PlayerData")
end)
if not success then
    warn("DataStore unavailable, using in-memory fallback")
    store = nil
end
```

### 3. Module Require Order
**Symptom**: "attempt to index nil" inside functions that use a module.
**Cause**: `require()` placed after function definitions that reference it.
**Fix**: ALL `require()` calls at TOP of file, before any function definitions.

### 4. Dot Notation on Modules
**Symptom**: Silent wrong behavior — function receives module table as first arg.
**Cause**: Using `Module:Func()` instead of `Module.Func()`.
**Fix**: ALWAYS use dot notation for module function calls.

### 5. No Luau Type Annotations
**Symptom**: "Ambiguous syntax" parse error.
**Cause**: `:: Type` or `: ReturnType` annotations.
**Fix**: Strip ALL type annotations from .lua files.

### 6. PaddingAll Doesn't Exist
**Symptom**: Error or property not set.
**Cause**: UIPadding has no PaddingAll property.
**Fix**: Set PaddingTop, PaddingBottom, PaddingLeft, PaddingRight individually.

### 7. GroupTransparency Needs CanvasGroup
**Symptom**: Transparency doesn't work on Frame.
**Cause**: GroupTransparency only works on CanvasGroup instances.
**Fix**: Use CanvasGroup instead of Frame when you need GroupTransparency.

### 8. rbxassetid Animations Don't Work in Studio Test
**Symptom**: Character animations don't play.
**Cause**: Asset-based animations can't load in local test mode.
**Fix**: Use TweenService Motor6D C0 rotation for all animations.

### 9. NPC Missing Accessories
**Symptom**: NPC spawns with plain body, no hat/weapon/cape.
**Cause**: Missing entry in accessoryBuilders table.
**Fix**: Every NPC in NPC_DEFS MUST have matching builder function AND accessoryBuilders entry.

### 10. Stale .rbxlx File
**Symptom**: "Nothing changed" after code updates.
**Cause**: User running old file without rebuilding.
**Fix**: Always rebuild + remind to close and reopen file.

## Performance Checklist

| Metric | Target | How to Check |
|--------|--------|-------------|
| Part count | < 10,000 | `#workspace:GetDescendants()` in command bar |
| Script memory | < 100 MB | View → Stats → Memory |
| Network traffic | < 50 KB/s | View → Stats → Network |
| FPS | > 30 | View → Stats → Summary |
| Remote fire rate | < 10/sec/player | Monitor in Output |

### Optimization Tips
- Anchor ALL static parts (map, buildings, decorations)
- Use Folders to organize, not Models (lighter)
- Batch monster AI updates (don't RunService every monster every frame)
- Limit BillboardGui count (remove when far away)
- Despawn item drops after 60 seconds

## Playtesting Flow

Complete gameplay loop to verify:

1. **Spawn** → Player appears at spawn point with starter gear
2. **Explore** → Walk around, verify map loads, no holes in terrain
3. **Talk to NPCs** → Click NPCs, verify dialog appears
4. **Gather** → Click resource nodes, verify gathering works
5. **Craft** → Use crafting interface, verify items created
6. **Equip** → Open inventory (B), equip weapons/armor
7. **Fight** → Click monsters, verify damage, HP bars, death
8. **Die** → Let monster kill you, verify respawn works
9. **Respawn** → Check inventory/equipment preserved or lost (PvP rules)
10. **Shop** → Buy/sell with NPCs, verify gold transactions
11. **Quest** → Accept quest, complete objectives, turn in
12. **Hotbar** → Assign items, use with number keys

## Bug Report Template

For Jeremy's feedback:

```
### Bug Report
**What happened**: [description]
**Expected**: [what should have happened]
**Steps to reproduce**:
1. [step 1]
2. [step 2]
**Output console errors**: [paste any red text from Output window]
**Screenshot**: [if applicable]
```

## Code Review Checklist (Quick Reference)

Before declaring work complete:

- [ ] No `:: Type` annotations
- [ ] No `PaddingAll`
- [ ] No `GroupTransparency` on Frame
- [ ] All module calls use dot notation
- [ ] All `require()` at TOP of file
- [ ] DataManager fields UPPERCASE
- [ ] Inventory: `{name, quantity}`
- [ ] ClickDetectors on ALL parts
- [ ] Monster/NPC Y positioning correct
- [ ] NPCs have accessoryBuilders entries
- [ ] Map scripts have correct task.wait() timing
- [ ] New items in BOTH ItemDatabase AND ItemVisuals
- [ ] BOM stripped
- [ ] Rojo build succeeds
- [ ] Reminded user to reload .rbxlx
