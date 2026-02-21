---
name: roblox-ui-builder
description: Build game UI for Roblox using ScreenGui, Frames, and scripted interfaces. Covers inventory panels, skill trees, hotbars, health bars, minimaps, dialog systems, and HUD elements with dark theme styling.
---

# Roblox UI Builder

Reference project: `workspace/projects/roblox-mmo/` (Roscape Runeblocks)
See also: `docs/team-lessons.md`, `docs/CODE-REVIEW-CHECKLIST.md`

## Critical Rules

- **GroupTransparency only works on CanvasGroup**, NOT Frame — silent fail on Frame
- **PaddingAll doesn't exist** on UIPadding — set PaddingTop/Bottom/Left/Right individually
- **TAB key is captured by Roblox** — never bind to TAB, use other keys
- **Dot notation on modules**: `Module.Func()` not `Module:Func()`
- **No Luau type annotations**
- **All requires at TOP of file**

## Theme: Dark Medieval

```lua
local THEME = {
    bg = Color3.fromRGB(26, 26, 46),          -- #1a1a2e
    bgLight = Color3.fromRGB(40, 40, 70),
    gold = Color3.fromRGB(240, 192, 64),       -- #f0c040
    text = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(180, 180, 180),
    headerFont = Enum.Font.GothamBold,
    bodyFont = Enum.Font.Gotham,
}

local RARITY_COLORS = {
    common = Color3.fromRGB(157, 157, 157),    -- #9d9d9d
    uncommon = Color3.fromRGB(30, 255, 0),     -- #1eff00
    rare = Color3.fromRGB(0, 112, 221),        -- #0070dd
    epic = Color3.fromRGB(163, 53, 238),       -- #a335ee
    legendary = Color3.fromRGB(255, 128, 0),   -- #ff8000
}
```

## ScreenGui → Frame Hierarchy Pattern

```lua
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameUI"
screenGui.ResetOnSpawn = false  -- persist through death
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local function makePanel(name, size, position, parent)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = THEME.bg
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = parent or screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = THEME.gold
    stroke.Thickness = 2
    stroke.Parent = frame

    return frame
end
```

## Key Bindings

```lua
local UIS = game:GetService("UserInputService")

local KEY_BINDS = {
    [Enum.KeyCode.B] = "StatsPanel",      -- Skills/Inventory/Loadout
    [Enum.KeyCode.K] = "SkillTree",
    [Enum.KeyCode.P] = "PrayerBook",
    [Enum.KeyCode.M] = "MiniMap",
    [Enum.KeyCode.J] = "QuestJournal",
}

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end  -- don't capture when typing in chat
    local panelName = KEY_BINDS[input.KeyCode]
    if panelName then
        local panel = screenGui:FindFirstChild(panelName)
        if panel then panel.Visible = not panel.Visible end
    end
end)
```

## Tab-Based Panel (StatsPanel)

```lua
local function createTabPanel(parent, tabs)
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, 0, 0, 36)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 4)
    layout.Parent = tabBar

    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 1, -40)
    contentFrame.Position = UDim2.new(0, 0, 0, 40)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = parent

    local pages = {}
    for i, tabName in ipairs(tabs) do
        -- Tab button
        local btn = Instance.new("TextButton")
        btn.Name = tabName
        btn.Size = UDim2.new(0, 90, 1, 0)
        btn.BackgroundColor3 = THEME.bgLight
        btn.TextColor3 = THEME.gold
        btn.Font = THEME.headerFont
        btn.TextSize = 14
        btn.Text = tabName
        btn.Parent = tabBar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        -- Page frame
        local page = Instance.new("Frame")
        page.Name = tabName .. "Page"
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = (i == 1)
        page.Parent = contentFrame
        pages[tabName] = page

        btn.MouseButton1Click:Connect(function()
            for _, p in pairs(pages) do p.Visible = false end
            page.Visible = true
        end)
    end
    return pages
end

-- Usage:
-- local pages = createTabPanel(statsPanel, {"Skills", "Inventory", "Loadout"})
```

## Hotbar System (1-9 Keys)

```lua
local HOTBAR_SLOTS = 9

local function createHotbar(parent)
    local bar = Instance.new("Frame")
    bar.Name = "Hotbar"
    bar.Size = UDim2.new(0, HOTBAR_SLOTS * 52, 0, 52)
    bar.Position = UDim2.new(0.5, -(HOTBAR_SLOTS * 52) / 2, 1, -60)
    bar.BackgroundTransparency = 1
    bar.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 4)
    layout.Parent = bar

    local slots = {}
    for i = 1, HOTBAR_SLOTS do
        local slot = Instance.new("TextButton")
        slot.Name = "Slot" .. i
        slot.Size = UDim2.new(0, 48, 0, 48)
        slot.BackgroundColor3 = THEME.bg
        slot.Text = ""
        slot.Parent = bar
        Instance.new("UICorner", slot).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", slot).Color = THEME.gold

        -- Key number label
        local keyLabel = Instance.new("TextLabel")
        keyLabel.Size = UDim2.new(0, 16, 0, 16)
        keyLabel.Position = UDim2.new(0, 2, 0, 2)
        keyLabel.BackgroundTransparency = 1
        keyLabel.Text = tostring(i)
        keyLabel.TextColor3 = THEME.textDim
        keyLabel.TextSize = 10
        keyLabel.Font = THEME.bodyFont
        keyLabel.Parent = slot

        -- Cooldown overlay
        local cooldown = Instance.new("Frame")
        cooldown.Name = "Cooldown"
        cooldown.Size = UDim2.new(1, 0, 0, 0)
        cooldown.Position = UDim2.new(0, 0, 1, 0)
        cooldown.AnchorPoint = Vector2.new(0, 1)
        cooldown.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        cooldown.BackgroundTransparency = 0.5
        cooldown.BorderSizePixel = 0
        cooldown.Parent = slot

        slots[i] = slot
    end

    -- Key binds (1-9)
    UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
        local num = input.KeyCode.Value - Enum.KeyCode.One.Value + 1
        if num >= 1 and num <= HOTBAR_SLOTS then
            activateHotbarSlot(num)
        end
    end)

    return slots
end
```

## Minimap (Circular Viewport)

```lua
local function createMinimap(parent)
    local container = Instance.new("Frame")
    container.Name = "MiniMap"
    container.Size = UDim2.new(0, 200, 0, 200)
    container.Position = UDim2.new(1, -210, 0, 10)
    container.BackgroundColor3 = THEME.bg
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(1, 0) -- circular
    local stroke = Instance.new("UIStroke", container)
    stroke.Color = THEME.gold
    stroke.Thickness = 3

    -- Clip contents
    container.ClipsDescendants = true

    -- Map canvas (rotates with player heading)
    local canvas = Instance.new("Frame")
    canvas.Name = "Canvas"
    canvas.Size = UDim2.new(2, 0, 2, 0)
    canvas.Position = UDim2.new(0.5, 0, 0.5, 0)
    canvas.AnchorPoint = Vector2.new(0.5, 0.5)
    canvas.BackgroundTransparency = 1
    canvas.Parent = container

    -- Player dot (always center)
    local playerDot = Instance.new("Frame")
    playerDot.Size = UDim2.new(0, 8, 0, 8)
    playerDot.Position = UDim2.new(0.5, -4, 0.5, -4)
    playerDot.BackgroundColor3 = Color3.fromRGB(0, 255, 255) -- cyan
    playerDot.Parent = container -- on top of canvas
    Instance.new("UICorner", playerDot).CornerRadius = UDim.new(1, 0)

    -- Zone indicator
    local zoneLabel = Instance.new("TextLabel")
    zoneLabel.Size = UDim2.new(1, 0, 0, 20)
    zoneLabel.Position = UDim2.new(0, 0, 1, 4)
    zoneLabel.BackgroundTransparency = 1
    zoneLabel.TextColor3 = THEME.gold
    zoneLabel.Font = THEME.headerFont
    zoneLabel.TextSize = 12
    zoneLabel.Text = "🏰 SAFE ZONE"
    zoneLabel.Parent = container

    return container, canvas, zoneLabel
end

-- Dot colors: cyan=players, green=NPCs, red=enemies, brown=rocks, green=trees, blue=fish, yellow=loot
```

## Skill Tree Layout

```lua
local function createSkillNode(parent, skillData, position)
    local node = Instance.new("TextButton")
    node.Size = UDim2.new(0, 48, 0, 48)
    node.Position = position
    node.BackgroundColor3 = skillData.unlocked and THEME.gold or THEME.bgLight
    node.Text = skillData.icon or "?"
    node.TextSize = 20
    node.Parent = parent
    Instance.new("UICorner", node).CornerRadius = UDim.new(1, 0) -- circular
    Instance.new("UIStroke", node).Color = skillData.unlocked and THEME.gold or THEME.textDim

    -- Draw lines to prerequisites
    for _, prereqPos in ipairs(skillData.prereqPositions or {}) do
        local line = Instance.new("Frame")
        -- Calculate line between two points (simplified)
        line.BackgroundColor3 = THEME.textDim
        line.Parent = parent
    end

    return node
end
```

## Dialog UI (Typewriter Effect)

```lua
local function createDialogUI(parent)
    local dialog = Instance.new("Frame")
    dialog.Name = "DialogFrame"
    dialog.Size = UDim2.new(0.6, 0, 0, 120)
    dialog.Position = UDim2.new(0.2, 0, 1, -130)
    dialog.BackgroundColor3 = THEME.bg
    dialog.Visible = false
    dialog.Parent = parent
    Instance.new("UICorner", dialog).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", dialog).Color = THEME.gold

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -20, 0, 24)
    nameLabel.Position = UDim2.new(0, 10, 0, 6)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = THEME.gold
    nameLabel.Font = THEME.headerFont
    nameLabel.TextSize = 16
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = dialog

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "DialogText"
    textLabel.Size = UDim2.new(1, -20, 0, 60)
    textLabel.Position = UDim2.new(0, 10, 0, 32)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = THEME.text
    textLabel.Font = THEME.bodyFont
    textLabel.TextSize = 14
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.Parent = dialog

    return dialog, nameLabel, textLabel
end

local function typewriterEffect(label, fullText, speed)
    speed = speed or 0.03
    label.Text = ""
    for i = 1, #fullText do
        label.Text = string.sub(fullText, 1, i)
        task.wait(speed)
    end
end
```

## BillboardGui for World-Space Labels

```lua
local function createWorldLabel(adornee, text, color)
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 120, 0, 30)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.Adornee = adornee
    bb.AlwaysOnTop = false
    bb.Parent = adornee

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color or THEME.gold
    label.Font = THEME.headerFont
    label.TextSize = 14
    label.TextScaled = false
    label.Text = text
    label.Parent = bb

    return bb
end
```

## UIPadding (Correct Way)

```lua
-- WRONG: padding.PaddingAll = UDim.new(0, 10)  -- DOESN'T EXIST
-- RIGHT:
local function addPadding(parent, top, right, bottom, left)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, top)
    p.PaddingRight = UDim.new(0, right or top)
    p.PaddingBottom = UDim.new(0, bottom or top)
    p.PaddingLeft = UDim.new(0, left or right or top)
    p.Parent = parent
    return p
end
```

> See also: **roblox-quest-system** for quest journal UI, **roblox-item-system** for inventory slot patterns, **roblox-particle-effects** for UI effect integration

## Mobile-Friendly Touch Targets

- Minimum button size: 44x44 pixels
- Spacing between buttons: at least 8px
- Use `UIS.TouchEnabled` to detect mobile and show touch buttons
- Add on-screen attack button for mobile (bottom-right)
- Inventory slots: at least 48x48 for finger tapping

## Inventory Panel (28 Slots)

Panel height: 440px for 7 rows × 4 columns at 48px slots with padding.

```lua
local function createInventoryGrid(parent, columns, rows)
    columns = columns or 4
    rows = rows or 7
    local grid = Instance.new("Frame")
    grid.Size = UDim2.new(1, -16, 1, -40)
    grid.Position = UDim2.new(0, 8, 0, 36)
    grid.BackgroundTransparency = 1
    grid.Parent = parent

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 48, 0, 48)
    gridLayout.CellPadding = UDim2.new(0, 4, 0, 4)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = grid

    for i = 1, columns * rows do
        local slot = Instance.new("TextButton")
        slot.Name = "Slot" .. i
        slot.BackgroundColor3 = THEME.bgLight
        slot.Text = ""
        slot.LayoutOrder = i
        slot.Parent = grid
        Instance.new("UICorner", slot).CornerRadius = UDim.new(0, 4)
    end
    return grid
end
```
