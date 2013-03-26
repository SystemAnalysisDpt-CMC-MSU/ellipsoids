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
            self.runAndCheckError('distance(ellArr, testPoly2DVec(1:2))','sizeMismatch');
            self.runAndCheckError('distance(testEll60D, testPoly2DVec(1:2))','dimensionMismatch');
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
            self.runAndCheckError('intersect(testEll60D, testPoly2DVec(1))','dimensionMismatch');
            %
            %
            function myTestIntesect(ellVec, polyVec, letter,isTestInterVec)
                   isInterVec = intersect(ellVec,polyVec,letter);
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
            poly1 = self.triToPolytope(depth1,sh2Mat);
            %
            depth2 = 2;
            poly2 = self.triToPolytope(depth2,sh2Mat);
            %
            %intersection with unit ball
            testDiffNorm = 0.05;
            myTestIntersectionIA(ell1,ell2,poly1,poly2,testDiffNorm)
            %intersection with ellipsoid with different center
            testDiffNorm2 = 0.25;
            myTestIntersectionIA(ell3,ell2,poly1,poly2,testDiffNorm2)
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
            [~,ellPoly8Mat] = double(ellPolyIA8);
            mlunit.assert(all(ellPoly8Mat(:) == 0));
            %
            %
            function myTestIntersectionIA(ell1,ell2,triEll2,triEll2n2,testDiffNorm)
                ellEllIA = intersection_ia(ell1,ell2);
                ellPolyIA1 = intersection_ia(ell1,triEll2);
                ellPolyIA2 = intersection_ia(ell1,triEll2n2);
                [ellEllVec ellEllMat] = double(ellEllIA);
                [ellPoly1Vec ellPoly1Mat] = double(ellPolyIA1);
                [ellPoly2Vec ellPoly2Mat] = double(ellPolyIA2);
                diffNorm1 = norm(ellEllVec - ellPoly1Vec) + norm(ellEllMat - ellPoly1Mat);
                mlunit.assert(diffNorm1 <= testDiffNorm);
                diffNorm2 = norm(ellEllVec - ellPoly2Vec) + norm(ellEllMat - ellPoly2Mat);
                mlunit.assert(diffNorm2 < diffNorm1);
           end
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
         %
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
    end
end

function checkHypEqual(testFstHypArr, testSecHypArr, isEqualArr, ansStr)
    [isEqArr, reportStr] = eq(testFstHypArr, testSecHypArr);
    mlunit.assert_equals(isEqArr, isEqualArr);
    mlunit.assert_equals(reportStr, ansStr);
end
