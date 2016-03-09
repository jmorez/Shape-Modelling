function [R, T] = findRigidTransformation(fixed, moving)
    [c_true,~,~,~]=findTrueRotationCenter(fixed, moving, ...
                                                    8, ...
                                                    64, ...
                                                    5);
    %Our rough rotation is pi/4 exactly
    Rr=rotV([0 0 1],-pi/4);
    
    %Rotate around c_true
    centered = rigidTransform(moving, eye(3,3), -c_true);
    rotated  = rigidTransform(  centered, ...
                                rotV([0 0 1],-pi/4), ... 
                                c_true);

    %Downsample the objects so ICP runs a bit faster
    fixed_downsampled=downsampleObject(fixed,0.1);
    moving_downsampled=downsampleObject(rotated,0.1);


    [TR,TT]=icp(fixed_downsampled.v',moving_downsampled.v','Matching','kDtree',...
                             'Normals',fixed_downsampled.vn',...
                             'Minimize','plane',...
                             'WorstRejection',0.4,...
                             'Extrapolation',false);

    registered=rigidTransform(rotated,TR,TT);

    %[~,TR,TT]=icp_mod_point_plane_pyr(moving,movingN,fixed,fixedN,0.05, 100, 3, 1, 10, 0, 0);      
    
    R=TR*Rr;
    T=TR*Rr*(-c_true)'+TR*c_true'+TT;
    showObj(fixed, registered);    
end