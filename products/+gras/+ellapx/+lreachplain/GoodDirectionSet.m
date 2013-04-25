classdef GoodDirectionSet
    properties
        % rstTransArray: double[nDims,nDims,nTimePoints] - R(s,t)' is a
        % transition matrix for good directions l(t)=R(s,t)'l_0
        RstTransDynamics
        ltGoodDirCurveSpline
        ltGoodDirOneCurveSplineList
        sTime
        lsGoodDirMat
    end
    properties (Constant, GetAccess = protected)
        ODE_NORM_CONTROL='on';
        CALC_PRECISION_FACTOR=0.001;
    end
    properties (Constant, GetAccess = private)
        % (temporary) algorithm:
        %   0 - X(t, t0)
        %   1 - X(t, t0) / matrixnorm(X(t, t0))
        %   2 - R(t, t0)
        %   3 - [R(t, t0); matrixnorm(X(t, t0))]
        %
        CALC_ALGORITHM = 0;
    end
    methods
        function nGoodDirs=getNGoodDirs(self)
            nGoodDirs=size(self.lsGoodDirMat,2);
        end
        function ltGoodDirCurveSpline=getGoodDirCurveSpline(self)
            ltGoodDirCurveSpline=self.ltGoodDirCurveSpline;
        end
        function ltGoodDirCurveSpline=getGoodDirOneCurveSpline(self,dirNum)
            ltGoodDirCurveSpline=...
                self.ltGoodDirOneCurveSplineList{dirNum};
        end
        function ltGoodDirSplineList=getGoodDirOneCurveSplineList(self)
            ltGoodDirSplineList=...
                self.ltGoodDirOneCurveSplineList;
        end
        %
        function RstTransDynamics=getRstTransDynamics(self)
            RstTransDynamics=self.RstTransDynamics;
        end
        function sTime=getsTime(self)
            sTime=self.sTime;
        end
        function lsGoodDirMat=getlsGoodDirMat(self)
            lsGoodDirMat=self.lsGoodDirMat;
        end
        function self=GoodDirectionSet(pDefObj,sTime,lsGoodDirMat,...
                calcPrecision)
            import gras.ellapx.common.*;
            import gras.mat.MatrixOperationsFactory;
            import gras.mat.fcnlib.ConstMatrixFunction;
            import gras.mat.fcnlib.ConstColFunction;
            import modgen.common.throwerror;
            %
            self.lsGoodDirMat=lsGoodDirMat;
            %
            timeLimsVec=pDefObj.getTimeLimsVec();
            if (sTime>timeLimsVec(2))||(sTime<timeLimsVec(1))
                throwerror('wrongInput',...
                    'sTime is expected to be within %s',...
                    mat2str(timeLimsVec));
            end
            timeVec=unique([pDefObj.getTimeVec(),sTime]);
            indSTime=find(timeVec==sTime,1,'first');
            if isempty(indSTime)
                throwerror('wrongInput',...
                    'sTime is expected to be among elements of timeVec');
            end
            %
            matOpFactory = MatrixOperationsFactory.create(timeVec);
            %
            
            %Rtt0Dynamics = self.calcRtt0Dynamics(pDefObj, calcPrecision);
            %Rt0tTransDynamics = ...
            %    matOpFactory.transpose(matOpFactory.inv(Rtt0Dynamics));
            %Rst0TransConstMatFunc = ...
            %    ConstMatrixFunction(Rtt0Dynamics.evaluate(sTime).');
            %RstTransDynamics = ...
            %    matOpFactory.rMultiply(Rt0tTransDynamics,...
            %    Rst0TransConstMatFunc);
            self.sTime=sTime;
            %
            RstDynamics = self.calcRstDynamics(pDefObj, calcPrecision);
            RstTransDynamics = matOpFactory.transpose(RstDynamics);
            %
            self.RstTransDynamics = RstTransDynamics;
            %
            nGoodDirs = self.getNGoodDirs();
            %
            self.ltGoodDirOneCurveSplineList = cell(nGoodDirs, 1);
            for iGoodDir = 1:nGoodDirs
                lsGoodDirConstColFunc = ...
                    ConstColFunction(lsGoodDirMat(:,iGoodDir));
                self.ltGoodDirOneCurveSplineList{iGoodDir} = ...
                    matOpFactory.rMultiply(RstTransDynamics, ...
                    lsGoodDirConstColFunc);
            end
            %
            lsGoodDirConstMatFunc = ConstMatrixFunction(lsGoodDirMat);
            self.ltGoodDirCurveSpline = matOpFactory.rMultiply(...
                RstTransDynamics, lsGoodDirConstMatFunc);
        end
    end
    methods (Access = protected)
        function odePropList=getOdePropList(self,calcPrecision)
            odePropList={'NormControl',self.ODE_NORM_CONTROL,'RelTol',...
                calcPrecision*self.CALC_PRECISION_FACTOR,...
                'AbsTol',calcPrecision*self.CALC_PRECISION_FACTOR};
        end
    end
    methods (Access = private)
            function RstDynamics = calcRstDynamics(self, pDefObj, ...
                calcPrecision)
            %
            import gras.interp.MatrixInterpolantFactory;
            import gras.ode.MatrixODESolver;
            %
            fAtMat = @(t) pDefObj.getAtDynamics().evaluate(t);
            sizeSysVec = size(fAtMat(0));
            %
            odeArgList = self.getOdePropList(calcPrecision);
            %
            solverObj=MatrixODESolver(sizeSysVec,@ode45, ...
                odeArgList{:});
            %
            t0 = pDefObj.gett0();
            t1 = pDefObj.gett1();
            nTimes = length( pDefObj.getTimeVec());
            sRstInitialMat = eye(sizeSysVec);
            %
            % calculation of R(s, t) if t > s
            %
            if (self.sTime < t1)
                timeVec = linspace(self.sTime, t1, nTimes);
                fXstDerivFunc = @(t, x) fXstDirectFunc(t, x, @(u) fAtMat(u));
                [timeRstRightVec,dataRstRightArray] = ...
                    solverObj.solve(fXstDerivFunc, timeVec, sRstInitialMat);
            else
                timeRstRightVec = [];
                dataRstRightArray = [];
            end
            %
            % calculation of R(s, t) if t < s
            %
            if (self.sTime > t0)
                timeVec = linspace(0, self.sTime - t0, nTimes);
                fXstDerivFunc = ...
                    @(t, x) fXstOppositeFunc(t, x, @(u) fAtMat(u), self.sTime);
                [timeRstLeftVec,dataRstLeftArray] = ...
                    solverObj.solve(fXstDerivFunc, timeVec, sRstInitialMat);
                %
                timeRstLeftVec(end) = []; dataRstLeftArray(:,:,1) = [];
                timeRstLeftVec = t0 + timeRstLeftVec;
                dataRstLeftArray = flipdim(dataRstLeftArray, 3);
            else
                timeRstLeftVec = [];
                dataRstLeftArray = [];
            end        
            %
            timeRstVec = cat(2, timeRstLeftVec, timeRstRightVec);
            dataRstArray = cat(3, dataRstLeftArray, dataRstRightArray);
            %
            RstDynamics=MatrixInterpolantFactory.createInstance(...
                'column',dataRstArray,timeRstVec);
        end
        %
        function Rtt0Dynamics = calcRtt0Dynamics(self, pDefObj, ...
                calcPrecision)
            %
            import gras.interp.MatrixInterpolantFactory;
            import gras.ode.MatrixODESolver;
            %
            fAtMat = @(t) pDefObj.getAtDynamics().evaluate(t);
            sizeSysVec = size(fAtMat(0));
            %
            % (temporary) fRtt0DerivFunc selection
            %
            switch (self.CALC_ALGORITHM)
                case 0
                    fRtt0DerivFunc = ...
                        @(t,x) fXtt0DerivFunc(t, x, @(u) fAtMat(u));
                case 1
                    fRtt0DerivFunc = ...
                        @(t,x) fXtt0DerivFunc(t, x, @(u) fAtMat(u));
                case 2
                    fRtt0DerivFunc = ...
                        @(t,x) fRtt0SimDerivFunc(t, x, @(u) fAtMat(u));
                case 3
                    fRtt0DerivFunc = ...
                        @(t,x) fRtt0ExtDerivFunc(t, x, @(u) fAtMat(u), ...
                        sizeSysVec);
            end
            %
            % (temporary) sRtt0InitialMat selection
            %
            switch (self.CALC_ALGORITHM)
                case 0
                    sRtt0InitialMat = eye(sizeSysVec);
                case 1
                    sRtt0InitialMat = eye(sizeSysVec);
                case 2
                    sRtt0InitialMat = eye(sizeSysVec);
                    sRtt0InitialMat = normaliz(sRtt0InitialMat);
                case 3
                    sRtt0InitialMat = eye(sizeSysVec);
                    norm = sqrt(sum(sum(sRtt0InitialMat, 2)));
                    sRtt0InitialMat = normaliz(sRtt0InitialMat);
                    sRtt0InitialMat = [sRtt0InitialMat(:); norm];
            end
            %
            odeArgList = self.getOdePropList(calcPrecision);
            %
            if (self.CALC_ALGORITHM == 3)
                numelSys = prod(sizeSysVec);
                solverObj=MatrixODESolver([numelSys + 1, 1],@ode45, ...
                    odeArgList{:});
            else
                solverObj=MatrixODESolver(sizeSysVec,@ode45, ...
                    odeArgList{:});
            end
            %
            [timeRtt0Vec,dataRtt0Array]=solverObj.solve(fRtt0DerivFunc,...
                pDefObj.getTimeVec(),sRtt0InitialMat);
            %
            % (temporary) postprocessing
            %
            switch (self.CALC_ALGORITHM)
                case 1
                    dataRtt0Array = normaliz(dataRtt0Array);
                case 3
                    sizeRtt0ArrayVec = size(dataRtt0Array);
                    normVec = dataRtt0Array(sizeRtt0ArrayVec(1), ...
                        sizeRtt0ArrayVec(2), :);
                    normVec = repmat(normVec, [sizeSysVec, 1]);
                    dataRtt0Array = ...
                        dataRtt0Array(1:(sizeRtt0ArrayVec(1) - 1), :, :);
                    dataRtt0Array = reshape(dataRtt0Array, [sizeSysVec, ...
                        sizeRtt0ArrayVec(3)]);
                    dataRtt0Array = dataRtt0Array .* normVec;
            end
            %
            Rtt0Dynamics=MatrixInterpolantFactory.createInstance(...
                'column',dataRtt0Array,timeRtt0Vec);
        end
    end
end
%
% equations for X(s, t)
%
function dx = fXstDirectFunc(t, x, fAt)
    dx = -x * fAt(t);
end
%
function dx = fXstOppositeFunc(t, x, fAt, sTime) % time will be t' = s - t
    dx = x * fAt(sTime - t);
end
%
% new equation for R(t, t0)
%
function dx = fRtt0SimDerivFunc(t, x, fAt)
    cachedMat = fAt(t) * x;
    %
    dx = cachedMat - x * sum(x(:) .* cachedMat(:));
end
%
% (temporary) old equation for X(t, t0)
%
function dx = fXtt0DerivFunc(t, x, fAt)
    dx = fAt(t) * x;
end
%
% (temporary) new equation for R(t, t0) and matrixnorm(X(t, t0))
%
function dx = fRtt0ExtDerivFunc(t, x, fAt, sizeAtVec)
    norm = x(length(x)); x(length(x)) = [];
    sRtt0Mat = reshape(x, sizeAtVec);
    %
    cachedMat = fAt(t) * sRtt0Mat;
    scprod = sum(sRtt0Mat(:) .* cachedMat(:));
    %
    dnorm = scprod * norm;
    dsRtt0Mat = cachedMat - sRtt0Mat * scprod;
    %
    dx = [dsRtt0Mat(:); dnorm];
end
%
% normalizes matrix argMat (matrixnorm(normalizMat) = 1)
%
function normalizMat = normaliz(argMat)
    szVec = size(argMat);
    normMat = argMat .* argMat;
    normMat = realsqrt(sum(sum(normMat, 2), 1));
    if (length(szVec) > 2)
        szVec(3:length(szVec)) = 1;
    end
    normMat = repmat(normMat, szVec);
    normalizMat = argMat ./ normMat;
end
