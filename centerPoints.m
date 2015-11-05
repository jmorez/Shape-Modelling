function [object_centered, center]=centerPoints(object)
    %Calculate the centroid
    center=[mean(object.v(:,1)) mean(object.v(:,2)) mean(object.v(:,3))]';
    
    %Allocate output
    object_centered=object;
    
    %Center each point.
    object_centered.v=object.v-repmat(center',length(object.v),1);
end