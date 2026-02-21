# Roblox Development Issues Research - 2026-02-18

## 1. NPC Underground Issues

### Common Causes:
1. **Spawn Position Calculation Errors**: NPCs spawning at incorrect Y-coordinates relative to terrain
2. **Terrain Loading Delays**: NPCs spawning before terrain is fully loaded
3. **Collision Detection Issues**: NPCs spawning inside terrain due to improper collision handling
4. **Anchor/CanCollide Settings**: Incorrect part properties causing sinking
5. **Network Latency**: Server-client synchronization issues

### Common Fixes from DevForum:

#### Fix 1: Spawn Above Ground with Raycasting
```lua
-- Spawn NPC a few studs above ground, then raycast down
local spawnPosition = Vector3.new(x, y + 10, z) -- Start 10 studs above
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = {npcModel}

local raycastResult = workspace:Raycast(spawnPosition, Vector3.new(0, -20, 0), raycastParams)
if raycastResult then
    npcModel:SetPrimaryPartCFrame(CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0)))
end
```

#### Fix 2: Delay AI Initialization
```lua
-- Wait for physics to settle before enabling NPC AI
local function spawnNPC()
    local npc = npcTemplate:Clone()
    npc.Parent = workspace
    
    -- Wait for physics to stabilize
    task.wait(1.5)
    
    -- Only then enable AI scripts
    local aiScript = npc:FindFirstChild("AIScript")
    if aiScript then
        aiScript.Disabled = false
    end
end
```

#### Fix 3: Use HumanoidRootPart Positioning
```lua
-- Ensure HumanoidRootPart exists and is positioned correctly
local humanoidRootPart = npc:FindFirstChild("HumanoidRootPart")
if humanoidRootPart then
    -- Set position with offset for character height
    humanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 3, 0))
end
```

#### Fix 4: Terrain Loading Check
```lua
-- Wait for terrain to load at spawn location
local function waitForTerrain(position)
    local startTime = tick()
    while tick() - startTime < 5 do -- 5 second timeout
        local region = Region3.new(position - Vector3.new(5, 5, 5), position + Vector3.new(5, 5, 5))
        local parts = workspace:FindPartsInRegion3(region, nil, 100)
        
        if #parts > 0 then
            return true -- Terrain exists
        end
        task.wait(0.1)
    end
    return false
end
```

### Best Practices:
1. **Always spawn NPCs 3-5 studs above intended position**
2. **Use raycasting to find actual ground position**
3. **Delay AI initialization by 1-2 seconds after spawning**
4. **Check terrain existence before spawning**
5. **Use Humanoid:MoveTo() instead of direct CFrame setting for pathfinding NPCs**

## 2. Skilling Station Problems

### Common Issues with Interactive Objects:

#### Mining Nodes/Fishing Spots Not Working:
1. **ClickDetector Coverage**: Parts without full ClickDetector coverage
2. **Network Replication**: Server-client communication failures
3. **Debounce Issues**: No debounce mechanism causing multiple triggers
4. **Proximity Detection**: Distance checks failing
5. **Tool Requirement Checks**: Not verifying player has required tool

### Best Practices for Interactive Objects:

#### Pattern 1: Robust ClickDetector Setup
```lua
-- Ensure ClickDetector covers ALL parts of the model
local function addClickDetectorsToModel(model)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local clickDetector = Instance.new("ClickDetector")
            clickDetector.Parent = part
            clickDetector.MaxActivationDistance = 20
            
            -- Connect to central handler
            clickDetector.MouseClick:Connect(function(player)
                handleInteraction(model, player)
            end)
        end
    end
end
```

#### Pattern 2: Server-Client Validation
```lua
-- Server-side validation
local function handleMiningRequest(player, nodeId)
    -- Verify player is near node
    local node = workspace.Nodes:FindFirstChild(nodeId)
    if not node then return end
    
    local playerCharacter = player.Character
    if not playerCharacter then return end
    
    local playerRoot = playerCharacter:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return end
    
    -- Distance check (server-side)
    if (playerRoot.Position - node.Position).Magnitude > 20 then
        return -- Player too far
    end
    
    -- Verify player has pickaxe
    local backpack = player:FindFirstChild("Backpack")
    local hasPickaxe = false
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool.Name == "Pickaxe" then
                hasPickaxe = true
                break
            end
        end
    end
    
    if not hasPickaxe then
        -- Notify client
        remoteEvents.NoTool:FireClient(player)
        return
    end
    
    -- Process mining
    processMining(player, node)
end
```

#### Pattern 3: State Management
```lua
-- Track node states to prevent conflicts
local nodeStates = {}
local COOLDOWN = 5 -- seconds

local function canMineNode(node)
    local nodeId = node:GetAttribute("NodeId") or node.Name
    
    if nodeStates[nodeId] then
        -- Check cooldown
        if tick() - nodeStates[nodeId].lastMined < COOLDOWN then
            return false
        end
    end
    
    return true
end

local function mineNode(player, node)
    local nodeId = node:GetAttribute("NodeId") or node.Name
    
    if not canMineNode(node) then
        return false
    end
    
    -- Update state
    nodeStates[nodeId] = {
        lastMined = tick(),
        minedBy = player.Name
    }
    
    -- Visual feedback
    node.Transparency = 0.5
    task.wait(1)
    node.Transparency = 0
    
    -- Reward player
    giveReward(player, "ore", 1)
    
    return true
end
```

#### Pattern 4: Progressive Disclosure
```lua
-- Show interaction prompts based on proximity
local PROXIMITY_RANGE = 15

local function setupProximityPrompt(model)
    local proximityPrompt = Instance.new("ProximityPrompt")
    proximityPrompt.Parent = model.PrimaryPart or model
    proximityPrompt.ActionText = "Mine"
    proximityPrompt.ObjectText = "Iron Ore"
    proximityPrompt.MaxActivationDistance = PROXIMITY_RANGE
    proximityPrompt.HoldDuration = 0.5 -- Short hold for mining
    
    proximityPrompt.Triggered:Connect(function(player)
        handleMining(player, model)
    end)
end
```

### Testing Checklist for Skilling Stations:
1. [ ] ClickDetector exists on all parts
2. [ ] Server-side distance validation
3. [ ] Tool requirement checks
4. [ ] Debounce mechanism
5. [ ] State tracking (cooldowns)
6. [ ] Visual feedback (transparency, particles)
7. [ ] Sound effects
8. [ ] Reward distribution
9. [ ] Multi-player conflict prevention
10. [ ] Mobile touch compatibility

## 3. UI Best Practices

### Modern Roblox UI Patterns (2025-2026):

#### Inventory System Best Practices:

**Responsive Grid Layout:**
```lua
-- Use UIGridLayout with AspectRatio constraint
local inventoryGrid = Instance.new("UIGridLayout")
inventoryGrid.Parent = inventoryFrame
inventoryGrid.CellPadding = UDim2.new(0, 5, 0, 5)
inventoryGrid.CellSize = UDim2.new(0, 80, 0, 80) -- Square cells
inventoryGrid.FillDirectionMaxCells = 4 -- 4x4 on desktop

-- Responsive adjustment
local function updateGridForScreen()
    local screenSize = game:GetService("GuiService"):GetScreenResolution()
    
    if screenSize.X < 800 then -- Mobile
        inventoryGrid.FillDirectionMaxCells = 3 -- 3x3 on mobile
        inventoryGrid.CellSize = UDim2.new(0, 70, 0, 70)
    else -- Desktop
        inventoryGrid.FillDirectionMaxCells = 4 -- 4x4 on desktop
        inventoryGrid.CellSize = UDim2.new(0, 80, 0, 80)
    end
end
```

**Item Slot Template:**
```lua
-- Reusable item slot component
local function createItemSlot(itemId, itemData)
    local slot = Instance.new("Frame")
    slot.Name = "ItemSlot_" .. itemId
    slot.Size = UDim2.new(0, 80, 0, 80)
    slot.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    slot.BorderSizePixel = 1
    slot.BorderColor3 = Color3.fromRGB(80, 80, 80)
    
    -- Item icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0.8, 0, 0.8, 0)
    icon.Position = UDim2.new(0.1, 0, 0.1, 0)
    icon.Image = itemData.icon
    icon.BackgroundTransparency = 1
    icon.Parent = slot
    
    -- Item count
    if itemData.count and itemData.count > 1 then
        local count = Instance.new("TextLabel")
        count.Name = "Count"
        count.Size = UDim2.new(0.4, 0, 0.4, 0)
        count.Position = UDim2.new(0.6, 0, 0.6, 0)
        count.Text = tostring(itemData.count)
        count.TextColor3 = Color3.fromRGB(255, 255, 255)
        count.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        count.BackgroundTransparency = 0.5
        count.TextScaled = true
        count.Parent = slot
    end
    
    -- Tooltip on hover
    local tooltip = Instance.new("TextLabel")
    tooltip.Name = "Tooltip"
    tooltip.Text = itemData.name
    tooltip.Visible = false
    -- ... tooltip setup
    
    return slot
end
```

#### Skills Panel Design:

**Modern Skills UI Pattern:**
```lua
-- Skills panel with progress bars
local function createSkillEntry(skillName, level, xp, xpToNext)
    local entry = Instance.new("Frame")
    entry.Name = skillName
    entry.Size = UDim2.new(1, -20, 0, 60)
    entry.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    entry.BorderSizePixel = 0
    
    -- Skill icon and name
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 40, 0, 40)
    icon.Position = UDim2.new(0, 10, 0.5, -20)
    icon.Image = "rbxassetid://" .. skillIcons[skillName]
    icon.Parent = entry
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text = skillName .. " " .. level
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Size = UDim2.new(0.4, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 60, 0, 5)
    nameLabel.Parent = entry
    
    -- Progress bar
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(0.6, -70, 0, 20)
    progressBar.Position = UDim2.new(0, 60, 0, 35)
    progressBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = entry
    
    local progressFill = Instance.new("Frame")
    progressFill.Name = "Fill"
    progressFill.Size = UDim2.new(xp / xpToNext, 0, 1, 0)
    progressFill.BackgroundColor3 = skillColors[skillName]
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBar
    
    -- XP text
    local xpText = Instance.new("TextLabel")
    xpText.Text = xp .. "/" .. xpToNext .. " XP"
    xpText.TextColor3 = Color3.fromRGB(200, 200, 200)
    xpText.Size = UDim2.new(0.3, 0, 0.5, 0)
    xpText.Position = UDim2.new(0.7, 10, 0, 5)
    xpText.TextXAlignment = Enum.TextXAlignment.Right
    xpText.Parent = entry
    
    return entry
end
```

#### UI Scaling Best Practices:

**Scale-Based Sizing (Not Offset):**
```lua
-- Use Scale for proportional sizing, Offset for fixed pixels
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8) -- 8 pixels

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 10) -- 10 pixels
padding.PaddingTop = UDim.new(0.02, 0) -- 2% of parent height

-- Responsive font sizes
local textLabel = Instance.new("TextLabel")
textLabel.TextScaled = true -- Auto-scale text
textLabel.TextSize = 14 -- Base size
textLabel.Size = UDim2.new(0.8, 0, 0.1, 0) -- 80% width, 10% height
```

**Mobile Optimization:**
```lua
-- Larger touch targets for mobile
local TOUCH_TARGET_SIZE = 44 -- pixels (Apple HIG recommendation)

local function optimizeForMobile(button)
    local absSize = button.AbsoluteSize
    if absSize.X < TOUCH_TARGET_SIZE or absSize.Y < TOUCH_TARGET_SIZE then
        button.Size = UDim2.new(
            button.Size.X.Scale,
            math.max(button.Size.X.Offset, TOUCH_TARGET_SIZE),
            button.Size.Y.Scale,
            math.max(button.Size.Y.Offset, TOUCH_TARGET_SIZE)
        )
    end
end
```

#### Performance Optimization:

**UI Recycling for Lists:**
```lua
-- Reuse UI elements instead of creating new ones
local itemPool = {}
local MAX_POOL_SIZE = 20

local function getItemSlot()
    if #itemPool > 0 then
        return table.remove(itemPool)
    else
        return createItemSlotTemplate()
    end
end

local function returnItemSlot(slot)
    if #itemPool < MAX_POOL_SIZE then
        slot.Visible = false
        table.insert(itemPool, slot)
    else
        slot:Destroy()
    end
end
```

### UI Testing Checklist:
1. [ ] Scales correctly on all screen sizes (mobile/desktop/tablet)
2. [ ] Touch targets ≥ 44x44 pixels on mobile
3. [ ] Text is readable without zooming
4. [ ] Color contrast meets accessibility standards
5. [ ] UI doesn't obscure gameplay
6. [ ] Performance: < 5ms per frame for UI updates
7. [ ] Memory: UI elements are pooled/recycled
8. [ ] Input: Works with mouse, touch, and gamepad
9. [ ] Localization: Text containers support translation
10. [ ] State: UI reflects game state accurately

## Recommended Fix Order:

1. **Start with NPC Underground Issues** - Most critical for gameplay
   - Implement raycast spawning
   - Add terrain loading checks
   - Test with multiple NPCs simultaneously

2. **Fix Skilling Stations** - Core gameplay loop
   - Add ClickDetector coverage check
   - Implement server-side validation
   - Add visual/audio feedback

3. **Update UI Systems** - Player experience
   - Implement responsive inventory grid
   - Create modern skills panel
   - Optimize for mobile

## Testing Strategy:
1. Single-player testing for basic functionality
2. Multi-player testing for network issues
3. Mobile device testing for UI/UX
4. Stress testing with 10+ players
5. Long-duration testing for memory leaks

## Resources:
- [Roblox UI Design Tips](https://devforum.roblox.com/t/designing-ui-tips-and-best-practices/3074034)
- [Modern UI Tutorial](https://devforum.roblox.com/t/heres-how-to-create-a-modern-sleek-ui-design-ui-tutorial/2528850)
- [NPC Spawning Fix](https://devforum.roblox.com/t/npc-sometimes-spawns-stuck-in-the-ground-and-walks-incorrectly/3952418)
- [Mining System Help](https://devforum.roblox.com/t/mining-system-not-working/2807947)