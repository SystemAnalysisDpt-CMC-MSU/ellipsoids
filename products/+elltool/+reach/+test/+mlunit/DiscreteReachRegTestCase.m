classdef DiscreteReachRegTestCase < mlunitext.test_case
    properties (Access=private)
        confName
        crm
        crmSys
        linSys
        atDefCMat
        btDefCMat
        ctDefCMat
        ControlBounds
        DistBounds
        x0Ell
        l0Mat
        timeVec
        absTol
        relTol
        regTol
        ellFactoryObj
        testReachObjFactory
    end
    %
    methods
        function ellObj = ellipsoid(self, varargin)
            ellObj = self.ellFactoryObj.createInstance('ellipsoid', ...
                varargin{:});            
        end
        %
        function reachObj = reachDiscrete(self, varargin)
            reachObj = self.testReachObjFactory.createInstance(...
                'reachDiscrete', varargin{:});            
        end
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
        function self = DiscreteReachRegTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up_param(self, confName, crm, crmSys)
            self.ellFactoryObj = elltool.core.test.mlunit.TEllipsoidFactory();
            self.testReachObjFactory = ...
                    elltool.reach.test.mlunit.TReachObjFactory();
            %
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
            [self.atDefCMat, self.btDefCMat, self.ctDefCMat, ptDefCMat,...
                ptDefCVec, qtDefCMat, qtDefCVec,...
                x0DefMat, x0DefVec, self.l0Mat] = self.getSysParams();
            %
            self.x0Ell = self.ellipsoid(x0DefVec, x0DefMat);
            self.timeVec = [self.crmSys.getParam('time_interval.t0'),...
                self.crmSys.getParam('time_interval.t1')];
            self.absTol =...
                self.crm.getParam('genericProps.absTol');
            self.relTol =...
                self.crm.getParam('genericProps.relTol');            
            self.regTol =...
                self.crm.getParam('regularizationProps.regTol');
            self.ControlBounds = struct();
            self.ControlBounds.center = ptDefCVec;
            self.ControlBounds.shape = ptDefCMat;
            self.DistBounds = struct();
            self.DistBounds.center = qtDefCVec;
            self.DistBounds.shape = qtDefCMat;
        end
        %
        function self = testRegularization(self)
            x0Ell = self.x0Ell.getCopy(); %#ok<*PROP>
            l0Mat = self.l0Mat;
            timeVec = self.timeVec;
            regTol = self.regTol; %#ok<NASGU>
            atDefCMat = self.atDefCMat;
            btDefCMat = self.btDefCMat;
            ControlBounds = self.ControlBounds;
            %
            %% 1
            btDefCMat = {'sin(t - 1)' 'sin(t - 1)'; 'sin(t - 1)' 'sin(t - 1)'; ...
                'sin(t - 1)' 'sin(t - 1)'; 'sin(t - 1)' 'sin(t - 1)'};
            timeVec = [0 5];
            ControlBoundsTest = self.ellipsoid(eye(2));
            linSys = elltool.linsys.LinSysDiscrete(...
                atDefCMat, btDefCMat, ControlBounds);
            self.runAndCheckError(...
                ['self.reachDiscrete(linSys, x0Ell,',...
                'l0Mat, timeVec, ''isRegEnabled'', true, ',...
                '''isJustCheck'', true, ''regTol'', regTol)'],...
                'MAKEELLTUBEREL:wrongInput:regProblem:onlyCheckIsEnabled');
            %
            %% 2 OVERFLOW
            self.runAndCheckError(@runBad2,...
                {'MAKEELLTUBEREL:wrongInput:ShapeMatCalcFailure',...
                'MATLAB:realsqrt:complexResult'});
            %
            %% 3 DEGRADED ESTIMATE, DEGRADED INITIAL SET
            self.runAndCheckError(@runBad3,...
                'MAKEELLTUBEREL:wrongInput:degradedEstimate');
            %
            function runBad3()%degraded estimate
                btDefCMat = self.btDefCMat;
                ctDefMat=diag([0 1 1 1]);
                timeVec = [0 1];
                ControlBoundsTest = self.ellipsoid(eye(2));
                l0Mat=eye(4);
                vVec=ones(4,1);
                linSys = elltool.linsys.LinSysDiscrete(...
                    atDefCMat, btDefCMat, ControlBoundsTest,ctDefMat,...
                    vVec);
                x0Ell=self.ellipsoid(diag([0 1 1 1]));
                %
                self.reachDiscrete(linSys, x0Ell,...
                    l0Mat, timeVec);
            end
                %
            function runBad2()%overflow
                btDefCMat = self.btDefCMat;
                timeVec = [0 50];
                ControlBoundsTest = self.ellipsoid(eye(2));
                linSys = elltool.linsys.LinSysDiscrete(...
                    atDefCMat, btDefCMat, ControlBounds);
                self.reachDiscrete(linSys, x0Ell,...
                    l0Mat, timeVec, 'isRegEnabled', false,...
                    'isJustCheck', false, 'regTol', 1e-5);
            end
        end
    end
    
end