classdef VecOde45RegInterp
    properties  (Access=private)
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
        dyNewCorrCVec = [];
        oldnout;
    end
    methods
        function interpObj = VecOde45RegInterp(SData)
            % VECODE45REGINTERP - VecOde45RegInterp class constructor
            % Input:
            %   regular:
            %       SData: structure that stores all the data needed
            %           to build the solution on an arbitrary grid
            % Output:
            %   interpObj: gras.ode.VecOde45RegInterp[1,1]
            % $Author: Vadim Danilov <vadimdanilov93@gmail.com> $  
            % $Date: 24-09-2013$
            % $Copyright: Moscow State University,
            %  Faculty of Computational Mathematics and Cybernetics,
            %  Science, System Analysis Department 2013 $
            
            import modgen.common.throwerror;            
            
            function sizeOfField = getFieldLength(SData,nameField)
                import modgen.common.throwerror;  
                sizeOfField = 0;
                if isfield(SData,nameField) == 1
                    sizeOfField = length(getfield(SData,nameField));
                else
                    throwerror('wrongInput', ['filed ' nameField ' not exist in SData']);
                end;
            end
            function isExist = checkField(SData,nameField)
                import modgen.common.throwerror;  
                isExist = isfield(SData,nameField);
                if isExist
                    if isempty(getfield(SData,nameField))
                        throwerror('wrongInput', ['filed ' nameField ' is empty']);
                    end;
                end;
            end            
            maskVec = zeros(1,15);
            sizeFirstField = getFieldLength(SData,'tnewVec');
            resCheckVec = [getFieldLength(SData,'tnewVec') getFieldLength(SData,'ynewCVec')...
                           getFieldLength(SData,'tCVec') getFieldLength(SData,'yCVec')...
                           getFieldLength(SData,'hCVec') getFieldLength(SData,'fCVec')...
                           getFieldLength(SData,'dyNewCorrCVec') checkField(SData,'fOdeRegFunc')...
                           checkField(SData,'dataType') checkField(SData,'neq')...
                           checkField(SData,'t0') checkField(SData,'y0Vec')...
                           checkField(SData,'tfinal') checkField(SData,'next')...
                           checkField(SData,'oldnout')];
            resCheckVec(1,1:7) = resCheckVec(1,1:7) - sizeFirstField;
            resCheckVec(1,8:15) = resCheckVec(1,8:15) - 1;
            if ~isequal(maskVec,resCheckVec)
                throwerror('wrongInput', 'one of fields of SData is not exist or have wrong size');
            end;
            
            interpObj.tnewVec = SData.tnewVec; 
            interpObj.ynewCVec = SData.ynewCVec;
            interpObj.tCVec = SData.tCVec;
            interpObj.yCVec = SData.yCVec;
            interpObj.hCVec = SData.hCVec;
            interpObj.fCVec = SData.fCVec;
            interpObj.fOdeRegFunc = SData.fOdeRegFunc;
            interpObj.dataType = SData.dataType;
            interpObj.neq = SData.neq;
            interpObj.t0 = SData.t0;
            interpObj.y0Vec = SData.y0Vec;
            interpObj.tfinal = SData.tfinal;
            interpObj.next = SData.next;
            interpObj.dyNewCorrCVec = SData.dyNewCorrCVec;
            interpObj.oldnout = SData.oldnout;
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
            function yInterpVec = ntrp45(tInterp,tAdaptivGrid,yAdaptivGridVec,...
                                      stepGrid,fVec,fOdeRegFunc)
                biMat = [
                        1       -183/64      37/12       -145/128
                        0          0           0            0
                        0       1500/371    -1000/159    1000/371
                        0       -125/32       125/12     -375/64 
                        0       9477/3392   -729/106    25515/6784
                        0        -11/7        11/3        -55/28
                        0         3/2         -4            5/2
                    ];
                s = (tInterp - tAdaptivGrid)/stepGrid;  
                [~,yInterpVec] = fOdeRegFunc(tInterp,yAdaptivGridVec(:,ones(size(tInterp)))+...
                    fVec*(stepGrid*biMat)*cumprod([s;s;s;s]));
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
                    dyRegMat(:,idx)=repmat(self.dyNewCorrCVec{i},1,nout_new);
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