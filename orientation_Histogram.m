function [phi,theta] = orientation_Histogram(object)
    %This function calculates the Gaussian Image, not sure if the final
    %image is correct though. We need to adjust the bin centers to
    %correspond with a uniformly sampled sphere!
    normals=object.vn;
    %Calculate the spherical angles for each normal.
    phi=atan2(normals(:,2),normals(:,1));
    r=sqrt(normals(:,1).^2+normals(:,2).^2+normals(:,3).^2);
    theta=atan2(normals(:,3),r);
    
    %Calculate the 2D histogram for the pairs of angles.
    binsize=200;
    phi_bin=linspace(0,2*pi,binsize);
    theta_bin=linspace(-pi/2,pi/2,binsize);
    %theta_bin=
    [N,~]=hist3([phi theta],[binsize binsize]);
    N=round(1+63.*(N./max(N(:))));
    
    %Map them to a sphere
    [x,y,z] = sphere(binsize);
    cmap=colormap;
    for i = 1:binsize
        for j = 1:binsize
            C(i,j,1:3) = cmap(N(i,j),1:3);        
        end
    end
    surf(x,y,z,C,'EdgeColor','none','LineStyle','none','FaceLighting','phong');
    axis image;
    view(3);
end
