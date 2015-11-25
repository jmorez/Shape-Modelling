%% Input Directories 
base_dir='C:/Users/Jan Morez/Documents/Data/';

%input_dirs={'113','129','131','133','134','137','141','145','149','150','152','154','100'};
input_dirs={'109'};

%% 
for m=1:length(input_dirs)
    %% 1. Import .grid files from <input_dir>. NOTE: use forward slashes!
    input_dir=strcat(base_dir,input_dirs{m});%'C:/Users/Jan Morez/Documents/Data/131';
    %outputdir=strcat('C:/Users/Guest/Desktop/RigideRegistratie/',input_dirs{m});
    outputdir=strcat('C:\Users\Jan Morez\Documents\',input_dirs{m});
    fprintf(1,'Processing %s . \n',input_dir);
    
    % Import all files found in input_dir
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
    
    %% 3. Rough aligning (centering & aligning z-axes), then transforming all aligned axes to be aligned with z=[0 0 1]
    objects_roughly_aligned=objects_raw;
    reverseStr='';
    for j=1:n 
        reverseStr=reportToConsole('Roughly aligning %d of %d. \n',reverseStr,j,n);
        for k=1:(j-1)
            objects_roughly_aligned{k}=roughAlign(objects_roughly_aligned{k+1},objects_roughly_aligned{k});
        end
    end
    %The last object should just be centered, not aligned as all the other
    %objects are aligned to it. 
    %Suggestion: align with the absolute z-axis!
    objects_roughly_aligned{n}=centerObj(objects_raw{n});
    
    disp('Done!')
    %% 4. Rotate
    theta=pi/4;
    objects_rotated{1}=objects_roughly_aligned{1};
    for j=2:n
        fprintf(1,'Rotating %d of %d. \n',j,n);
        objects_rotated{j}=rotateObjectZ(centerObj(objects_roughly_aligned{j}),theta*(j-1));
    end

    %% 5. Remove bad quads based on their skewness.
    %Bypassing this for a moment...
    objects_clean=objects_rotated;

    % %The treshold determines how skewed a quad can be without being removed.
    % %Note that angles smaller than pi/4 might result in too much removal.
    % angle_treshold=pi/4;
    % disp('Removing bad quads.')
    % for j=1:n
    %     fprintf(1,'Removing bad quads in %d of %d. \n',j,n);
    %     objects_clean{j}=removeBadQuads(objects_rotated{j},angle_treshold);
    %     
    %     file=strcat(outputdir,'/clean',num2str(j),'.obj');
    %     exportOBJ(objects_clean{j},file);
    %      
    %  end

    %% 6. ICP
    %Subsampling factor
    %Idee: volgorde van registratie aanpassen, altijd de kleinste dataset
    %registreren aan de grotere
    stride=8;
    fprintf(1,'Starting fine registration with ICP. Subsampling with 1/%d th of all points. \n',stride);

    objects_registered=objects_clean;
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
      %% 7. Non-rigid ICP
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
    
    %% Export

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

