classdef GoodDirsContinuousGen<gras.ellapx.lreachplain.AGoodDirsContinuous
    properties (Constant, GetAccess = protected)
        ODE_NORM_CONTROL = 'on';
        CALC_PRECISION_FACTOR = 1e-5;
        CALC_CGRID_COUNT = 4000;
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
        function RstDynamics = calcRstDynamics(self, t0, t1, ...
                AtDynamics, calcPrecision)
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
            %
            fRstDerivFunc = @(t, x) fRstFunc(t, x, @(u) fAtMat(u));
            fRstPostProcFunc = @(t, x) fPostProcLeftFunc(t, x);
            %
            tStart=tic;
            %
            % calculation of X(s, t) on [t0, s]
            %
            [timeRstVec, dataRstArray] = self.calcHalfRstDynamics(...
                self.sTime, t0, fRstDerivFunc, sRstInitialMat, ...
                calcPrecision, fRstPostProcFunc);
            %
            % calculation of X(s, t) on [s, t1]
            %
            [timeRstRightVec, dataRstRightArray] = ...
                self.calcHalfRstDynamics(self.sTime, t1, fRstDerivFunc, ...
                sRstInitialMat, calcPrecision);
            %
            if (length(timeRstRightVec) > 1)
                timeRstVec = cat(2, timeRstVec, timeRstRightVec(2:end));
                dataRstArray = cat(3, dataRstArray, ...
                    dataRstRightArray(:,:,2:end));
            end
            %
            RstDynamics=MatrixInterpolantFactory.createInstance(...
                'column', dataRstArray, timeRstVec);
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
        function [timeRstHalfVec, dataRstHalfArray] = ...
                calcHalfRstDynamics(self, startTime, endTime, ...
                fRstDerivFunc, sRstInitialMat, calcPrecision, varargin ...
                )
            %
            import gras.ode.MatrixODESolver;
            %
            odeArgList = self.getOdePropList(calcPrecision);
            sizeSysVec = size(sRstInitialMat);
            %
            solverObj = MatrixODESolver(sizeSysVec, @ode45, ...
                odeArgList{:});
            timeVec = linspace(startTime, endTime, ...
                self.CALC_CGRID_COUNT + 1);
            [timeRstHalfVec, dataRstHalfArray] = solverObj.solve(...
                fRstDerivFunc, timeVec, sRstInitialMat);
            %
            if nargin > 6
                fRstPostProcFunc = varargin{1};
                [timeRstHalfVec, dataRstHalfArray] = fRstPostProcFunc(...
                    timeRstHalfVec, dataRstHalfArray);
            end
        end
    end
end
%
% post processing function
%
function [timeRstOutVec, dataRstOutArray] = ...
    fPostProcLeftFunc(timeRstInVec, dataRstInArray)
    %
    timeRstOutVec = flipdim(timeRstInVec, 2);
    dataRstOutArray = flipdim(dataRstInArray, 3);
end
%
% equations for R(s, t)
%
function dxMat = fRstFunc(t, xMat, fAtMat)
    import gras.gen.matdot;
    %
    cachedMat = -xMat * fAtMat(t);
    dxMat = cachedMat - xMat * matdot(xMat, cachedMat);
end