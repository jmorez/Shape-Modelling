function object_Centered=centerPoints(object)
    %Calculate the centroid
    %xcenter=0.5*(max(object.v(:,1))-min(object.v(:,1)));
    %ycenter=0.5*(max(object.v(:,2))-min(object.v(:,2)));
    %zcenter=0.5*(max(object.v(:,3))-min(object.v(:,3)));
    
    xcenter=mean(object.v(:,1));
    ycenter=mean(object.v(:,2));
    zcenter=mean(object.v(:,3));
    
    %Allocate output
    object_Centered=object;
    
    %Center each point.
    object_Centered.v(:,1)=object.v(:,1)-xcenter;
    object_Centered.v(:,2)=object.v(:,2)-ycenter;
    object_Centered.v(:,3)=object.v(:,3)-zcenter;
end