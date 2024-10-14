import os
import numpy as np
import matplotlib.pyplot as plt

numOFsample = 2000

x = np.linspace(0, 2*np.pi, numOFsample)
y = (128 * np.sin(x) + 128)
y = y.astype(int)

dat = open(f"D:\\GITProjects\\MSM\\src\\SIGNAL_GENERATER\\cos_{numOFsample}hex.dat", "w")

for item in y:
    data = str(hex(item)).split('x')[1]
    if len(data) == 1:
        data = "0" + data
    dat.writelines(f"{data}\n")

dat.close()