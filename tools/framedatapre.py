import os
from PIL import Image

root_path = "C:\\Users\\86150\\Desktop\\haha\\sig_gen"
save1path = "C:\\Users\\86150\\Desktop\\DATA\\PNG"
save2path = "C:\\Users\\86150\\Desktop\\DATA\\RGB"
if not os.path.exists(save1path):
    os.makedirs(save1path)
if not os.path.exists(save2path):
    os.makedirs(save2path)
confirmedString = ["wave", "amp", "fre", "pha", "confirm`"]

sub2path = ['amp', 'duty_cycle', 'frequency', 'phase', 'type', 'wave']
sub2paths = [os.path.join(root_path, subpath) for subpath in sub2path]

empty_path = "C:\\Users\\86150\\Desktop\\haha\\sig_gen\\empty.png"
rec_path = "C:\\Users\\86150\\Desktop\\haha\\sig_gen\\rec.png"
confirm_path = "C:\\Users\\86150\\Desktop\\haha\\sig_gen\\confirm.png"

amp_imgs_compath = [name.split(".p")[0] for name in os.listdir(sub2paths[0])]
fre_imgs_compath = [name.split(".p")[0] for name in os.listdir(sub2paths[2])]
duty_imgs_compath = [name.split(".p")[0] for name in os.listdir(sub2paths[1])]
pha_imgs_compath = [name.split(".p")[0] for name in os.listdir(sub2paths[3])]
type_imgs_compath = [name.split(".p")[0] for name in os.listdir(sub2paths[4])]
wave_imgs_compath = [name.split(".p")[0] for name in os.listdir(sub2paths[5])]

rec_img = Image.open(rec_path)
confirm_img = Image.open(confirm_path)
amp_imgs = [Image.open(img) for img in [os.path.join(sub2paths[0], file) for file in os.listdir(sub2paths[0])]]
fre_imgs = [Image.open(img) for img in [os.path.join(sub2paths[2], file) for file in os.listdir(sub2paths[2])]]
duty_imgs = [Image.open(img) for img in [os.path.join(sub2paths[1], file) for file in os.listdir(sub2paths[1])]]
pha_imgs = [Image.open(img) for img in [os.path.join(sub2paths[3], file) for file in os.listdir(sub2paths[3])]]
type_imgs = [Image.open(img) for img in [os.path.join(sub2paths[4], file) for file in os.listdir(sub2paths[4])]]
wave_imgs = [Image.open(img) for img in [os.path.join(sub2paths[5], file) for file in os.listdir(sub2paths[5])]]

rec_pos = [(13, 109), (13, 199), (13, 294), (13, 387), (13, 480)]
type_pos = (33,126)
wave_pos = {"sin": (610, 160), "square": (609, 167), "triangle": (605, 160), "zigzag": (610, 160)}
amp_pos = (33, 219)
fre_pos = (33, 312)
pha_pos = (33, 405)
confirm_pos = (33, 498)

# confirmedModule + wave + amp + fre + pha/duty
for i in range(len(rec_pos)):
    for j in range(len(type_imgs)):
        for k in range(len(amp_imgs)):
            for l in range(len(fre_imgs)):
                if type_imgs_compath[j] == "square":
                    for m in range(len(duty_imgs)):
                        name = confirmedString[i] + "_" + type_imgs_compath[j] + "_" + amp_imgs_compath[k] + "_" + \
                               fre_imgs_compath[l] + "_" + \
                               duty_imgs_compath[m]
                        savepath = os.path.join(save1path, f"{name}.png")
                        if not os.path.exists(savepath):
                            print(f"{name} Processing\n")
                            empty_img = Image.open(empty_path)
                            empty_img.paste(rec_img, box=rec_pos[i], mask=None)
                            empty_img.paste(type_imgs[j], box=type_pos, mask=None)
                            empty_img.paste(wave_imgs[j], box=wave_pos[wave_imgs_compath[j]], mask=None)
                            empty_img.paste(amp_imgs[k], box=amp_pos, mask=None)
                            empty_img.paste(fre_imgs[l], box=fre_pos, mask=None)
                            empty_img.paste(duty_imgs[m], box=pha_pos, mask=None)
                            empty_img.paste(confirm_img, box=confirm_pos, mask=None)
                            empty_img.save(savepath)
                        else:
                            print(f"{name} existed\n")
                else:
                    for m in range(len(pha_imgs)):
                        name = confirmedString[i] + "_" + type_imgs_compath[j] + "_" + amp_imgs_compath[k] + "_" + \
                               fre_imgs_compath[l] + "_" + \
                               pha_imgs_compath[m]
                        savepath = os.path.join(save1path, f"{name}.png")
                        if not os.path.exists(savepath):
                            print(f"{name} Processing\n")
                            empty_img = Image.open(empty_path)
                            empty_img.paste(rec_img, box=rec_pos[i], mask=None)
                            empty_img.paste(type_imgs[j], box=type_pos, mask=None)
                            empty_img.paste(wave_imgs[j], box=wave_pos[wave_imgs_compath[j]], mask=None)
                            empty_img.paste(amp_imgs[k], box=amp_pos, mask=None)
                            empty_img.paste(fre_imgs[l], box=fre_pos, mask=None)
                            empty_img.paste(pha_imgs[m], box=pha_pos, mask=None)
                            empty_img.paste(confirm_img, box=confirm_pos, mask=None)
                            empty_img.save(savepath)
                        else:
                            print(f'{name} existed\n')

print("PNGing ends\n")

print("RGBing starts\n")
imgs_path = [os.path.join(save1path, img) for img in os.listdir(save1path)]
for img_path in imgs_path:

    datfile_name = img_path.split("\PNG\\")[1].split(".p")[0] + ".dat"
    tol_file_name = os.path.join(save2path, datfile_name)
    if os.path.exists(tol_file_name):
        print(f"{datfile_name} Rewriting")
        f = open(tol_file_name, "w")
        f.close()
    else:
        print(f"{datfile_name} Writing\n")

    c_img = Image.open(img_path)
    rgb_img = c_img.convert("RGB")
    l, h = rgb_img.size

    f = open(tol_file_name, 'a')

    f.write(f"{datfile_name.split('.da')[0]}'s DATA:\n")

    for row in range(h):
        string = f"rgbdata[{row}] <= 24576'H"
        for col in range(l):
            r, g, b = rgb_img.getpixel((col, row))
            if col != l-1:
                string = string + f"{hex(r)[2:]}{hex(g)[2:]}{hex(b)[2:]}"
            else:
                string = string + f"{hex(r)[2:]}{hex(g)[2:]}{hex(b)[2:]};\n"
        f.write(string)

    f.write("\n")
    f.close()

print("=====DATA WRITE END=====")




