function quadData_trimmed=trimQuadDataByIndex(quadData,flag)
    %Remove points and associated quads according to flag. 
    %Removing points means remapping indices. 
    mapping=cumsum(flag);

    %Remove all vertices that were flagged
    quadData_trimmed=quadData(flag==1,:);
    %Extract quad indices for remapping, switch to one-based indexing
    Q=quadData_trimmed(:,5:8)+1;
    Q_remapped=zeros(size(Q));  
    
    %Remap, if the quad references a deleted point, set the data  
    %to -1 (line 27) so it gets ignored when exporting.
    for j=1:length(Q)
        if(Q(j,1)~=0)
            Q_remapped(j,1)=mapping(Q(j,1))*flag(Q(j,1));
        end
        if(Q(j,2)~=0)
            Q_remapped(j,2)=mapping(Q(j,2))*flag(Q(j,2));
        end
        if(Q(j,3)~=0)
            Q_remapped(j,3)=mapping(Q(j,3))*flag(Q(j,3));
        end
        if(Q(j,4)~=0)
            Q_remapped(j,4)=mapping(Q(j,4))*flag(Q(j,4));
        end
        %quadData_trimmed(j,5:8)=Q_remapped(j,:)-1;
    end
    quadData_trimmed(:,5:8)=Q_remapped-1;
end