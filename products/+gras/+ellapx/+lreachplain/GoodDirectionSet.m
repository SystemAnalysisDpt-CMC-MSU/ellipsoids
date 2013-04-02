classdef GoodDirectionSet
    properties
        %rstTransArray: double[nDims,nDims,nTimePoints] - R(s,t)' - transition
        %       matrix for good directions l(t)=R(s,t)'l_0
        RstTransDynamics
        ltGoodDirCurveSpline
        ltGoodDirOneCurveSplineList
        sTime
        lsGoodDirMat
    end
    methods
        function nGoodDirs=getNGoodDirs(self)
            nGoodDirs=size(self.lsGoodDirMat,2);
        end
        function ltGoodDirCurveSpline=getGoodDirCurveSpline(self)
            ltGoodDirCurveSpline=self.ltGoodDirCurveSpline;
        end
        function ltGoodDirCurveSpline=getGoodDirOneCurveSpline(self,dirNum)
            ltGoodDirCurveSpline=...
                self.ltGoodDirOneCurveSplineList{dirNum};
        end
        function ltGoodDirSplineList=getGoodDirOneCurveSplineList(self)
            ltGoodDirSplineList=...
                self.ltGoodDirOneCurveSplineList;
        end
        %
        function RstTransDynamics=getRstTransDynamics(self)
            RstTransDynamics=self.RstTransDynamics;
        end
        function sTime=getsTime(self)
            sTime=self.sTime;
        end
        function lsGoodDirMat=getlsGoodDirMat(self)
            lsGoodDirMat=self.lsGoodDirMat;
        end
        function self=GoodDirectionSet(pDefObj,sTime,lsGoodDirMat,...
                calcPrecision)
            import gras.ellapx.common.*;
            import gras.mat.MatrixOperationsFactory;
            import gras.mat.fcnlib.ConstMatrixFunction;
            import gras.mat.fcnlib.ConstColFunction;
            import modgen.common.throwerror;
            %
            self.lsGoodDirMat=lsGoodDirMat;
            %
            timeLimsVec=pDefObj.getTimeLimsVec();
            if (sTime>timeLimsVec(2))||(sTime<timeLimsVec(1))
                throwerror('wrongInput',...
                    'sTime is expected to be within %s',...
                    mat2str(timeLimsVec));
            end
            timeVec=unique([pDefObj.getTimeVec(),sTime]);
            indSTime=find(timeVec==sTime,1,'first');
            if isempty(indSTime)
                throwerror('wrongInput',...
                    'sTime is expected to be among elements of timeVec');
            end
            %
            matOpFactory = MatrixOperationsFactory.create(timeVec);
            %
            Rtt0Dynamics = pDefObj.getRtt0Dynamics();
            Xt0tTransDynamics = ...
                matOpFactory.transpose(matOpFactory.inv(Rtt0Dynamics));
            Rst0TransConstMatFunc = ...
                ConstMatrixFunction(Rtt0Dynamics.evaluate(sTime).');
            RstTransDynamics = ...
                matOpFactory.rMultiply(Xt0tTransDynamics,...
                Rst0TransConstMatFunc);
            %
            self.RstTransDynamics = RstTransDynamics;
            self.sTime=sTime;
            %
            nGoodDirs = self.getNGoodDirs();
            %
            self.ltGoodDirOneCurveSplineList = cell(nGoodDirs, 1);
            for iGoodDir = 1:nGoodDirs
                lsGoodDirConstColFunc = ...
                    ConstColFunction(lsGoodDirMat(:,iGoodDir));
                self.ltGoodDirOneCurveSplineList{iGoodDir} = ...
                    matOpFactory.rMultiply(RstTransDynamics, ...
                    lsGoodDirConstColFunc);
            end
            %
            lsGoodDirConstMatFunc = ConstMatrixFunction(lsGoodDirMat);
            self.ltGoodDirCurveSpline = matOpFactory.rMultiply(...
                RstTransDynamics, lsGoodDirConstMatFunc);
        end
    end
end
