classdef ContinuousReachReachabilityTestCase < mlunitext.test_case
    properties (Access = private, Constant)
        FIELDS_NOT_TO_COMPARE={'LT_GOOD_DIR_MAT';'LT_GOOD_DIR_NORM_VEC';...
            'LS_GOOD_DIR_NORM';'LS_GOOD_DIR_VEC'};
        COMP_PRECISION = 5e-5;
    end
    properties (Access=private)
        testDataRootDir
        etalonDataRootDir
        etalonDataBranchKey
        confName
        crm
        crmSys
        linSys
        reachObj
        timeVec
        calcPrecision
    end
    methods
        function self = ContinuousReachReachabilityTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir = [fileparts(which(className)),...
                filesep, 'TestData', filesep, shortClassName];
            % obtain the path of etalon data
            regrClassName =...
                'gras.ellapx.uncertcalc.test.regr.mlunit.SuiteRegression';
            shortRegrClassName = 'SuiteRegression';
            self.etalonDataRootDir = [fileparts(which(regrClassName)),...
                filesep, 'TestData', filesep, shortRegrClassName];
            self.etalonDataBranchKey = 'testRegression_out';
        end
        %
        function self = set_up_param(self, confName, crm, crmSys)
            self.crm = crm;
            self.crmSys = crmSys;
            self.confName = confName;
            %
            self.crm.deployConfTemplate(self.confName);
            self.crm.selectConf(self.confName);
            sysDefConfName = self.crm.getParam('systemDefinitionConfName');
            self.crmSys.selectConf(sysDefConfName, 'reloadIfSelected', false);
            %
            atDefCMat = self.crmSys.getParam('At');
            btDefCMat = self.crmSys.getParam('Bt');
            ctDefCMat = self.crmSys.getParam('Ct');
            ptDefCMat = self.crmSys.getParam('control_restriction.Q');
            ptDefCVec = self.crmSys.getParam('control_restriction.a');
            qtDefCMat = self.crmSys.getParam('disturbance_restriction.Q');
            qtDefCVec = self.crmSys.getParam('disturbance_restriction.a');
            x0DefMat = self.crmSys.getParam('initial_set.Q');
            x0DefVec = self.crmSys.getParam('initial_set.a');
            l0CMat = self.crm.getParam(...
                'goodDirSelection.methodProps.manual.lsGoodDirSets.set1');
            l0Mat = cell2mat(l0CMat.').';
            self.timeVec = [self.crmSys.getParam('time_interval.t0'),...
                self.crmSys.getParam('time_interval.t1')];
            self.calcPrecision =...
                self.crm.getParam('genericProps.calcPrecision');
            ControlBounds = struct();
            ControlBounds.center = ptDefCVec;
            ControlBounds.shape = ptDefCMat;
            DistBounds = struct();
            DistBounds.center = qtDefCVec;
            DistBounds.shape = qtDefCMat;
            %
            self.linSys = elltool.linsys.LinSys(atDefCMat, btDefCMat,...
                ControlBounds, ctDefCMat, DistBounds);
            self.reachObj = elltool.reach.ReachContinious(self.linSys,...
                ellipsoid(x0DefVec, x0DefMat), l0Mat, self.timeVec);
        end
        % change:
        function self = DISABLED_testSystem(self)
            import modgen.common.throwerror;
            import elltool.reach.test.mlunit.ContiniousReachTestCase;
            %
            COMPARED_FIELD_LIST = {'ellTubeRel'};
            SSORT_KEYS.ellTubeRel = {'approxSchemaName', 'lsGoodDirVec'};
            ROUND_FIELD_LIST = {'lsGoodDirOrigVec', 'lsGoodDirVec'};
            nRoundDigits = -fix(log(self.COMP_PRECISION) / log(10));
            %
            resMap = modgen.containers.ondisk.HashMapMatXML(...
                'storageLocationRoot', self.etalonDataRootDir,...
                'storageBranchKey', self.etalonDataBranchKey,...
                'storageFormat', 'mat', 'useHashedPath', false,...
                'useHashedKeys', true);
            %
            SRunProp = struct();
            SRunProp.ellTubeRel = self.reachObj.getEllTubeRel();
            %
            isOk = all(SRunProp.ellTubeRel.calcPrecision <=...
                self.calcPrecision);
            mlunit.assert_equals(true, isOk);
            %
            SRunProp=pathfilterstruct(SRunProp, COMPARED_FIELD_LIST);
            if resMap.isKey(self.confName);
                SExpRes = resMap.get(self.confName);
                nCmpFields = numel(COMPARED_FIELD_LIST);
                for iField = 1 : nCmpFields
                    fieldName = COMPARED_FIELD_LIST{iField};
                    expRel = SExpRes.(fieldName);
                    rel = SRunProp.(fieldName);
                    %
                    keyList = SSORT_KEYS.(fieldName);
                    isRoundVec = ismember(keyList, ROUND_FIELD_LIST);
                    roundKeyList = keyList(isRoundVec);
                    nRoundKeys = length(roundKeyList);
                    %
                    for iRound = 1 : nRoundKeys
                        roundKey = roundKeyList{iRound};
                        rel.applySetFunc(@(x) roundn(x, -nRoundDigits),...
                            roundKey);
                        expRel.applySetFunc(@(x) roundn(x, -nRoundDigits),...
                            roundKey);
                    end
                    rel.sortBy(SSORT_KEYS.(fieldName));
                    expRel.sortBy(SSORT_KEYS.(fieldName));
                    [isOk, reportStr] =...
                        expRel.isEqual(rel, 'maxTolerance',...
                        self.COMP_PRECISION, 'checkTupleOrder', true);
                    %
                    reportStr = sprintf('confName=%s\n %s', self.confName,...
                        reportStr);
                    mlunit.assert_equals(true, isOk, reportStr);
                end
            else
                throwerror('WrongInput', 'Do not exist config mat file.');
            end
        end
        %
        function self = testProjection(self)
            atDefCMat = self.crmSys.getParam('At');
            zeroASizeCMat = arrayfun(@num2str, zeros(size(atDefCMat)),...
                'UniformOutput', false);
            newAtCMat = [atDefCMat zeroASizeCMat; zeroASizeCMat atDefCMat];
            btDefCMat = self.crmSys.getParam('Bt');
            zeroBSizeCMat = arrayfun(@num2str, zeros(size(btDefCMat)),...
                'UniformOutput', false);
            newBtCMat = [btDefCMat zeroBSizeCMat; zeroBSizeCMat btDefCMat];
            ctDefCMat = self.crmSys.getParam('Ct');
            zeroCSizeCMat = arrayfun(@num2str, zeros(size(ctDefCMat)),...
                'UniformOutput', false);
            newCtCMat = [ctDefCMat zeroCSizeCMat; zeroCSizeCMat ctDefCMat];
            %
            ptDefCMat = self.crmSys.getParam('control_restriction.Q');
            zeroPSizeCMat = arrayfun(@num2str, zeros(size(ptDefCMat)),...
                'UniformOutput', false);
            newPtCMat = [ptDefCMat zeroPSizeCMat; zeroPSizeCMat ptDefCMat];
            ptDefCVec = self.crmSys.getParam('control_restriction.a');
            newPtCVec = [ptDefCVec; ptDefCVec];
            qtDefCMat = self.crmSys.getParam('disturbance_restriction.Q');
            zeroQSizeCMat = arrayfun(@num2str, zeros(size(qtDefCMat)),...
                'UniformOutput', false);
            newQtCMat = [qtDefCMat zeroQSizeCMat; zeroQSizeCMat qtDefCMat];
            qtDefCVec = self.crmSys.getParam('disturbance_restriction.a');
            newQtCVec = [qtDefCVec; qtDefCVec];
            x0DefMat = self.crmSys.getParam('initial_set.Q');
            newX0Mat = [x0DefMat zeros(size(x0DefMat));...
                zeros(size(x0DefMat)) x0DefMat];
            x0DefVec = self.crmSys.getParam('initial_set.a');
            newX0Vec = [x0DefVec; x0DefVec];
            l0CMat = self.crm.getParam(...
                'goodDirSelection.methodProps.manual.lsGoodDirSets.set1');
            l0Mat = cell2mat(l0CMat.').';
            newL0Mat = [l0Mat zeros(size(l0Mat)); zeros(size(l0Mat)) l0Mat];
            ControlBounds = struct();
            ControlBounds.center = newPtCVec;
            ControlBounds.shape = newPtCMat;
            DistBounds = struct();
            DistBounds.center = newQtCVec;
            DistBounds.shape = newQtCMat;
            %
            oldDim = self.reachObj.dimension;
            newLinSys = elltool.linsys.LinSys(newAtCMat, newBtCMat,...
                ControlBounds, newCtCMat, DistBounds);
            newReachObj = elltool.reach.ReachContinious(newLinSys,...
                ellipsoid(newX0Vec, newX0Mat), newL0Mat, self.timeVec);
            firstProjReachObj =...
                newReachObj.projection([eye(oldDim); zeros(oldDim)]);
            secondProjReachObj =...
                newReachObj.projection([zeros(oldDim); eye(oldDim)]);
            isEqual = self.reachObj.isEqual(firstProjReachObj);
            mlunit.assert_equals(true, isEqual);
            isEqual = self.reachObj.isEqual(secondProjReachObj);
            mlunit.assert_equals(true, isEqual);
        end
    end
end