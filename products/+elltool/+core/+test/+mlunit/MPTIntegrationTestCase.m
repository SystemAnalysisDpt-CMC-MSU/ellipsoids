classdef MPTIntegrationTestCase < mlunitext.test_case
    % $Author: <Zakharov Eugene>  <justenterrr@gmail.com> $ 
    % $Date: <28 february> $
    % $Copyright: Moscow State University,
    % Faculty of Computational Mathematics and 
    % Computer Science, System Analysis Department <2013> $
    %
    properties (Access=private)
        testDataRootDir
    end
    methods
        function self = MPTIntegrationTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,'TestData',...
                filesep,shortClassName];     
        end
        function tear_down(~)
            close all;
        end
        function self = testDistance(self)  
            [testEll2DVec,testPoly2DVec,testEll60D,testPoly60D,ellArr] = self.genDataDistAndInter();
            %
            absTol =  elltool.conf.Properties.getAbsTol();
            %
            %distance between testEll2DVec(i) and testPoly2Vec(i)
            tesDist1Vec = [2, sqrt(2), 0, 0]; 
            myTestDist(testEll2DVec,testPoly2DVec, tesDist1Vec, absTol);
            %distance between testEll2DVec(1) and testPoly2Vec(1,2)
            tesDist2Vec =  [2, sqrt(2*(3/2 - 1/sqrt(2))^2)];
            myTestDist(testEll2DVec(1),testPoly2DVec(1:2), tesDist2Vec, absTol);
            %distance between testEll2DVec(1,2) and testPoly2Vec(2)            
            tesDist3Vec =  [sqrt(2*(3/2 - 1/sqrt(2))^2), sqrt(2)];
            myTestDist(testEll2DVec(1:2),testPoly2DVec(2), tesDist3Vec, absTol);
            %            
            testDist60D =  sqrt(2*(2-1/sqrt(2))^2);
            myTestDist(testEll60D,testPoly60D, testDist60D, absTol);
            %test if distance(ellArr,poly) works properly, when ellArr -
            %more than two-dimensional ellipsoidal array and poly - single
            %polytope
            distTestArr = zeros(size(ellArr));
            myTestDist(ellArr,testPoly2DVec(4), distTestArr, absTol);
            %
            %no test for dimension mismatch with different dimension of
            %polytopes, becuse polytope class forbid to create vector of
            %polytopes with different dimensions
            self.runAndCheckError('distance(ellArr, testPoly2DVec(1:2))','wrongInput');
            self.runAndCheckError('distance([testEll60D testEll2DVec(1)], testPoly2DVec(1:2))','wrongInput');
            self.runAndCheckError('distance(testEll60D, testPoly2DVec(1:2))','wrongInput');
            %
            %
            function myTestDist(ellVec,polyVec, testDistVec, tol)
                distVec = distance(ellVec,polyVec);
                mlunit.assert(max(distVec - testDistVec) <= tol);
            end
        end
        %
        function self = testIntersect(self)
            [testEll2DVec,testPoly2DVec,testEll60D,testPoly60D,ellArr] = self.genDataDistAndInter();
            %
            %
            isTestInterU2D1 = true;
            isTestInterU2D2 = true;
            isTestInterU2DVec = [false, false, true, true];
            isTestInterI2D = false;
            isTestInterI2DVec = [false, false, true, true];
            isTestInter60D = false;
            isTestInterWitharr = false;
            %
            %
            myTestIntesect(testEll2DVec([1,4]),testPoly2DVec(1),'u',isTestInterU2D1);
            %
            myTestIntesect(testEll2DVec([2,3]),testPoly2DVec(3),'u',isTestInterU2D2);
            %
            myTestIntesect(testEll2DVec([2,3]),testPoly2DVec,'u',isTestInterU2DVec);
            %
            myTestIntesect(testEll2DVec([2,3]),testPoly2DVec(3),'i',isTestInterI2D);
            %
            myTestIntesect(testEll2DVec([4,3]),testPoly2DVec,'i',isTestInterI2DVec);
            %
            myTestIntesect(testEll60D,testPoly60D,'u',isTestInter60D); 
            %            
            myTestIntesect(ellArr,testPoly2DVec(1),'u',isTestInterWitharr); 
            %
            self.runAndCheckError('intersect(testEll60D, testPoly2DVec(1))','wrongInput');
            %
            %Intersection with reach
            reachObj = self.getReach();
            polyVec = [self.makePolytope([0 -1],-1.7),...
                self.makePolytope([0 -1],-1),self.makePolytope([0 -1],0)];
            isTestExtResVec = [false, true,true];
            isTestIntResVec = [false, false,true];
            %
            myTestIntesect(reachObj,polyVec,'e',isTestExtResVec);
            myTestIntesect(reachObj,polyVec,'i',isTestIntResVec);
            %
            function myTestIntesect(objVec, polyVec, letter,isTestInterVec)
                   isInterVec = intersect(objVec,polyVec,letter);
                   mlunit.assert(all(isInterVec == isTestInterVec));
            end 
        end
        %
        function self = testIsInside(self)
            ellConstrMat = eye(2);
            nDims = 15;
            ellConstr15DMat = eye(nDims);
            ellShift1 = [0.05; 0];
            ellShift2 = [0; 4];
            %
            ell1 = ellipsoid(ellConstrMat);
            ell2 = ellipsoid(ellShift1,ellConstrMat);
            ell3 = ellipsoid(ellShift2,ellConstrMat);
            ell15D = ellipsoid(ellConstr15DMat);
            %
            %
            polyConstrMat = [-1 0; 1 0; 0 1; 0 -1];
            polyConstr3DMat = [-1 0 0; 1 0 0; 0 1 0; 0 -1 0; 0 0 1; 0 0 -1];
            polyConstr15DMat = [eye(nDims);-eye(nDims)];
            %
            polyK1Vec = [0; 0.1; 0.1; 0.1];
            polyK2Vec = [0.5; 0.05; sqrt(3)/2; 0];
            polyK3Vec = [1; 0.05; 0.8; 0.8];
            polyK4Vec = [0.5; -0.1; 0.1; 0.1];
            polyK3DVec = 0.1 * ones(6,1);
            polyK15DVec = (1/sqrt(nDims))*ones(nDims*2,1);
            %
            poly1 = self.makePolytope(polyConstrMat,polyK1Vec);
            poly2 = self.makePolytope(polyConstrMat,polyK2Vec);
            poly3 = self.makePolytope(polyConstrMat,polyK3Vec);
            poly4 = self.makePolytope(polyConstrMat,polyK4Vec);
            poly3D = self.makePolytope(polyConstr3DMat,polyK3DVec);
            poly15D = self.makePolytope(polyConstr15DMat,polyK15DVec);
            %
            isTestInsideVec = [1, 0, 1, 1, 1, 0, 1, 0, -1];
            
            self.myTestIsinside(ell1, [poly1, poly2], 'u',isTestInsideVec(1))
            %
            self.myTestIsinside(ell1, [poly1, poly3], 'u',isTestInsideVec(2))
            %
            self.myTestIsinside(ell1, [poly1, poly2], 'i',isTestInsideVec(3))
            %
            self.myTestIsinside(ell1, [poly1, poly3], 'i',isTestInsideVec(4))
            %
            self.myTestIsinside([ell1, ell2], [poly1, poly3], 'i',isTestInsideVec(5))
            %
            self.myTestIsinside([ell1, ell2], [poly1, poly2], 'u',isTestInsideVec(6))
            %
            self.myTestIsinside(ell15D, poly15D, 'u',isTestInsideVec(7))
            %
            self.myTestIsinside([ell1, ell3], poly1, 'u',isTestInsideVec(8))
            %
            self.myTestIsinside(ell1, [poly1, poly4],'i',isTestInsideVec(9))
            %
            self.runAndCheckError('isinside(ell1, poly3D)','wrongSizes');
        end
        %
        %
        function self = testPoly2HypAndHyp2Poly(self)
            polyConstMat = [-1 2 3; 3 4 2; 0 1 2];
            polyKVec = [1; 2; 3];
            testPoly = self.makePolytope(polyConstMat,polyKVec);
            testHyp = hyperplane(polyConstMat',polyKVec');
            hyp = polytope2hyperplane(testPoly);
            mlunit.assert(eq(testHyp,hyp));
            poly = hyperplane2polytope(hyp);
            mlunit.assert(eq(poly,testPoly));
            self.runAndCheckError('hyperplane2polytope(poly)',...
                'wrongInput:class');
            hyp2 = [testHyp, hyperplane([1 2 3 4], 1)];
            self.runAndCheckError('hyperplane2polytope(hyp2)',...
                'wrongInput:dimensions');
            self.runAndCheckError('polytope2hyperplane(hyp)',...
                'wrongInput:class');
            
        end
        
        function self = testIntersectionIA(self)
            ell1 = ellipsoid(eye(3));
            sh2Mat = [1 3 0; 0 0 2; 0 3 1];
            ell2 = ellipsoid(sh2Mat*sh2Mat');
            transfMat = [2 1 0; 1 1 1; 3 8 2];
            sh3Mat = transfMat*transfMat';
            c3Vec = [0.3; 0.2; 0.5];
            ell3 = ellipsoid(c3Vec,sh3Mat);
            %
            depth1 = 1;
            poly1 = elltool.exttbx.gen.tri2polytope(depth1,sh2Mat);
            %
            depth2 = 2;
            poly2 = elltool.exttbx.gen.tri2polytope(depth2,sh2Mat);
            %
            %intersection with unit ball
            EXP_MAX_TOL1 = 0.05;
            myTestIntersectionIA(ell1,ell2,poly1,poly2,EXP_MAX_TOL1)
            %intersection with ellipsoid with different center
            EXP_MAX_TOL2 = 0.25;
            myTestIntersectionIA(ell3,ell2,poly1,poly2,EXP_MAX_TOL2)
            %ellipsoid lies in polytope
            ell4 = ellipsoid(eye(2));
            poly4 = self.makePolytope([eye(2); -eye(2)], ones(4,1));
            ellPolyIA5 = intersection_ia(ell4,poly4);
            mlunit.assert(eq(ell4,ellPolyIA5));
            %
            %polytope lies in ellipsoid
            ell5 = ellipsoid(eye(2));
            poly5 = self.makePolytope([eye(2); -eye(2)], 1/4*ones(4,1));
            expEll = ellipsoid(1/16*eye(2));
            ellPolyIA5 = intersection_ia(ell5,poly5);
            mlunit.assert(eq(expEll,ellPolyIA5));
            %
            %test if internal approximation is really internal
            c6Vec =  [0.8913;0.7621;0.4565;0.0185;0.8214];
            sh6Mat = [ 1.0863 0.4281 1.0085 1.4706 0.6325;...
                       0.4281 0.5881 0.9390 1.1156 0.6908;...
                       1.0085 0.9390 2.2240 2.3271 1.7218;...
                       1.4706 1.1156 2.3271 2.9144 1.6438;...
                       0.6325 0.6908 1.7218 1.6438 1.6557];    
            ell6 = ellipsoid(c6Vec, sh6Mat);
            poly6 = self.makePolytope(eye(5),c6Vec);
            ellPolyIA6 = intersection_ia(ell6,poly6);
            mlunit.assert(isinside(ell6,ellPolyIA6) && self.isEllInsidePolytope(poly6,ellPolyIA6));
            %
            sh7Mat = [1.1954 0.3180 1.3183; 0.3180 0.2167 0.5039; 1.3183 0.5039 1.6320];
            ell7 = ellipsoid(sh7Mat);
            poly7 = self.makePolytope([1 1 1], 0.2);
            ellPolyIA7 = intersection_ia(ell7,poly7);
            mlunit.assert(isinside(ell7,ellPolyIA7) && self.isEllInsidePolytope(poly7,ellPolyIA7));
            %
            %test if internal approximation is an empty ellipsoid, when
            %ellipsoid and polytope aren't intersect
            ell8 = ellipsoid(eye(2));
            poly8 = self.makePolytope([1 1], -sqrt(2));
            ellPolyIA8 = intersection_ia(ell8,poly8);
            [~,ellPoly8Mat] = double(ellPolyIA8);
            mlunit.assert(all(ellPoly8Mat(:) == 0));
            %
            %
            function myTestIntersectionIA(ell1,ell2,triEll2,triEll2n2,expTol)
                ellEllIA = intersection_ia(ell1,ell2);
                ellPolyIA1 = intersection_ia(ell1,triEll2);
                ellPolyIA2 = intersection_ia(ell1,triEll2n2);
                %
                [isEq, reportStr] = ellEllIA.eq(ellPolyIA1,expTol);
                mlunit.assert(isEq, reportStr);
                %                
                [isEq2, reportStr2] = ellEllIA.eq(ellPolyIA2,expTol);
                mlunit.assert(isEq2, reportStr2);
                %
                [ellEllVec ellEllMat] = double(ellEllIA);
                [ellPoly1Vec ellPoly1Mat] = double(ellPolyIA1);
                [ellPoly2Vec ellPoly2Mat] = double(ellPolyIA2);                
                tol1 = norm(ellEllVec - ellPoly1Vec) + norm(ellEllMat - ellPoly1Mat);
                tol2 = norm(ellEllVec - ellPoly2Vec) + norm(ellEllMat - ellPoly2Mat);
                mlunit.assert(tol2 < tol1);
           end
        end
        %
        %
        function self = testIntersectionEA(self)
            %Analitically proved, that minimal volume ellipsoid, covering
            %intersection of ell1 and poly1 is ell1.            
            defaultShMat = eye(2);
            ell1 = ellipsoid(defaultShMat);
            defaultPolyMat = [0 1];
            defaultPolyConst = 0.25;
            poly1 = self.makePolytope(defaultPolyMat,defaultPolyConst);
            ellEA1 = intersection_ea(ell1,poly1);
            mlunit.assert(eq(ell1,ellEA1));
            %
            %If we apply same linear tranform to both ell1 and poly1, than
            %minimal volume ellipsoid shouldn't change.
            transfMat =  [1 3; 2 2];
            shiftVec = [1; 1];
            transfShMat = transfMat*(transfMat)';
            ell2 = ellipsoid(shiftVec,transfShMat);
            poly2 = self.makePolytope(defaultPolyMat/(transfMat),...
                defaultPolyConst+(defaultPolyMat/(transfMat))*shiftVec);
            ellEA2 = intersection_ea(ell2,poly2);
            mlunit.assert(eq(ell2,ellEA2));
            %
            %Checking, that amount of constraints in polytope does not
            %affect accuracy of computation of external approximation
            nConstr = 100;
            angleVec = (0:2*pi/nConstr:2*pi*(1-1/nConstr))';
            hMat = [cos(angleVec), sin(angleVec)];
            kVec = ones(nConstr,1);
            polyManyConstr = self.makePolytope(hMat,kVec);
            ellEAManyConstr = intersection_ea(ell1,polyManyConstr);
            mlunit.assert(eq(ell1,ellEAManyConstr));
            %
            %First example, but for nDims
            nDims = 10;
            shNMat = eye(nDims);
            ellN = ellipsoid(shNMat);
            polyNMat = [1, zeros(1,nDims-1)];
            polyNConst = 1/(2*nDims);
            polyN = self.makePolytope(polyNMat,polyNConst);
            ellEAN = intersection_ea(ellN,polyN);
            mlunit.assert(eq(ellN,ellEAN));
            %
            transfNMat =  [0.8913 0.1763 0.1389 0.4660 0.8318 0.1509 0.8180 0.3704 0.1730 0.2987;...
            0.7621 0.4057 0.2028 0.4186 0.5028 0.6979 0.6602 0.7027 0.9797 0.6614;...
            0.4565 0.9355 0.1987 0.8462 0.7095 0.3784 0.3420 0.5466 0.2714 0.2844;...
            0.0185 0.9169 0.6038 0.5252 0.4289 0.8600 0.2897 0.4449 0.2523 0.4692;...
            0.8214 0.4103 0.2722 0.2026 0.3046 0.8537 0.3412 0.6946 0.8757 0.0648;...
            0.4447 0.8936 0.1988 0.6721 0.1897 0.5936 0.5341 0.6213 0.7373 0.9883;...
            0.6154 0.0579 0.0153 0.8381 0.1934 0.4966 0.7271 0.7948 0.1365 0.5828;...
            0.7919 0.3529 0.7468 0.0196 0.6822 0.8998 0.3093 0.9568 0.0118 0.4235;...
            0.9218 0.8132 0.4451 0.6813 0.3028 0.8216 0.8385 0.5226 0.8939 0.5155;...
            0.7382 0.0099 0.9318 0.3795 0.5417 0.6449 0.5681 0.8801 0.1991 0.3340];
            %
            shiftNVec = [1; -1; zeros(nDims-2,1)];
            %
            transfShNMat = transfNMat*(transfNMat)';
            ellN2 = ellipsoid(shiftNVec,transfShNMat);
            polyN2 = self.makePolytope(polyNMat/(transfNMat),...
                polyNConst+(polyNMat/(transfNMat))*shiftNVec);
            ellEA2 = intersection_ea(ellN2,polyN2);
            mlunit.assert(eq(ellN2,ellEA2));
        end
    end
    %
    methods(Static)
         %
         function myTestIsinside(ellVec,polyVec,letter,isInsideTest)
                isInsideVec = isinside(ellVec,polyVec,letter);
                mlunit.assert(all(isInsideVec == isInsideTest));
         end
         %
         %
         function poly = makePolytope(constrMat,constrValVec)
             Q = struct('H',constrMat,'K',constrValVec);
             poly = polytope(Q);
         end
         %
         function res = isEllInsidePolytope(poly,ell)
             [constrMat constrValVec] = double(poly);
             [shiftVec shapeMat] = double(ell);
             suppFuncVec = zeros(size(constrValVec));
             [nRows, ~] = size(constrValVec);
             absTol = getAbsTol(ell);
             for iRows = 1:nRows
                 suppFuncVec(iRows) = constrMat(iRows,:)*shiftVec + sqrt(constrMat(iRows,:)*shapeMat*constrMat(iRows,:)');
             end
             res = all(suppFuncVec <= constrValVec+absTol);
         end
         %
         function [testEll2DVec,testPoly2DVec,testEll60D,testPoly60D,ellArr] = genDataDistAndInter()
             testEll2DVec(4) = ellipsoid(16*eye(2));
             testEll2DVec(3) = ellipsoid([1.25 -0.75; -0.75 1.25]);
             testEll2DVec(2) = ellipsoid([1.25 0.75; 0.75 1.25]);
             testEll2DVec(1) = ellipsoid(eye(2));
             %
             testPoly2DVec = [polytope(struct('H',[-1 0; 1 0; 0 1; 0 -1], 'K',[-3; 4; 1; 1])),...
                 polytope(struct('H',[1 0; -1 0; 0 1; 0 -1], 'K',[2.5; -1.5; -1.5; 100])),...
                 polytope(struct('H',[1 -1; -1 1; -1 0; 0 1], 'K',[-2; 2.5; 2; 2])),...
                 polytope(struct('H',[1 0; -1 0; 0 1; 0 -1], 'K',[1; 0; 1; 0]))];
             testEll60D = ellipsoid(eye(60));
             h60D = [eye(60); -eye(60)];
             h60D(121,:) = [-1 1 zeros(1,58)];
             k60D = [4; 0; ones(58,1); 0; 4; ones(58,1); -4];
             testPoly60D = polytope(struct('H',h60D,'K',k60D));
             for i = 2:-1:1
                for j = 2:-1:1
                    for k = 2:-1:1
                        ellArr(i,j,k) = ellipsoid(eye(2));
                    end
                end
            end
         end
         %
         function reachObj = getReach()
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
            linSys = elltool.linsys.LinSysFactory.create(atDefCMat, btDefCMat,...
                ControlBounds, ctDefCMat, DistBounds);
            fullReachObj = elltool.reach.ReachContinuous(linSys,...
                ellipsoid(x0DefVec, x0DefMat), l0Mat, timeVec);
            reachObj = fullReachObj.cut(timeVec(2));
         end
    end
end
