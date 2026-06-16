from PIL import Image
import glob
import os

paths = glob.glob(r'C:\Users\JorLo\.gemini\antigravity-cli\brain\53ce7dcc-1cfd-4e81-8627-dd9fb58e5df9\*_chest_*.png')
dest_dir = r'C:\Users\JorLo\Desktop\marvelsurvivors\marvelous-survivors\Structures\Chest'

for p in paths:
    img = Image.open(p).convert('RGBA')
    bg = img.getpixel((0,0))
    datas = img.getdata()
    new_data = []
    for i in datas:
        dist = abs(i[0]-bg[0]) + abs(i[1]-bg[1]) + abs(i[2]-bg[2])
        if dist < 45:
            new_data.append((255,255,255,0))
        else:
            new_data.append(i)
    
    img.putdata(new_data)
    name = 'golden_chest.png' if 'golden' in p else 'normal_chest.png'
    img.save(os.path.join(dest_dir, name), 'PNG')
    print(f"Saved {name}")
