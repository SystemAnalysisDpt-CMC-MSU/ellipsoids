classdef GoodDirsContinuousGen<gras.ellapx.lreachplain.AGoodDirs
    properties (Constant, GetAccess = protected)
        ODE_NORM_CONTROL = 'on';
        CALC_PRECISION_FACTOR = 1e-5;
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
                'RelTol', relTol*self.CALC_PRECISION_FACTOR, ...
                'AbsTol', absTol*self.CALC_PRECISION_FACTOR};
        end
        function [XstDynamics, RstDynamics, XstNormDynamics, RstInterp]=...
                calcTransMatDynamics(self, matOpFactory, STimeData, ...
                AtDynamics, relTol, absTol) %#ok<INUSL>
            import gras.gen.matdot;
            import gras.mat.interp.MatrixInterpolantFactory;
            import gras.ellapx.uncertcalc.log.Log4jConfigurator;
            import gras.mat.CompositeMatrixOperations;
            %
            compMatrixOprs = CompositeMatrixOperations();
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
            if STimeData.indSTime ~= 1 && ...
                    STimeData.indSTime ~= length(STimeData.timeVec)
                %
                % calculation of X(s, t) on [t0, s]
                %
                halfTimeVec = ...
                    fliplr(STimeData.timeVec(1:STimeData.indSTime));
                [timeRstVec, dataRstArray, dataXstNormArray, ...
                    dataRstInterpArray] = self.calcHalfRstExtDynamics(...
                    halfTimeVec,  fRstExtDerivFunc, sRstInitialMat, ...
                    sXstNormInitial, relTol, absTol, fRstPostProcFunc);
                %
                % calculation of X(s, t) on [s, t1]
                %
                halfTimeVec = STimeData.timeVec(STimeData.indSTime:end);
                [timeRstRightVec, dataRstRightArray, ...
                    dataXstNormRightArray, dataRstRightInterpArray] = ...
                    self.calcHalfRstExtDynamics(halfTimeVec, ...
                    fRstExtDerivFunc, sRstInitialMat, sXstNormInitial, ...
                    relTol, absTol);
                %
                timeRstVec = cat(2, timeRstVec, timeRstRightVec(2:end));
                dataRstArray = cat(3, dataRstArray, ...
                    dataRstRightArray(:,:,2:end));
                RstInterp = compMatrixOprs.catDiffTimeVec(...
                    dataRstInterpArray, dataRstRightInterpArray,...
                    3, timeRstVec, timeRstRightVec);
                dataXstNormArray = cat(2, dataXstNormArray, ...
                    dataXstNormRightArray(2:end));
            elseif STimeData.indSTime ~= 1
                % [s, t1] = {t1}
                halfTimeVec = ...
                    fliplr(STimeData.timeVec(1:STimeData.indSTime));
                [timeRstVec, dataRstArray, dataXstNormArray, ...
                    RstInterp] = self.calcHalfRstExtDynamics(...
                    halfTimeVec,  fRstExtDerivFunc, sRstInitialMat, ...
                    sXstNormInitial, relTol, absTol, fRstPostProcFunc);
            else
                %[t0, s] = {t0}
                halfTimeVec = STimeData.timeVec(STimeData.indSTime:end);
                [timeRstVec, dataRstArray, dataXstNormArray, ...
                    RstInterp] = self.calcHalfRstExtDynamics(...
                    halfTimeVec, fRstExtDerivFunc, sRstInitialMat, ...
                    sXstNormInitial, relTol, absTol);
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
                dataXstNormHalfArray, dataRstHalfInterpArray] = ...
                calcHalfRstExtDynamics(self, timeVec, fRstDerivFunc, ...
                sRstInitialMat, sXstNormInitial, relTol, absTol, varargin)
            %
            import gras.ode.MatrixSysODERegInterpSolver;
            import gras.ode.MatrixODE45InterpFunc;
            import gras.mat.CompositeMatrixOperations;
            import gras.ode.ode45reg;
            %
            compMatrixOprs = CompositeMatrixOperations();
            %
            sRstExtInitialMat = {[sRstInitialMat(:); sXstNormInitial]};
            %
            odeArgList = self.getOdePropList(relTol, absTol);
            sizeSysVec = {size(sRstExtInitialMat{:})};
            %
            solverObj = MatrixSysODERegInterpSolver(sizeSysVec,...
                @(varargin)ode45reg(varargin{:}, odeset(odeArgList{:})),...
                'outArgStartIndVec',[1 2]);
            %
            if nargin > 7
                timeVec = -timeVec;
                fRstDerivFunc = @(t,y)-fRstDerivFunc(t,y);
                %
                fDerivFuncList = {fRstDerivFunc,  @(t,y)fOdeReg(t, y)};
                [timeRstHalfVec, dataRstExtHalfArray, ~,...
                    matrixReshapeInterpObj] = ...
                    solverObj.solve(fDerivFuncList, timeVec, ...
                    sRstExtInitialMat{:});
                
                dataRstHalfInterpArray = MatrixODE45InterpFunc(...
                    matrixReshapeInterpObj, true);
                %
                timeRstHalfVec = - timeRstHalfVec;
                %
                dataRstHalfInterpArray = compMatrixOprs.reshape(...
                    dataRstHalfInterpArray, [size(sRstInitialMat), ...
                    length(timeRstHalfVec)]);
                dataRstHalfArray = reshape(dataRstExtHalfArray(1:end-1,:), ...
                    [size(sRstInitialMat), length(timeRstHalfVec)]);
                dataXstNormHalfArray = dataRstExtHalfArray(end,:);
                %
                fRstPostProcFunc = varargin{1};
                [timeRstHalfVec, dataRstHalfArray, ...
                    dataXstNormHalfArray, dataRstHalfInterpArray] = ...
                    fRstPostProcFunc(timeRstHalfVec, dataRstHalfArray, ...
                    dataXstNormHalfArray, dataRstHalfInterpArray, ...
                    compMatrixOprs);
            else
                fDerivFuncList = {fRstDerivFunc,  @(t,y)fOdeReg(t, y)};
                [timeRstHalfVec, dataRstExtHalfArray, ~,...
                    matrixReshapeInterpObj] = ...
                    solverObj.solve(fDerivFuncList, timeVec, ...
                    sRstExtInitialMat{:});
                %
                dataRstHalfInterpArray = MatrixODE45InterpFunc(...
                    matrixReshapeInterpObj, false);
                %
                dataRstHalfInterpArray = compMatrixOprs.reshape(...
                    dataRstHalfInterpArray, [size(sRstInitialMat), ...
                    length(timeRstHalfVec)]);
                dataRstHalfArray = reshape(dataRstExtHalfArray(1:end-1,:), ...
                    [size(sRstInitialMat), length(timeRstHalfVec)]);
                dataXstNormHalfArray = dataRstExtHalfArray(end,:);
            end
        end
    end
end
%
% post processing function
%
function [timeRstOutVec, dataRstOutArray, dataXstNormOutArray, ...
    dataRstHalfInterpArray] = fPostProcLeftFunc(timeRstInVec, ...
    dataRstInArray, dataXstNormInArray, dataRstHalfInterpArray, ...
    compMatrixOprs)
%
timeRstOutVec = flip(timeRstInVec, 2);
dataXstNormOutArray = flip(dataXstNormInArray, 2);
dataRstOutArray = flip(dataRstInArray, 3);
dataRstHalfInterpArray = compMatrixOprs.flipdim(...
    dataRstHalfInterpArray, 2);
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
%
%regularization function for ode45reg
%
function [isStrictViolation,yReg] = fOdeReg(t,yVec) %#ok<INUSL>
isStrictViolation=false;
yReg=yVec;
end