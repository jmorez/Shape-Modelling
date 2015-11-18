function R=roughAlign(fixed_obj,moving_obj)

    compareObj(moving_obj,fixed_obj);
    xlabel('x'); ylabel('y'); zlabel('z');
    
    %Find the principal components. These are 3 x 3 matrices with each
    %column a basis vector
    moving_cropped=cropObject(centerObj(moving_obj));
    fixed_cropped=cropObject(centerObj(fixed_obj));
    B_moving=pca(moving_cropped.v,'Centered',true);
    B_fixed=pca(fixed_cropped.v,'Centered',true);

    [~,cm]=centerObj(moving_obj);
    [~,cf]=centerObj(fixed_obj);
    
    %Figure out decent scale for the basis vectors.
    axes=gca;
    xlength=axes.XLim(2)-axes.XLim(1);
    ylength=axes.YLim(2)-axes.YLim(1);
    S=abs(min(xlength,ylength));
    
    
    drawBasis(cm,B_moving,S,'color',[1 0 0],'linewidth',2);
    drawBasis(cf,B_fixed,S,'color',[0 1 0],'linewidth',2);
    
    %First rotation about first principal component (z_moving gets rotated
    %into z_fixed by rotating in a plane perpendicular to both)
    moving_z=B_moving(:,1);
    fixed_z=B_fixed(:,1);
    %Find the angle between both axes
    angle=acos((moving_z'*fixed_z)/(norm(moving_z)*norm(fixed_z)));
    %Set up rotation matrix
    R1=rotV(cross(moving_z,fixed_z),angle);
    
    B1=R1*B_moving;
    %drawBasis([0 0 0],B_new_moving,'color',[0 0 1])
    
    %Rotate around z_fixed (both xy-planes should be aligned now, so we
    %find the angle between the B1 y-axis and the fixed y-axis.
    y_moving=B1(:,2);
    y_fixed=B_fixed(:,2);
    
    angle=acos((y_moving'*y_fixed)/(norm(y_moving)*norm(y_fixed)));
    R2=rotV(fixed_z,-angle);
    R=R2*R1;
    %B_new_moving2=R2*B1;

    %compareObj( rigidTransform(centerObj(moving_obj), R2*R1,(cm-cf)), ...
    %            centerObj(fixed_obj));

end


