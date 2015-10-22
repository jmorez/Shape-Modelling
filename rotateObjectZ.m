function object_rotated = rotateObjectZ(object,angle)
    %Set up rotation matrix
    R=rotz(angle); 
    object_rotated=object;
    for j=1:length(object.v)
        %Rotate vertices
        object_rotated.v(j,:)=(R*object.v(j,:)')';   
        
        %Rotate vertex normals
        object_rotated.vn(j,:)=(R*object.vn(j,:)')';   
    end
end
