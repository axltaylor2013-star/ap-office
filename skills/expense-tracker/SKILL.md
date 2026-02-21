---
name: expense-tracker
description: Track business expenses in dashboard/expenses.json with category breakdowns, recurring expense monitoring, and profit margin calculations. Build and update a visual HTML dashboard at dashboard/expenses.html with dark theme and gold accents.
---

# Expense Tracker

## Data Location

- **Data:** `dashboard/expenses.json`
- **HTML Dashboard:** `dashboard/expenses.html`
- **Revenue Data:** `dashboard/revenue.json` (read-only, for profit calculations)

## JSON Schema

```json
{
  "expenses": [
    {
      "id": 1,
      "date": "2026-02-15",
      "description": "Adobe Creative Cloud",
      "amount": 59.99,
      "category": "software/subscriptions",
      "vendor": "Adobe",
      "recurring": true,
      "notes": "Monthly plan — Premiere Pro, After Effects, Photoshop"
    }
  ],
  "categories": [
    "software/subscriptions",
    "hardware",
    "marketing/ads",
    "contractors",
    "office/supplies",
    "travel",
    "API costs",
    "other"
  ],
  "budgets": {
    "monthly": 3000,
    "yearly": 36000
  }
}
```

## Categories

| Category | Examples |
|---|---|
| `software/subscriptions` | Adobe CC, Canva Pro, hosting, domains, SaaS tools |
| `hardware` | Camera gear, laptop, mic, lighting, drives |
| `marketing/ads` | Meta ads, Google ads, influencer collabs, boosted posts |
| `contractors` | Freelancers, editors, designers, VAs |
| `office/supplies` | Desk, chair, stationery, printer ink |
| `travel` | Gas, flights, hotels, meals (client meetings) |
| `API costs` | OpenAI, ElevenLabs, cloud compute, SMS/email APIs |
| `other` | Anything that doesn't fit above |

## Commands

### Log Expense

1. Read `dashboard/expenses.json` (create from template if missing)
2. Add entry with auto-incremented ID and today's date (unless specified)
3. Write back
4. Rebuild HTML dashboard

**Examples:**
- "Log expense: $59.99 Adobe Creative Cloud — software/subscriptions, recurring"
- "Expense: $450 to John Doe for video editing — contractors"
- "Add expense: $120 Meta ads for Bella's Bistro campaign — marketing/ads"

### Log Recurring Expenses (Bulk)

When user says "log recurring expenses for this month" or similar:
1. Filter all entries where `recurring: true`
2. Find the most recent entry per unique (description + vendor + category) combo
3. Duplicate each with the current month's date and same amount
4. Write back and rebuild

### Delete / Edit Expense

- "Delete expense #5"
- "Change expense #3 amount to $75"
- "Mark expense #8 as non-recurring"

### Set Budgets

Update `budgets` object with new targets.

**Example:** "Set monthly expense budget to $4000"

### View Summary

Generate text summary for a given period:
- "Expenses this month" / "Expenses in January" / "Expenses YTD"
- Include: total, by category breakdown, top vendors, recurring vs one-time
- Compare against budget if set

### Profit Margin Report

1. Read `dashboard/revenue.json` for revenue totals
2. Read `dashboard/expenses.json` for expense totals
3. Calculate for requested period:
   - **Gross Profit:** Revenue − Expenses
   - **Profit Margin:** ((Revenue − Expenses) / Revenue) × 100
   - **Expense Ratio:** (Expenses / Revenue) × 100

**Example:** "What's my profit margin this month?" / "Profit report for Q1"

### Rebuild Dashboard

Regenerate `dashboard/expenses.html` from current data. Always rebuild after data changes.

## HTML Dashboard Spec

The dashboard at `dashboard/expenses.html` must:

### Design
- **Dark theme:** Background `#1a1a2e`, cards `#16213e`, text `#e0e0e0`
- **Gold accents:** `#d4a843` for highlights, borders, charts, headers
- **Font:** System sans-serif stack
- **Responsive:** Works on mobile and desktop
- **No external dependencies** — pure HTML/CSS/JS, inline everything

### Sections

1. **Header** — "Kermicle Media — Expense Tracker" with gold accent bar
2. **KPI Cards** (4 cards in a row):
   - Total expenses this month (vs budget, color-coded)
   - YTD expenses
   - Largest category this month (name + amount)
   - Profit margin % (green if >30%, yellow 15-30%, red <15%)
3. **Expense List** — Sortable table with all entries:
   - Columns: Date, Description, Amount, Category, Vendor, Recurring ⟳
   - Filter dropdowns: category, vendor, date range
   - Search box
   - Pagination or scroll
4. **Category Breakdown** — Horizontal CSS bar chart showing spend per category
5. **Monthly Trend** — Vertical CSS bar chart, last 6 months, gold bars on dark bg
6. **Recurring Expenses** — Dedicated section:
   - List of all recurring items with monthly cost
   - **Monthly Burn Rate** total (sum of all recurring)
   - % of total expenses that are recurring
7. **Quick-Add Form** — Inline form with fields:
   - Date (default today), Description, Amount, Category (dropdown), Vendor, Recurring (checkbox), Notes
   - Submit button (gold) — adds to embedded data and re-renders
   - Note: form only works in-page; actual persistence requires agent
8. **Export Button** — Downloads expenses as CSV

### CSS Charts (No Libraries)

**Horizontal bar chart (category breakdown):**
```css
.h-bar-chart .bar-row { display: flex; align-items: center; margin: 6px 0; }
.h-bar-chart .bar-label { width: 160px; text-align: right; padding-right: 12px; color: #e0e0e0; font-size: 0.85rem; }
.h-bar-chart .bar-track { flex: 1; background: #0f3460; border-radius: 4px; overflow: hidden; height: 28px; }
.h-bar-chart .bar-fill { background: linear-gradient(90deg, #d4a843, #f0c966); height: 100%; border-radius: 4px; transition: width 0.3s; }
.h-bar-chart .bar-value { margin-left: 10px; color: #d4a843; font-weight: bold; min-width: 70px; }
```

**Vertical bar chart (monthly trend):**
```css
.v-bar-chart { display: flex; align-items: flex-end; gap: 8px; height: 200px; padding-top: 20px; }
.v-bar-chart .bar { background: #d4a843; border-radius: 4px 4px 0 0; min-width: 40px; flex: 1; transition: height 0.3s; position: relative; }
.v-bar-chart .bar-label { position: absolute; bottom: -22px; left: 50%; transform: translateX(-50%); font-size: 0.75rem; color: #888; }
.v-bar-chart .bar-amount { position: absolute; top: -20px; left: 50%; transform: translateX(-50%); font-size: 0.75rem; color: #d4a843; }
```

### Data Loading

Embed the current JSON data directly into the HTML:
```html
<script>
const expenseData = /* EMBEDDED JSON */;
const revenueData = /* EMBEDDED REVENUE JSON */;
// ... render functions
</script>
```

When rebuilding, read both `expenses.json` and `revenue.json` and embed both.

### Hub Integration

Include at the top of the HTML:
```html
<!-- Tab: Expenses | Link from hub.html -->
```

## Calculations

- **Monthly total:** Sum all expense amounts for the calendar month
- **YTD:** Sum all expenses from Jan 1 of current year through today
- **Category breakdown:** Group by `category`, sum amounts, sort descending
- **Monthly burn rate:** Sum amounts of all entries where `recurring: true` (use most recent instance of each unique recurring expense)
- **Profit margin:** `((revenue - expenses) / revenue) × 100` for the period
- **Budget %:** `(actual / budget) × 100`
- **Top vendors:** Group by `vendor`, sum amounts, sort descending

## Integration

- **revenue-dashboard:** Reads `revenue.json` for profit margin calculations
- **client-crm:** Contractor expenses can reference client projects
- **task-manager:** Expense-related tasks (reimbursements, invoice follow-ups)

## Rules

1. **Always rebuild HTML** after any data change
2. **Embed data directly** in HTML — no fetch() calls to local files
3. **Amounts in dollars** — store as numbers, format with `$` on display
4. **Auto-increment IDs** — max existing ID + 1
5. **Dates in ISO format** — `YYYY-MM-DD`
6. **Category must match** one of the 8 defined categories
7. **Recurring detection:** When logging, if user says "recurring" or "monthly" or "subscription", set `recurring: true`
8. **Vendor normalization:** Capitalize vendor names consistently (e.g., "adobe" → "Adobe")
