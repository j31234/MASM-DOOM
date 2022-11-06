'''
将 input 文件夹中的 png 图像转化为 bmp，保存在 output 文件夹中
'''
from PIL import Image
import numpy as np
import glob
import os

blt_color = (255, 255, 255) # blt color: white
png_list = glob.glob('input/*.bmp')
if not os.path.isdir('output'):
    os.mkdir('output')
for shift_times, color in enumerate(['red', 'green', 'blue']):
    if not os.path.isdir(color):
        os.mkdir(color)

    for png in png_list:
        img = Image.open(png)

        rgb = np.array(img)

        # r -> g, g -> b, b -> r
        for _ in range(shift_times):
            rgb = rgb[:, :, [2, 0, 1]]

        # save figure
        Image.fromarray(rgb).save(png.replace('.png', '.bmp').replace('input', color))