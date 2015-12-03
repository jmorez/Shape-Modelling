function object_downsampled=downsampleObject(object,varargin)
    %Randomly subsamples an object. Either the user supplies a percentage
    %or some integer
    N=length(object.v);
    
    if ~isempty(varargin)
        if isinteger(varargin{1}) && varargin{1} > 0 && varargin{1} <= N && varargin{1}~=1
            K=varargin{1};
        elseif isreal(varargin{1}) && varargin{1} > 0 && varargin{1} <= 1
            K=round(varargin{1}*N);
        else
            error('Invalid input. Should be strictly positive integer or real.');
        end
    else
        %With no specification, we just remove half of the points.
        K=round(0.5*N);
    end
    
    if K==N
        object_downsampled=object;
    else
        %Find the random subset of indices so that the new object only has
        %approximately percentage*N points
        indices=vision.internal.samplingWithoutReplacement(N, K);
        flag=zeros(1,N);
        flag(indices)=1;
        object_downsampled=trimObjectByIndex(object,flag);
    end
end