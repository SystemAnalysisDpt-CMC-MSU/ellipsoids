classdef AGoodDirsContinuous
    properties
        % XstTransDynamics - X(s,t)' is a transition matrix for good
        % directions l(t)=X(s,t)'l_s
        %
        % RstTransDynamics - R(s,t)' is a transition matrix for good
        % directions lR(t)=R(s,t)'l_s
        XstTransDynamics
        RstTransDynamics
        XstNormDynamics
        ltGoodDirCurveSpline
        ltGoodDirOneCurveSplineList
        ltRGoodDirCurveSpline
        ltRGoodDirOneCurveSplineList
        sTime
        lsGoodDirMat
    end
    methods
        function nGoodDirs = getNGoodDirs(self)
            nGoodDirs = size(self.lsGoodDirMat, 2);
        end
        function ltGoodDirCurveSpline = getGoodDirCurveSpline(self)
            ltGoodDirCurveSpline = self.ltGoodDirCurveSpline;
        end
        function ltGoodDirCurveSpline = getGoodDirOneCurveSpline(...
                self, dirNum)
            ltGoodDirCurveSpline = ...
                self.ltGoodDirOneCurveSplineList{dirNum};
        end
        function ltGoodDirSplineList = getGoodDirOneCurveSplineList(self)
            ltGoodDirSplineList= ...
                self.ltGoodDirOneCurveSplineList;
        end
        function ltRGoodDirCurveSpline = getRGoodDirCurveSpline(self)
            ltRGoodDirCurveSpline = self.ltRGoodDirCurveSpline;
        end
        function ltRGoodDirCurveSpline = getRGoodDirOneCurveSpline(...
                self, dirNum)
            ltRGoodDirCurveSpline = ...
                self.ltRGoodDirOneCurveSplineList{dirNum};
        end
        function ltRGoodDirSplineList = getRGoodDirOneCurveSplineList(self)
            ltRGoodDirSplineList= ...
                self.ltRGoodDirOneCurveSplineList;
        end
        function XstNormDynamics = getXstNormDynamics(self)
            XstNormDynamics = self.XstNormDynamics;
        end
        function XstTransDynamics = getXstTransDynamics(self)
            XstTransDynamics = self.XstTransDynamics;
        end
        function RstTransDynamics = getRstTransDynamics(self)
            RstTransDynamics = self.RstTransDynamics;
        end
        function sTime = getsTime(self)
            sTime = self.sTime;
        end
        function lsGoodDirMat = getlsGoodDirMat(self)
            lsGoodDirMat = self.lsGoodDirMat;
        end
        function self = AGoodDirsContinuous(pDynObj, sTime, ...
                lsGoodDirMat, calcPrecision)
            import gras.ellapx.common.*;
            import gras.mat.MatrixOperationsFactory;
            import gras.mat.ConstMatrixFunctionFactory;
            import modgen.common.throwerror;
            %
            self.lsGoodDirMat = lsGoodDirMat;
            %
            timeLimsVec = pDynObj.getTimeLimsVec();
            if ((timeLimsVec(1) < timeLimsVec(2)) && ...
                    (sTime > timeLimsVec(2)) || (sTime < timeLimsVec(1)))
                throwerror('wrongInput',...
                    'sTime is expected to be within %s', ...
                    mat2str(timeLimsVec));
            end
            timeVec = unique([pDynObj.getTimeVec(), sTime]);
            indSTime = find(timeVec == sTime, 1, 'first');
            if isempty(indSTime)
                throwerror('wrongInput', ...
                    'sTime is expected to be among elements of timeVec');
            end
            %
            matOpFactory = MatrixOperationsFactory.create(timeVec);
            %
            self.sTime = sTime;
            %
            t0 = pDynObj.gett0();
            t1 = pDynObj.gett1();
            %
            [cXstNormDynamics, RstDynamics] = self.calcTransMatDynamics(...
                t0, t1, pDynObj.getAtDynamics(), calcPrecision);
            %
            self.RstTransDynamics = matOpFactory.transpose(RstDynamics);
            self.XstNormDynamics = cXstNormDynamics;
            self.XstTransDynamics = matOpFactory.rMultiplyByScalar(...
                self.RstTransDynamics, cXstNormDynamics);
            %
            [self.ltGoodDirCurveSpline, ...
                self.ltGoodDirOneCurveSplineList] = ...
                buildGoodDirCurve(matOpFactory, ...
                self.XstTransDynamics, lsGoodDirMat);
            %
            [self.ltRGoodDirCurveSpline, ...
                self.ltRGoodDirOneCurveSplineList] = ...
                buildGoodDirCurve(matOpFactory, ...
                self.RstTransDynamics, lsGoodDirMat);
            function [ltCurveSpline, ltCurveSplineList] = ...
                    buildGoodDirCurve(factory, stTransDynamics, ...
                    lsGoodDirMat)
                import gras.mat.ConstMatrixFunctionFactory;
                %
                nGoodDirs = size(lsGoodDirMat, 2);
                ltCurveSplineList = cell(nGoodDirs, 1);
                for iGoodDir = 1:nGoodDirs
                    lsGoodDirConstColFunc = ...
                            ConstMatrixFunctionFactory.createInstance(...
                            lsGoodDirMat(:, iGoodDir));
                    ltCurveSplineList{iGoodDir} = ...
                        factory.rMultiply(stTransDynamics, ...
                        lsGoodDirConstColFunc);
                end
                %
                lsGoodDirConstFunc =  ...
                    ConstMatrixFunctionFactory.createInstance(...
                    lsGoodDirMat);
                ltCurveSpline = factory.rMultiply(stTransDynamics, ...
                    lsGoodDirConstFunc);
            end
        end
    end
    methods (Abstract, Access = protected)
        calcTransMatDynamics(self, t0, t1, AtDynamics, calcPrecision)
    end
end