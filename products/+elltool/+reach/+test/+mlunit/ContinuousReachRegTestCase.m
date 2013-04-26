classdef ContinuousReachRegTestCase < mlunitext.test_case
    properties (Access=private)
        confName
        crm
        crmSys
        linSys
        x0Ell
        l0Mat
        timeVec
        calcPrecision
        regTol
    end
    %
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
    %
    methods
        function self = ContinuousReachRegTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
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
            self.crmSys.selectConf(sysDefConfName,...
                'reloadIfSelected', false);
            %
            [atDefCMat, btDefCMat, ctDefCMat, ptDefCMat,...
                ptDefCVec, qtDefCMat, qtDefCVec,...
                x0DefMat, x0DefVec, self.l0Mat] = self.getSysParams();
            %
            self.x0Ell = ellipsoid(x0DefVec, x0DefMat);
            % bad direction (if without regularization):
            self.timeVec = [self.crmSys.getParam('time_interval.t0'),...
                self.crmSys.getParam('time_interval.t1')];
            self.calcPrecision =...
                self.crm.getParam('genericProps.calcPrecision');
            self.regTol =...
                self.crm.getParam('regularizationProps.regTol');
            ControlBounds = struct();
            ControlBounds.center = ptDefCVec;
            ControlBounds.shape = ptDefCMat;
            DistBounds = struct();
            DistBounds.center = qtDefCVec;
            DistBounds.shape = qtDefCMat;
            self.linSys = elltool.linsys.LinSysFactory.create(atDefCMat,...
                btDefCMat, ControlBounds, ctDefCMat, DistBounds);
        end
        %
        function self = testRegularization(self)
            linSys = self.linSys.getCopy();
            x0Ell = self.x0Ell.getCopy();
            l0Mat = self.l0Mat;
            timeVec = self.timeVec;
            regTol = self.regTol;
            self.runAndCheckError(...
                ['elltool.reach.ReachContinuous(linSys, x0Ell,',...
                'l0Mat, timeVec)'],...
                'GRAS:LA:ISMATPOSDEF:wrongInput:nonSymmMat');
            %
            self.runAndCheckError(...
                ['elltool.reach.ReachContinuous(linSys, x0Ell, l0Mat,',...
                'timeVec, ''isRegEnabled'',',...
                'true, ''isJustCheck'', true)'],...
                'MODGEN:COMMON:CHECKVAR:wrongInput');
            %
            elltool.reach.ReachContinuous(linSys, x0Ell, l0Mat, timeVec,...
                'isRegEnabled', true,...
                'isJustCheck', false,...
                'regTol', regTol);
        end
    end
    
end