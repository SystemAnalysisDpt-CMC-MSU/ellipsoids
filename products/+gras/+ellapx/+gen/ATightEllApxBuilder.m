classdef ATightEllApxBuilder<gras.ellapx.gen.IEllApxBuilder
    properties (Access=private)
        goodDirSetObj        
        pDefObj
        timeVec
        timeLimsVec
        nGoodDirs
        calcPrecision
        odeAbsCalcPrecision
        odeRelCalcPrecision        
    end
    properties (Constant,GetAccess=private)
        MAX_PRECISION_FACTOR=0.02;
    end
    methods (Access=protected)
        function res=getAbsODECalcPrecision(self)
            res=self.odeAbsCalcPrecision;
        end
        function res=getRelODECalcPrecision(self)
            res=self.odeRelCalcPrecision;
        end
        function pDefObj=getProblemDef(self)
            pDefObj=self.pDefObj;
        end
        function nGoodDirs=getNGoodDirs(self)
            nGoodDirs=self.nGoodDirs;
        end
        function timeVec=getTimeVec(self)
            timeVec=self.timeVec;
        end
        function timeLimsVec=getTimeLims(self,indVec)
            timeLimsVec=self.timeLimsVec;
            if nargin>1
                timeLimsVec=timeLimsVec(indVec);
            end
        end
        function goodDirSetObj=getGoodDirSet(self)
            goodDirSetObj=self.goodDirSetObj;
        end
    end
    methods
        function calcPrecision=getCalcPrecision(self)
            calcPrecision=self.calcPrecision;
        end
        function self=ATightEllApxBuilder(pDefObj,goodDirSetObj,...
                timeLimsVec,nTimePoints,calcPrecision)
            import gras.ellapx.gen.ATightEllApxBuilder;
            import modgen.common.throwerror;
            if ~isa(pDefObj,...
                    'gras.ellapx.lreachplain.LReachProblemDefInterp')
                throwerror('wrongInput','incorrect type of pDefObj');
            end
            sTime=goodDirSetObj.getsTime();
            if (sTime>timeLimsVec(2))||(sTime<timeLimsVec(1))
                throwerror('wrongInput',...
                    'sTime is expected to be within %s',...
                    mat2str(timeLimsVec));
            end
            pDefTimeLimsVec=pDefObj.getTimeLimsVec();
            if (pDefTimeLimsVec(1)>timeLimsVec(1))||...
                    (pDefTimeLimsVec(2)<timeLimsVec(2))
                throwerror('wrongInput',...
                    'timeLimsVec should be within pDefTimeLimsVec');
            end
            nDims=pDefObj.getDimensionality;            
            precisionFactor=min(2./(nDims*nDims),...
                ATightEllApxBuilder.MAX_PRECISION_FACTOR);            
            self.odeAbsCalcPrecision=calcPrecision*precisionFactor;
            self.odeRelCalcPrecision=calcPrecision*precisionFactor;               
            self.calcPrecision=calcPrecision;
            %% check that there is no disturbance
            self.pDefObj=pDefObj;   
            self.goodDirSetObj=goodDirSetObj;
            self.nGoodDirs=goodDirSetObj.getNGoodDirs();            
            timeVec=union(linspace(timeLimsVec(1),timeLimsVec(2),...
                nTimePoints),goodDirSetObj.getsTime());            
            self.timeVec=timeVec;
            self.timeLimsVec=timeLimsVec;
        end
    end
end
