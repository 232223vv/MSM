import os
from PIL import Image

root_paths = "C:\\Users\\86150\\Desktop\\haha"
level2_paths = ["menu"]

# for root_path in root_paths:
for level2_path in level2_paths:
    cur_path = os.path.join(root_paths, level2_path)
    imgs = os.listdir(cur_path)
    cdata_path = os.path.join("C:\\Users\\86150\\Desktop\\data", level2_path)
    if not os.path.exists(cdata_path):
        os.makedirs(cdata_path)
    for img in imgs:
        name = "\\" + img.split(".")[0]
        dat_path = cdata_path + name + ".dat"
        img_path = os.path.join(cur_path, img)
        print(f"Progressing {img_path}\n")
        if os.path.exists(dat_path):
            f = open(dat_path, "w")
            f.close()
        with Image.open(img_path) as image:
            rgb_img = image.convert("RGB")
            f = open(dat_path, "a")
            for row in range(600):
                string = f"        rgbdata[{row}] <= 24576'H"
                for col in range(1024):
                    r, g, b = rgb_img.getpixel((col, row))
                    if col != 1023:
                        string = string + f"{hex(r)[2:]}{hex(g)[2:]}{hex(b)[2:]}"
                    else:
                        string = string + f"{hex(r)[2:]}{hex(g)[2:]}{hex(b)[2:]};\n"
                f.write(string)






