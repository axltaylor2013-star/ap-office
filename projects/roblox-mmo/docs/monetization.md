# Roscape Runeblocks — Monetization Plan

## 2x XP Boost (Primary Revenue Stream)
Time-limited 2x XP multiplier. All skills affected (gathering, combat, quest rewards).

### Pricing Tiers
| Duration | Price (USD) | Robux (~) | Notes |
|----------|------------|-----------|-------|
| 10 minutes | $1 | ~80 R$ | Quick test / impulse buy |
| 1 hour | $5 | ~400 R$ | Grinding session |
| 1 day (24h) | $20 | ~1,600 R$ | Dedicated day |
| 1 week (7 days) | $99 | ~7,900 R$ | Hardcore players |

### Implementation
- Developer Products via `MarketplaceService`
- Server tracks boost expiry per player in DataStore
- `Config.XPMultiplier` checks for active boost: returns 6x if boost (3x base * 2x boost) or 3x base
- Visual indicator: golden glow border on screen + countdown timer
- Notification on purchase: "🔥 2x XP Active! Time remaining: X:XX"
- Notification on expiry: "Your 2x XP boost has expired!"
- Stack with base 3x = effectively 6x XP during boost

### Future Monetization Ideas (Phase 2+)
- Cosmetic skins (weapon effects, armor glow colors)
- Pet companions (follow player, purely cosmetic)
- Bank space expansion (default 28 → 56 → 112)
- Custom titles/name colors
- Private server access
- Battle pass (seasonal content + exclusive cosmetics)

### Rules
- NO pay-to-win: no buyable weapons, armor, or stats
- XP boost is acceptable because it's TIME savings, not power
- All content achievable without spending
- Cosmetics are the long-term revenue play
