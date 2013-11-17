classdef GoodDirsContinuousGen<gras.ellapx.lreachplain.AGoodDirs
    properties (Constant, GetAccess = protected)
        ODE_NORM_CONTROL = 'on';
        CALC_PRECISION_FACTOR = 1e-5;
    end
    methods
        function self = GoodDirsContinuousGen(pDynObj, sTime, ...
                lsGoodDirMat, calcPrecision)
            self=self@gras.ellapx.lreachplain.AGoodDirs(...
                pDynObj, sTime, lsGoodDirMat, calcPrecision);
        end
    end
    methods (Access = protected)
        function odePropList=getOdePropList(self,calcPrecision)
            odePropList={'NormControl', self.ODE_NORM_CONTROL, ...
                'RelTol', calcPrecision*self.CALC_PRECISION_FACTOR, ...
                'AbsTol', calcPrecision*self.CALC_PRECISION_FACTOR};
        end
        function [XstDynamics, RstDynamics, XstNormDynamics,varargout]=...
                calcTransMatDynamics(self, matOpFactory, STimeData, ...
                AtDynamics, calcPrecision)
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
            
            [timeRstVec, dataRstArray, dataXstNormArray,...
                dataRstArrayInterpObj, dataXstNormArrayInterpObj] = ...
                self.calcHalfRstExtDynamics(halfTimeVec, ...
                fRstExtDerivFunc, sRstInitialMat, sXstNormInitial, ...
                calcPrecision, fRstPostProcFunc);
                
            %
            % calculation of X(s, t) on [s, t1]
            %
            halfTimeVec = STimeData.timeVec(STimeData.indSTime:end);
            [timeRstRightVec, dataRstRightArray, ...
                dataXstNormRightArray,dataRstRightArrayInterpObj...
                dataXstNormRightArrayInterpObj] =...
                self.calcHalfRstExtDynamics(halfTimeVec,...
                fRstExtDerivFunc, sRstInitialMat, sXstNormInitial,...
                calcPrecision);
            %
            if (length(timeRstRightVec) > 1)
                timeRstVec = cat(2, timeRstVec, timeRstRightVec(2:end));
                dataRstArray = cat(3, dataRstArray, ...
                    dataRstRightArray(:,:,2:end));
                
                nTimePoints = length(timeRstRightVec);
                compositeMatrixOperationsObj = ...
                    gras.mat.CompositeMatrixOperations();
                nRows = dataRstRightArrayInterpObj.getNRows();
                nCols = dataRstRightArrayInterpObj.getNCols();
                indexesList = [{1:nRows} {1:nCols} {2:nTimePoints}];
                dataRstRightArraySubarrayInterpObj = ...
                    compositeMatrixOperationsObj.subarray(...
                    dataRstRightArrayInterpObj,indexesList);
                dataRstArrayInterpObj = ...
                    compositeMatrixOperationsObj.cat(...
                        dataRstArrayInterpObj,...
                        dataRstRightArraySubarrayInterpObj,3);
                    
                dataXstNormArray = cat(2, dataXstNormArray, ...
                    dataXstNormRightArray(2:end));
                
                nRows = dataXstNormRightArrayInterpObj.getNRows();
                nCols = dataXstNormRightArrayInterpObj.getNCols();
                indexesList = [{1:nRows} {1:nCols} {2:nTimePoints}];
                
                
                dataXstNormRightArraySubarrayInterpObj =...
                    compositeMatrixOperationsObj.subarray(...
                    dataXstNormRightArrayInterpObj,indexesList);
                dataXstNormArrayInterpObj = ...
                    compositeMatrixOperationsObj.cat(...
                    dataXstNormArrayInterpObj,...
                    dataXstNormRightArraySubarrayInterpObj,2);
                
                varargout = [{dataRstArrayInterpObj}...
                    {dataXstNormArrayInterpObj}];
                
                
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
                dataXstNormHalfArray varargout] = calcHalfRstExtDynamics(self, ...
                timeVec, fRstDerivFunc, sRstInitialMat, ...
                sXstNormInitial, calcPrecision, varargin)
            %
            import gras.ode.MatrixSysODERegInterpSolver;
            import gras.ode.MatrixODE45InterpFunc;
            %
            sRstExtInitialMat = [sRstInitialMat(:); sXstNormInitial];
            %
            
            function varargout=fAdvRegFunc(~,varargin)
                    nEqs=length(varargin);
                    varargout{1}=false;
                    for iEq=1:nEqs
                        varargout{iEq+1} = varargin{iEq};
                    end
            end
                
            if(length(timeVec) > 1)
                odeArgList = self.getOdePropList(calcPrecision);
                sizeSysVec = size(sRstExtInitialMat);
                fSolver = @gras.ode.ode45reg;
                fSolveFunc = @(varargin)fSolver(varargin{:},...
                    odeset(odeArgList{:}));
                solverObj = gras.ode.MatrixSysODERegInterpSolver(...
                    {sizeSysVec},fSolveFunc,'outArgStartIndVec',[1 2]);                
                [timeRstHalfVec, dataRstExtHalfArray,~,interpObj] = ...
                    solverObj.solve({fRstDerivFunc,@fAdvRegFunc},...
                    timeVec, sRstExtInitialMat);
                ltRGoodDirFuncObj = MatrixODE45InterpFunc(interpObj);
            else
                timeRstHalfVec = timeVec;
                dataRstExtHalfArray = sRstExtInitialMat;
                ltRGoodDirFuncObj = ...
                    gras.ode.MatrixODE45ScalarTimeInterpFunc(...
                    dataRstExtHalfArray,timeRstHalfVec);                
            end;
            
            
            compositeMatrixOperationsObj = ...
                    gras.mat.CompositeMatrixOperations();
            nRows = ltRGoodDirFuncObj.getNRows();
            nCols = ltRGoodDirFuncObj.getNCols();
            n3Dim = length(timeVec);
            indexesList = [{1:(nRows-1)} {1:nCols} {1:n3Dim}];
            ltRGoodDirSubArrayFuncObj = ...
                compositeMatrixOperationsObj.subarray(...
                ltRGoodDirFuncObj,indexesList);
            ltRGoodDirReshapeFuncObj = ...
                compositeMatrixOperationsObj.reshape(...
                ltRGoodDirSubArrayFuncObj,[size(sRstInitialMat),...
                length(timeRstHalfVec)]);
            indexesList = [{nRows} {1:nCols} {1:n3Dim}];
            dataXstNormHalfArrayFuncObj =...
                compositeMatrixOperationsObj.subarray(...
                ltRGoodDirFuncObj,indexesList);
            varargout = [{ltRGoodDirReshapeFuncObj} ...
                {dataXstNormHalfArrayFuncObj}];         
            dataRstHalfArray = reshape(dataRstExtHalfArray(1:end-1,:), ...
                [size(sRstInitialMat), length(timeRstHalfVec)]);
            dataXstNormHalfArray = dataRstExtHalfArray(end,:);
            %
            if nargin > 6
                fRstPostProcFunc = varargin{1};
                [timeRstHalfVec, dataRstHalfArray, ...
                    dataXstNormHalfArray] = fRstPostProcFunc(...
                    timeRstHalfVec, dataRstHalfArray, ...
                    dataXstNormHalfArray);
                ltRGoodDirFlipdimFuncObj = ...
                    compositeMatrixOperationsObj.flipdim(...
                    ltRGoodDirReshapeFuncObj,3);
                dataXstNormHalfArrayFlipdimFuncObj = ...
                    compositeMatrixOperationsObj.flipdim(...
                    dataXstNormHalfArrayFuncObj,2);
                varargout = [{ltRGoodDirFlipdimFuncObj} ...
                    {dataXstNormHalfArrayFlipdimFuncObj}];
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