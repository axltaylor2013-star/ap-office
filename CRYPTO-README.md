# Kermicle Crypto Command 🏆

A premium crypto portfolio management system built for Jeremy.

## System Overview

| Component | Location | Purpose |
|-----------|----------|---------|
| `portfolio.json` | workspace root | Holdings, cost basis, alert config |
| `scripts/crypto-check.js` | scripts/ | CLI price checker (Node.js) |
| `dashboard/portfolio.html` | dashboard/ | Live portfolio dashboard |
| `mule-output/price-history.json` | mule-output/ | Historical price snapshots |

## Quick Start

### View the Dashboard
Open `dashboard/portfolio.html` in any browser. It fetches live prices directly from CoinGecko and DexScreener APIs. Auto-refreshes every 60 seconds.

### Run the Price Checker
```bash
node scripts/crypto-check.js
```
Outputs a JSON summary with current prices, P&L, and any triggered alerts. Also appends a snapshot to the price history file.

## Updating Holdings

Edit `portfolio.json` → `holdings` array. For each token:

```json
{
  "symbol": "TOKEN",
  "name": "Token Name",
  "quantity": 1000,
  "costBasis": 0.50,
  "source": "dexscreener",
  "searchQuery": "TOKEN"
}
```

**Also update the dashboard**: Edit the `PORTFOLIO_CONFIG.holdings` array at the top of the `<script>` section in `portfolio.html` to match.

For CoinGecko-listed tokens (major coins), use `"source": "coingecko"` and include `"coingeckoId"`.
For memecoins/small tokens, use `"source": "dexscreener"` and include `"searchQuery"`.

## Alert System

Configured in `portfolio.json` → `alerts`:

| Alert | Threshold | Meaning |
|-------|-----------|---------|
| `priceChange` | ±10% | Token moved 10%+ from cost basis |
| `bigMove` | ±25% | Major price swing — pay attention |
| `rugDetection` | -50% | Token crashed hard — possible rug pull |

Alerts show as:
- 🔴 Red dot on token cards in the dashboard
- Alert items in the "Active Alerts" panel
- JSON output from the CLI script

## Dashboard Features

- **Real-time prices** from CoinGecko + DexScreener
- **Portfolio allocation** pie chart
- **24h change** indicators (green/red)
- **P&L tracker** showing gain/loss since tracking started
- **Market sentiment** gauge based on average 24h movement
- **Alert badges** on tokens exceeding thresholds
- **Mobile responsive** — works great on phones
- **Dark Bloomberg-style theme** with gold accents
- **Auto-refresh** every 60 seconds

## Notes

- DexScreener picks the highest-liquidity pair for each token search
- Cost basis defaults to current price at time of setup (Feb 14, 2026)
- Price history accumulates over time (keeps last 365 snapshots)
- No external dependencies — pure HTML/CSS/JS + native Node.js fetch
