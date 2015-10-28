function object=importOBJ(objfile)
    f=fopen(objfile);
    %Get file size, because preallocation *really* makes a difference now.
    fseek(f, 0, 'eof');
    fileSize=ftell(f);
    frewind(f);
    %# Read the whole file.
    data=fread(f, fileSize, 'uint8');
    %# Count number of line-feeds.
    numLines=sum(data==10);
    frewind(f)
    
    %Allocate return object. This is a bit overzealous in terms of size but
    %now we're sure we have enough storage (number of vertices/faces/...
    %will never exceed the number of lines, obviously).
    object=struct(  'v', zeros(numLines,3), ...     %Vertex data
                    'vt', zeros(numLines,2),...     %Vertex texture data
                    'vn', zeros(numLines,3),...     %Vertex normal data
                    'f', zeros(numLines,4)); %Face data
    if f==-1
        fprintf(1, 'Failed to open "%s% \n', objfile);
    else
        %Count all types included in the obj file. This can easily be
        %extended.
        nv=1; nvt=1; nvn=1; nf=1;
        %Needed for progress report              
        reverseStr='';
        %Check each line and copy data to the correct struct field.
        for j=1:numLines
            line=fgetl(f);
            if length(line) > 1
                if strcmp(line(1:2),'v ')       
                    line_parsed=textscan(line, 'v %f %f %f');
                    object.v(nv,1:3)=[line_parsed{3}  line_parsed{2} -line_parsed{1}];
                    nv=nv+1;
                elseif strcmp(line(1:2),'vt')   
                    line_parsed=textscan(line, 'vt %f %f');
                    object.vt(nvt,1:2)=[line_parsed{1} line_parsed{2}];
                    nvt=nvt+1;
                elseif strcmp(line(1:2),'vn')
                    line_parsed=textscan(line, 'vn %f %f %f');
                    object.vn(nvn,1:3)=[line_parsed{3}  line_parsed{2} -line_parsed{1}];
                    nvn=nvn+1;
                elseif strcmp(line(1), 'f')
                    line_parsed=regexp(line,'f (\d+)/(\d+)/(\d+) (\d+)/(\d+)/(\d+) (\d+)/(\d+)/(\d+) (\d+)/(\d+)/(\d+)','tokens');
                    line_parsed=line_parsed{1};
                    if isnan(str2double(line_parsed{1})) || isnan(str2double(line_parsed{2})) || isnan(str2double(line_parsed{3})) || isnan(str2double(line_parsed{4}))
                        [str2double(line_parsed{1})... 
                                        str2double(line_parsed{4})...
                                        str2double(line_parsed{7})... 
                                        str2double(line_parsed{10})];
                    end
                    object.f(nf,1:4)=  [str2double(line_parsed{1})... 
                                        str2double(line_parsed{4})...
                                        str2double(line_parsed{7})... 
                                        str2double(line_parsed{10})];

                    nf=nf+1;
                end
            end
            %Display progress occasionally
            if mod(j,10000)==0
                msg = sprintf('importOBJ: %d of %d lines read from file "%s" \n', j, numLines, objfile);
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end
        msg = sprintf('importOBJ: %d of %d lines read from file "%s" \n', numLines, numLines, objfile);
        fprintf([reverseStr, msg]);
        
        %Remove trailing zeros.
        object.v =object.v(1:(nv-1),:);
        object.vt=object.vt(1:(nvt-1),:);
        object.vn=object.vn(1:(nvn-1),:);
        object.f =object.f(1:(nf-1),:);
        fclose(f);
    end
end

%Written by Jan Morez, 22/10/2015
%Visielab, Antwerpen
%jan.morez@gmail.com