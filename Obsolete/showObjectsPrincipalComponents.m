    function coeffs=showObjectsPrincipalComponents(objects)
    hold on;
    n=length(objects);
    
    %Set up some colors going from red to purple
    color=zeros(n,3);
    color(:,1)=linspace(0,1,n);
    color(:,3)=linspace(1,0,n);
    for j=1:n
        coeffs=pca(objects{j}{1}.v,'Centered',true);
        [~,c]=centerObj(objects{j}{1});
        %Draw object
        %scatter3(obj_centered{j},1,color(j,:));
        %Draw main axes
        %quiver3(zeros(1,3),zeros(1,3),zeros(1,3),...
        %        coeffs(1,:),coeffs(2,:),coeffs(3,:),50,'Color',color(j,:));
        %quiver3(0,0,0,...
        %        coeffs(1,1),coeffs(2,1),coeffs(3,1),50,'Color',color(j,:));
        %drawnow;   
    end
    hold off
end