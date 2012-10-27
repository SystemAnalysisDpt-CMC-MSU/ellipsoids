classdef GoodDirectionSet
    properties
        %xstTransArray: double[nDims,nDims,nTimePoints] - X(s,t)' - transition
        %       matrix for good directions l(t)=X(s,t)'l_0        
        xstTransSpline
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
        %
        function xstTransSpline=getXstTransSpline(self)
            xstTransSpline=self.xstTransSpline;
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
            import gras.gen.SquareMatVector;
            import gras.interp.MatrixInterpolantFactory;
            import modgen.common.throwerror;
            %
            self.lsGoodDirMat=lsGoodDirMat;
            Xtt0SplineObj=pDefObj.getXtt0Spline();
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
            xtt0Array=Xtt0SplineObj.evaluate(timeVec);
            xt0tTransArray=SquareMatVector.transpose(SquareMatVector.pinv(xtt0Array));
            xst0TransMat=transpose(xtt0Array(:,:,indSTime));
            xstTransArray=SquareMatVector.rMultiply(xt0tTransArray,...
                xst0TransMat);
            self.xstTransSpline=...
                MatrixInterpolantFactory.createInstance(...
                'column',xstTransArray,timeVec);
            self.sTime=sTime;
            ltGoodDirCurveArray=SquareMatVector.rMultiply(...
                xstTransArray,lsGoodDirMat);
            self.ltGoodDirCurveSpline=...
                MatrixInterpolantFactory.createInstance(...
                'column',ltGoodDirCurveArray,timeVec);
            self.ltGoodDirOneCurveSplineList=...
                self.ltGoodDirCurveSpline.getColSplines();
        end
    end
end
