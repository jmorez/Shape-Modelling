function quadData_trimmed=trimQuadDataByIndex(quadData,keep_vertex)
    %quadData_trimmed=quadData;
    %Removing points means remapping indices. 
    mapping=cumsum(keep_vertex);

    %Remove all vertices that were flagged
    quadData_Trimmed=quadData(keep_vertex==1,:);
    %Extract quad indices for remapping, switch to one-based indexing
    Q=quadData_Trimmed(:,5:8)+1;
    Q_remapped=zeros(size(Q));  
    
    %Remap, if the quad references a deleted point, set the data  
    %to -1 (line 27) so it gets ignored when exporting.
    for j=1:length(Q)
        if(Q(j,1)~=0)
            Q_remapped(j,1)=mapping(Q(j,1))*keep_vertex(Q(j,1));
        end
        if(Q(j,2)~=0)
            Q_remapped(j,2)=mapping(Q(j,2))*keep_vertex(Q(j,2));
        end
        if(Q(j,3)~=0)
            Q_remapped(j,3)=mapping(Q(j,3))*keep_vertex(Q(j,3));
        end
        if(Q(j,4)~=0)
            Q_remapped(j,4)=mapping(Q(j,4))*keep_vertex(Q(j,4));
        end
        %quadData_trimmed(j,5:8)=Q_remapped(j,:)-1;
    end
    quadData_trimmed(:,5:8)=Q_remapped-1;
end