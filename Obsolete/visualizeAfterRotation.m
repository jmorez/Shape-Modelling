%This needs rewriting to deal with quads, or should just be removed...

directory='grid';
files=struct2cell(dir(directory))';
n=1;

%Rotation angle of each view
theta=pi/4;
if(~exist('data_n.mat','file'))
    %data=[];
    for j=1:length(files)
        if files{j,4}==0 %Check if we're dealing with a directory or a file.
            quads=grid2array(strcat([directory '/' files{j,1}]));
            points=quads(:,2:4);
            data_n{n}=points;
            n=n+1;
        end
    end  
else
    load('data_n.mat')
end
%%
close all;
for j=1:length(data_n)
    data=data_n{j};
    %Center data
    xcenter=mean(data(:,1));
    ycenter=mean(data(:,2));
    zcenter=mean(data(:,3));
    center=[xcenter ycenter zcenter];
    data_centered=data-repmat(center,length(data),1);
    
    %Crop data within some cylinder with radius r
    data_cropped=zeros(size(data_centered));
    for k=1:length(data_centered)
        ROI_radius=40;
        r=sqrt(sum(data_centered(k,1:2).*data_centered(k,1:2)));
        if r < ROI_radius
            data_cropped(k,:)=data_centered(k,:);
        end
    end
    %Rotate j*45 degrees
    R=rotz(theta*(j-1));
    for k=1:length(data_cropped)
        points(k,:)=(R*data_cropped(k,:)')';
    end
    data_rotated{j}=points;
    figure
    pcshow(data_rotated{j});
    title(strcat(['\theta = ' num2str(j-1) '\cdot \pi / 2']))
end

%pcshow(data_rotated{1});

xlabel('x')
ylabel('y')
zlabel('z')


