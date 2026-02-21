---
name: client-crm
description: JSON-based client relationship manager at clients/crm.json. Track clients, projects, invoices, and follow-ups for Kermicle Media. Pairs with client-onboarding skill.
---

# Client CRM

## Data Location

`clients/crm.json`

## JSON Schema

```json
{
  "clients": [
    {
      "id": 1,
      "name": "Business Name",
      "contact": {
        "person": "Contact Name",
        "email": "email@example.com",
        "phone": "555-0100",
        "preferred": "email"
      },
      "services": ["photo-editing", "video-editing", "ai-headshots", "social-media-content"],
      "projects": [
        {
          "name": "Project Name",
          "service": "video-editing",
          "date": "2026-02-15",
          "amount": 500,
          "status": "completed",
          "notes": ""
        }
      ],
      "invoices": [
        {
          "id": "INV-001",
          "project": "Project Name",
          "amount": 500,
          "issued": "2026-02-15",
          "due": "2026-03-01",
          "status": "unpaid",
          "paidDate": null
        }
      ],
      "followUp": "2026-02-20",
      "notes": "Found via Instagram DM. Prefers quick turnarounds.",
      "tags": ["restaurant", "recurring"],
      "added": "2026-02-15",
      "lastContact": "2026-02-15"
    }
  ]
}
```

## Service Types

Standard Kermicle Media services:
- `photo-editing` — Photo retouching, color grading
- `video-editing` — Video production, editing, reels
- `ai-headshots` — AI-generated professional headshots
- `ai-tools` — Custom AI automations, chatbots
- `social-media-content` — Content creation packages
- `branding` — Logo, brand kit, visual identity
- `website` — Web design/development

## Commands

### Add Client

1. Read `clients/crm.json` (create if missing with `{"clients": []}`)
2. Assign `id = max(existing ids) + 1`
3. Fill all fields; set `added` and `lastContact` to today
4. Write back

**Example prompt:** "Add client: Bella's Bistro, contact Maria Lopez, maria@bellasbistro.com, 555-0199, services: photo-editing, video-editing"

### Update Client

1. Read CRM, find client by name or ID
2. Update specified fields, set `lastContact` to today
3. Write back

**Example:** "Update Bella's Bistro phone to 555-0200"

### List Clients

Read and display clients. Support filters:
- By service: "list clients using ai-headshots"
- By invoice status: "list clients with overdue invoices"
- By tag: "list restaurant clients"
- All: "list all clients"

Format as a clean summary table or bullet list depending on platform.

### Log Project

1. Find client by name/ID
2. Append to their `projects` array
3. Auto-create an invoice entry with status `unpaid`
4. Set `due` date to 15 days from issued date
5. Invoice ID format: `INV-{3-digit sequential}`
6. Update `lastContact` to today

**Example:** "Log project for Bella's Bistro: Valentine's Day Reel, video-editing, $750"

### Mark Invoice Paid

1. Find client, find invoice by ID or project name
2. Set `status` to `paid`, `paidDate` to today
3. Write back

**Example:** "Mark INV-003 as paid"

### Due Follow-ups

List all clients where `followUp` date is today or past. Include:
- Client name, last contact date, follow-up date, notes
- Any overdue invoices for that client

### Weekly Summary

Generate a summary covering:
1. **Overdue invoices** — Any invoice where `due` < today and `status` = `unpaid`
2. **Due follow-ups** — Clients needing contact this week
3. **Recent projects** — Projects logged in the last 7 days
4. **Revenue snapshot** — Total invoiced, total paid, total outstanding

## Invoice Status Rules

- `unpaid` — Issued, not yet due or just due
- `overdue` — Past due date and unpaid. Auto-flag when checking: if `status` = `unpaid` and `due` < today, treat as overdue and update status to `overdue`
- `paid` — Payment received

## Integration

- **client-onboarding**: When onboarding completes, auto-add client to CRM
- **revenue-dashboard**: Invoice payment data feeds into revenue tracking
- **email-outreach**: Contacts who convert get added here

## Rules

1. **Always validate JSON** before writing back
2. **Never delete clients** — mark inactive with tag `inactive` instead
3. **Update `lastContact`** on every interaction
4. **Auto-increment IDs** — read existing, find max, add 1
5. **Dates in ISO format** — `YYYY-MM-DD`
