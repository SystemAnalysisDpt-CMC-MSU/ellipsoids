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
            mlunit.assert(isInterI2D == isTestInterI2D);
            isInterI2DVec = intersect(testEll2DVec([4,3]),testPoly2DVec,'i');
            mlunit.assert(all(isInterI2DVec == isTestInterI2DVec));
            isInter60D = intersect(testEll60D,testPoly60D);
            mlunit.assert(isTestInter60D == isInter60D);
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
            
            isInside = isinside(ell1, [poly1, poly2], 'u');
            mlunit.assert(all(isTestInsideVec(1) == isInside));
            isInside = isinside(ell1, [poly1, poly3], 'u');
            mlunit.assert(all(isTestInsideVec(2) == isInside));
            isInside = isinside(ell1, [poly1, poly2], 'i');
            mlunit.assert(all(isTestInsideVec(3) == isInside));
            isInside = isinside(ell1, [poly1, poly3], 'i');
            mlunit.assert(all(isTestInsideVec(4) == isInside));
            isInside = isinside([ell1, ell2], [poly1, poly3], 'i');
            mlunit.assert(all(isTestInsideVec(5) == isInside));
            isInside = isinside([ell1, ell2], [poly1, poly2], 'u');
            mlunit.assert(all(isTestInsideVec(6) == isInside));
            isInside = isinside(ell15D, poly15D);
            mlunit.assert(all(isTestInsideVec(7) == isInside));
            isInside = isinside([ell1, ell3], poly1);
            mlunit.assert(all(isTestInsideVec(8) == isInside));
            isInside = isinside(ell1, [poly1, poly4],'i');
            mlunit.assert(all(isTestInsideVec(9) == isInside));
            %
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
            poly1 = self.triToPolytope(depth1,sh2Mat);
            %
            depth2 = 2;
            poly2 = self.triToPolytope(depth2,sh2Mat);
            %
            %intersection with unit ball
            ellEllIA1 = intersection_ia(ell1,ell2);
            ellPolyIA1 = intersection_ia(ell1,poly1);
            ellPolyIA2 = intersection_ia(ell1,poly2);
            [ellEllVec ellEllMat] = double(ellEllIA1);
            [ellPoly1Vec ellPoly1Mat] = double(ellPolyIA1);
            [ellPoly2Vec ellPoly2Mat] = double(ellPolyIA2);
            %
            testDiffNorm = 0.05;
            diffNorm1 = norm(ellEllVec - ellPoly1Vec) + norm(ellEllMat - ellPoly1Mat);
            mlunit.assert(diffNorm1 <= testDiffNorm);
            diffNorm2 = norm(ellEllVec - ellPoly2Vec) + norm(ellEllMat - ellPoly2Mat);
            mlunit.assert(diffNorm2 < diffNorm1);
            %
            %intersection with ellipsoid with different center
            ellEllIA2 = intersection_ia(ell3,ell2);
            ellPolyIA3 = intersection_ia(ell3,poly1);
            ellPolyIA4 = intersection_ia(ell3,poly2);
            [ellEll2Vec ellEll2Mat] = double(ellEllIA2);
            [ellPoly3Vec ellPoly3Mat] = double(ellPolyIA3);
            [ellPoly4Vec ellPoly4Mat] = double(ellPolyIA4);
            %
            testDiffNorm2 = 0.25;
            diffNorm3 = norm(ellEll2Vec - ellPoly3Vec) + norm(ellEll2Mat - ellPoly3Mat);
            mlunit.assert(diffNorm3 <= testDiffNorm2);
            diffNorm4 = norm(ellEll2Vec - ellPoly4Vec) + norm(ellEll2Mat - ellPoly4Mat);
            mlunit.assert(diffNorm4 < diffNorm3);
            %
            %ellipsoid lies in polytope
            ell4 = ellipsoid(eye(2));
            absTol = getAbsTol(ell4);
            poly4 = self.makePolytope([eye(2); -eye(2)], ones(4,1));
            ellPolyIA5 = intersection_ia(ell4,poly4);
            [ellPoly5Vec ellPoly5Mat] = double(ellPolyIA5);
            mlunit.assert(norm(ellPoly5Vec) + norm(ellPoly5Mat-eye(2)) <= absTol);
            %
            %polytope lies in ellipsoid
            ell5 = ellipsoid(eye(2));
            absTol = getAbsTol(ell5);
            poly5 = self.makePolytope([eye(2); -eye(2)], 1/4*ones(4,1));
            ellPolyIA5 = intersection_ia(ell5,poly5);
            [ellPoly5Vec ellPoly5Mat] = double(ellPolyIA5);
            mlunit.assert(norm(ellPoly5Vec) + norm(ellPoly5Mat-1/16*eye(2)) <= absTol);
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
            mlunit.assert(isempty(ellPolyIA8));
        end
        
        function self = testIntersectionEA(self)
            ell1 = ellipsoid(eye(2));
            poly1 = self.makePolytope([-1 0],0.9);
            ellEA1 = intersection_ea(ell1, poly1);
            [cVec1 shMat1] = double(ellEA1);
            tol = 50*getAbsTol(ell1);
            mlunit.assert(norm(cVec1) + norm(shMat1 - eye(2)) <= nconstr(poly1)*tol);
            transfMat = [1 3; 3 2];
            shiftVec = [1; 0];
            ell2 = ellipsoid(-shiftVec,transfMat*transfMat');
            poly2 = self.makePolytope([-1 0]/transfMat,0.9 + [-1 0]*shiftVec);
            ellEA2 = intersection_ea(ell2, poly2);
            [cVec2 shMat2] = double(ellEA2);
            mlunit.assert(norm(cVec2+shiftVec) + norm(shMat2 - transfMat*transfMat') <= nconstr(poly2)*tol);
        end
    end
    %
    methods(Static)
         function SInpData = auxReadFile(self)
            inpFileName=[self.testDataRootDir,filesep,['test_inp.mat']];
            %
            SInpData = load(inpFileName);
         end
         
         function poly = makePolytope(H,K)
             Q = struct('H',H,'K',K);
             poly = polytope(Q);
         end
         
         function poly = triToPolytope(depth,transfMat)
            [vMat,fMat]=gras.geom.tri.spheretri(depth);
            nFaces = size(fMat,1);
            normMat = zeros(3,nFaces);
            constVec = zeros(1,nFaces);
            for iFaces = 1:nFaces
                normMat(:,iFaces) = (cross(vMat(fMat(iFaces,3),:) - vMat(fMat(iFaces,2),:),vMat(fMat(iFaces,3),:) - vMat(fMat(iFaces,1),:)))';
                constVec(iFaces) = vMat(fMat(iFaces,3),:)*normMat(:,iFaces);
                if constVec(iFaces) < 0
                    constVec(iFaces) = -constVec(iFaces);
                     normMat(:,iFaces) = - normMat(:,iFaces);
                end
            end
            normMat = normMat'/(transfMat);%normMat = normMa*inv(transfMat)
            poly = polytope(struct('H',normMat,'K',constVec'));
         end
         
         function res = isEllInsidePolytope(poly,ell)
             [H K] = double(poly);
             [shiftVec shapeMat] = double(ell);
             suppFuncVec = zeros(size(K));
             [nRows, ~] = size(K);
             absTol = getAbsTol(ell);
             for iRows = 1:nRows
                 suppFuncVec(iRows) = H(iRows,:)*shiftVec + sqrt(H(iRows,:)*shapeMat*H(iRows,:)');
             end
             res = all(suppFuncVec <= K+absTol);
         end
    end
end

function checkHypEqual(testFstHypArr, testSecHypArr, isEqualArr, ansStr)
    [isEqArr, reportStr] = eq(testFstHypArr, testSecHypArr);
    mlunit.assert_equals(isEqArr, isEqualArr);
    mlunit.assert_equals(reportStr, ansStr);
end
