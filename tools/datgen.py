import os
import numpy as np
import matplotlib.pyplot as plt

numOFsample = 256
dataFile = ["sin"]
# squ_duty = [0.3, 0.5, 0.7, 0.9]

sin_cnt = np.linspace(0, 2*np.pi, numOFsample)
sin_data = (32768 * np.cos(sin_cnt) + 32768)
sin_data = sin_data.astype(int)
print(f"{len(sin_data)}\n")

# s2_cnt = [i for i in range(numOFsample)]
# saw_data = [int(i * 255 / (numOFsample - 1)) for i in s2_cnt]
# print(f"{len(saw_data)}\n")
# squ30_data = []
# squ50_data = []
# squ70_data = []
# squ90_data = []
# for i in squ_duty:
#     duty = numOFsample * i



# plt.plot(s2_cnt, saw_data)
# plt.show()

# tri_cnt = [numOFsample - i if i >= (numOFsample / 2) else i for i in range(numOFsample)]
# tri_data = [int(i * 255 / (numOFsample / 2)) for i in tri_cnt]
# print(f"{len(tri_data)}\n")
# print(f"{tri_data[1000]} / {tri_data[1999]}\n")
# plt.plot(s2_cnt, tri_data)
# plt.show()

for wave in dataFile:
    f = open(f"D:\\GITProjects\\MSM\\src\\{wave}_{numOFsample}hex.dat", "w")
    if(wave == "sin"):
        for item in sin_data:
            print(item)
            data = str(hex(item)).split("x")[1]
            if len(data) == 1:
                data = "000" + data
            elif len(data) == 2:
                data = "00" + data
            elif len(data) == 3:
                data = "0" + data
            f.write(f"{data}\n")
    elif(wave == "tri"):
        for item in tri_data:
            data = str(hex(item)).split("x")[1]
            if len(data) == 1:
                data = "0" + data
            f.write(f"{data}\n")
    elif(wave == "saw"):
        for item in saw_data:
            data = str(hex(item)).split("x")[1]
            if len(data) == 1:
                data = "0" + data
            f.write(f"{data}\n")
    f.close()
