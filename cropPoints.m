function quadData_Cropped=cropPoints(quadData)
    %It will remove all points outside a 
    %cylinder with given radius and make sure the face-data is not corrupted due
    %to the removing of points. It still corrupts face-data though :(
    n=length(quadData);
    d=zeros(n,1);
    
    %Calculate (cylindrical) distance for all points.
    for j=1:n
        d(j)=sqrt(quadData(j,2)^2+quadData(j,3)^2);
    end
    
    %Find the 
    [counts,centers]=hist(d(:),1000);
    counts=smooth(counts,15);
    [peaks,locs]=findpeaks(counts,centers);
    p=max(peaks);
    x_max=locs((peaks==p));
    delta=abs(p/2-counts);
    x_fwhm=centers((min(delta)==delta));
    radius=2*5*abs(x_max-x_fwhm); %This is quite arbitrary.
    
    %Next we remove all points that are outside this radius. Because this
    %will change the indices, we will have to remember which vertices were
    %removed and use it to adjust the face-data.
    keep_vertex=ones(n,1);
    for j=1:n
        if(d(j) > radius)
            keep_vertex(j)=0;
        end
    end
    
    %Removing points means remapping indices. 
    mapping=cumsum(keep_vertex);

    %Remove all vertices that were flagged
    quadData_Cropped=quadData(keep_vertex==1,:);
    %Extract quad indices for remapping, switch to one-based indexing
    Q=quadData_Cropped(:,5:8)+1;
    Q_remapped=zeros(size(Q));  
    
    %Remap, if the quad references a deleted point, set the data to -1 so
    %it gets ignored when exporting
    for j=1:length(Q)
        if(Q(j,1)~=0)
            Q_remapped(j,1)=mapping(Q(j,1))*keep_vertex(Q(j,1));
        end
        if(Q(j,2)~=0)
            Q_remapped(j,2)=mapping(Q(j,2))*keep_vertex(Q(j,2));
        end
        if(Q(j,3)~=0)
            Q_remapped(j,3)=mapping(Q(j,3))*keep_vertex(Q(j,3));
        end
        if(Q(j,4)~=0)
            Q_remapped(j,4)=mapping(Q(j,4))*keep_vertex(Q(j,4));
        end
    end
    quadData_Cropped(:,5:8)=Q_remapped-1;

end