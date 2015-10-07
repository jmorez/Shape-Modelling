function quadData_Cropped=cropPoints(quadData,percentile)
    %This function will first find a minimum radius that corresponds with 
    %<percentile> of all points. It will then remove all points outside a 
    %cylinder with said radius and make sure the face-data is not corrupted due
    %to the removing of points.

    d=zeros(length(quadData),1);
    %Calculate (cylindrical) distance for all points.
    for j=1:length(quadData)
        d(j)=sqrt(quadData(j,2)^2+quadData(j,3)^2);
    end
    [counts,centers]=hist(d(:),100);
    cumulative=cumsum(counts)/sum(counts(:));
    plot(centers,cumulative)
    radius=min(centers((cumulative > percentile)));
    
    %Next we remove all points that are outside this radius. Because this
    %will change the indices, we will have to remember this change and
    %apply it to the face-data.
    keep_vertex=ones(length(quadData),1);
    for j=1:length(quadData)
        if(d(j) > radius)
            keep_vertex(j)=0;
        end
    end
    
    %Removing points means remapping indices. 
    mapping=cumsum(keep_vertex);
    %mapping=mapping(keep_vertex);

    %Remove vertices with the appropriate flag.
    quadData_Cropped=quadData;%(keep_vertex==1,:);
    
    %If a vertex is related to a face with a removed point, set the face
    %data to -1 so it gets ignored when exporting. I still have to relabel
    %all the quad indices, is that possible in O < O(n^2)??
    
    
    Q_flat=quadData(:,4:8);
    Q_flat=Q_flat(:);
    for j=1:length(Q_flat)
        Q_flat(j)=Q_flat(j)mapping(Q_flat(j));
    end
    
    
    for j=1:length(quadData_Cropped);
        if ~keep_vertex(j)
            quadData_Cropped(j,4:8)=-1*ones(1,4);
        end
    end
end