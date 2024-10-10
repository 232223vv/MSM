import os
from PIL import Image

root_path = "C:\\Users\\86150\\Desktop\\haha\\sig_gen"
save1path = "C:\\Users\\86150\\Desktop\\DATA\\PNG"
save2path = "C:\\Users\\86150\\Desktop\\DATA\\RGB"
if not os.path.exists(save1path):
    os.makedirs(save1path)
if not os.path.exists(save2path):
    os.makedirs(save2path)
confirmedString = ["wave", "amp", "fre", "pha", "confirm"]

sub2path = ['amp', 'duty_cycle', 'frequency', 'phase', 'type', 'wave']
sub2paths = [os.path.join(root_path, subpath) for subpath in sub2path]
empty_path = "C:\\Users\\86150\\Desktop\\haha\\sig_gen\\empty.png"
rec_path = "C:\\Users\\86150\\Desktop\\haha\\sig_gen\\rec.png"
confirm_path = "C:\\Users\\86150\\Desktop\\haha\\sig_gen\\confirm.png"

# name of each module
amp_imgs_compath = [name.split(".p")[0] for name in os.listdir(sub2paths[0])]
fre_imgs_compath = [name.split(".p")[0] for name in os.listdir(sub2paths[2])]
duty_imgs_compath = [name.split(".p")[0] for name in os.listdir(sub2paths[1])]
pha_imgs_compath = [name.split(".p")[0] for name in os.listdir(sub2paths[3])]
type_imgs_compath = [name.split(".p")[0] for name in os.listdir(sub2paths[4])]
wave_imgs_compath = [name.split(".p")[0] for name in os.listdir(sub2paths[5])]

# imgs of each module
rec_img = Image.open(rec_path)
confirm_img = Image.open(confirm_path)
amp_imgs = [Image.open(img) for img in [os.path.join(sub2paths[0], file) for file in os.listdir(sub2paths[0])]]
fre_imgs = [Image.open(img) for img in [os.path.join(sub2paths[2], file) for file in os.listdir(sub2paths[2])]]
duty_imgs = [Image.open(img) for img in [os.path.join(sub2paths[1], file) for file in os.listdir(sub2paths[1])]]
pha_imgs = [Image.open(img) for img in [os.path.join(sub2paths[3], file) for file in os.listdir(sub2paths[3])]]
type_imgs = [Image.open(img) for img in [os.path.join(sub2paths[4], file) for file in os.listdir(sub2paths[4])]]
wave_imgs = [Image.open(img) for img in [os.path.join(sub2paths[5], file) for file in os.listdir(sub2paths[5])]]

# paste pos of each module
rec_pos = [(13, 109), (13, 199), (13, 294), (13, 387), (13, 480)]
type_pos = (33,126)
wave_pos = {"sin": (610, 160), "square": (609, 167), "triangle": (605, 160), "zigzag": (610, 160)}
amp_pos = (33, 219)
fre_pos = (33, 312)
pha_pos = (33, 405)
confirm_pos = (33, 498)

# bitSec of each module
waveSec = {"sin": "00", "square": "01", "triangle": "10", "zigzag": "11"}
ampSec = {"5": "00", "2.5": "01", "1.25": "10", "0.625": "11"}
freSec = {"1MHz": "00", "0.5MHz": "01", "250kHz": "10", "125kHz": "11"}
phaSec = {"0°": "00", "90°": "01", "180°": "10", "270°": "11"}
dutySec = {"30%": "00", "50%": "01", "70%": "10", "90%": "11"}
confirmSec = {"wave": "000", "amp": "001", "fre": "010", "pha": "011", "confirm": "100"}


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
if os.path.exists("C:\\Users\\86150\\Desktop\\DATA\\SigGen.v"):
    f = open("C:\\Users\\86150\\Desktop\\DATA\\SigGen.v", "w")
    f.close()

f = open("C:\\Users\\86150\\Desktop\\DATA\\SigGen.v", 'a')
f.write("case(sig_gen_cnt)\n")
imgs_path = [os.path.join(save1path, img) for img in os.listdir(save1path)]
imgCount = 1
for img_path in imgs_path:
    print(f"{imgCount} \\ {len(imgs_path)}")
    confirm, wave, amp, fre, pha = img_path.split('\\PNG\\')[1].split(".p")[0].split("_")
    c_img = Image.open(img_path)
    rgb_img = c_img.convert("RGB")
    l, h = rgb_img.size

    if wave == "square":
        f.write(f"    11'b{confirmSec[confirm]}{waveSec[wave]}{ampSec[amp]}{freSec[fre]}{dutySec[pha]}: begin\n")
        for row in range(h):
            string = f"        rgbdata[{row}] <= 24576'H"
            for col in range(l):
                r, g, b = rgb_img.getpixel((col, row))
                if col != l - 1:
                    string = string + f"{hex(r)[2:]}{hex(g)[2:]}{hex(b)[2:]}"
                else:
                    string = string + f"{hex(r)[2:]}{hex(g)[2:]}{hex(b)[2:]};\n"
            f.write(string)
        f.write("    end\n")
    else:
        f.write(f"    11'b{confirmSec[confirm]}{waveSec[wave]}{ampSec[amp]}{freSec[fre]}{phaSec[pha]}: begin\n")
        for row in range(h):
            string = f"        rgbdata[{row}] <= 24576'H"
            for col in range(l):
                r, g, b = rgb_img.getpixel((col, row))
                if col != l - 1:
                    string = string + f"{hex(r)[2:]}{hex(g)[2:]}{hex(b)[2:]}"
                else:
                    string = string + f"{hex(r)[2:]}{hex(g)[2:]}{hex(b)[2:]};\n"
            f.write(string)
        f.write("    end\n")

    imgCount += 1

f.write("endcase\n")
f.close()
print("==========END==========")

