%% 1. Import .grid files from <input_dir>. NOTE: use forward slashes!
input_dir='C:/Users/Jan Morez/Documents/MATLAB/Shape-Modelling/137';
outputdir='C:/Users/Jan Morez/Documents/MATLAB/Shape-Modelling/processed';

if ~exist(outputdir,'dir')
    fprintf(1,'"%s" does not exist. Creating it in current working path.',outputdir);
    mkdir(outputdir);
end

%% Import all files found in input_dir
n=0; %File counter
files=dir(input_dir);
disp('Importing files...')
for j=1:length(files)
    [~,file,ext]=fileparts(files(j).name);
    if ~files(j).isdir && strcmp(ext,'.obj')
        objects_raw{n+1}=importOBJ(strcat(input_dir,'/',files(j).name));
        n=n+1;  
    end 
end
if n==0
    fprintf(1,'Failed to find any .obj files in "%s"! Aborting... \n',input_dir);
    return
end

%% 2. Center 
disp('Starting rough registration:');
disp('Centering...')
for j=1:n
    objects_centered{j}=centerPoints(objects_raw{j});
    fprintf(1,'Centered %d of %d. \n',j,n);
end

%% 3. Crop
for j=1:n
    fprintf(1,'Cropping %d of %d. \n',j,n);
    objects_cropped{j}=cropObject(objects_centered{j});
end

%% 4. Rotate
theta=pi/4;
objects_rotated{1}=objects_cropped{1};
for j=2:n
    fprintf(1,'Rotating %d of %d. \n',j,n);
    objects_rotated{j}=rotateObjectZ(objects_cropped{j},theta*(j-1));
end

%% 5. Remove bad quads based on their skewness.
%Bypassing this for a moment...
objects_clean=objects_rotated;

%The treshold determines how skewed a quad can be without being removed.
%Note that angles smaller than pi/4 might result in too much removal.
% angle_treshold=pi/4;
% disp('Removing bad quads.')
% for j=1:n
%     fprintf(1,'Removing bad quads in %d of %d. \n',j,n);
%     objects_clean{j}=removeBadQuads(objects_rotated{j},angle_treshold);
%     
%     file=strcat(outputdir,'/clean',num2str(j),'.obj');
%     exportOBJ(objects_clean{j},file);
%     
% end

%% 6. ICP
%Subsampling factor
stride=8;
fprintf(1,'Starting fine registration with ICP. Subsampling with 1/%d th of all points. \n',stride);

n=length(objects_clean);
objects_t=objects_clean;

for j=1:(n-1)
    fixed =objects_t{j+1}.v(1:stride:end,1:3)';
    moving=objects_t{j}.v(1:stride:end,1:3)';
    
    [TR,TT]=icp(fixed,moving);
    
    for k=1:j
        objects_t{k}=rigidTransform(objects_t{k},TR,TT);
    end
    fprintf(1,'Registered %d out of %d. \n',j,n-1);
    
    %% Export
    file=strcat(outputdir,'/',num2str(j),'.obj');
    exportOBJ(objects_t{j},file);
end

file=strcat(outputdir,'/',num2str(n),'.obj');
exportOBJ(objects_t{n},file);

%Written by Jan Morez, 22/10/2015
%Visielab, Antwerpen
%jan.morez@gmail.com

