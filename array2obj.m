function array2obj(quads,file)
    n=length(quads);
    f=fopen(file,'w');
    if (f~=-1)
        %Needed for progress report
        reverseStr='';
        for j=1:n
            fprintf(f,'v %f %f %f \n',quads(j,2),quads(j,3),quads(j,4));
            %Display progress
            if mod(j,round(n/10)-1)==0
                msg = sprintf('array2obj: %d of %d vertices written... \n', j,n);
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end
        %Write quad data
        for j=1:n
            face=[quads(j,11) quads(j,12) quads(j,13) quads(j,14)];
            %Remove -1 entries and adjust to one-indexing
            face=face(face~=-1)+1;
            face=int2str(face);
            fprintf(f,'f %s \n',face);
            %Display progress
            if mod(j,round(n/10)-1)==0
                msg = sprintf('array2obj: %d of %d quads written... \n', j,n);
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end
        fclose(f);
    else
        fprintf(1,'Error: failed to create file: "%s" \n',file);
    end
end