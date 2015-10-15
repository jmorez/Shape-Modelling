function quadData_new=removeBadQuads(quadData,angle_treshold)
    [angle,index]=quadSkewAngle(quadData);
    keep_quad=zeros(length(quadData),1);
    %Keep all quads that are within angle_treshold
    for j=1:length(angle)
        if(abs(angle(j)-pi/2) < angle_treshold) 
            keep_quad(index(j))=1;
        end
    end
    quadData_new=trimQuadDataByIndex(quadData,keep_quad);
    
    n=length(quadData);
    fprintf(1,'Removed %d %% of quads. \n',round(100*(n-sum(keep_quad))/n)); 
end