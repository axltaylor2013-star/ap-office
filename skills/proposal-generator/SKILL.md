---
name: proposal-generator
description: Generate gorgeous, branded client proposals for Kermicle Media. Input client name, service type, scope, price, and timeline to produce a premium standalone HTML proposal. Supports pre-built service templates for Reels Package, Video Editing, Photo Editing, Social Media Management, Full Package, and AI Setup. Output goes to proposals/{client-slug}/proposal.html with a registry at proposals/registry.json.
---

# Proposal Generator

## Quick Reference

| Parameter | Required | Example |
|-----------|----------|---------|
| Client Name | ✅ | "Bella's Boutique" |
| Service Type | ✅ | reels, video-editing, photo-editing, social-media, full-package, ai-setup |
| Price | ✅ | "$1,500/month" or "$3,000 one-time" |
| Scope Description | Optional | Custom scope (defaults to service template) |
| Timeline | Optional | "4 weeks" (defaults to service template) |
| Special Requirements | Optional | "Rush delivery needed", "Bilingual captions" |

## Service Templates

### Reels Package (`reels`)

**Scope of Work:**
- Professional short-form video production (Instagram Reels, TikTok, YouTube Shorts)
- Content strategy and concept development for each reel
- On-location or remote video capture coordination
- Professional editing with transitions, text overlays, and branded elements
- Trending audio selection and integration
- Caption writing with hashtag strategy
- Platform-optimized exports (9:16 vertical, multiple formats)

**Deliverables:**
- 8-12 professionally edited reels per month
- Content calendar with posting schedule
- Caption copy for each reel
- Monthly performance analytics report
- 2 rounds of revisions per reel

**Timeline:**
- Week 1: Strategy session + content calendar creation
- Week 2-3: Content production and editing
- Week 4: Review, revisions, and scheduling
- Ongoing monthly cycle

---

### Video Editing (`video-editing`)

**Scope of Work:**
- Professional video editing for long-form and short-form content
- Color grading and color correction
- Audio mixing, cleanup, and enhancement
- Motion graphics and text animations
- Transitions, pacing, and narrative flow optimization
- Thumbnail design for YouTube content
- Multi-format exports for various platforms

**Deliverables:**
- Up to 8 fully edited videos per month (up to 15 min each)
- Color grading applied to all footage
- Audio enhancement and mixing
- Custom thumbnails for each video
- Source project files upon request
- 2 rounds of revisions per video

**Timeline:**
- Week 1: Receive raw footage + creative brief
- Week 2: First draft delivery
- Week 3: Revisions and final polish
- Week 4: Final delivery + next batch prep

---

### Photo Editing (`photo-editing`)

**Scope of Work:**
- Professional photo retouching and enhancement
- Color grading for brand consistency
- Background removal and replacement
- Product photo optimization for e-commerce
- Batch processing with consistent style application
- Social media format optimization
- Before/after documentation

**Deliverables:**
- Up to 50 professionally edited photos per month
- Consistent color grading across all images
- Multiple format exports (web, print, social)
- Brand-consistent preset development
- 1 round of revisions per batch

**Timeline:**
- Batch 1 delivery: 3-5 business days from receipt
- Revisions: 1-2 business days
- Ongoing monthly batches

---

### Social Media Management (`social-media`)

**Scope of Work:**
- Complete social media strategy development
- Content creation (graphics, captions, video clips)
- Content calendar planning and management
- Daily posting and scheduling across all platforms
- Community management (comments, DMs, engagement)
- Hashtag research and optimization
- Monthly analytics reporting and strategy adjustments
- Competitor analysis and trend monitoring

**Deliverables:**
- Custom social media strategy document
- 20-25 posts per month across platforms
- Daily story content (Instagram/Facebook)
- Monthly content calendar for approval
- Weekly engagement and community management
- Monthly performance report with insights
- Quarterly strategy review and optimization

**Timeline:**
- Week 1: Brand audit + strategy development
- Week 2: Content creation + calendar approval
- Week 3-4: Execution, posting, engagement
- Monthly cycle with quarterly deep-dive reviews

---

### Full Package (`full-package`)

**Scope of Work:**
- Comprehensive content and social media solution
- All Photo Editing services
- All Video Editing services
- All Social Media Management services
- All Reels Package services
- Brand strategy and creative direction
- Monthly strategy calls
- Priority support and expedited turnaround

**Deliverables:**
- Everything from Photo, Video, Social Media, and Reels packages
- Monthly 30-minute strategy call
- Priority 24-hour response time
- Dedicated project management
- Quarterly brand audit and recommendations
- Access to premium stock assets and music library

**Timeline:**
- Week 1: Comprehensive brand audit + strategy
- Week 2: Content creation sprint
- Week 3-4: Execution and optimization
- Ongoing with monthly strategy sessions

---

### AI Setup (`ai-setup`)

**Scope of Work:**
- Custom AI tool implementation for business workflow
- AI-powered content generation system setup
- Automated scheduling and posting pipeline
- Custom chatbot or auto-response configuration
- AI-assisted analytics and reporting dashboard
- Staff training on AI tools and best practices
- Documentation of all systems and workflows

**Deliverables:**
- Custom AI workflow documentation
- Configured and tested AI tools (ChatGPT, MidJourney, automation platforms)
- Automated content pipeline setup
- Custom prompt libraries for content generation
- Training session (1-2 hours) with recording
- 30-day post-setup support
- Operations manual for all systems

**Timeline:**
- Week 1: Audit current workflow + identify AI opportunities
- Week 2: Tool selection and initial configuration
- Week 3: Integration, testing, and refinement
- Week 4: Training session + documentation + handoff

---

## Proposal Registry

Maintain a registry at `proposals/registry.json`:

```json
{
  "proposals": [
    {
      "id": "bella-boutique-2026-02",
      "client": "Bella's Boutique",
      "slug": "bellas-boutique",
      "service": "social-media",
      "price": "$1,500/month",
      "date": "2026-02-15",
      "status": "sent",
      "file": "proposals/bellas-boutique/proposal.html"
    }
  ]
}
```

## proposal.html Template

Generate to `proposals/{client-slug}/proposal.html`. Replace all `{VARIABLES}`.

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Proposal for {CLIENT_NAME} — Kermicle Media</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;600;700;800&family=Inter:wght@300;400;500;600;700&family=Space+Grotesk:wght@400;500;600&display=swap');

        :root {
            --gold: #C8A24E;
            --gold-light: #E8D48A;
            --gold-dark: #A07D2E;
            --bg-primary: #0A0A0A;
            --bg-secondary: #111111;
            --bg-card: #161616;
            --bg-elevated: #1A1A1A;
            --text-primary: #F0EDE6;
            --text-secondary: rgba(240, 237, 230, 0.6);
            --text-muted: rgba(240, 237, 230, 0.35);
            --border: rgba(200, 162, 78, 0.12);
            --border-subtle: rgba(255, 255, 255, 0.06);
            --success: #2ECC40;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            line-height: 1.7;
            font-weight: 300;
            -webkit-font-smoothing: antialiased;
        }

        /* ===== COVER PAGE ===== */
        .cover {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            padding: 80px 40px;
            position: relative;
            overflow: hidden;
        }
        .cover::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background:
                radial-gradient(ellipse at 20% 50%, rgba(200, 162, 78, 0.08), transparent 60%),
                radial-gradient(ellipse at 80% 50%, rgba(200, 162, 78, 0.04), transparent 60%);
        }
        .cover::after {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 1px;
            background: linear-gradient(90deg, transparent, var(--gold), transparent);
            opacity: 0.3;
        }
        .cover-content { position: relative; z-index: 1; }
        .cover-logo {
            font-family: 'Playfair Display', serif;
            font-size: 1rem;
            letter-spacing: 6px;
            text-transform: uppercase;
            color: var(--gold);
            margin-bottom: 80px;
            font-weight: 600;
        }
        .cover-label {
            font-size: 0.7rem;
            letter-spacing: 5px;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 24px;
        }
        .cover h1 {
            font-family: 'Playfair Display', serif;
            font-size: clamp(3rem, 8vw, 6rem);
            font-weight: 800;
            line-height: 1.05;
            margin-bottom: 16px;
            background: linear-gradient(135deg, var(--gold-light) 0%, var(--gold) 50%, var(--gold-dark) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .cover-client {
            font-family: 'Playfair Display', serif;
            font-size: clamp(1.2rem, 3vw, 2rem);
            color: var(--text-secondary);
            font-weight: 400;
            font-style: italic;
            margin-bottom: 60px;
        }
        .cover-meta {
            display: flex;
            gap: 48px;
            justify-content: center;
            flex-wrap: wrap;
        }
        .cover-meta-item {
            text-align: center;
        }
        .cover-meta-label {
            font-size: 0.65rem;
            letter-spacing: 3px;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 6px;
        }
        .cover-meta-value {
            font-family: 'Space Grotesk', sans-serif;
            font-size: 0.95rem;
            color: var(--text-secondary);
            font-weight: 500;
        }
        .cover-divider {
            width: 60px;
            height: 1px;
            background: var(--gold);
            margin: 60px auto 0;
            opacity: 0.4;
        }

        /* ===== LAYOUT ===== */
        .container { max-width: 900px; margin: 0 auto; padding: 0 40px; }

        section {
            padding: 100px 0;
            position: relative;
        }
        section + section { border-top: 1px solid var(--border-subtle); }

        .section-number {
            font-family: 'Space Grotesk', sans-serif;
            font-size: 0.65rem;
            letter-spacing: 4px;
            text-transform: uppercase;
            color: var(--gold);
            margin-bottom: 12px;
            font-weight: 500;
        }
        .section-title {
            font-family: 'Playfair Display', serif;
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 16px;
            line-height: 1.2;
        }
        .section-intro {
            color: var(--text-secondary);
            font-size: 1.05rem;
            max-width: 650px;
            margin-bottom: 48px;
        }

        /* ===== ABOUT SECTION ===== */
        .about-highlights {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 24px;
            margin-top: 40px;
        }
        .about-stat {
            text-align: center;
            padding: 32px 20px;
            background: var(--bg-card);
            border-radius: 16px;
            border: 1px solid var(--border-subtle);
        }
        .about-stat-number {
            font-family: 'Playfair Display', serif;
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--gold);
            line-height: 1;
            margin-bottom: 8px;
        }
        .about-stat-label {
            font-size: 0.8rem;
            color: var(--text-muted);
            letter-spacing: 1px;
        }

        /* ===== SCOPE OF WORK ===== */
        .scope-item {
            padding: 32px;
            background: var(--bg-card);
            border-radius: 16px;
            border: 1px solid var(--border-subtle);
            margin-bottom: 16px;
            position: relative;
            overflow: hidden;
        }
        .scope-item::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 3px;
            background: var(--gold);
            border-radius: 0 3px 3px 0;
        }
        .scope-item h3 {
            font-family: 'Playfair Display', serif;
            font-size: 1.2rem;
            margin-bottom: 12px;
            color: var(--text-primary);
        }
        .scope-item p, .scope-item li {
            color: var(--text-secondary);
            font-size: 0.95rem;
        }
        .scope-item ul {
            list-style: none;
            padding: 0;
        }
        .scope-item li {
            padding: 6px 0 6px 20px;
            position: relative;
        }
        .scope-item li::before {
            content: '◆';
            position: absolute;
            left: 0;
            color: var(--gold);
            font-size: 0.5rem;
            top: 12px;
        }

        /* ===== TIMELINE ===== */
        .timeline {
            position: relative;
            padding-left: 40px;
        }
        .timeline::before {
            content: '';
            position: absolute;
            left: 12px;
            top: 0;
            bottom: 0;
            width: 1px;
            background: linear-gradient(to bottom, var(--gold), var(--border-subtle));
        }
        .timeline-item {
            position: relative;
            margin-bottom: 40px;
            padding: 28px 32px;
            background: var(--bg-card);
            border-radius: 16px;
            border: 1px solid var(--border-subtle);
        }
        .timeline-item::before {
            content: '';
            position: absolute;
            left: -34px;
            top: 34px;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: var(--gold);
            box-shadow: 0 0 0 4px var(--bg-primary), 0 0 0 5px var(--gold);
        }
        .timeline-phase {
            font-family: 'Space Grotesk', sans-serif;
            font-size: 0.7rem;
            letter-spacing: 3px;
            text-transform: uppercase;
            color: var(--gold);
            margin-bottom: 8px;
            font-weight: 500;
        }
        .timeline-item h3 {
            font-size: 1.1rem;
            margin-bottom: 8px;
        }
        .timeline-item p {
            color: var(--text-secondary);
            font-size: 0.9rem;
        }

        /* ===== PRICING ===== */
        .pricing-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 24px;
        }
        .pricing-table th {
            font-family: 'Space Grotesk', sans-serif;
            font-size: 0.7rem;
            letter-spacing: 2px;
            text-transform: uppercase;
            color: var(--text-muted);
            text-align: left;
            padding: 16px 20px;
            border-bottom: 1px solid var(--border);
            font-weight: 500;
        }
        .pricing-table th:last-child { text-align: right; }
        .pricing-table td {
            padding: 20px;
            border-bottom: 1px solid var(--border-subtle);
            font-size: 0.95rem;
        }
        .pricing-table td:last-child {
            text-align: right;
            font-family: 'Space Grotesk', sans-serif;
            font-weight: 600;
            color: var(--text-primary);
        }
        .pricing-table td:first-child { color: var(--text-primary); }
        .pricing-table td:nth-child(2) { color: var(--text-secondary); font-size: 0.85rem; }

        .pricing-total {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 32px;
            background: linear-gradient(135deg, rgba(200, 162, 78, 0.08), rgba(200, 162, 78, 0.03));
            border: 1px solid var(--border);
            border-radius: 16px;
            margin-top: 24px;
        }
        .pricing-total-label {
            font-family: 'Playfair Display', serif;
            font-size: 1.3rem;
            color: var(--text-primary);
        }
        .pricing-total-amount {
            font-family: 'Playfair Display', serif;
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--gold);
        }
        .pricing-total-period {
            font-family: 'Inter', sans-serif;
            font-size: 0.85rem;
            color: var(--text-muted);
            font-weight: 300;
        }

        /* ===== WHY CHOOSE US ===== */
        .why-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 24px;
        }
        .why-card {
            padding: 32px;
            background: var(--bg-card);
            border-radius: 16px;
            border: 1px solid var(--border-subtle);
            transition: border-color 0.3s;
        }
        .why-card:hover { border-color: var(--border); }
        .why-icon {
            font-size: 1.8rem;
            margin-bottom: 16px;
        }
        .why-card h3 {
            font-size: 1.05rem;
            margin-bottom: 8px;
            font-weight: 600;
        }
        .why-card p {
            color: var(--text-secondary);
            font-size: 0.9rem;
        }

        /* ===== TERMS ===== */
        .terms-list {
            list-style: none;
            padding: 0;
            counter-reset: terms;
        }
        .terms-list li {
            counter-increment: terms;
            padding: 20px 0 20px 48px;
            border-bottom: 1px solid var(--border-subtle);
            color: var(--text-secondary);
            font-size: 0.9rem;
            position: relative;
        }
        .terms-list li::before {
            content: counter(terms, decimal-leading-zero);
            position: absolute;
            left: 0;
            font-family: 'Space Grotesk', sans-serif;
            font-size: 0.8rem;
            color: var(--gold);
            font-weight: 600;
        }
        .terms-list li strong {
            color: var(--text-primary);
            font-weight: 500;
        }

        /* ===== CTA ===== */
        .cta {
            text-align: center;
            padding: 120px 40px;
            position: relative;
            overflow: hidden;
        }
        .cta::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background: radial-gradient(ellipse at 50% 50%, rgba(200, 162, 78, 0.06), transparent 70%);
        }
        .cta-content { position: relative; z-index: 1; }
        .cta h2 {
            font-family: 'Playfair Display', serif;
            font-size: 2.8rem;
            font-weight: 700;
            margin-bottom: 16px;
        }
        .cta p {
            color: var(--text-secondary);
            font-size: 1.1rem;
            margin-bottom: 48px;
            max-width: 500px;
            margin-left: auto;
            margin-right: auto;
        }
        .cta-button {
            display: inline-block;
            padding: 18px 48px;
            background: linear-gradient(135deg, var(--gold), var(--gold-dark));
            color: var(--bg-primary);
            text-decoration: none;
            font-weight: 600;
            font-size: 0.9rem;
            letter-spacing: 2px;
            text-transform: uppercase;
            border-radius: 4px;
            transition: all 0.3s;
        }
        .cta-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 30px rgba(200, 162, 78, 0.3);
        }
        .cta-contact {
            margin-top: 40px;
            font-size: 0.85rem;
            color: var(--text-muted);
        }
        .cta-contact a {
            color: var(--gold);
            text-decoration: none;
        }

        /* ===== FOOTER ===== */
        .footer {
            padding: 40px;
            text-align: center;
            border-top: 1px solid var(--border-subtle);
        }
        .footer p {
            font-size: 0.75rem;
            color: var(--text-muted);
        }
        .footer .brand { color: var(--gold); }

        /* ===== PRINT ===== */
        @media print {
            @page {
                size: A4;
                margin: 0.75in;
            }
            body {
                background: #0A0A0A !important;
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
            }
            .cover { min-height: auto; padding: 60px 40px; page-break-after: always; }
            section { page-break-inside: avoid; padding: 40px 0; }
            .cta { page-break-before: always; padding: 60px 40px; }
            .cta-button { box-shadow: none; }
        }

        @media (max-width: 768px) {
            .container { padding: 0 24px; }
            .about-highlights { grid-template-columns: 1fr; }
            .why-grid { grid-template-columns: 1fr; }
            .cover-meta { flex-direction: column; gap: 16px; }
            .pricing-total { flex-direction: column; text-align: center; gap: 8px; }
        }
    </style>
</head>
<body>

    <!-- ===== COVER PAGE ===== -->
    <header class="cover">
        <div class="cover-content">
            <div class="cover-logo">Kermicle Media</div>
            <div class="cover-label">Proposal</div>
            <h1>Proposal</h1>
            <div class="cover-client">for {CLIENT_NAME}</div>
            <div class="cover-meta">
                <div class="cover-meta-item">
                    <div class="cover-meta-label">Date</div>
                    <div class="cover-meta-value">{DATE}</div>
                </div>
                <div class="cover-meta-item">
                    <div class="cover-meta-label">Service</div>
                    <div class="cover-meta-value">{SERVICE_TITLE}</div>
                </div>
                <div class="cover-meta-item">
                    <div class="cover-meta-label">Investment</div>
                    <div class="cover-meta-value">{TOTAL_PRICE}</div>
                </div>
                <div class="cover-meta-item">
                    <div class="cover-meta-label">Prepared By</div>
                    <div class="cover-meta-value">Jeremy Kermicle</div>
                </div>
            </div>
            <div class="cover-divider"></div>
        </div>
    </header>

    <!-- ===== ABOUT ===== -->
    <section>
        <div class="container">
            <div class="section-number">01 — About Us</div>
            <h2 class="section-title">Kermicle Media</h2>
            <p class="section-intro">We're a creative media agency that helps businesses stand out, grow their audience, and turn content into customers. From scroll-stopping reels to full-scale social media management, we bring the strategy, creativity, and consistency your brand needs to thrive in today's digital landscape.</p>

            <div class="about-highlights">
                <div class="about-stat">
                    <div class="about-stat-number">50+</div>
                    <div class="about-stat-label">Clients Served</div>
                </div>
                <div class="about-stat">
                    <div class="about-stat-number">500+</div>
                    <div class="about-stat-label">Projects Delivered</div>
                </div>
                <div class="about-stat">
                    <div class="about-stat-number">98%</div>
                    <div class="about-stat-label">Client Retention</div>
                </div>
            </div>
        </div>
    </section>

    <!-- ===== SCOPE OF WORK ===== -->
    <section>
        <div class="container">
            <div class="section-number">02 — Scope of Work</div>
            <h2 class="section-title">What We'll Deliver</h2>
            <p class="section-intro">Here's a detailed breakdown of exactly what's included in your {SERVICE_TITLE} package.</p>

            {SCOPE_ITEMS}
        </div>
    </section>

    <!-- ===== DELIVERABLES ===== -->
    <section>
        <div class="container">
            <div class="section-number">03 — Deliverables</div>
            <h2 class="section-title">Your Deliverables</h2>
            <p class="section-intro">Everything you'll receive as part of this engagement.</p>

            <div class="scope-item">
                <ul>
                    {DELIVERABLES_LIST}
                </ul>
            </div>
        </div>
    </section>

    <!-- ===== TIMELINE ===== -->
    <section>
        <div class="container">
            <div class="section-number">04 — Timeline</div>
            <h2 class="section-title">Project Timeline</h2>
            <p class="section-intro">A clear, phased approach to ensure smooth execution and timely delivery.</p>

            <div class="timeline">
                {TIMELINE_ITEMS}
            </div>
        </div>
    </section>

    <!-- ===== PRICING ===== -->
    <section>
        <div class="container">
            <div class="section-number">05 — Investment</div>
            <h2 class="section-title">Pricing</h2>
            <p class="section-intro">Transparent pricing with no hidden fees. Your investment includes everything outlined in this proposal.</p>

            <table class="pricing-table">
                <thead>
                    <tr>
                        <th>Service</th>
                        <th>Description</th>
                        <th>Price</th>
                    </tr>
                </thead>
                <tbody>
                    {PRICING_ROWS}
                </tbody>
            </table>

            <div class="pricing-total">
                <div>
                    <div class="pricing-total-label">Total Investment</div>
                    <div class="pricing-total-period">{PRICING_PERIOD}</div>
                </div>
                <div class="pricing-total-amount">{TOTAL_PRICE}</div>
            </div>
        </div>
    </section>

    <!-- ===== WHY CHOOSE US ===== -->
    <section>
        <div class="container">
            <div class="section-number">06 — Why Kermicle Media</div>
            <h2 class="section-title">Why Work With Us</h2>
            <p class="section-intro">Here's what sets us apart and why our clients stick around.</p>

            <div class="why-grid">
                <div class="why-card">
                    <div class="why-icon">🎯</div>
                    <h3>Strategy-First Approach</h3>
                    <p>We don't just create content — we create content that converts. Every piece is backed by data and aligned with your business goals.</p>
                </div>
                <div class="why-card">
                    <div class="why-icon">⚡</div>
                    <h3>Fast Turnaround</h3>
                    <p>We respect deadlines like they're sacred. Expect timely delivery, clear communication, and no last-minute surprises.</p>
                </div>
                <div class="why-card">
                    <div class="why-icon">🤝</div>
                    <h3>True Partnership</h3>
                    <p>We're not a faceless agency. You work directly with us — real people who genuinely care about your success.</p>
                </div>
                <div class="why-card">
                    <div class="why-icon">📈</div>
                    <h3>Proven Results</h3>
                    <p>Our clients see real, measurable growth. More followers, more engagement, more customers — that's the Kermicle Media effect.</p>
                </div>
                <div class="why-card">
                    <div class="why-icon">🎨</div>
                    <h3>Creative Excellence</h3>
                    <p>We stay ahead of trends and push creative boundaries. Your brand won't just keep up — it'll stand out.</p>
                </div>
                <div class="why-card">
                    <div class="why-icon">🔄</div>
                    <h3>Revisions Included</h3>
                    <p>Your satisfaction is non-negotiable. Every deliverable comes with revision rounds to ensure it's exactly what you envisioned.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- ===== TERMS ===== -->
    <section>
        <div class="container">
            <div class="section-number">07 — Terms & Conditions</div>
            <h2 class="section-title">Terms</h2>

            <ol class="terms-list">
                <li><strong>Acceptance.</strong> This proposal is valid for 30 days from the date above. To accept, reply in writing (email is fine) or sign and return this document.</li>
                <li><strong>Payment.</strong> A 50% deposit is required to begin work. Remaining balance due upon project completion. For monthly services, payment is due on the 1st of each month.</li>
                <li><strong>Payment Methods.</strong> We accept Zelle, PayPal, and bank transfer. Details provided upon acceptance.</li>
                <li><strong>Revisions.</strong> Each deliverable includes 2 rounds of revisions. Additional revisions billed at $50/hour.</li>
                <li><strong>Ownership.</strong> Client receives full usage rights to all deliverables upon final payment. Kermicle Media retains portfolio usage rights unless otherwise agreed.</li>
                <li><strong>Timeline.</strong> Timelines assume timely feedback and asset delivery from the client. Delays in client response may extend project timelines accordingly.</li>
                <li><strong>Cancellation.</strong> Either party may cancel with 14 days written notice. Work completed up to cancellation date will be billed proportionally.</li>
                <li><strong>Confidentiality.</strong> All project details, strategy documents, and business information shared will be kept strictly confidential.</li>
            </ol>
        </div>
    </section>

    <!-- ===== CTA ===== -->
    <section class="cta">
        <div class="cta-content">
            <h2>Ready to Get Started?</h2>
            <p>Let's turn this proposal into reality. We're excited to work with {CLIENT_NAME} and can't wait to see what we'll create together.</p>
            <a href="mailto:{CONTACT_EMAIL}" class="cta-button">Let's Do This</a>
            <div class="cta-contact">
                <p>Questions? Reach out anytime.</p>
                <p style="margin-top: 8px;">
                    <a href="mailto:{CONTACT_EMAIL}">{CONTACT_EMAIL}</a>
                    {CONTACT_PHONE_LINE}
                </p>
            </div>
        </div>
    </section>

    <!-- ===== FOOTER ===== -->
    <footer class="footer">
        <p>© {YEAR} <span class="brand">Kermicle Media</span> — All rights reserved.</p>
        <p style="margin-top: 6px;">This proposal is confidential and intended solely for {CLIENT_NAME}.</p>
    </footer>

</body>
</html>
```

## Filling the Template

### Scope Items Format
For each scope area, generate:
```html
<div class="scope-item">
    <h3>{Scope Area Title}</h3>
    <ul>
        <li>{Item 1}</li>
        <li>{Item 2}</li>
    </ul>
</div>
```

### Deliverables List Format
```html
<li>{Deliverable 1}</li>
<li>{Deliverable 2}</li>
```

### Timeline Items Format
```html
<div class="timeline-item">
    <div class="timeline-phase">Phase 1 — Week 1</div>
    <h3>{Phase Title}</h3>
    <p>{Phase description}</p>
</div>
```

### Pricing Rows Format
```html
<tr>
    <td>{Service Name}</td>
    <td>{Brief description}</td>
    <td>{Price}</td>
</tr>
```

If single line item, just use one row. For itemized pricing, break down into multiple rows with a total.

### Contact Info
- `{CONTACT_EMAIL}` — Pull from USER.md or use placeholder
- `{CONTACT_PHONE_LINE}` — If phone available: ` | <a href="tel:{phone}">{phone}</a>`, otherwise empty string

## Execution Checklist

1. ☐ Get client name, service type, price (and optional scope, timeline, special requirements)
2. ☐ Generate slug from client name
3. ☐ Look up service template for scope, deliverables, and timeline defaults
4. ☐ Customize scope/deliverables/timeline if custom details provided
5. ☐ Fill the HTML template with all values
6. ☐ Create `proposals/{slug}/` directory
7. ☐ Write `proposal.html`
8. ☐ Read or create `proposals/registry.json`
9. ☐ Add entry to registry
10. ☐ Write updated registry
11. ☐ Notify Jeremy with:
    - Client name and service
    - File path
    - Tip: "Open in browser for full preview" or offer to present in Canvas
12. ☐ Offer to send the proposal cover email (using template-vault `proposal-email` template)

## Example Usage

> "Create a proposal for Bella's Boutique — social media management, $1,500/month"

→ Generates proposal at `proposals/bellas-boutique/proposal.html` using social-media service template, registers in `proposals/registry.json`, sends notification.

> "Proposal for Mike's Gym, full package, $3,000/month, they need bilingual content in English and Spanish"

→ Uses full-package template, adds bilingual requirement to scope and deliverables, generates premium HTML proposal.
