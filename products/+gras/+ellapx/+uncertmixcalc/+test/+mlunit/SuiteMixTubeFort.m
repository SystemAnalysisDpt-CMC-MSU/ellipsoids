classdef SuiteMixTubeFort < mlunitext.test_case
    properties (Access=private)
        confName
        crm
        crmSys
    end
    methods
        function self = SuiteMixTubeFort(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up_param(self,crm,crmSys,confName)
            self.crm=crm;
            self.crmSys=crmSys;
            self.confName=confName;
        end
        %
        function testCompare(self)
            import gras.ellapx.smartdb.F
            %
            calcPrecision = 1e-5;
            %
            SRunProp = gras.ellapx.uncertmixcalc.run(self.confName,...
                'confRepoMgr',self.crm,'sysConfRepoMgr',self.crmSys);
            ellTubeGot = SRunProp.ellTubeRel;
            DataGot = ellTubeGot.getData();
            %
            curPath = fileparts(mfilename('fullpath'));
            SFortranTube = load([curPath filesep 'TestData'...
                filesep self.confName '.mat']);
            ellTubeExp = SFortranTube.ellTubeRel;
            DataExp = ellTubeExp.getData();
            %
            nTubes = ellTubeExp.getNElems;
            for iTube = 1:nTubes
                checkField(F.Q_ARRAY);
                checkField(F.A_MAT);
                %
                lGotMat = DataGot.(F.LT_GOOD_DIR_MAT){iTube};
                lExpMat = DataExp.(F.LT_GOOD_DIR_MAT){iTube};
                lGotMat = bsxfun(@rdivide, lGotMat,...
                    realsqrt(sum(lGotMat.*lGotMat)));
                lExpMat = bsxfun(@rdivide, lExpMat,...
                    realsqrt(sum(lExpMat.*lExpMat)));
                compareArrays(lGotMat, lExpMat);
            end
            %
            function checkField(fieldName)
                compareArrays(DataGot.(fieldName){iTube}, ...
                    DataExp.(fieldName){iTube})
            end
            %
            function compareArrays(aArray, bArray)
                rArray = aArray - bArray;
                mlunitext.assert(max(abs(rArray(:))) < calcPrecision);
            end
        end
    end
end