---
name: roblox-animation-system
description: Create and manage animations for Roblox characters using TweenService and Motor6D manipulation. Covers attack swings, gathering actions, emotes, idle animations, and NPC behaviors.
---

# Roblox Animation System

Reference project: `workspace/projects/roblox-mmo/` (Roscape Runeblocks)
See also: `docs/team-lessons.md`

## CRITICAL: rbxassetid Animations DON'T WORK in Studio Test Mode

**This is the #1 animation gotcha.** Animations uploaded to Roblox (rbxassetid) require the game to be published AND the animation owner to match the game owner. In local Studio test play, they silently fail — no error, no animation.

**Solution**: Use TweenService + Motor6D C0 manipulation for ALL animations. This works everywhere — Studio, local test, published game.

## TweenService Motor6D Animation Pattern

```lua
local TweenService = game:GetService("TweenService")

-- Find Motor6D joints on character
local function getMotor(character, jointName)
    for _, desc in ipairs(character:GetDescendants()) do
        if desc:IsA("Motor6D") and desc.Name == jointName then
            return desc
        end
    end
    return nil
end

-- Animate a joint by tweening C0
local function animateJoint(motor, targetAngle, duration, easingStyle)
    if not motor then return nil end
    local originalC0 = motor.C0
    local targetC0 = originalC0 * targetAngle  -- CFrame rotation

    local tween = TweenService:Create(motor, TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    ), {C0 = targetC0})

    tween:Play()
    return tween, originalC0
end

-- Reset joint to original
local function resetJoint(motor, originalC0, duration)
    if not motor or not originalC0 then return end
    local tween = TweenService:Create(motor, TweenInfo.new(
        duration or 0.2,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    ), {C0 = originalC0})
    tween:Play()
    return tween
end
```

## CFrame.Angles Quick Reference

```lua
-- CFrame.Angles(rx, ry, rz) — radians
-- math.rad(degrees) converts degrees to radians

CFrame.Angles(math.rad(-90), 0, 0)  -- arm swing forward 90°
CFrame.Angles(math.rad(90), 0, 0)   -- arm swing backward 90°
CFrame.Angles(0, 0, math.rad(-45))  -- arm swing outward 45°
CFrame.Angles(0, math.rad(30), 0)   -- rotate around Y axis

-- Combine rotations:
CFrame.Angles(math.rad(-60), 0, math.rad(-20))  -- forward + slight outward
```

## Motor6D Joint Names

```
Right Shoulder → right arm
Left Shoulder  → left arm
Right Hip      → right leg
Left Hip       → left leg
Neck           → head
RootJoint      → torso (body rotation)
```

## Attack Animations

### Sword Slash

```lua
local function playSwordSlash(character)
    local rightShoulder = getMotor(character, "Right Shoulder")
    if not rightShoulder then return end

    local origC0 = rightShoulder.C0

    -- Wind up (arm back)
    local windUp = TweenService:Create(rightShoulder, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        C0 = origC0 * CFrame.Angles(math.rad(30), 0, math.rad(-30))
    })
    windUp:Play()
    windUp.Completed:Wait()

    -- Slash down (arm forward fast)
    local slash = TweenService:Create(rightShoulder, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        C0 = origC0 * CFrame.Angles(math.rad(-120), 0, math.rad(10))
    })
    slash:Play()
    slash.Completed:Wait()

    -- Recovery
    task.wait(0.1)
    resetJoint(rightShoulder, origC0, 0.3)
end
```

### Bow Draw

```lua
local function playBowDraw(character)
    local leftShoulder = getMotor(character, "Left Shoulder")
    local rightShoulder = getMotor(character, "Right Shoulder")
    if not leftShoulder or not rightShoulder then return end

    local origLeft = leftShoulder.C0
    local origRight = rightShoulder.C0

    -- Raise bow arm (left) forward
    local raise = TweenService:Create(leftShoulder, TweenInfo.new(0.3), {
        C0 = origLeft * CFrame.Angles(math.rad(-90), 0, 0)
    })
    -- Pull string (right arm back)
    local pull = TweenService:Create(rightShoulder, TweenInfo.new(0.3), {
        C0 = origRight * CFrame.Angles(math.rad(-70), 0, math.rad(30))
    })
    raise:Play()
    pull:Play()
    pull.Completed:Wait()

    task.wait(0.2)  -- hold

    -- Release
    resetJoint(leftShoulder, origLeft, 0.2)
    resetJoint(rightShoulder, origRight, 0.15)
end
```

### Pickaxe Swing (Mining)

```lua
local function playPickaxeSwing(character)
    local rightShoulder = getMotor(character, "Right Shoulder")
    if not rightShoulder then return end

    local origC0 = rightShoulder.C0

    -- Raise
    local raise = TweenService:Create(rightShoulder, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        C0 = origC0 * CFrame.Angles(math.rad(60), 0, math.rad(-20))
    })
    raise:Play()
    raise.Completed:Wait()

    -- Swing down
    local swing = TweenService:Create(rightShoulder, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
        C0 = origC0 * CFrame.Angles(math.rad(-100), 0, math.rad(10))
    })
    swing:Play()
    swing.Completed:Wait()

    task.wait(0.1)
    resetJoint(rightShoulder, origC0, 0.3)
end
```

## Idle Animations

```lua
-- Subtle breathing: loop torso slight up/down
local function playIdleBreathing(character)
    local rootJoint = getMotor(character, "RootJoint")
    if not rootJoint then return end

    local origC0 = rootJoint.C0
    local breathing = true

    task.spawn(function()
        while breathing and character.Parent do
            local inhale = TweenService:Create(rootJoint, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                C0 = origC0 * CFrame.new(0, 0.05, 0)
            })
            inhale:Play()
            inhale.Completed:Wait()

            local exhale = TweenService:Create(rootJoint, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                C0 = origC0
            })
            exhale:Play()
            exhale.Completed:Wait()
        end
    end)

    return function() breathing = false end  -- stop function
end
```

## NPC Idle Behaviors

```lua
-- Head look around
local function npcHeadLook(character)
    local neck = getMotor(character, "Neck")
    if not neck then return end

    local origC0 = neck.C0
    local active = true

    task.spawn(function()
        while active and character.Parent do
            local yaw = math.rad(math.random(-30, 30))
            local pitch = math.rad(math.random(-10, 10))
            local tween = TweenService:Create(neck, TweenInfo.new(1, Enum.EasingStyle.Sine), {
                C0 = origC0 * CFrame.Angles(pitch, yaw, 0)
            })
            tween:Play()
            tween.Completed:Wait()
            task.wait(math.random(2, 5))
        end
    end)

    return function() active = false end
end
```

## Animation State Machine

```lua
local AnimState = {}
AnimState.__index = AnimState

function AnimState.new()
    local self = setmetatable({}, AnimState)
    self.current = "idle"
    self.locked = false
    return self
end

function AnimState.transition(self, newState, playFunc, duration)
    if self.locked then return false end
    self.current = newState
    self.locked = true

    task.spawn(function()
        playFunc()
        task.wait(duration or 0.5)
        self.locked = false
        self.current = "idle"
    end)
    return true
end

-- Usage:
-- local state = AnimState.new()
-- state:transition("attack", function() playSwordSlash(char) end, 0.6)
```

## Combo System

```lua
local comboWindow = 0.8  -- seconds to chain next attack
local lastAttackTime = 0
local comboCount = 0

local function tryComboAttack(character)
    local now = tick()
    if now - lastAttackTime < comboWindow and comboCount < 3 then
        comboCount = comboCount + 1
    else
        comboCount = 1
    end
    lastAttackTime = now

    if comboCount == 1 then
        playSwordSlash(character)  -- normal slash
    elseif comboCount == 2 then
        -- Wider slash (different angle)
        playWideSlash(character)
    elseif comboCount == 3 then
        -- Heavy overhead (more damage, longer recovery)
        playOverheadSlam(character)
        comboCount = 0
    end
end
```

> See also: **roblox-combat-system** for damage + attack flow, **roblox-particle-effects** for hit VFX, **roblox-sound-design** for combat SFX timing

## Common Pitfalls

1. **Weapon type drives animation** — EquipmentManager sends weapon type to client via `EquipmentInfoRemote`. Animation script must listen and switch between sword slash, bow draw, fist punch:
```lua
EquipmentInfoRemote.OnClientEvent:Connect(function(info)
    currentWeaponType = info.weaponType  -- "sword", "bow", "crossbow", "fist"
end)
```
2. **R15 vs R6 Motor6D names differ** — Always search by class, not by name. Use `getMotor()` pattern with `GetDescendants()`.
3. **Store originalC0 before ANY tween** — If you tween C0 without saving original, you can never reset. Capture `origC0` once on character load.
4. **isAnimating guard** — Always check/set a flag to prevent overlapping animations. The combo system must respect this.
5. **Motor6D can be nil** — Player may have non-standard avatar. Always nil-check motor before tweening.

## Easing Styles Reference

| Style | Best For |
|-------|----------|
| Quad | Most animations (natural acceleration) |
| Back | Wind-up effects (slight overshoot) |
| Sine | Breathing, gentle loops |
| Elastic | Bouncy, cartoon impacts |
| Linear | Constant speed movement |
