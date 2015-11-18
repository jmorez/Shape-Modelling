function R=rotV(v,theta)
%Rotation around arbitrary (non-unit) vector v. 
%See https://en.wikipedia.org/wiki/Rotation_matrix#Rotation_matrix_from_axis_and_angle
    v=v/norm(v);
    R=  cos(theta).*eye(3,3)+ ...
        sin(theta).*[0 -v(3) v(2); v(3) 0 -v(1); -v(2) v(1) 0] ...
        +(1-cos(theta)).*(kron(v,v'));
end