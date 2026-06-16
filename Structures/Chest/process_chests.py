from PIL import Image
import glob
import os

p = glob.glob(r'C:\Users\JorLo\.gemini\antigravity-cli\brain\53ce7dcc-1cfd-4e81-8627-dd9fb58e5df9\*normal_chest_*.png')[0]
img = Image.open(p).convert('RGBA')
pixels = img.load()
w, h = img.size
bg = pixels[0, 0]

to_v = [(x,0) for x in range(w)] + [(x,h-1) for x in range(w)] + [(0,y) for y in range(h)] + [(w-1,y) for y in range(h)]
vis = set()

while to_v:
    x, y = to_v.pop()
    if (x, y) in vis or x < 0 or x >= w or y < 0 or y >= h:
        continue
    vis.add((x, y))
    
    if pixels[x, y] == bg:
        pixels[x, y] = (255, 255, 255, 0)
        to_v.extend([(x+1, y), (x-1, y), (x, y+1), (x, y-1)])

img.save(r'C:\Users\JorLo\Desktop\marvelsurvivors\marvelous-survivors\Structures\Chest\normal_chest.png', 'PNG')
