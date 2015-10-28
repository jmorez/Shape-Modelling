function object_new=removeBadQuads(object,angle_treshold)
    angle=quadSkewAngle(object);
    flag=zeros(length(object.v),1);
    %Keep vertices *only* associated with "good" quads. 
    for j=1:length(object.f)
        if(abs(angle(j)-pi/2) < angle_treshold) 
            flag(object.f(j,:))=1;
        end
    end
    object_new=trimObjectByIndex(object,flag);
    n=length(object.v);
    fprintf(1,'Removed %d %% of points and associated quads. \n',round(100*(n-sum(flag))/n)); 
end

%Written by Jan Morez, 22/10/2015
%Visielab, Antwerpen
%jan.morez@gmail.com