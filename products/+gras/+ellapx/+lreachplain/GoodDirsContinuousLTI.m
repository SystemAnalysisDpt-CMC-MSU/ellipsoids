classdef GoodDirsContinuousLTI<gras.ellapx.lreachplain.AGoodDirsContinuous
    properties (Constant, GetAccess = protected)
        CALC_CGRID_COUNT = 6000;
    end
    methods
        function self = GoodDirsContinuousLTI(pDynObj, sTime, ...
                lsGoodDirMat, calcPrecision)
            self=self@gras.ellapx.lreachplain.AGoodDirsContinuous(...
                pDynObj, sTime, lsGoodDirMat, calcPrecision);
        end
    end
    methods (Access = protected)
        function [XstNormDynamics, RstDynamics] = calcTransMatDynamics(...
                self, t0, t1, AtDynamics, ~)
            %
            import gras.mat.MatrixOperationsFactory;
            import gras.ellapx.uncertcalc.log.Log4jConfigurator;
            %
            logger=Log4jConfigurator.getLogger();                
            %
            timeRstVec = halfTimeVecGen(t0, self.sTime, ...
                self.CALC_CGRID_COUNT + 1);
            timeRstRightVec = halfTimeVecGen(self.sTime, t1, ...
                self.CALC_CGRID_COUNT + 1);
            if (length(timeRstRightVec) > 1)
                timeRstVec = cat(2, timeRstVec, timeRstRightVec(2:end));
            end
            %
            tStart=tic;
            %
            % calculation of R(s, t) on [t0, t1]
            %
            matOpFactory = MatrixOperationsFactory.create(timeRstVec);
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
                self.sTime, length(timeRstVec), ...
                num2str(toc(tStart))));
        end
    end
end
%
% post processing function
%
function timeHalfVec = halfTimeVecGen(startTime, endTime, nVals)
    if (startTime == endTime)
        timeHalfVec = startTime;
    else
        timeHalfVec = linspace(startTime, endTime, nVals);
    end
end