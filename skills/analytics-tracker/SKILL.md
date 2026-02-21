---
name: analytics-tracker
description: Track social media analytics across Instagram, TikTok, YouTube, and X/Twitter. Visualize growth over time in dashboard/analytics.html with dark theme and gold accents.
---

# Analytics Tracker

## Data Location

- **Data:** `dashboard/analytics.json`
- **HTML Dashboard:** `dashboard/analytics.html`

## JSON Schema

```json
{
  "snapshots": [
    {
      "id": 1,
      "date": "2026-02-15",
      "platform": "instagram",
      "metrics": {
        "followers": 1250,
        "engagementRate": 4.2,
        "reach": 15000,
        "impressions": 22000
      },
      "topContent": [
        { "title": "Valentine's Day Reel", "metric": "likes", "value": 340, "url": "" }
      ],
      "notes": "Post-Valentine's boost"
    }
  ],
  "goals": [
    {
      "platform": "instagram",
      "metric": "followers",
      "target": 5000,
      "deadline": "2026-06-30",
      "setDate": "2026-02-15"
    }
  ],
  "config": {
    "platforms": ["instagram", "tiktok", "youtube", "twitter"]
  }
}
```

### Platform Metric Shapes

**Instagram:** `followers`, `engagementRate`, `reach`, `impressions`
**TikTok:** `followers`, `views`, `likes`, `comments`
**YouTube:** `subscribers`, `views`, `watchTimeHours`, `likes`
**X/Twitter:** `followers`, `impressions`, `engagementRate`, `retweets`

All platforms may include `topContent` array with `{ title, metric, value, url }`.

## Commands

### Log Snapshot

1. Read `dashboard/analytics.json` (create with empty structure if missing)
2. Parse platform and metrics from user message
3. Auto-increment ID, add ISO date
4. Calculate deltas from previous snapshot for same platform
5. Append to `snapshots` array
6. Write back and rebuild HTML dashboard

**Examples:**
- "Log analytics: Instagram — 1,250 followers, 4.2% engagement, 15,000 reach"
- "Log TikTok stats: 8,500 followers, 125,000 views, 45,000 likes"
- "YouTube update: 2,100 subscribers, 50,000 views, 1,200 watch hours"
- "X analytics: 900 followers, 80,000 impressions, 2.1% engagement"

### View Summary

Generate text summary for a platform or all platforms:
- "Analytics summary" — cross-platform overview
- "How's Instagram doing?" — single platform deep dive
- Include: current metrics, growth since last snapshot, trend direction, goal progress

### Compare Platforms

- "Compare all platforms this month"
- Show side-by-side follower counts, growth rates, engagement
- Highlight best/worst performers

### Set Goals

- "Set Instagram goal: 5,000 followers by June"
- Add to `goals` array
- Show progress in dashboard

### Rebuild Dashboard

Regenerate `dashboard/analytics.html` from current data. Always rebuild after data changes.

## HTML Dashboard Spec

The dashboard at `dashboard/analytics.html` must:

### Design
- **Dark theme:** Background `#1a1a2e`, cards `#16213e`, text `#e0e0e0`
- **Gold accents:** `#d4a843` for highlights, borders, active tabs, headers
- **Platform colors:** Instagram `#E1306C`, TikTok `#00f2ea`, YouTube `#FF0000`, X `#000000`/`#e0e0e0`
- **Font:** System sans-serif stack
- **Responsive:** Works on mobile and desktop
- **No external dependencies** — pure HTML/CSS/JS, inline everything

### Sections
1. **Header** — "Kermicle Media — Analytics Tracker" with gold accent bar
2. **Quick-Add Form** — Log a snapshot directly from the dashboard
3. **Platform Tabs** — All / Instagram / TikTok / YouTube / X
4. **KPI Cards** — Current followers, growth rate, engagement, reach/views
5. **Growth Chart** — Animated SVG line chart showing follower growth over time
6. **Best Performing Content** — Ranked list of top posts/videos
7. **Cross-Platform Summary** — Side-by-side comparison table
8. **Goal Tracking** — Progress bars toward goals with projected completion
9. **Growth Projections** — Trend-based projections per platform
10. **Export Button** — Download analytics.json

### Data Loading

Embed current JSON data directly into the HTML file:
```html
<script>
const analyticsData = /* EMBEDDED JSON */;
</script>
```

When rebuilding, embed the current JSON data directly into the HTML file.

### Hub Integration

Include at the top:
```html
<!-- Tab: Analytics | Link from hub.html -->
```

## Calculations

- **Growth rate:** `((current - previous) / previous) × 100` between consecutive snapshots
- **Trend:** Linear regression on last 5+ data points for projection
- **Goal progress:** `(current / target) × 100`
- **Projected completion:** Extrapolate current growth rate to estimate when goal is hit
- **Cross-platform score:** Normalize follower counts and engagement to 0-100 scale for comparison
- **Deltas:** Always calculate and store difference from last snapshot of same platform

## Integration

- **revenue-dashboard:** Correlate social growth with revenue trends
- **client-crm:** Track which client campaigns drove social growth

## Rules

1. **Always rebuild HTML** after any data change
2. **Embed data directly** in HTML — no fetch() calls to local files
3. **Platform names lowercase** in data — `instagram`, `tiktok`, `youtube`, `twitter`
4. **Auto-increment IDs** across all snapshots regardless of platform
5. **Dates in ISO format** — `YYYY-MM-DD`
6. **Metrics as numbers** — no commas or symbols in stored data, format on display
7. **Preserve all snapshots** — never delete historical data unless explicitly asked
