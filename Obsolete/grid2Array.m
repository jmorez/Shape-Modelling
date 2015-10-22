%Written by Jan Morez, 30/09/2015
%Universiteit Antwerpen
function array=grid2Array(file)
%Output is a M by 14-array with each column representing:
%[vertex ID] vx vy vz u v pu pv quad1 quad2 quad3 quad4
f=fopen(file);
if (f~=-1)
    n=1;
    while ~feof(f)
        line=fgetl(f);
        %Read the amount of quads (line 2 of the header).
        if(n==2)
            result=textscan(line,'%s %d');
            quads_amount=result{2};
            if(~isnumeric(quads_amount) || ~isinteger(quads_amount) || ~(quads_amount > 0))
                fprintf(1,'Invalid amount of quads!')
                return
            end
        else
        %Find the start of the actual quad data.
            data=sscanf(line,'%d %f %f %f %f %f %f %f %d %d %d %d %d %d');
            if(length(data)==14)
                break
            end
        end
        n=n+1;
    end
    
    %Now that we know the amount of quads, we can allocate an array.
    array=zeros(quads_amount,14);
    array(1,:)=data;
    
    %Needed for progress report
    reverseStr='';
    
    %Read the rest of the quads
    for j=2:quads_amount
        data=sscanf(fgetl(f),'%d %f %f %f %f %f %f %f %d %d %d %d %d %d');
        array(j,:)=data;
        
        %Display progress
        if mod(j,round(quads_amount/50))==0
            msg = sprintf('grid2Array: %d of %d read from file "%s" \n', j,quads_amount,file);
            fprintf([reverseStr, msg]);
            reverseStr = repmat(sprintf('\b'), 1, length(msg));
        end

    end
    
    %Adjust axes (z-axis is actually -x axis and v.v.)
    temp=array(:,2);
    array(:,2)=array(:,4);
    array(:,4)=-temp;
    
    disp('Done!')
    fclose(f);
else
    fprintf(1,'Unable to open file: "%s" \n', file);
    array=[];
end