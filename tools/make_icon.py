"""Generates Assets/AppIcon.png (1024x1024): emerald rounded square, gold beads ring, red record dot with a gold crescent."""
import math
from PIL import Image, ImageDraw

S = 2048
k = S / 1024.0

grad = Image.new("RGBA", (S, S))
px = grad.load()
c1, c2 = (6, 40, 46), (20, 105, 112)
for y in range(S):
    for x in range(S):
        t = (x + y) / (2.0 * S)
        px[x, y] = (int(c1[0] + (c2[0] - c1[0]) * t), int(c1[1] + (c2[1] - c1[1]) * t),
                    int(c1[2] + (c2[2] - c1[2]) * t), 255)

mask = Image.new("L", (S, S), 0)
ImageDraw.Draw(mask).rounded_rectangle([100 * k, 100 * k, 924 * k, 924 * k], radius=185 * k, fill=255)
img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
img.paste(grad, (0, 0), mask)
d = ImageDraw.Draw(img)

gold, light = (233, 196, 106, 255), (255, 236, 170, 255)
cx, cy, R = 512 * k, 512 * k, 300 * k
n = 33
for i in range(n):
    a = math.radians(-90 + i * 360.0 / n)
    x, y = cx + R * math.cos(a), cy + R * math.sin(a)
    r = 20 * k
    d.ellipse([x - r, y - r, x + r, y + r], fill=gold)
    h = 7 * k
    d.ellipse([x - r * 0.45 - h / 2, y - r * 0.45 - h / 2, x - r * 0.45 + h / 2, y - r * 0.45 + h / 2], fill=light)

# red record dot
rr = 150 * k
d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], fill=(220, 50, 47, 255))
d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], outline=light, width=int(8 * k))

# gold crescent inside the dot
cm = Image.new("L", (S, S), 0)
cd = ImageDraw.Draw(cm)
cd.ellipse([(500 - 80) * k, (512 - 80) * k, (500 + 80) * k, (512 + 80) * k], fill=255)
cd.ellipse([(530 - 68) * k, (500 - 68) * k, (530 + 68) * k, (500 + 68) * k], fill=0)
img.paste(Image.new("RGBA", (S, S), light), (0, 0), cm)

img = img.resize((1024, 1024), Image.LANCZOS)
img.save("Assets/AppIcon.png")
print("saved Assets/AppIcon.png")
