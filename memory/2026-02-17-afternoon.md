# 2026-02-17 Afternoon Session

## Fixes Applied
1. **Inventory completely broken** — Root cause: `UIPadding.PaddingAll` (doesn't exist in Roblox) on StatsPanel line 788 crashed the script. Everything after that line (context menu, equip, drop, use, drag-drop handlers) never loaded. Fixed with individual PaddingTop/Bottom/Left/Right.

2. **Monster attack animations not working** — AttackVisualHandler created RemoteEvents at ReplicatedStorage root, but client listened on Remotes folder (project.json). Two separate instances. Fixed to use `Remotes:WaitForChild()`.

3. **Player body exploding** — MonsterMovementAnimations.client.lua animated ALL models with Humanoids, including player character. Fixed with `Players:GetPlayerFromCharacter()` filter.

4. **Tree blocking Haven exit** — Removed tree at (0, 0, -18) directly in front of North Gate.

5. **Wilderness visual overhaul** — Replaced random scatter with 6 themed zones:
   - Skeleton Graveyard (iron fences, gravestones, dead trees)
   - Dark Wizard Ruins (stone walls, pillars, magic circle)
   - Demon Wasteland (scorched ground, lava, obsidian spires)
   - Dark Waters (proper pond, glowing mushrooms)
   - Dragon's Nest (walled crater, lava veins, bone piles)
   - Lich King's Domain (pillar circle, altar)

6. **MonsterManager/NPCManager remote fix** — Switched from getOrCreateRemote to Remotes:WaitForChild()

7. **Added MonsterLoot + XPPopup to project.json**

## Skills Updated
- roblox-game-builder SKILL.md updated with new lessons (via sub-agent)
- MEMORY.md updated with new lessons learned

## Jeremy's Directives
- "take your time use the team dont break anything"
- "update me in an hour" → reminder set for 2:20 PM EST
