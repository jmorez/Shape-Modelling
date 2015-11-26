function showObj(object,varargin)
    %Pure lazyness...
    if length(object)==1
        if length(varargin)>0
        pcshow(object.v,varargin{1});
        else
            pcshow(object.v);
        end  
    else
        hold on
        for j=1:length(object)
            pcshow(object{j}.v);
        end
        hold off
    end
    cameratoolbar('ResetCamera');
end