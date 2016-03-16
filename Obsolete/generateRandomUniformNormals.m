function vn = generateRandomUniformNormals(n)
    for i=1:n
        phi=2*pi*rand()-pi;
        theta=pi*rand();
        vn(i,1:3)=sph2cart(phi,theta,1);
    end
end