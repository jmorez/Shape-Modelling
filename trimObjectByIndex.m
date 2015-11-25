function object_trimmed=trimObjectByIndex(object,flag)
    %Remove vertices according to the flag. Flag is an M by 1 matrix where
    %1 indicates that the corresponding vertex should be kept and 0 that it
    %should be removed. Removing vertices will result in a shift in
    %indices, so the function will also remap all indices in the face data.
    
    %Draw an indexed array and remove an entry to intuitively see this
    %correspondence.
    mapping=cumsum(flag);
    %n=length(object.v);
    
    %Remove all vertices that were flagged
    object_trimmed.v =object.v(logical(flag),:);
    object_trimmed.vt=object.vt(logical(flag),:);
    object_trimmed.vn=object.vn(logical(flag),:);
    
    %Extract quad indices for remapping, switch to one-based indexing so we
    %can apply the mapping easily.
    facedata=object.f(:,1:4);
    newfacedata=zeros(size(facedata));  
    
    %Remap, if the quad references a deleted point, remove it altogether.
    keepface=ones(length(facedata),1);
    for j=1:length(facedata)
            newfacedata(j,1)=mapping(facedata(j,1))*flag(facedata(j,1));
            newfacedata(j,2)=mapping(facedata(j,2))*flag(facedata(j,2));
            newfacedata(j,3)=mapping(facedata(j,3))*flag(facedata(j,3));
            newfacedata(j,4)=mapping(facedata(j,4))*flag(facedata(j,4));
            if any(~newfacedata(j,:))==1
                keepface(j)=0;
            end
    end
    object_trimmed.f(:,1:4)=newfacedata(logical(keepface),1:4);
end

%Written by Jan Morez, 22/10/2015
%Visielab, Antwerpen
%jan.morez@gmail.com