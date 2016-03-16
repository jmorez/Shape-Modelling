function [N, phi_ax, theta_ax] = extendedGaussianImage(normals, bins_phi, bins_theta)
    %This function calculates the Extended Gaussian Image of an object. 
    %Input arguments:
    %   normals     An N x 3 vector describing the surface normals. 
    %   bins_amount An integer specifying the amount of bins to use. 
    
    %Output arguments:
    %   N           A matrix with the counts where the first index 
    %               corresponds with the 'elevation', but starting from the
    %               north pole. 
    %               The second index corresponds with the
    %               azimuth
    %   phi_ax      Centers of the phi bins so that they correspond
    %               with the first index of C. 
    %   theta_ax    Centers of the theta bins so that they correspond with
    %               the second index of C. This allows you to plot he image
    %               as a plane: 
    %               imagesc(phi_ax,theta_ax,C);
    
    %Calculate the spherical angles for each normal (using physics
    %convention, see Wolfram Mathworld).
    [phi,theta,~]=cart2sph(normals(:,1),normals(:,2),normals(:,3));
    
    %Calculate the 2D histogram for the pairs of angles.
    phi_bin  =linspace(-pi,pi,bins_phi);
    theta_bin=linspace(-pi/2,pi/2,bins_theta/2);
    
    [N,~]=hist3([phi theta],{phi_bin,theta_bin});
    
    %Rescale the counts so we can use a colormap. 
    N=round(1+63.*(N./max(N(:))));
    
    %Plot the sphere.
    
    [x,y,z] = sphere(bins_amount);    
    cmap=hot;
    close all
    for i = 1:bins_amount
        for j = 1:(bins_amount/2)
            C(i,j,1:3) =cmap(N(i,j),1:3);        
        end
    end
    
    phi_ax=linspace(-pi,pi,bins_amount);
    theta_ax=linspace(0,pi,bins_amount);
    if nargout==0
        surf(x,y,z,C,'EdgeColor','none','LineStyle','none','FaceLighting','phong');
        axis image;
        view(3);
    end
    
end

