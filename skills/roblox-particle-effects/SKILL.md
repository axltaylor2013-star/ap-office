---
name: roblox-particle-effects
description: Create visual effects using ParticleEmitters, Beams, Trails, and lighting in Roblox. Covers combat effects, environmental ambiance, skill-up celebrations, loot glows, and weather.
---

# Roblox Particle Effects

Reference project: `workspace/projects/roblox-mmo/` (Roscape Runeblocks)

## Critical Rules

- **Performance**: Keep total active particles under ~500 per client
- **Disable when offscreen**: Use `.Enabled = false` for distant effects
- **Dot notation on modules**, no Luau type annotations, requires at TOP

## ParticleEmitter Basics

```lua
local function createParticle(parent, props)
    local pe = Instance.new("ParticleEmitter")
    pe.Rate = props.rate or 10
    pe.Speed = NumberRange.new(props.speedMin or 1, props.speedMax or 3)
    pe.Lifetime = NumberRange.new(props.lifeMin or 0.5, props.lifeMax or 1.5)
    pe.SpreadAngle = Vector2.new(props.spread or 15, props.spread or 15)
    pe.RotSpeed = NumberRange.new(-45, 45)

    -- Size over lifetime (start big, shrink)
    pe.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, props.startSize or 0.5),
        NumberSequenceKeypoint.new(1, props.endSize or 0),
    })

    -- Transparency over lifetime (fade out)
    pe.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, props.startAlpha or 0),
        NumberSequenceKeypoint.new(0.8, 0.3),
        NumberSequenceKeypoint.new(1, 1),
    })

    -- Color
    if props.color then
        pe.Color = ColorSequence.new(props.color)
    elseif props.colorStart and props.colorEnd then
        pe.Color = ColorSequence.new(props.colorStart, props.colorEnd)
    end

    pe.Parent = parent
    return pe
end
```

## NumberSequence & ColorSequence

```lua
-- Grow then shrink
local sizeSeq = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0),     -- start invisible
    NumberSequenceKeypoint.new(0.3, 1.5), -- grow to peak
    NumberSequenceKeypoint.new(1, 0),     -- shrink to nothing
})

-- Color shift: yellow → orange → red
local colorSeq = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 128, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
})
```

## Combat Hit Effect

```lua
local function playHitEffect(position, color)
    local part = Instance.new("Part")
    part.Size = Vector3.new(0.1, 0.1, 0.1)
    part.Position = position
    part.Anchored = true
    part.Transparency = 1
    part.CanCollide = false
    part.Parent = workspace

    local pe = Instance.new("ParticleEmitter")
    pe.Color = ColorSequence.new(color or Color3.fromRGB(255, 50, 50))
    pe.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(1, 0),
    })
    pe.Speed = NumberRange.new(5, 15)
    pe.SpreadAngle = Vector2.new(180, 180)
    pe.Lifetime = NumberRange.new(0.2, 0.5)
    pe.Rate = 0
    pe.Parent = part

    pe:Emit(20)  -- burst 20 particles

    task.delay(1, function()
        part:Destroy()
    end)
end
```

## Beam (Lightning/Laser)

```lua
local function createBeam(startPart, endPart, color)
    local a0 = Instance.new("Attachment")
    a0.Parent = startPart
    local a1 = Instance.new("Attachment")
    a1.Parent = endPart

    local beam = Instance.new("Beam")
    beam.Attachment0 = a0
    beam.Attachment1 = a1
    beam.Color = ColorSequence.new(color or Color3.fromRGB(100, 150, 255))
    beam.Width0 = 0.5
    beam.Width1 = 0.2
    beam.FaceCamera = true
    beam.Segments = 10
    beam.CurveSize0 = math.random(-2, 2)  -- jagged for lightning
    beam.CurveSize1 = math.random(-2, 2)
    beam.Parent = startPart
    return beam
end
```

## Trail (Sword Swipe)

```lua
local function addTrail(part, color)
    local a0 = Instance.new("Attachment")
    a0.Position = Vector3.new(0, 1, 0)
    a0.Parent = part
    local a1 = Instance.new("Attachment")
    a1.Position = Vector3.new(0, -1, 0)
    a1.Parent = part

    local trail = Instance.new("Trail")
    trail.Attachment0 = a0
    trail.Attachment1 = a1
    trail.Color = ColorSequence.new(color or Color3.fromRGB(255, 255, 255))
    trail.Lifetime = 0.3
    trail.MinLength = 0.1
    trail.FaceCamera = true
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 1),
    })
    trail.Parent = part
    return trail
end
```

## Loot Glow by Rarity

```lua
local RARITY_GLOW = {
    common = {color = Color3.fromRGB(200, 200, 200), brightness = 1, range = 6},
    uncommon = {color = Color3.fromRGB(30, 255, 30), brightness = 1.5, range = 8},
    rare = {color = Color3.fromRGB(30, 100, 255), brightness = 2, range = 10},
    epic = {color = Color3.fromRGB(180, 30, 255), brightness = 2.5, range = 12},
    legendary = {color = Color3.fromRGB(255, 200, 30), brightness = 3, range = 16},
}

local function addLootGlow(part, rarity)
    local glow = RARITY_GLOW[rarity] or RARITY_GLOW.common
    local light = Instance.new("PointLight")
    light.Color = glow.color
    light.Brightness = glow.brightness
    light.Range = glow.range
    light.Parent = part

    -- Add sparkle particles for rare+
    if rarity == "rare" or rarity == "epic" or rarity == "legendary" then
        local pe = Instance.new("ParticleEmitter")
        pe.Color = ColorSequence.new(glow.color)
        pe.Size = NumberSequence.new(0.2, 0)
        pe.Rate = 5
        pe.Speed = NumberRange.new(0.5, 1.5)
        pe.Lifetime = NumberRange.new(0.5, 1)
        pe.SpreadAngle = Vector2.new(180, 180)
        pe.Parent = part
    end
end
```

## Level-Up Celebration

```lua
local function playLevelUpEffect(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local pe = Instance.new("ParticleEmitter")
    pe.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0), Color3.fromRGB(255, 255, 100))
    pe.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.2, 1),
        NumberSequenceKeypoint.new(1, 0),
    })
    pe.Speed = NumberRange.new(8, 15)
    pe.SpreadAngle = Vector2.new(180, 180)
    pe.Lifetime = NumberRange.new(0.8, 1.5)
    pe.Rate = 0
    pe.Parent = root
    pe:Emit(50)

    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 215, 0)
    light.Brightness = 5
    light.Range = 20
    light.Parent = root

    task.delay(2, function()
        pe:Destroy()
        light:Destroy()
    end)
end
```

## Weather Effects

```lua
-- Rain: attach to camera or large part above player
local function createRain(parent)
    local pe = Instance.new("ParticleEmitter")
    pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    pe.Color = ColorSequence.new(Color3.fromRGB(150, 180, 255))
    pe.Size = NumberSequence.new(0.05, 0.02)
    pe.Speed = NumberRange.new(30, 50)
    pe.Lifetime = NumberRange.new(0.5, 1)
    pe.Rate = 200
    pe.SpreadAngle = Vector2.new(5, 5)
    pe.EmissionDirection = Enum.NormalId.Bottom
    pe.Parent = parent
    return pe
end
```

## Performance Guidelines

- Max ~500 active particles per client
- Use `Emit(n)` for bursts instead of high `Rate`
- Set `Enabled = false` when not visible
- Destroy temporary effect parts after delay
- Reduce Rate for mobile clients
- Avoid ParticleEmitters on every item in inventory — only on dropped/equipped

> See also: **roblox-combat-system** for when to trigger hit effects, **roblox-animation-system** for timing effects to animations, **roblox-sound-design** for syncing audio with VFX
