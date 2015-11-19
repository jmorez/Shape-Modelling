hold on
stride=64;
z_mean=0;
for j=[1 2]
    B{j}=pca(objects_raw{j}.v,'centered',true);
    [~,c(1:3,j)]=centerObj(objects_raw{j});
    plot3(objects_raw{j}.v(1:stride:end,1),objects_raw{j}.v(1:stride:end,2),objects_raw{j}.v(1:stride:end,3),'.','Color',[0 j/8 1-j/8],'Markersize',1)
    drawBasis(c(:,j),B{j},25,'color',[0 j/8 1-j/8],'linewidth',2);
    z_mean=B{j}+z_mean;
end
z_mean=-z_mean/4;
c_mean=mean(c,2);
quiver3(c_mean(1),c_mean(2),c_mean(3),z_mean(1),z_mean(2),z_mean(3),50,'color',[1 0 0]),'linewidth',2;
axis image; view(3); camorbit(5,0);
hold off