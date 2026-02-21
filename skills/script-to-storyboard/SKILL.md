---
name: script-to-storyboard
description: Converts cartoon scripts into numbered storyboard panels with AI art prompts for Stable Diffusion. Use when breaking down an episode script into visual panels, generating consistent SD prompts, and preparing storyboard assets. References local ComfyUI at C:\Users\alfre\stable-diffusion\.
---

# Script to Storyboard

## Overview

Takes a markdown episode script → produces numbered storyboard panels, each with scene description, camera angle, character positions, SD prompt, and dialogue overlay text.

## Character Visual Reference

Use these descriptions consistently in every prompt where the character appears:

| Character | SD Prompt Description |
|-----------|----------------------|
| **Jeremy** | young adult male, messy brown hair, green hoodie, jeans, sneakers, expressive eyes, slim build |
| **The Brain / Jarvis** | floating holographic AI sphere, glowing blue-white, subtle face projection, clean geometric lines, soft light emission |
| **Mule** | large stocky male, round face, small eyes, overalls, work boots, slightly hunched posture, dopey smile |
| **Forge** | muscular female, short dark hair, welding goggles on forehead, tank top, utility belt, grease smudges, confident stance |

## Style Anchor (prefix every prompt)

```
cartoon style, animated series, bold outlines, vibrant colors, cel shaded, clean linework, expressive characters, 2D animation aesthetic,
```

**Negative prompt (use for all generations):**
```
photorealistic, 3d render, photograph, blurry, deformed, extra limbs, bad anatomy, watermark, signature, text, low quality
```

## Workflow

### Step 1: Read & Segment the Script

Break the script into **20–25 panels** (adjust for script length). Each panel = one visual beat:
- Major action or movement
- Emotion shift
- New speaker in a conversation (if visually distinct)
- Scene/location change
- Comedic punchline or reaction shot

### Step 2: Panel Breakdown Template

For each panel, produce:

```markdown
### Panel {XX}: {Short Title}

**Scene:** {Location and time of day}
**Characters:** {Who is visible}
**Action:** {What's happening}
**Camera:** {Shot type and angle}
**Mood:** {Lighting/atmosphere}
**Dialogue:** "{Any spoken text for overlay}"
**Speaker:** {Character name}

**SD Prompt:**
cartoon style, animated series, bold outlines, vibrant colors, cel shaded, clean linework, expressive characters, 2D animation aesthetic, {scene description}, {character descriptions from table above}, {action}, {camera angle}, {lighting/mood}, {background details}

**Negative Prompt:**
photorealistic, 3d render, photograph, blurry, deformed, extra limbs, bad anatomy, watermark, signature, text, low quality
```

### Step 3: Camera Angle Guide

| Shot Type | When to Use | SD Prompt Addition |
|-----------|-------------|-------------------|
| Wide/establishing | Scene openings, location reveals | `wide shot, establishing shot, full scene visible` |
| Medium | Conversations, general action | `medium shot, waist up, two characters` |
| Close-up | Emotions, reactions, punchlines | `close-up, face detail, expressive` |
| Over-the-shoulder | Dialogue between two characters | `over the shoulder shot, depth of field` |
| Low angle | Power, intimidation, dramatic | `low angle shot, looking up, dramatic perspective` |
| High angle | Vulnerability, overview | `high angle shot, looking down, bird's eye` |
| Dutch angle | Chaos, unease, comedy | `dutch angle, tilted frame, dynamic composition` |
| POV | Immersion, reveal moments | `first person perspective, point of view shot` |

### Step 4: Generate Images via ComfyUI

**Local setup:** `C:\Users\alfre\stable-diffusion\`

**API call to ComfyUI:**
```bash
# Queue a prompt via ComfyUI API
curl -X POST "http://127.0.0.1:8188/prompt" \
  -H "Content-Type: application/json" \
  -d '{"prompt": {WORKFLOW_JSON}}'
```

**Generation settings:**
- Resolution: 768×512 (widescreen) or 512×768 (portrait panels)
- Steps: 30
- CFG Scale: 7
- Sampler: DPM++ 2M Karras
- Model: SD 1.5 (or fine-tuned cartoon checkpoint if available)

**Save to:** `storyboard/ep{XX}/panel-{NN}.png`

### Step 5: Assemble Storyboard Document

Generate a combined markdown file with all panels:

```markdown
# Episode {XX} Storyboard: "{Title}"

## Panel 01: Opening Shot
![Panel 01](panel-01.png)
**Camera:** Wide establishing shot
**Dialogue:** —
**Duration:** 3s

## Panel 02: Jeremy Enters
![Panel 02](panel-02.png)
**Camera:** Medium shot
**Dialogue:** "Dude, check this out!"
**Duration:** 2s

...
```

## Example: Script → Panels

**Script input:**
```
INT. JEREMY'S GARAGE - DAY

Jeremy bursts through the door holding a strange glowing device. Mule is sitting on a crate eating a sandwich.

JEREMY: "Mule! MULE! You gotta see this thing I found!"

MULE: (mouth full) "Mmhh... is it a sandwich?"

The Brain materializes as a hologram above the device.

JARVIS: "I would strongly recommend not touching that again, sir."
```

**Panel output:**

**Panel 01** — Wide shot of garage interior, cluttered workbench, Mule on crate with sandwich. Warm daylight through open door. Establishing shot.

**Panel 02** — Medium shot, Jeremy bursting through door, device in hand glowing, motion blur, excited expression. Dynamic angle.

**Panel 03** — Close-up of Mule's face, cheeks full, confused expression, sandwich in hand. Dialogue: "Mmhh... is it a sandwich?"

**Panel 04** — Medium-wide, holographic Jarvis materializing above the device in Jeremy's hand, blue glow illuminating both characters. Dialogue: "I would strongly recommend not touching that again, sir."

## Output File Structure

```
storyboard/
  ep{XX}/
    panel-01.png
    panel-02.png
    ...
    storyboard.md          # Combined visual document
    prompts.json           # All SD prompts for batch generation
```

**prompts.json format:**
```json
[
  {
    "panel": 1,
    "prompt": "cartoon style, animated series, ...",
    "negative_prompt": "photorealistic, 3d render, ...",
    "width": 768,
    "height": 512,
    "steps": 30,
    "cfg_scale": 7,
    "seed": -1
  }
]
```

## Integration

- Feeds into **animatic-pipeline** Step 2–3 (panels + prompts)
- Audio from **voiceover-studio** maps to panels via dialogue text matching
