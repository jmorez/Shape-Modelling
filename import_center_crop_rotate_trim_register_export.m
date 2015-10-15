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
%Percentile of quads to keep. Lower means more quads will be removed.
percentile=0.95;
disp('Removing bad quads. \n')
for j=1:n
    fprintf(1,'Removing bad quads in %d of %d. \n',j,n);
    quadData_tr{j}=removeBadQuads(quadData_r{j},percentile);
end

%% 6. ICP
%Subsampling factor
stride=4;
fprintf(1,'Starting fine registration with ICP. Subsampling with 1/%d th of all points. \n',stride);

n=length(quadData_tr);
quadData_t=quadData_tr;

for j=1:(n-1)
    fixed =quadData_t{j+1}(1:stride:end,2:4)';
    moving=quadData_t{j}(1:stride:end,2:4)';
    %% 
    [TR,TT]=icp(fixed,moving);
    %% 
    for k=1:j
        quadData_t{k}=rigidTransform(quadData_t{k},TR,TT);
    end
    fprintf(1,'Registered %d out of %d. \n',j,n-1);
end


%% 7. Export
outputdir='processed';
for j=1:n
    file=strcat(outputdir,'/',num2str(j),'.obj');
    quadData2Obj(quadData_t{j},file);
end
