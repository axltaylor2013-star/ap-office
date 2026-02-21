# Roblox Skill Audit Report

**Date**: 2026-02-16
**Auditor**: Skill Audit Subagent
**Skills Reviewed**: 17/17

## Changes Per Skill

| Skill | Changes |
|-------|---------|
| **roblox-game-builder** | Added cross-reference hub listing all 16 other skills. Added `getOrCreateRemote` pattern to RemoteEvents section. |
| **roblox-combat-system** | Added cross-refs to animation/particles/sound/multiplayer. Added Common Pitfalls: weapon type detection, getOrCreateRemote, BindableEvent pattern, declarative spawn table pattern from MonsterManager. |
| **roblox-ui-builder** | Added cross-refs to quest-system, item-system, particle-effects. |
| **roblox-map-builder** | Added cross-refs to npc-designer and combat-system. |
| **roblox-item-system** | Added cross-refs to economy/combat/data-persistence. Added Common Pitfalls: dual-database requirement, weapon type naming, BindableEvent on equip, stackable flag. |
| **roblox-qa-tester** | No changes needed — already comprehensive with 10 bug patterns and full checklist. |
| **roblox-npc-designer** | Added cross-refs to quest-system, map-builder, economy-design. |
| **roblox-data-persistence** | Added cross-refs to economy/quest/pet. Added Common Pitfalls: UpdateAsync vs SetAsync, BindToClose budget, schema migration, save batching. |
| **roblox-economy-design** | Added cross-refs to item-system, data-persistence, monetization. Added Common Pitfalls: remove-before-add, sell price asymmetry, quantity validation, gold overflow. |
| **roblox-multiplayer-sync** | Added cross-refs to combat/data/economy. Added Common Pitfalls: dual remote locations (waitForRemote pattern from codebase), getOrCreateRemote, RemoteFunction hang, BindableEvent for server↔server. |
| **roblox-particle-effects** | Added cross-refs to combat-system, animation-system, sound-design. |
| **roblox-sound-design** | Added cross-refs to combat/animation/particles. Added Common Pitfalls: Sound leak/destroy, 3D sound parent, crossfade race condition, invalid asset IDs. |
| **roblox-animation-system** | Added cross-refs to combat/particles/sound. Added Common Pitfalls: weapon type drives animation, R15/R6 motor names, originalC0 capture, isAnimating guard, nil motor check. |
| **roblox-quest-system** | Added cross-refs to npc-designer, ui-builder, data-persistence. Added Common Pitfalls: tracking hooks, prerequisite cycles, branching reward replacement, gather quest item drops. |
| **roblox-pet-system** | Added cross-refs to monetization, data-persistence, combat, particles. Added Common Pitfalls: teleport threshold, anchored replication, slot validation, dismiss on death/leave. |
| **roblox-dungeon-generator** | Added cross-refs to combat/map/economy/item. Added Common Pitfalls: TeleportService publish requirement, RNG seeding, room overlap, boss room distance, cleanup. |
| **roblox-monetization** | Added cross-refs to economy/data-persistence/pet. Added Common Pitfalls: ProcessReceipt return, immediate save after purchase, GamePass async check, power selling. |

## Key Patterns Added From Codebase

1. **`getOrCreateRemote(name)`** — Self-healing remote creation pattern from MonsterManager/EquipmentManager. Added to game-builder, combat-system, multiplayer-sync.
2. **`waitForRemote(name)`** — Dual-location remote lookup (Remotes folder + root) from AttackAnimations. Added to multiplayer-sync.
3. **BindableEvent for cross-script comms** — `EquipmentChanged` pattern from EquipmentManager. Added to combat-system, item-system.
4. **Declarative spawn table** — Table-driven monster placement from MonsterManager. Added to combat-system.
5. **Weapon type detection from name** — String matching pattern from EquipmentManager. Added to animation-system, item-system.

## Cross-Reference Map

```
roblox-game-builder (HUB) ──→ all 16 skills

roblox-combat-system ←→ roblox-animation-system
roblox-combat-system ←→ roblox-particle-effects
roblox-combat-system ←→ roblox-sound-design
roblox-combat-system ←→ roblox-multiplayer-sync
roblox-combat-system ←→ roblox-dungeon-generator

roblox-item-system ←→ roblox-economy-design
roblox-item-system ←→ roblox-combat-system
roblox-item-system ←→ roblox-data-persistence

roblox-npc-designer ←→ roblox-quest-system
roblox-npc-designer ←→ roblox-map-builder
roblox-npc-designer ←→ roblox-economy-design

roblox-quest-system ←→ roblox-ui-builder
roblox-quest-system ←→ roblox-data-persistence

roblox-pet-system ←→ roblox-monetization
roblox-pet-system ←→ roblox-data-persistence
roblox-pet-system ←→ roblox-particle-effects

roblox-economy-design ←→ roblox-monetization
roblox-economy-design ←→ roblox-data-persistence

roblox-dungeon-generator ←→ roblox-map-builder
roblox-dungeon-generator ←→ roblox-economy-design

roblox-particle-effects ←→ roblox-sound-design
roblox-animation-system ←→ roblox-sound-design
```

## New Skill Ideas (Not Built)

1. **roblox-anti-exploit** — Dedicated skill for server validation patterns, rate limiting, sanity checks. Currently spread across multiplayer-sync and combat-system.
2. **roblox-world-animation** — Torch flicker, tree sway, water shimmer, NPC idle behaviors. Currently split between animation-system and map-builder.
3. **roblox-crafting-system** — Dedicated crafting skill with recipe chains, skill requirements, station types. Currently a small section in item-system and economy-design.
4. **roblox-boss-design** — Boss mechanics, phases, unique attacks, arena design. Currently brief mentions in combat-system and dungeon-generator.
5. **roblox-player-progression** — XP curves, level-gating, skill unlocks, prestige systems. Currently fragmented across multiple skills.
