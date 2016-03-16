function triData2Obj(triData,file)
    n=length(triData{1});
    f=fopen(file,'w');
    if (f~=-1)
        %Needed for progress report
        reverseStr='';
        for j=1:n
            fprintf(f,'v %f %f %f \n',triData{1}(j,2),triData{1}(j,3),triData{1}(j,4));
            %Display progress
            if mod(j,round(n/10)-1)==0
                msg = sprintf('triData2Obj: %d of %d vertices written to "%s" \n', j,n,file);
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end
        %Write quad data
        n=length(triData{2});
        for j=1:n
            face=[triData{2}(j,1) triData{2}(j,2) triData{2}(j,3)];
            %Remove -1 entries and adjust to one-indexing
            face=face(face~=-1)+1;
            if length(face)> 2 %Remove anything that is not a quad, this doesn't work though
                face=int2str(face);
                fprintf(f,'f %s \n',face);
            end
            %Display progress
            if mod(j,round(n/10)-1)==0
                msg = sprintf('triData2Obj: %d of %d triangles written to "%s" \n', j,n,file);
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end
        fclose(f);
    else
        fprintf(1,'Error: failed to create file: "%s" \n',file);
    end
end