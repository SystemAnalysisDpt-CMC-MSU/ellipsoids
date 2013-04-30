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
        ODE_NORM_CONTROL = 'on';
        CALC_PRECISION_FACTOR = 1e-5;
        CALC_CGRID_COUNT = 4000;
    end
    methods
        function nGoodDirs = getNGoodDirs(self)
            nGoodDirs = size(self.lsGoodDirMat, 2);
        end
        function ltGoodDirCurveSpline = getGoodDirCurveSpline(self)
            ltGoodDirCurveSpline = self.ltGoodDirCurveSpline;
        end
        function ltGoodDirCurveSpline = getGoodDirOneCurveSpline(...
                self, dirNum)
            ltGoodDirCurveSpline = ...
                self.ltGoodDirOneCurveSplineList{dirNum};
        end
        function ltGoodDirSplineList = getGoodDirOneCurveSplineList(self)
            ltGoodDirSplineList= ...
                self.ltGoodDirOneCurveSplineList;
        end
        function RstTransDynamics = getRstTransDynamics(self)
            RstTransDynamics = self.RstTransDynamics;
        end
        function sTime = getsTime(self)
            sTime = self.sTime;
        end
        function lsGoodDirMat = getlsGoodDirMat(self)
            lsGoodDirMat = self.lsGoodDirMat;
        end
        function self = GoodDirectionSet(pDefObj, sTime, lsGoodDirMat, ...
                calcPrecision)
            import gras.ellapx.common.*;
            import gras.mat.MatrixOperationsFactory;
            import gras.mat.fcnlib.ConstMatrixFunction;
            import gras.mat.fcnlib.ConstColFunction;
            import modgen.common.throwerror;
            %
            self.lsGoodDirMat = lsGoodDirMat;
            %
            timeLimsVec = pDefObj.getTimeLimsVec();
            if (sTime > timeLimsVec(2)) || (sTime < timeLimsVec(1))
                throwerror('wrongInput',...
                    'sTime is expected to be within %s', ...
                    mat2str(timeLimsVec));
            end
            timeVec = unique([pDefObj.getTimeVec(), sTime]);
            indSTime = find(timeVec == sTime, 1, 'first');
            if isempty(indSTime)
                throwerror('wrongInput', ...
                    'sTime is expected to be among elements of timeVec');
            end
            %
            matOpFactory = MatrixOperationsFactory.create(timeVec);
            %
            self.sTime = sTime;
            %
            RstDynamics = self.calcRstDynamics(pDefObj, calcPrecision);
            self.RstTransDynamics = matOpFactory.transpose(RstDynamics);
            %
            nGoodDirs = self.getNGoodDirs();
            %
            self.ltGoodDirOneCurveSplineList = cell(nGoodDirs, 1);
            for iGoodDir = 1:nGoodDirs
                lsGoodDirConstColFunc = ...
                    ConstColFunction(lsGoodDirMat(:, iGoodDir));
                self.ltGoodDirOneCurveSplineList{iGoodDir} = ...
                    matOpFactory.rMultiply(self.RstTransDynamics, ...
                    lsGoodDirConstColFunc);
            end
            %
            lsGoodDirConstMatFunc = ConstMatrixFunction(lsGoodDirMat);
            self.ltGoodDirCurveSpline = matOpFactory.rMultiply(...
                self.RstTransDynamics, lsGoodDirConstMatFunc);
        end
    end
    methods (Access = protected)
        function odePropList=getOdePropList(self,calcPrecision)
            odePropList={'NormControl', self.ODE_NORM_CONTROL, ...
                'RelTol', calcPrecision*self.CALC_PRECISION_FACTOR, ...
                'AbsTol', calcPrecision*self.CALC_PRECISION_FACTOR};
        end
    end
    methods (Access = private)
        function RstDynamics = calcRstDynamics(self, pDefObj, ...
                calcPrecision)
            %
            import gras.interp.MatrixInterpolantFactory;
            import gras.ellapx.uncertcalc.log.Log4jConfigurator;
            %
            logger=Log4jConfigurator.getLogger();
            %
            fAtMat = @(t) pDefObj.getAtDynamics().evaluate(t);
            sizeSysVec = size(fAtMat(0));
            %
            t0 = pDefObj.gett0();
            t1 = pDefObj.gett1();
            sRstInitialMat = eye(sizeSysVec);
            %
            tStart=tic;
            %
            % calculation of X(s, t) on [t0, s]
            %
            fRstDerivFunc = @(t, x) fXstOppositeFunc(t, x, ...
                @(u) fAtMat(u), self.sTime);
            fRstPostProcFunc = @(t, x) fPostProcLeftFunc(t, x, t0);
            [timeRstVec, dataRstArray] = self.calcHalfRstDynamics(...
                0, self.sTime - t0, fRstDerivFunc, sRstInitialMat, ...
                calcPrecision, fRstPostProcFunc);
            %
            % calculation of X(s, t) on [s, t1]
            %
            fRstDerivFunc = @(t, x) fXstDirectFunc(t, x, @(u) fAtMat(u));
            fRstPostProcFunc = @(t, x) fPostProcRightFunc(t, x); 
            [timeRstRightVec, dataRstRightArray] = ...
                self.calcHalfRstDynamics(self.sTime, t1, fRstDerivFunc, ...
                sRstInitialMat, calcPrecision, fRstPostProcFunc);
            %
            if (length(timeRstRightVec) > 1)
                timeRstVec = cat(2, timeRstVec, timeRstRightVec(2:end));
                dataRstArray = cat(3, dataRstArray, dataRstRightArray(:,:,2:end));
            end
            %
            RstDynamics=MatrixInterpolantFactory.createInstance(...
                'column', dataRstArray, timeRstVec);
            %
            logger.info(...
                sprintf(['calculating transition matrix spline ' ...
                'at time %d, nodes = %d, time elapsed = %s sec.'],...
                self.sTime, length(timeRstVec),...
                num2str(toc(tStart))));
        end
        %
        % calculations for Xst on [t0, s) and (s, t1]
        %
        function [timeRstHalfVec, dataRstHalfArray] = ...
                calcHalfRstDynamics(self, startTime, endTime, fRstDerivFunc, ...
                sRstInitialMat, calcPrecision, fRstPostProcFunc)
            %
            import gras.ode.MatrixODESolver;
            %
            odeArgList = self.getOdePropList(calcPrecision);
            sizeSysVec = size(sRstInitialMat);
            %
            solverObj = MatrixODESolver(sizeSysVec, @ode45, ...
                odeArgList{:});
            if (startTime ~= endTime)
                timeVec = linspace(startTime, endTime, ...
                    self.CALC_CGRID_COUNT + 1);
                [timeRstHalfVec, dataRstHalfArray] = solverObj.solve( ...
                    fRstDerivFunc, timeVec, sRstInitialMat);
            else
                timeRstHalfVec = startTime;
                dataRstHalfArray = sRstInitialMat;
            end
            [timeRstHalfVec, dataRstHalfArray] = fRstPostProcFunc(...
                timeRstHalfVec, dataRstHalfArray);
        end
    end
end
%
%
%
function [timeRstOutVec, dataRstOutArray] = ...
    fPostProcLeftFunc(timeRstInVec, dataRstInArray, addTime)
    %
    timeRstOutVec = addTime + timeRstInVec;
    dataRstOutArray = flipdim(dataRstInArray, 3);
end
function [timeRstOutVec, dataRstOutArray] = ...
    fPostProcRightFunc(timeRstInVec, dataRstInArray)
    %
    timeRstOutVec = timeRstInVec;
    dataRstOutArray = dataRstInArray;
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