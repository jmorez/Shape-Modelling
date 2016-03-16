function triData_new=removeInvalidTriangles(triData)
    triData_new=triData;
    keep_triangle=logical(FALSE(length(triData{2}),1));
    %Find all valid triangles (i.e. without -1 entries)
    for j=1:length(triData{2})
        if sum(triData{2}(j,:)==-1)==0
            keep_triangle(j)=1;
        end
    end
    %Filter out all valid triangles
    triData_new{2}=triData{2}(keep_triangle,:);
end