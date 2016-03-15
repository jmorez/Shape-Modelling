function object = importObj(varargin)
    for k=1:length(varargin)
            objfile=backward2ForwardSlash(varargin{k});
            fprintf(1,'Processing %s. \n',objfile);
            [v,vt,vn,f]=importObjMex(objfile);
            
            %Remove zero padding.
            v=v(any(v,2),:);
            vt=v(any(vt,2),:);
            vn=v(any(vn,2),:);
            f=f(any(f,2),:);
            
            object=struct('v',v,'vt',vt,'vn',vn,'f',f);
    end
end