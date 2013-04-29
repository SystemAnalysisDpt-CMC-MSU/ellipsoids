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
            %
            fAtMat = @(t) pDefObj.getAtDynamics().evaluate(t);
            sizeSysVec = size(fAtMat(0));
            %
            t0 = pDefObj.gett0();
            t1 = pDefObj.gett1();
            sRstInitialMat = eye(sizeSysVec);
            %
            % calculation of X(s, t) on [t0, s)
            %
            fRstDerivFunc = @(t, x) fXstOppositeFunc(t, x, ...
                @(u) fAtMat(u), self.sTime);
            [timeRstVec, dataRstArray] = self.calcHalfRstDynamics(t0, ...
                fRstDerivFunc, sRstInitialMat, calcPrecision);
            %
            % concatenation with X(s, s) on time sTime
            %
            timeRstVec = cat(2, timeRstVec, self.sTime);
            dataRstArray = cat(3, dataRstArray, ...
                repmat(sRstInitialMat, [1 1 1]));
            %
            % calculation of X(s, t) on (s, t1)
            %
            fRstDerivFunc = @(t, x) fXstDirectFunc(t, x, @(u) fAtMat(u));
            [timeRstRightVec, dataRstRightArray] = ...
                self.calcHalfRstDynamics(t1, fRstDerivFunc, ...
                sRstInitialMat, calcPrecision);
            %
            timeRstVec = cat(2, timeRstVec, timeRstRightVec);
            dataRstArray = cat(3, dataRstArray, dataRstRightArray);
            %
            RstDynamics=MatrixInterpolantFactory.createInstance(...
                'column', dataRstArray, timeRstVec);
        end
        %
        % calculations for Xst on [t0, s) and (s, t1]
        %
        function [timeRstHalfVec, dataRstHalfArray] = ...
                calcHalfRstDynamics(self, endTime, fRstDerivFunc, ...
                sRstInitialMat, calcPrecision)
            %
            import gras.ode.MatrixODESolver;
            %
            odeArgList = self.getOdePropList(calcPrecision);
            sizeSysVec = size(sRstInitialMat);
            %
            solverObj = MatrixODESolver(sizeSysVec, @ode45, ...
                odeArgList{:});
            if (self.sTime ~= endTime)
                if (endTime < self.sTime)
                    timeVec = linspace(0, self.sTime - endTime, ...
                        self.CALC_CGRID_COUNT + 1);
                else
                    timeVec = linspace(self.sTime, endTime, ...
                        self.CALC_CGRID_COUNT + 1);
                end
                [timeRstHalfVec, dataRstHalfArray] = solverObj.solve( ...
                    fRstDerivFunc, timeVec, sRstInitialMat);
                %
                dataRstHalfArray(:,:,1) = [];
                if (endTime < self.sTime)
                    timeRstHalfVec(end) = [];
                    timeRstHalfVec = endTime + timeRstHalfVec;
                    dataRstHalfArray = flipdim(dataRstHalfArray, 3);
                else
                    timeRstHalfVec(1) = [];
                end
            else
                timeRstHalfVec = [];
                dataRstHalfArray = [];
            end
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