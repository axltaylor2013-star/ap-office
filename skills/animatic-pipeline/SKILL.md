---
name: animatic-pipeline
description: Full pipeline for turning cartoon scripts into animatics. Use when breaking scripts into panels, writing AI art prompts, generating images via Stable Diffusion, creating voiceover via TTS, and assembling into video. Covers the complete workflow from script to finished animatic.
---

# Animatic Pipeline

## Pipeline Steps

### Step 1: Script Breakdown
- Read the full script
- Break into **20–25 key panels** (one per major beat/action/emotion shift)
- Each panel gets: panel number, scene description, dialogue, camera direction, mood

### Step 2: AI Art Prompts
- Write one image prompt per panel
- **Start every prompt with the style anchor** from `references/style-guide.md`
- Include: character names/descriptions, action, background, lighting, camera angle
- Reference `references/characters.md` for consistent character descriptions
- Keep prompts under 200 words each

### Step 3: Image Generation
- Send prompts to local Stable Diffusion API (`http://127.0.0.1:7860/sdapi/v1/txt2img`)
- Settings: 768x512 (widescreen), 30 steps, CFG 7, sampler DPM++ 2M Karras
- Save as `panels/panel-XX.png`
- Review for consistency — regenerate outliers

### Step 4: Voiceover
- Extract all dialogue lines from the script breakdown
- Generate TTS for each line using the `tts` tool or ElevenLabs API
- Save as `audio/line-XX.mp3`
- Match voice to character (see `references/characters.md` for voice notes)

### Step 5: Assembly
- Combine panels + audio into video using ffmpeg
- Each panel displays for the duration of its dialogue + 1s buffer
- Add simple transitions (crossfade 0.5s between panels)
- Add background music track if provided (mix at -12dB under dialogue)
- Export as MP4, 1080p, 24fps

```bash
# Example ffmpeg concat approach
ffmpeg -f concat -i filelist.txt -vf "fps=24,scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" -c:v libx264 -pix_fmt yuv420p output.mp4
```

## Resources

- **Visual style specs**: `references/style-guide.md`
- **Character designs**: `references/characters.md`
