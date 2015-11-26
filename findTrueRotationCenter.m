%function c=findTrueRotationCenter(obj_moving,obj_fixed,dist_treshold)
    %This function will attempt to find the true center of rotation c by
    %using the knowledge of two point clouds that are know to succesfully
    %be registered to eachother
    dist_treshold=5;


    %% 
    %obj_moving=objects_raw{1}; obj_fixed=rigidTransform(objects_raw{1},rotz(pi/4),c_true); dist_treshold=0.5;
    obj_moving=objects_raw{1}; obj_fixed=objects_raw{2};
    
       %% 
    %compareObj(objects_raw{1},moving_test);
    %% Apply rough outlining and ICP to find matching point pairs   
    disp('Starting rough registration');
    
    %Find centroids
    [moving_centered,cm]=centerObj(obj_moving);
    [fixed_centered,cf]=centerObj(obj_fixed);
    
    %Rotate 45 degrees to prepare for ICP
    moving_rot=rigidTransform(moving_centered,rotz(-pi/4),[0 0 0]);
    
    %% 
    %compareObj(rigidTransform(moving_rot,eye(3,3),[1 1 1]),fixed_centered);
    %compareObj(moving_rot,fixed_centered);

    %% Find ICP transformations
    disp('ICP')
    stride=64;
    [TR,TT]=icp(fixed_centered.v(1:stride:end,1:3)',moving_rot.v(1:stride:end,1:3)', ...
                             'Matching','kDtree',...
                             'Normals',fixed_centered.vn(1:stride:end,1:3)',...
                             'Minimize','plane',...
                             'WorstRejection',0.3,... %0.4
                             'Extrapolation',false);%,...
                             %'iter',300);  %off
                         
    moving_reg=rigidTransform(moving_rot,TR,TT);
    compareObj(moving_reg,fixed_centered);
    %Calculate the general transformation and translation
    T=TR*rotz(pi/4);
    t=-TR*rotz(pi/4)*cm+TT+cf;
    
    %Use these to set up a homogeneous transformation.
    %Note: not really necessary
    Rh=[T t; 0 0 0 1];
    %% 
    %Find the eigenvector (~rotation axis direction). 
    [V,~]=eigs(Rh);
    rot_axis=real(V(1:3,3)); %We now know the direction of the rotation axis, now we can calculate the location
    %NOTE: is the third eigenvector always the axis we are looking for?
    disp('Done!');
    
    %% Find point pairs that are close enough (dist_treshold)
    disp('Matching point pairs and calculating true center...')
    stride=64; %Subsample
    fixedvertices =fixed_centered.v(1:stride:end,1:3);
    movingvertices=moving_reg.v(1:stride:end,1:3);
    
    %R=rotz(pi/4);
    R=rotV(rot_axis,pi/4);
    R=R(1:2,1:2);
    %R=R(1:2,1:2);
    c=[];
    n=1;
    
    %%
    reverseStr='';
    for j=1:min(length(fixedvertices),length(movingvertices))
        %Find point pairs that are close enough
        point=movingvertices(j,:);
        [idx,distance]=findNearestNeighbors(pointCloud(fixedvertices),point,1);
        
       %Given these points, calculate the center (see papers on my desk)...
        if distance < dist_treshold
            c(n,1:2)=(eye(2,2)-R)\(obj_fixed.v(stride*idx,1:2)'-R*obj_moving.v(stride*j,1:2)');
            weight(n)=distance;
            n=n+1;
        end
        if(mod(j,round(length(fixedvertices)/100))==0)
            reverseStr=reportToConsole('%d %% \n', reverseStr, round(100*j/length(fixedvertices)));
        end
    end
    %% Normalize weight
    weight=weight./(sum(weight));
    disp('Done!')
  %% 
    c_true=[weight*c(:,1) weight*c(:,2) 0];
    %c_true2=[mean(c,1) 0];
    %% Let's see if the true rotation center makes any sense
    
    step1=rigidTransform(objects_raw{4},eye(3,3),-c_true);
    step2=rigidTransform(step1,rotz(-pi/4),c_true);
    
    compareObj(step2,objects_raw{5})
    
    %%
%     compareObj(obj_moving,obj_fixed);
%     n=length(c);
%  
%     cx=c(:,1);
%     cy=c(:,2);
%     cz=c(:,3);
%     
%     rx=repmat(rot_axis(1),n,1);
%     ry=repmat(rot_axis(2),n,1);
%     rz=repmat(rot_axis(3),n,1);
    %% 
%     hold on;
%     quiver3(cx,cy,cz,rx,ry,rz,100)
%     hold off
    
%     %Show point cloud from z direction
%     [counts,locs]=hist3(obj_fixed.v(:,1:2),[100 100]);
%     imagesc(locs{1},locs{2},counts)
%     
%     %Calculate true center
%     [counts,locs]=hist3(c,[100 100]);
%     %imagesc(locs{1},locs{2},counts)
%     c_true=[sum(weight*c(:,1)) sum(weight*c(:,2 ))];%[mean(locs{1}) mean(locs{2})];
%     
%     %Calculate centroid for comparison
%     centroid=[mean(obj_fixed.v(:,1)) mean(obj_fixed.v(:,2))];
%     
%     hold on
%     plot(c_true(1),c_true(2),'ow');
%     plot(centroid(1),centroid(2),'or')
%     plot(centroid(1),centroid(2),'xr')
%     hold off
%     c=c_true;
%end