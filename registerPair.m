function object_registered = registerPair(object_fixed,object_moving)
%Subsampling factor
    stride=8;
    fixed =object_fixed.v(1:stride:end,1:3)';
    moving=object_moving.v(1:stride:end,1:3)';
    [TR,TT]=icp(fixed,moving,'Normals',);
    object_registered=rigidTransform(object_moving,TR,TT);
end

