#By Jan Morez, Universiteit Antwerpen
#This script will scan <sourcefiledir> for any grid.ss3d files and convert them 
#to simple text files in the folder "converted"

import io, os, re, shutil, gzip, glob
sourcefiledir=r"C:\Users\Jan Morez\Documents\Beelden\18092015\105"
os.chdir(sourcefiledir)
#Create folder to store the .gzip files
if not os.path.exists("converted"):
    os.makedirs("converted")
    
print("Found the following file(s):")
#Find all .ss3d files
for f in glob.glob("**/grid.ss3d",recursive=True):
    print(f)
    #Extract the index, could be more robust. 
    m=re.search("patch[0-9][0-9][0-9]",f)
    if m:
       idx=m.group()[-3:]
       outfile="converted\\"+ str(idx) + ".gzip"
       shutil.copyfile(f,outfile)
        
#Decompress and write to a plaintext file.
os.chdir("converted")
files=os.listdir()
for f in files:
    inF=gzip.open(f,'rb')
    data=inF.read()
    inF.close()
    os.remove(f)
    
    ofName=str(f[:3])+".txt"
    outF=open(ofName,'wb')
    outF.write(data)
    outF.close()