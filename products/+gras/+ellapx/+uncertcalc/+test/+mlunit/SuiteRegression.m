classdef SuiteRegression < mlunitext.test_case
    properties (Access=private)
        testDataRootDir
        confNameList
        crm
        crmSys
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
                compFieldNameList=setdiff(fieldnames(SRunProp),...
                    NOT_COMPARED_FIELD_LIST);
                SRunProp=pathfilterstruct(SRunProp,compFieldNameList);
                if ~resMap.isKey(inpKey);
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
                    keyList=SSORT_KEYS.(fieldName);
                    isRoundVec=ismember(keyList,ROUND_FIELD_LIST);
                    roundKeyList=keyList(isRoundVec);
                    nRoundKeys=length(roundKeyList);
                    %
                    for iRound=1:nRoundKeys
                        roundKey=roundKeyList{iRound};
                        rel.applySetFunc(@(x)roundn(x,-nRoundDigits),...
                            roundKey);
                        expRel.applySetFunc(@(x)roundn(x,-nRoundDigits),...
                            roundKey);
                    end
                    rel.sortBy(SSORT_KEYS.(fieldName));
                    expRel.sortBy(SSORT_KEYS.(fieldName));
                    %
                    %expRel=smartdb.relations.DynamicRelation(expRel);
                    %expRel.removeFields('approxSchemaName');
                    %rel=smartdb.relations.DynamicRelation(rel);
                    %rel.removeFields('approxSchemaName');
                    %
                    [isOk,reportStr]=expRel.isEqual(rel,'maxTolerance',...
                        MAX_TOL,'checkTupleOrder',true);
                    %
                    reportStr=sprintf('confName=%s\n %s',confName,...
                        reportStr);
                    mlunit.assert_equals(true,isOk,reportStr);
                end
            end
            
        end
    end
end