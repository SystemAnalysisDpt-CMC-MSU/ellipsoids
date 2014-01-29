classdef ContinuousReachFirstTestCase < mlunitext.test_case
    properties (Access=private, Constant)
        COMP_PRECISION = 5e-5;
    end
    properties (Access=private)
        testDataRootDir
        confName
        crm
        crmSys
        linSys
        reachObj
        timeVec
    end
    methods (Access=private, Static)
        function checkIntersection(reachObj, ellVec)
            mlunitext.assert_equals(false,reachObj.intersect(ellVec(1),'e'));
            mlunitext.assert_equals(false,reachObj.intersect(ellVec(1),'i'));
            mlunitext.assert_equals(true,reachObj.intersect(ellVec(2),'e'));
            mlunitext.assert_equals(false,reachObj.intersect(ellVec(2),'i'));
            mlunitext.assert_equals(true,reachObj.intersect(ellVec(3),'e'));
            mlunitext.assert_equals(true,reachObj.intersect(ellVec(3),'i'));
        end
    end
    methods
        function self = ContinuousReachFirstTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir = [fileparts(which(className)),...
                filesep, 'TestData', filesep, shortClassName];
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
            isRegEnabled = crm.getParam('regularizationProps.isEnabled');
            isJustCheck = crm.getParam('regularizationProps.isJustCheck');
            regTol = crm.getParam('regularizationProps.regTol');
            ControlBounds = struct();
            ControlBounds.center = ptDefCVec;
            ControlBounds.shape = ptDefCMat;
            DistBounds = struct();
            DistBounds.center = qtDefCVec;
            DistBounds.shape = qtDefCMat;
            %
            self.linSys = elltool.linsys.LinSysFactory.create(atDefCMat,...
                btDefCMat, ControlBounds, ctDefCMat, DistBounds);
            self.reachObj = elltool.reach.ReachContinuous(self.linSys,...
                ellipsoid(x0DefVec, x0DefMat), l0Mat, self.timeVec,...
                'isRegEnabled', isRegEnabled,...
                'isJustCheck', isJustCheck,...
                'regTol', regTol);
        end
        %
        function self = testIntersect(self)
            cutReachObj = self.reachObj.cut(self.timeVec(2));
            projCutReachObj =...
                cutReachObj.projection(eye(self.reachObj.dimension()));
            newTimeVec = [sum(self.timeVec) / 2, self.timeVec(2)];
            cutIntReachObj = self.reachObj.cut(newTimeVec);
            cut2ReachObj = cutIntReachObj.cut(newTimeVec(2));
            evolveReachObj = self.reachObj.evolve(self.timeVec(2) + 1);
            cutEvolveReachObj = evolveReachObj.cut(self.timeVec(2) + 1);
            ell1 = ellipsoid([-2.5;1], 1.2 * eye(2));
            ell2 = ellipsoid([-2.5;1], 1.25 * eye(2));
            ell3 = ellipsoid([-2.5;1], 1.3 * eye(2));
            ell4 = ellipsoid([-2.5;1], 0.8 * eye(2));
            ell5 = ellipsoid([-2.5;1], 1.2 * eye(2));
            ell6 = ellipsoid([-2.5;1], 1.6 * eye(2));
            %
            self.checkIntersection(cutReachObj, [ell1, ell2, ell3]);
            self.checkIntersection(projCutReachObj, [ell1, ell2, ell3]);
            self.checkIntersection(cut2ReachObj, [ell1, ell2, ell3]);
            self.checkIntersection(cutEvolveReachObj, [ell4, ell5, ell6]);
        end
        %
        function self = DISABLED_testBackward(self)
            CONF_NAME = 'demo3firstBackTest';
            crm = gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            crmSys =...
                gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            crm.deployConfTemplate(CONF_NAME);
            crm.selectConf(CONF_NAME);
            sysDefConfName = crm.getParam('systemDefinitionConfName');
            crmSys.selectConf(sysDefConfName, 'reloadIfSelected', false);
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
            l0Mat = cell2mat(l0CMat.').';
            timeVec = [crmSys.getParam('time_interval.t1'),...
                crmSys.getParam('time_interval.t0')];
            ControlBounds = struct();
            ControlBounds.center = ptDefCVec;
            ControlBounds.shape = ptDefCMat;
            DistBounds = struct();
            DistBounds.center = qtDefCVec;
            DistBounds.shape = qtDefCMat;
            linSys = elltool.linsys.LinSysFactory.create(atDefCMat, btDefCMat,...
                ControlBounds, ctDefCMat, DistBounds);
            backReachObj = elltool.reach.ReachContinuous(linSys,...
                ellipsoid(x0DefVec, x0DefMat), l0Mat, timeVec);
            isEqual = self.reachObj.isEqual(backReachObj);
            mlunitext.assert_equals(isEqual, true);
        end
    end
end
