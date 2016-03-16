function exportPoints(points,filepath)
    %<points> is an M x 3 matrix containing the xyz-coordinates of M
    %vertices. 
    %<filepath> is the full path to the output .obj file. Remember to include
    %the extension in <filepath>!
    
    [M,N]=size(points);
    if N~=3
        error('Invalid input size (%d by %d). \n',M,N);
        return
    end
    
    file=backward2ForwardSlash(filepath);
    f=fopen(file,'w');
    if f==-1
        error('Unable to write to %s \n',file);
        return
    else
        fprintf(1,'exportPoints: Writing %s . \n',file);
        
        %Needed for progress report
        reverseStr='';
        n=length(points);
        for j=1:n
            fprintf(f,'v %f %f %f \n',points(j,:));
            %Display progress
            if mod(j+round(n/100),round(n/100))==0 || j==n
                msg = sprintf('exportPoints: %d of %d vertices written.\n', j,n);
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end   
        
        disp('Done!')
        fclose(f);
    end
end

function validstr=backward2ForwardSlash(str)
%This function converts all backward slashes to forward slashes. Copying a
%directory in Windows will result in backward slashes, which messes up
%fprint and others because it is an escape character in that context.
    for j=1:length(str)
        ch=double(str(j));
        if(ch==92)
            validstr(j)=char(47);
        else
            validstr(j)=str(j);
        end
    end
end

%Written by Jan Morez, 22/10/2015 Visielab, Antwerpen jan.morez@gmail.com