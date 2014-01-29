classdef ContinuousReachRegTestCase < mlunitext.test_case
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
            [self.atDefCMat, self.btDefCMat, self.ctDefCMat, ptDefCMat,...
                ptDefCVec, qtDefCMat, qtDefCVec,...
                x0DefMat, x0DefVec, self.l0Mat] = self.getSysParams();
            %
            self.x0Ell = ellipsoid(x0DefVec, x0DefMat);
            self.timeVec = [self.crmSys.getParam('time_interval.t0'),...
                self.crmSys.getParam('time_interval.t1')];
            self.calcPrecision =...
                self.crm.getParam('genericProps.calcPrecision');
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
            x0Ell = self.x0Ell.getCopy();
            l0Mat = self.l0Mat;
            timeVec = self.timeVec;
            regTol = self.regTol;
            atDefCMat = self.atDefCMat;
            btDefCMat = self.btDefCMat;
            %ctDefCMat = self.ctDefCMat;
            ctDefCMat = [1;0];
            DistBounds = struct();
            DistBounds.shape = {'0.09*(sin(t))^2'};
            DistBounds.center = {'2*cos(t)'};
            %%
            linSys = elltool.linsys.LinSysFactory.create(...
                atDefCMat, zeros(size(btDefCMat)));
            check(false,false,regTol,...
                'MAKEELLTUBEREL:wrongInput:regProblem:RegIsDisabled:degenerateControlBounds');            
            %%
%            ControlBoundsTest = 100 * ellipsoid(eye(2));            
%            linSys = elltool.linsys.LinSysFactory.create(...
%                atDefCMat, btDefCMat, ControlBoundsTest);
            %
            %check(true,false,0.01,'MAKEELLTUBEREL:wrongInput:BadCalcPrec')
            %%
            ControlBounds = self.ControlBounds;            
            linSys = elltool.linsys.LinSysFactory.create(atDefCMat,...
                btDefCMat, ControlBounds, ctDefCMat, DistBounds);
            check(false,false,regTol,...
                'MAKEELLTUBEREL:wrongInput:regProblem:RegIsDisabled')            
            %%
            check(true,true,regTol,...
                'MAKEELLTUBEREL:wrongInput:regProblem:onlyCheckIsEnabled');              
            %%
            x0Ell = 1e-2 * ell_unitball(2);
            badRegTol = 1e-1;
            check(true,false,badRegTol,'',false);
            %
            badRegTol = 1e-4;
            check(true,false,badRegTol,...
                'MAKEELLTUBEREL:wrongInput:regProblem:regTolIsTooLow');            
            %%
%            badODE45RegTol = 1e-3;
%            check(true,false,badODE45RegTol,...
%                'MAKEELLTUBEREL:wrongInput:regProblem:regTolIsTooLow:Ode45Failed');              
            %%
            x0Ell = 0* ell_unitball(2);
            check(false,false,regTol,...
                'MAKEELLTUBEREL:wrongInput:BadInitSet');              
            %%
            x0Ell = self.x0Ell.getCopy();
            check(true,false,regTol*10,'',false);
            %
            function check(isRegEnabled,isJustCheck,regTol,expErrTag,isNeg)
                if nargin<5
                    isNeg=true;
                end
                inpArgList={linSys, x0Ell,...
                    l0Mat, timeVec,'isRegEnabled',isRegEnabled,...
                    'isJustCheck',isJustCheck,'regTol',regTol}; %#ok<NASGU>
                %
                evalStr='elltool.reach.ReachContinuous(inpArgList{:})';
                if isNeg
                    self.runAndCheckError(evalStr,expErrTag);
                else
                    evalc(evalStr);
                end
            end
        end
    end
    
end