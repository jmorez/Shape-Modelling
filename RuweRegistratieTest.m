%% 2. Center 
disp('Starting rough registration:');
disp('Centering...')
for j=1:2
    objects_centered{j}=centerPoints(objects_raw{j});
    fprintf(1,'Centered %d of %d. \n',j,n);
end

%% 3. Crop
for j=1:2
    fprintf(1,'Cropping %d of %d. \n',j,n);
    objects_cropped{j}=cropObject(objects_centered{j});
end

%% 4. Rotate
theta=pi/4;
objects_rotated{1}=objects_cropped{1};
for j=2
    fprintf(1,'Rotating %d of %d. \n',j,n);
    objects_rotated{j}=rotateObjectZ(objects_cropped{j},theta*(j-1));
end

stride=8;
fprintf(1,'Starting fine registration with ICP. Subsampling with 1/%d th of all points. \n',stride);

objects_registered=objects_rotated;
for j=1:2
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