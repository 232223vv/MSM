import os

shape = ["sin", "squ", "tri", "saw"]


for each in shape:
    if os.path.exists(f"signalData\{each}.dat"):
        f = open(f"signalData\{each}.dat", "w")
        f.close()
    with open(f"signalData\{each}.mif") as f:
        while True:
            data = f.readline()
            if data.find("0") == 0:
                dat = data.split(' ')[2].split(';')[0]
                with open(f"signalData\{each}.dat", 'a') as fp:
                    fp.write(f"{dat}\n")
            elif data.find("E") == 0:
                break