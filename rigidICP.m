function [error,Reallignedsource,transform]=rigidICP(target,source,flag,Indices_edgesS,Indices_edgesT)
    % This function rotates, translates and scales a 3D pointcloud "source" of N*3 size (N points in N rows, 3 collumns for XYZ)
    % to fit a similar shaped point cloud "target" again of N by 3 size
    % 
    % The output shows the minimized value of dissimilarity measure in "error", the transformed source data set and the 
    % transformation, rotation, scaling and translation in transform.T, transform.b and transform.c such that
    % Reallignedsource = b*source*T + c;


    if flag==0
    [Prealligned_source,Prealligned_target,transformtarget ]=Preall(target,source);
    else
        Prealligned_source=source;
        Prealligned_target=target;
    end

    display ('error')
    errortemp(1,:)=0;
    index=2;
    [errortemp(index,:),Reallignedsourcetemp]=ICPmanu_allign2(Prealligned_target,Prealligned_source,Indices_edgesS,Indices_edgesT);

    while (abs(errortemp(index-1,:)-errortemp(index,:)))>0.000001
    [errortemp(index+1,:),Reallignedsourcetemp]=ICPmanu_allign2(Prealligned_target,Reallignedsourcetemp,Indices_edgesS,Indices_edgesT);
    index=index+1;
    d=errortemp(index,:); %This has been suppressed.

    end

    error=errortemp(index,:);

    if flag==0
    Reallignedsource=Reallignedsourcetemp*transformtarget.T+repmat(transformtarget.c(1,1:3),length(Reallignedsourcetemp(:,1)),1);
    [d,Reallignedsource,transform] = procrustes(Reallignedsource,source);
    else
       [d,Reallignedsource,transform] = procrustes(Reallignedsourcetemp,source);
    end
end

function [Prealligned_source,Prealligned_target,transformtarget ]=Preall(target,source)
    % This function performs a first and rough pre-alligment of the data as starting position for the iterative allignment and scaling procedure

    % Initial positioning of the data is based on alligning the coordinates of the objects -which are assumed to be close/similar in shape- following principal component analysis

    [COEFF,Prealligned_source] = princomp(source);

    [COEFF,Prealligned_target] = princomp(target);

    % the direction of the axes is than evaluated and corrected if necesarry.
    Maxtarget=max(Prealligned_source)-min(Prealligned_source);
    Maxsource=max(Prealligned_target)-min(Prealligned_target);
    D=Maxtarget./Maxsource;
    D=[D(1,1) 0 0;0 D(1,2) 0; 0 0 D(1,3)];
    RTY=Prealligned_source*D;

    load R
    for i=1:8
        T=R{1,i};
        T=RTY*T;
        [bb DD]=knnsearch(T,Prealligned_target);
        MM(i,1)=sum(DD);
    end

    [M I]=min(MM);
     T=R{1,I};
     Prealligned_source=Prealligned_source*T;

     [d,Z,transformtarget] = procrustes(target,Prealligned_target);
end

function [error,Reallignedsource]=ICPmanu_allign2(target,source,Indices_edgesS,Indices_edgesT)

[IDX1(:,1),IDX1(:,2)]=knnsearch(target,source);
[IDX2(:,1),IDX2(:,2)]=knnsearch(source,target);
IDX1(:,3)=1:length(source(:,1));
IDX2(:,3)=1:length(target(:,1));

[C,ia]=setdiff(IDX2(:,1),Indices_edgesS);
IDX2=IDX2(ia,:);

[C,ia]=setdiff(IDX1(:,1),Indices_edgesT);
IDX1=IDX1(ia,:);

m1=mean(IDX1(:,2));
s1=std(IDX1(:,2));
IDX2=IDX2(IDX2(:,2)<(m1+1.96*s1),:);

Datasetsource=vertcat(source(IDX1(:,3),:),source(IDX2(:,1),:));
Datasettarget=vertcat(target(IDX1(:,1),:),target(IDX2(:,3),:));

[error,Reallignedsource,transform] = procrustes(Datasettarget,Datasetsource);
Reallignedsource=transform.b*source*transform.T+repmat(transform.c(1,1:3),size(source,1),1);

end
