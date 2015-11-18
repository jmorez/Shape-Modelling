function Br = rotateBasis(B,R)
    %B is a 3 by 3 matrix with its columns corresponding to each basis
    %vector. R is a rotation matrix. 
    Br(:,1:3) = R*B(:,1:3);
end