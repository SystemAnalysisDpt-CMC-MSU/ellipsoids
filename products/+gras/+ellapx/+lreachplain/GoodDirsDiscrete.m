classdef GoodDirsDiscrete < gras.ellapx.lreachplain.AGoodDirs
    methods
        function self = GoodDirsDiscrete(pDynObj, sTime, ...
                lsGoodDirMat, calcPrecision)
            self = self@gras.ellapx.lreachplain.AGoodDirs(...
                pDynObj, sTime, lsGoodDirMat, calcPrecision);
        end
    end
    methods (Access = protected)
        function [XstDynamics, RstDynamics, XstNormDynamics] = ...
                calcTransMatDynamics(self, matOpFactory, STimeData, ...
                AtDynamics, calcPrecision)
            %
            import gras.interp.MatrixInterpolantFactory;
            import gras.ellapx.uncertcalc.log.Log4jConfigurator;
            import gras.mat.CompositeMatrixOperations;
            import gras.gen.matdot;
            %
            logger=Log4jConfigurator.getLogger();
            %
            compOpFactory = CompositeMatrixOperations();
            aInvMatFcn = compOpFactory.inv(AtDynamics);
            fAtMat = @(t) aInvMatFcn.evaluate(t);
            sizeSysVec = size(fAtMat(0));
            %
            t0 = STimeData.t0;
            t1 = STimeData.t1;
            %
            isBack = t0 > t1;
            if isBack
                timeVec = fliplr(t1:t0);
            else
                timeVec = t0:t1;
            end
            nTimePoints = length(timeVec);
            %
            dataXtt0Arr = zeros([sizeSysVec nTimePoints]);
            dataRtt0Arr = zeros([sizeSysVec nTimePoints]);
            dataXtt0NormVec = zeros([1, nTimePoints]);
            %
            dataXtt0Arr(:, :, 1) = eye(sizeSysVec);
            dataXtt0NormVec(1) = realsqrt(matdot(...
                    dataXtt0Arr(:, :, 1), dataXtt0Arr(:, :, 1)));
            dataRtt0Arr(:, :, 1) = dataXtt0Arr(:, :, 1) ./ ...
                    dataXtt0NormVec(1);
            %
            for iTime = 2:nTimePoints
                dataXtt0Arr(:, :, iTime) = ...
                    fAtMat(timeVec(iTime - 1 + isBack)) * ...
                    dataXtt0Arr(:, :, iTime - 1);
                dataXtt0NormVec(iTime) = realsqrt(matdot(...
                    dataXtt0Arr(:, :, iTime), dataXtt0Arr(:, :, iTime)));
                dataRtt0Arr(:, :, iTime) = dataXtt0Arr(:, :, iTime) ./ ...
                    dataXtt0NormVec(iTime);
            end
            %
            XstDynamics = MatrixInterpolantFactory.createInstance(...
                'column', dataXtt0Arr, timeVec);
            RstDynamics = MatrixInterpolantFactory.createInstance(...
                'column', dataRtt0Arr, timeVec);
            XstNormDynamics = MatrixInterpolantFactory.createInstance(...
                'scalar', dataXtt0NormVec, timeVec);
            %
            tStart = tic;
            %
            logger.debug(...
                sprintf(['calculating transition matrix spline ' ...
                'at time %d, nodes = %d, time elapsed = %s sec.'], ...
                self.sTime, length(timeVec), ...
                num2str(toc(tStart))));
        end
    end
end