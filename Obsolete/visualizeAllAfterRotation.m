close all
load('data_rotated.mat')
data_overlapped=[];
fixed=data_rotated{1};
for j=1%(length(data_rotated)-1)
    tic
    moving=data_rotated{j+1};
    [TR,TT]=icp(moving',fixed',200);
    movingReg=zeros(size(moving));
    for k=1:length(moving)
        movingReg(k,:)=(TR*moving(k,:)'+TT)';
    end
    data_overlapped=cat(1,data_overlapped,movingReg);
    fixed=movingReg;
    t=toc;
    
    disp(strcat(['Registered ' num2str(j) ' out of ' num2str(length(data_rotated))]))
    disp(strcat(['Estimated time left: ' num2str(t*(length(data_rotated)-j)) ' seconds.']))
    %pcshow(data_overlapped)
    pcshowpair(pointCloud(data_rotated{1}),pointCloud(movingReg));
    drawnow
end

%pcshow(data_overlapped)