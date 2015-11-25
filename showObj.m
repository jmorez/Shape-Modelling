function showObj(object,C)
    %Pure lazyness...
    if length(object)==1
        pcshow(object.v,C);
    else
        hold on
        for j=1:length(object)
            pcshow(object{j}.v);
        end
        hold off
    end
end