classdef VecOde45RegInterp
    properties  (Access=private)
        tVec = [] 
        yCVec = []
        hVec = []
        fCVec = []
        fOdeRegFunc
        dataType
        nSysDims
        tBegin
        yBeginVec = []
        tFinal
        dyNewCorrCVec = []
    end
    methods
        function interpObj = VecOde45RegInterp(SData)
            % VECODE45REGINTERP - VecOde45RegInterp class constructor
            % Input:
            %   regular:
            %       SData: struct[1,1] - structure stores all the data
            %           needed to build the solution on an arbitrary grid
            %           
            %           tVec: double[1,nKnots] - nodes of adaptive
            %               time grid
            %           yCVec: cell[1,nKnots] of double[nSysDims,1] - 
            %               values of the resulting function in nodes 
            %               adaptive time grid
            %           hVec: double[1,nKnots] - step of adaptive time grid
            %           fCVec: cell[1,nKnots] of double[nSysDims,1] - 
            %               values of the derivatives
            %           fOdeRegFunc: function_handle[1,1] - function
            %               responsible for regularizing
            %           dataType: char[1] - data type, result of the 
            %               function superiorfloat()
            %           nSysDims: double[1,1] - the number of equations 
            %               in the system
            %           tBegin: double[1,1] - start time
            %           yBeginVec: double[nSysDims,1] - initial
            %               conditions
            %           tFinal: double[1,1] - end time
            %           dyNewCorrCVec: cell[1,nKnots] of double[nSysDims,1]
            %               - list of new   correctional vectors
            %     
            % Output:
            %   interpObj: gras.ode.VecOde45RegInterp[1,1]
            % $Author: Vadim Danilov <vadimdanilov93@gmail.com> $  
            % $Date: 24-09-2013$
            % $Copyright: Moscow State University,
            %  Faculty of Computational Mathematics and Cybernetics,
            %  Science, System Analysis Department 2013 $
                          
            import modgen.common.throwerror;
            EXP_FIELD_LIST={'dataType','dyNewCorrCVec','fCVec',...
                'fOdeRegFunc','hVec',...
                'nSysDims','tBegin','tFinal','tVec','yBeginVec','yCVec'};
            fieldNameList=sort(fieldnames(SData)).';
            if ~isequal(fieldNameList,EXP_FIELD_LIST)
                throwerror('wrongInput',['one or more fields in SData' ...
                    ' are absent']);              
            end;
            sizeStructFieldsVec = structfun(@length,SData);
            sizeStructFieldsVec(7:11)=sizeStructFieldsVec(7:11)...
                -sizeStructFieldsVec(9);
            sizeStructFieldsVec(7:8) = sizeStructFieldsVec(7:8) - 1;
            if ~isequal(sizeStructFieldsVec(7:11),zeros(5,1));
                throwerror('wrongInput',['one or more fields of SData '...
                    'have a wrong size']);
            end;
            interpObj.tVec = SData.tVec;
            interpObj.yCVec = SData.yCVec;
            interpObj.hVec = SData.hVec;
            interpObj.fCVec = SData.fCVec;
            interpObj.fOdeRegFunc = SData.fOdeRegFunc;
            interpObj.dataType = SData.dataType;
            interpObj.nSysDims = SData.nSysDims;
            interpObj.tBegin = SData.tBegin;
            interpObj.yBeginVec = SData.yBeginVec;
            interpObj.tFinal = SData.tFinal;
            interpObj.dyNewCorrCVec = SData.dyNewCorrCVec;
        end
        function [tOutVec, yOutMat, dyRegMat] = evaluate(self, timeVec)
            % EVALUATE - this method duplicates the function's 
            % gras.ode.ode45reg work on an arbitrary time grid timeVec
            % Input:
            %   regular:
            %       self: VecOde45RegInterp[1,1] - all the data nessecary 
            %           for calculation on an arbitrary time grid is
            %           stored in   this object
            %       timeVec: double[1,nPoints] - time range, same meaning 
            %           as in ode45
            %   Output:
            %       tOutVec: double[nPoints,1] - time grid, same meaning
            %           as in ode45
            %       yOutMat: double[nPoints,nDims] - solution, same meaning
            %           as in ode45
            %       dyRegMat: double[nPoints,nDims] - regularizing
            %           derivative addition to the right-hand side
            %           function value performed at each step, basically
            %           yOutMat is a solution of
            %           dot(y)=fOdeDeriv(t,y)+dyRegMat(t,y)
            %
            % $Author: Vadim Danilov  <vadimdanilov93@gmail.com>
            % $	$Date: 2013$
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer
            %            Science, System Analysis Department 2013 $
            %
            function yInterpVec = ntrp45(tInterp,tAdaptivGrid,...
                    yAdaptivGridVec,stepGrid,fVec,fOdeRegFunc)
                biMat = [
                        1       -183/64      37/12       -145/128
                        0          0           0            0
                        0       1500/371    -1000/159    1000/371
                        0       -125/32       125/12     -375/64 
                        0       9477/3392   -729/106    25515/6784
                        0        -11/7        11/3        -55/28
                        0         3/2         -4            5/2
                    ];
                hInterpRatio = (tInterp - tAdaptivGrid)/stepGrid;  
                [~,yInterpVec] = fOdeRegFunc(tInterp,yAdaptivGridVec(:,...
                    ones(size(tInterp)))+fVec*(stepGrid*biMat)*...
                    cumprod([hInterpRatio;hInterpRatio;hInterpRatio;...
                    hInterpRatio]));
            end
            
            import modgen.common.throwerror;
            nIter = size(self.tVec,2);
            nTspan = size(timeVec,2);
            if nTspan > 2
                tOutVec = zeros(1,nTspan,self.dataType);
                yOutMat = zeros(self.nSysDims,nTspan,self.dataType);
                dyRegMat=yOutMat;
            else
                throwerror('wrongInput',['length of timeVec should be'... 
                    ' more that 2']);
            end;
            if (~((timeVec(nTspan) <= self.tFinal) && ...
                    (timeVec(1) >= self.tBegin)))
                throwerror('wrongInput',['segment [timeVec(1),'...
                    ' timeVec(end)] should be inside domain solutions']);
            end;
            
            nOut = 1;
            indVec = 2:nIter;
            if self.tBegin ~= timeVec(1)
                indVec = indVec(self.tVec(2:end) > timeVec(1) & ...
                    self.tVec(2:end) < timeVec(nTspan));
                ind0 = indVec(1);
                tOutVec(nOut) = timeVec(1);
                yOutMat(:,nOut) = ntrp45(timeVec(1),self.tVec(ind0-1),...
                            self.yCVec{ind0-1},self.hVec(ind0-1),...
                            self.fCVec{ind0-1},self.fOdeRegFunc);
            else
                tOutVec(nOut) = self.tBegin;
                yOutMat(:,nOut) = self.yBeginVec;
            end;
            
            iNext = 2;                
            for iIter = 2:nIter;
                nOutNew =  0;
                tNewOutVec = [];
                yNewOutMat = [];
                while iNext <= nTspan
                    if self.tVec(iIter) < timeVec(iNext)
                        break;
                    end
                    nOutNew = nOutNew + 1;
                    tNewOutVec = [tNewOutVec, timeVec(iNext)];
                    if timeVec(iNext) == self.tVec(iIter);
                        yNewOutMat = [yNewOutMat, self.yCVec{iIter}];
                    else
                        yNewOutMat = [yNewOutMat,...
                            ntrp45(timeVec(iNext),self.tVec(iIter-1),...
                            self.yCVec{iIter-1},self.hVec(iIter-1),...
                            self.fCVec{iIter-1},self.fOdeRegFunc)];
                    end
                    iNext = iNext + 1;
                end
                
                if nOutNew > 0
                    nOldCountElements = nOut;
                    nOut = nOut + nOutNew;
                    idx = nOldCountElements+1:nOut;
                    tOutVec(idx) = tNewOutVec;
                    yOutMat(:,idx) = yNewOutMat;
                    dyRegMat(:,idx)=repmat(self.dyNewCorrCVec{iIter-1},...
                        1,nOutNew);
                end
                
            end
            
            shrinkResults();
            function shrinkResults()
                tOutVec = tOutVec(1:nOut).';
            	yOutMat = yOutMat(:,1:nOut).';
            	dyRegMat = dyRegMat(:,1:nOut).';
            end
          
        end
    end
end