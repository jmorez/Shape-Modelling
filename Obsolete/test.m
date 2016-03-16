    hold on
    for j=1:5
        pcshow(normrnd(0,5,100,3));
    end
    hold off
%Then if you use the "Rotate 3D" button:

%%%%%%%%%%%%%%%%%%%CONSOLE OUTPUT: 
% Error using matlab.graphics.axis.Axes/set
% While setting the 'CameraPosition' property of 'Axes':
% Input values must be finite numbers.
% 
% Error in camorbit (line 63)
% set(ax, 'cameraposition', newPos, 'cameraupvector', newUp);
% 
% Error in cameratoolbar>orbitPangca (line 631)
%                 camorbit(haxes,xy(1), xy(2), coordsys)
% 
% Error in cameratoolbar (line 215)
%                     orbitPangca(hfig,haxes,deltaPix, 'o');
% 
% Error in cameratoolbar>@(~,~)cameratoolbar(hfig,'motion') (line 196)
%                     set(hfig, 'WindowButtonMotionFcn', @(~,~) cameratoolbar(hfig, 'motion'))
%  
% Error while evaluating Figure WindowButtonMotionFcn