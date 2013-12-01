classdef GoodDirsContinuousLTI<gras.ellapx.lreachplain.AGoodDirs
    methods
        function self = GoodDirsContinuousLTI(pDynObj, sTime, ...
                lsGoodDirMat, calcPrecision)
            self=self@gras.ellapx.lreachplain.AGoodDirs(...
                pDynObj, sTime, lsGoodDirMat, calcPrecision);
        end
    end
    methods (Access = protected)
        function [XstDynamics, RstDynamics, XstNormDynamics,interpRstObj] = ...
                calcTransMatDynamics(self, matOpFactory, STimeData, ...
                AtDynamics, calcPrecision)
            %
            import gras.mat.MatrixOperationsFactory;
            import gras.ellapx.uncertcalc.log.Log4jConfigurator;
            import gras.interp.MatrixNearestInterp;
            import gras.mat.CompositeMatrixOperations;
            %
            logger=Log4jConfigurator.getLogger();
            
            
            
            interpObj = MatrixNearestInterp(...
                AtDynamics.evaluate(STimeData.timeVec),STimeData.timeVec);
            compMatrixOprs = CompositeMatrixOperations();
            
            %
            tStart=tic;
            %
            % calculation of R(s, t) on [t0, t1]
            %
            AtUmDynamics = matOpFactory.uminus(AtDynamics);
            interpUmObj = compMatrixOprs.uminus(interpObj);
            
            XstDynamics = ...
                matOpFactory.expmt(AtUmDynamics, self.sTime);
            interpXtObj = compMatrixOprs.expmt(interpUmObj,self.sTime);
            
            XstNormDynamics = ...
                matOpFactory.matdot(XstDynamics, XstDynamics);
            interpXtNormObj = compMatrixOprs.matdot(interpXtObj,...
                interpXtObj);
            
            XstNormDynamics = matOpFactory.realsqrt(XstNormDynamics);
            interpXtNormObj = compMatrixOprs.realsqrt(interpXtNormObj);
            
            RstDynamics = matOpFactory.rDivideByScalar(XstDynamics, ...
                XstNormDynamics);
            interpRstObj = compMatrixOprs.rDivideByScalar(interpXtObj,...
                interpXtNormObj);
            %
            logger.info(...
                sprintf(['calculating transition matrix exponent ' ...
                'at time %d, nodes = %d, time elapsed = %s sec.'], ...
                self.sTime, length(STimeData.timeVec), ...
                num2str(toc(tStart))));
        end
    end
end