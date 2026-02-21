---
name: voiceover-studio
description: TTS voiceover production for "Jeremy & The Brain" cartoon series. Use when generating character dialogue audio from scripts, mapping voices to characters, controlling pacing/timing, and exporting audio clips for animatic assembly. Supports ElevenLabs API and system TTS.
---

# Voiceover Studio

## Character Voice Map

| Character | Voice Style | ElevenLabs Voice | System TTS Fallback | Notes |
|-----------|-------------|------------------|---------------------|-------|
| **Jeremy** | Casual, energetic, young adult | `Jeremy` or clone | High pitch, fast rate | Main character. Enthusiastic, sometimes sarcastic. Speaks in bursts. |
| **The Brain / Jarvis** | Smooth, British AI, composed | `Daniel` or `Antoni` | British English, measured pace | The AI assistant. Calm and articulate. Dry wit. Never raises voice. |
| **Mule** | Slow, dopey, gentle | `Adam` or clone | Low pitch, slow rate | Lovable idiot. Long pauses between thoughts. Drawn-out vowels. |
| **Forge** | Gruff, focused, no-nonsense | `Arnold` or clone | Deep pitch, steady rate | The builder. Short sentences. Direct. Occasional frustrated sighs. |
| **Narrator** | Warm, storytelling tone | `Rachel` or `Bella` | Neutral, medium pace | Used for scene transitions and episode intros. |

## Dialogue Processing Workflow

### Step 1: Extract Dialogue from Script

Parse the episode script (markdown) and extract every dialogue line:

```
CHARACTER: "Dialogue line here."
```

Output a structured dialogue list:

```json
[
  {"id": "line-001", "character": "Jeremy", "text": "Dude, check this out!", "scene": 1, "emotion": "excited"},
  {"id": "line-002", "character": "Jarvis", "text": "I would advise caution, sir.", "scene": 1, "emotion": "calm"},
  {"id": "line-003", "character": "Mule", "text": "Uhhh... what's that do?", "scene": 1, "emotion": "confused"}
]
```

### Step 2: Apply Voice Direction

For each line, add TTS parameters based on character + emotion:

**Jeremy:**
- Default: stability 0.4, similarity 0.75, speed 1.1
- Excited: speed 1.2, higher pitch
- Scared: speed 1.3, stability 0.3 (more variation)

**The Brain / Jarvis:**
- Default: stability 0.7, similarity 0.8, speed 0.95
- Sarcastic: stability 0.6, speed 0.9
- Urgent: speed 1.05 (never above 1.1 — Jarvis doesn't panic)

**Mule:**
- Default: stability 0.5, similarity 0.7, speed 0.75
- Confused: speed 0.65, add "uhhh" prefix if not present
- Happy: speed 0.85

**Forge:**
- Default: stability 0.6, similarity 0.8, speed 0.95
- Angry: stability 0.4, speed 1.0
- Focused: speed 0.9, stability 0.7

### Step 3: Generate Audio via ElevenLabs

```bash
# Per-line generation
curl -X POST "https://api.elevenlabs.io/v1/text-to-speech/{voice_id}" \
  -H "xi-api-key: $ELEVENLABS_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Dude, check this out!",
    "model_id": "eleven_monolingual_v1",
    "voice_settings": {
      "stability": 0.4,
      "similarity_boost": 0.75
    }
  }' \
  --output audio/line-001.mp3
```

**System TTS fallback** (when ElevenLabs unavailable):
- Use the `tts` tool with appropriate text
- Less character differentiation but functional for drafts

### Step 4: Timing & Pacing

**Between lines (same scene):**
- Same speaker continues: 0.3s pause
- Different speaker responds: 0.5s pause
- Comedic beat / reaction pause: 1.0–1.5s pause
- Mule responding to anything: add extra 0.8s (he's slow)

**Between scenes:**
- Hard cut: 1.0s silence
- Scene transition with narrator: narrator clip + 0.5s padding on each side

**Pacing rules:**
- Never have more than 3 lines without a 0.5s+ pause
- Action scenes: tighten pauses by 30%
- Emotional moments: expand pauses by 50%

### Step 5: Export & Assembly

**File naming convention:**
```
audio/ep{XX}/line-{NNN}-{character}.mp3
```
Example: `audio/ep01/line-001-jeremy.mp3`

**Export specs:**
- Format: MP3, 128kbps, 44.1kHz mono
- Normalize all clips to -3dB peak
- Trim silence from start/end (leave max 0.1s)

**Manifest file** — generate `audio/ep{XX}/manifest.json`:
```json
{
  "episode": 1,
  "title": "Episode Title",
  "lines": [
    {
      "id": "line-001",
      "file": "line-001-jeremy.mp3",
      "character": "Jeremy",
      "text": "Dude, check this out!",
      "duration_ms": 1200,
      "scene": 1,
      "pause_after_ms": 500
    }
  ],
  "total_duration_ms": 45000
}
```

**Concatenation for full episode audio:**
```bash
# Generate silence segments, then concat all with ffmpeg
ffmpeg -f concat -safe 0 -i audio/ep01/concat-list.txt -c:a libmp3lame -b:a 128k audio/ep01/full-episode-dialogue.mp3
```

## Quick Reference

| Task | Command |
|------|---------|
| Extract dialogue from script | Parse markdown, output JSON dialogue list |
| Generate single line | ElevenLabs API call with character voice settings |
| Generate full episode | Loop through dialogue list, apply voice direction, batch generate |
| Check timing | Sum durations + pauses, compare to target episode length |
| Export for animatic | Normalized MP3s + manifest.json in episode folder |

## Integration with Animatic Pipeline

This skill feeds directly into **animatic-pipeline** Step 4. The manifest.json maps each audio clip to its corresponding panel for video assembly.
