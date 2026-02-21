#!/usr/bin/env node
/**
 * Kermicle Crypto Command — Price Checker
 * Fetches live prices from DexScreener + CoinGecko, compares to portfolio,
 * outputs alerts, and appends to price history.
 */

import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const WORKSPACE = join(__dirname, '..');
const PORTFOLIO_PATH = join(WORKSPACE, 'portfolio.json');
const HISTORY_PATH = join(WORKSPACE, 'mule-output', 'price-history.json');

const COINGECKO_URL = 'https://api.coingecko.com/api/v3/simple/price?ids=ethereum,ripple,usd-coin&vs_currencies=usd&include_24hr_change=true';

async function loadJSON(path) {
  try {
    return JSON.parse(await readFile(path, 'utf-8'));
  } catch { return null; }
}

async function saveJSON(path, data) {
  await mkdir(dirname(path), { recursive: true });
  await writeFile(path, JSON.stringify(data, null, 2));
}

async function fetchCoinGecko() {
  try {
    const res = await fetch(COINGECKO_URL);
    if (!res.ok) throw new Error(`CoinGecko ${res.status}`);
    return await res.json();
  } catch (e) {
    console.error('CoinGecko fetch failed:', e.message);
    return null;
  }
}

async function fetchDexScreener(query) {
  try {
    const res = await fetch(`https://api.dexscreener.com/latest/dex/search?q=${encodeURIComponent(query)}`);
    if (!res.ok) throw new Error(`DexScreener ${res.status}`);
    const data = await res.json();
    if (data.pairs && data.pairs.length > 0) {
      // Pick highest-liquidity pair
      const sorted = data.pairs.sort((a, b) => (b.liquidity?.usd || 0) - (a.liquidity?.usd || 0));
      const pair = sorted[0];
      return {
        price: parseFloat(pair.priceUsd || 0),
        change24h: pair.priceChange?.h24 || 0,
        liquidity: pair.liquidity?.usd || 0,
        volume24h: pair.volume?.h24 || 0,
        pairAddress: pair.pairAddress,
        dexId: pair.dexId
      };
    }
    return null;
  } catch (e) {
    console.error(`DexScreener fetch failed for "${query}":`, e.message);
    return null;
  }
}

function checkAlerts(holding, currentPrice, alertConfig) {
  const alerts = [];
  const pctChange = ((currentPrice - holding.costBasis) / holding.costBasis) * 100;

  if (Math.abs(pctChange) >= alertConfig.priceChange) {
    alerts.push({
      type: pctChange > 0 ? 'PRICE_UP' : 'PRICE_DOWN',
      message: `${holding.symbol} moved ${pctChange.toFixed(2)}% from cost basis`,
      severity: Math.abs(pctChange) >= alertConfig.bigMove ? 'HIGH' : 'MEDIUM'
    });
  }

  if (alertConfig.rugDetection && pctChange <= alertConfig.rugThreshold) {
    alerts.push({
      type: 'RUG_WARNING',
      message: `⚠️ ${holding.symbol} down ${pctChange.toFixed(2)}% — possible rug!`,
      severity: 'CRITICAL'
    });
  }

  return alerts;
}

async function main() {
  const portfolio = await loadJSON(PORTFOLIO_PATH);
  if (!portfolio) { console.error('Cannot load portfolio.json'); process.exit(1); }

  const geckoData = await fetchCoinGecko();
  const geckoMap = {
    'usd-coin': geckoData?.['usd-coin'],
    'ethereum': geckoData?.ethereum,
    'ripple': geckoData?.ripple
  };

  const results = [];
  let totalValue = 0;
  const allAlerts = [];

  for (const holding of portfolio.holdings) {
    let price = null;
    let change24h = null;
    let extra = {};

    if (holding.source === 'coingecko' && geckoMap[holding.coingeckoId]) {
      const d = geckoMap[holding.coingeckoId];
      price = d.usd;
      change24h = d.usd_24h_change || 0;
    } else if (holding.source === 'dexscreener' && holding.searchQuery) {
      const d = await fetchDexScreener(holding.searchQuery);
      if (d) {
        price = d.price;
        change24h = d.change24h;
        extra = { liquidity: d.liquidity, volume24h: d.volume24h };
      }
    }

    const currentValue = price !== null ? holding.quantity * price : holding.valueAtSnapshot;
    totalValue += currentValue;

    const holdingAlerts = price !== null
      ? checkAlerts(holding, price, portfolio.alerts)
      : [];
    allAlerts.push(...holdingAlerts);

    results.push({
      symbol: holding.symbol,
      name: holding.name,
      quantity: holding.quantity,
      priceAtSnapshot: holding.priceAtSnapshot,
      currentPrice: price,
      currentValue: parseFloat(currentValue.toFixed(2)),
      change24h: change24h !== null ? parseFloat(change24h.toFixed(2)) : null,
      changeSinceSnapshot: price !== null
        ? parseFloat((((price - holding.priceAtSnapshot) / holding.priceAtSnapshot) * 100).toFixed(2))
        : null,
      alerts: holdingAlerts,
      ...extra
    });

    // Small delay to avoid rate limits on DexScreener
    if (holding.source === 'dexscreener') await new Promise(r => setTimeout(r, 300));
  }

  const pnl = totalValue - portfolio.tracking.startValue;
  const pnlPct = (pnl / portfolio.tracking.startValue) * 100;

  const summary = {
    timestamp: new Date().toISOString(),
    totalValue: parseFloat(totalValue.toFixed(2)),
    startValue: portfolio.tracking.startValue,
    pnl: parseFloat(pnl.toFixed(2)),
    pnlPercent: parseFloat(pnlPct.toFixed(2)),
    holdings: results,
    alerts: allAlerts,
    alertCount: allAlerts.length
  };

  // Print summary
  console.log(JSON.stringify(summary, null, 2));

  // Append to price history
  let history = await loadJSON(HISTORY_PATH) || { snapshots: [] };
  history.snapshots.push({
    timestamp: summary.timestamp,
    totalValue: summary.totalValue,
    pnl: summary.pnl,
    prices: results.map(r => ({ symbol: r.symbol, price: r.currentPrice, change24h: r.change24h }))
  });
  // Keep last 365 snapshots
  if (history.snapshots.length > 365) history.snapshots = history.snapshots.slice(-365);
  await saveJSON(HISTORY_PATH, history);

  // Update portfolio.json with latest prices
  for (const r of results) {
    if (r.currentPrice !== null) {
      const h = portfolio.holdings.find(h => h.symbol === r.symbol);
      if (h) {
        h.priceAtSnapshot = r.currentPrice;
        h.valueAtSnapshot = r.currentValue;
        if (r.change24h !== null) h.change24h = r.change24h;
      }
    }
  }
  portfolio.portfolio.snapshotDate = new Date().toISOString();
  portfolio.portfolio.totalValueAtSnapshot = summary.totalValue;
  await saveJSON(PORTFOLIO_PATH, portfolio);

  return summary;
}

main().catch(e => { console.error(e); process.exit(1); });
