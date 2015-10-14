function visualizePointCloud(file)
    quads=grid2array(file);
    %%
    %quads=quads(quads(:,4)<210,:);
    %quads=quads(quads(:,3)>-25,:);
    %%
    ptCloud=pointCloud(quads(:,2:4));
    ptCloudDenoised=pcdenoise(ptCloud);
    pcshow(ptCloudDenoised);

    xlabel('x')
    ylabel('y')
    zlabel('z')
end