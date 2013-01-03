classdef NewReachTestCase < mlunitext.test_case
    properties (Access=private)
        testDataRootDir
        etalonDataRootDir
        etalonDataBranchKey
        confNameList
        crm
        crmSys
    end
    methods
        function self = NewReachTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),...
                filesep,'TestData',filesep,shortClassName];
            % obtain the path of etalon data
            regrClassName = 'gras.ellapx.uncertcalc.test.regr.mlunit.SuiteRegression';
            shortRegrClassName='SuiteRegression';
            self.etalonDataRootDir=[fileparts(which(regrClassName)),...
                filesep,'TestData',filesep,shortRegrClassName];
            self.etalonDataBranchKey = 'testRegression_out';
        end
        %
        function self = set_up_param(self,confNameList,crm,crmSys)
            self.crm=crm;
            self.crmSys=crmSys;
            self.confNameList=confNameList;
        end
        %
        function self = testSystem(self)
            COMPARED_FIELD_LIST={'ellTubeRel'};
            MAX_TOL=5*1e-5;
            SSORT_KEYS.ellTubeRel={'approxSchemaName','lsGoodDirVec'};
            ROUND_FIELD_LIST={'lsGoodDirOrigVec','lsGoodDirVec'};
            nRoundDigits=-fix(log(MAX_TOL)/log(10));
            crm=self.crm;
            crmSys=self.crmSys;
            confNameList=self.confNameList;
            nConfs=length(self.confNameList);
            for iConf=1:nConfs
                crm.deployConfTemplate(confNameList{iConf});
            end
            %
            resMap=modgen.containers.ondisk.HashMapMatXML(...
                'storageLocationRoot',self.etalonDataRootDir,...
                'storageBranchKey',self.etalonDataBranchKey,...
                'storageFormat','mat',...
                'useHashedPath',false,'useHashedKeys',true);
            %
            for iConf=1:nConfs
                confName=confNameList{iConf};
                inpKey=confName;
                crm = self.crm;
                crm.selectConf(confName,'reloadIfSelected',false);
                sysDefConfName = crm.getParam('systemDefinitionConfName');
                crmSys = self.crmSys;
                crmSys.selectConf(sysDefConfName,'reloadIfSelected',false);
                %
                atDefCMat = crmSys.getParam('At');
                btDefCMat = crmSys.getParam('Bt');
                ctDefCMat = crmSys.getParam('Ct');
                ptDefCMat = crmSys.getParam('control_restriction.Q');
                ptDefCVec = crmSys.getParam('control_restriction.a');
                qtDefCMat = crmSys.getParam('disturbance_restriction.Q');
                qtDefCVec = crmSys.getParam('disturbance_restriction.a');
                x0DefMat = crmSys.getParam('initial_set.Q');
                x0DefVec = crmSys.getParam('initial_set.a');
                l0CMat = crm.getParam(...
                    'goodDirSelection.methodProps.manual.lsGoodDirSets.set1');
                l0Mat = reshape(cell2mat(l0CMat),...
                    numel(l0CMat), numel(l0CMat{1}));
                tLims = [crmSys.getParam('time_interval.t0'),...
                    crmSys.getParam('time_interval.t1')];
                ControlBounds = struct();
                ControlBounds.center = ptDefCVec;
                ControlBounds.shape = ptDefCMat;
                DistBounds = struct();
                DistBounds.center = qtDefCVec;
                DistBounds.shape = qtDefCMat;
                %
                linSys = elltool.linsys.LinSys(atDefCMat, btDefCMat,...
                    ControlBounds, ctDefCMat, DistBounds);
                reachObj = elltool.reach.ReachContinious(linSys,...
                    ellipsoid(x0DefVec, x0DefMat), l0Mat, tLims);
                %
                SRunProp = struct();
                SRunProp.ellTubeRel = reachObj.getEllTubeRel();
                %
                calcPrecision=crm.getParam('genericProps.calcPrecision');
                isOk=all(SRunProp.ellTubeRel.calcPrecision<=calcPrecision);
                mlunit.assert_equals(true,isOk);
                %
                SRunProp=pathfilterstruct(SRunProp,COMPARED_FIELD_LIST);
                if resMap.isKey(inpKey);
                    SExpRes = resMap.get(inpKey);
                    nCmpFields=numel(COMPARED_FIELD_LIST);
                    for iField=1:nCmpFields
                        fieldName=COMPARED_FIELD_LIST{iField};
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
   
                        [isOk,reportStr]=expRel.isEqual(rel,'maxTolerance',...
                            MAX_TOL,'checkTupleOrder',true);
                        %
                        reportStr=sprintf('confName=%s\n %s',confName,...
                            reportStr);
                        mlunit.assert_equals(true,isOk,reportStr);
                    end
                else
                    % error
                end 
            end
        end
    end
end