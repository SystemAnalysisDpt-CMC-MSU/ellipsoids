classdef GoodDirectionSet
    properties
        %xstTransArray: double[nDims,nDims,nTimePoints] - X(s,t)' - transition
        %       matrix for good directions l(t)=X(s,t)'l_0
        XstTransDynamics
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
        function XstTransDynamics=getXstTransDynamics(self)
            XstTransDynamics=self.XstTransDynamics;
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
            import gras.ellapx.uncertcalc.MatrixOperationsFactory;
            import gras.mat.ConstMatrixFunction;
            import gras.mat.ConstColFunction;
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
            Xtt0Dynamics = pDefObj.getXtt0Dynamics();
            Xt0tTransDynamics = ...
                matOpFactory.transpose(matOpFactory.inv(Xtt0Dynamics));
            Xst0TransConstMatFunc = ...
                ConstMatrixFunction(Xtt0Dynamics.evaluate(sTime).');
            XstTransDynamics = ...
                matOpFactory.rMultiply(Xt0tTransDynamics,...
                Xst0TransConstMatFunc);
            %
            self.XstTransDynamics = XstTransDynamics;
            self.sTime=sTime;
            %
            nGoodDirs = self.getNGoodDirs();
            %
            self.ltGoodDirOneCurveSplineList = cell(nGoodDirs, 1);
            for iGoodDir = 1:nGoodDirs
                lsGoodDirConstColFunc = ...
                    ConstColFunction(lsGoodDirMat(:,iGoodDir));
                self.ltGoodDirOneCurveSplineList{iGoodDir} = ...
                    matOpFactory.rMultiply(XstTransDynamics, ...
                    lsGoodDirConstColFunc);
            end
            %
            lsGoodDirConstMatFunc = ConstMatrixFunction(lsGoodDirMat);
            self.ltGoodDirCurveSpline = matOpFactory.rMultiply(...
                XstTransDynamics, lsGoodDirConstMatFunc);
        end
    end
end
