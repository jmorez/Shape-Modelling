function quadData2Obj(quadData,file)
    n=length(quadData);
    f=fopen(file,'w');
    if (f~=-1)
        %Needed for progress report
        reverseStr='';
        for j=1:n
            fprintf(f,'v %f %f %f \n',quadData(j,2),quadData(j,3),quadData(j,4));
            %Display progress
            if mod(j,round(n/10)-1)==0
                msg = sprintf('quadData2Obj: %d of %d vertices written to "%s" \n', j,n,file);
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end
        %Write quad data
        for j=1:n
            face=[quadData(j,5) quadData(j,6) quadData(j,7) quadData(j,8)];
            %Remove -1 entries and adjust to one-indexing
            face=face(face~=-1)+1;
            if length(face)> 2 %Remove anything that is not a quad, this doesn't work though
                face=int2str(face);
                fprintf(f,'f %s \n',face);
            end
            %Display progress
            if mod(j,round(n/10)-1)==0
                msg = sprintf('quadData2Obj: %d of %d quads written to "%s" \n', j,n,file);
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end
        fclose(f);
    else
        fprintf(1,'Error: failed to create file: "%s" \n',file);
    end
end