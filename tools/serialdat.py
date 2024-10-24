f = open("c:\\Users\\86150\\Desktop\\sin_256hex.dat", "r")
string  = "error"
for i in range(256):
    data = f.readline().split("\n")[0]
    string = string + data

f.close()
f = open("c:\\Users\\86150\\Desktop\\sin1024.txt", "w")
string = "4096'h" + string.split("error")[1] + ";"
f.write(string)
f.close()

