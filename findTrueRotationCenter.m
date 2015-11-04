function c=findTrueRotationCenter(obj_moving,obj_fixed,dist_treshold)
    %This function will attempt to find the true center of rotation c by
    %using the knowledge of two point clouds that are know to succesfully
    %be registered to eachother
    %% Apply rough outlining and ICP to find matching point pairs
    
    c=[];
    
    %Center objects
    moving_c=centerPoints(obj_moving);
    fixed_c=centerPoints(obj_fixed);
    
    %Crop objects
    moving_cr=cropObject(moving_c);
    fixed_cr=cropObject(fixed_c);
    
    %Rotate object roughly
    theta=pi/4;
    fixed_rot=rotateObjectZ(fixed_cr,pi/4);
    
    %Register objects
    stride=8;
    fprintf(1,'Starting fine registration with ICP. Subsampling with 1/%d th of all points. \n',stride);
    
    %Apply ICP
    fixedvertices =fixed_rot.v(1:stride:end,1:3)';
    movingvertices=moving_cr.v(1:stride:end,1:3)';

    [TR,TT]=icp(fixedvertices,movingvertices,'Matching','kDtree',...
                             'Normals',fixed_rot.vn(1:stride:end,1:3)',...
                             'Minimize','plane',...
                             'WorstRejection',0.4,...
                             'Extrapolation',false);
                         
    moving_reg=rigidTransform(moving_cr,TR,TT);

    %% Find point pairs that are close enough (dist_treshold)
    disp('Matching point pairs and calculating true center...')
    stride=32; %Subsample
    fixedvertices =fixed_rot.v(1:stride:end,1:3);
    movingvertices=moving_reg.v(1:stride:end,1:3);
    
    R=rotz(pi/4);
    R=R(1:2,1:2);
    c=[];
    n=1;
    for j=1:length(fixedvertices)
        point=movingvertices(j,:);
        [idx,distance]=findNearestNeighbors(pointCloud(fixedvertices),point,1);
        
       %Use the original coordinates!!!
        if distance < dist_treshold
            c(n,1:2)=(eye(2,2)-R)\(obj_fixed.v(stride*idx,1:2)'-R*obj_moving.v(stride*j,1:2)');
            weight(n)=distance;
            n=n+1;
        end
        if(mod(j,round(length(fixedvertices)/100))==0)
            fprintf(1,'%d %% \n',round(100*j/length(fixedvertices)));
        end
    end
    weight=weight./(sum(weight));
    disp('Done!')
    %%
    [counts,locs]=hist3(obj_fixed.v(:,1:2),[100 100]);
    %[counts,locs]=hist3(c,[100 100]);
    imagesc(locs{1},locs{2},counts)
    c_true=[sum(weight*c(:,1)) sum(weight*c(:,2 ))];%[mean(locs{1}) mean(locs{2})];
    centroid=[mean(obj_fixed.v(:,1)) mean(obj_fixed.v(:,2))];
    
    hold on
    plot(c_true(1),c_true(2),'ow');
    plot(centroid(1),centroid(2),'or')
    plot(centroid(1),centroid(2),'xr')
    hold off
    c=c_true;
end