function object=importObj(varargin)
%NOTE: this function also switches a few axes (see line 37)!!!
    for k=1:length(varargin)
        objfile=backward2ForwardSlash(varargin{k});
        f=fopen(objfile);
        if f==-1
            fprintf(1, 'Failed to open "%s% \n', objfile);
        else
            %Get file size, because preallocation *really* makes a difference now.
            fseek(f, 0, 'eof');
            filesize=ftell(f);
            frewind(f);
            %# Read the whole file.
            data=fread(f, filesize, 'uint8');
            %# Count number of line-feeds.
            numlines=sum(data==10);
            frewind(f)

            %Allocate return object. This is a bit overzealous in terms of size but
            %now we're sure we have enough storage (number of vertices/faces/...
            %will never exceed the number of lines, obviously).
            object{k}=struct('v', zeros(numlines,3),...     %Vertex data
                            'vt', zeros(numlines,2),...     %Vertex texture data
                            'vn', zeros(numlines,3),...     %Vertex normal data
                            'f' , zeros(numlines,4));       %Face data
        
            %Count all types included in the obj file. This can easily be
            %extended.
            nv=1; nvt=1; nvn=1; nf=1;
            %Needed for progress report              
            reverseStr='';
            %Check each line and copy data to the correct struct field.
            for j=1:numlines
                line=fgetl(f);
                if length(line) > 1
                    if strcmp(line(1:2),'v ')       
                        line_parsed=textscan(line, 'v %f %f %f');
                        object{k}.v(nv,1:3)=[line_parsed{3}  line_parsed{2} -line_parsed{1}];
                        %object{k}.v(nv,1:3)=[-line_parsed{1}  line_parsed{2} line_parsed{3}]; %This one for 141 data set, INELEGANT
                        nv=nv+1;
                    elseif strcmp(line(1:2),'vt')   
                        line_parsed=textscan(line, 'vt %f %f');
                        object{k}.vt(nvt,1:2)=[line_parsed{1} line_parsed{2}];
                        nvt=nvt+1;
                    elseif strcmp(line(1:2),'vn')
                        line_parsed=textscan(line, 'vn %f %f %f');
                        object{k}.vn(nvn,1:3)=[line_parsed{3}  line_parsed{2} -line_parsed{1}];
                        nvn=nvn+1;
                    elseif strcmp(line(1), 'f')
                        line_parsed=regexp(line,'f (\d+)/(\d+)/(\d+) (\d+)/(\d+)/(\d+) (\d+)/(\d+)/(\d+) (\d+)/(\d+)/(\d+)','tokens');
                        if length(line_parsed)~=0
                            line_parsed=line_parsed{1};
                            if isnan(str2double(line_parsed{1})) || isnan(str2double(line_parsed{2})) || isnan(str2double(line_parsed{3})) || isnan(str2double(line_parsed{4}))                            
                            object{k}.f(nf,1:4)=  [str2double(line_parsed{1})... 
                                                str2double(line_parsed{4})...
                                                str2double(line_parsed{7})... 
                                                str2double(line_parsed{10})];
                            end
                        else
                            line_parsed=textscan(line, 'f %f %f %f %f');
                            object{k}.f(nf,1:4)=[line_parsed{1} line_parsed{2} line_parsed{3} line_parsed{4}];
                        end
                        nf=nf+1;
                    end
                end
                %Display progress occasionally
                if mod(j,1000)==0 || j==numlines
                    msg = sprintf('importOBJ: %d of %d lines read from file "%s" \n', j, numlines, objfile);
                    fprintf([reverseStr, msg]);
                    reverseStr = repmat(sprintf('\b'), 1, length(msg));
                end
            end

            %Remove trailing zeros.
            object{k}.v =object{k}.v(1:(nv-1),:);
            object{k}.vt=object{k}.vt(1:(nvt-1),:);
            object{k}.vn=object{k}.vn(1:(nvn-1),:);
            object{k}.f =object{k}.f(1:(nf-1),:);
            fclose(f);
            
            if length(varargin)==1
                object=object{1};
            end
        end
    end
end

%Written by Jan Morez, 22/10/2015
%Visielab, Antwerpen
%jan.morez@gmail.com

%Note: the filesize part was found on stackexchange...