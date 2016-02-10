function showObj(object,varargin)
%Varargin is problematic because passing a cell array will expand into
%multiple arguments
    figure('units','normalized','outerposition',[0 0 1 1])
    downsample_parameter=0.15;

    if isempty(varargin)
                object_d=downsampleObject(object,downsample_parameter);
                scatter3(object_d.v(:,1),object_d.v(:,2),object_d.v(:,3),0.5,object_d.vn);  
    else
        hold on
        object_d=downsampleObject(object,downsample_parameter);
        scatter3(object_d.v(:,1),object_d.v(:,2),object_d.v(:,3),0.5,object_d.vn); 
        for j=1:length(varargin)
            object_d=downsampleObject(varargin{j},downsample_parameter);
            scatter3(object_d.v(:,1),object_d.v(:,2),object_d.v(:,3),0.5,object_d.vn);
        end
        hold off
    end
    axis image; view(3); xlabel('x'); ylabel('y'); zlabel('z');
    drawnow;
end
