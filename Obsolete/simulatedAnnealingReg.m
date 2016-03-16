function [TR,TT,d]=simulatedAnnealingReg(obj_fixed,obj_moving,subsample_factor,TR0,TT0,dmin,sigma_rot,sigma_trans)
TR=TR0; TT=TT0;
    obj_fixed_d=downsampleObject(obj_fixed,subsample_factor);
    obj_moving_d=downsampleObject(obj_moving,subsample_factor);
    d(1)=ModHausdorffDist(obj_fixed_d.v,obj_moving_d.v); d_best=d
    n=1;
    success=0;
    TTn=[];
    while d(n) > dmin
        
        n=n+1;
        [dTR,dTT]=generateRndRigidTransform(sigma_rot,sigma_trans);
        
        TR=dTR*TR;
        TT=TT+0.05*dTT;
        TTn=cat(1,TTn,TT');
        obj_moving_t=rigidTransform(obj_moving_d,TR,TT);
        d(n)=ModHausdorffDist(obj_fixed_d.v,obj_moving_t.v);
        disp(d(n));
        if d(n) > d_best
            TR=TR/dTR;
            TT=TT-0.01*dTT;
            disp('Crap!')
            fprintf(1,'%d / %d ',success,n);
        else
            sigma_rot=sigma_rot*0.5;
            sigma_trans=sigma_trans*0.5;
            obj_moving_d=obj_moving_t;
            disp('Good!')
            d_best=d(n)
            success=success+1;
        end
        if(d(n) > 100000)
            return
        end
        if n==2
            q=quiver3(0,0,0,TT(1),TT(2),TT(3));
        else
            set(q,'XData',zeros(n-1,1),'YData',zeros(n-1,1),'ZData',zeros(n-1,1), ...
                'UData',TTn(:,1),'VData',TTn(:,2),'WData',TTn(:,3));
            refreshdata; drawnow;
        end
    end
    %plot(1:n,d,'ko-');
end

%Note: perhaps generate only a translation, a rotation axis and an angle. 
%Now we generate random rotation axes, which greatly increases the chances
%to rotate incorrectly. 
function [TR,TT]=generateRndRigidTransform(sigma_rot,sigma_trans)
    TT=normrnd(0,sigma_trans,3,1);
    TT=TT./norm(TT);

    rot_axis=rand(3,1);
    rot_axis=rot_axis/norm(rot_axis);
    %rot_axis=[0 0 1];
    theta=normrnd(0,sigma_rot);
    TR=rotV(rot_axis,pi/2);
end