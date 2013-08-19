classdef SuiteRegression < mlunitext.test_case
    properties (Access=private)
        testDataRootDir
        confNameList
        crm
        crmSys
        resTmpDir
        isReCache
    end
    methods
        function self = SuiteRegression(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),...
                filesep,'TestData',filesep,shortClassName];
        end
        %
        function self = set_up(self)
            self.resTmpDir = elltool.test.TmpDataManager.getDirByCallerKey;
        end
        function self = tear_down(self)
            rmdir(self.resTmpDir,'s');
        end
        function self = set_up_param(self,varargin)
            [reg,~,self.isReCache]=modgen.common.parseparext(varargin,...
                {'reCache';false;'islogical(x)'});
            nRegs=length(reg);
            if nRegs>2
                self.crm=reg{2};
            else
                self.crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            end
            if nRegs>3
                self.crmSys=reg{3};
            else
                self.crmSys=...
                    gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            end
            confNameList=reg{1};
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
            %
            %
            curCrm=self.crm;
            curCrmSys=self.crmSys;
            curConfNameList=self.confNameList;
            nConfs=length(curConfNameList);
            for iConf=1:nConfs
                curCrm.deployConfTemplate(curConfNameList{iConf});
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
                confName=curConfNameList{iConf};
                inpKey=confName;
                curCrm.selectConf(confName,'reloadIfSelected',false);
                curCrm.setParam('customResultDir.dirName',self.resTmpDir,...
                        'writeDepth','cache');
                curCrm.setParam('customResultDir.isEnabled',true,...
                        'writeDepth','cache');
                SRunProp=gras.ellapx.uncertcalc.run(confName,...
                    'confRepoMgr',curCrm,'sysConfRepoMgr',curCrmSys);
                if curCrm.getParam('plottingProps.isEnabled')
                    SRunProp.plotterObj.closeAllFigures();
                end
                %
                calcPrecision=curCrm.getParam('genericProps.calcPrecision');                
                isOk=all(SRunProp.ellTubeProjRel.calcPrecision<=...
                    calcPrecision);
                mlunitext.assert_equals(true,isOk);
                %
                compFieldNameList=setdiff(fieldnames(SRunProp),...
                    NOT_COMPARED_FIELD_LIST);
                SRunProp=pathfilterstruct(SRunProp,compFieldNameList);
                if self.isReCache||~resMap.isKey(inpKey);
                    SExpRes=SRunProp;
                    resMap.put(inpKey,SExpRes);
                end
                SExpRes=resMap.get(inpKey);
                nCmpFields=numel(compFieldNameList);
                for iField=1:nCmpFields
                    fieldName=compFieldNameList{iField};
                    expRel=SExpRes.(fieldName);
                    rel=SRunProp.(fieldName);
                    %
                    %expRel=smartdb.relations.DynamicRelation(expRel);
                    %expRel.removeFields('approxSchemaName');
                    %rel=smartdb.relations.DynamicRelation(rel);
                    %rel.removeFields('approxSchemaName');
                    %
                    [isOk,reportStr]=expRel.isEqual(rel);
                    %
                    reportStr=sprintf('confName=%s\n %s',confName,...
                        reportStr);
                    mlunitext.assert_equals(true,isOk,reportStr);
                end
            end
            
        end
    end
end