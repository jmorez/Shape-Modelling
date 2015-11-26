function A=removeEps(A)
    %Rounds all entries to some integer if their distance to the nearest
    %integer is less than eps(1). 
    idx=abs(round(A)-A) < ones(size(A)).*eps(1);
    A(idx)=round(A(idx));
end