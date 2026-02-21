---
name: kermicle-web-builder
description: Build web pages and apps for the Kermicle Media brand. Use when creating dashboard pages, web tools, or any HTML/CSS/JS for Kermicle Media. Enforces brand colors (dark theme with gold accents), responsive design, and dashboard integration via hub.html tabs.
---

# Kermicle Web Builder

## Quick Reference

| Token | Value |
|-------|-------|
| Background | `#0d0d0d` (body), `#1a1a1a` (cards/panels) |
| Accent/Gold | `#d4a843` |
| Text | `#e0e0e0` |
| Font | `Segoe UI, system-ui, sans-serif` |

## Build Rules

1. **All new apps go in `dashboard/`** as their own folder or HTML file.
2. **Add a tab in `hub.html`** for every new app — link it in the nav.
3. **Mobile responsive required** — use flexbox/grid, test at 375px+.
4. **Dark backgrounds, gold accents** — buttons, links, borders use `#d4a843`.
5. **Hover glow effects** — use `box-shadow: 0 0 15px rgba(212,168,67,0.3)` on hover.
6. **Rounded corners** — `border-radius: 12px` on cards/panels.
7. **No external CDNs** unless explicitly requested. Keep it self-contained.

## Workflow

1. Copy boilerplate from `assets/boilerplate.html`
2. Customize content and functionality
3. Save to `dashboard/<app-name>/index.html`
4. Add nav tab in `hub.html`
5. Test responsive at multiple widths

## Resources

- **Full brand specs**: See `references/brand-guide.md`
- **HTML boilerplate**: Copy from `assets/boilerplate.html`
