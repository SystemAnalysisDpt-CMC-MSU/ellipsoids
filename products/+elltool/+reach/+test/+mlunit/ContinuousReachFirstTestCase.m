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
        l0Mat
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
            self.l0Mat = cell2mat(l0CMat.').';
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
                ellipsoid(x0DefVec, x0DefMat), self.l0Mat, self.timeVec,...
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
        function self = testBackward(self)
            TOL_MUL = 1e-3;
            absTol = TOL_MUL*self.reachObj.getAbsTol();
            relTol = TOL_MUL*self.reachObj.getRelTol();
            
            t0 = self.timeVec(1);
            t1 = self.timeVec(2);
            
            x0Ell = self.reachObj.getInitialSet();
            l1Mat = getDirsMatAt(self.reachObj, t1);
            iaCutAtT1EllVec = getEllCut(self.reachObj, t1, 'ia');
            eaCutAtT1EllVec = getEllCut(self.reachObj, t1, 'ea');
            
            mlunitext.assert_equals(numel(iaCutAtT1EllVec),...
                numel(eaCutAtT1EllVec),...
                ['Size of internal and external approximations ',...
                 'is different']);
            
            for iElem = 1:numel(iaCutAtT1EllVec)
                eaEllAtT1 = iaCutAtT1EllVec(iElem);
                iaEllAtT1 = eaCutAtT1EllVec(iElem);
                
                backReachEaObj = elltool.reach.ReachContinuous(self.linSys,...
                    eaEllAtT1, l1Mat, [t1 t0]);
                backReachIaObj = elltool.reach.ReachContinuous(self.linSys,...
                    iaEllAtT1, l1Mat, [t1 t0]);
                
                solvEaCutAtT0EllVec = getEllCut(backReachEaObj, t0, 'ea');
                isX0Inside = all( x0Ell.isInside(solvEaCutAtT0EllVec) );
                mlunitext.assert(isX0Inside,...
                    'Solvability set from EA does not cover X0');
                
                solvIaCutAtT0EllVec = getEllCut(backReachIaObj, t0, 'ea');
                isIntersectX0 = intersect(solvIaCutAtT0EllVec, x0Ell, 'i');
                mlunitext.assert(isIntersectX0,...
                    'Solvability set from IA does not intersect X0');
                
                l0BackMat = getDirsMatAt(backReachIaObj, t0);
                isDirsT0Equal = modgen.common.absrelcompare(self.l0Mat,...
                    l0BackMat, absTol, relTol, @norm);
                mlunitext.assert(isDirsT0Equal,...
                    'Directions are not consistent');
                
                %check that the intersection contains support function
                %maximizer for each direction
                for jDirElem = 1:size(self.l0Mat, 2)
                    curl0Vec = self.l0Mat(:,jDirElem);
                    checkIntersectionContainMaximizer(x0Ell, ...
                        solvIaCutAtT0EllVec, curl0Vec)
                end
            end
        end
        
    end
end

function checkIntersectionContainMaximizer(x0Ell, eaEllVec, dirVec)
    [~, boundVec] = rho(x0Ell, dirVec);
    isInternal = isinternal(eaEllVec, boundVec, 'i');
    mlunitext.assert(isInternal,...
        ['Intersection of X0 and solvability set (from IA) ',...
         'does not contain maximizer of X0 support function']);
end

function outEllVec = getEllCut(obj, t, type)
    if strcmp(type, 'ia')
        [allEllMat, timeVec] = obj.cut(t).get_ia();
    else
        [allEllMat, timeVec] = obj.cut(t).get_ea();
    end
    mlunitext.assert(any(timeVec == t));
    outEllVec = allEllMat(:, timeVec == t);
end

function dirsMat = getDirsMatAt(reachObj, t)
    [dirsCVec, timeVec] = reachObj.get_directions();
    
    indVec = find(timeVec == t);
    mlunitext.assert_equals(numel(indVec), 1);
    
    dirsCMat = cellfun(@(d) d(:,indVec), dirsCVec, 'UniformOutput', false);
    dirsMat = [dirsCMat{:}];
end