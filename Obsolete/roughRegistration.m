function [obj_registered,TR,TT,cm,cf,moving_rot]=roughRegistration(obj_fixed,obj_moving)
    %TR: ICP rotation matrix
    %TT: ICP translation vector
    %cm: centroid of moving object
    %cf: centroid of fixed object
    
    %Center objects so we can rotate them.
    [moving_c,cm]=centerObj(obj_moving);
    [fixed_c,cf] =centerObj(obj_fixed);
    
    %Crop objects (not entirely necessary)
    moving_cr=cropObject(moving_c);
    fixed_cr=cropObject(fixed_c);
    
    %Rotate object roughly.
    theta=-pi/4;
    moving_rot=rotateObjectZ(moving_cr,theta);
    
    %Register objects
    stride=8;
    fprintf(1,'Starting fine registration with ICP. Subsampling with 1/%d th of all points. \n',stride);
    
    %Apply ICP
    fixedvertices =fixed_cr.v(1:stride:end,1:3)';
    movingvertices=moving_rot.v(1:stride:end,1:3)';

    [TR,TT]=icp(fixedvertices,movingvertices,'Matching','kDtree',...
                             'Normals',fixed_cr.vn(1:stride:end,1:3)',...
                             'Minimize','plane',...
                             'WorstRejection',0.5,... %0.4
                             'Extrapolation',false);%,...
                             %'iter',300);  %off
                         
    obj_registered=rigidTransform(moving_rot,TR,TT);
end

%Written by Jan Morez
%Visielab, Antwerpen
%jan.morez@gmail.com