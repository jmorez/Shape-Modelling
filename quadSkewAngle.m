function [angle,index]=quadSkewAngle(quadData)
%This function will calculate the skew angle for every quad and return both
%the angle and the index.

    %Make a list of all quads, i.e. remove everything with a -1
    quads=quadData(:,5:8);
    quads_filtered=zeros(size(quads));
    keep_quad=zeros(length(quads),1);
    %Remove everything that is not a quad but keep the index
    n=1;
    for j=1:length(quadData)
        if sum(-1==quads(j,:))==0
            quads_filtered(j,:)=quads(j,:);
            keep_quad(j)=1;
            index(n,1)=j-1;
            n=n+1;
        end
    end
    quads_filtered=quads_filtered(keep_quad==1,:);
    n=length(quads_filtered);
    reverseStr='';
    %Calculate eigenvalues of each quad
    angle=zeros(length(quads_filtered),1);
    for j=1:length(quads_filtered)
        v1=quadData(quads_filtered(j,1),2:4);
        v2=quadData(quads_filtered(j,2),2:4);
        v3=quadData(quads_filtered(j,3),2:4);
        v4=quadData(quads_filtered(j,4),2:4);
        %PCA-measure, slow, not very useful either
%       M=[v1' v2' v3' v4'];
%       M_c=M-repmat(mean(M,2),1,4);
%       ar(j,1:2)=pca(M_c,'NumComponents',2);
        
        %Skew-angle quality measure
        x=(v1-v4-v3+v2);
        y=(v2-v1-v4+v3);
        angle(j)=acos(((v1-v4-v3+v2)*(v2-v1-v4+v3)')/(norm(v1-v4-v3+v2)*norm(v2-v1-v4+v3)));

        
        %Display progress
        if mod(j,round(n/1000)-1)==0
            msg = sprintf('quadSkewAngle: %d of %d quads analyzed... \n', j,n);
            fprintf([reverseStr, msg]);
            reverseStr = repmat(sprintf('\b'), 1, length(msg));
        end
    end
end