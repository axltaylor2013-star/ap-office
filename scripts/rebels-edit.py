from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
import math, os

# Load original
img = Image.open(r"C:\Users\alfre\.openclaw\workspace\rebels-original.jpg").convert("RGBA")
W, H = img.size

# === EDIT 1: Championship Card — cinematic color grade + gold overlay ===
edit1 = img.copy()

# Boost contrast and saturation for that ESPN feel
enhancer = ImageEnhance.Contrast(edit1)
edit1 = enhancer.enhance(1.3)
enhancer = ImageEnhance.Color(edit1)
edit1 = enhancer.enhance(1.2)
enhancer = ImageEnhance.Brightness(edit1)
edit1 = enhancer.enhance(1.05)

# Create gold gradient overlay from bottom
overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
draw = ImageDraw.Draw(overlay)
for y in range(H):
    # Gold gradient from bottom 40%
    if y > H * 0.6:
        alpha = int(180 * ((y - H * 0.6) / (H * 0.4)))
        draw.line([(0, y), (W, y)], fill=(212, 168, 67, min(alpha, 180)))
    # Slight dark vignette from top
    if y < H * 0.15:
        alpha = int(100 * (1 - y / (H * 0.15)))
        draw.line([(0, y), (W, y)], fill=(0, 0, 0, min(alpha, 100)))

edit1 = Image.alpha_composite(edit1.convert("RGBA"), overlay)

# Add side vignette
vignette = Image.new("RGBA", (W, H), (0, 0, 0, 0))
vdraw = ImageDraw.Draw(vignette)
for x in range(W):
    if x < W * 0.1:
        alpha = int(120 * (1 - x / (W * 0.1)))
        vdraw.line([(x, 0), (x, H)], fill=(0, 0, 0, alpha))
    if x > W * 0.9:
        alpha = int(120 * ((x - W * 0.9) / (W * 0.1)))
        vdraw.line([(x, 0), (x, H)], fill=(0, 0, 0, alpha))

edit1 = Image.alpha_composite(edit1, vignette)

# Add text overlays
draw1 = ImageDraw.Draw(edit1)

# Try to get a bold font
try:
    font_large = ImageFont.truetype("C:/Windows/Fonts/impact.ttf", 72)
    font_med = ImageFont.truetype("C:/Windows/Fonts/impact.ttf", 36)
    font_small = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 24)
    font_xs = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 20)
except:
    font_large = ImageFont.load_default()
    font_med = font_large
    font_small = font_large
    font_xs = font_large

# Top banner — dark stripe
draw1.rectangle([(0, 0), (W, 55)], fill=(0, 0, 0, 200))
draw1.text((W//2, 28), "⚡ BREAKING NEWS ⚡", fill=(255, 215, 0, 255), font=font_med, anchor="mm")

# Bottom area — championship callout  
draw1.rectangle([(0, H-90), (W, H)], fill=(0, 0, 0, 220))
draw1.text((W//2, H-65), "RUNNIN' REBELS TAKE THE CROWN", fill=(255, 255, 255, 255), font=font_med, anchor="mm")
draw1.text((W//2, H-30), "3rd Grade Tournament  •  Owen County  •  Undefeated Season?  •  League on Notice", fill=(212, 168, 67, 255), font=font_xs, anchor="mm")

# "ESPN-style" scoreboard box top right
draw1.rectangle([(W-280, 65), (W-10, 160)], fill=(20, 20, 20, 230))
draw1.rectangle([(W-280, 65), (W-10, 95)], fill=(139, 0, 0, 255))
draw1.text((W-145, 80), "FINAL SCORE", fill=(255, 255, 255), font=font_xs, anchor="mm")
draw1.text((W-200, 128), "REBELS", fill=(255, 255, 255), font=font_small, anchor="mm")
draw1.text((W-60, 128), "W", fill=(0, 255, 100), font=font_small, anchor="mm")

# Fire emoji corners
draw1.text((15, 60), "🔥", font=font_med, fill=(255,255,255))
draw1.text((W-55, H-135), "🏆", font=font_med, fill=(255,255,255))

edit1_rgb = edit1.convert("RGB")
edit1_rgb.save(r"C:\Users\alfre\.openclaw\workspace\rebels-espn.jpg", quality=95)
print("Edit 1 saved: rebels-espn.jpg")

# === EDIT 2: Movie Poster Style ===
edit2 = img.copy().convert("RGBA")

# Dramatic contrast boost
enhancer = ImageEnhance.Contrast(edit2)
edit2 = enhancer.enhance(1.5)
enhancer = ImageEnhance.Color(edit2)
edit2 = enhancer.enhance(0.7)  # desaturate slightly for cinematic
enhancer = ImageEnhance.Brightness(edit2)
edit2 = enhancer.enhance(0.85)

# Heavy dark overlay from top and bottom
poster_overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
pdraw = ImageDraw.Draw(poster_overlay)
for y in range(H):
    if y < H * 0.2:
        alpha = int(200 * (1 - y / (H * 0.2)))
        pdraw.line([(0, y), (W, y)], fill=(0, 0, 0, alpha))
    if y > H * 0.55:
        alpha = int(230 * ((y - H * 0.55) / (H * 0.45)))
        pdraw.line([(0, y), (W, y)], fill=(0, 0, 0, min(alpha, 230)))

# Red tint overlay for drama
for y in range(H):
    if y > H * 0.7:
        alpha = int(60 * ((y - H * 0.7) / (H * 0.3)))
        pdraw.line([(0, y), (W, y)], fill=(139, 0, 0, min(alpha, 60)))

edit2 = Image.alpha_composite(edit2, poster_overlay)

# Add side vignette
edit2 = Image.alpha_composite(edit2, vignette)

draw2 = ImageDraw.Draw(edit2)

# Movie-style top text
try:
    font_title = ImageFont.truetype("C:/Windows/Fonts/impact.ttf", 80)
    font_tagline = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 22)
    font_credits = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 14)
except:
    font_title = ImageFont.load_default()
    font_tagline = font_title
    font_credits = font_title

# Top: "FROM THE COURTS OF OWEN COUNTY"
draw2.text((W//2, 25), "FROM THE COURTS OF OWEN COUNTY", fill=(200, 200, 200, 200), font=font_tagline, anchor="mm")

# Big title at bottom
draw2.text((W//2 + 3, H-120+3), "REBELS", fill=(0, 0, 0, 255), font=font_title, anchor="mm")  # shadow
draw2.text((W//2, H-120), "REBELS", fill=(255, 215, 0, 255), font=font_title, anchor="mm")

# Tagline
draw2.text((W//2, H-65), "THEY DIDN'T COME TO PLAY. THEY CAME TO DOMINATE.", fill=(255, 255, 255, 230), font=font_tagline, anchor="mm")

# Fake credits line
draw2.text((W//2, H-30), "A KERMICLE MEDIA PRODUCTION  •  OWEN COUNTY RUNNIN' REBELS  •  2026 NCKC CHAMPIONS", fill=(150, 150, 150, 200), font=font_credits, anchor="mm")

# Rating box bottom left
draw2.rectangle([(20, H-50), (100, H-15)], outline=(255, 255, 255, 180), width=2)
draw2.text((60, H-32), "RATED\nW", fill=(255, 255, 255, 200), font=font_credits, anchor="mm")

edit2_rgb = edit2.convert("RGB")
edit2_rgb.save(r"C:\Users\alfre\.openclaw\workspace\rebels-movie.jpg", quality=95)
print("Edit 2 saved: rebels-movie.jpg")

# === EDIT 3: Trading Card Style ===
edit3 = img.copy().convert("RGBA")

# Slight sharpen
edit3_sharp = edit3.filter(ImageFilter.SHARPEN)
enhancer = ImageEnhance.Contrast(edit3_sharp)
edit3 = enhancer.enhance(1.2)
enhancer = ImageEnhance.Color(edit3)
edit3 = enhancer.enhance(1.3)

# Create card border
card = Image.new("RGBA", (W+40, H+180), (15, 15, 15, 255))
# Gold border
card_draw = ImageDraw.Draw(card)
card_draw.rectangle([(8, 8), (W+32, H+172)], outline=(212, 168, 67, 255), width=4)
card_draw.rectangle([(14, 14), (W+26, H+166)], outline=(139, 0, 0, 255), width=3)

# Paste photo with small margin
card.paste(edit3, (20, 20))

# Stats area at bottom
card_draw.rectangle([(20, H+25), (W+20, H+160)], fill=(25, 25, 25, 255))
card_draw.rectangle([(20, H+25), (W+20, H+28)], fill=(212, 168, 67, 255))  # gold line

try:
    font_card_title = ImageFont.truetype("C:/Windows/Fonts/impact.ttf", 40)
    font_card_stat = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 22)
    font_card_label = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 14)
    font_card_sm = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 16)
except:
    font_card_title = ImageFont.load_default()
    font_card_stat = font_card_title
    font_card_label = font_card_title
    font_card_sm = font_card_title

card_draw.text(((W+40)//2, H+50), "OWEN COUNTY RUNNIN' REBELS", fill=(212, 168, 67), font=font_card_title, anchor="mm")

# Stats row
stats = [("SEASON", "CHAMPS"), ("GRADE", "3RD"), ("HEART", "💯"), ("HUSTLE", "MAX"), ("CLUTCH", "∞")]
stat_width = (W - 20) // len(stats)
for i, (label, value) in enumerate(stats):
    x = 40 + i * stat_width + stat_width // 2
    card_draw.text((x, H+85), value, fill=(255, 255, 255), font=font_card_stat, anchor="mm")
    card_draw.text((x, H+110), label, fill=(150, 150, 150), font=font_card_label, anchor="mm")

# Card number / set info
card_draw.text(((W+40)//2, H+145), "2026 NCKC TOURNAMENT  •  CHAMPIONSHIP EDITION  •  #001/100", fill=(100, 100, 100), font=font_card_label, anchor="mm")

# Holographic-ish shine stripe (diagonal gold line)
for i in range(5):
    x_start = 30 + i * 3
    card_draw.line([(x_start, 20), (x_start + 100, H+20)], fill=(212, 168, 67, 40), width=1)

card_rgb = card.convert("RGB")
card_rgb.save(r"C:\Users\alfre\.openclaw\workspace\rebels-card.jpg", quality=95)
print("Edit 3 saved: rebels-card.jpg")

print("\nAll 3 edits complete!")
