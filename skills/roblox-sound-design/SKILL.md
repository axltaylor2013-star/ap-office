---
name: roblox-sound-design
description: Implement audio systems for Roblox games. Covers ambient sounds, combat SFX, UI feedback, music zones, and 3D spatial audio.
---

# Roblox Sound Design

Reference project: `workspace/projects/roblox-mmo/` (Roscape Runeblocks)

## Critical Rules

- **3D sounds**: Parent Sound to a Part in Workspace
- **Global sounds**: Parent to SoundService or use SoundGroup
- **Dot notation on modules**, no Luau type annotations, requires at TOP

## Sound Placement

```
Workspace/Part/Sound          → 3D positional audio (heard by nearby players)
SoundService/Sound            → Global, all players hear equally
PlayerGui/Sound               → Only that player hears it (UI sounds)
```

## SoundGroup Categories

```lua
local SoundService = game:GetService("SoundService")

local function createSoundGroups()
    local groups = {"Music", "SFX", "Ambient", "UI"}
    for _, name in ipairs(groups) do
        if not SoundService:FindFirstChild(name) then
            local sg = Instance.new("SoundGroup")
            sg.Name = name
            sg.Volume = 1
            sg.Parent = SoundService
        end
    end
end

-- Assign sounds to groups:
-- sound.SoundGroup = SoundService.SFX
```

## 3D Sound with RollOff

```lua
local function create3DSound(parent, soundId, props)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = props.volume or 0.5
    sound.Looped = props.looped or false
    sound.RollOffMode = Enum.RollOffMode.InverseTapered
    sound.RollOffMinDistance = props.minDist or 10
    sound.RollOffMaxDistance = props.maxDist or 100
    if props.group then
        sound.SoundGroup = game:GetService("SoundService"):FindFirstChild(props.group)
    end
    sound.Parent = parent
    return sound
end
```

## Common Roblox Audio Library IDs

```lua
-- NOTE: These are examples. Verify in Studio's Toolbox → Audio
local SFX = {
    -- Combat
    swordHit = "rbxassetid://12221976",
    swordSwing = "rbxassetid://12222208",
    bowRelease = "rbxassetid://12221831",
    shieldBlock = "rbxassetid://3932505841",
    explosion = "rbxassetid://5765933615",
    death = "rbxassetid://5765933615",

    -- UI
    buttonClick = "rbxassetid://6895079853",
    inventoryOpen = "rbxassetid://6895079853",
    equipItem = "rbxassetid://3932505841",
    errorBuzz = "rbxassetid://2865227271",
    questComplete = "rbxassetid://5765933615",
    levelUp = "rbxassetid://5765933615",

    -- Ambient
    fire = "rbxassetid://31758982",
    waterStream = "rbxassetid://6034115029",
    wind = "rbxassetid://1243635800",
    birds = "rbxassetid://9120600014",
}
```

## Combat Sound Patterns

```lua
local function playCombatSound(character, soundType)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local id = SFX[soundType]
    if not id then return end

    local sound = Instance.new("Sound")
    sound.SoundId = id
    sound.Volume = 0.6
    sound.RollOffMode = Enum.RollOffMode.InverseTapered
    sound.RollOffMinDistance = 10
    sound.RollOffMaxDistance = 60
    sound.SoundGroup = game:GetService("SoundService"):FindFirstChild("SFX")
    sound.Parent = root
    sound:Play()

    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end
```

## Zone-Based Music System

```lua
-- Client: MusicManager.client.lua
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local currentMusic = nil
local currentZone = ""

local ZONE_MUSIC = {
    town = "rbxassetid://1837849285",
    forest = "rbxassetid://1839938093",
    mine = "rbxassetid://1843463175",
    wilderness = "rbxassetid://1845554081",
    boss = "rbxassetid://1847554081",
}

local function crossfade(newZone)
    if newZone == currentZone then return end
    currentZone = newZone

    local newId = ZONE_MUSIC[newZone]
    if not newId then return end

    -- Fade out current
    if currentMusic then
        local fadeOut = TweenService:Create(currentMusic, TweenInfo.new(1.5), {Volume = 0})
        fadeOut:Play()
        local old = currentMusic
        fadeOut.Completed:Connect(function()
            old:Stop()
            old:Destroy()
        end)
    end

    -- Fade in new
    local newSound = Instance.new("Sound")
    newSound.SoundId = newId
    newSound.Volume = 0
    newSound.Looped = true
    newSound.SoundGroup = SoundService:FindFirstChild("Music")
    newSound.Parent = SoundService
    newSound:Play()

    TweenService:Create(newSound, TweenInfo.new(1.5), {Volume = 0.4}):Play()
    currentMusic = newSound
end

-- Detect zone by region or part overlap
-- Call crossfade("town") when player enters town area
```

## UI Feedback Sounds

```lua
-- Client helper: play UI sound (non-positional)
local function playUISound(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 0.3
    sound.SoundGroup = game:GetService("SoundService"):FindFirstChild("UI")
    sound.Parent = game:GetService("Players").LocalPlayer.PlayerGui
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end

-- Usage:
-- playUISound(SFX.buttonClick)
-- playUISound(SFX.errorBuzz)
```

## Ambient Zone Sounds

```lua
local AMBIENT_ZONES = {
    forest = {
        {id = SFX.birds, volume = 0.3, looped = true},
        {id = SFX.wind, volume = 0.15, looped = true},
    },
    mine = {
        {id = SFX.waterStream, volume = 0.2, looped = true},
    },
    town = {
        -- Town chatter via low-volume looped sound
    },
}
```

## Volume Balancing Guidelines

| Category | Default Volume | Notes |
|----------|---------------|-------|
| Music | 0.3-0.4 | Background, never dominant |
| SFX | 0.5-0.7 | Clear but not jarring |
| Ambient | 0.15-0.3 | Subtle atmosphere |
| UI | 0.2-0.4 | Quick feedback clicks |

- Let players adjust category volumes via Settings UI
- Store preferences in player data

> See also: **roblox-combat-system** for attack timing, **roblox-animation-system** for syncing SFX to animation keyframes, **roblox-particle-effects** for coordinating audio+visual

## Common Pitfalls

1. **Sound:Destroy() on Ended** — Always connect `sound.Ended` to destroy one-shot sounds, or use `Debris:AddItem(sound, duration)`. Leaked Sound instances accumulate.
2. **3D sound needs a Part parent** — Parenting a Sound to a Model or nil = no positional audio. Must be on a BasePart.
3. **Music crossfade race condition** — If zone changes rapidly, multiple crossfades can stack. Track `currentZone` and bail early if already transitioning.
4. **rbxassetid audio IDs** — Verify IDs in Studio Toolbox. Invalid IDs silently fail with no error.
