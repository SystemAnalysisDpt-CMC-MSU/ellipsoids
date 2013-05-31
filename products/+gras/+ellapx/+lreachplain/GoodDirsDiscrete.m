classdef GoodDirsDiscrete < gras.ellapx.lreachplain.AGoodDirsContinuous
    methods
        function self = GoodDirsDiscrete(pDynObj, sTime, ...
                lsGoodDirMat, calcPrecision)
            self = self@gras.ellapx.lreachplain.AGoodDirsContinuous(...
                pDynObj, sTime, lsGoodDirMat, calcPrecision);
        end
    end
    methods (Access = protected)
        function RstDynamics = calcRstDynamics(self, t0, t1, ...
                AtDynamics, calcPrecision)
            %
            import gras.interp.MatrixInterpolantFactory;
            import gras.ellapx.uncertcalc.log.Log4jConfigurator;
            import gras.mat.CompositeMatrixOperations;
            %
            logger=Log4jConfigurator.getLogger();
            %
            compOpFact = CompositeMatrixOperations();
            aInvMatFcn = compOpFact.inv(AtDynamics);
            fAtMat = @(t) aInvMatFcn.evaluate(t);
            sizeSysVec = size(fAtMat(0));
            isBack = t0 > t1;
            if isBack
                timeVec = fliplr(t1:t0);
            else
                timeVec = t0:t1;
            end
            nTimePoints = length(timeVec);
            %
            dataXtt0Arr = zeros([sizeSysVec nTimePoints]);
            dataXtt0Arr(:, :, 1) = eye(sizeSysVec);
            for iTime = 2:nTimePoints
                dataXtt0Arr(:, :, iTime) = ...
                    fAtMat(timeVec(iTime - 1 + isBack)) * ...
                    dataXtt0Arr(:, :, iTime - 1);
            end
            %
            RstDynamics = MatrixInterpolantFactory.createInstance(...
                'column', dataXtt0Arr, timeVec);
            %
            tStart = tic;
            %
            logger.info(...
                sprintf(['calculating transition matrix spline ' ...
                'at time %d, nodes = %d, time elapsed = %s sec.'], ...
                self.sTime, length(timeVec), ...
                num2str(toc(tStart))));
        end
    end
end