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

function angle=quadSkewAngle(object)
%This function will calculate the skew angle for every quad.
    reverseStr='';
    %Calculate skew angle for each quad
    angle=zeros(length(object.f),1);
    for j=1:length(object.f)
        v1=object.v(object.f(j,1),1:3);
        v2=object.v(object.f(j,2),1:3);
        v3=object.v(object.f(j,3),1:3);
        v4=object.v(object.f(j,4),1:3);
        
        %Skew-angle quality measure
        x=(v1-v4-v3+v2);
        y=(v2-v1-v4+v3);
        angle(j)=acos(((v1-v4-v3+v2)*(v2-v1-v4+v3)')/(norm(v1-v4-v3+v2)*norm(v2-v1-v4+v3)));

        %Display progress
        if mod(j,round(length(object.f)/1000)-1)==0
            msg = sprintf('quadSkewAngle: %d of %d quads analyzed. \n', j,length(object.f));
            fprintf([reverseStr, msg]);
            reverseStr = repmat(sprintf('\b'), 1, length(msg));
        end
    end
end

%Written by Jan Morez
%Visielab, Antwerpen
%jan.morez@gmail.com