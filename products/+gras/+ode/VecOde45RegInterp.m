classdef VecOde45RegInterp
    properties
        tnew_arr = [];
        ynew_arr = [];
        t_arr = [];
        y_arr = [];
        h_arr = [];
        f_arr = [];
        odeRegFunc = [];
        dataType = [];
        neq = [];
        t0 = [];
        y0 = [];
        next = [];
        dyNewCorrVec = [];
    end
    methods
        function interpObj = VecOde45RegInterp(fOdeReg)
            interpObj.odeRegFunc = fOdeReg;
        end
        function [tout, yout, dyRegMat] = evaluate(self, timeVec) % не забудь, что тут должен быть другой выход
            function yinterp = ntrp45(tinterp,t,y,h,f,fOdeReg)
            BI = [
                    1       -183/64      37/12       -145/128
                    0          0           0            0
                    0       1500/371    -1000/159    1000/371
                    0       -125/32       125/12     -375/64 
                    0       9477/3392   -729/106    25515/6784
                    0        -11/7        11/3        -55/28
                    0         3/2         -4            5/2
                ];
            s = (tinterp - t)/h;  
            [~,yinterp] = fOdeReg(tinterp,y(:,ones(size(tinterp)))+...
                f*(h*BI)*cumprod([s;s;s;s]));
            end
            niter = size(self.tnew_arr,2);
            ntspan = size(timeVec,2);
            if ntspan > 2                         % output only at tspan points
                tout = zeros(1,ntspan,self.dataType);
                yout = zeros(self.neq,ntspan,self.dataType);
                dyRegMat=yout;
            else
            end;
            
            nout = 1;
            tout(nout) = self.t0;
            yout(:,nout) = self.y0;
            
            for i = 1:niter
                nout_new =  0;
                tout_new = [];
                yout_new = [];
                while self.next <= ntspan
                    if self.tnew_arr{i} < timeVec(self.next)
                        break;
                    end
                    nout_new = nout_new + 1;
                    tout_new = [tout_new, timeVec(self.next)];
                    if timeVec(self.next) == self.tnew_arr{i};
                        yout_new = [yout_new, self.ynew_arr{i}];
                    else
                        yout_new = [yout_new, ntrp45(timeVec(self.next),self.t_arr{i},...
                            self.y_arr{i},self.h_arr{i},self.f_arr{i},self.odeRegFunc)];
                    end
                    self.next = self.next + 1;
                end
                
                if nout_new > 0
                    oldnout = nout;
                    nout = nout + nout_new;
                    %if nout > length(tout)
                        %'nout > length(tout)'
                        %tout = [tout, zeros(1,chunk,self.dataType)];  % requires chunk >= refine
                        %yout = [yout, zeros(self.neq,chunk,selfdataType)];
                    %end
                    idx = oldnout+1:nout;
                    tout(idx) = tout_new;
                    yout(:,idx) = yout_new;
                    dyRegMat(:,idx)=repmat(self.dyNewCorrVec{i},1,nout_new);
                end
                
            end
            
                
            shrinkResults();
            function shrinkResults()
                tout = tout(1:nout).';
            	yout = yout(:,1:nout).';
            	dyRegMat = dyRegMat(:,1:nout).';
            end
            
            
        end
    end
end