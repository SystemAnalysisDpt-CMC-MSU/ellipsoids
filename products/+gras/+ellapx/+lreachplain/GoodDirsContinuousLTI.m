classdef GoodDirsContinuousLTI<gras.ellapx.lreachplain.AGoodDirsContinuous
    properties (Constant, GetAccess = protected)
        CALC_CGRID_COUNT = 4000;
    end
    methods
        function self = GoodDirsContinuousLTI(pDynObj, sTime, ...
                lsGoodDirMat, calcPrecision)
            self=self@gras.ellapx.lreachplain.AGoodDirsContinuous(...
                pDynObj, sTime, lsGoodDirMat, calcPrecision);
        end
    end
    methods (Access = protected)
        function RstDynamics = calcRstDynamics(self, t0, t1, AtDynamics, ~)
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
            % calculation of X(s, t) on [t0, t1]
            %
            matOpFactory = MatrixOperationsFactory.create(timeRstVec);
            AtTransDynamics = matOpFactory.transpose(AtDynamics);
            AtUmTransDynamics = matOpFactory.uminus(AtTransDynamics);
            RstDynamics = ...
                matOpFactory.expmt(AtUmTransDynamics, self.sTime);
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