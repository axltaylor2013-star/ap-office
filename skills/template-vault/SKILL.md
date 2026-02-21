---
name: template-vault
description: Central repository for all reusable templates — emails, proposals, captions, contracts, reports, and briefs. Use when Jeremy needs to quickly generate pre-written content with variable substitution, save new templates, or browse the template library. Templates live at workspace templates/ with a registry at templates/registry.json.
---

# Template Vault

## Quick Reference

| Command Pattern | Action |
|----------------|--------|
| "Use cold outreach template for [niche]" | Fill variables, output ready text |
| "Send a follow-up email to [client]" | Use follow-up template with client details |
| "List all email templates" | Show filtered view of email category |
| "List templates" / "Show all templates" | Show full registry |
| "Save this as a template called [name]" | Store new template to registry |
| "Use [template-id]" | Use specific template by ID |
| "Caption for Instagram promo" | Use social caption template |

## Variable System

All templates use `{{variable}}` syntax. Standard variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `{{client_name}}` | Client's full name | "Sarah Mitchell" |
| `{{client_first_name}}` | Client's first name | "Sarah" |
| `{{company}}` | Client's company/business name | "Bella's Boutique" |
| `{{service_type}}` | Service being offered | "Social Media Management" |
| `{{price}}` | Price/rate | "$1,500/month" |
| `{{date}}` | Current or relevant date | "February 15, 2026" |
| `{{your_name}}` | Jeremy's name | "Jeremy Kermicle" |
| `{{your_company}}` | Company name | "Kermicle Media" |
| `{{your_email}}` | Contact email | (from USER.md) |
| `{{your_phone}}` | Contact phone | (from USER.md) |
| `{{niche}}` | Client's industry/niche | "fitness" |
| `{{deliverables}}` | List of deliverables | "4 reels/month, stories, captions" |
| `{{timeline}}` | Project timeline | "2 weeks" |
| `{{cta}}` | Call to action | "Book a free strategy call" |
| `{{pain_point}}` | Client's main challenge | "inconsistent posting schedule" |
| `{{result}}` | Promised outcome | "3x engagement in 90 days" |
| `{{testimonial}}` | Social proof quote | "Jeremy doubled our reach..." |
| `{{invoice_number}}` | Invoice ID | "KM-2026-015" |
| `{{amount_due}}` | Amount owed | "$1,500.00" |
| `{{due_date}}` | Payment due date | "March 1, 2026" |
| `{{project_name}}` | Project name | "Spring Campaign" |
| `{{platform}}` | Social media platform | "Instagram" |

### Default Values

When Jeremy doesn't specify, auto-fill:
- `{{your_name}}` → "Jeremy Kermicle"
- `{{your_company}}` → "Kermicle Media"
- `{{date}}` → today's date

## Workflow

### Using a Template

1. Identify which template matches the request
2. Gather required variables from context or ask Jeremy
3. Substitute all `{{variables}}` with actual values
4. Output the filled template as clean, ready-to-use text
5. Ask if any tweaks are needed

### Saving a New Template

1. Jeremy provides content and a name
2. Generate a slug ID from the name (e.g., "Holiday Promo" → `holiday-promo`)
3. Identify category and platform (ask if unclear)
4. Extract variables (look for things that would change per use)
5. Replace specific values with `{{variable}}` placeholders
6. Add to `templates/registry.json`
7. Confirm save with summary

### Listing Templates

1. Read `templates/registry.json`
2. Filter by requested category/platform/tag
3. Display as a clean formatted list with ID, name, and category

## Template Registry

The registry lives at `templates/registry.json`. Create it on first use if it doesn't exist. Structure:

```json
{
  "templates": [
    {
      "id": "cold-outreach-restaurant",
      "name": "Cold Outreach — Restaurant",
      "category": "email",
      "subcategory": "cold-outreach",
      "platform": null,
      "tags": ["cold", "outreach", "restaurant", "food"],
      "variables": ["client_name", "company", "your_name", "your_company", "pain_point", "result", "cta"],
      "description": "Cold email for reaching out to restaurant owners about content/social media services."
    }
  ]
}
```

## Pre-Loaded Templates

### EMAIL — Cold Outreach

---

#### Template: `cold-outreach-restaurant`
**Name:** Cold Outreach — Restaurant
**Category:** email / cold-outreach
**Tags:** cold, outreach, restaurant, food, hospitality
**Variables:** client_name, company, your_name, your_company, pain_point, result, cta

```
Subject: {{company}}'s food looks incredible — let's make sure people see it

Hey {{client_name}},

I came across {{company}} and honestly, your food looks amazing. But I noticed your social media presence might not be doing it justice — and that means potential customers are scrolling right past you.

Here's the thing: restaurants that post consistent, high-quality content see 2-3x more foot traffic from social media. But I get it — you're busy running a kitchen, not a content studio.

That's where I come in. I'm {{your_name}} from {{your_company}}, and I help restaurants like yours turn their food into scroll-stopping content that actually brings people through the door.

What I typically do for restaurants:
• Professional food photography & video content
• Short-form reels that showcase your dishes and vibe
• Strategic posting schedule optimized for local reach

{{cta}}

No pressure at all — just thought your spot deserved more eyeballs.

Best,
{{your_name}}
{{your_company}}
```

---

#### Template: `cold-outreach-fitness`
**Name:** Cold Outreach — Fitness / Personal Trainer
**Category:** email / cold-outreach
**Tags:** cold, outreach, fitness, gym, trainer, health
**Variables:** client_name, company, your_name, your_company, result, cta

```
Subject: Your transformations are impressive — let's get them seen

Hey {{client_name}},

I've been checking out {{company}} and the results you're getting with your clients are seriously impressive. But here's what I've noticed with a lot of fitness pros: the work speaks for itself... when people actually see it.

Most trainers post inconsistently or with content that doesn't capture the energy of what they actually do. That's a missed opportunity, because people buy transformations — and you clearly deliver them.

I'm {{your_name}} from {{your_company}}. I help fitness professionals and gyms create content that converts followers into paying clients.

Here's what that usually looks like:
• High-energy workout reels and transformation stories
• Before/after content with cinematic quality
• Consistent posting strategy that builds authority in your area

The result? {{result}}

{{cta}} — I'd love to show you what we could do with your brand.

Talk soon,
{{your_name}}
{{your_company}}
```

---

#### Template: `cold-outreach-real-estate`
**Name:** Cold Outreach — Real Estate Agent
**Category:** email / cold-outreach
**Tags:** cold, outreach, real estate, realtor, property
**Variables:** client_name, company, your_name, your_company, result, cta

```
Subject: Your listings deserve better content — here's what I mean

Hey {{client_name}},

I was browsing listings in your area and came across your profile at {{company}}. You clearly know your market, but I think your content could be working a lot harder for you.

In today's market, buyers make decisions before they ever schedule a showing. The agents winning right now are the ones with cinematic property tours, neighborhood highlight reels, and a personal brand that screams "I'm the expert here."

I'm {{your_name}} from {{your_company}}, and I specialize in helping real estate professionals create content that sells — both properties and your personal brand.

What I do for agents like you:
• Cinematic property walkthrough videos
• "Day in the life" and market update reels
• Professional listing photos and virtual tours
• Social media strategy that positions you as the local authority

My clients typically see {{result}}.

{{cta}} — I'll put together a quick content game plan specific to your market.

Best,
{{your_name}}
{{your_company}}
```

---

### EMAIL — Follow-Up

---

#### Template: `follow-up-gentle`
**Name:** Gentle Follow-Up
**Category:** email / follow-up
**Tags:** follow-up, gentle, reminder, warm
**Variables:** client_name, company, your_name, your_company, service_type

```
Subject: Re: Quick follow-up

Hey {{client_name}},

Just wanted to float back to the top of your inbox — I know things get busy!

I reached out recently about helping {{company}} with {{service_type}}, and I'd still love to chat if you're open to it. No pressure at all.

If now's not the right time, totally understand. But if you're even a little curious, I'm happy to put together a quick mockup or strategy outline so you can see what it'd look like — no commitment needed.

Either way, wishing you and {{company}} all the best!

Cheers,
{{your_name}}
{{your_company}}
```

---

#### Template: `follow-up-breakup`
**Name:** Break-Up Email (Final Follow-Up)
**Category:** email / follow-up
**Tags:** follow-up, breakup, final, last-chance
**Variables:** client_name, company, your_name, your_company, service_type

```
Subject: Should I close your file?

Hey {{client_name}},

I've reached out a couple of times about helping {{company}} with {{service_type}}, and I haven't heard back — which is totally fine! You're busy, and I respect that.

I don't want to be that person clogging up your inbox, so I'll assume the timing isn't right and close things out on my end.

But if anything changes down the road — whether it's next month or next year — my door's always open. Just reply to this email and we'll pick right back up.

Wishing you nothing but success,
{{your_name}}
{{your_company}}

P.S. If I totally missed your reply somehow, I apologize! Just let me know and I'll get right back to you.
```

---

### EMAIL — Welcome

---

#### Template: `welcome-email`
**Name:** Welcome Email — New Client
**Category:** email / welcome
**Tags:** welcome, onboarding, new-client
**Variables:** client_name, client_first_name, company, your_name, your_company, service_type, deliverables

```
Subject: Welcome to {{your_company}}! 🎬 Let's get started

Hey {{client_first_name}}!

Welcome aboard — I'm so pumped to be working with you and {{company}}!

Here's what happens next:

1. **Onboarding** — I'll send over a quick questionnaire to learn more about your brand, goals, and style preferences. This helps me nail your voice from day one.

2. **Brand Assets** — Please send over any logos, brand colors, fonts, or style guides you have. Don't have them? No worries — I'll work with what we've got.

3. **First Deliverables** — Once I have your materials, I'll get started on {{service_type}}. Here's what you can expect:
   {{deliverables}}

4. **Communication** — I'm available via email or text. I'll send progress updates and always get your approval before anything goes live.

**What to expect from me:**
✅ Consistent, high-quality work
✅ Clear communication and fast responses
✅ 2 rounds of revisions included per deliverable
✅ Monthly check-ins to make sure we're aligned

If you have any questions at all, don't hesitate to reach out. I'm here to make your life easier.

Let's create something awesome together!

Best,
{{your_name}}
{{your_company}}
```

---

### EMAIL — Invoice Reminder

---

#### Template: `invoice-reminder`
**Name:** Invoice Payment Reminder
**Category:** email / invoice
**Tags:** invoice, payment, reminder, billing
**Variables:** client_name, client_first_name, company, your_name, your_company, invoice_number, amount_due, due_date

```
Subject: Friendly reminder — Invoice {{invoice_number}}

Hey {{client_first_name}},

Hope you're doing well! Just a quick reminder that Invoice {{invoice_number}} for {{amount_due}} is due on {{due_date}}.

**Invoice Details:**
• Invoice #: {{invoice_number}}
• Amount: {{amount_due}}
• Due Date: {{due_date}}

If you've already sent payment, please disregard this — and thank you! If not, no rush, just wanted to make sure it's on your radar.

Payment can be sent via Zelle, PayPal, or bank transfer. Let me know if you need the details again or have any questions about the invoice.

Thanks as always for being a great client!

Best,
{{your_name}}
{{your_company}}
```

---

### SOCIAL MEDIA — Captions

---

#### Template: `caption-promo`
**Name:** Social Media Caption — Promo/Service Highlight
**Category:** caption / promo
**Tags:** caption, social, promo, service, instagram, tiktok
**Platform:** Instagram, TikTok, X
**Variables:** company, service_type, result, cta, pain_point

**Instagram/TikTok version:**
```
{{pain_point}}? Yeah, we fixed that. 😮‍💨

Here's the truth: most businesses know they need great content. But between running the day-to-day and trying to figure out algorithms, it falls to the bottom of the list.

That's exactly why {{company}} exists.

We handle {{service_type}} so you can focus on what you do best — running your business.

The result? {{result}} 📈

{{cta}} 👇
Link in bio.

#ContentCreator #SocialMediaMarketing #{{niche}} #BusinessGrowth #ContentStrategy #BrandBuilding
```

**X (Twitter) version:**
```
{{pain_point}}?

That's why {{company}} exists.

We handle {{service_type}} → you focus on your business.

Result: {{result}}

{{cta}} ↓
```

---

#### Template: `caption-value`
**Name:** Social Media Caption — Value Post / Tips
**Category:** caption / value
**Tags:** caption, social, value, tips, educational, instagram, tiktok
**Platform:** Instagram, TikTok, YouTube
**Variables:** company, niche, your_name

**Instagram/TikTok version:**
```
Stop making these 3 content mistakes 🚫

1️⃣ Posting without a strategy
You're not "staying consistent" — you're just throwing spaghetti at the wall. Every post should have a purpose: educate, entertain, or convert.

2️⃣ Ignoring video content
Reels and TikToks get 2-3x more reach than static posts. If you're not on video, you're invisible.

3️⃣ No clear CTA
Every post should tell people what to do next. Follow, save, click, DM — make it easy.

Save this for later ✅ and follow @{{company}} for more content tips.

#ContentTips #SocialMediaTips #{{niche}} #MarketingStrategy #ContentCreation #GrowYourBrand
```

**YouTube description version:**
```
In this video, I'm breaking down the 3 biggest content mistakes I see businesses make — and exactly how to fix them.

If you're posting consistently but not seeing results, this is for you.

🔔 Subscribe for weekly content & marketing tips
📩 Work with me: [link]

Timestamps:
0:00 — Intro
0:30 — Mistake #1: No Strategy
2:15 — Mistake #2: Avoiding Video
4:00 — Mistake #3: No CTA
5:30 — Bonus Tip

#ContentMarketing #SocialMediaTips #{{niche}}
```

---

### PROPOSAL

---

#### Template: `proposal-email`
**Name:** Proposal Cover Email
**Category:** email / proposal
**Tags:** proposal, pitch, formal, service
**Variables:** client_name, client_first_name, company, your_name, your_company, service_type, price

```
Subject: Your custom proposal from {{your_company}}

Hey {{client_first_name}},

Thanks for taking the time to chat — I really enjoyed learning about {{company}} and what you're looking to achieve.

As promised, I've put together a custom proposal tailored to your needs. Here's a quick summary:

**Service:** {{service_type}}
**Investment:** {{price}}

The full proposal is attached with a detailed scope of work, timeline, and deliverables breakdown.

I'm confident we can deliver some seriously great results for {{company}}. If you have any questions or want to adjust anything, I'm all ears.

Ready to get started? Just reply to this email or book a call, and we'll lock everything in.

Looking forward to it!

Best,
{{your_name}}
{{your_company}}
```

---

### BRIEF

---

#### Template: `project-brief`
**Name:** Project Brief Template
**Category:** brief / project
**Tags:** brief, project, planning, scope, creative
**Variables:** client_name, company, project_name, service_type, deliverables, timeline, date

```
# Project Brief: {{project_name}}

**Client:** {{client_name}} — {{company}}
**Date:** {{date}}
**Service:** {{service_type}}
**Timeline:** {{timeline}}

---

## Objective
What is the goal of this project? What does success look like?

[Fill in]

## Deliverables
{{deliverables}}

## Target Audience
Who is this content for?

[Fill in — demographics, psychographics, platforms they use]

## Brand Voice & Style
Describe the tone, visual style, and any brand guidelines to follow.

[Fill in — or reference brand-kit if available]

## Key Messages
What are the 2-3 most important things to communicate?

1. [Message 1]
2. [Message 2]
3. [Message 3]

## References & Inspiration
Links or descriptions of content you like.

- [Reference 1]
- [Reference 2]

## Timeline & Milestones

| Phase | Deliverable | Due Date |
|-------|------------|----------|
| Phase 1 | [First draft / concept] | [Date] |
| Phase 2 | [Revisions] | [Date] |
| Phase 3 | [Final delivery] | [Date] |

## Notes
Any additional context, requirements, or constraints.

[Fill in]
```

---

### REPORT

---

#### Template: `weekly-report`
**Name:** Weekly Report Template
**Category:** report / weekly
**Tags:** report, weekly, analytics, progress, update
**Variables:** client_name, company, your_name, your_company, date, project_name

```
# Weekly Report — {{company}}

**Prepared by:** {{your_name}}, {{your_company}}
**Week of:** {{date}}
**Project:** {{project_name}}

---

## Summary

[1-2 sentence overview of what was accomplished this week]

## Work Completed

- ✅ [Deliverable 1]
- ✅ [Deliverable 2]
- ✅ [Deliverable 3]

## In Progress

- 🔄 [Task 1] — Expected completion: [date]
- 🔄 [Task 2] — Expected completion: [date]

## Key Metrics (if applicable)

| Metric | This Week | Last Week | Change |
|--------|-----------|-----------|--------|
| Followers | [X] | [X] | [+/-X] |
| Engagement Rate | [X%] | [X%] | [+/-X%] |
| Reach | [X] | [X] | [+/-X] |
| Website Clicks | [X] | [X] | [+/-X] |

## Highlights

🌟 [Notable win, viral post, positive feedback, etc.]

## Next Week Plan

- [ ] [Priority 1]
- [ ] [Priority 2]
- [ ] [Priority 3]

## Notes / Blockers

[Anything Jeremy or the client needs to address]

---

*Questions? Reply to this report or text me anytime.*
*— {{your_name}}, {{your_company}}*
```

---

### EMAIL — Testimonial Request

---

#### Template: `testimonial-request`
**Name:** Testimonial Request Email
**Category:** email / testimonial
**Tags:** testimonial, review, social-proof, feedback
**Variables:** client_name, client_first_name, company, your_name, your_company, service_type, result

```
Subject: Quick favor? 🙏

Hey {{client_first_name}},

I hope you've been loving the work we've been doing together! It's been awesome helping {{company}} with {{service_type}} and seeing {{result}}.

I have a small favor to ask — would you be open to writing a quick testimonial about your experience working with me? Nothing fancy, just a few sentences about:

• What it's been like working with {{your_company}}
• Any results or improvements you've noticed
• Whether you'd recommend us to others

It would mean the world to me and helps other businesses feel confident about working together. If you're up for it, you can just reply to this email with a few lines — or I can send you a quick form if that's easier.

Totally understand if you're too busy — no pressure at all!

Thanks for being such a great client,
{{your_name}}
{{your_company}}
```

---

### EMAIL — Partnership Inquiry

---

#### Template: `partnership-inquiry`
**Name:** Partnership / Collaboration Inquiry
**Category:** email / partnership
**Tags:** partnership, collaboration, B2B, networking
**Variables:** client_name, company, your_name, your_company, service_type, cta

```
Subject: Potential collaboration between {{your_company}} + {{company}}?

Hey {{client_name}},

I'm {{your_name}}, founder of {{your_company}} — we specialize in {{service_type}} for businesses looking to level up their content and online presence.

I've been following {{company}} for a while and really respect what you're building. I think there's a natural synergy between what we both do, and I wanted to reach out about a potential collaboration.

Here's what I had in mind:
• **Cross-promotion** — Feature each other to our respective audiences
• **Bundled services** — Offer complementary packages to each other's clients
• **Content collaboration** — Create joint content that showcases both brands

I think this could be a win-win that brings value to both our audiences. No strings attached — just exploring the idea.

{{cta}}

Would love to hear your thoughts!

Best,
{{your_name}}
{{your_company}}
```

---

### EMAIL — Rate Increase Notice

---

#### Template: `rate-increase`
**Name:** Rate Increase Notice
**Category:** email / rate-increase
**Tags:** rate, pricing, increase, notice, existing-client
**Variables:** client_name, client_first_name, company, your_name, your_company, service_type, price, date

```
Subject: A note about our pricing starting {{date}}

Hey {{client_first_name}},

I wanted to reach out personally because I value our working relationship and believe in being upfront and transparent.

Starting {{date}}, I'll be adjusting my rates for {{service_type}}. Your new rate will be {{price}}.

**Why the change?**
Over the past year, I've invested heavily in upgrading my skills, tools, and processes to deliver even better results. The quality of work you're receiving has grown significantly, and this adjustment reflects that.

**What this means for you:**
• The same (or better) quality you've come to expect
• Priority scheduling and faster turnaround
• Access to new services and capabilities I've added
• Everything else stays the same — same communication, same dedication

This new rate takes effect on {{date}}, giving you plenty of time to adjust. Your current rate will be honored through the end of this billing cycle.

I truly love working with {{company}} and hope to continue doing so. If you have any questions or want to discuss this further, I'm always available.

Thank you for your continued trust and partnership,
{{your_name}}
{{your_company}}
```

---

## Registry File

Create `templates/registry.json` with the following content on first use or when initializing:

```json
{
  "version": "1.0",
  "lastUpdated": "2026-02-15",
  "templates": [
    {
      "id": "cold-outreach-restaurant",
      "name": "Cold Outreach — Restaurant",
      "category": "email",
      "subcategory": "cold-outreach",
      "platform": null,
      "tags": ["cold", "outreach", "restaurant", "food", "hospitality"],
      "variables": ["client_name", "company", "your_name", "your_company", "cta", "result"],
      "description": "Cold email targeting restaurant owners for content/social media services."
    },
    {
      "id": "cold-outreach-fitness",
      "name": "Cold Outreach — Fitness / Personal Trainer",
      "category": "email",
      "subcategory": "cold-outreach",
      "platform": null,
      "tags": ["cold", "outreach", "fitness", "gym", "trainer", "health"],
      "variables": ["client_name", "company", "your_name", "your_company", "result", "cta"],
      "description": "Cold email targeting fitness pros and gym owners."
    },
    {
      "id": "cold-outreach-real-estate",
      "name": "Cold Outreach — Real Estate Agent",
      "category": "email",
      "subcategory": "cold-outreach",
      "platform": null,
      "tags": ["cold", "outreach", "real estate", "realtor", "property"],
      "variables": ["client_name", "company", "your_name", "your_company", "result", "cta"],
      "description": "Cold email targeting real estate agents for content/branding services."
    },
    {
      "id": "follow-up-gentle",
      "name": "Gentle Follow-Up",
      "category": "email",
      "subcategory": "follow-up",
      "platform": null,
      "tags": ["follow-up", "gentle", "reminder", "warm"],
      "variables": ["client_name", "company", "your_name", "your_company", "service_type"],
      "description": "Friendly follow-up email after no response to initial outreach."
    },
    {
      "id": "follow-up-breakup",
      "name": "Break-Up Email (Final Follow-Up)",
      "category": "email",
      "subcategory": "follow-up",
      "platform": null,
      "tags": ["follow-up", "breakup", "final", "last-chance"],
      "variables": ["client_name", "company", "your_name", "your_company", "service_type"],
      "description": "Final follow-up that gracefully closes the loop."
    },
    {
      "id": "welcome-email",
      "name": "Welcome Email — New Client",
      "category": "email",
      "subcategory": "welcome",
      "platform": null,
      "tags": ["welcome", "onboarding", "new-client"],
      "variables": ["client_name", "client_first_name", "company", "your_name", "your_company", "service_type", "deliverables"],
      "description": "Welcome email sent after a new client signs on."
    },
    {
      "id": "invoice-reminder",
      "name": "Invoice Payment Reminder",
      "category": "email",
      "subcategory": "invoice",
      "platform": null,
      "tags": ["invoice", "payment", "reminder", "billing"],
      "variables": ["client_name", "client_first_name", "company", "your_name", "your_company", "invoice_number", "amount_due", "due_date"],
      "description": "Friendly payment reminder for outstanding invoices."
    },
    {
      "id": "caption-promo",
      "name": "Social Media Caption — Promo/Service Highlight",
      "category": "caption",
      "subcategory": "promo",
      "platform": "Instagram, TikTok, X",
      "tags": ["caption", "social", "promo", "service", "instagram", "tiktok"],
      "variables": ["company", "service_type", "result", "cta", "pain_point", "niche"],
      "description": "Promotional caption template with platform-specific versions."
    },
    {
      "id": "caption-value",
      "name": "Social Media Caption — Value Post / Tips",
      "category": "caption",
      "subcategory": "value",
      "platform": "Instagram, TikTok, YouTube",
      "tags": ["caption", "social", "value", "tips", "educational"],
      "variables": ["company", "niche", "your_name"],
      "description": "Educational/value-driven caption with tips format."
    },
    {
      "id": "proposal-email",
      "name": "Proposal Cover Email",
      "category": "email",
      "subcategory": "proposal",
      "platform": null,
      "tags": ["proposal", "pitch", "formal", "service"],
      "variables": ["client_name", "client_first_name", "company", "your_name", "your_company", "service_type", "price"],
      "description": "Email to accompany a formal proposal document."
    },
    {
      "id": "project-brief",
      "name": "Project Brief Template",
      "category": "brief",
      "subcategory": "project",
      "platform": null,
      "tags": ["brief", "project", "planning", "scope", "creative"],
      "variables": ["client_name", "company", "project_name", "service_type", "deliverables", "timeline", "date"],
      "description": "Structured project brief for scoping new work."
    },
    {
      "id": "weekly-report",
      "name": "Weekly Report Template",
      "category": "report",
      "subcategory": "weekly",
      "platform": null,
      "tags": ["report", "weekly", "analytics", "progress", "update"],
      "variables": ["client_name", "company", "your_name", "your_company", "date", "project_name"],
      "description": "Weekly progress report with metrics and status updates."
    },
    {
      "id": "testimonial-request",
      "name": "Testimonial Request Email",
      "category": "email",
      "subcategory": "testimonial",
      "platform": null,
      "tags": ["testimonial", "review", "social-proof", "feedback"],
      "variables": ["client_name", "client_first_name", "company", "your_name", "your_company", "service_type", "result"],
      "description": "Email requesting a testimonial from a happy client."
    },
    {
      "id": "partnership-inquiry",
      "name": "Partnership / Collaboration Inquiry",
      "category": "email",
      "subcategory": "partnership",
      "platform": null,
      "tags": ["partnership", "collaboration", "B2B", "networking"],
      "variables": ["client_name", "company", "your_name", "your_company", "service_type", "cta"],
      "description": "Outreach email proposing a business collaboration."
    },
    {
      "id": "rate-increase",
      "name": "Rate Increase Notice",
      "category": "email",
      "subcategory": "rate-increase",
      "platform": null,
      "tags": ["rate", "pricing", "increase", "notice", "existing-client"],
      "variables": ["client_name", "client_first_name", "company", "your_name", "your_company", "service_type", "price", "date"],
      "description": "Professional notice to existing clients about a rate increase."
    }
  ]
}
```

## Execution Checklist

### Using a Template
1. ☐ Identify template from request (match by name, category, keywords, or ID)
2. ☐ Read template from this SKILL.md
3. ☐ Collect variable values from context / conversation
4. ☐ Substitute all `{{variables}}`
5. ☐ Output clean, ready-to-use text
6. ☐ Ask if any adjustments needed

### Saving a New Template
1. ☐ Get template content and name from Jeremy
2. ☐ Generate slug ID
3. ☐ Identify category, subcategory, platform, tags
4. ☐ Extract and parameterize variables
5. ☐ Read current `templates/registry.json`
6. ☐ Append new template entry
7. ☐ Write updated registry
8. ☐ Confirm with summary

### Listing Templates
1. ☐ Read `templates/registry.json`
2. ☐ Apply filters (category, platform, tag, search)
3. ☐ Format as clean list
4. ☐ Display to Jeremy
