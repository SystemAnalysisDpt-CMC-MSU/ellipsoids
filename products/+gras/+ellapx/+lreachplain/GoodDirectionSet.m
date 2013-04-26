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
        CALC_CGRID_COUNT = 2000;
    end
    properties (Constant, GetAccess = private)
        % (temporary) algorithm:
        %   0 - X(s, t)
        %   1 - R(s, t)
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
            switch (self.CALC_ALGORITHM)
                case 0
                    sRstInitialMat = eye(sizeSysVec);
                case 1
                    sRstInitialMat = normaliz(eye(sizeSysVec));
            end
            %
            % calculation of R(s, t) if t > s
            %
            if (self.sTime < t1)
                timeVec = linspace(self.sTime, t1, self.CALC_CGRID_COUNT);
                switch (self.CALC_ALGORITHM)
                    case 0
                        fRstDerivFunc = @(t, x) fXstDirectFunc(t, x, @(u) fAtMat(u));
                    case 1
                        fRstDerivFunc = @(t, x) fRstDirectFunc(t, x, @(u) fAtMat(u));
                end
                [timeRstRightVec,dataRstRightArray] = ...
                    solverObj.solve(fRstDerivFunc, timeVec, sRstInitialMat);
            else
                timeRstRightVec = [];
                dataRstRightArray = [];
            end
            %
            % calculation of R(s, t) if t < s
            %
            if (self.sTime > t0)
                timeVec = linspace(0, self.sTime - t0, self.CALC_CGRID_COUNT);
                switch (self.CALC_ALGORITHM)
                    case 0
                        fRstDerivFunc = ...
                            @(t, x) fXstOppositeFunc(t, x, ...
                            @(u) fAtMat(u), self.sTime);
                    case 1
                        fRstDerivFunc = ...
                            @(t, x) fRstOppositeFunc(t, x, ...
                            @(u) fAtMat(u), self.sTime);
                end
                [timeRstLeftVec,dataRstLeftArray] = ...
                    solverObj.solve(fRstDerivFunc, timeVec, sRstInitialMat);
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
    end
end
%
% equations for X(s, t)
%
function dxMat = fXstDirectFunc(t, xMat, fAtMat)
    dxMat = -xMat * fAtMat(t);
end
%
function dxMat = fXstOppositeFunc(t, xMat, fAtMat, sTime) 
    dxMat = xMat * fAtMat(sTime - t); % time will be t' = s - t
end
%
% equations for R(s, t)
%
function dxMat = fRstDirectFunc(t, xMat, fAtMat)
    cachedMat = -xMat * fAtMat(t);
    dxMat = cachedMat - xMat * dot(xMat(:), cachedMat(:));
end
%
function dxMat = fRstOppositeFunc(t, xMat, fAtMat, sTime) 
    cachedMat = xMat * fAtMat(sTime - t); % time will be t' = s - t
    dxMat = cachedMat - xMat * dot(xMat(:), cachedMat(:));
end
%
% (temporary) new equation for R(t, t0) and matrixnorm(X(t, t0))
%
function dx = fRtt0ExtDerivFunc(t, x, fAtMat, sizeAtVec)
    norm = x(length(x)); x(length(x)) = [];
    sRtt0Mat = reshape(x, sizeAtVec);
    %
    cachedMat = fAtMat(t) * sRtt0Mat;
    scProd = dot(sRtt0Mat(:), cachedMat(:));
    %
    dnorm = scProd * norm;
    dsRtt0Mat = cachedMat - sRtt0Mat * scProd;
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
    szVecNumel = numel(szVec);
    if (szVecNumel > 2)
        szVec(3:szVecNumel) = 1;
    end
    normMat = repmat(normMat, szVec);
    normalizMat = argMat ./ normMat;
end
