function object_triangles=quads2Triangles(object_quads)
    object_triangles=zeros(2*length(object_quads),3);
    n=1;
    for j=1:length(object_quads)
        v1=object_quads(j,1);
        v2=object_quads(j,2);
        v3=object_quads(j,3);
        v4=object_quads(j,4);
        object_triangles(n,:)=[v1 v2 v3];
        object_triangles(n+1,:)=[v2 v4 v3];
        n=n+2;
    end
end