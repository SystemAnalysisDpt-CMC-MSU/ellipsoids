classdef MPTIntegrationTestCase < mlunitext.test_case
    % $Author: <Zakharov Eugene>  <justenterrr@gmail.com> $ 
    % $Date: <may> $
    % $Copyright: Moscow State University,
    % Faculty of Computational Mathematics and 
    % Computer Science, System Analysis Department <2013> $
    %
    methods
        function self = MPTIntegrationTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function self = testIntersect(self)
            %intersection with polytope
            myReachObj = self.getReach();
            polyVec = [polytope([0 -1],-1.7),...
                polytope([0 -1],-1),polytope([0 -1],0)];
            isTestExtResVec = [false, true,true];
            isTestIntResVec = [false, false,true];
            %
            myTestIntesect(myReachObj,polyVec,'e',isTestExtResVec);
            myTestIntesect(myReachObj,polyVec,'i',isTestIntResVec);
            %
            function myTestIntesect(objVec, polyVec, letter,isTestInterVec)
                   isInterVec = intersect(objVec,polyVec,letter);
                   mlunitext.assert(all(isInterVec == isTestInterVec));
            end 
        end
        function reachObj = getReach(self)
            crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            confName = 'demo3firstTest';
            crm.deployConfTemplate(confName);
            crm.selectConf(confName);
            sysDefConfName = crm.getParam('systemDefinitionConfName');
            crmSys.selectConf(sysDefConfName, 'reloadIfSelected', false);
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
            timeVec = [crmSys.getParam('time_interval.t0'),...
                crmSys.getParam('time_interval.t1')];
            ControlBounds = struct();
            ControlBounds.center = ptDefCVec;
            ControlBounds.shape = ptDefCMat;
            DistBounds = struct();
            DistBounds.center = qtDefCVec;
            DistBounds.shape = qtDefCMat;
            linSys = elltool.linsys.LinSysFactory.create(atDefCMat, ...
                btDefCMat,ControlBounds, ctDefCMat, DistBounds);
            fullReachObj = elltool.reach.ReachContinuous(linSys,...
                ellipsoid(x0DefVec, x0DefMat), l0Mat, timeVec);
            reachObj = fullReachObj.cut(timeVec(2));
        end
    end
end
