function showObj(object,varargin)
    figure('units','normalized','outerposition',[0 0 1 1])
    if isempty(varargin)
        downsample_parameter=0.5;
    else
        downsample_parameter=varargin{1};
    end
    if length(object)==1
                object_d=downsampleObject(object,downsample_parameter);
                scatter3(object_d.v(:,1),object_d.v(:,2),object_d.v(:,3),0.5,object_d.vn);  
    else
        hold on
        for j=1:length(object)
            object_d=downsampleObject(object{j},downsample_parameter);
            scatter3(object_d.v(:,1),object_d.v(:,2),object_d.v(:,3),0.5,object_d.vn);
        end
        hold off
    end
    axis image; view(3); xlabel('x'); ylabel('y'); zlabel('z');
end
