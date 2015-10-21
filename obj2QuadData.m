function quadData=obj2QuadData(file)
    f=fopen(file);
    if f==-1
        fprintf(1, 'Failed to open "%s% \n', file);
        quadData=[];
    else
        %# Get file size, because preallocation *really* makes a difference now.
        fseek(f, 0, 'eof');
        fileSize=ftell(f);
        frewind(f);
        %# Read the whole file.
        data=fread(f, fileSize, 'uint8');
        %# Count number of line-feeds and increase by one.
        numLines=sum(data==10);
        frewind(f)

        %Finding the face data is a bit more involved because they have the
        %format "f v1/v1n/v1t etc."
        m=1;
        n=1;
        vertexData=zeros(numLines,3);
        faceData=zeros(numLines,4);
        reverseStr='';
        for j=1:numLines
            %Needed for progress report
            line=fgetl(f);
            if length(line) > 1
                if strcmp(line(1:2),'v ')
                    line_parsed=textscan(line, 'v %f %f %f');
                    vertexData(n,1:3)=[line_parsed{1} line_parsed{2} line_parsed{3}];
                    n=n+1;
                elseif strcmp(line(1), 'f')
                    line_parsed=regexp(line, '\d*');
                    faceData(m,1)=line_parsed(1); 
                    faceData(m,2)=line_parsed(4); 
                    faceData(m,3)=line_parsed(7);
                    faceData(m,4)=line_parsed(10);
                    m=m+1;
                end
            end
            %Display progress
            if mod(j,10000)==0
                msg = sprintf('obj2QuadData: %d lines read from file "%s" \n', j,file);
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end
        fclose(f);
        quadData{1}=vertexData(1:m,:);
        quadData{2}=faceData(1:n,:);
    end
    
end