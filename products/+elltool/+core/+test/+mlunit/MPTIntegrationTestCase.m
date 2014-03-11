classdef MPTIntegrationTestCase < mlunitext.test_case
    % $Author: <Zakharov Eugene>  <justenterrr@gmail.com> $
    % $Date: <28 february> $
    % $Copyright: Moscow State University,
    % Faculty of Computational Mathematics and
    % Computer Science, System Analysis Department <2013> $
    %
    
    methods
        
        function self = MPTIntegrationTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function tear_down(~)
            close all;
        end
        function self = testDistance(self)
            [testEll2DVec,testPoly2DVec,testEll60D,testPoly60D,ellArr] =...
                self.genDataDistAndInter();
            %
            absTol =  elltool.conf.Properties.getAbsTol();
            %
            %distance between testEll2DVec(i) and testPoly2Vec(i)
            tesDist1Vec = [2, sqrt(2), 0, 0];
            myTestDist(testEll2DVec,testPoly2DVec, tesDist1Vec, absTol);
            %distance between testEll2DVec(1) and testPoly2Vec(1,2)
            tesDist2Vec =  [2, sqrt(2*(3/2 - 1/sqrt(2))^2)];
            myTestDist(testEll2DVec(1),testPoly2DVec(1:2), tesDist2Vec,...
                absTol);
            %distance between testEll2DVec(1,2) and testPoly2Vec(2)
            tesDist3Vec =  [sqrt(2*(3/2 - 1/sqrt(2))^2), sqrt(2)];
            myTestDist(testEll2DVec(1:2),testPoly2DVec(2), tesDist3Vec,...
                absTol);
            %
            testDist60D =  sqrt(2*(2-1/sqrt(2))^2);
            myTestDist(testEll60D,testPoly60D, testDist60D,...
                absTol);
            %test if distance(ellArr,poly) works properly, when ellArr -
            %more than two-dimensional ellipsoidal array and poly - single
            %polytope
            distTestArr = zeros(size(ellArr));
            myTestDist(ellArr,testPoly2DVec(4), distTestArr, absTol);
            %
            %no test for dimension mismatch with different dimension of
            %polytopes, becuse polytope class forbid to create vector of
            %polytopes with different dimensions
            self.runAndCheckError('distance(ellArr, testPoly2DVec(1:2))',...
                'wrongInput');
            self.runAndCheckError(strcat('distance([testEll60D, ',...
                'testEll2DVec(1)], testPoly2DVec(1:2))'),'wrongInput');
            self.runAndCheckError(strcat('distance(testEll60D,',...
                ' testPoly2DVec(1:2))'),'wrongInput');
            %
            %
            function myTestDist(ellVec,polyVec, testDistVec, tol)
                distVec = distance(ellVec,polyVec);
                mlunitext.assert(max(distVec - testDistVec) <= tol);
            end
        end
        %
        function self = testIntersect(self)
            [testEll2DVec,testPoly2DVec,testEll60D,testPoly60D,ellArr] =...
                self.genDataDistAndInter();
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
            myTestIntesect(testEll2DVec([1,4]),testPoly2DVec(1),'u',...
                isTestInterU2D1);
            %
            myTestIntesect(testEll2DVec([2,3]),testPoly2DVec(3),'u',...
                isTestInterU2D2);
            %
            myTestIntesect(testEll2DVec([2,3]),testPoly2DVec,'u',...
                isTestInterU2DVec);
            %
            myTestIntesect(testEll2DVec([2,3]),testPoly2DVec(3),'i',...
                isTestInterI2D);
            %
            myTestIntesect(testEll2DVec([4,3]),testPoly2DVec,'i',...
                isTestInterI2DVec);
            %
            myTestIntesect(testEll60D,testPoly60D,'u',isTestInter60D);
            %
            myTestIntesect(ellArr,testPoly2DVec(1),'u',isTestInterWitharr);
            %
            self.runAndCheckError(strcat('intersect(testEll60D,',...
                ' testPoly2DVec(1))'),'wrongInput');
            %
            function myTestIntesect(objVec, polyVec, letter,isTestInterVec)
                isInterVec = intersect(objVec,polyVec,letter);
                mlunitext.assert(all(isInterVec == isTestInterVec));
            end
        end
        %
        function self = testDoesIntersectionContain(self)
            ellConstrMat = eye(2);
            nDims = 14;
            ellConstr15DMat = eye(nDims);
            ellShift1 = [0.05; 0];
            ellShift2 = [0; 4];
            %
            ell1 = ellipsoid(ellConstrMat);
            ell2 = ellipsoid(ellShift1,ellConstrMat);
            ell3 = ellipsoid(ellShift2,ellConstrMat);
            ell14D = ellipsoid(ellConstr15DMat);
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
            polyK5Vec = [2; -0.3; 0.3; 0];
            polyK6Vec = [1.5; -0.6; 0.6; 0];
            polyK3DVec = 0.1 * ones(6,1);
            polyK15DVec = (1/sqrt(nDims))*ones(nDims*2,1);
            %
            poly1 = polytope(polyConstrMat,polyK1Vec);
            poly2 = polytope(polyConstrMat,polyK2Vec);
            poly3 = polytope(polyConstrMat,polyK3Vec);
            poly4 = polytope(polyConstrMat,polyK4Vec);
            poly5 = polytope(polyConstrMat,polyK5Vec);
            poly6 = polytope(polyConstrMat,polyK6Vec);
            poly3D = polytope(polyConstr3DMat,polyK3DVec);
            poly14D = polytope(polyConstr15DMat,polyK15DVec);
            %
            isExpVec = [1, 0, 1, 1, 1, 0, 1, 0, -1, 0, 1, 0];
            
            self.myTestIsCII(ell1, [poly1, poly2], 'u',isExpVec(1),true,...
                'no')
            %
            self.myTestIsCII(ell1, [poly1, poly3], 'u',isExpVec(2),true,...
                'no')
            %
            self.myTestIsCII(ell1, [poly1, poly2], 'i',isExpVec(3),true,...
                'no')
            %
            self.myTestIsCII(ell1, [poly1, poly3], 'i',isExpVec(4),true,...
                'no')
            %
            self.myTestIsCII([ell1, ell2], [poly1, poly3], 'i',...
                isExpVec(5),true,'no')
            %
            self.myTestIsCII([ell1, ell2], [poly1, poly2], 'u',...
                isExpVec(6),true,'no')
            %
            self.myTestIsCII([ell1, ell3], poly1, 'u',isExpVec(8),false,...
                'no')
            %
            self.myTestIsCII(ell1, [poly1, poly4],'i',isExpVec(9),false,...
                'no')
            %
            self.myTestIsCII(ell1, [poly1, poly2, poly3],'u',...
                isExpVec(10),true,'no')
            %
            self.myTestIsCII([ell1,ell2], [poly3, poly5, poly2],'i',...
                isExpVec(11),true,'no')
            %
            self.myTestIsCII(ell2, [poly3, poly5, poly6],'i',...
                isExpVec(12),true,'no')
            %
            self.runAndCheckError(strcat('doesIntersectionContain',...
                '(ell1, poly3D)'),'wrongSizes');
            %
            nDims2 = 9;
            ell9D = ellipsoid(eye(nDims2));
            poly9D = polytope([eye(nDims2); -eye(nDims2)],ones(2*nDims2,1)/...
                sqrt(nDims2));
            self.myTestIsCII(ell9D, poly9D, 'u',isExpVec(7),true,'low')
            self.myTestIsCII(ell14D, poly14D, 'u',isExpVec(7),true,'high')
        end
        %
        function self = testPoly2HypAndHyp2Poly(self)
            polyConstMat = [-1 2 3; 3 4 2; 0 1 2];
            polyKVec = [1; 2; 3];
            testPoly = polytope(polyConstMat,polyKVec);
            testHyp = hyperplane(polyConstMat',polyKVec');
            hyp = polytope2hyperplane(testPoly);
            mlunitext.assert(eq(testHyp,hyp));
            poly = hyperplane2polytope(hyp);
            mlunitext.assert(eq(poly,testPoly));
            self.runAndCheckError('hyperplane2polytope(poly)',...
                'wrongInput:class');
            hyp2 = [testHyp, hyperplane([1 2 3 4], 1)];
            self.runAndCheckError('hyperplane2polytope(hyp2)',...
                'wrongInput:dimensions');
            self.runAndCheckError('polytope2hyperplane(hyp)',...
                'wrongInput:class');
            
        end
        %
        %
        function self = testIntersectionIA(self)
           import elltool.exttbx.mpt.gen.*;
            %ELLIPSOID AND POLYTOPE
            %ellipsoid lies in polytope
            my1Ell = ellipsoid(eye(2));
            my1Poly = polytope([eye(2); -eye(2)], ones(4,1));
            my1EllPolyIAObj = intersection_ia(my1Ell,my1Poly);
            [isOk, reportStr] = my1Ell.isEqual(my1EllPolyIAObj);
            mlunitext.assert(isOk, reportStr);
            %
            %polytope lies in ellipsoid
            my2Ell = ellipsoid(eye(2));
            my2Poly = polytope([eye(2); eye(2)], 1/4*ones(4,1));
            myExpectedEll = ellipsoid([-0.362623; -0.362623],[0.375307 -0.13955;-0.13955 0.375307]);
            my2EllPolyIAObj = intersection_ia(my2Ell,my2Poly);
            [isOk, reportStr] = myExpectedEll.isEqual(my2EllPolyIAObj);
            mlunitext.assert(isOk, reportStr);
            %
            %test if internal approximation is really internal
            my3EllVec =  [0.8913;0.7621;0.4565;0.0185;0.8214];
            my3EllMat = [ 1.0863 0.4281 1.0085 1.4706 0.6325;...
                       0.4281 0.5881 0.9390 1.1156 0.6908;...
                       1.0085 0.9390 2.2240 2.3271 1.7218;...
                       1.4706 1.1156 2.3271 2.9144 1.6438;...
                       0.6325 0.6908 1.7218 1.6438 1.6557];    
            my3Ell = ellipsoid(my3EllVec, my3EllMat);
            my3Poly = polytope(eye(5),my3EllVec);
            my3EllPolyIAObj = intersection_ia(my3Ell,my3Poly);
            mlunitext.assert(doesIntersectionContain(my3Ell,my3EllPolyIAObj) &&...
                isInside(my3EllPolyIAObj,my3Poly));
            %
            my4EllMat = [1.1954 0.3180 1.3183; 0.3180 0.2167 0.5039;...
                1.3183 0.5039 1.6320];
            my4Ell = ellipsoid(my4EllMat);
            my4Poly = polytope([1 1 1], 0.2);
            my4EllPolyIAObj = intersection_ia(my4Ell,my4Poly);
            mlunitext.assert(doesIntersectionContain(my4Ell,my4EllPolyIAObj) &&...
                isInside(my4EllPolyIAObj,my4Poly));
            %
            %test if internal approximation is a point, when
            %the ellipsoid touches the polytope 
            my5Ell = ellipsoid(eye(2));
            my5Poly = polytope([1 1], -sqrt(2));
            my5EllPolyIAObj = intersection_ia(my5Ell,my5Poly);
            [~,my5EllPolyIAObjMat] = double(my5EllPolyIAObj);
            mlunitext.assert(all(my5EllPolyIAObjMat(:) == 0));
            %
            %test if internal approximation is an empty ellpsoid,
            %when the polytope and the ellipsoid do not intersect
            my6Ell = ellipsoid(eye(2));
            my6Poly = [-1;-1]+polytope([1 1], -sqrt(2));
            my6EllPolyIAObj = intersection_ia(my6Ell,my6Poly);
            mlunitext.assert(isEmpty(my6EllPolyIAObj));
        end
        %
        %
        function self = testNegativeIntersectionIA(self)
            my1Ell = ellipsoid(zeros(2));
            my2Ell = ellipsoid(eye(2));
            self.runAndCheckError('my1Ell.intersection_ia(my2Ell)',...
                'wrongInput:shapeMat');
            my3Ell = ellipsoid([2 1; 1 0.5]);
            self.runAndCheckError('my3Ell.intersection_ia(my2Ell)',...
                'wrongInput:shapeMat');
            my4Ell = ellipsoid;
            self.runAndCheckError('my2Ell.intersection_ia(my4Ell)',...
                'wrongSizes');
            self.runAndCheckError('my4Ell.intersection_ia(my2Ell)',...
                'wrongSizes');
        end
        
        
         function self = testNegativeIntersectionEA(self)
            my1Ell = ellipsoid(eye(2));
            my2Ell = ellipsoid;
            self.runAndCheckError('my1Ell.intersection_ea(my2Ell)',...
                'wrongSizes');
            self.runAndCheckError('my2Ell.intersection_ea(my1Ell)',...
                'wrongSizes');
         end
        
        
        function self = testIntersectionIAForEll(self)
            %test for internal approximation of intersection
            %of two ellipsoids
            %
            %test if the second ellipsoid lies in the first
            my11Ell = ellipsoid(eye(2));
            my12Ell = [0.5; 0]+ellipsoid(0.2*eye(2));
            my1EllEllIAObj = my11Ell.intersection_ia(my12Ell);
            [isOk, reportStr] = my12Ell.isEqual(my1EllEllIAObj);
            mlunitext.assert(isOk, reportStr);
            %
            %the same for nDims
            nDims=10;
            my2CentVec=[0.5; zeros(nDims-1, 1)];
            my21Ell=ellipsoid(2*eye(nDims));
            my22Ell=my2CentVec+ellipsoid(0.5*eye(nDims));
            my2EllEllIAObj=intersection_ia(my21Ell, my22Ell);
            [isOk, reportStr] = my22Ell.isEqual(my2EllEllIAObj);
            mlunitext.assert(isOk, reportStr);
            %
            %test if internal approximation is really internal
            my31Ell = ellipsoid([0; 1; 0], eye(3));
            my32Ell = ellipsoid([1; 0; 0], eye(3));
            my3EllEllIAObj = my31Ell.intersection_ia(my32Ell);
            myEllVec = [my31Ell my32Ell];
            mlunitext.assert(myEllVec.doesIntersectionContain(my3EllEllIAObj));
            %
            %test if internal approximation is a point, when
            %the first ellipsoid touches the second
            eps=1e-8;
            my41Ell = ellipsoid(0.5*eye(2));
            my42Ell = [1;1]+ellipsoid(0.5*eye(2));
            my4EllEllIAObj = my41Ell.intersection_ia(my42Ell);
            [~,my4EllEllIAObjMat] = double(my4EllEllIAObj);
            mlunitext.assert(all(my4EllEllIAObjMat(:) < eps));
            %
            %test if internal approximation is an empty ellpsoid,
            %when the ellipsoids do not intersect
            my51Ell = ellipsoid(0.5*eye(2));
            my52Ell = [2;2]+ellipsoid(0.5*eye(2));
            my5EllEllIAObj = my51Ell.intersection_ia(my52Ell);
            mlunitext.assert(isEmpty(my5EllEllIAObj))
            %
            %test when the second ellipsoid is a point
            my61Ell = ellipsoid(eye(2));
            my62Ell = ellipsoid(zeros(2));
            my6EllEllIAObj = my61Ell.intersection_ia(my62Ell);
            [~,my6EllEllIAObjMat] = double(my6EllEllIAObj);
            mlunitext.assert(all(my6EllEllIAObjMat(:) == 0));
            %
            %test when a shape matrix is a multidimensional array           
            checkIAShMatArrayEll([2,2,3]);
            checkIAShMatArrayEll([5,5,1,3]);
            %
            %test for arrays of ellipsoids
            checkIAEllArray([2,1,2]);
            checkIAEllArray([2,3,1,5]);
            %
            function checkIAShMatArrayEll(dimsShMatArrayVec)
                %checks if the intersection of multi-dimensional ellipsoid
                %and ellipsoid is really internal
                [myMultiDimEllArray, mCount, ~] = constructEllForTests(dimsShMatArrayVec);
                myEll = ellipsoid(eye(mCount));
                myMultiDimEllArrayEllIAObj = myMultiDimEllArray.intersection_ia(myEll);
                mlunitext.assert(myEll.doesIntersectionContain(myMultiDimEllArrayEllIAObj));
            end
            function checkIAEllArray(dimsEllArrayVec)
                %checks if the intersection of two arrays of ellipsoids
                %is equal to the second array
                [my1EllArray, my2EllArray]=construct2EllArraysForTests(dimsEllArrayVec);
                myEllEllArrayIAObj = my1EllArray.intersection_ia(my2EllArray);
                [isOk, reportStr] = my2EllArray.isEqual(myEllEllArrayIAObj);
                mlunitext.assert(isOk, reportStr);
            end
        end
        %
        %
        function self = testIntersectionIAForHyper(self)
            %test for internal approximation of intersection
            %of an ellipsoid and a hyperplane
            %
            %ellipsoid lies in halfspace
            my1Ell = ellipsoid(eye(2));
            my1Hyper = hyperplane([1;1], 3);
            my1EllHyperIAObj = my1Ell.intersection_ia(my1Hyper);
            [isOk, reportStr] = my1Ell.isEqual(my1EllHyperIAObj);
            mlunitext.assert(isOk, reportStr)
            %
            %test if internal approximation is an empty ellipsoid, when
            %ellipsoid doesn't lie in the halfspace
            my2Ell = ellipsoid(eye(2));
            my2Hyper = hyperplane([-1;-1], -3);
            my2EllHyperIAObj = intersection_ia(my2Ell, my2Hyper);
            [~,my2EllHyperIAObjMat] = double(my2EllHyperIAObj);
            mlunitext.assert(my2EllHyperIAObjMat == [])
            %
            %halfspace intersects an ellpsoid
            my3Ell = ellipsoid(eye(3));
            my3Hyper = hyperplane([-1;1;1], 1);
            my3EllHyperIAObj = my3Ell.intersection_ia(my3Hyper);
            mlunitext.assert(my3Ell.doesIntersectionContain(my3EllHyperIAObj));
            %
            %the same for nDims
            nDims=10;
            my4Vec = ones(nDims, 1);
            my4Ell = ellipsoid(2*eye(nDims));
            my4Hyper = hyperplane(my4Vec, 1);
            myEllHyperIAObj=intersection_ia(my4Ell, my4Hyper);
            mlunitext.assert(my4Ell.doesIntersectionContain(myEllHyperIAObj));
            %
            %test when a shape matrix is a multidimensional array
            checkIAShMatArrayEll([2,2]);
            checkIAShMatArrayEll([2,2,1,4]); 
            %
            %test for an array of ellipsoids
            checkIAEllArray([3,2]);
            checkIAEllArray([2,1,3,2]);
            %
            function checkIAShMatArrayEll(dimsShMatArrayVec)
                %checks if the intersection of multi-dimensional ellipsoid
                %and hyperplane is really internal
                [myMultiDimEllArray, mCount, ~] = constructEllForTests(dimsShMatArrayVec);
                myHyper = hyperplane((-1)*ones(mCount,1), 1);
                myMultiDimEllArrayHyperIAObj = myMultiDimEllArray.intersection_ia(myHyper);
                mlunitext.assert(myMultiDimEllArrayHyperIAObj.isInside(myMultiDimEllArray));
            end
            function checkIAEllArray(dimsEllArrayVec)
                %checks if the intersection of array of ellipsoids
                %and hyperplane is really internal
                myEllArray=constructEllArrayForTests(dimsEllArrayVec);
                myHyper=hyperplane(ones([2,dimsEllArrayVec]));
                myEllHyperArrayIAObj = myEllArray.intersection_ia(myHyper);
                mlunitext.assert(myEllHyperArrayIAObj.isInside(myEllArray));
            end
        end
        %
        %
        function self = testIntersectionEA(self)
            %ELLIPSOID AND POLYTOPE
            %analitically proved, that minimal volume ellipsoid, covering
            %intersection of my1Ell and my1Poly is my1Ell.
            my1Ell = ellipsoid(eye(2));
            my1PolyMat = [0 1];
            my1PolyConst = 0.25;
            my1Poly = polytope(my1PolyMat,my1PolyConst);
            my1EllPolyEAObj = intersection_ea(my1Ell,my1Poly);
            [isOk, reportStr] = my1Ell.isEqual(my1EllPolyEAObj);
            mlunitext.assert(isOk, reportStr);
            %
            %if we apply same linear tranform to both my1Ell and my1Poly, than
            %minimal volume ellipsoid shouldn't change.
            my2Mat =  [1 3; 2 2];
            my2Vec = [1; 1];
            my2TransfMat = my2Mat*(my2Mat)';
            my2Ell = ellipsoid(my2Vec,my2TransfMat);
            my2Poly = polytope(my1PolyMat/(my2Mat),...
                my1PolyConst+(my1PolyMat/(my2Mat))*my2Vec);
            my2EllPolyEAObj = intersection_ea(my2Ell,my2Poly);
            [isOk, reportStr] = my2Ell.isEqual(my2EllPolyEAObj);
            mlunitext.assert(isOk, reportStr);
            %
            %checking, that amount of constraints in polytope does not
            %affect accuracy of computation of external approximation
            nConstr = 100;
            angleVec = (0:2*pi/nConstr:2*pi*(1-1/nConstr))';
            my3PolyMat = [cos(angleVec), sin(angleVec)];
            my3PolyVec = ones(nConstr,1);
            my3Poly = polytope(my3PolyMat,my3PolyVec);
            my3EllPolyEAObj = intersection_ea(my1Ell,my3Poly);
            [isOk, reportStr] = my1Ell.isEqual(my3EllPolyEAObj);
            mlunitext.assert(isOk, reportStr);
            %
            %first example, but for nDims
            nDims = 10;
            my4Ell = ellipsoid(eye(nDims));
            my4PolyMat = [1, zeros(1,nDims-1)];
            my4PolyConst = 1/(2*nDims);
            my4Poly = polytope(my4PolyMat,my4PolyConst);
            my4EllPolyEAObj = intersection_ea(my4Ell,my4Poly);
            [isOk, reportStr] = my4Ell.isEqual(my4EllPolyEAObj);
            mlunitext.assert(isOk, reportStr);
            %
            my5Mat =  [0.8913 0.1763 0.1389 0.4660 0.8318 0.1509 0.8180 0.3704 0.1730 0.2987;...
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
            my5Vec = [1; -1; zeros(nDims-2,1)];
            %
            my5TransfMat = my5Mat*(my5Mat)';
            my5Ell = ellipsoid(my5Vec,my5TransfMat);
            my5Poly = polytope(my4PolyMat/(my5Mat),...
                -(my4PolyConst+(my4PolyMat/(my5Mat))*my5Vec));
            my5EllPolyEAObj = intersection_ea(my5Ell,my5Poly);
            [isOk, reportStr] = my5Ell.isEqual(my5EllPolyEAObj);
            mlunitext.assert(isOk, reportStr);
        end
        %
        %
        function self = testIntersectionEAForEll(self)
            %test for external approximation of intersection
            %of two ellipsoids
            %
            %analitically proved, that minimal volume ellipsoid, covering
            %intersection of my11Ell and my12Ell is my11Ell.
            my11ShMat = eye(2);
            my12ShMat = 0.5*eye(2);
            my11CentVec = [0;0];
            my12CentVec = [0.5;0];
            my11Ell = ellipsoid(my11CentVec, my11ShMat);
            my12Ell = ellipsoid(my12CentVec, my12ShMat);
            my1EllEllEAObj = my11Ell.intersection_ea(my12Ell);
            [isOk, reportStr] = my12Ell.isEqual(my1EllEllEAObj);
            mlunitext.assert(isOk, reportStr)
            %if we apply same linear tranform to both my11Ell and my12Ell, than
            %minimal volume ellipsoid shouldn't change.
            my2TransfMat = [1 2; 3 3];
            my2CentVec = [1; 2];
            my21Ell = ellipsoid(my2CentVec, my2TransfMat*my2TransfMat');
            my22Ell = ellipsoid(my2TransfMat*my12CentVec + my2CentVec,...
            my2TransfMat*my12ShMat*my2TransfMat');
            my2EllEllEAObj = my21Ell.intersection_ea(my22Ell);
            [isOk, reportStr] = my22Ell.isEqual(my2EllEllEAObj);
            mlunitext.assert(isOk, reportStr)
            %for 3 dims analitically proved, that minimal volume ellipsoid,
            %covering intersection of my31Ell and my32Ell, is my33Ell
            my31Ell = ellipsoid(eye(3));
            my32Ell = ellipsoid([1; 0; 0], eye(3));
            myExpectedEll = ellipsoid([0.5; 0; 0], 0.75*eye(3));
            my3EllEllEAObj = my31Ell.intersection_ea(my32Ell);
            [isOk, reportStr] = myExpectedEll.isEqual(my3EllEllEAObj);
            mlunitext.assert(isOk, reportStr)
            %
            %one more example for nDims
            nDims = 3;
            my4Mat = [1 3 1;...
                      7 5 7;...
                      1 3 0];
            my4ShMat = my4Mat'*my4Mat;
            my41Ell = ellipsoid(my4ShMat);
            my42Ell = ellipsoid(0.5*eye(nDims));
            my4EllEllEAObj = my41Ell.intersection_ea(my42Ell);
            [isOk, reportStr] = my42Ell.isEqual(my4EllEllEAObj);
            mlunitext.assert(isOk, reportStr);
            %
            %test if one of the ellipsoids is a point
            my51Ell = ellipsoid(zeros(2));
            my52Ell = ellipsoid(eye(2));
            my5EllEllIAObj = my51Ell.intersection_ea(my52Ell);
            [~,my5EllEllIAObjMat] = double(my5EllEllIAObj);
            mlunitext.assert(all(my5EllEllIAObjMat(:) == 0));
            my5EllEllIAObj = my52Ell.intersection_ea(my51Ell);
            [~,my5EllEllIAObjMat] = double(my5EllEllIAObj);
            mlunitext.assert(all(my5EllEllIAObjMat(:) == 0));
            %
            %test when a shape matrix is a multidimensional array
            checkEAShMatArrayEll([2,2]);
            checkEAShMatArrayEll([2,2,1,4]);
            %
            %test for an array of ellipsoids
            checkEAEllArray([2,1,3]);
            checkEAEllArray([2,3,2,4]);
            %
            function checkEAShMatArrayEll(dimsShMatArrayVec)
                %checks if the intersection of multi-dimensional ellipsoid
                %and ellipsoid is equal to the second ellipsoid
                [myMultiDimEllArray, mCount, nDelta] = constructEllForTests(dimsShMatArrayVec);
                myEll = [-1+nDelta; zeros(mCount-1,1)] + ellipsoid(.5*eye(mCount));
                myMultiDimEllArrayEllEAObj = myMultiDimEllArray.intersection_ea(myEll);
                [isOk, reportStr] = myEll.isEqual(myMultiDimEllArrayEllEAObj);
                mlunitext.assert(isOk, reportStr);
            end
            function checkEAEllArray(dimsEllArrayVec)
                %checks if the intersection of two arrays of ellipsoids
                %is equal to the second array
                [my1EllArray, my2EllArray]=construct2EllArraysForTests(dimsEllArrayVec);
                myEllEllArrayEAObj = my1EllArray.intersection_ea(my2EllArray);
                [isOk, reportStr] = my2EllArray.isEqual(myEllEllArrayEAObj);
                mlunitext.assert(isOk, reportStr);
            end
            
        end
        %
        %
        function self = testIntersectionEAForHyper(self)
            %test for external approximation of intersection
            %of an ellipsoid and a hyperplane
            %
            %ellipsoid lies in halfspace
            my1Ell = ellipsoid([-5;2;1],eye(3));
            my1Hyper = hyperplane([1;1;0], 1);
            my1EllHyperEAObj = my1Ell.intersection_ea(my1Hyper);
            [isOk, reportStr] = my1Ell.isEqual(my1EllHyperEAObj);
            mlunitext.assert(isOk, reportStr)
            %analitically proved, that minimal volume ellipsoid, covering
            %intersection of ell3 and hyp3 is ell3.
            my2Ell = ellipsoid([-2;2],eye(2));
            my2Hyper = hyperplane([1;1], 1);
            my2EllHyperEAObj = my2Ell.intersection_ea(my2Hyper);
            [isOk, reportStr] = my2Ell.isEqual(my2EllHyperEAObj);
            mlunitext.assert(isOk, reportStr)
            %
            %the same for nDims
            nDims=10;
            my3Vec = ones(nDims, 1);
            my3Ell = ellipsoid(eye(nDims));
            my3Hyper = hyperplane(my3Vec, 1);
            my3EllHyperEAObj = my3Ell.intersection_ea(my3Hyper);
            [isOk, reportStr] = my3Ell.isEqual(my3EllHyperEAObj);
            mlunitext.assert(isOk, reportStr)
            %3
            %test when a shape matrix is a multidimensional array
            checkEAShMatArrayEll([2,2,1]);
            checkEAShMatArrayEll([2,2,2,3]);            %
            %
            %test for an array of ellipsoids
            checkEAEllArray([2,4]);
            checkEAEllArray([2,3,3,5]);
            %
            function checkEAShMatArrayEll(dimsShMatArrayVec)
                %checks if an intersection of multi-dimensional ellipsoid
                %and hyperplane is empty
                [myMultiDimEllArray, mCount, ~] = constructEllForTests(dimsShMatArrayVec);
                myHyper = hyperplane([1;zeros(mCount-1,1)], -5);
                myMultiDimEllArrayHyperEAObj = myMultiDimEllArray.intersection_ea(myHyper);
                mlunitext.assert(isEmpty(myMultiDimEllArrayHyperEAObj))
            end
            function checkEAEllArray(dimsEllArrayVec)
                %checks if the intersection of array of ellipsoids
                %and hyperplane is equal to the array
                myEllArray=constructEllArrayForTests(dimsEllArrayVec);
                myHyper=hyperplane(ones([2,dimsEllArrayVec]), 3);
                myEllHyperArrayEAObj = myEllArray.intersection_ea(myHyper);
                [isOk, reportStr] = myEllArray.isEqual(myEllHyperArrayEAObj);
                mlunitext.assert(isOk, reportStr);
            end

        end
        %
        %
        function self = testIsInside(self)
            ellVec = ellipsoid.fromRepMat(eye(2),[1,3]);
            polyVec = [polytope([1,0],1), polytope([0, 1],2),...
                polytope([1 0],0)];
            isExpRes = true;
            isExpRes1Vec = [true, true, false];
            isExpRes2Vec = [false, false, false];
            %
            %
            myTestIsInside(ellVec(1),polyVec(1),isExpRes);
            %
            myTestIsInside(ellVec,polyVec,isExpRes1Vec);
            %
            myTestIsInside(ellVec(1),polyVec,isExpRes1Vec);
            %
            myTestIsInside(ellVec,polyVec(3),isExpRes2Vec);
            function myTestIsInside(ellVec,polyVec, expResVec)
                resVec = isInside(ellVec,polyVec);
                mlunitext.assert(all(resVec == expResVec));
            end
        end
        %
        %
        function self = testTri2Polytope(self)
            tri2poly = @(x,y) elltool.exttbx.mpt.gen.tri2polytope(x,y);
            % 3D Case
            vMat = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1];
            fMat = [1 2 3; 2 3 4; 3 4 5; 1 3 5; 1 2 6; 2 4 6; 4 5 6; 1 5 6];
            poly1 = tri2poly(vMat,fMat);
            expPoly1NormMat = [1 1 1; -1 1 1; -1 -1 1; 1 -1 1; 1 1 -1;...
                -1 1 -1; -1 -1 -1; 1 -1 -1];
            expPoly1ConstVec = ones(8,1);
            expPoly1 = polytope(expPoly1NormMat,expPoly1ConstVec);
            mlunitext.assert(poly1 == expPoly1);
            %
            transfMat = [1 2 3; 4 1 1; 0 -2 3];
            transfVec = [1; -2; 0];
            v2Mat = vMat*transfMat' + repmat(transfVec',[size(vMat,1),1]);
            poly2 = tri2poly(v2Mat,fMat);
            
            expPoly2 = transfMat*expPoly1 + transfVec;
            mlunitext.assert(poly2 == expPoly2);
            %
            v3Mat = [1 0 0; 0 1 0; 0 0 1; 0 0 0];
            f3Mat = [1 2 3; 1 4 3; 1 2 4; 2 3 4];
            poly3 = tri2poly(v3Mat, f3Mat);
            expPoly3NormMat = [1 1 1; -eye(3)];
            expPoly3ConstVec = [1; zeros(3,1)];
            expPoly3 = polytope(expPoly3NormMat,expPoly3ConstVec);
            mlunitext.assert(poly3 == expPoly3);
            %
            % 2D Case
            v4Mat = [0 0; 2 0; 5 3; 4 6; 0 1];
            f4Mat = [1 2; 2 3; 3 4; 4 5; 5 1];
            poly4 = tri2poly(v4Mat,f4Mat);
            expPoly4NormMat = [0 -1; 1 -1; 3 1; -5 4; -1 0];
            expPoly4ConstVec = [0; 2; 18; 4; 0];
            expPoly4 = polytope(expPoly4NormMat,expPoly4ConstVec);
            mlunitext.assert(poly4 == expPoly4);
            %
            transf2Mat = [1 2; 3 4];
            transf2Vec = [-1; 1];
            v5Mat = v4Mat*transf2Mat' + repmat(transf2Vec',[5,1]);
            poly5 = tri2poly(v5Mat, f4Mat);
            expPoly5 = transf2Mat*expPoly4+ transf2Vec;
            mlunitext.assert(poly5 == expPoly5);
        end
        %
        %
        function self = testDoesContain(self)
            ellConstrMat = eye(2);
            ellShift1 = [0.05; 0];
            %
            ell1 = ellipsoid(ellConstrMat);
            ell2 = ellipsoid(ellShift1,ellConstrMat);
            %
            polyConstrMat = [-1 0; 1 0; 0 1; 0 -1];
            %
            polyK1Vec = [0; 0.1; 0.1; 0.1];
            polyK2Vec = [0.5; 0.05; sqrt(3)/2; 0];
            %
            poly1 = polytope(polyConstrMat,polyK1Vec);
            poly2 = polytope(polyConstrMat,polyK2Vec);
            %
            exp1Const = 0;
            exp1Vec = [1, 1];
            exp2Vec = [1, 1];
            exp3Vec = [1, 0];
            myTestDoesContain(ell2,poly2,exp1Const);
            myTestDoesContain(ell1,[poly1,poly2],exp1Vec);
            myTestDoesContain([ell1,ell2],poly1,exp2Vec);
            myTestDoesContain([ell1,ell2],[poly1,poly2],exp3Vec);
            function myTestDoesContain(ellVec,polyVec,expVec)
                doesContainVec = doesContain(ellVec,polyVec);
                mlunitext.assert(all(doesContainVec == expVec));
            end
        end
        %
        %
        function self = testToPolytope(self)
            ell1ConstrMat = [4 0; 0 9];
            ell2ConstrMat = eye(2);
            ell3ConstrMat = eye(3);
            ell1ShiftVec = [0; 0];
            ell2ShiftVec = [0.5; 0];
            ell3ShiftVec = [0.05; -0.1; 0];
            %
            ell1 = ellipsoid(ell1ShiftVec,ell1ConstrMat);
            ell2 = ellipsoid(ell2ShiftVec,ell2ConstrMat);
            ell3 = ellipsoid(ell3ShiftVec,ell3ConstrMat);
            poly1 = toPolytope(ell1);
            poly2 = toPolytope(ell2);
            poly3 = toPolytope(ell3);
            %
            %test for 2D-case
            isBound = self.isBoundary(ell1ShiftVec, ell1ConstrMat, poly1);
            mlunitext.assert(isBound);
            isBound = self.isBoundary(ell2ShiftVec, ell2ConstrMat, poly2);
            mlunitext.assert(isBound);
            %test for 3D-case
            isBound = self.isBoundary(ell3ShiftVec, ell3ConstrMat, poly3);
            mlunitext.assert(isBound);
        end
    end
    %
    methods(Static)
        %
        function myTestIsCII(ellVec,polyVec,letter,isCIIExpVec,checkBoth,...
                timeCompare)
            
            if checkBoth
                tic;
                isCIIVec = doesIntersectionContain(ellVec,polyVec,...
                    'mode',letter,'computeMode','lowDimFast');
                lowTime = toc;
                mlunitext.assert(all(isCIIVec == isCIIExpVec));
                tic;
                isCIIVec = doesIntersectionContain(ellVec,polyVec,...
                    'mode',letter,'computeMode','highDimFast');
                highTime = toc;
                mlunitext.assert(all(isCIIVec == isCIIExpVec));
                if strcmp(timeCompare,'low')
                    mlunitext.assert(lowTime <= highTime);
                elseif strcmp(timeCompare,'high')
                    mlunitext.assert(lowTime >= highTime);
                end
            else
                isCIIVec = doesIntersectionContain(ellVec,polyVec,...
                    'mode',letter);
                mlunitext.assert(all(isCIIVec == isCIIExpVec));
            end
        end
        %
        %
        function [testEll2DVec,testPoly2DVec,testEll60D,....
                testPoly60D,ellArr] = genDataDistAndInter()
            testEll2DVec(4) = ellipsoid(16*eye(2));
            testEll2DVec(3) = ellipsoid([1.25 -0.75; -0.75 1.25]);
            testEll2DVec(2) = ellipsoid([1.25 0.75; 0.75 1.25]);
            testEll2DVec(1) = ellipsoid(eye(2));
            %
            testPoly2DVec = [polytope([-1 0; 1 0; 0 1; 0 -1],[-3; 4; 1; 1]),...
                polytope([1 0; -1 0; 0 1; 0 -1], [2.5; -1.5; -1.5; 100]),...
                polytope([1 -1; -1 1; -1 0; 0 1], [-2; 2.5; 2; 2]),...
                polytope([1 0; -1 0; 0 1; 0 -1], [1; 0; 1; 0])];
            testEll60D = ellipsoid(eye(60));
            h60D = [eye(60); -eye(60)];
            h60D(121,:) = [-1 1 zeros(1,58)];
            k60D = [4; 0; ones(58,1); 0; 4; ones(58,1); -4];
            testPoly60D = polytope(h60D,k60D);
            ellArr = ellipsoid.fromRepMat(eye(2),[2,2,2]);
        end
        %
        function isBound = isBoundary(ellShiftVec,ellConstrMat,poly)
            import modgen.common.absrelcompare;
            polyhedron = toPolyhedron(poly);
            pointsArray=polyhedron.V;
            nPoints = size(pointsArray,1);
            isBound = true;
            nDims = size(pointsArray,2);
            for i = 1:nPoints
                if nDims == 3
                    [isEqual, absDiff] = absrelcompare(((pointsArray(i,1) - ellShiftVec(1))^2/ellConstrMat(1,1))...
                        +((pointsArray(i,2)-ellShiftVec(2))^2/ellConstrMat(2,2))...
                        +((pointsArray(i,3)-ellShiftVec(3))^2/ellConstrMat(3,3)),...
                        1,1e-7,[],@abs);
                else
                    [isEqual, absDiff] = absrelcompare(((pointsArray(i,1)-ellShiftVec(1))^2/ellConstrMat(1,1))...
                        +((pointsArray(i,2)-ellShiftVec(2))^2/ellConstrMat(2,2)),...
                        1,1e-7,[],@abs);
                end
                if ~isEqual
                    isBound = false;
                    i = nPoints + 1;
                end
            end
        end
        %
    end
end
function [myMultiDimEllArray, mCount, nDelta]=constructEllForTests(dimsShMatArrayVec)
%constructs a multi-dimensional array of ellipsoids
    dimsCentVecArrayVec=dimsShMatArrayVec(2:end);
    if numel(dimsShMatArrayVec)==2
        dimsCentVecArrayVec(2)=1;
    end
    myVec=dimsShMatArrayVec(3:end);
    mCount=dimsShMatArrayVec(1);
    nCount=prod(myVec);
    my2Vec=[];
    my2Vec=zeros(1,prod(dimsShMatArrayVec));
    jElem=1;
    for iElem=1:mCount^2:mCount^2*nCount
        myMat=jElem*eye(mCount);
        my2Vec(iElem:iElem+mCount^2-1)=reshape(myMat, [1, mCount^2]);
        jElem=jElem+1;
    end
    shMatArray=reshape(my2Vec, dimsShMatArrayVec);
    my3Vec=[];
    my3Vec=zeros(1,prod(dimsCentVecArrayVec));
    jElem=1;
    nDelta=2/(nCount+1);
    for iElem=1:mCount:mCount*nCount
        my3Vec(iElem) = -1+jElem*nDelta;
        my3Vec(iElem+1:iElem+mCount-1) = 0;
        jElem=jElem+1;
    end
    centVecArray = reshape(my3Vec, dimsCentVecArrayVec);
    myMultiDimEllArray = ellipsoid(centVecArray, shMatArray);
end
function myEllArray=constructEllArrayForTests(dimsEllArrayVec)
%constructs an array of ellipsoids with dimensionality dimsVec
    nCount = prod(dimsEllArrayVec);
    alpha=2*pi/nCount;
    myEllVec=[];
    myEllVec=[cos(alpha);sin(alpha)] + ellipsoid(1.5*eye(2));
    for iElem = 1:nCount
        myEllVec(iElem) = [cos(iElem*alpha);sin(iElem*alpha)] + ellipsoid(1.5*eye(2));
    end
    myEllArray = reshape(myEllVec, dimsEllArrayVec);
end
function [my1EllArray, my2EllArray]=construct2EllArraysForTests(dimsEllArrayVec)
%constructs two arrays of ellipsoids with the same dimensionality dimsVec
    nCount = prod(dimsEllArrayVec);
    alpha=2*pi/nCount;
    myEllVec=[];
    myEllVec=[cos(alpha);sin(alpha)] + ellipsoid(1.5*eye(2));
    for iElem = 1:nCount
        myEllVec(iElem) = [cos(iElem*alpha);sin(iElem*alpha)] + ellipsoid(1.5*eye(2));
    end
    my1EllArray = reshape(myEllVec, dimsEllArrayVec);
    for iElem = 1:nCount
        myEllVec(iElem) = [cos(iElem*alpha);sin(iElem*alpha)] + ellipsoid(eye(2));
    end
    my2EllArray=reshape(myEllVec, dimsEllArrayVec);
end