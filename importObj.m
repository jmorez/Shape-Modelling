function object = importObj(varargin)
    for k=1:length(varargin)
            objfile=backward2ForwardSlash(varargin{k});
            fprintf(1,'importObj: processing %s. \n',objfile);
            [v,vt,vn,f]=importObjMex(objfile);
            
            %Remove zero padding.
            v=v(any(v,2),:);
            vt=vt(any(vt,2),:);
            vn=vn(any(vn,2),:);
            f=double(f(any(f,2),:));
            
            object=struct('v',v,'vt',vt,'vn',vn,'f',f);
    end
end