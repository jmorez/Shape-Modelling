function quadData=array2quaddata(array)
    %Transforms the raw grid-data into a neat M by 8 array with the columns
    %representing:
    %vertex_id vertex_x vertex_y vertex_z quad_id1 quad_id2 quad_id3 quad_id4

    quadData=cat(2, array(:,1),array(:,2),array(:,3),array(:,4), ... 
                    array(:,11),array(:,12),array(:,13),array(:,14));
    
end