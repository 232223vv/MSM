import os
string = []
f = open("C:\\Users\\86150\\Desktop\\MSM\\cos_1024hex.dat", "r")
for i in range(1024):
    string.append(f.readline())

f.close()

f = open("C:\\Users\\86150\\Desktop\\MSM\\cos_1024hex.dat", "w")
for i in range(1024):
    f.write(string[i].split(",")[0] + "\n")