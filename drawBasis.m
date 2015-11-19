function drawBasis(loc,B,varargin)
    %Draws a basis B ( 3 by 3 matrix with columns being the basis vectors) at
    %the location loc (3-element vector)
    %varargin will directly be sent to quiver3, so the documentation for
    %that is identical. 
    %hold on
    x=repmat(loc(1),1,3);
    y=repmat(loc(2),1,3);
    z=repmat(loc(3),1,3);
    quiver3(x, y, z, B(1,:), B(2,:), B(3,:),varargin{:});    
    %hold off
end