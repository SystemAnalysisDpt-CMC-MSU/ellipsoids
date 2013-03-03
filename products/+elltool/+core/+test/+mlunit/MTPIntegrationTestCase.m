classdef MTPIntegrationTestCase < mlunitext.test_case
    % $Author: <Zakharov Eugene>  <justenterrr@gmail.com> $    $Date: <28 february> $
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department <2013> $
    %
    properties (Access=private)
        testDataRootDir
    end
    methods
        function self = MTPIntegrationTestCase(varargin)
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
            %
            SInpData =  self.auxReadFile(self);
            testEll2DVec = SInpData.testEll2DVec;
            testPoly2DVec = SInpData.testPoly2DVec;
            testEll60D = SInpData.testEll60D;
            testPoly60 = SInpData.testPoly60D;
            %
            %distance between testEll2DVec(i) and testPoly2Vec(i)
            tesDist1Vec = [2, sqrt(2), 0, 0]; 
            %distance between testEll2DVec(1) and testPoly2Vec(1,2)
            tesDist2Vec =  [2, sqrt(2*(3/2 - 1/sqrt(2))^2)];
            %distance between testEll2DVec(1,2) and testPoly2Vec(2)            
            tesDist3Vec =  [sqrt(2*(3/2 - 1/sqrt(2))^2), sqrt(2)];
            %            
            testDist60D =  sqrt(2*(2-1/sqrt(2))^2);
            %
            absTol =  elltool.conf.Properties.getAbsTol();
            %
            %
            distVec1 = distance(testEll2DVec,testPoly2DVec);
            mlunit.assert(max(distVec1 - tesDist1Vec) <= absTol);
            %            
            distVec2 = distance(testEll2DVec(1),testPoly2DVec(1:2));
            mlunit.assert(max(distVec2 - tesDist2Vec) <= absTol);
            %
            distVec3 = distance(testEll2DVec(1:2),testPoly2DVec(2));
            mlunit.assert(max(distVec3 - tesDist3Vec) <= absTol);
            %
            dist60D = distance(testEll60D,testPoly60);
            mlunit.assert(max(dist60D - testDist60D) <= absTol);
            %
            %error test
        end
        %
        function self = testIntersect(self)
            SInpData =  self.auxReadFile(self);
            testEll2DVec = SInpData.testEll2DVec;
            testPoly2DVec = SInpData.testPoly2DVec;
            testEll60D = SInpData.testEll60D;
            testPoly60D = SInpData.testPoly60D;
            
            isTestInterU2D1 = true;
            isTestInterU2D2 = true;
            isTestInterU2DVec = [false, false, true, true];
            isTestInterI2D = false;
            isTestInterI2DVec = [false, false, true, true];
            isTestInter60D = false;
            
            isInterU2D1 = intersect(testEll2DVec([1,4]),testPoly2DVec(1),'u');
            mlunit.assert(isTestInterU2D1 == isInterU2D1);
            isInterU2D2 = intersect(testEll2DVec([2,3]),testPoly2DVec(3),'u');
            mlunit.assert(isInterU2D2 == isTestInterU2D2);
            isInterU2DVec = intersect(testEll2DVec([2,3]),testPoly2DVec,'u');
            mlunit.assert(all(isInterU2DVec == isTestInterU2DVec));
            isInterI2D = intersect(testEll2DVec([2,3]),testPoly2DVec(3),'i');
            plot(testEll2DVec([2,3]));
            hold on;
            plot(testPoly2DVec(3));
            mlunit.assert(isInterI2D == isTestInterI2D);
            isInterI2DVec = intersect(testEll2DVec([4,3]),testPoly2DVec,'i');
            mlunit.assert(all(isInterI2DVec == isTestInterI2DVec));
            isInter60D = intersect(testEll60D,testPoly60D);
            mlunit.assert(isTestInter60D == isInter60D);
        end
        %
        function self = testIsInside(self)
            ellConstrMat = eye(2);
            ellConstr60DMat = eye(60);
            ellShift1 = [0.05; 0];
            ellShift2 = [0; 4];
            %
            ell1 = ellipsoid(ellConstrMat);
            ell2 = ellipsoid(ellShift1,ellConstrMat);
            ell3 = ellipsoid(ellShift2,ellConstrMat);
            ell60D = ellipsoid(ellConstr60DMat);
            %
            %
            polyConstrMat = [-1 0; 1 0; 0 1; 0 -1];
            polyConstr3DMat = [-1 0 0; 1 0 0; 0 1 0; 0 -1 0; 0 0 1; 0 0 -1];
            polyConstr60DMat = [eye(60);-eye(60)];
            %
            polyK1Vec = [0; 0.1; 0.1; 0.1];
            polyK2Vec = [0.5; 0.05; sqrt(3)/2; 0];
            polyK3Vec = [1; 0.05; 0.8; 0.8];
            polyK4Vec = [0.5; -0.1; 0.1; 0.1];
            polyK3DVec = 0.1 * ones(6,1);
            polyK60DVec = (1/sqrt(2))*ones(120,1);
            %
            poly1 = self.makePolytope(polyConstrMat,polyK1Vec);
            poly2 = self.makePolytope(polyConstrMat,polyK2Vec);
            poly3 = self.makePolytope(polyConstrMat,polyK3Vec);
            poly4 = self.makePolytope(polyConstrMat,polyK4Vec);
            poly3D = self.makePolytope(polyConstr3DMat,polyK3DVec);
            poly60D = self.makePolytope(polyConstr60DMat,polyK60DVec);
            %
            isTestInsideVec = [true, false, true, true, true, false, true, false, true];
            isInsideVec = false(1,9);
            isInsideVec(1) = isinside(ell1, [poly1, poly2], 'u');
            isInsideVec(2) = isinside(ell1, [poly1, poly3], 'u');
            isInsideVec(3) = isinside(ell1, [poly1, poly2], 'i');
            isInsideVec(4) = isinside(ell1, [poly1, poly3], 'i');
            isInsideVec(5) = isinside([ell1, ell2], [poly1, poly3], 'i');
            isInsideVec(6) = isinside([ell1, ell2], [poly1, poly2], 'u');
            isInsideVec(7) = isinside(ell60D, poly60D);
            isInsideVec(8) = isinside([ell1, ell3], poly1);
            isInsideVec(9) = isinside(ell1, [poly1, poly4]);
            %
            mlunit.assert(all(isTestInsideVec == isInsideVec)); 
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
    end
    %
    methods(Static, Access = private)
         function SInpData = auxReadFile(self)
            inpFileName=[self.testDataRootDir,filesep,['test_inp.mat']];
            %
            SInpData = load(inpFileName);
         end
         
         function poly = makePolytope(H,K)
             Q = struct('H',H,'K',K);
             poly = polytope(Q);
         end
    end
end

function checkHypEqual(testFstHypArr, testSecHypArr, isEqualArr, ansStr)
    [isEqArr, reportStr] = eq(testFstHypArr, testSecHypArr);
    mlunit.assert_equals(isEqArr, isEqualArr);
    mlunit.assert_equals(reportStr, ansStr);
end
