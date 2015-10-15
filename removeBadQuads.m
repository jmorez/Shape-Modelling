function quadData_new=removeBadQuads(quadData,percentile)
    %Find the peak index. Center angles around pi/2 (ideal) and take the
    %absolute value.
    [angle,index]=quadSkewAngle(quadData);
    angle=abs(angle-pi/2);
    [counts,centers]=hist(angle,100);
    counts=counts./sum(counts(:));
    [pks,locs]=findpeaks(counts);
    [p,idx]=max(pks);
    idx_max=locs(idx);
    x_max=centers(idx_max);
    
    %Find FWHM
    delta=abs(p/2-counts);
    x_fwhm=centers((min(delta)==delta));
    max_angle=2*5*abs(x_max-x_fwhm); %This 5 is quite arbitrary.
    
    %max_angle=centers(right_idx);
    %min_angle=centers(left_idx);
    keep_quad=zeros(length(quadData),1);
    
    %Keep all quads that are within the angle limits.
    for j=1:length(angle)
        if(abs(angle(j)) < max_angle) % && angle(j) > min_angle)
            keep_quad(index(j))=1;
        end
    end
    quadData_new=trimQuadDataByIndex(quadData,keep_quad);
end