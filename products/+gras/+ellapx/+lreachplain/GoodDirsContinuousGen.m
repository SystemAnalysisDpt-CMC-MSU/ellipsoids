classdef GoodDirsContinuousGen<gras.ellapx.lreachplain.AGoodDirsContinuous
    properties (Constant, GetAccess = protected)
        ODE_NORM_CONTROL = 'on';
        CALC_PRECISION_FACTOR = 1e-5;
        CALC_CGRID_COUNT = 8000;
    end
    methods
        function self = GoodDirsContinuousGen(pDynObj, sTime, ...
                lsGoodDirMat, calcPrecision)
            self=self@gras.ellapx.lreachplain.AGoodDirsContinuous(...
                pDynObj, sTime, lsGoodDirMat, calcPrecision);
        end
    end
    methods (Access = protected)
        function odePropList=getOdePropList(self,calcPrecision)
            odePropList={'NormControl', self.ODE_NORM_CONTROL, ...
                'RelTol', calcPrecision*self.CALC_PRECISION_FACTOR, ...
                'AbsTol', calcPrecision*self.CALC_PRECISION_FACTOR};
        end
        function [XstNormDynamics, RstDynamics] = calcTransMatDynamics(...
                self, t0, t1, AtDynamics, calcPrecision)
            %
            import gras.gen.matdot;
            import gras.interp.MatrixInterpolantFactory;
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
            [timeRstVec, dataRstArray, dataXstNormArray] = ...
                self.calcHalfRstExtDynamics(self.sTime, t0, ...
                fRstExtDerivFunc, sRstInitialMat, sXstNormInitial, ...
                calcPrecision, fRstPostProcFunc);
            %
            % calculation of X(s, t) on [s, t1]
            %
            [timeRstRightVec, dataRstRightArray, ...
                dataXstNormRightArray] = self.calcHalfRstExtDynamics(...
                self.sTime, t1, fRstExtDerivFunc, sRstInitialMat, ...
                sXstNormInitial, calcPrecision);
            %
            if (length(timeRstRightVec) > 1)
                timeRstVec = cat(2, timeRstVec, timeRstRightVec(2:end));
                dataRstArray = cat(3, dataRstArray, ...
                    dataRstRightArray(:,:,2:end));
                dataXstNormArray = cat(2, dataXstNormArray, ...
                    dataXstNormRightArray(2:end));
            end
            %
            RstDynamics = MatrixInterpolantFactory.createInstance(...
                'column', dataRstArray, timeRstVec);
            XstNormDynamics = MatrixInterpolantFactory.createInstance(...
                'scalar', dataXstNormArray, timeRstVec); % temp
            %
            logger.info(...
                sprintf(['calculating transition matrix spline ' ...
                'at time %d, nodes = %d, time elapsed = %s sec.'], ...
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
                startTime, endTime, fRstDerivFunc, sRstInitialMat, ...
                sXstNormInitial, calcPrecision, varargin)
            %
            import gras.ode.MatrixODESolver;
            %
            sRstExtInitialMat = [sRstInitialMat(:); sXstNormInitial];
            %
            odeArgList = self.getOdePropList(calcPrecision);
            sizeSysVec = size(sRstExtInitialMat);
            %
            solverObj = MatrixODESolver(sizeSysVec, @ode45, ...
                odeArgList{:});
            timeVec = linspace(startTime, endTime, ...
                self.CALC_CGRID_COUNT + 1);
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
    timeRstOutVec = flipdim(timeRstInVec, 2);
    dataXstNormOutArray = flipdim(dataXstNormInArray, 2);
    dataRstOutArray = flipdim(dataRstInArray, 3);
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