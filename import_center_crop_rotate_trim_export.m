clear all;
%Sections
%% 1. Import
input_dir='grid';
files=dir(input_dir);
n=1;
clear quadData;
for j=1:length(files)
    [~,file,ext]=fileparts(files(j).name);
    if ~files(j).isdir && strcmp(ext,'.grid')
        quadData{n}=array2quaddata(grid2array(strcat(input_dir,'/',files(j).name)));
        n=n+1;
    end 
end
n=n-1;
%% 2. Center 
for j=1:n
    quadData_c{j}=centerPoints(quadData{j});
end

%% 3. Crop
for j=1:n
    quadData_cr{j}=cropPoints(quadData_c{j});
end

%% 4. Rotate 
%Rotate each set over an angle <theta> corresponding with the angle the
%platform makes for each view.
theta=pi/4;
quadData_r{1}=quadData_cr{1};
for j=2:n
    R=rotz(theta*(j-1));
    quadData_r{j}=quadData_cr{j};
    for k=1:length(quadData_r{j})
        quadData_r{j}(k,2:4)=(R*quadData_cr{j}(k,2:4)')';
    end
end

%% 5. ICP Registration
%Subsampling factor, improves speed a lot.
stride=4;

%Initialize target set.
quadData_t=quadData_r;

%Transform each set
for j=1:(n-1)
    fixed =quadData_t{j+1}(1:stride:end,2:4)';
    moving=quadData_t{j}(1:stride:end,2:4)';
    %% 
    [TR,TT]=icp(fixed,moving);
    %% 
    for k=1:j
        quadData_t{k}=rigidtransform(quadData_t{k},TR,TT);
    end
    fprintf(1,'Registered %d out of %d. \n',j,n-1);
end

%% 6. Remove bad quads based on their skewness.
%Percentile of quads to keep. Lower means more quads will be removed.
percentile=0.975;

for j=1:n
    quadData_tr{j}=removeBadQuads(quadData_t{j},percentile);
end

%% 7. Export
outputdir='processed';
for j=1:n
    file=strcat(outputdir,'/',num2str(j),'.obj');
    quaddata2obj(quadData_tr{j},file);
end
