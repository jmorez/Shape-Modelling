function quadData_Centered=centerPoints(quadData)
    xcenter=mean(quadData(:,2));
    ycenter=mean(quadData(:,3));
    zcenter=mean(quadData(:,4));
    center=[xcenter ycenter zcenter];
    quadData_Centered=quadData;
    quadData_Centered(:,2)=quadData(:,2)-xcenter;
    quadData_Centered(:,3)=quadData(:,3)-ycenter;
    quadData_Centered(:,4)=quadData(:,4)-zcenter;

end