'''
将 input 文件夹中的 png 图像转化为 bmp，保存在 output 文件夹中
'''
from PIL import Image
import numpy as np
import glob

blt_color = (255, 255, 255) # blt color: green
png_list = glob.glob('input/*.png')
for png in png_list:
    img = Image.open(png)
    img = img.convert('RGBA')

    # mask transparent rgb with blt_color
    arr = np.array(img)
    rgb, a = arr[:, :, :3], arr[:, :, 3]
    rgb[a == 0] = blt_color

    # save figure
    Image.fromarray(rgb).save(png.replace('.png', '.bmp').replace('input', 'output'))