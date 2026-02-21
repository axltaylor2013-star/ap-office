---
name: portfolio-generator
description: Generate a branded before/after portfolio showcase page for Kermicle Media. Takes work samples and descriptions, outputs a responsive HTML page with dark theme, gold accents, SEO meta tags, and Open Graph tags. Ready to deploy to kermiclemedia.com.
---

# Portfolio Generator

## Quick Reference

| Token | Value |
|-------|-------|
| Background | `#0d0d0d` (body), `#1a1a1a` (cards) |
| Accent/Gold | `#d4a843` |
| Text | `#e0e0e0` |
| Subtle Text | `#888888` |
| Font | `Segoe UI, system-ui, sans-serif` |
| Card Radius | `12px` |
| Hover Glow | `box-shadow: 0 0 15px rgba(212,168,67,0.3)` |

## Input Parameters

| Parameter | Required | Example |
|-----------|----------|---------|
| Page Title | ✅ | "Video Editing Portfolio" |
| Items[] | ✅ | Array of portfolio pieces (see below) |
| Category | Optional | "video-editing", "photo-editing", "social-media" |
| Deploy Path | Optional | Defaults to `dashboard/portfolio/` |

### Portfolio Item Structure

Each item should include:

```
- title: "Fitness Brand Commercial"
- client: "FitLife Co" (optional, omit if confidential)
- category: "video-editing"
- description: "30-second commercial with motion graphics and color grading"
- before_image: "path/to/before.jpg" (optional)
- after_image: "path/to/after.jpg" (optional)
- video_url: "https://youtube.com/..." (optional)
- tags: ["color-grading", "motion-graphics", "commercial"]
```

## Output

Save to `dashboard/portfolio/index.html` (or specified deploy path).

## HTML Template

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- SEO Meta Tags -->
    <title>{Page Title} | Kermicle Media</title>
    <meta name="description" content="Professional {category} portfolio by Kermicle Media. Photo editing, video editing, and AI-powered creative services by Jeremy Kermicle.">
    <meta name="keywords" content="kermicle media, {category}, photo editing, video editing, AI tools, portfolio, jeremy kermicle">
    <meta name="author" content="Jeremy Kermicle">
    <meta name="robots" content="index, follow">
    <link rel="canonical" href="https://kermiclemedia.com/portfolio/">

    <!-- Open Graph -->
    <meta property="og:type" content="website">
    <meta property="og:title" content="{Page Title} | Kermicle Media">
    <meta property="og:description" content="Professional {category} work by Kermicle Media. See the transformation.">
    <meta property="og:image" content="https://kermiclemedia.com/portfolio/og-image.jpg">
    <meta property="og:url" content="https://kermiclemedia.com/portfolio/">
    <meta property="og:site_name" content="Kermicle Media">

    <!-- Twitter Card -->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="{Page Title} | Kermicle Media">
    <meta name="twitter:description" content="Professional {category} work by Kermicle Media.">
    <meta name="twitter:image" content="https://kermiclemedia.com/portfolio/og-image.jpg">

    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            background: #0d0d0d;
            color: #e0e0e0;
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            line-height: 1.6;
        }

        /* Header */
        .hero {
            text-align: center;
            padding: 80px 20px 60px;
            background: linear-gradient(180deg, #1a1a1a 0%, #0d0d0d 100%);
        }
        .hero h1 {
            font-size: 2.8rem;
            color: #d4a843;
            margin-bottom: 12px;
            font-weight: 700;
        }
        .hero p {
            font-size: 1.2rem;
            color: #888;
            max-width: 600px;
            margin: 0 auto;
        }
        .hero .brand {
            font-size: 0.9rem;
            color: #d4a843;
            text-transform: uppercase;
            letter-spacing: 3px;
            margin-bottom: 16px;
        }

        /* Filter Tabs */
        .filters {
            display: flex;
            justify-content: center;
            gap: 12px;
            padding: 20px;
            flex-wrap: wrap;
        }
        .filter-btn {
            background: #1a1a1a;
            color: #e0e0e0;
            border: 1px solid #333;
            padding: 8px 20px;
            border-radius: 24px;
            cursor: pointer;
            transition: all 0.3s;
            font-size: 0.9rem;
        }
        .filter-btn:hover, .filter-btn.active {
            border-color: #d4a843;
            color: #d4a843;
            box-shadow: 0 0 15px rgba(212,168,67,0.3);
        }

        /* Portfolio Grid */
        .portfolio-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 24px;
            padding: 40px 5%;
            max-width: 1400px;
            margin: 0 auto;
        }

        /* Portfolio Card */
        .card {
            background: #1a1a1a;
            border-radius: 12px;
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
            border: 1px solid #222;
        }
        .card:hover {
            transform: translateY(-4px);
            box-shadow: 0 0 15px rgba(212,168,67,0.3);
        }

        /* Before/After Slider */
        .ba-container {
            position: relative;
            width: 100%;
            aspect-ratio: 16/10;
            overflow: hidden;
            cursor: col-resize;
        }
        .ba-container img {
            position: absolute;
            top: 0; left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .ba-after {
            clip-path: inset(0 50% 0 0);
        }
        .ba-slider {
            position: absolute;
            top: 0;
            left: 50%;
            width: 3px;
            height: 100%;
            background: #d4a843;
            z-index: 2;
            pointer-events: none;
        }
        .ba-slider::after {
            content: '◀ ▶';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: #d4a843;
            color: #0d0d0d;
            padding: 6px 10px;
            border-radius: 20px;
            font-size: 0.7rem;
            white-space: nowrap;
        }
        .ba-label {
            position: absolute;
            bottom: 10px;
            padding: 4px 12px;
            background: rgba(0,0,0,0.7);
            color: #d4a843;
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            border-radius: 4px;
            z-index: 3;
        }
        .ba-label.before { left: 10px; }
        .ba-label.after { right: 10px; }

        /* Card single image (no before/after) */
        .card-image {
            width: 100%;
            aspect-ratio: 16/10;
            object-fit: cover;
        }

        /* Card Body */
        .card-body {
            padding: 20px;
        }
        .card-body h3 {
            color: #d4a843;
            margin-bottom: 6px;
            font-size: 1.15rem;
        }
        .card-body .client {
            color: #888;
            font-size: 0.85rem;
            margin-bottom: 10px;
        }
        .card-body p {
            color: #ccc;
            font-size: 0.95rem;
            margin-bottom: 12px;
        }
        .tags {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
        }
        .tag {
            background: rgba(212,168,67,0.15);
            color: #d4a843;
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 0.75rem;
        }

        /* Footer */
        .footer {
            text-align: center;
            padding: 60px 20px;
            color: #555;
        }
        .footer a {
            color: #d4a843;
            text-decoration: none;
        }

        /* CTA */
        .cta {
            text-align: center;
            padding: 60px 20px;
        }
        .cta-btn {
            display: inline-block;
            background: #d4a843;
            color: #0d0d0d;
            padding: 14px 36px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 700;
            font-size: 1.1rem;
            transition: box-shadow 0.3s;
        }
        .cta-btn:hover {
            box-shadow: 0 0 25px rgba(212,168,67,0.5);
        }

        /* Responsive */
        @media (max-width: 768px) {
            .hero h1 { font-size: 2rem; }
            .portfolio-grid {
                grid-template-columns: 1fr;
                padding: 20px;
            }
        }
    </style>
</head>
<body>
    <section class="hero">
        <div class="brand">Kermicle Media</div>
        <h1>{Page Title}</h1>
        <p>Professional photo & video editing, powered by creativity and AI.</p>
    </section>

    <div class="filters">
        <button class="filter-btn active" data-filter="all">All</button>
        <button class="filter-btn" data-filter="photo-editing">Photo Editing</button>
        <button class="filter-btn" data-filter="video-editing">Video Editing</button>
        <button class="filter-btn" data-filter="social-media">Social Media</button>
    </div>

    <div class="portfolio-grid">
        <!-- PORTFOLIO ITEMS GO HERE -->
        <!-- Example card with before/after: -->
        <div class="card" data-category="photo-editing">
            <div class="ba-container" data-before="before.jpg" data-after="after.jpg">
                <img src="before.jpg" alt="Before editing" class="ba-before">
                <img src="after.jpg" alt="After editing" class="ba-after">
                <div class="ba-slider"></div>
                <span class="ba-label before">Before</span>
                <span class="ba-label after">After</span>
            </div>
            <div class="card-body">
                <h3>Project Title</h3>
                <div class="client">Client Name</div>
                <p>Description of the work performed.</p>
                <div class="tags">
                    <span class="tag">color-grading</span>
                    <span class="tag">retouching</span>
                </div>
            </div>
        </div>

        <!-- Example card with single image / video: -->
        <div class="card" data-category="video-editing">
            <img src="thumbnail.jpg" alt="Project thumbnail" class="card-image">
            <div class="card-body">
                <h3>Project Title</h3>
                <p>Description of the work performed.</p>
                <div class="tags">
                    <span class="tag">motion-graphics</span>
                </div>
            </div>
        </div>
    </div>

    <section class="cta">
        <a href="mailto:contact@kermiclemedia.com" class="cta-btn">Work With Me</a>
    </section>

    <footer class="footer">
        <p>&copy; {year} <a href="https://kermiclemedia.com">Kermicle Media</a>. All rights reserved.</p>
    </footer>

    <script>
        // Before/After Slider
        document.querySelectorAll('.ba-container').forEach(container => {
            let isDragging = false;
            const afterImg = container.querySelector('.ba-after');
            const slider = container.querySelector('.ba-slider');

            function updateSlider(x) {
                const rect = container.getBoundingClientRect();
                let pct = ((x - rect.left) / rect.width) * 100;
                pct = Math.max(0, Math.min(100, pct));
                afterImg.style.clipPath = `inset(0 ${100 - pct}% 0 0)`;
                slider.style.left = pct + '%';
            }

            container.addEventListener('mousedown', () => isDragging = true);
            document.addEventListener('mouseup', () => isDragging = false);
            container.addEventListener('mousemove', e => { if (isDragging) updateSlider(e.clientX); });
            container.addEventListener('touchmove', e => { updateSlider(e.touches[0].clientX); });
            container.addEventListener('click', e => updateSlider(e.clientX));
        });

        // Category Filter
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                const filter = btn.dataset.filter;
                document.querySelectorAll('.card').forEach(card => {
                    card.style.display = (filter === 'all' || card.dataset.category === filter) ? '' : 'none';
                });
            });
        });
    </script>
</body>
</html>
```

## Image Optimization Notes

When adding images:
- **Before/After pairs:** Use matching dimensions, ideally 1200×750 (16:10)
- **Format:** WebP preferred, JPEG fallback. Compress to <200KB per image
- **Thumbnails:** Generate 600px-wide thumbnails for grid, link to full-size on click
- **Alt text:** Always include descriptive alt text for accessibility & SEO
- **Lazy loading:** Add `loading="lazy"` to all images below the fold
- **OG Image:** Create a 1200×630 branded image for social sharing (`og-image.jpg`)

## Workflow

1. Collect portfolio items (descriptions, images, categories)
2. Populate the HTML template — one `.card` div per item
3. Replace all `{placeholders}` with actual content
4. Optimize and place images in `dashboard/portfolio/images/`
5. Save to `dashboard/portfolio/index.html`
6. Add nav tab in `hub.html` if not already present
7. Test responsive at 375px, 768px, 1200px

## Example Usage

> "Build a portfolio page with these 4 projects: [descriptions]. Use the before/after slider for the photo edits."

Generates a complete, deployable HTML page with all SEO tags, responsive layout, interactive sliders, and Kermicle Media branding.
