classdef VecOde45RegInterp
    properties  (Access=private)
        tNewVec = [] 
        yNewCVec = []
        tCVec = []
        yCVec = []
        hCVec = []
        fCVec = []
        fOdeRegFunc
        dataType
        nEquations
        tBegin
        yBeginVec = []
        tFinal
        iNext
        dyNewCorrCVec = []
        nOldCountElements
    end
    methods
        function interpObj = VecOde45RegInterp(SData)
            % VECODE45REGINTERP - VecOde45RegInterp class constructor
            % Input:
            %   regular:
            %       SData: struct[1,1] - structure stores all the data
            %           needed to build the solution on an arbitrary grid
            %           
            %           tNewVec: double[1,nIter] - new nodes of adaptive
            %               time grid
            %           yNewCVec: cell[1,nIter] - values of the resulting
            %               function in nodes new adaptive time grid
            %           tCVec: cell[1,nIter] - nodes of adaptive time grid
            %           yCVec: cell[1,nIter] - values of the resulting
            %               function in nodes adaptive time grid
            %           hCVec: cell[1,nIter] - step of adaptive time grid 
            %               on each iteration
            %           fCVec: cell[1,nIter] - values ??of the derivatives
            %           fOdeRegFunc: function_handle[1,1] -function
            %               responsible for regularizing
            %           dataType: char[1,1] - data type, result of the 
            %               function superiorfloat()
            %           nEquations: double[1,1] - the number of equations 
            %               in the system
            %           tBegin: double[1,1] - start time
            %           yBeginVec: double[nEquations,1] - initial
            %               conditions
            %           tFinal: double[1,1] - end time
            %           iNext: double[1,1] - next iteration index
            %           dyNewCorrCVec: cell[1,nIter] - list of new
            %               correctional vectors
            %           nOldCountElements: double[1,1] - the number of
            %               elements in the previous iteration
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
                'fOdeRegFunc','hCVec','iNext','nEquations',...
                'nOldCountElements','tBegin','tCVec','tFinal',...
                'tNewVec','yBeginVec','yCVec','yNewCVec'};
            fieldNameList=sort(fieldnames(SData))';
            if ~isequal(fieldNameList,EXP_FIELD_LIST)
                throwerror('wrongInput',['one or more fields in SData' ...
                    ' are absent']);              
            end;
            sizeStructFields = structfun(@length,SData);
            if ~isequal(sizeStructFields(8:14)-sizeStructFields(8),...
                    zeros(7,1))
                throwerror('wrongInput',['one or more fields of SData '...
                    'have a wrong size']);
            end;
            interpObj.tNewVec = SData.tNewVec; 
            interpObj.yNewCVec = SData.yNewCVec;
            interpObj.tCVec = SData.tCVec;
            interpObj.yCVec = SData.yCVec;
            interpObj.hCVec = SData.hCVec;
            interpObj.fCVec = SData.fCVec;
            interpObj.fOdeRegFunc = SData.fOdeRegFunc;
            interpObj.dataType = SData.dataType;
            interpObj.nEquations = SData.nEquations;
            interpObj.tBegin = SData.tBegin;
            interpObj.yBeginVec = SData.yBeginVec;
            interpObj.tFinal = SData.tFinal;
            interpObj.iNext = SData.iNext;
            interpObj.dyNewCorrCVec = SData.dyNewCorrCVec;
            interpObj.nOldCountElements = SData.nOldCountElements;
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
            nIter = size(self.tNewVec,2);
            nTspan = size(timeVec,2);
            if nTspan > 2
                tOutVec = zeros(1,nTspan,self.dataType);
                yOutMat = zeros(self.nEquations,nTspan,self.dataType);
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
            indVec = 1:nIter;
            if self.tBegin ~= timeVec(1)
                indVec = indVec(self.tNewVec > timeVec(1) & ...
                    self.tNewVec < timeVec(nTspan));
                ind0 = indVec(1);
                tOutVec(nOut) = timeVec(1);
                yOutMat(:,nOut) = ntrp45(timeVec(1),self.tCVec{ind0},...
                            self.yCVec{ind0},self.hCVec{ind0},...
                            self.fCVec{ind0},self.fOdeRegFunc);
            else
                tOutVec(nOut) = self.tBegin;
                yOutMat(:,nOut) = self.yBeginVec;
            end;
                
            for i = 1:nIter;
                nOutNew =  0;
                tNewOutVec = [];
                yNewOutMat = [];
                while self.iNext <= nTspan
                    if self.tNewVec(i) < timeVec(self.iNext)
                        break;
                    end
                    nOutNew = nOutNew + 1;
                    tNewOutVec = [tNewOutVec, timeVec(self.iNext)];
                    if timeVec(self.iNext) == self.tNewVec(i);
                        yNewOutMat = [yNewOutMat, self.yNewCVec{i}];
                    else
                        yNewOutMat = [yNewOutMat,...
                            ntrp45(timeVec(self.iNext),self.tCVec{i},...
                            self.yCVec{i},self.hCVec{i},self.fCVec{i},...
                            self.fOdeRegFunc)];
                    end
                    self.iNext = self.iNext + 1;
                end
                
                if nOutNew > 0
                    nOldCountElements = nOut;
                    nOut = nOut + nOutNew;
                    idx = nOldCountElements+1:nOut;
                    tOutVec(idx) = tNewOutVec;
                    yOutMat(:,idx) = yNewOutMat;
                    dyRegMat(:,idx)=repmat(self.dyNewCorrCVec{i},1,...
                        nOutNew);
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