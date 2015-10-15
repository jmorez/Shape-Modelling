%% 1. Import .grid files from <input_dir>. NOTE: use forward slashes!
input_dir='C:/Users/Jan Morez/Documents/MATLAB/Shape-Modelling/grid';
outputdir='C:/Users/Jan Morez/Documents/MATLAB/Shape-Modelling/processed';


if ~exist(outputdir,'dir')
    fprintf(1,'"%s" does not exist. Creating it in current working path.',outputdir);
    mkdir(outputdir);
end
%%
files=dir(input_dir);
n=1;
for j=1:length(files)
    [~,file,ext]=fileparts(files(j).name);
    if ~files(j).isdir && strcmp(ext,'.grid')
        quadData{n}=array2QuadData(grid2Array(strcat(input_dir,'/',files(j).name)));
        n=n+1;
    end 
end
n=n-1;

%% 2. Center 
fprintf(1,'Starting rough registration. \n');
for j=1:n
    fprintf(1,'Centering %d of %d. \n',j,n);
    quadData_c{j}=centerPoints(quadData{j});
end

%% 3. Crop
for j=1:n
    fprintf(1,'Cropping %d of %d. \n',j,n);
    quadData_cr{j}=cropPoints(quadData_c{j});
end

%% 4. Rotate
theta=pi/4;
quadData_r{1}=quadData_cr{1};
for j=2:n
    fprintf(1,'Rotating %d of %d. \n',j,n);
    R=rotz(theta*(j-1));
    quadData_r{j}=quadData_cr{j};
    for k=1:length(quadData_r{j})
        quadData_r{j}(k,2:4)=(R*quadData_cr{j}(k,2:4)')';
    end
end

%% 5. Remove bad quads based on their skewness.
%The treshold determines how skewed a quad can be without being removed.
%Note that angles smaller than pi/4 might result in too much removal.
angle_treshold=pi/4;
disp('Removing bad quads.')
for j=1:n
    fprintf(1,'Removing bad quads in %d of %d. \n',j,n);
    quadData_tr{j}=removeBadQuads(quadData_r{j},angle_treshold);
end

%% 6. ICP
%Subsampling factor
stride=8;
fprintf(1,'Starting fine registration with ICP. Subsampling with 1/%d th of all points. \n',stride);

n=length(quadData_tr);
quadData_t=quadData_tr;

for j=1:(n-1)
    fixed =quadData_t{j+1}(1:stride:end,2:4)';
    moving=quadData_t{j}(1:stride:end,2:4)';
    
    [TR,TT]=icp(fixed,moving);
    
    for k=1:j
        quadData_t{k}=rigidTransform(quadData_t{k},TR,TT);
    end
    fprintf(1,'Registered %d out of %d. \n',j,n-1);
end
%% 7. Convert to triData
disp('Converting quadData to triData.')
for j=1:n
    triData{j}=removeInvalidTriangles(quadData2TriData(quadData_t{j}));
end

%% 7. Apply Non-Rigid ICP
%Subsampling is not immediately possible because we need the face data.
fprintf(1,'Starting fine registration with non-rigid ICP. Subsampling with 1/%d th of all points. \n',stride);

triData_t=triData;
for j=1:(n-1)
    fixed   =triData_t{j+1}{1}(:,2:4)';
    moving  =triData_t{j}{1}(:,2:4)';
    fixed_F	=triData_t{j+1}{2}(:,1:3)';
    moving_F=triData_t{j}{2}(:,1:3)';
    
    for k=1:j
        fixed{k}{1}=nonrigidICP(fixed,moving,fixed_F,moving_F,10,1);
    end
    fprintf(1,'Registered %d out of %d. \n',j,n-1);
end

%% 7. Export
outputdir='processed';
for j=1:n
    file=strcat(outputdir,'/',num2str(j),'.obj');
    triData2Obj(fixed{k},file);
end
