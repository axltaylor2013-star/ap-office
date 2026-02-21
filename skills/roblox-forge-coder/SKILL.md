---
name: roblox-forge-coder
description: Write Luau code for Roblox games using Rojo. Covers server scripts, client scripts, modules, UI, combat, items, NPCs, and all game systems. Includes critical bug-avoidance rules from production experience.
---

# Roblox Forge Coder

You write Luau code for a Roblox MMO game synced via Rojo.

## Project Location
- Game: `C:\Users\alfre\.openclaw\workspace\projects\roblox-mmo\`
- Rojo binary: `C:\Users\alfre\bin\rojo.exe`
- Project file: `default.project.json`

## File Naming
- `*.server.lua` → Script (server-side)
- `*.client.lua` → LocalScript (client-side)
- `*.lua` → ModuleScript (shared, must return a value)

## Project Structure
```
src/
  ServerScriptService/     ← server scripts
  ReplicatedStorage/Modules/ ← shared ModuleScripts
  StarterPlayerScripts/    ← client scripts
```

## CRITICAL RULES (violating these = broken game)

### 1. BOM Kills Everything
Windows writes UTF-8 BOM (bytes EF BB BF) to files. Roblox can't parse it — silent failure.
**ALWAYS strip BOM after writing ANY .lua file:**
```
node -e "const fs=require('fs'); let f='FILEPATH'; let b=fs.readFileSync(f); if(b[0]===0xEF&&b[1]===0xBB&&b[2]===0xBF){fs.writeFileSync(f,b.slice(3));console.log('stripped')}"
```

### 2. Always Rebuild After Edits
```
cd C:\Users\alfre\.openclaw\workspace\projects\roblox-mmo
C:\Users\alfre\bin\rojo.exe build -o build.rbxlx
```

### 3. Variables Before Use
Luau does NOT hoist local variables. If you use `HEAD_RADIUS` at line 100 but declare it at line 300, it's `nil`. Always declare constants at the top of the file or before the function that uses them.

### 4. No Type Annotations
Luau type syntax (`:: Type`, return types) causes parse errors in our setup. Never use them.

### 5. Dot Notation for Modules
Use `Module.Func(arg)` NOT `Module:Func(arg)`. Colon passes `self` as first arg and silently breaks everything.

### 6. Only require() ModuleScripts
You can only `require()` files ending in `.lua` (ModuleScripts). You CANNOT require `.server.lua` or `.client.lua` files.

### 7. $ignoreUnknownInstances
The project.json MUST have `"$ignoreUnknownInstances": true` on Workspace and services with Studio-placed content, or Rojo deletes everything.

### 8. DataStore Needs Published Place
DataStore crashes on unpublished places. ALWAYS wrap in pcall with in-memory fallback:
```lua
local ok, store = pcall(function()
    return DataStoreService:GetDataStore("GameData")
end)
if not ok then
    warn("DataStore unavailable — using in-memory fallback")
end
```

### 9. RemoteEvents
Define in project.json OR create via Instance.new in a server script. Client scripts use `WaitForChild` to get them.

### 10. PaddingAll Doesn't Exist
UIPadding has PaddingLeft, PaddingRight, PaddingTop, PaddingBottom — no PaddingAll shortcut.

### 11. GroupTransparency = CanvasGroup Only
`GroupTransparency` only works on `CanvasGroup`, NOT `Frame`.

### 12. Scripts Can't Return Values
Scripts (`.server.lua`, `.client.lua`) can't `return` anything — only ModuleScripts can export. Use `_G` for global access or RemoteEvents for communication.

### 13. Forward Declare Functions
Declare functions before callbacks that use them:
```lua
local toggleUI  -- Forward declaration
local function onButtonClick()
    toggleUI(true)  -- Won't be nil
end
function toggleUI(visible) -- Actual definition
    -- ...
end
```

### 14. Type Check Before pairs()
Data can be strings, numbers, or nil — not always tables:
```lua
if data and type(data) == "table" then
    for k, v in pairs(data) do
        -- safe
    end
elseif data then
    warn("data: " .. tostring(data))
end
```

### 15. Method vs Function Calls
Use colon (`:`) for methods, dot (`.`) for functions:
```lua
-- WRONG: Passes self twice
ErrorHandler:SafeCall(ErrorHandler, "LoadData", func)

-- RIGHT: Self passed automatically  
ErrorHandler:SafeCall("LoadData", func)
```

### 16. Player Instance Type Checks
Check type before calling IsA():
```lua
if not player or type(player) ~= "userdata" or not player:IsA("Player") then
    return getDefaultData()
end
```

### 17. String Concatenation Safety
Always tostring() variables that might be tables:
```lua
-- WRONG: crashes if killerName is a table
reasonLabel.Text = "Killed by: " .. killerName

-- RIGHT: handles any type safely
reasonLabel.Text = "Killed by: " .. tostring(killerName or "Unknown")
```

### 18. Never Build Everything At Once
**CARDINAL RULE:** Build ONE system at a time. Test it. Fix bugs. THEN build the next system. Building 30+ scripts simultaneously creates cascading failures where every bug breaks every other system.

## Common Patterns

### Creating a RemoteEvent in script
```lua
local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:FindFirstChild("Remotes") or Instance.new("Folder")
Remotes.Name = "Remotes"
Remotes.Parent = RS

local myEvent = Instance.new("RemoteEvent")
myEvent.Name = "MyEvent"
myEvent.Parent = Remotes
```

### Loading a Module
```lua
local RS = game:GetService("ReplicatedStorage")
local Modules = RS:WaitForChild("Modules")
local ItemDatabase = require(Modules:WaitForChild("ItemDatabase"))
local item = ItemDatabase.GetItem("Iron Sword")
```

### NPC/Monster Y Positioning
Baseplate top = Y 0. Body center = bodyHeight/2. Don't place bodies at Y=0 or they'll be half underground.

## After Every Task
1. Strip BOM from ALL files you edited
2. Run Rojo build
3. Report what you changed and any new files created
