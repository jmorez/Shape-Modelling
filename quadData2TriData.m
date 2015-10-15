function quadData2TriData(quadData)
    triData{1}=quadData(:,1:4);
    triData{2}=zeros(2*length(quadData),3);
    for j=1:2:(2*length(quadData))
        v1=quadData(j,5);
        v2=quadData(j,6);
        v3=quadData(j,7);
        v4=quadData(j,8);
        triData{2}(j)=[v1 v2 v3];
        triData{2}(j+1)=[v2 v4 v3];
    end
end