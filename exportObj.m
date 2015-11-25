function exportObj(object,file)
    file=backward2ForwardSlash(file);
    f=fopen(file,'w');
    if f==-1
        fprintf(1,'Unable to write to %s. \n',file);
        return
    else
        fprintf(1,'Writing %s . \n',file);
        
        %Needed for progress report
        reverseStr='';
        
        for j=1:length(object.v)
            fprintf(f,'v %f %f %f \n',object.v(j,:));
            %Display progress
            if mod(j,round(length(object.v)/100))==0
                msg = sprintf('exportOBJ: %d of %d vertices written.\n', j,length(object.v));
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end
        for j=1:length(object.vt)
            fprintf(f,'vt %f %f \n',object.vt(j,:));
            %Display progress
            if mod(j,round(length(object.vt)/100))==0
                msg = sprintf('exportOBJ: %d of %d vertex texture coordinates written.\n', j,length(object.vt));
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end
        
        for j=1:length(object.vn)
            fprintf(f,'vn %f %f %f \n',object.vn(j,:));
            if mod(j,round(length(object.vn)/100))==0
                msg = sprintf('exportOBJ: %d of %d vertex normals written.\n', j,length(object.vn));
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end
        
        for j=1:length(object.f)
            %fprintf(f,'f %d %d %d %d \n',object.f(j,:));
            fprintf(f,'f %d/%d/%d %d/%d/%d %d/%d/%d %d/%d/%d \n', ...
                    kron(object.f(j,:),[1 1 1]));
            %Display progress
            if mod(j,round(length(object.vn)/100))==0
                msg = sprintf('exportOBJ: %d of %d faces written.\n', j,length(object.vn));
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end
        
        disp('Done!')
        fclose(f);
    end
end

%Written by Jan Morez, 22/10/2015
%Visielab, Antwerpen
%jan.morez@gmail.com