%This script will search for folders with some triple-decimal name, look in
%the subfolders for all .obj files and put them neatly in a folder called
%'ordered'. 
general_dir=backward2ForwardSlash('C:/Users/Jan Morez/Documents/Data/');
sub_dirs={'47','49','57','58','59','62','63','69','74','76','15','17','31','32'};
for j=1:length(sub_dirs)
    sub_dirs{j}=strcat(sub_dirs{j},'patches');
end
for k=1:length(sub_dirs)
    searchdir=strcat(general_dir,sub_dirs{k});
    result=rdir([searchdir,'\**\*.obj']);

    %Find all unique base directories
    n=1;
    for j=1:length(result);
        str=result(j).name;
        m=regexp(str,'\d*');
        if length(m) > 1
            basedir{n}=str(1:(m(1)+1));
            n=n+1;
        end
    end
    basedir=unique(basedir');

    %Find all files within these base directories
    n=1;
    for j=1:length(basedir)
        files=rdir([general_dir sub_dirs{j},'\**\*.obj']);
        outdir=strcat(basedir{j},'');
        if ~exist(outdir,'dir')
            mkdir(outdir);
        end

        for k=1:length(files)
            file=files(k).name;
            [m,nm]=regexp(file,'patch\d*','match','split');     
            if ~isempty(m)
                id=regexp(m(2),'\d*','match');
                id=id{1};
                %Copy these files to outdir
                copyfile(file,strcat(outdir,'/',id{1},'.obj'));
                n=n+1;
            end
        end
    end
end