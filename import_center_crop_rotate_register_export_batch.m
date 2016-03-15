%% Parameters
dist_treshold=5;

%% Input Directories 
base_dir='C:\Users\Jan Morez\Documents\Data\';
%input_dirs={'31','17','15'};
%Tot nu toe gedaan: '74','76','69','63','62','59','58','57','49',
input_dirs={'47','151','143', ... 
            '138','146','125','124','157','85','96','90','109','104','101',...
            '99','84','81','100','154','152','150','149','145','141','134',...
            '137','133','103','131','129','113'};

%% Iterate over all directories
for m=1:length(input_dirs)
    %% 1. Import .grid files from <input_dir>. 
    input_dir=strcat(base_dir,input_dirs{m});%'C:/Users/Jan Morez/Documents/Data/131';
    %outputdir=strcat('C:/Users/Guest/Desktop/RigideRegistratie/',input_dirs{m});
    outputdir=strcat('C:\Users\Guest\Desktop\RigideRegistratie\',input_dirs{m});
    fprintf(1,'Processing %s . \n',input_dir);

    n=0; %File counter
    files=dir(input_dir);
    disp('Importing files...')
    for j=1:length(files)
        [~,file,ext]=fileparts(files(j).name);
        if ~files(j).isdir && strcmp(ext,'.obj')
            objects_raw{n+1}=importObj(strcat(input_dir,'/',files(j).name));
            n=n+1;  
        end 
    end
    if n==0
        fprintf(1,'Failed to find any .obj files in "%s"! Aborting... \n',input_dir);
        return
    end
    
    %% 3. Find the true rotation center and use this for rough aligning.
    disp('Searching for true rotation center, this might take a while.')
    stride_matching=64; %Different subsampling stride for matching pairs, as it uses KNN so it is quite expensive.
    stride_icp=8;
    c_true1=findTrueRotationCenter(objects_raw{1}, ...
                                                    objects_raw{2}, ...
                                                    stride_icp, ...
                                                    stride_matching, ...
                                                    dist_treshold);
    %% 
    c_true2=findTrueRotationCenter(objects_raw{2}, ...
                                                    objects_raw{1}, ...
                                                    stride_icp, ...
                                                    stride_matching, ...
                                                    dist_treshold);
 
    c_true=0.5*(c_true1+c_true2);
    
    %% Find a succesful rigid transform 
    [R, T]=findRigidTransformation(c_true, objects_raw{2},objects_raw{1});
    
    %% 4. Apply it to the remaining objects, except the last one
    disp('Rotating all objects using the first-to-second object transformation.')
    theta=pi/4;
    objects_roughly_aligned=objects_raw;
    for j=1:(n-1)
        for k=1:j
            objects_roughly_aligned{k}=rigidTransform(objects_roughly_aligned{k},R,T);
        end
    end  

    disp('Done!')
   
    %% 5. ICP
    stride=8;

    objects_registered=objects_roughly_aligned;
    for j=1:(n-1)        
        fixedObj=downsampleObject(objects_registered{j+1},0.1);
        movingObj=downsampleObject(objects_registered{j},0.1);
        
        fixed =fixedObj.v;
        fixedN =fixedObj.vn;
        moving=movingObj.v;
        movingN=movingObj.vn;
        
        [TR,TT]=icp(fixed',moving','Matching','kDtree',...
                                 'Normals',objects_registered{j+1}.vn(1:stride:end,1:3)',...
                                 'Minimize','plane',...
                                 'WorstRejection',0.4,...
                                 'Extrapolation',false);
                                                        
        for k=1:j
            objects_registered{k}=rigidTransform(objects_registered{k},TR,TT);
        end
        
        fprintf(1,'Registered %d out of %d. \n',j,n-1);
    end
    disp('Done!')

    %% 6. Export

    %Create output directory.
    if ~exist(outputdir,'dir')
        fprintf(1,'"%s" does not exist. Directory has been created. %s. \n',outputdir);
        mkdir(outputdir);
    end

    for j=1:n
        file=strcat(outputdir,'/',num2str(j),'.obj');
        %exportOBJ(objects_nrregistered{j},file);
        exportObj(objects_registered{j},file);
    end
    %Something weird happens to this variable when opening a single
    %folder...
    alldata{m}=objects_raw;
end
%Written by Jan Morez, 22/10/2015-9/03/2016
%Visielab, Antwerpen
%jan.morez@gmail.com

