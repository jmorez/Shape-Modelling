function object_Cropped=cropObject(object)
    %This function will remove all points outside a cylinder with a
    %diameter of five times (heuristically chosen) the FWHM of the distance
    %distribution. 
    n=length(object.v);
    d=zeros(n,1);
    
    %Calculate (cylindrical) distance for all points.
    for j=1:n
        d(j)=sqrt(object.v(j,2)^2+object.v(j,3)^2);
    end
    
    %Find the largest peak and use the FWHM to select the majority of the
    %points.
    [counts,centers]=hist(d(:),1000);
    counts=smooth(counts,15);
    [peaks,locs]=findpeaks(counts,centers);
    p=max(peaks);
    x_max=locs((peaks==p));
    delta=abs(p/2-counts);
    x_fwhm=centers((min(delta)==delta));
    radius=2*5*abs(x_max-x_fwhm); %This 5 is quite arbitrary.
    
    %Next we remove all points that are outside this radius. Because this
    %will change the indices, we will have to remember which vertices were
    %removed and use it to adjust the face-data.
    flag=ones(n,1);
    for j=1:n
        if(d(j) > radius)
            flag(j)=0;
        end
    end
    object_Cropped=trimObjectByIndex(object,flag);
end