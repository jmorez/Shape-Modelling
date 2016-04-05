%This script will search for folders with some triple-decimal name, look in
%the subfolders for all .obj files and put them neatly in a folder called
%'ordered'. 
general_dir=backward2ForwardSlash('C:/Users/Jan Morez/Documents/Data/');
sub_dirs={'32','8','10','12','27','3','17','6','4'};
out_dir=general_dir;

%% We expect the input directories to have the id followed with 'patches', 
% e.g. '45patches', so we add that to the specified sub_dirs cell. 
for j=1:length(sub_dirs)
    %sub_dirs{j}=strcat(sub_dirs{j},'patches');
end

%% Then we iterate over each input directory
for k=1:length(sub_dirs)
    %Set up the absolute path for each input directory. 
    searchdir=strcat(general_dir,strcat(sub_dirs{k},'patches'));
    %Find all .obj files within. 
    result=rdir([searchdir,'\**\*.obj']);
    if isempty(result)
        printf('No .obj files found in %s . Aborting. \n',searchdir);
        return
    end
    
    outdir=strcat(out_dir,sub_dirs{k},'/');
    %Now that we have the absolute path for each file, we extract a unique
    %filename out of it (namely ...\patch01\..., ...\patch02\... etc. ) 
    n=1;
    for j=1:length(result);
        str=result(j).name;
        [startIdx,endIdx]=regexp(str,'patch\d*');
        if  ~isempty(startIdx) && ~isempty(endIdx) && (endIdx(2)-startIdx(2)) > 2
            file_id{n}=str((endIdx(2)-2):(endIdx(2)));
            n=n+1;
        else
            fprintf(1,'Error: please check if the folders have the correct structure, e.g.: \n')
            fprintf(1,'.../32patches/32.15012016/patch021/unit1_cam3d/grid_v02.obj \n')
            fprintf(1,'.../32patches/32.15012016/patch022/unit1_cam3d/grid_v02.obj \n')
            fprintf(1,'etc. \n')
            return
        end
    end
    %basedir=unique(basedir');
    if ~exist(outdir,'dir')
        mkdir(outdir)
    else
        fprintf(1,'Warning: directory "%s" already exists. \n Any contents will be overwritten. Proceed? \n',outdir);
        user_response=input('y/n: ','s');
        idxy=regexp(lower(user_response),'y');
        idxn=regexp(lower(user_response),'n');
        if(~isempty(idxy) && ~isempty(idxn))
            fprintf(1,'Input "%s" is ambiguous. Aborting anyway... \n',user_response);
            return
        elseif strcmp(user_response(idxn),'n')
            disp('User ended script.')
            return
        end
    end
    %Now that we found all files, we can copy them with a new clean
    %filename to a new directory.
    for j=1:length(result)
        infile=result(j).name;
        outfile=strcat(outdir,file_id{j},'.obj');
        copyfile(infile,outfile);
    end
end