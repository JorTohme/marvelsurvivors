from PIL import Image

def process_image(src_path, dest_path):
    img = Image.open(src_path).convert('RGBA')
    pixels = img.load()
    width, height = img.size
    bg_color = pixels[0, 0]
    
    # Tolerancia para color de fondo
    def is_bg(c):
        return abs(c[0] - bg_color[0]) + abs(c[1] - bg_color[1]) + abs(c[2] - bg_color[2]) < 45

    # BFS para flood fill desde el (0,0) y los bordes
    to_visit = []
    for x in range(width):
        to_visit.append((x, 0))
        to_visit.append((x, height - 1))
    for y in range(height):
        to_visit.append((0, y))
        to_visit.append((width - 1, y))

    visited = set()
    while to_visit:
        x, y = to_visit.pop()
        if (x, y) in visited:
            continue
        visited.add((x, y))
        if x < 0 or x >= width or y < 0 or y >= height:
            continue
        if is_bg(pixels[x, y]):
            pixels[x, y] = (255, 255, 255, 0)
            to_visit.append((x + 1, y))
            to_visit.append((x - 1, y))
            to_visit.append((x, y + 1))
            to_visit.append((x, y - 1))

    img.save(dest_path, 'PNG')

import glob
paths = glob.glob(r'C:\Users\JorLo\.gemini\antigravity-cli\brain\53ce7dcc-1cfd-4e81-8627-dd9fb58e5df9\*_chest_*.png')
dest_dir = r'C:\Users\JorLo\Desktop\marvelsurvivors\marvelous-survivors\Structures\Chest'
import os
for p in paths:
    name = 'golden_chest.png' if 'golden' in p else 'normal_chest.png'
    process_image(p, os.path.join(dest_dir, name))
    print(f"Processed {name}")
