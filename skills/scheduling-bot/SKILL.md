---
name: scheduling-bot
description: Manage content posting schedules across social platforms. Integrates with dashboard/calendar.json for visual display on calendar.html. Supports single and batch scheduling, optimal time suggestions, reminders, and content queue management.
---

# Scheduling Bot

## Data Location

- **Data:** `dashboard/calendar.json` (shared with calendar dashboard)
- **Display:** `dashboard/calendar.html` (existing — do not recreate)

## JSON Schema — Scheduled Posts

Posts are stored as events in `calendar.json`. Scheduling entries use `type: "content"`:

```json
{
  "events": [
    {
      "id": "post-001",
      "type": "content",
      "title": "Behind the scenes reel",
      "date": "2026-02-16",
      "time": "10:00",
      "platform": "instagram",
      "status": "scheduled",
      "content": {
        "caption": "Take a peek behind the curtain 🎬✨ #BTS #ContentCreation",
        "format": "reel",
        "hashtags": ["#BTS", "#ContentCreation", "#KermicleMedia"],
        "media": "bts-reel-feb16.mp4",
        "notes": "Use trending audio, keep under 60s"
      },
      "client": null,
      "campaign": null,
      "createdAt": "2026-02-15T16:30:00Z"
    }
  ]
}
```

### Status Flow

```
draft → scheduled → posted → archived
```

- **draft** — Content planned but not finalized
- **scheduled** — Confirmed, ready to post at the specified time
- **posted** — Published (manually marked or auto-detected)
- **archived** — Old content, kept for reference

## Supported Platforms

| Platform | Key | Optimal Times (EST) | Notes |
|---|---|---|---|
| Instagram | `instagram` | 11am, 1pm, 7pm | Reels: 9am, 12pm. Carousels perform best midweek |
| TikTok | `tiktok` | 10am, 2pm, 8pm | Tue-Thu highest engagement. Trending audio matters more than time |
| YouTube | `youtube` | 2pm–4pm (weekdays), 9am–11am (weekends) | Publish 2-3h before peak viewing |
| Facebook | `facebook` | 1pm–4pm | Wed highest engagement. Video > image > text |
| Twitter/X | `twitter` | 8am–10am, 12pm–1pm | Threads perform well. Engage in replies 30min after posting |
| LinkedIn | `linkedin` | 7am–8am, 12pm, 5pm–6pm | Tue-Thu best. Professional tone, no hashtag spam |
| Pinterest | `pinterest` | 8pm–11pm | Sat highest. Use keyword-rich descriptions |

## Commands

### Schedule a Post

**Syntax:** "Schedule post for [platform] [date] [time] — [description]"

**Procedure:**
1. Read `dashboard/calendar.json`
2. Parse platform, date/time, and description
3. Create entry with auto-generated ID (`post-NNN`), status `scheduled`
4. If no time given, suggest optimal time for that platform
5. Add platform-specific formatting reminders in response
6. Write back and confirm

**Examples:**
- "Schedule post for Instagram tomorrow 10am — Behind the scenes reel"
- "Schedule TikTok post Friday — Product demo with trending audio"
- "Schedule LinkedIn post Monday 8am — Case study: How we grew Bella's engagement 300%"

### Batch Scheduling

**Syntax:** "Schedule [N] posts this week" or "Batch schedule for the week"

**Procedure:**
1. Ask for platform(s) and content themes (or use defaults)
2. Auto-distribute across the week using optimal times per platform
3. Avoid scheduling conflicts (no two posts within 2 hours on same platform)
4. Spread across days: prefer Tue-Thu for engagement, lighter on Mon/Fri
5. Create all entries as `draft` status for review
6. Present the full schedule for approval before finalizing to `scheduled`

**Example:**
```
User: "Schedule 5 Instagram posts this week"
Agent: Here's the proposed schedule:
  Mon 11:00 AM — [Draft] Post 1
  Tue  1:00 PM — [Draft] Post 2
  Wed  7:00 PM — [Draft] Post 3
  Thu 11:00 AM — [Draft] Post 4
  Sat  9:00 AM — [Draft] Post 5
Want me to confirm these or adjust any times?
```

### Suggest Optimal Time

**Syntax:** "Best time to post on [platform]?" or "When should I post this?"

Response includes:
- Top 3 time slots for the platform
- Day-of-week recommendations
- Any format-specific timing (e.g., Reels vs Stories)
- If engagement data exists in analytics.json, use actual data over defaults

### Content Queue

**Syntax:** "Show content queue" / "What's scheduled this week?"

**Procedure:**
1. Read `calendar.json`, filter `type: "content"`
2. Group by status: drafts first, then scheduled (chronological), then recently posted
3. Format as a clean list with platform emoji, date/time, title, status

**Status emojis:**
- 📝 draft
- 📅 scheduled
- ✅ posted
- 📦 archived

### Mark as Posted

**Syntax:** "Mark post #post-005 as posted" / "Posted the Instagram reel"

Updates status to `posted` and adds `postedAt` timestamp.

### Weekly Schedule Overview

**Syntax:** "Show this week's schedule" / "Weekly posting schedule"

Generates a day-by-day view:
```
📅 Week of Feb 16–22, 2026

Monday:
  📅 11:00 AM — Instagram: Behind the scenes reel

Tuesday:
  📅  1:00 PM — TikTok: Product showcase
  📅  5:30 PM — LinkedIn: Case study post

Wednesday:
  (nothing scheduled)

Thursday:
  📅  2:00 PM — YouTube: Tutorial upload
  📝  7:00 PM — Instagram: [DRAFT] Carousel ideas

Friday–Sunday:
  📅 Sat 9:00 AM — Instagram: Weekend engagement post
```

### Reminders

When a heartbeat fires or the agent checks in, scan for upcoming posts:
- **≤2 hours away:** "⏰ Reminder: Instagram post 'Behind the scenes reel' scheduled for 10:00 AM — ready to go?"
- **≤30 minutes:** "🚨 Post NOW: TikTok 'Product demo' is due in 30 minutes!"
- **Overdue (not marked posted):** "⚠️ Overdue: Instagram post from 10:00 AM hasn't been marked as posted. Did you publish it?"

Add reminder logic to `HEARTBEAT.md` checklist:
```markdown
- [ ] Check calendar.json for posts due within 2 hours
```

### Reschedule / Cancel

- "Move the Instagram post to Thursday 2pm"
- "Cancel post #post-003"
- "Push all Wednesday posts to Thursday"

## Platform-Specific Formatting Reminders

When scheduling, include relevant reminders:

### Instagram
- **Caption limit:** 2,200 characters
- **Hashtags:** 3-5 targeted > 30 generic. Mix niche + broad
- **Reels:** Use trending audio, hook in first 3 seconds, 15-60s optimal
- **Carousels:** 10 slides max, strong CTA on last slide
- **Stories:** Use polls/questions for engagement

### TikTok
- **Caption limit:** 2,200 characters
- **Hashtags:** 3-5 max, include 1 trending + niche
- **Video:** Hook in first 1 second. 15-60s sweet spot
- **Trending sounds** boost reach significantly
- **Post consistently** (daily if possible)

### YouTube
- **Title:** Under 60 chars, keyword-front-loaded
- **Description:** First 2 lines matter (above the fold)
- **Thumbnail:** Custom always. High contrast, readable text
- **Tags:** 5-8 relevant tags
- **Publish 2-3h before peak** viewing in your audience's timezone

### LinkedIn
- **Character limit:** 3,000 for posts
- **No hashtag spam** — 3-5 relevant ones at the end
- **Professional tone** but personality is fine
- **Native video/docs** get higher reach than links
- **Engage in comments** within first hour

### Twitter/X
- **Character limit:** 280 (or 25,000 for premium)
- **Threads** outperform single tweets for engagement
- **Media tweets** get 3x more engagement
- **Reply to your own tweet** within 30 min for algorithm boost
- **No more than 2 hashtags**

### Facebook
- **Video posts** get highest organic reach
- **Optimal length:** 1-2 short paragraphs
- **Questions/polls** drive comments
- **Share to Stories** for extra visibility

### Pinterest
- **Vertical images** (2:3 ratio)
- **Keyword-rich descriptions** — Pinterest is a search engine
- **Rich Pins** when possible
- **Consistency matters** — pin daily

## Integration

- **calendar dashboard:** All posts appear on `calendar.html` as events
- **revenue-dashboard:** Track content → client revenue correlation
- **analytics (future):** Pull engagement data to refine optimal posting times
- **task-manager:** Create tasks for content production pipeline

## Rules

1. **All times in EST** unless user specifies otherwise
2. **Auto-generate post IDs** — format `post-NNN` (zero-padded 3 digits)
3. **No double-booking** — warn if same platform has a post within 2 hours
4. **Draft by default** for batch scheduling — require confirmation to set `scheduled`
5. **Always show platform reminders** when scheduling (brief, 1-2 lines)
6. **Dates in ISO format** in JSON — `YYYY-MM-DD`
7. **Times in 24h format** in JSON — `HH:MM` — display in 12h for user
8. **Rebuild calendar if needed** — after modifying calendar.json, note that calendar.html may need refresh
9. **Respect quiet hours** — don't suggest posting times between 11pm–6am unless user insists
