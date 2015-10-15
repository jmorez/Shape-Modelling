function quadData_t=rigidTransform(quadData,TR,TT)
    n=length(quadData);
    quadData_t=quadData;
    for j=1:n
        quadData_t(j,2:4)=(TR*quadData(j,2:4)'+TT)';
    end
end