classdef SuiteSupportFunction < mlunitext.test_case
    properties (Access=private)
        testDataRootDir
        confNameList
        crm
        crmSys
    end
    methods
        function self = SuiteSupportFunction(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),...
                filesep,'TestData',filesep,shortClassName];
        end
        %
        function self = set_up_param(self,varargin)
            if nargin>2
                self.crm=varargin{2};
            else
                self.crm=gras.ellapx.uncertcalc.test.conf.ConfRepoMgr();
            end
            if nargin>3
                self.crmSys=varargin{3};
            else
                self.crmSys=...
                    gras.ellapx.uncertcalc.test.conf.sysdef.ConfRepoMgr();
            end
            confNameList=varargin{1};
            if strcmp(confNameList,'*')
                self.crm.deployConfTemplate('*');
                confNameList=self.crm.getConfNameList();
            end
            if ischar(confNameList)
                confNameList={confNameList};
            end
            self.confNameList=confNameList;
        end
        function testRegression(self)
            NOT_COMPARED_FIELD_LIST={'resDir','plotterObj'};
            MAX_TOL=1e-6;
            SSORT_KEYS.ellTubeProjRel={'projSpecDimVec','projType',...
                'sTime','lsGoodDirOrigVec'};
            SSORT_KEYS.ellTubeRel={'sTime','lsGoodDirVec'};
            SSORT_KEYS.ellUnionTubeRel={'sTime','lsGoodDirVec'};
            SSORT_KEYS.ellUnionTubeStaticProjRel=...
                {'projSpecDimVec','projType','sTime','lsGoodDirOrigVec'};
            %
            ROUND_FIELD_LIST={'lsGoodDirOrigVec','lsGoodDirVec'};
            %
            nRoundDigits=-fix(log(MAX_TOL)/log(10));
            %
            crm=self.crm;
            crmSys=self.crmSys;
            confNameList=self.confNameList;
            nConfs=length(confNameList);
            for iConf=1:nConfs
                crm.deployConfTemplate(confNameList{iConf});
            end
            %
            methodName=modgen.common.getcallernameext(1);
            resMap=modgen.containers.ondisk.HashMapMatXML(...
                'storageLocationRoot',self.testDataRootDir,...
                'storageBranchKey',[methodName,'_out'],...
                'storageFormat','mat',...
                'useHashedPath',false,'useHashedKeys',true);
            %
            for iConf=1:nConfs
                confName=confNameList{iConf};
                inpKey=confName;
                SRunProp=gras.ellapx.uncertcalc.run(confName,...
                    'confRepoMgr',crm,'sysConfRepoMgr',crmSys);
                if crm.getParam('plottingProps.isEnabled')
                    SRunProp.plotterObj.closeAllFigures();
                end
                %
                calcPrecision=crm.getParam('genericProps.calcPrecision');                
                isOk=all(SRunProp.ellTubeProjRel.calcPrecision<=...
                    calcPrecision);
                mlunit.assert_equals(true,isOk);
                %
                self.crmSys.getParam('At');
                disp(At)
                pause;
            end
            
        end
    end
end