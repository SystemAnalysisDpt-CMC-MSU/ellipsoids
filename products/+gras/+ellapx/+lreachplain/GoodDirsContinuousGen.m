classdef GoodDirsContinuousGen<gras.ellapx.lreachplain.AGoodDirs
    properties (Constant, GetAccess = protected)
        ODE_NORM_CONTROL = 'on';
        REL_TOL_FACTOR = 1e-5;
        ABS_TOL_FACTOR = 1e-5;
    end
    methods
        function self = GoodDirsContinuousGen(pDynObj, sTime, ...
                lsGoodDirMat, relTol, absTol)
            self=self@gras.ellapx.lreachplain.AGoodDirs(...
                pDynObj, sTime, lsGoodDirMat, relTol, absTol);
        end
    end
    methods (Access = protected)
        function odePropList=getOdePropList(self,relTol, absTol)
            odePropList={'NormControl', self.ODE_NORM_CONTROL, ...
                'RelTol', relTol*self.REL_TOL_FACTOR, ...
                'AbsTol', absTol*self.ABS_TOL_FACTOR};
        end
        function [XstDynamics, RstDynamics, XstNormDynamics] = ...
                calcTransMatDynamics(self, matOpFactory, STimeData, ...
                AtDynamics, relTol, absTol) %#ok<INUSL>
            %
            import gras.gen.matdot;
            import gras.mat.interp.MatrixInterpolantFactory;
            import gras.ellapx.uncertcalc.log.Log4jConfigurator;
            %
            logger=Log4jConfigurator.getLogger();
            %
            fAtMat = @(t) AtDynamics.evaluate(t);
            sizeSysVec = size(fAtMat(0));
            %
            sRstInitialMat = eye(sizeSysVec);
            sRstInitialMat = sRstInitialMat / ...
                realsqrt(matdot(sRstInitialMat, sRstInitialMat));
            sXstNormInitial = 1;
            %
            fRstExtDerivFunc = @(t, x) fRstExtFunc(t, x, @(u) fAtMat(u));
            fRstPostProcFunc = @fPostProcLeftFunc;
            %
            tStart=tic;
            %
            % calculation of X(s, t) on [t0, s]
            %
            halfTimeVec = fliplr(STimeData.timeVec(1:STimeData.indSTime));
            [timeRstVec, dataRstArray, dataXstNormArray] = ...
                self.calcHalfRstExtDynamics(halfTimeVec, ...
                fRstExtDerivFunc, sRstInitialMat, sXstNormInitial, ...
                relTol, absTol, fRstPostProcFunc);
            %
            % calculation of X(s, t) on [s, t1]
            %
            halfTimeVec = STimeData.timeVec(STimeData.indSTime:end);
            [timeRstRightVec, dataRstRightArray, ...
                dataXstNormRightArray] = self.calcHalfRstExtDynamics(...
                halfTimeVec, fRstExtDerivFunc, sRstInitialMat, ...
                sXstNormInitial, relTol, absTol);
            %
            if (length(timeRstRightVec) > 1)
                timeRstVec = cat(2, timeRstVec, timeRstRightVec(2:end));
                dataRstArray = cat(3, dataRstArray, ...
                    dataRstRightArray(:,:,2:end));
                dataXstNormArray = cat(2, dataXstNormArray, ...
                    dataXstNormRightArray(2:end));
            end
            %
            XstNormDynamics = MatrixInterpolantFactory.createInstance(...
                'scalar', dataXstNormArray, timeRstVec);
            dataXstNormArray = permute(dataXstNormArray, [1 3 2]);
            XstDynamics = MatrixInterpolantFactory.createInstance(...
                'column', dataRstArray .* repmat(dataXstNormArray, ...
                [sizeSysVec, 1]), timeRstVec);
            RstDynamics = MatrixInterpolantFactory.createInstance(...
                'column', dataRstArray, timeRstVec);
            %
            logger.info(...
                sprintf(['calculating transition matrix spline\n '...
                '\tat time %d, nodes = %d,\n\ttime elapsed = %s sec.'],...
                self.sTime, length(timeRstVec), ...
                num2str(toc(tStart))));
        end
        %
        % calculations for Xst on [t0, s) and (s, t1]
        %
    end
    methods (Access = private)
        function [timeRstHalfVec, dataRstHalfArray, ...
                dataXstNormHalfArray] = calcHalfRstExtDynamics(self, ...
                timeVec, fRstDerivFunc, sRstInitialMat, ...
                sXstNormInitial, relTol, absTol, varargin)
            %
            import gras.ode.MatrixODESolver;
            %
            sRstExtInitialMat = [sRstInitialMat(:); sXstNormInitial];
            %
            odeArgList = self.getOdePropList(relTol, absTol);
            sizeSysVec = size(sRstExtInitialMat);
            %
            solverObj = MatrixODESolver(sizeSysVec, @ode45, ...
                odeArgList{:});
            [timeRstHalfVec, dataRstExtHalfArray] = solverObj.solve(...
                fRstDerivFunc, timeVec, sRstExtInitialMat);
            dataRstHalfArray = reshape(dataRstExtHalfArray(1:end-1,:), ...
                [size(sRstInitialMat), length(timeRstHalfVec)]);
            dataXstNormHalfArray = dataRstExtHalfArray(end,:);
            %
            if nargin > 7
                fRstPostProcFunc = varargin{1};
                [timeRstHalfVec, dataRstHalfArray, ...
                    dataXstNormHalfArray] = fRstPostProcFunc(...
                    timeRstHalfVec, dataRstHalfArray, ...
                    dataXstNormHalfArray);
            end
        end
    end
end
%
% post processing function
%
function [timeRstOutVec, dataRstOutArray, dataXstNormOutArray] = ...
    fPostProcLeftFunc(timeRstInVec, dataRstInArray, dataXstNormInArray)
%
timeRstOutVec = flip(timeRstInVec, 2);
dataXstNormOutArray = flip(dataXstNormInArray, 2);
dataRstOutArray = flip(dataRstInArray, 3);
end
%
% equations for R(s, t)
%
function dxMat = fRstExtFunc(t, xMat, fAtMat)
import gras.gen.matdot;
%
atMat = fAtMat(t);
rstMat = reshape(xMat(1:end-1), size(atMat));
xstNorm = xMat(end);
%
cachedMat = -rstMat * atMat;
arstNorm = matdot(rstMat, cachedMat);
%
drstMat = cachedMat - rstMat * arstNorm;
dxstNorm = arstNorm .* xstNorm;
%
dxMat = [drstMat(:); dxstNorm];
end