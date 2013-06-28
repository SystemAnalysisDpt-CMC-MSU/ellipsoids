classdef GoodDirsContinuousLTI<gras.ellapx.lreachplain.AGoodDirs
    methods
        function self = GoodDirsContinuousLTI(pDynObj, sTime, ...
                lsGoodDirMat, calcPrecision)
            self=self@gras.ellapx.lreachplain.AGoodDirs(...
                pDynObj, sTime, lsGoodDirMat, calcPrecision);
        end
    end
    methods (Access = protected)
        function [XstDynamics, RstDynamics, XstNormDynamics] = ...
                calcTransMatDynamics(self, matOpFactory, STimeData, ...
                AtDynamics, calcPrecision)
            %
            import gras.mat.MatrixOperationsFactory;
            import gras.ellapx.uncertcalc.log.Log4jConfigurator;
            %
            logger=Log4jConfigurator.getLogger();                
            %
            tStart=tic;
            %
            % calculation of R(s, t) on [t0, t1]
            %
            AtUmDynamics = matOpFactory.uminus(AtDynamics);
            XstDynamics = ...
                matOpFactory.expmt(AtUmDynamics, self.sTime);
            XstNormDynamics = ...
                matOpFactory.matdot(XstDynamics, XstDynamics);
            XstNormDynamics = matOpFactory.realsqrt(XstNormDynamics);
            RstDynamics = matOpFactory.rDivideByScalar(XstDynamics, ...
                XstNormDynamics);
            %
            logger.info(...
                sprintf(['calculating transition matrix exponent ' ...
                'at time %d, nodes = %d, time elapsed = %s sec.'], ...
                self.sTime, length(STimeData.timeVec), ...
                num2str(toc(tStart))));
        end
    end
end