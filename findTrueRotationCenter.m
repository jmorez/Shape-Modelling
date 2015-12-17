function [c_true,true_rotation_axis,cn,c_truew]=findTrueRotationCenter(obj_moving,obj_fixed,stride_icp,stride_matching,dist_treshold)
    %Idea: apply it twice, switching moving with fixed to get double the
    %population
    %This function will attempt to find the true center of rotation c    
    %assuming that obj_moving and obj_fixed can be registered relatively
    %easy. If this function spews nonsense, compare the overlap of
    %moving_reg and fixed_centered! It should be near perfect.
    
    %stride: will be used to subsample the data when searching for nearest
    %neighbours. Highly advised (e.g. 64)!
    
    %dist_treshold: determines which point pairs will be used to calculate
    %the true center, smaller values will give a smaller sample size but
    %possibly less variance and mutatis mutandum for larger values
    %(typically set to 0.5 < dist_treshold < 5)
    
    
    %%%%%%%%%%%%%%%%%%%%%Rough Aligning & ICP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Center data
    [moving_centered,~]=centerObj(obj_moving);
    [fixed_centered,~]=centerObj(obj_fixed);
    
    %Rotate 45 degrees to prepare for ICP
    moving_rot=rigidTransform(moving_centered,rotz(-pi/4),[0 0 0]);
    
    %Find ICP transformations
    %Idea: increase sample size by perturbing moving a bit and applying ICP
    %again.
    disp('findTrueRotationCenter: applying ICP.')
    [TR,TT]=icp(fixed_centered.v(1:stride_icp:end,1:3)',moving_rot.v(1:stride_icp:end,1:3)', ...
                             'Matching','kDtree',...
                             'Normals',fixed_centered.vn(1:stride_icp:end,1:3)',...
                             'Minimize','plane',...
                             'WorstRejection',0.3,... %0.4
                             'Extrapolation',false);
                         
    %Apply the ICP transformation and calculate the total transformation
    %(i.e. including centering and the 45 degree-rotation).
    moving_registered=rigidTransform(moving_rot,TR,TT);
    %showObj({moving_registered,fixed_centered});
    
    
    %Calculate the general transformation and translation
    T=TR*rotz(pi/4);
    %t=-TR*rotz(pi/4)*cm+TT+cf;

    %Find the eigenvector (~rotation axis direction).
    [V,~]=eigs(T);
    %Sometimes eigs returns complex vectors due to machine error.
    true_rotation_axis=real(V(:,3)); 
    
    %%%%%%%%%%%%%%%%%%%%Calculation of the true center%%%%%%%%%%%%%%%%%%%%%
    %We now know the direction of the rotation axis, now we can calculate
    %the location using a vector expression.
    
    %NOTE: is the third eigenvector always the axis we are looking for?

    % Find point pairs that are close enough (dist_treshold)
    disp('findTrueRotationCenter: matching point pairs and calculating true center.')
    
    fixedvertices =fixed_centered.v(1:stride_matching:end,1:3);
    movingvertices=moving_registered.v(1:stride_matching:end,1:3);
    
    %% Can also be a pure z-axis.
    R=rotV([0 0 1],pi/4);
    %Restrict the system to the x- and y-coordinates, z is not needed and
    %results in a badly conditioned matrix anyway.
    R=R(1:2,1:2);
    
    %Count the number of point pairs
    n=1;
    %Needed for progress report
    reverseStr=''; 
    
    %Calculate the true center for all point pairs that are sufficiently
    %close to eachother. Keep the distance as a weight when averaging all
    %these values.
    numpoints=min(length(fixedvertices),length(movingvertices))-1;
    for j=1:numpoints
        point=movingvertices(j,:);
        [idx,distance]=findNearestNeighbors(pointCloud(fixedvertices),point,1);
       %Given these points, calculate the center (see papers on my desk)...
        if distance < dist_treshold
            cn(n,1:2)=(eye(2,2)-R)\(obj_fixed.v(stride_matching*idx,1:2)'-R*obj_moving.v(stride_matching*j,1:2)');
            weight(n)=distance;
            n=n+1;
        end
        %Report progress
        if(mod(j,round(numpoints/100))==0)
            reverseStr=reportToConsole('%d %% \n', reverseStr, round(100*j/numpoints));
        end
    end
	%Normalize weight, append the z-component to get a 3D vector
    weight=weight./(sum(weight));
    c_truew=[weight*cn(:,1) weight*cn(:,2) 0];  
    c_true=[mean(cn(:,1)) mean(cn(:,2)) 0];  
end

%Written by Jan Morez 
%Visielab, Antwerpen 
%jan.morez@gmail.com