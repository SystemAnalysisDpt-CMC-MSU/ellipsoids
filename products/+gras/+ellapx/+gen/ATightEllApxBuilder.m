classdef ATightEllApxBuilder<gras.ellapx.gen.IEllApxBuilder
    properties (Constant,GetAccess=private)
        N_TIME_POINTS=100;
    end
    properties (Access=private)
        goodDirSetObj
        pDefObj
        timeVec
        timeLimsVec
        nGoodDirs
        odeAbsCalcPrecision
        odeRelCalcPrecision
    end
    properties (Access=protected)
        sMethodName
    end
    properties (SetAccess=private,GetAccess=protected)
        relTol
        absTol
    end
    properties (Constant,GetAccess=private)
        MAX_PRECISION_FACTOR=0.002;
    end
    %
    methods
        function property = get.absTol(self)
            self.beforeGetAbsTol();
            property = self.absTol;
        end
        function property = get.relTol(self)
            self.beforeGetRelTol();
            property = self.relTol;
        end
    end
    methods (Access = protected)
        function beforeGetAbsTol(self) %#ok<MANU>
            % count references to absTol in subclasses
        end
        function beforeGetRelTol(self) %#ok<MANU>
            % count references to relTol in subclasses
        end
    end
    %
    methods (Access=protected)
        function sMat=getOrthTranslMatrix(self,QMat,RSqrtMat,bVec,aVec)
            import gras.la.*;
            switch self.sMethodName
                case 'hausholder'
                    sMat=orthtranslhaus(bVec,aVec);
                case 'gram',
                    sMat=orthtransl(bVec,aVec);
                case 'trace',
                    sMat=orthtranslmaxtr(bVec,aVec,RSqrtMat*QMat);
                case 'volume',
                    sMat=orthtranslmaxtr(bVec,aVec,RSqrtMat/(QMat.'));
                case 'qr',
                    sMat=orthtranslqr(bVec,aVec);
                otherwise,
                    modgen.common.throwerror('wrongInput',...
                        'method %s is not supported',self.sMethodName);
            end
        end
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
        function relTol=getRelTol(self)
            relTol = self.relTol;
        end
        function absTol=getAbsTol(self)
            absTol = self.absTol;
        end
        %
        function self=ATightEllApxBuilder(pDefObj,goodDirSetObj,...
                timeLimsVec,relTol,absTol,varargin)
            import gras.ellapx.gen.ATightEllApxBuilder;
            import modgen.common.throwerror;
            import gras.la.ismatposdef; 
            [~,~,nTimePoints]=modgen.common.parseparext(varargin,...
                {'nTimeGridPoints'; ATightEllApxBuilder.N_TIME_POINTS},...
                [0 1]);
            if ~isa(pDefObj,...
                    'gras.ellapx.lreachplain.probdyn.IReachProblemDynamics')
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
                ATightEllApxBuilder.MAX_PRECISION_FACTOR)*...
                (100/nTimePoints);
            %
            self.odeAbsCalcPrecision=absTol*precisionFactor;
            self.odeRelCalcPrecision=relTol*precisionFactor;
            self.relTol=relTol;
            self.absTol=absTol;
            x0Mat = pDefObj.getX0Mat();            
            if ~ismatposdef(x0Mat, absTol)
                throwerror('wrongInput',...
                    'Initial set is not positive definite.');
            end            
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
