directory='grid';
files=struct2cell(dir(directory))';
n=1;
theta=pi/4;
if(~exist('data','var'))
    data=[];
    for j=1:length(files)
        if files{j,4}==0 %Check if we're dealing with a directory or a file.
            quads=grid2array(strcat(directory, '/', files{j,1}));
            points=quads(:,2:4);
            %Switch axes so indices 1,2,3 correspond with x,y,z
            temp=points(:,1);
            points(:,1)=points(:,3);
            points(:,3)=-temp;
            data_sep{n}=points;
            data=cat(1,data,points);
            n=n+1;
        end
    end  
end
%%
close all;

%Center data
xcenter=mean(data(:,1));
ycenter=mean(data(:,2));
zcenter=mean(data(:,3));
center=[xcenter ycenter zcenter];
points_centered=data-repmat(center,length(data),1);

%Crop data
points_cropped=zeros(size(points_centered));
for j=1:length(points_centered)
    ROI_radius=50;
    r=sqrt(sum(points_centered(j,:).*points_centered(j,:)));
    if r < ROI_radius
        points_cropped(j,:)=points_centered(j,:);
    end
end

pcshow(data);

xlabel('x')
ylabel('y')
zlabel('z')
