%% Parameters
dist_treshold=5;

%% Input Directories 
base_dir='C:\Users\Jan Morez\Documents\Data\';

%input_dirs={'113','129','131','133','134','137','141','145','149','150','152','154','100'};
input_dirs={'90','96','85','157','125','124'};
h=figure;

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
    stride_matching=64;
    stride_icp=8;
    [c_true,rotation_axis]=findTrueRotationCenter(  objects_raw{1}, ...
                                                    objects_raw{2}, ...
                                                    stride_icp, ...
                                                    stride_matching, ...
                                                    dist_treshold);
    disp('Done!')
    
    %% 4. Rough aligning by rotating around j*pi/4 
    disp('Rotating all objects around this center.')
    theta=pi/4;
    for j=1:n
        centered=rigidTransform(objects_raw{j}, eye(3,3), -c_true);
        objects_rotated{j}=rigidTransform(  centered, ...
                                            rotV([0 0 1],-theta*(n-j)), ... %This works better than the calculated axis...
                                            c_true);
    end  
    disp('Done!')
    figure(h)
    showObj(objects_rotated)
    title(input_dirs{m});
    view(3)
    drawnow

    %% 5. ICP
    %Subsampling factor
    %Idee: volgorde van registratie aanpassen, altijd de kleinste dataset
    %registreren aan de grotere
    stride=8;
    fprintf(1,'Starting fine registration with ICP. Subsampling with 1/%d th of all points. \n',stride);

    objects_registered=objects_rotated;
    for j=1:(n-1)
        fixed =objects_registered{j+1}.v(1:stride:end,1:3)';
        moving=objects_registered{j}.v(1:stride:end,1:3)';
        
        [TR,TT]=icp(fixed,moving,'Matching','kDtree',...
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
    
      %% 7. Non-rigid ICP (currently on hold)
%     objects_nrregistered=objects_registered;
%     for j=1:(n-1)
%         fixed =objects_nrregistered{j+1};
%         moving=objects_nrregistered{j};
%         
%         %Subsample/simplify with QSlim
%         fixedV=fixed.v(1:stride:end,1:3);
%         movingV=moving.v(1:stride:end,1:3);
%         
%         %Subsampling will affect indices, so we need to get the right
%         %facedata
%         
%         
%         %Now we can get the correct facedata.
%         fixedF=quads2Triangles(fixedtrimmed.f);
%         movingF=quads2Triangles(movingtrimmed.f);
%             
%         objects_nrregistered{j}=nonrigidICP(fixedV,movingV,fixedF,movingF,50,1);
%         fprintf(1,'Registered %d out of %d. \n',j,n-1);
%     end
    
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
%Written by Jan Morez, 22/10/2015
%Visielab, Antwerpen
%jan.morez@gmail.com

