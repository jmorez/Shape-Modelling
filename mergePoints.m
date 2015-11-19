function points_merged=mergePoints(varargin)
    %Input should be a cell of objects or a list of objects
    points_merged=[];
    if length(varargin)==1 && iscell(varargin{1}) && length(varargin{1}) > 1
        for j=1:length(varargin{1})
            points_merged=cat(1,points_merged,varargin{1}{j}.v);
        end
    else
        for j=1:length(varargin)
            points_merged=cat(1,points_merged,varargin{j}.v);
        end
    end
end