---
name: brand-kit-generator
description: Generate complete brand identity packages for clients. Input a client name, industry, and vibe keywords to produce a full brand guide (HTML), color palette (JSON), and social media templates. Output goes to clients/{client-slug}/brand-kit/. Use when Jeremy needs to create branding for a new or existing client.
---

# Brand Kit Generator

## Quick Reference

| Parameter | Required | Example |
|-----------|----------|---------|
| Client Name | ✅ | "Bella's Boutique" |
| Industry | ✅ | restaurant, fitness, real-estate, boutique, tech, salon, coaching |
| Vibe Keywords | ✅ | modern, playful, elegant, bold, minimal, luxurious, warm, edgy |
| Primary Color | Optional | "#C8A24E" (hex) — auto-derived from industry if not given |

## Industry Defaults

When no primary color is provided, use these industry-specific palettes:

| Industry | Primary | Vibe | Font Style |
|----------|---------|------|------------|
| Restaurant / Food | `#C4392D` (warm red) | warm, inviting, appetizing | Serif headings, clean body |
| Fitness / Gym | `#2ECC40` (bold green) | energetic, bold, powerful | Heavy sans-serif, impact |
| Real Estate | `#1B2A4A` (navy) | professional, trustworthy, premium | Classic serif, elegant |
| Boutique / Fashion | `#E8B4B8` (soft pink) | feminine, elegant, curated | Thin serif, script accents |
| Tech / SaaS | `#4A6CF7` (electric blue) | innovative, clean, futuristic | Geometric sans-serif |
| Salon / Beauty | `#9B6B9E` (mauve) | luxurious, pampering, stylish | Elegant serif, light |
| Coaching / Consulting | `#D4A843` (gold) | authoritative, aspirational, warm | Strong serif, clean |
| Default | `#C8A24E` (gold) | professional, versatile | Modern sans-serif |

## Color Generation Algorithm

From the primary color, generate a full 5-color palette using HSL math:

```
Given primary color as HSL(h, s, l):

1. PRIMARY     = HSL(h, s, l)                    — the input color
2. SECONDARY   = HSL((h + 30) % 360, s - 10, l + 5)   — analogous, slightly lighter
3. ACCENT      = HSL((h + 180) % 360, s, l)      — complementary (opposite)
4. NEUTRAL     = HSL(h, 8, 25)                    — desaturated dark from same hue family
5. BACKGROUND  = HSL(h, 5, 8)                     — very dark, near-black with hue tint

Additional derived colors:
- LIGHT TEXT   = HSL(h, 5, 92)                    — off-white with warmth
- MUTED        = HSL(h, s - 30, l + 20)           — softer version of primary
- SUCCESS      = HSL(140, 60, 45)                 — green (fixed)
- WARNING      = HSL(45, 90, 55)                  — amber (fixed)
- ERROR        = HSL(0, 70, 55)                   — red (fixed)
```

### HSL to Hex Conversion

Use JavaScript-style conversion logic. When generating the brand-guide.html, embed the colors directly as hex values — compute them when filling the template.

## Output Files

Generate to `clients/{client-slug}/brand-kit/`:

### 1. brand-guide.html

A gorgeous standalone HTML page. Dark theme, gold accents, premium feel. Contains everything a client or designer needs to maintain brand consistency.

### 2. colors.json

```json
{
  "brand": "{client_name}",
  "generated": "{date}",
  "palette": {
    "primary": { "hex": "#XXXXXX", "rgb": "rgb(X, X, X)", "hsl": "hsl(X, X%, X%)", "name": "Primary" },
    "secondary": { "hex": "#XXXXXX", "rgb": "rgb(X, X, X)", "hsl": "hsl(X, X%, X%)", "name": "Secondary" },
    "accent": { "hex": "#XXXXXX", "rgb": "rgb(X, X, X)", "hsl": "hsl(X, X%, X%)", "name": "Accent" },
    "neutral": { "hex": "#XXXXXX", "rgb": "rgb(X, X, X)", "hsl": "hsl(X, X%, X%)", "name": "Neutral" },
    "background": { "hex": "#XXXXXX", "rgb": "rgb(X, X, X)", "hsl": "hsl(X, X%, X%)", "name": "Background" }
  }
}
```

### 3. social-templates.md

Platform-specific bios, hashtag sets, and posting guidelines.

## brand-guide.html Template

Replace all `{VARIABLES}` when generating. Compute colors from the algorithm above.

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{CLIENT_NAME} — Brand Guide</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Inter:wght@300;400;500;600;700&family=Space+Grotesk:wght@300;400;500;600;700&display=swap');

        :root {
            --primary: {PRIMARY_HEX};
            --secondary: {SECONDARY_HEX};
            --accent: {ACCENT_HEX};
            --neutral: {NEUTRAL_HEX};
            --background: {BACKGROUND_HEX};
            --text-light: {LIGHT_TEXT_HEX};
            --muted: {MUTED_HEX};
            --gold: #C8A24E;
            --gold-light: #E8D48A;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--background);
            color: var(--text-light);
            line-height: 1.7;
            font-weight: 300;
        }

        .container { max-width: 1100px; margin: 0 auto; padding: 0 40px; }

        /* HERO */
        .hero {
            min-height: 70vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            padding: 100px 40px;
            position: relative;
            overflow: hidden;
        }
        .hero::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle at 50% 50%, var(--primary), transparent 60%);
            opacity: 0.06;
        }
        .hero-badge {
            display: inline-block;
            padding: 8px 24px;
            border: 1px solid var(--gold);
            color: var(--gold);
            font-size: 0.75rem;
            letter-spacing: 4px;
            text-transform: uppercase;
            margin-bottom: 40px;
            font-weight: 500;
        }
        .hero h1 {
            font-family: 'Playfair Display', serif;
            font-size: clamp(3rem, 7vw, 5.5rem);
            font-weight: 700;
            line-height: 1.1;
            margin-bottom: 20px;
            background: linear-gradient(135deg, var(--gold-light), var(--gold));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .hero p {
            font-size: 1.15rem;
            color: rgba(255,255,255,0.5);
            max-width: 500px;
            font-weight: 300;
        }
        .hero-meta {
            margin-top: 60px;
            display: flex;
            gap: 40px;
            font-size: 0.8rem;
            color: rgba(255,255,255,0.3);
            letter-spacing: 1px;
            text-transform: uppercase;
        }

        /* SECTIONS */
        section {
            padding: 100px 0;
            border-top: 1px solid rgba(255,255,255,0.06);
        }
        .section-label {
            font-size: 0.7rem;
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
        .section-desc {
            color: rgba(255,255,255,0.5);
            max-width: 600px;
            margin-bottom: 50px;
            font-size: 1.05rem;
        }

        /* COLOR PALETTE */
        .color-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 24px;
            margin-bottom: 40px;
        }
        .color-card {
            border-radius: 16px;
            overflow: hidden;
            background: rgba(255,255,255,0.03);
            border: 1px solid rgba(255,255,255,0.06);
            transition: transform 0.3s;
        }
        .color-card:hover { transform: translateY(-4px); }
        .color-swatch {
            height: 140px;
            width: 100%;
        }
        .color-info {
            padding: 20px;
        }
        .color-name {
            font-weight: 600;
            font-size: 0.95rem;
            margin-bottom: 8px;
        }
        .color-hex {
            font-family: 'Space Grotesk', monospace;
            font-size: 0.85rem;
            color: rgba(255,255,255,0.6);
            margin-bottom: 4px;
        }
        .color-rgb {
            font-family: 'Space Grotesk', monospace;
            font-size: 0.75rem;
            color: rgba(255,255,255,0.35);
        }

        /* TYPOGRAPHY */
        .type-showcase {
            display: grid;
            gap: 40px;
            margin-bottom: 40px;
        }
        .type-item {
            padding: 40px;
            background: rgba(255,255,255,0.02);
            border-radius: 16px;
            border: 1px solid rgba(255,255,255,0.06);
        }
        .type-role {
            font-size: 0.7rem;
            letter-spacing: 3px;
            text-transform: uppercase;
            color: var(--gold);
            margin-bottom: 16px;
        }
        .type-sample {
            font-size: 2.5rem;
            margin-bottom: 16px;
            line-height: 1.2;
        }
        .type-details {
            font-size: 0.85rem;
            color: rgba(255,255,255,0.4);
        }
        .type-details span {
            color: rgba(255,255,255,0.6);
            font-weight: 500;
        }

        /* TONE OF VOICE */
        .voice-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 24px;
        }
        .voice-card {
            padding: 32px;
            background: rgba(255,255,255,0.02);
            border-radius: 16px;
            border: 1px solid rgba(255,255,255,0.06);
        }
        .voice-card h3 {
            font-family: 'Playfair Display', serif;
            font-size: 1.3rem;
            margin-bottom: 12px;
            color: var(--gold);
        }
        .voice-card p {
            color: rgba(255,255,255,0.5);
            font-size: 0.95rem;
        }

        /* DO'S AND DON'TS */
        .dos-donts {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
        }
        .dos, .donts {
            padding: 32px;
            border-radius: 16px;
        }
        .dos {
            background: rgba(46, 204, 64, 0.05);
            border: 1px solid rgba(46, 204, 64, 0.15);
        }
        .donts {
            background: rgba(204, 46, 46, 0.05);
            border: 1px solid rgba(204, 46, 46, 0.15);
        }
        .dos h3, .donts h3 {
            font-family: 'Playfair Display', serif;
            font-size: 1.3rem;
            margin-bottom: 16px;
        }
        .dos h3 { color: #2ECC40; }
        .donts h3 { color: #CC2E2E; }
        .dos li, .donts li {
            color: rgba(255,255,255,0.5);
            margin-bottom: 10px;
            font-size: 0.95rem;
            list-style: none;
            padding-left: 24px;
            position: relative;
        }
        .dos li::before { content: '✓'; position: absolute; left: 0; color: #2ECC40; font-weight: 700; }
        .donts li::before { content: '✗'; position: absolute; left: 0; color: #CC2E2E; font-weight: 700; }

        /* LOGO GUIDELINES */
        .logo-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 24px;
        }
        .logo-card {
            padding: 40px;
            background: rgba(255,255,255,0.02);
            border-radius: 16px;
            border: 1px solid rgba(255,255,255,0.06);
            text-align: center;
        }
        .logo-placeholder {
            width: 120px;
            height: 120px;
            margin: 0 auto 20px;
            border: 2px dashed rgba(255,255,255,0.15);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.75rem;
            color: rgba(255,255,255,0.3);
            letter-spacing: 1px;
            text-transform: uppercase;
        }
        .logo-card h4 {
            font-size: 1rem;
            margin-bottom: 8px;
        }
        .logo-card p {
            font-size: 0.85rem;
            color: rgba(255,255,255,0.4);
        }

        /* SOCIAL MEDIA */
        .social-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 24px;
        }
        .social-card {
            padding: 32px;
            background: rgba(255,255,255,0.02);
            border-radius: 16px;
            border: 1px solid rgba(255,255,255,0.06);
        }
        .social-card h3 {
            font-size: 1.1rem;
            margin-bottom: 16px;
            color: var(--gold);
        }
        .social-card p, .social-card li {
            color: rgba(255,255,255,0.5);
            font-size: 0.9rem;
        }
        .social-card ul {
            list-style: none;
            padding: 0;
        }
        .social-card li {
            margin-bottom: 8px;
            padding-left: 16px;
            position: relative;
        }
        .social-card li::before {
            content: '→';
            position: absolute;
            left: 0;
            color: var(--gold);
        }

        /* FOOTER */
        .footer {
            padding: 60px 0;
            text-align: center;
            border-top: 1px solid rgba(255,255,255,0.06);
        }
        .footer p {
            color: rgba(255,255,255,0.25);
            font-size: 0.8rem;
        }
        .footer .brand {
            color: var(--gold);
            font-weight: 500;
        }

        /* PRINT */
        @media print {
            body { background: #1a1a1a; }
            section { page-break-inside: avoid; }
            .hero { min-height: auto; padding: 60px 40px; }
        }

        @media (max-width: 768px) {
            .dos-donts { grid-template-columns: 1fr; }
            .hero-meta { flex-direction: column; gap: 8px; }
            .container { padding: 0 20px; }
        }
    </style>
</head>
<body>

    <!-- HERO -->
    <header class="hero">
        <span class="hero-badge">Brand Guidelines</span>
        <h1>{CLIENT_NAME}</h1>
        <p>{TAGLINE_OR_DESCRIPTION}</p>
        <div class="hero-meta">
            <span>Industry: {INDUSTRY}</span>
            <span>Created: {DATE}</span>
            <span>By: Kermicle Media</span>
        </div>
    </header>

    <!-- COLOR PALETTE -->
    <section>
        <div class="container">
            <div class="section-label">01 — Color Palette</div>
            <h2 class="section-title">Colors</h2>
            <p class="section-desc">The brand color palette creates visual consistency across all touchpoints. Use the primary color for key elements, secondary for supporting UI, and accent for calls-to-action and highlights.</p>

            <div class="color-grid">
                <div class="color-card">
                    <div class="color-swatch" style="background: {PRIMARY_HEX};"></div>
                    <div class="color-info">
                        <div class="color-name">Primary</div>
                        <div class="color-hex">{PRIMARY_HEX}</div>
                        <div class="color-rgb">{PRIMARY_RGB}</div>
                    </div>
                </div>
                <div class="color-card">
                    <div class="color-swatch" style="background: {SECONDARY_HEX};"></div>
                    <div class="color-info">
                        <div class="color-name">Secondary</div>
                        <div class="color-hex">{SECONDARY_HEX}</div>
                        <div class="color-rgb">{SECONDARY_RGB}</div>
                    </div>
                </div>
                <div class="color-card">
                    <div class="color-swatch" style="background: {ACCENT_HEX};"></div>
                    <div class="color-info">
                        <div class="color-name">Accent</div>
                        <div class="color-hex">{ACCENT_HEX}</div>
                        <div class="color-rgb">{ACCENT_RGB}</div>
                    </div>
                </div>
                <div class="color-card">
                    <div class="color-swatch" style="background: {NEUTRAL_HEX};"></div>
                    <div class="color-info">
                        <div class="color-name">Neutral</div>
                        <div class="color-hex">{NEUTRAL_HEX}</div>
                        <div class="color-rgb">{NEUTRAL_RGB}</div>
                    </div>
                </div>
                <div class="color-card">
                    <div class="color-swatch" style="background: {BACKGROUND_HEX};"></div>
                    <div class="color-info">
                        <div class="color-name">Background</div>
                        <div class="color-hex">{BACKGROUND_HEX}</div>
                        <div class="color-rgb">{BACKGROUND_RGB}</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- TYPOGRAPHY -->
    <section>
        <div class="container">
            <div class="section-label">02 — Typography</div>
            <h2 class="section-title">Typefaces</h2>
            <p class="section-desc">Consistent typography reinforces brand recognition. Use the heading font for titles and hero text, the body font for all general content, and the accent font sparingly for special elements.</p>

            <div class="type-showcase">
                <div class="type-item">
                    <div class="type-role">Heading Font</div>
                    <div class="type-sample" style="font-family: '{HEADING_FONT}', serif;">{HEADING_FONT}</div>
                    <div class="type-details">
                        <span>Use for:</span> Headlines, titles, hero text, section headers<br>
                        <span>Weights:</span> 400 (Regular), 700 (Bold)<br>
                        <span>Google Fonts:</span> fonts.google.com/specimen/{HEADING_FONT_SLUG}
                    </div>
                </div>
                <div class="type-item">
                    <div class="type-role">Body Font</div>
                    <div class="type-sample" style="font-family: '{BODY_FONT}', sans-serif;">{BODY_FONT}</div>
                    <div class="type-details">
                        <span>Use for:</span> Body text, paragraphs, captions, UI elements<br>
                        <span>Weights:</span> 300 (Light), 400 (Regular), 500 (Medium), 600 (Semi-Bold)<br>
                        <span>Google Fonts:</span> fonts.google.com/specimen/{BODY_FONT_SLUG}
                    </div>
                </div>
                <div class="type-item">
                    <div class="type-role">Accent Font</div>
                    <div class="type-sample" style="font-family: '{ACCENT_FONT}', monospace;">{ACCENT_FONT}</div>
                    <div class="type-details">
                        <span>Use for:</span> Labels, badges, code, tags, special callouts<br>
                        <span>Weights:</span> 400 (Regular), 500 (Medium)<br>
                        <span>Google Fonts:</span> fonts.google.com/specimen/{ACCENT_FONT_SLUG}
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- LOGO GUIDELINES -->
    <section>
        <div class="container">
            <div class="section-label">03 — Logo Usage</div>
            <h2 class="section-title">Logo Guidelines</h2>
            <p class="section-desc">Proper logo usage ensures brand integrity. Follow these placement and spacing rules across all media.</p>

            <div class="logo-grid">
                <div class="logo-card">
                    <div class="logo-placeholder">Primary Logo</div>
                    <h4>Primary Mark</h4>
                    <p>Use the primary logo on dark backgrounds. Maintain clear space equal to the height of the logomark on all sides.</p>
                </div>
                <div class="logo-card">
                    <div class="logo-placeholder">Light Version</div>
                    <h4>Light Variant</h4>
                    <p>For light backgrounds, use the dark version of the logo. Never place the light logo on a light background.</p>
                </div>
                <div class="logo-card">
                    <div class="logo-placeholder">Icon Only</div>
                    <h4>Icon / Favicon</h4>
                    <p>For small applications (favicons, app icons, social avatars), use the standalone icon mark without text.</p>
                </div>
                <div class="logo-card">
                    <div class="logo-placeholder">Min Size</div>
                    <h4>Minimum Size</h4>
                    <p>Never display the logo smaller than 32px (digital) or 0.5 inches (print). Below this, use the icon mark only.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- TONE OF VOICE -->
    <section>
        <div class="container">
            <div class="section-label">04 — Voice & Tone</div>
            <h2 class="section-title">Brand Voice</h2>
            <p class="section-desc">The brand voice should feel {VIBE_KEYWORDS}. Every piece of communication should reflect these qualities.</p>

            <div class="voice-grid">
                {VOICE_CARDS}
            </div>
        </div>
    </section>

    <!-- DO'S AND DON'TS -->
    <section>
        <div class="container">
            <div class="section-label">05 — Guidelines</div>
            <h2 class="section-title">Do's & Don'ts</h2>
            <p class="section-desc">Maintain brand consistency by following these guidelines across all materials and platforms.</p>

            <div class="dos-donts">
                <div class="dos">
                    <h3>Do</h3>
                    <ul>
                        {DOS_LIST}
                    </ul>
                </div>
                <div class="donts">
                    <h3>Don't</h3>
                    <ul>
                        {DONTS_LIST}
                    </ul>
                </div>
            </div>
        </div>
    </section>

    <!-- SOCIAL MEDIA -->
    <section>
        <div class="container">
            <div class="section-label">06 — Social Media</div>
            <h2 class="section-title">Social Presence</h2>
            <p class="section-desc">Guidelines for maintaining a cohesive brand presence across all social platforms.</p>

            <div class="social-grid">
                <div class="social-card">
                    <h3>Profile Setup</h3>
                    <ul>
                        <li>Use the icon mark as profile picture</li>
                        <li>Banner/cover: brand colors with tagline</li>
                        <li>Bio: concise, include CTA and link</li>
                        <li>Consistent handle across all platforms</li>
                    </ul>
                </div>
                <div class="social-card">
                    <h3>Content Style</h3>
                    <ul>
                        <li>Use brand colors in all graphics</li>
                        <li>Heading font for text overlays</li>
                        <li>Maintain consistent filter/preset</li>
                        <li>Logo watermark on original content</li>
                    </ul>
                </div>
                <div class="social-card">
                    <h3>Posting Guidelines</h3>
                    <ul>
                        <li>{POSTING_FREQUENCY}</li>
                        <li>Mix content types: reels, carousels, stories</li>
                        <li>Use brand hashtags consistently</li>
                        <li>Engage with comments within 2 hours</li>
                    </ul>
                </div>
                <div class="social-card">
                    <h3>Hashtag Strategy</h3>
                    <ul>
                        <li>Branded: #{CLIENT_SLUG}</li>
                        <li>Industry: {INDUSTRY_HASHTAGS}</li>
                        <li>Use 15-20 hashtags per Instagram post</li>
                        <li>3-5 hashtags for X/Twitter</li>
                    </ul>
                </div>
            </div>
        </div>
    </section>

    <!-- FOOTER -->
    <footer class="footer">
        <div class="container">
            <p>Brand guide created for <span class="brand">{CLIENT_NAME}</span> by <span class="brand">Kermicle Media</span> — {DATE}</p>
            <p style="margin-top: 8px;">This is a living document. Update as the brand evolves.</p>
        </div>
    </footer>

</body>
</html>
```

## Font Recommendations by Vibe

| Vibe Keywords | Heading Font | Body Font | Accent Font |
|--------------|-------------|-----------|-------------|
| modern, clean, minimal | Space Grotesk | Inter | JetBrains Mono |
| elegant, luxurious, premium | Playfair Display | Lora | Cormorant Garamond |
| bold, energetic, powerful | Oswald | Roboto | Space Mono |
| playful, fun, creative | Poppins | Nunito | Fira Code |
| warm, inviting, friendly | Merriweather | Source Sans 3 | IBM Plex Mono |
| edgy, urban, streetwear | Bebas Neue | Barlow | Share Tech Mono |
| professional, corporate, trustworthy | Libre Baskerville | Open Sans | Roboto Mono |
| feminine, soft, delicate | Cormorant Garamond | Raleway | DM Mono |

## Voice Card Generation

Based on vibe keywords, generate 4 voice cards. Examples:

**Modern + Professional:**
- **Confident** — We speak with authority. No hedging, no fluff. Every word earns its place.
- **Clear** — Complex ideas, simple language. If a sentence needs re-reading, rewrite it.
- **Human** — Professional doesn't mean robotic. We're real people talking to real people.
- **Forward-Thinking** — We look ahead. Our language reflects innovation and possibility.

**Playful + Creative:**
- **Fun** — We don't take ourselves too seriously. A little humor goes a long way.
- **Energetic** — Our words have bounce. Short sentences. Punchy phrases. Exclamation points welcome!
- **Relatable** — We talk like a friend, not a corporation. Casual but not careless.
- **Imaginative** — We paint pictures with words. Metaphors, stories, and unexpected angles.

**Elegant + Luxurious:**
- **Refined** — Every word is intentional. We choose quality over quantity.
- **Aspirational** — We inspire. Our language evokes the lifestyle our brand represents.
- **Understated** — We let quality speak for itself. No shouting, no hard sells.
- **Timeless** — We avoid trends and slang. Our voice endures.

## Do's and Don'ts Generation

**Default Do's:**
- Use brand colors consistently across all materials
- Maintain adequate whitespace and breathing room
- Reference this guide when creating any new assets
- Use approved fonts only — no substitutions
- Keep the logo proportions locked (no stretching)
- Write in the brand voice for all communications

**Default Don'ts:**
- Don't use colors outside the approved palette
- Don't modify, rotate, or add effects to the logo
- Don't use more than 2 fonts in a single design
- Don't write in ALL CAPS except for short labels
- Don't use stock photos that contradict the brand vibe
- Don't mix brand elements with competitor aesthetics

## social-templates.md Template

```markdown
# {CLIENT_NAME} — Social Media Templates

*Generated by Kermicle Media — {DATE}*

---

## Brand Hashtags

**Primary:** #{client_slug} #{client_slug_no_hyphens}
**Industry:** {INDUSTRY_HASHTAGS}
**Location (if applicable):** #YourCity #YourState

---

## Platform Bios

### Instagram
{INSTAGRAM_BIO}

### TikTok
{TIKTOK_BIO}

### X (Twitter)
{TWITTER_BIO}

### Facebook
{FACEBOOK_BIO}

### LinkedIn
{LINKEDIN_BIO}

---

## Content Pillars

1. **Educational** (30%) — Tips, how-tos, industry insights
2. **Behind the Scenes** (20%) — Process, team, day-in-the-life
3. **Social Proof** (20%) — Testimonials, results, case studies
4. **Promotional** (15%) — Services, offers, CTAs
5. **Community** (15%) — Reposts, engagement, trending topics

---

## Posting Schedule

| Platform | Frequency | Best Times | Content Type |
|----------|-----------|------------|-------------|
| Instagram | 4-5x/week | 11am, 1pm, 7pm | Reels, Carousels, Stories daily |
| TikTok | 5-7x/week | 10am, 2pm, 8pm | Short-form video |
| X | 3-5x/week | 9am, 12pm, 5pm | Text, threads, engagement |
| Facebook | 3x/week | 1pm, 3pm | Links, video, community posts |
| LinkedIn | 2-3x/week | 8am, 12pm | Professional, long-form |

---

## Caption Formulas

### Hook → Value → CTA
> [Attention-grabbing first line]
> [2-3 lines of value/content]
> [Clear call to action]
> .
> .
> [Hashtags]

### Storytelling
> [Relatable situation]
> [The challenge/problem]
> [The solution/transformation]
> [Lesson or takeaway]
> [CTA]

### List/Tips
> X things about [topic] you need to know 👇
> 1️⃣ [Tip]
> 2️⃣ [Tip]
> 3️⃣ [Tip]
> Save this for later ✅

---

## Hashtag Sets (rotate these)

### Set 1 — Brand & Industry
{HASHTAG_SET_1}

### Set 2 — Growth & Community
{HASHTAG_SET_2}

### Set 3 — Content & Creative
{HASHTAG_SET_3}
```

## Execution Checklist

1. ☐ Get client name, industry, vibe keywords, optional primary color
2. ☐ Generate slug from client name
3. ☐ Select or generate primary color (from industry defaults if not provided)
4. ☐ Run color generation algorithm → derive full 5-color palette + extras
5. ☐ Convert all colors to HEX, RGB, HSL
6. ☐ Select fonts based on vibe keywords
7. ☐ Generate voice cards based on vibe keywords
8. ☐ Generate Do's and Don'ts (customize to industry)
9. ☐ Fill brand-guide.html template with all computed values
10. ☐ Create `clients/{slug}/brand-kit/` directory
11. ☐ Write `brand-guide.html`
12. ☐ Write `colors.json`
13. ☐ Generate social-templates.md (customize bios/hashtags to industry)
14. ☐ Write `social-templates.md`
15. ☐ Notify Jeremy with summary of what was generated
16. ☐ Mention the brand guide can be opened in a browser for full preview

## Example Usage

> "Generate a brand kit for Sunrise Café — they're a restaurant, going for warm, inviting, modern vibes"

→ Generates full brand kit at `clients/sunrise-cafe/brand-kit/` with warm red primary palette, Merriweather + Source Sans 3 fonts, restaurant-specific social templates.

> "Brand kit for Alex Reeves Fitness, primary color #00C853"

→ Uses provided green, fitness industry defaults, bold/energetic voice cards.
