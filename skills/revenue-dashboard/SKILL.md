---
name: revenue-dashboard
description: Track Kermicle Media income by client, service, and month in dashboard/revenue.json. Build and update a visual HTML dashboard at dashboard/revenue.html with dark theme and gold accents.
---

# Revenue Dashboard

## Data Location

- **Data:** `dashboard/revenue.json`
- **HTML Dashboard:** `dashboard/revenue.html`

## JSON Schema

```json
{
  "entries": [
    {
      "id": 1,
      "date": "2026-02-15",
      "client": "Bella's Bistro",
      "service": "video-editing",
      "amount": 750,
      "description": "Valentine's Day Reel",
      "status": "paid"
    }
  ],
  "goals": {
    "monthly": 5000,
    "quarterly": 15000,
    "yearly": 60000
  },
  "projections": {
    "method": "3-month-average"
  }
}
```

## Commands

### Log Revenue

1. Read `dashboard/revenue.json` (create with `{"entries":[],"goals":{"monthly":5000,"quarterly":15000,"yearly":60000},"projections":{"method":"3-month-average"}}` if missing)
2. Add entry with auto-incremented ID
3. Write back
4. Rebuild HTML dashboard

**Example:** "Log revenue: $750 from Bella's Bistro for video-editing — Valentine's Day Reel"

### Set Goals

Update `goals` object with new targets.

**Example:** "Set monthly revenue goal to $8000"

### View Summary

Generate text summary for a given period:
- "Revenue this month" / "Revenue in January" / "Revenue Q1"
- Include: total, by service breakdown, by client, vs goal

### Rebuild Dashboard

Regenerate `dashboard/revenue.html` from current data. Always rebuild after data changes.

## HTML Dashboard Spec

The dashboard at `dashboard/revenue.html` must:

### Design
- **Dark theme:** Background `#1a1a2e`, cards `#16213e`, text `#e0e0e0`
- **Gold accents:** `#d4a843` for highlights, borders, progress bars, headers
- **Font:** System sans-serif stack
- **Responsive:** Works on mobile and desktop
- **No external dependencies** — pure HTML/CSS/JS, inline everything

### Sections
1. **Header** — "Kermicle Media — Revenue Dashboard" with gold accent bar
2. **KPI Cards** — Monthly revenue, YTD revenue, outstanding invoices, avg per client
3. **Monthly Revenue Chart** — Pure CSS bar chart, last 6 months, gold bars on dark bg
4. **Revenue by Service** — Horizontal bar chart or pie-style breakdown
5. **Top Clients** — Ranked list with revenue amounts
6. **Goal Tracking** — Progress bar showing monthly/quarterly/yearly vs targets
7. **Projections** — Based on 3-month rolling average, show projected monthly/yearly

### CSS Charts (No Libraries)

**Bar chart pattern:**
```css
.bar-chart { display: flex; align-items: flex-end; gap: 8px; height: 200px; }
.bar { background: #d4a843; border-radius: 4px 4px 0 0; min-width: 40px; transition: height 0.3s; }
```

**Progress bar pattern:**
```css
.progress-track { background: #0f3460; border-radius: 8px; overflow: hidden; }
.progress-fill { background: linear-gradient(90deg, #d4a843, #f0c966); height: 24px; border-radius: 8px; }
```

### Data Loading

The HTML file reads from `revenue.json` via inline `<script>` with the data embedded directly:
```html
<script>
const revenueData = /* PASTE JSON HERE */;
// ... render functions
</script>
```

When rebuilding, embed the current JSON data directly into the HTML file.

### Hub Integration

The dashboard should be linkable as a tab from `dashboard/hub.html`. Include at the top:
```html
<!-- Tab: Revenue | Link from hub.html -->
```

## Calculations

- **Monthly revenue:** Sum all entries for the calendar month
- **By service:** Group entries by `service` field, sum amounts
- **Top clients:** Group by `client`, sum amounts, sort descending
- **Projection:** Average of last 3 months with data × 12 for yearly
- **Goal %:** `(actual / goal) × 100`, cap display at 150%

## Integration

- **client-crm**: When an invoice is marked paid, log revenue entry here
- **task-manager**: Revenue work can be tracked as tasks

## Rules

1. **Always rebuild HTML** after any data change
2. **Embed data directly** in HTML — no fetch() calls to local files
3. **Amounts in dollars** — store as numbers, format with `$` on display
4. **Status values:** `paid`, `pending`, `refunded`
5. **Auto-increment IDs**
6. **Dates in ISO format** — `YYYY-MM-DD`
