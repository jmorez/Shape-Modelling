%% Parameters
%This is the threshold distance to find point pairs that can be used to calculate the true center.
dist_treshold=5;

%% Input Directories 
base_dir='C:\Users\Jan Morez\Documents\Data\';
% input_dirs={'138','146','125','124','157','85','96','90','109','104','101',...
%             '99','84','81','100','154','152','150','149','145','141','134',...
%             '137','133','103','131','129','113'};
        input_dirs={'133'};

%% Output directories
outputbasedir='C:\Users\Guest\Desktop\RigideRegistratie\';

%% Iterate over all directories
for m=1:length(input_dirs)
    tic
    %% 1. Import .obj files from <input_dir>. 
    % If importObj is buggy/crashes, you can replace it with
    % ./Obsolete/importObj_old.m
    input_dir=backward2ForwardSlash(strcat(base_dir,input_dirs{m}));
    fprintf(1,'Processing directory %s  \n',input_dir);
    outputdir=strcat(outputbasedir,input_dirs{m});
    n=0; %File counter
    files=dir(input_dir);

    for j=1:length(files)
        [~,file,ext]=fileparts(files(j).name);
        if ~files(j).isdir && strcmp(ext,'.obj')
            inputfile=strcat(input_dir,'/',files(j).name);
            objects_raw{n+1}=importObj(inputfile);
            fprintf(1,'importObj: imported %s. \n',inputfile);
            n=n+1;  
        end 
    end
    if n==0
        fprintf(1,'Failed to find any .obj files in "%s"! Aborting... \n',input_dir);
        return
    end
    
    %% 3. Find the true rotation center and use this for rough aligning.
    %The true rotation center is found by assuming that the first and
    %second object can be registered correctly. If that is the case, we can
    %calculate the true center if we assume that the rotation was about the
    %z-axis. We use the mean of two calculated centers by switching object
    %1 and 2 around,because the ICP results might be slightly different or
    %skewed for each registration.
    
    %Subsampling stride for matching pairs. It uses KNN so it is quite
    %expensive so this should be quite large.
    stride_matching=64; 
    
    %ICP subsampling stride
    stride_icp=8;       
    
    disp('Searching for true rotation center, this might take a while.')
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
    %Calculate the mean of the two centers
    c_true=0.5*(c_true1+c_true2);
    
    %% 4. Find a succesful rigid transform. 
    %Here we assume that we can find a correct rigid transformation by
    %centering the first two objects, rotating one by pi/4 about the center
    %we found in step #3 and applying ICP. Afterwards we calculate the
    %total transform (i.e. the combination of the centering, the pi/4
    %rotation and the ICP transform).
    [R, T]=findRigidTransformation(c_true, objects_raw{2},objects_raw{1});
    
    %% 5. Apply the total transform to the remaining objects, except the last one.
    %Since the person stands on a rotating platform and is rotated by pi/4
    %increments about the same center, we can assume that the first
    %succesful transform from step #4 also works for the rest. This is not
    %ideal, but it is close enough so that we can apply a final ICP
    %registration and avoid false minima. If we don't perform this step,
    %the objects will be too misaligned and ICP will not find a correct
    %registration transform.
    
    disp('Rotating all objects using the first-to-second object transformation.')
    theta=pi/4;
    objects_roughly_aligned=objects_raw;
    for j=1:(n-1)
        for k=1:j
            objects_roughly_aligned{k}=rigidTransform(objects_roughly_aligned{k},R,T);
        end
    end  

    disp('Done!')
   
    %% 6. ICP
    %All objects are now roughly aligned, we can now directly apply ICP and
    %expect a correct registration in most cases.
    disp('Applying ICP to the roughly aligned objects.')
    icp_stride=8;
    
    objects_registered=objects_roughly_aligned;
    for j=1:(n-1)        
        fixedObj=downsampleObject(objects_registered{j+1},0.1);
        movingObj=downsampleObject(objects_registered{j},0.1);
        
        fixed =fixedObj.v;
        fixedN =fixedObj.vn;
        moving=movingObj.v;
        movingN=movingObj.vn;
        
        [TR,TT]=icp(fixed',moving','Matching','kDtree',...
                                 'Normals',objects_registered{j+1}.vn(1:icp_stride:end,1:3)',...
                                 'Minimize','plane',...
                                 'WorstRejection',0.4,...
                                 'Extrapolation',false);
                                                        
        for k=1:j
            objects_registered{k}=rigidTransform(objects_registered{k},TR,TT);
        end
        
        fprintf(1,'Registered %d out of %d. \n',j,n-1);
    end
    disp('Done!')

    %% 6. Export the objects to some directory.

    %Create output directory.
    if ~exist(outputdir,'dir')
        fprintf(1,'"%s" does not exist. Directory has been created. %s. \n',outputdir);
        mkdir(outputdir);
    end
    
    for j=1:n 
        file=strcat(backward2ForwardSlash(outputdir),'/',num2str(j),'.obj');
        exportObj(file,objects_registered{j});
        fprintf(1,'exportObj: exported to %s \n',file);
    end
    fprintf(1,'Registration took %f seconds. \n',toc);
end

%Written by Jan Morez, 22/10/2015-9/03/2016
%Visielab, Antwerpen
%jan.morez@gmail.com

