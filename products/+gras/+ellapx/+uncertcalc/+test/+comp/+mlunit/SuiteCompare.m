classdef SuiteCompare < mlunitext.test_case
    properties (Access=private)
        confNameList
        crm
        crmSys
        resTmpDir
    end
    methods
        function self = SuiteCompare(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up(self)
            self.resTmpDir = elltool.test.TmpDataManager.getDirByCallerKey;
        end
        function self = tear_down(self)
            rmdir(self.resTmpDir,'s');
        end
        function self = set_up_param(self,varargin)
            if nargin>2
                self.crm=varargin{2};
            else
                self.crm=gras.ellapx.uncertcalc.test.comp.conf.ConfRepoMgr();
            end
            if nargin>3
                self.crmSys=varargin{3};
            else
                self.crmSys=...
                    gras.ellapx.uncertcalc.test.comp.conf.sysdef.ConfRepoMgr();
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
        function testCompare(self)
            NOT_COMPARED_FIELD_LIST={'resDir','plotterObj'};
            MAX_TOL=1e-6;
            SSORT_KEYS.ellTubeProjRel={'projSTimeMat','projType',...
                'sTime','lsGoodDirOrigVec'};
            SSORT_KEYS.ellTubeRel={'sTime','lsGoodDirVec'};
            SSORT_KEYS.ellUnionTubeRel={'sTime','lsGoodDirVec'};
            SSORT_KEYS.ellUnionTubeStaticProjRel=...
                {'projSTimeMat','projType','sTime','lsGoodDirOrigVec'};
            %
            ROUND_FIELD_LIST={'lsGoodDirOrigVec','lsGoodDirVec'};
            %
            nRoundDigits=-fix(log(MAX_TOL)/log(10));
            %
            crm=self.crm;
            crmSys=self.crmSys;
            confNameList=self.confNameList;
            nConfs=length(confNameList);
            %
            % expecting two configurations: name and name_lti
            %
            mlunitext.assert_equals(nConfs,2);
            %
            for iConf=1:2
                crm.deployConfTemplate(confNameList{iConf});
            end
            %
            % run computation for each configuration
            %
            runResults = cell(1,2);
            nCmpFieldsCVec = cell(1,2);
            compFieldNameListCVec = cell(1,2);
            for iConf=1:2
                confName=confNameList{iConf};
                crm.selectConf(confName,'reloadIfSelected',false);
                crm.setParam('customResultDir.dirName',self.resTmpDir,...
                        'writeDepth','cache');
                crm.setParam('customResultDir.isEnabled',true,...
                        'writeDepth','cache');
                runResult=gras.ellapx.uncertcalc.run(confName,...
                    'confRepoMgr',crm,'sysConfRepoMgr',crmSys);
                if crm.getParam('plottingProps.isEnabled')
                    runResult.plotterObj.closeAllFigures();
                end
                %
                calcPrecision=crm.getParam('genericProps.calcPrecision');
                isOk=all(runResult.ellTubeProjRel.calcPrecision<=...
                    calcPrecision);
                mlunitext.assert_equals(true,isOk);
                %
                % filter struct fields
                %
                compFieldNameList=setdiff(fieldnames(runResult),...
                    NOT_COMPARED_FIELD_LIST);
                runResult=pathfilterstruct(runResult,compFieldNameList);
                
                runResults{iConf} = runResult;
                nCmpFieldsCVec{iConf} = numel(compFieldNameList);
                compFieldNameListCVec{iConf} = sort(compFieldNameList);
            end;
            %
            % number of fields and fields themselves should be the same
            %
            mlunitext.assert_equals(nCmpFieldsCVec{1},nCmpFieldsCVec{2});
            isEqVec=strcmp(compFieldNameListCVec{1},compFieldNameListCVec{2});
            mlunitext.assert_equals(all(isEqVec),true);
            %
            compFieldNameList = fieldnames(runResults{1});
            nCmpFields = numel(compFieldNameList);
            %
            % compare results
            %
            for iField=1:nCmpFields
                fieldName=compFieldNameList{iField};
                fieldValue1=runResults{1}.(fieldName);
                fieldValue2=runResults{2}.(fieldName);
                %
                keyList=SSORT_KEYS.(fieldName);
                isRoundVec=ismember(keyList,ROUND_FIELD_LIST);
                roundKeyList=keyList(isRoundVec);
                nRoundKeys=length(roundKeyList);
                %
                for iRound=1:nRoundKeys
                    roundKey=roundKeyList{iRound};
                    fieldValue1.applySetFunc(@(x)roundn(x,-nRoundDigits),...
                        roundKey);
                    fieldValue2.applySetFunc(@(x)roundn(x,-nRoundDigits),...
                        roundKey);
                end
                fieldValue1.sortBy(SSORT_KEYS.(fieldName));
                fieldValue2.sortBy(SSORT_KEYS.(fieldName));
                [isOk,reportStr]=fieldValue1.isEqual(fieldValue2,...
                    'maxTolerance',2*calcPrecision,'checkTupleOrder',true);
                %
                reportStr=sprintf('confName=%s\n %s',confName,...
                    reportStr);
                mlunitext.assert_equals(true,isOk,reportStr);
            end
            
        end
    end
end