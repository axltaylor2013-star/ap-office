---
name: social-media-autopilot
description: Generate platform-specific social media posts from a single content brief. Outputs formatted posts for Instagram Reels, TikTok, YouTube, and X/Twitter with captions, hashtags, posting times, and CTA variations. Use when Jeremy needs to promote content, services, or portfolio pieces across platforms.
---

# Social Media Autopilot

## Quick Reference

| Platform | Character Limit | Hashtag Strategy | Best Posting Times (EST) |
|----------|----------------|------------------|--------------------------|
| Instagram Reels | 2,200 caption | 20-30 relevant, mix of sizes | Tue/Wed/Thu 11am-1pm, 7-9pm |
| TikTok | 4,000 caption | 3-5 targeted | Tue/Thu 10am-12pm, 7-9pm |
| YouTube | 5,000 description | 3-5 in description, tags separate | Fri/Sat 2-4pm, Sun 9-11am |
| X/Twitter | 280 characters | 2-3 max | Mon-Fri 8-10am, 12-1pm |

## Input Parameters

| Parameter | Required | Example |
|-----------|----------|---------|
| Topic/Brief | ✅ | "Before/after of a real estate photo edit showing HDR enhancement" |
| Content Type | Optional | promo, tutorial, behind-the-scenes, testimonial, transformation |
| Target Audience | Optional | "real estate agents", "content creators", "small business owners" |
| CTA Goal | Optional | followers, website, DMs, bookings |
| Media Notes | Optional | "vertical video, 15 sec, quick transitions" |

## Output Format

Generate a structured markdown file saved to `content/social-posts/{YYYY-MM-DD}-{slug}.md`:

````markdown
# Social Media Posts: {Topic}

**Generated:** {date}
**Content Type:** {type}
**Brief:** {original brief}

---

## 📸 Instagram Reels

### Caption
{Hook line — first 125 chars are critical, this shows before "...more"}

{Body — storytelling, value, or transformation narrative}

{CTA line}

### Hashtags
{20-30 hashtags in 3 tiers}

**Tier 1 — Niche (10K-100K posts):**
#photoediting #beforeandafteredit #realestatephotography

**Tier 2 — Mid-range (100K-500K):**
#editingskills #photoshoptips #lightroompresets

**Tier 3 — Broad (500K+):**
#photography #editing #creative

### Posting
- **Best time:** {specific recommendation}
- **Reel length:** 15-30 sec recommended
- **Cover image:** Use the "after" as cover with text overlay
- **Audio:** Trending audio or original

---

## 🎵 TikTok

### Caption
{Short, punchy hook — TikTok rewards brevity}

{Brief context}

### Hashtags
#beforeandafter #photoediting #editingtransformation #fyp #kermiclemedia

### Posting
- **Best time:** {specific recommendation}
- **Video style:** Quick reveal, satisfying transition
- **Hook (first 1-2 sec):** "{attention-grabbing text overlay}"
- **Trending sound:** Search for trending transition sounds
- **Text overlays:** "POV: You hired a professional editor" / "Wait for it..."

---

## 🎬 YouTube

### Title
{SEO-optimized title, 60 chars max}

### Description
{First 2 lines — these show in search, front-load keywords}

{Paragraph with context, process description, value}

🔗 Links:
- Website: https://kermiclemedia.com
- Instagram: @kermiclemedia
- Book a consultation: [link]

⏱️ Timestamps:
- 0:00 - {Intro/Hook}
- 0:XX - {Section}
- 0:XX - {Section}
- 0:XX - {Final result}

### Tags
photo editing, before and after, {category-specific tags}, kermicle media, jeremy kermicle

### Posting
- **Best time:** {specific recommendation}
- **Thumbnail:** Before/after split, bold text, surprised expression or arrow
- **End screen:** Subscribe CTA + related video
- **Cards:** Link to portfolio/services at transformation reveal

---

## 🐦 X / Twitter

### Post (Thread)

**Tweet 1 (Main — 280 chars max):**
{Hook + transformation tease}

{CTA or link}

**Tweet 2 (Reply — optional):**
{Process breakdown or behind-the-scenes detail}

**Tweet 3 (Reply — optional):**
{CTA — "DM me for rates" or "Link in bio"}

### Hashtags
#PhotoEditing #KermicleMedia

### Posting
- **Best time:** {specific recommendation}
- **Media:** Attach before/after side-by-side image
- **Engagement bait:** "Which do you prefer? 1 or 2?" or "Rate this edit 1-10"

---

## 🔄 CTA Variations

Use these interchangeably across platforms:

| Style | CTA |
|-------|-----|
| Direct | "DM me 'EDIT' to get started" |
| Soft | "Follow for more transformations ✨" |
| Urgency | "Only taking 3 new clients this month — link in bio" |
| Social Proof | "Join 50+ clients who leveled up their content" |
| Question | "Want this for your brand? Drop a 🔥 below" |
| Value | "Save this for your next project" |

---

## 📅 Suggested Posting Schedule

| Day | Platform | Time (EST) |
|-----|----------|------------|
| {Day 1} | Instagram Reels | {time} |
| {Day 1} | TikTok | {time} |
| {Day 2} | X/Twitter | {time} |
| {Day 3} | YouTube | {time} |

*Stagger posts 1-2 days apart for maximum reach without audience fatigue.*
````

## Content Type Templates

### 🔄 Transformation / Before-After
- **Hook formula:** "You won't believe this is the same [photo/video]"
- **Structure:** Tease → Reveal → CTA
- **Best for:** Instagram Reels, TikTok

### 📚 Tutorial / Tips
- **Hook formula:** "Stop doing [X]. Do this instead."
- **Structure:** Problem → Solution → Result → CTA
- **Best for:** YouTube, Instagram Reels

### 🎬 Behind-the-Scenes
- **Hook formula:** "Here's how I [process] in [time]"
- **Structure:** Setup → Process → Result
- **Best for:** TikTok, Instagram Stories

### ⭐ Testimonial / Social Proof
- **Hook formula:** "My client's reaction when they saw the final edit"
- **Structure:** Context → Testimonial → CTA
- **Best for:** Instagram, X/Twitter

### 📢 Promo / Service Push
- **Hook formula:** "Your [content type] could look like this"
- **Structure:** Pain point → Solution → Offer → CTA
- **Best for:** All platforms

## Brand Voice Guidelines

- **Tone:** Confident but approachable, professional but not stiff
- **Personality:** Creative, tech-savvy, results-focused
- **Avoid:** Overly salesy language, clickbait that doesn't deliver
- **Emojis:** Use sparingly — 2-4 per Instagram caption, 1-2 on Twitter, minimal on YouTube
- **Brand mentions:** Always tag @kermiclemedia, use #KermicleMedia

## Workflow

1. Receive content brief / topic from Jeremy
2. Determine content type and target audience
3. Generate all 4 platform posts using the output template
4. Save to `content/social-posts/{date}-{slug}.md`
5. Notify Jeremy the posts are ready

## Example Usage

> "Make posts about this real estate photo edit I just finished — dramatic HDR enhancement, turned a dark listing into a bright, inviting home. Target real estate agents."

Generates complete posts for all 4 platforms, tailored for real estate audience, with transformation hooks and agent-focused CTAs.
