function object=importOBJ(objfile)
    f=fopen(objfile);
%Get file size, because preallocation *really* makes a difference now.
    fseek(f, 0, 'eof');
    fileSize=ftell(f);
    frewind(f);
    %# Read the whole file.
    data=fread(f, fileSize, 'uint8');
    %# Count number of line-feeds and increase by one.
    numLines=sum(data==10);
    frewind(f)
%Allocate return object
    object=struct(  'v',zeros(numLines,3), ...
                    'vt',zeros(numLines,2),...
                    'vn',zeros(numLines,3),...
                    'f',uint8(zeros(numLines,4)));
    if f==-1
        fprintf(1, 'Failed to open "%s% \n', objfile);
    else
        %Count all types included in the obj file.
        nv=1; nvt=1; nvn=1; nf=1;
        %Needed for progress report              
        reverseStr='';
        for j=1:numLines
            
            line=fgetl(f);
            if length(line) > 1
                if strcmp(line(1:2),'v ')
                    line_parsed=textscan(line, 'v %f %f %f');
                    object.v(nv,1:3)=[line_parsed{1} line_parsed{2} line_parsed{3}];
                    nv=nv+1;
                elseif strcmp(line(1:2),'vt')
                    line_parsed=textscan(line, 'vt %f %f');
                    object.vt(nvt,1:2)=[line_parsed{1} line_parsed{2}];
                    nvt=nvt+1;
                elseif strcmp(line(1:2),'vn')
                    line_parsed=textscan(line, 'vn %f %f %f');
                    object.vn(nvn,1:3)=[line_parsed{1} line_parsed{2} line_parsed{3}];
                    nvn=nvn+1;
                elseif strcmp(line(1), 'f')
                    line_parsed=regexp(line, '\d*');
                    object.f(nf,1:4)=[line_parsed(1) line_parsed(4) line_parsed(7) line_parsed(10)];
                    nf=nf+1;
                end
            end
            %Display progress
            if mod(j,10000)==0
                msg = sprintf('obj2QuadData: %d of %d lines read from file "%s" \n', j, numLines, objfile);
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end
        msg = sprintf('obj2QuadData: %d of %d lines read from file "%s" \n', numLines, numLines, objfile);
        fprintf([reverseStr, msg]);
                
        object.v =object.v(1:(nv-1),:);
        object.vt=object.vt(1:(nvt-1),:);
        object.vn=object.vn(1:(nvn-1),:);
        object.f =object.f(1:(nf-1),:);
        fclose(f);
    end
    
end