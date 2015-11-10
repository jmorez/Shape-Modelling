%function [T,t]=roughAlign(fixed_obj,moving_obj)
    moving_obj=objects_raw{1}; fixed_obj=objects_raw{2};
    moving_coeffs=pca(moving_obj.v,'Centered',true);
    fixed_coeffs=pca(fixed_obj.v,'Centered',true);
    
    moving_c=centerPoints(moving_obj);
    fixed_c=centerPoints(fixed_obj);
    compareObj(moving_c,fixed_c);
    hold on
    quiver3([0 0 0],[0 0 0],[0 0 0],moving_coeffs(1,:),moving_coeffs(2,:),moving_coeffs(3,:),50,'color',[1 0 0]);
    quiver3([0 0 0],[0 0 0],[0 0 0],fixed_coeffs(1,:),fixed_coeffs(2,:),fixed_coeffs(3,:),50,'color',[0 1 0]);
    hold off
%end