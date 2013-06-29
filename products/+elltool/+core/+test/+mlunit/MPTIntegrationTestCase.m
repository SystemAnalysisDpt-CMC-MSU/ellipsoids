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
            polyK3DVec = 0.1 * ones(6,1);
            polyK15DVec = (1/sqrt(nDims))*ones(nDims*2,1);
            %
            poly1 = polytope(polyConstrMat,polyK1Vec);
            poly2 = polytope(polyConstrMat,polyK2Vec);
            poly3 = polytope(polyConstrMat,polyK3Vec);
            poly4 = polytope(polyConstrMat,polyK4Vec);
            poly3D = polytope(polyConstr3DMat,polyK3DVec);
            poly14D = polytope(polyConstr15DMat,polyK15DVec);
            %
            isExpVec = [1, 0, 1, 1, 1, 0, 1, 0, -1];
            
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
            self.myTestIsCII([ell1, ell3], poly1, 'u',isExpVec(8),false,'no')
            %
            self.myTestIsCII(ell1, [poly1, poly4],'i',isExpVec(9),false,'no')
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
        
        function self = testIntersectionIA(self)
            import elltool.exttbx.mpt.gen.*;
            %
            %ellipsoid lies in polytope
            ell4 = ellipsoid(eye(2));
            poly4 = polytope([eye(2); -eye(2)], ones(4,1));
            ellPolyIA5 = intersection_ia(ell4,poly4);
            mlunitext.assert(eq(ell4,ellPolyIA5));
            %
            %polytope lies in ellipsoid
            ell5 = ellipsoid(eye(2));
            poly5 = polytope([eye(2); -eye(2)], 1/4*ones(4,1));
            expEll = ellipsoid(1/16*eye(2));
            ellPolyIA5 = intersection_ia(ell5,poly5);
            mlunitext.assert(eq(expEll,ellPolyIA5));
            %
            %test if internal approximation is really internal
            c6Vec =  [0.8913;0.7621;0.4565;0.0185;0.8214];
            sh6Mat = [ 1.0863 0.4281 1.0085 1.4706 0.6325;...
                       0.4281 0.5881 0.9390 1.1156 0.6908;...
                       1.0085 0.9390 2.2240 2.3271 1.7218;...
                       1.4706 1.1156 2.3271 2.9144 1.6438;...
                       0.6325 0.6908 1.7218 1.6438 1.6557];    
            ell6 = ellipsoid(c6Vec, sh6Mat);
            poly6 = polytope(eye(5),c6Vec);
            ellPolyIA6 = intersection_ia(ell6,poly6);
            mlunitext.assert(doesIntersectionContain(ell6,ellPolyIA6) &&...
                isInside(ellPolyIA6,poly6));
            %
            sh7Mat = [1.1954 0.3180 1.3183; 0.3180 0.2167 0.5039;...
                1.3183 0.5039 1.6320];
            ell7 = ellipsoid(sh7Mat);
            poly7 = polytope([1 1 1], 0.2);
            ellPolyIA7 = intersection_ia(ell7,poly7);
            mlunitext.assert(doesIntersectionContain(ell7,ellPolyIA7) &&...
                isInside(ellPolyIA7,poly7));
            %
            %test if internal approximation is an empty ellipsoid, when
            %ellipsoid and polytope aren't intersect
            ell8 = ellipsoid(eye(2));
            poly8 = polytope([1 1], -sqrt(2));
            ellPolyIA8 = intersection_ia(ell8,poly8);
            [~,ellPoly8Mat] = double(ellPolyIA8);
            mlunitext.assert(all(ellPoly8Mat(:) == 0));
            %
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
            poly1 = polytope(defaultPolyMat,defaultPolyConst);
            ellEA1 = intersection_ea(ell1,poly1);
            mlunitext.assert(eq(ell1,ellEA1));
            %
            %If we apply same linear tranform to both ell1 and poly1, than
            %minimal volume ellipsoid shouldn't change.
            transfMat =  [1 3; 2 2];
            shiftVec = [1; 1];
            transfShMat = transfMat*(transfMat)';
            ell2 = ellipsoid(shiftVec,transfShMat);
            poly2 = polytope(defaultPolyMat/(transfMat),...
                defaultPolyConst+(defaultPolyMat/(transfMat))*shiftVec);
            ellEA2 = intersection_ea(ell2,poly2);
            mlunitext.assert(eq(ell2,ellEA2));
            %
            %Checking, that amount of constraints in polytope does not
            %affect accuracy of computation of external approximation
            nConstr = 100;
            angleVec = (0:2*pi/nConstr:2*pi*(1-1/nConstr))';
            hMat = [cos(angleVec), sin(angleVec)];
            kVec = ones(nConstr,1);
            polyManyConstr = polytope(hMat,kVec);
            ellEAManyConstr = intersection_ea(ell1,polyManyConstr);
            mlunitext.assert(eq(ell1,ellEAManyConstr));
            %
            %First example, but for nDims
            nDims = 10;
            shNMat = eye(nDims);
            ellN = ellipsoid(shNMat);
            polyNMat = [1, zeros(1,nDims-1)];
            polyNConst = 1/(2*nDims);
            polyN = polytope(polyNMat,polyNConst);
            ellEAN = intersection_ea(ellN,polyN);
            mlunitext.assert(eq(ellN,ellEAN));
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
            polyN2 = polytope(polyNMat/(transfNMat),...
                polyNConst+(polyNMat/(transfNMat))*shiftNVec);
            ellEA2 = intersection_ea(ellN2,polyN2);
            mlunitext.assert(eq(ellN2,ellEA2));
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
            
            expPoly2 = expPoly1*transfMat + transfVec;
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
            f4Mat = [1; 2; 3; 4; 5];
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
            expPoly5 = expPoly4*transf2Mat+ transf2Vec;
            mlunitext.assert(poly5 == expPoly5);
        end
        
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
             testPoly60D = polytope(struct('H',h60D,'K',k60D));
             ellArr = ellipsoid.fromRepMat(eye(2),[2,2,2]);
         end
         %
    end
end
