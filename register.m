%Subsampling factor
stride=4;
outputdir='processed';
n=length(quadData_r);

quadData_t=quadData_r;

for j=1:(n-1)
    fixed =quadData_t{j+1}(1:stride:end,2:4)';
    moving=quadData_t{j}(1:stride:end,2:4)';
    %% 
    [TR,TT]=icp(fixed,moving);
    %% 
    for k=1:j
        quadData_t{k}=rigidtransform(quadData_t{k},TR,TT);
    end
    fprintf(1,'Registered %d out of %d. \n',j,n-1);
end

for j=1:n
    file=strcat(outputdir,'/',num2str(j),'r','.obj');
    quaddata2obj(quadData_t{j},file);
end