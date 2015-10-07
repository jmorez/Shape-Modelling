function quadData_Centered=centerPoints(quadData)
    %Calculate the centroid
    xcenter=mean(quadData(:,2));
    ycenter=mean(quadData(:,3));
    zcenter=mean(quadData(:,4));
    
    quadData_Centered=quadData;
    
    %Center each point.
    quadData_Centered(:,2)=quadData(:,2)-xcenter;
    quadData_Centered(:,3)=quadData(:,3)-ycenter;
    quadData_Centered(:,4)=quadData(:,4)-zcenter;

end