classdef VecOde45RegInterp
    properties
        tnewVec = []; 
        ynewCVec = [];
        tCVec = [];
        yCVec = [];
        hCVec = [];
        fCVec = [];
        fOdeRegFunc;
        dataType;
        neq;
        t0;
        y0Vec = [];
        tfinal;
        next;
        dyNewCorrVec = [];
        oldnout;
    end
    methods
        function interpObj = VecOde45RegInterp(fOdeReg)
            % VECODE45REGINTERP - VecOde45RegInterp class constructor
            % Input:
            %   regular:
            %       fOdeReg: function_handle[1,1] - function responsible 
            %           for regularizing the phase variables as 
            %           [isStrictViolation,yReg]=fOdeReg(t,y) where
            %           isStrictViolation is supposed to be true when y is
            %           outside of definition area of the right-hand side
            %           function
            % Output:
            %   interpObj: gras.ode.VecOde45RegInterp[1,1]
            % $Author: Vadim Danilov <vadimdanilov93@gmail.com> $  
            % $Date: 24-09-2013$
            % $Copyright: Moscow State University,
            %  Faculty of Computational Mathematics and Cybernetics,
            %  Science, System Analysis Department 2013 $
            interpObj.fOdeRegFunc = fOdeReg;
        end
        function [tout, yout, dyRegMat] = evaluate(self, timeVec)
            % EVALUATE - this method duplicates the function's 
            % gras.ode.ode45reg work on an arbitrary time grid timeVec
            % Input:
            %   regular:
            %       self: VecOde45RegInterp[1,1] - all the data nessecary 
            %           for calculation on an arbitrary time grid is stored in
            %           this object
            %       timeVec: double[1,nPoints] - time range, same meaning 
            %           as in ode45
            %   Output:
            %       tout: double[nPoints,1] - time grid, same meaning as in
            %           ode45            %
            %       yout: double[nPoints,nDims] - solution, same meaning as
            %           in ode45            %
            %       dyRegMat: double[nPoints,nDims] - regularizing
            %           derivative addition to the right-hand side
            %           function value performed at each step, basically
            %           yout is a solution of
            %           dot(y)=fOdeDeriv(t,y)+dyRegMat(t,y)
            %
            % $Author: Vadim Danilov  <vadimdanilov93@gmail.com>
            % $	$Date: 2013$
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer
            %            Science, System Analysis Department 2013 $
            %
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
            
            import modgen.common.throwerror;
            
            nIter = size(self.tnewVec,2);
            nTspan = size(timeVec,2);
            if nTspan > 2
                tout = zeros(1,nTspan,self.dataType);
                yout = zeros(self.neq,nTspan,self.dataType);
                dyRegMat=yout;
            else
                throwerror('wrongInput','length of timeVec should be more that 2');
            end;
            if (~((timeVec(nTspan) <= self.tfinal) && (timeVec(1) >= self.t0)))
                throwerror('wrongInput','segment [timeVec(1), timeVec(end)] should be inside domain solutions');
            end;
            
            nout = 1;
            indVec = 1:nIter;
            if self.t0 ~= timeVec(1)
                indVec = indVec(self.tnewVec > timeVec(1) & self.tnewVec < timeVec(nTspan));
                ind0 = indVec(1);
                tout(nout) = timeVec(1);
                yout(:,nout) = ntrp45(timeVec(1),self.tCVec{ind0},...
                            self.yCVec{ind0},self.hCVec{ind0},self.fCVec{ind0},self.fOdeRegFunc);
            else
                tout(nout) = self.t0;
                yout(:,nout) = self.y0Vec;
            end;
                
            for i = 1:nIter;
                nout_new =  0;
                tout_new = [];
                yout_new = [];
                while self.next <= nTspan
                    if self.tnewVec(i) < timeVec(self.next)
                        break;
                    end
                    nout_new = nout_new + 1;
                    tout_new = [tout_new, timeVec(self.next)];
                    if timeVec(self.next) == self.tnewVec(i);
                        yout_new = [yout_new, self.ynewCVec{i}];
                    else
                        yout_new = [yout_new, ntrp45(timeVec(self.next),self.tCVec{i},...
                            self.yCVec{i},self.hCVec{i},self.fCVec{i},self.fOdeRegFunc)];
                    end
                    self.next = self.next + 1;
                end
                
                if nout_new > 0
                    oldnout = nout;
                    nout = nout + nout_new;
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