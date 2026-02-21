---
name: thumbnail-factory
description: Generates multiple thumbnail concepts with Stable Diffusion prompts and text overlay suggestions for YouTube/Instagram. Use when creating A/B test-ready thumbnail variants for videos. References local SD setup at C:\Users\alfre\stable-diffusion\.
---

# Thumbnail Factory

## Overview

Given a video title or topic → generates 3–4 thumbnail variants, each with an SD prompt, text overlay plan, and platform-specific dimensions.

## Dimensions

| Platform | Size | Aspect Ratio | SD Resolution |
|----------|------|-------------|---------------|
| YouTube | 1280×720 | 16:9 | 768×432 (upscale 2x) |
| Instagram Post | 1080×1080 | 1:1 | 512×512 (upscale 2x) |
| Instagram Reel | 1080×1920 | 9:16 | 512×912 (upscale 2x) |
| Shorts/TikTok | 1080×1920 | 9:16 | 512×912 (upscale 2x) |

Default to **YouTube 16:9** unless specified otherwise.

## Workflow

### Step 1: Concept Generation

For each video, generate **4 variant concepts** using these proven thumbnail archetypes:

| Variant | Archetype | Description |
|---------|-----------|-------------|
| A | **Reaction/Emotion** | Character with exaggerated facial expression reacting to the topic |
| B | **Before/After** | Split composition showing contrast or transformation |
| C | **Object Focus** | Hero object/subject center frame, dramatic lighting, minimal background |
| D | **Chaos/Action** | Dynamic scene with movement, multiple elements, visual energy |

### Step 2: SD Prompt Template

```
{style anchor}, {subject/scene description}, {character or object}, {lighting}, {background}, {composition notes}, high detail, sharp focus, thumbnail composition, eye-catching
```

**Style anchors by content type:**

| Content Type | Style Anchor |
|-------------|-------------|
| Cartoon/Animation | `cartoon style, vibrant colors, bold outlines, cel shaded, animated` |
| Tech/Tutorial | `digital illustration, clean modern style, tech aesthetic, gradient background` |
| Vlog/Lifestyle | `cinematic photography style, shallow depth of field, warm tones` |
| Gaming | `dramatic digital art, neon lighting, high contrast, gaming aesthetic` |

**Negative prompt (all thumbnails):**
```
blurry, low quality, watermark, text, words, letters, signature, deformed, bad anatomy, oversaturated
```

### Step 3: Text Overlay Plan

For each variant, specify:

```yaml
text_overlay:
  primary_text: "MAX 4 WORDS"          # Big, bold, readable at small sizes
  font_style: "Impact / Bebas Neue / Anton"
  color: "#FFFFFF"                       # High contrast against background
  stroke: "#000000, 4px"                # Always add stroke for readability
  position: "top-right"                  # Keep faces/subjects visible
  size: "LARGE"                          # Must be readable at 168×94px (YouTube browse)
  secondary_text: null                   # Optional smaller text, use sparingly
```

**Text rules:**
- MAX 4 words on primary text (3 is ideal)
- ALL CAPS for impact
- Leave 30% of thumbnail text-free for the subject
- Never cover faces
- Test readability at YouTube's smallest display size (168×94px)

**High-contrast color combos:**
- White text + black stroke (universal)
- Yellow (#FFD700) + black stroke (attention-grabbing)
- Red (#FF0000) + white stroke (urgency)
- Cyan (#00FFFF) + dark background (tech/gaming)

### Step 4: Generate via ComfyUI

**Local setup:** `C:\Users\alfre\stable-diffusion\`

```bash
curl -X POST "http://127.0.0.1:8188/prompt" \
  -H "Content-Type: application/json" \
  -d '{"prompt": {WORKFLOW_JSON}}'
```

**Settings:**
- Resolution: per platform table above
- Steps: 30
- CFG: 7
- Sampler: DPM++ 2M Karras
- Generate 2 seeds per variant (8 total images for 4 concepts)

**Save to:** `thumbnails/{video-slug}/variant-{A|B|C|D}-{seed}.png`

### Step 5: Post-Processing

After SD generation, text overlays are added via ImageMagick or Pillow:

```bash
# Example: Add text overlay with ImageMagick
magick convert variant-A.png \
  -gravity NorthEast -pointsize 72 \
  -font Impact -fill white -stroke black -strokewidth 4 \
  -annotate +40+40 "OH NO" \
  variant-A-final.png
```

Upscale to final dimensions:
```bash
magick convert variant-A-final.png -resize 1280x720! variant-A-youtube.png
```

## Example

**Input:** Video title "Jeremy Accidentally Deletes The Brain"

### Variant A — Reaction
**Concept:** Jeremy with hands on head, mouth open in horror, computer screen behind him showing error message, Jarvis hologram flickering/fading
**SD Prompt:** `cartoon style, vibrant colors, bold outlines, cel shaded, animated, young adult male messy brown hair green hoodie, shocked expression hands on head mouth open, flickering blue holographic sphere fading away, computer screen with red error, dramatic lighting, medium close-up, eye-catching, high detail`
**Text:** "HE'S GONE" — white + black stroke, bottom-left
**Position:** Jeremy right of center, text bottom-left

### Variant B — Before/After
**Concept:** Split frame — left: Jarvis glowing bright and healthy; right: empty space with scattered digital particles
**SD Prompt:** `cartoon style, vibrant colors, bold outlines, cel shaded, animated, split composition, left side glowing blue holographic AI sphere bright detailed, right side empty dark space with fading blue particles, dramatic contrast, clean split, high detail`
**Text:** "BEFORE / AFTER" — yellow + black stroke, center divider
**Position:** Subject centered in each half

### Variant C — Object Focus
**Concept:** Close-up of Jeremy's finger hovering over a big red DELETE button, Jarvis reflected in the button surface
**SD Prompt:** `cartoon style, vibrant colors, bold outlines, cel shaded, animated, extreme close-up, finger hovering over large red button labeled delete, reflection of blue holographic face in button surface, dramatic rim lighting, dark background, high detail, sharp focus`
**Text:** "DON'T PRESS IT" — red + white stroke, top-center
**Position:** Button center frame

### Variant D — Chaos
**Concept:** Jeremy running through a digital void, fragmented code and data swirling, Mule and Forge in background looking confused, everything glitching
**SD Prompt:** `cartoon style, vibrant colors, bold outlines, cel shaded, animated, young adult male running through digital void, fragmented code and data particles swirling, glitch effects, two characters in background looking confused, dynamic action pose, chaotic composition, neon accents, high detail`
**Text:** "TOTAL CHAOS" — cyan + black stroke, top-right
**Position:** Jeremy left of center running right

## Output Structure

```
thumbnails/
  {video-slug}/
    variant-A-1.png
    variant-A-2.png
    variant-B-1.png
    variant-B-2.png
    variant-C-1.png
    variant-C-2.png
    variant-D-1.png
    variant-D-2.png
    concepts.md            # All concepts, prompts, and text overlay specs
    prompts.json           # Machine-readable for batch generation
```

## Quick Reference

| Task | Action |
|------|--------|
| New video thumbnails | Provide title → get 4 variants with prompts |
| Platform switch | Change resolution per dimensions table |
| Regenerate variant | Rerun with new seed, same prompt |
| Add text overlays | ImageMagick/Pillow post-processing |
| A/B test | Upload variants A–D, track CTR |
