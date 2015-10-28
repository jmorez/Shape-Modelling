import io, os, re, shutil, gzip, glob, sys

inputdir=sys.argv[1]
outputdir=sys.argv[2]+"/"

os.chdir(inputdir)
#Create folder to store the arranged files
if not os.path.exists(outputdir):
    os.makedirs(outputdir)
files=glob.glob("**/*.obj",recursive=True)

for f in files:
    print(f)
    m=re.search("patch[0-9][0-9][0-9]",f)
    if m:
        idx=m.group()[-3:]
        outfile=outputdir+ str(idx) + ".obj"
        print(outfile)
        shutil.copyfile(f,outfile)
