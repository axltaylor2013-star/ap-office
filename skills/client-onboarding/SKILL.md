---
name: client-onboarding
description: Auto-generate everything needed when a new client is landed — project folder structure, contract, invoice template, welcome email, and Telegram notification. Use when Jeremy says he landed a new client or asks to onboard someone. Accepts client name, service type, rate, and project description.
---

# Client Onboarding

## Quick Reference

| Parameter | Required | Example |
|-----------|----------|---------|
| Client Name | ✅ | "Sarah Mitchell" |
| Service Type | ✅ | photo-editing, video-editing, social-media, full-package |
| Rate | ✅ | "$500/month" or "$75/hour" |
| Project Description | ✅ | "Monthly product photo editing for e-commerce store" |
| Client Email | Optional | "sarah@example.com" |
| Start Date | Optional | Defaults to today |

## Service Types

| Type | Slug | Typical Deliverables |
|------|------|---------------------|
| Photo Editing | `photo-editing` | Retouching, color grading, composites, batch processing |
| Video Editing | `video-editing` | Cuts, transitions, color grade, audio mix, exports |
| Social Media Management | `social-media` | Content calendar, post creation, scheduling, analytics |
| Full Package | `full-package` | All of the above + strategy calls |

## Workflow

When triggered, create the following under `clients/<client-slug>/`:

### 1. Folder Structure

```
clients/
  <client-slug>/
    README.md              ← Project overview & quick reference
    contract.md            ← Service agreement
    invoice-template.md    ← Reusable invoice
    welcome-email.md       ← Draft email to send
    briefs/                ← Incoming project briefs
    deliverables/          ← Completed work
    assets/                ← Raw files, logos, brand kits from client
    notes/                 ← Meeting notes, feedback
```

### 2. README.md Template

```markdown
# {Client Name} — {Service Type}

**Status:** 🟢 Active
**Start Date:** {date}
**Rate:** {rate}
**Contact:** {email}

## Project Description

{description}

## Key Links

- Contract: [contract.md](./contract.md)
- Invoice Template: [invoice-template.md](./invoice-template.md)

## Notes

- Onboarded on {date}
```

### 3. Contract Template

```markdown
# Service Agreement

**Between:** Kermicle Media ("Provider")
**And:** {Client Name} ("Client")
**Effective Date:** {date}

---

## 1. Services

The Provider agrees to deliver the following services:

**Service Type:** {Service Type Title}

{description}

### Deliverables
<!-- Auto-filled based on service type -->

**For photo-editing:**
- Professional photo retouching and color grading
- Batch processing of up to [X] images per month
- 2 rounds of revisions per batch
- Delivery in requested formats (JPEG, PNG, TIFF, PSD)

**For video-editing:**
- Professional video editing including cuts, transitions, and pacing
- Color grading and audio mixing
- Up to [X] minutes of finished video per month
- 2 rounds of revisions per project
- Export in requested formats and resolutions

**For social-media:**
- Content calendar creation (monthly)
- [X] posts per week across agreed platforms
- Graphic/video creation for posts
- Caption writing and hashtag strategy
- Monthly analytics report

**For full-package:**
- All photo editing, video editing, and social media services above
- Monthly strategy call (30 min)
- Priority turnaround

## 2. Compensation

**Rate:** {rate}
**Payment Terms:** Net 15 — invoice sent on the 1st of each month
**Payment Method:** Zelle, PayPal, or bank transfer

## 3. Revisions

- Included revisions per deliverable: 2
- Additional revisions billed at $50/hour

## 4. Ownership & Usage

- Client receives full usage rights to all deliverables upon payment
- Provider retains the right to display work in portfolio (unless NDA is signed)

## 5. Termination

Either party may terminate with 14 days written notice. Outstanding invoices remain due.

## 6. Signatures

**Provider:** Jeremy Kermicle, Kermicle Media
Date: _______________

**Client:** {Client Name}
Date: _______________
```

### 4. Invoice Template

```markdown
# INVOICE

**From:** Kermicle Media
**To:** {Client Name}
**Invoice #:** KM-{YYYYMM}-001
**Date:** {date}
**Due Date:** {date + 15 days}

---

| Description | Qty | Rate | Amount |
|-------------|-----|------|--------|
| {Service Type Title} — {month} | 1 | {rate} | {amount} |
| | | | |
| | | **Total:** | **{amount}** |

---

**Payment Methods:**
- Zelle: [Jeremy's Zelle]
- PayPal: [Jeremy's PayPal]
- Bank Transfer: Available on request

**Terms:** Net 15. Late payments subject to 1.5% monthly fee.

Thank you for your business! 🙏
— Kermicle Media
```

### 5. Welcome Email Draft

```markdown
# Welcome Email Draft

**To:** {Client Email}
**Subject:** Welcome to Kermicle Media! 🎬

---

Hey {Client First Name}!

Welcome aboard — I'm excited to work with you!

Here's what happens next:

1. **Contract** — I've attached our service agreement. Give it a look and let me know if you have any questions.

2. **Onboarding** — Send over any brand assets, style guides, or examples of what you're going for. You can drop files in our shared folder or email them directly.

3. **First Brief** — Once I have your materials, send me your first project brief and I'll get started!

**What to expect:**
- {service-specific turnaround expectations}
- I'll keep you updated on progress
- 2 rounds of revisions included per deliverable
- Reach me anytime via email or text

Looking forward to creating some great stuff together!

Best,
Jeremy Kermicle
Kermicle Media
kermiclemedia.com
```

### 6. Telegram Notification

After creating all files, send a Telegram message to Jeremy:

```
🎉 New client onboarded!

👤 {Client Name}
📋 {Service Type}
💰 {Rate}
📝 {Description (truncated)}

✅ Created: folder structure, contract, invoice template, welcome email
📂 clients/{client-slug}/
```

## Execution Checklist

1. ☐ Parse client details (name, service, rate, description)
2. ☐ Generate slug from client name (lowercase, hyphens)
3. ☐ Create folder structure under `clients/<slug>/`
4. ☐ Fill and write README.md
5. ☐ Fill and write contract.md (use correct service type section)
6. ☐ Fill and write invoice-template.md
7. ☐ Fill and write welcome-email.md
8. ☐ Create empty `briefs/`, `deliverables/`, `assets/`, `notes/` folders (use .gitkeep)
9. ☐ Send Telegram notification
10. ☐ Confirm completion to Jeremy

## Example Usage

> "Hey, I just landed a new client — Sarah Mitchell. She needs video editing, $800/month. She runs a fitness YouTube channel and needs weekly video edits, color grading, and thumbnails."

This triggers full onboarding with service type `video-editing`, rate `$800/month`, and all templates populated accordingly.
