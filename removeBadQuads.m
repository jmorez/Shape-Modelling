function quadData_new=removeBadQuads(quadData,percentile)
    [angle,index]=quadSkewAngle(quadData);
    [counts,centers]=hist(abs(angle),100);
    counts=counts./sum(counts(:));
    [pks,locs]=findpeaks(counts);
    [~,idx]=max(pks);
    idx_max=locs(idx);
    
    %Suggestion: use FWHM instead of percentiles, a "bad" distribution will
    %also lead to bad quads being included.
    %Exclude outlying quads
    right=cumsum(counts(1:end)) < percentile;
    
    right_idx=find(right,1,'last')+1;
    %left_idx=idx_max-find(left,1,'last')+1;

    
    max_angle=centers(right_idx);
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