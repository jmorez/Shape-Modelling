%% Import
input_dir='grid';
files=dir(input_dir);
n=1;
clear quadData;
for j=1:length(files)
    [~,file,ext]=fileparts(files(j).name);
    if ~files(j).isdir && strcmp(ext,'.grid')
        strcmp(ext,'.grid')
        quadData{n}=array2quaddata(grid2array(strcat(input_dir,'/',files(j).name)));
        n=n+1;
    end 
end
n=n-1;
%% Center 
for j=1:n
    quadData_c{j}=centerPoints(quadData{j});
end

%% Crop
for j=1:n
    quadData_cr{j}=cropPoints(quadData_c{j});
end

%% Rotate
theta=pi/4;
quadData_r{1}=quadData_cr{1};
for j=2:n
    R=rotz(theta*(j-1));
    quadData_r{j}=quadData_cr{j};
    for k=1:length(quadData_r{j})
        quadData_r{j}(k,2:4)=(R*quadData_cr{j}(k,2:4)')';
    end
end

%% Remove bad quads

for j=1:n
    quadData_tr=removeBadQuads(quadData_r{j},percentile);
end

%% Export
outputdir='processed';
for j=1:n
    file=strcat(outputdir,'/',num2str(j),'.obj');
    quaddata2obj(quadData_tr{j},file);
end
