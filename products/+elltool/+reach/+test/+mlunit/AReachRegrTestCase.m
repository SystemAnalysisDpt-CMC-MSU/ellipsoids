classdef AReachRegrTestCase < mlunitext.test_case
    properties (Access=private, Constant)
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
        linSysFactory
        reachObfFactory
    end
    methods (Access = private)
        function [atDefCMat, btDefCMat, ctDefCMat, ptDefCMat,...
                ptDefCVec, qtDefCMat, qtDefCVec, x0DefMat,...
                x0DefVec, l0Mat] = getSysParams(self)
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
        end
    end
    methods
        function self = AReachRegrTestCase(linSysFactory, ...
                reachObfFactory, varargin)
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
            self.linSysFactory = linSysFactory;
            self.reachObfFactory = reachObfFactory;
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
            [atDefCMat, btDefCMat, ctDefCMat, ptDefCMat,...
                ptDefCVec, qtDefCMat, qtDefCVec,...
                x0DefMat, x0DefVec, l0Mat] = self.getSysParams();
            %
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
            self.linSys = self.linSysFactory.create(atDefCMat, btDefCMat,...
                ControlBounds, ctDefCMat, DistBounds);
            self.reachObj = self.reachObfFactory.create(self.linSys,...
                ellipsoid(x0DefVec, x0DefMat), l0Mat, self.timeVec);
        end
        %
        function self = testProjection(self)
            [atDefCMat, btDefCMat, ctDefCMat, ptDefCMat,...
                ptDefCVec, qtDefCMat, qtDefCVec,...
                x0DefMat, x0DefVec, l0Mat] = self.getSysParams();
            zeroASizeCMat = arrayfun(@num2str, zeros(size(atDefCMat)),...
                'UniformOutput', false);
            newAtCMat = [atDefCMat zeroASizeCMat; zeroASizeCMat atDefCMat];
            zeroBSizeCMat = arrayfun(@num2str, zeros(size(btDefCMat)),...
                'UniformOutput', false);
            newBtCMat = [btDefCMat zeroBSizeCMat; zeroBSizeCMat btDefCMat];
            zeroCSizeCMat = arrayfun(@num2str, zeros(size(ctDefCMat)),...
                'UniformOutput', false);
            newCtCMat = [ctDefCMat zeroCSizeCMat; zeroCSizeCMat ctDefCMat];
            zeroPSizeCMat = arrayfun(@num2str, zeros(size(ptDefCMat)),...
                'UniformOutput', false);
            newPtCMat = [ptDefCMat zeroPSizeCMat; zeroPSizeCMat ptDefCMat];
            newPtCVec = [ptDefCVec; ptDefCVec];
            zeroQSizeCMat = arrayfun(@num2str, zeros(size(qtDefCMat)),...
                'UniformOutput', false);
            newQtCMat = [qtDefCMat zeroQSizeCMat; zeroQSizeCMat qtDefCMat];
            newQtCVec = [qtDefCVec; qtDefCVec];
            newX0Mat = [x0DefMat zeros(size(x0DefMat));...
                zeros(size(x0DefMat)) x0DefMat];
            newX0Vec = [x0DefVec; x0DefVec];
            newL0Mat = [l0Mat zeros(size(l0Mat)); zeros(size(l0Mat)) l0Mat];
            ControlBounds = struct();
            ControlBounds.center = newPtCVec;
            ControlBounds.shape = newPtCMat;
            DistBounds = struct();
            DistBounds.center = newQtCVec;
            DistBounds.shape = newQtCMat;
            %
            oldDim = self.reachObj.dimension();
            newLinSys = self.linSysFactory.create(newAtCMat, ...
                newBtCMat, ControlBounds, newCtCMat, DistBounds);
            newReachObj = feval(class(self.reachObj), newLinSys,...
                ellipsoid(newX0Vec, newX0Mat), newL0Mat, self.timeVec);
            firstProjReachObj =...
                newReachObj.projection([eye(oldDim); zeros(oldDim)]);
            secondProjReachObj =...
                newReachObj.projection([zeros(oldDim); eye(oldDim)]);
            isEqual = self.reachObj.isEqual(firstProjReachObj);
            mlunitext.assert_equals(true, isEqual);
            isEqual = self.reachObj.isEqual(secondProjReachObj);
            mlunitext.assert_equals(true, isEqual);
        end
    end
end