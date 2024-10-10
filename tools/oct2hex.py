import os

foct = open("C:\\Users\\86150\\Desktop\\MSE\\cos_256.dat", "r")

fhex = open("C:\\Users\\86150\\Desktop\\MSE\\cos_256hex.dat", "w")

for i in range(256):
    string = foct.readline()
    data = string.split(",")[0]
    data = hex(int(data)).split("x")[1]
    if len(data) == 1:
        data = "0" + data
    fhex.write(f"{data}\n")

foct.close()
fhex.close()
