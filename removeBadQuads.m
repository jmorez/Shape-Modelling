function quadData_new=removeBadQuads(quadData,percentile)
    [angle,index]=quadSkewAngle(quadData);
    [counts,centers]=hist(angle,100);
    counts=counts./sum(counts(:));
    [pks,locs]=findpeaks(counts);
    [~,idx]=max(pks);
    idx_max=locs(idx);
    %Find half of the percentile to the right of the peak
    right=cumsum(counts(idx_max:end)) < 0.5*percentile;
    
    %Same for left side
    %Suggestion: flip left side around and add it to the right side so we
    %have a symmetric trimming.
    left=cumsum(flip(counts(1:idx_max))) < 0.5*percentile;
    right_idx=idx_max+find(right,1,'last')+1;
    left_idx=idx_max-find(left,1,'last')+1;

    max_angle=centers(right_idx);
    min_angle=centers(left_idx);
    keep_quad=zeros(length(quadData),1);
    
    %Keep all quads that are within the angle limits.
    for j=1:length(angle)
        if(angle(j) < max_angle && angle(j) > min_angle)
            keep_quad(index(j))=1;
        end
    end
    quadData_new=trimQuadDataByIndex(quadData,keep_quad);
end