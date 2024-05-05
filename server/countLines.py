import os,pathlib
files = 0
line = 0
chars = 0
output = ""
for folder in os.walk(pathlib.Path(__file__).parent.resolve()):
    if len(folder) == 3:
        for file in folder[2]:
            with open(folder[0]+"/"+file) as f:
                lines = f.readlines()
                line += len(lines)
                for x in lines:
                    chars += len(x)
                    output += x
            files += 1
print("lines: "+str(line))
print("chars: "+str(chars))
print("files: "+str(files))
with open("countLinesOutput.txt",'w') as f:
    f.write(output)