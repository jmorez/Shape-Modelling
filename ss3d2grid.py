#By Jan Morez, Universiteit Antwerpen
#This script will scan <sourcefiledir> for any grid.ss3d files and convert them
#to .grid files (plaintext) in the folder <outputdir>. Change these accordingly.

import io, os, re, shutil, gzip, glob, sys

#Change these accordingly. Glob will scan all subfolders so you can point it to
#a folder that is a few levels above. The last two slashes are important!

inputdir=sys.argv[1] #r"C:/Users/Jan Morez/Documents/Beelden/"
outputdir=sys.argv[2]+"/" #r"C:/Users/Jan Morez/Documents/Outtest/"

os.chdir(inputdir)
#Create folder to store the .gzip files
if not os.path.exists(outputdir):
    os.makedirs(outputdir)
files=glob.glob("**/grid.ss3d",recursive=True)

if files:
    print("Found the following file(s) in \"{}\":".format(inputdir))
    #Find all .ss3d files
    for f in files:
        print(f)
        #Extract the index, could be more robust.
        m=re.search("patch[0-9][0-9][0-9]",f)
        if m:
            idx=m.group()[-3:]
            outfile=outputdir+ str(idx) + ".gzip"
            shutil.copyfile(f,outfile)

    #Decompress and write to a plaintext file.
    print("Decompressing...")
    os.chdir(outputdir)
    files=os.listdir()
    for f in files:
        ext=os.path.splitext(f)[1]
        if ext==".gzip":
            inF=gzip.open(f,'rb')
            data=inF.read()
            inF.close()
            os.remove(f)

            ofName=str(f[:3])+".grid"
            outF=open(ofName,'wb')
            outF.write(data)
            outF.close()
            print("Wrote \"{}\"".format(ofName))
else:
    print("Couldn't find any files in \"{}\"!".format(inputdir))
