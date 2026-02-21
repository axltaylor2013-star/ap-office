---
name: email-outreach
description: Write personalized cold outreach emails for Kermicle Media by business niche. Track contacts in outreach/contacts.json. Manage follow-up sequences. Pairs with local-lead-gen skill.
---

# Email Outreach

## Data Location

`outreach/contacts.json`

## JSON Schema

```json
{
  "contacts": [
    {
      "id": 1,
      "business": "Bella's Bistro",
      "niche": "restaurant",
      "contact": "Maria Lopez",
      "email": "maria@bellasbistro.com",
      "phone": "555-0199",
      "source": "local-lead-gen",
      "stage": "initial",
      "emails": [
        {
          "type": "initial",
          "sentDate": "2026-02-15",
          "subject": "Quick question about your content",
          "opened": false,
          "replied": false
        }
      ],
      "followUpDate": "2026-02-18",
      "status": "active",
      "notes": "Found on Google Maps, 4.5 stars, active Instagram",
      "added": "2026-02-15"
    }
  ]
}
```

## Supported Niches

Each niche has tailored messaging angles:

| Niche | Key Pain Points | Kermicle Media Angle |
|-------|----------------|---------------------|
| `restaurant` | Food photography looks amateur, no video content | Professional food/ambiance shots, short-form reels |
| `real-estate` | Listings need better visuals, virtual tours | Property photo editing, video walkthroughs, AI staging |
| `fitness` | Need content for socials, before/after edits | Transformation reels, trainer highlight videos |
| `boutique` | Product photos lack polish, no brand consistency | Product photography editing, brand content packages |
| `event-planner` | Need portfolio content, highlight reels | Event recap videos, photo editing, promo content |

## Email Sequence

Each contact moves through a 4-stage sequence:

### Stage 1: Initial Contact
- **When:** Day 0
- **Tone:** Friendly, specific, short
- **Goal:** Get a reply or meeting

### Stage 2: Follow-up #1
- **When:** 3 days after initial (no reply)
- **Tone:** Add value, reference something specific about their business
- **Goal:** Demonstrate you looked at their stuff

### Stage 3: Follow-up #2
- **When:** 5 days after follow-up #1
- **Tone:** Social proof, case study, quick win offer
- **Goal:** Overcome objection or inertia

### Stage 4: Break-up Email
- **When:** 7 days after follow-up #2
- **Tone:** Respectful close, leave door open
- **Goal:** Last chance reply or clean exit

## Email Templates

### Initial Contact — Restaurant Example

**Subject:** Quick idea for [Business Name]'s Instagram

**Body:**
```
Hi [Name],

I was checking out [Business Name] on Instagram and your food looks amazing — but I think your content could be doing way more for you.

I'm Alex with Kermicle Media. We help restaurants turn their dishes into scroll-stopping content — professional photo editing, short-form reels, the works.

Would you be open to a quick 10-minute chat about what that could look like for [Business Name]? No pressure at all.

Best,
Alex Taylor
Kermicle Media
```

### Follow-up #1 — Restaurant Example

**Subject:** Re: Quick idea for [Business Name]'s Instagram

**Body:**
```
Hi [Name],

Just circling back — I put together a quick mock-up of how [specific dish or photo from their page] could look with professional editing. Happy to send it over if you're curious.

Either way, no worries. Just thought it could help.

Alex
```

### Follow-up #2 — Any Niche

**Subject:** Thought you'd find this interesting

**Body:**
```
Hi [Name],

Wanted to share a quick win — we recently helped [similar business type] increase their social engagement by [X]% with just a content refresh. Took about a week.

If [Business Name] is looking to level up its visuals, I'd love to show you what we did. Free, no strings.

Alex
Kermicle Media
```

### Break-up Email — Any Niche

**Subject:** Should I close your file?

**Body:**
```
Hi [Name],

I've reached out a few times and totally understand if the timing isn't right. No hard feelings at all.

If you ever want to explore better content for [Business Name], just reply to this email and I'll be here.

Wishing you all the best,
Alex
Kermicle Media
```

## Commands

### Draft Email

Generate a personalized email for a contact based on their niche and current stage.

1. Look up contact in `outreach/contacts.json`
2. Determine current stage
3. Generate email using niche-specific template, personalized with business details
4. Present draft for review

**Example:** "Draft email for Bella's Bistro"

### Send (Log) Email

After approval, log the email as sent:

1. Add entry to contact's `emails` array
2. Advance `stage` to next stage
3. Set `followUpDate` based on sequence timing
4. Update `status` if break-up was sent → `closed`

**Example:** "Mark initial email sent to Bella's Bistro"

### Add Contact

1. Read contacts file (create if missing)
2. Add new contact with auto-incremented ID, stage `initial`
3. Write back

**Example:** "Add outreach contact: Flex Gym, fitness niche, contact Jake@flexgym.com"

### Due Follow-ups

List all contacts where `followUpDate` ≤ today and `status` = `active`.

**Example:** "Show due follow-ups" / "Who needs a follow-up?"

### Update Contact Status

Mark contacts as `replied`, `converted`, `unsubscribed`, or `closed`.

- `replied` → Stop sequence, move to manual handling
- `converted` → Add to client-crm via client-crm skill
- `unsubscribed` → Never contact again
- `closed` → Sequence complete, no reply

**Example:** "Bella's Bistro replied to our email"

## Personalization Rules

1. **Always reference something specific** — their Instagram, a menu item, a listing, a class name
2. **Keep emails under 100 words** for initial and follow-ups
3. **No attachments** in cold emails
4. **Subject lines under 8 words**, curiosity-driven
5. **Sign as Alex Taylor, Kermicle Media**
6. **Adapt tone per niche** — casual for restaurants/fitness, professional for real estate

## Integration

- **local-lead-gen**: Leads discovered flow into outreach contacts
- **client-crm**: Converted contacts become CRM clients
- **task-manager**: Outreach batches can be tracked as tasks

## Rules

1. **Never email `unsubscribed` contacts**
2. **Auto-increment IDs**
3. **Dates in ISO format** — `YYYY-MM-DD`
4. **Validate JSON** before writing
5. **Check for duplicates** by email before adding
6. **Max 20 new outreach emails per day** to avoid spam flags
