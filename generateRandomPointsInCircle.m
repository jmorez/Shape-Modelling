function [x,y] = generateRandomPointsInCircle(center, radius, amount)
        %This function generates a set amount of random points within a
        %disk. The distribution is uniform. 
        
        theta=rand(amount,1)*2*pi;
        rho=rand(amount,1)*radius;
        
        %http://mathworld.wolfram.com/DiskPointPicking.html
        x=sqrt(rho).*cos(theta)+center(1);
        y=sqrt(rho).*sin(theta)+center(2);
end