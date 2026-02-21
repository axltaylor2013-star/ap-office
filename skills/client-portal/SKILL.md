---
name: client-portal
description: Generate branded client-facing status portals for Kermicle Media. Creates standalone HTML pages per client showing project progress, deliverables, activity feed, and contact info. Dark theme with gold accents. Deploy anywhere (GitHub Pages, Netlify, etc). Use when asked to create, update, or manage client portals.
---

# Client Portal Builder

## Quick Reference

| Token | Value |
|-------|-------|
| Body BG | `#0b0e14` |
| Card BG | `#131720` |
| Card Border | `#1c2030` |
| Gold Accent | `#d4a843` |
| Gold Hover | `#e6bc5a` |
| Green (done) | `#2ecc71` |
| Gray (upcoming) | `#3a3f4c` |
| Text Primary | `#e8e8e8` |
| Text Muted | `#8a8f9c` |
| Font | `'Segoe UI', system-ui, -apple-system, sans-serif` |

## Output Location

All portals go to: `portals/{client-slug}/index.html`
Registry at: `portals/registry.json`

## Workflow

### Create a New Portal

Trigger: "Create portal for [Client Name] — [Project Name]"

1. Generate slug from client name (lowercase, hyphens, no special chars)
2. Determine service template (video / photo / reels / full-package / generic)
3. Build `portals/{slug}/index.html` using the HTML template below
4. Add entry to `portals/registry.json`
5. Confirm with portal path and summary

### Update Portal Phase

Trigger: "Update [client] portal: move to [Phase Name]"

1. Read current `portals/{slug}/index.html`
2. Update the phase data in the embedded JSON config
3. Update `registry.json` with new phase and `lastUpdated`
4. Confirm change

### Add Deliverable

Trigger: "Add deliverable to [client] portal: '[name]' — status: [status]"

Statuses: `pending` | `in-progress` | `ready` | `delivered`

1. Read portal HTML
2. Add deliverable to the embedded config
3. Save and confirm

### Add Activity Update

Trigger: "Add update to [client] portal: '[message]'"

1. Read portal HTML
2. Prepend new activity entry with today's date
3. Save and confirm

### List All Portals

Trigger: "List all portals" / "Show portals"

Read and display `portals/registry.json`

## Service Templates

### Video Editing
Phases: `Footage Review` → `Editing` → `Color Grade` → `Sound Design` → `Delivered`
Default deliverables: Final Cut, Behind-the-Scenes, Thumbnail

### Photo Editing
Phases: `Selection` → `Editing` → `Retouching` → `Delivered`
Default deliverables: Edited Photos, Web-Optimized Set, Print-Ready Files

### Reels Package
Phases: `Strategy` → `Filming Guide` → `Editing` → `Delivery Schedule`
Default deliverables: Reel #1, Reel #2, Reel #3, Content Calendar

### Full Package
Phases: `Discovery` → `Content Strategy` → `Production` → `Post-Production` → `Review` → `Delivered`
Default deliverables: Video Package, Photo Set, Reels Bundle, Brand Assets

### Generic (Default)
Phases: `Discovery` → `In Progress` → `Review` → `Revisions` → `Delivered`

## Portal HTML Structure

Every portal is a single self-contained HTML file with:

- **Embedded config JSON** in a `<script id="portal-config" type="application/json">` block
- All CSS inline in `<style>` tags
- All JS inline in `<script>` tags
- No external dependencies whatsoever

### Config Schema

```json
{
  "client": "Client Name",
  "project": "Project Title",
  "service": "video-editing",
  "package": "Premium",
  "startDate": "2026-02-10",
  "estCompletion": "2026-03-15",
  "phases": ["Footage Review", "Editing", "Color Grade", "Sound Design", "Delivered"],
  "currentPhase": 1,
  "deliverables": [
    { "name": "Final Cut", "status": "in-progress" },
    { "name": "Thumbnail", "status": "pending" }
  ],
  "activity": [
    { "date": "2026-02-15", "text": "First draft delivered for review" },
    { "date": "2026-02-10", "text": "Project started" }
  ],
  "password": null
}
```

### Updating Portals Programmatically

To update a portal, edit the JSON inside `<script id="portal-config">`. The JS reads this config on load and renders everything dynamically. This means:

- Phase changes = update `currentPhase` index
- New deliverables = append to `deliverables` array
- New activity = prepend to `activity` array
- All rendering happens client-side from this single config block

## Password Protection

When `password` is set in config (not null), the portal shows a password gate overlay before revealing content. This is **cosmetic obfuscation only** — not real security. The content is still in the HTML source. Good enough to prevent casual snooping.

## Design Rules

1. **Dark backgrounds, gold accents** — consistent with Kermicle brand
2. **Cards have subtle borders** — `1px solid #1c2030`, `border-radius: 16px`
3. **Hover effects** — gold glow: `box-shadow: 0 0 20px rgba(212,168,67,0.15)`
4. **Animations** — fade-in on load, progress bar fill, phase pulse
5. **Mobile first** — works perfectly at 360px+, tested responsive
6. **Print stylesheet** — clean B&W version for invoicing
7. **Countdown timer** — live countdown to estimated completion
8. **No external fonts/CDNs/deps** — everything inline

## Sample Portal

A working demo lives at `portals/sample/index.html` — use it as visual reference and copy its HTML structure for new portals.

## Registry Schema (portals/registry.json)

```json
{
  "portals": [
    {
      "client": "Sample Client",
      "slug": "sample",
      "project": "Brand Video Package",
      "service": "video-editing",
      "currentPhase": "Editing",
      "created": "2026-02-15",
      "lastUpdated": "2026-02-15",
      "url": "portals/sample/index.html"
    }
  ]
}
```
