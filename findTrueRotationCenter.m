%function c=findTrueRotationCenter(obj_moving,obj_fixed,dist_treshold)
    %This function will attempt to find the true center of rotation c by
    %using the knowledge of two point clouds that are know to succesfully
    %be registered to eachother
    obj_moving=objects_raw{1}; obj_fixed=objects_raw{2}; dist_treshold=0.5;
    %% Apply rough outlining and ICP to find matching point pairs                       
    [moving_reg,TR,TT,cm,cf,fixed_rot]=roughRegistration(obj_fixed,obj_moving);
    
    %% 
    T=TR*rotz(pi/4); %TR Is already a pi/4 rotation, what's going on???
    t=-TR*rotz(pi/4)*cm+TT+cf;
    
    Rh=[T t; 0 0 0 1];
    [V,~]=eigs(Rh);
    ch=V(:,1);  
    rot_axis=real([ch(1) ch(2) ch(3)]); %We now know the direction of the rotation axis, now we can 
    
    
    %% Find point pairs that are close enough (dist_treshold)
    disp('Matching point pairs and calculating true center...')
    stride=32; %Subsample
    fixedvertices =fixed_rot.v(1:stride:end,1:3);
    movingvertices=moving_reg.v(1:stride:end,1:3);
    
    %R=rotz(pi/4);
    R=rotV(rot_axis,pi/4);
    R=R(1:2,1:2);
    c=[];
    n=1;
    
    %
    reverseStr='';
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
            reverseStr=reportToConsole('%d %% \n', reverseStr, round(100*j/length(fixedvertices)));
        end
    end
    weight=weight./(sum(weight));
    disp('Done!')
    %%
    %Show point cloud from z direction
    [counts,locs]=hist3(obj_fixed.v(:,1:2),[100 100]);
    imagesc(locs{1},locs{2},counts)
    
    %Calculate true center
    [counts,locs]=hist3(c,[100 100]);
    %imagesc(locs{1},locs{2},counts)
    c_true=[sum(weight*c(:,1)) sum(weight*c(:,2 ))];%[mean(locs{1}) mean(locs{2})];
    
    %Calculate centroid for comparison
    centroid=[mean(obj_fixed.v(:,1)) mean(obj_fixed.v(:,2))];
    
    hold on
    plot(c_true(1),c_true(2),'ow');
    plot(centroid(1),centroid(2),'or')
    plot(centroid(1),centroid(2),'xr')
    hold off
    c=c_true;
%end