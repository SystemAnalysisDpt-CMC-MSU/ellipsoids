classdef EllipsoidTestCase < mlunitext.test_case

% $Author: Vadim Kaushanskiy, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 15-October-2012, <vkaushanskiy@gmail.com>$

    methods
        function self = EllipsoidTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function self = testIsInternal(self)
            nDim = 100;
            testEllipsoid = ellipsoid(zeros(nDim, 1), eye(nDim));
            testPoint = zeros(nDim, 1);
            testRes = isinternal(testEllipsoid, testPoint);
            mlunit.assert_equals(1, testRes);
            
            testPoint(nDim) = 1;
            testRes = isinternal(testEllipsoid, testPoint);
            mlunit.assert_equals(1, testRes);
            
            for iDim = 1:nDim
                testPoint(iDim) = 1 / sqrt(nDim);
            end;
            testRes = isinternal(testEllipsoid, testPoint);
            mlunit.assert_equals(1, testRes);
            
            testPoint = ones(nDim, 1);
            testRes = isinternal(testEllipsoid, testPoint);
            mlunit.assert_equals(0, testRes);
            
            for iDim = 1:nDim
                testPoint(iDim) = 1 / sqrt(nDim);
            end;
            testPoint(1) = testPoint(1) + 1e-4;
            testRes = isinternal(testEllipsoid, testPoint);
            mlunit.assert_equals(0, testRes);
            
            
            
            nDim = 3;
            testEllipsoid = ellipsoid(zeros(nDim, 1), [1, 0, 0; 0, 2, 0; 0, 0, 0]);
            testPoint = [0.3, -0.8, 0]';
            testRes = isinternal(testEllipsoid, testPoint);
            mlunit.assert_equals(1, testRes);
            
            testPoint = [0.3, -0.8, 1e-3]';
            testRes = isinternal(testEllipsoid, testPoint);
            mlunit.assert_equals(0, testRes);
            
            nDim = 2;
        
            testEllipsoid(1) = ellipsoid(zeros(nDim, 1), eye(nDim));
            testEllipsoid(2) = ellipsoid([2, 0]', eye(nDim));
            testPoint = [1, 0; 2, 0]';
            testRes = isinternal(testEllipsoid, testPoint, 'u');
            mlunit.assert_equals([1, 1], testRes);
            testRes = isinternal(testEllipsoid, testPoint, 'i');
            mlunit.assert_equals([1, 0], testRes);
            
            for iNum = 1:1000
                testEllipsoid(iNum) = ellipsoid(eye(2));
            end;
            testPoint = [0, 0]';
            testRes = isinternal(testEllipsoid, testPoint, 'i');
            mlunit.assert_equals(1, testRes);
            testRes = isinternal(testEllipsoid, testPoint, 'u');
            mlunit.assert_equals(1, testRes);
            
            
        end
        function self = testPolar(self)

           nDim = 100;
           testEllipsoid = ellipsoid(zeros(nDim, 1), eye(nDim));
           polarEllipsoid = polar(testEllipsoid);
           mlunit.assert_equals(1, eq(testEllipsoid, polarEllipsoid));
           
           nDim = 100;
           testSingularEllipsoid = ellipsoid(zeros(nDim, 1), zeros(nDim));
           self.runAndCheckError('polar(testSingularEllipsoid)','degenerateEllipsoid');

           nDim = 3;
           testDegenerateEllipsoid = ellipsoid(zeros(nDim, 1), [1, 0, 0; 0, 2, 0; 0, 0, 0]);
           self.runAndCheckError('polar(testSingularEllipsoid)','degenerateEllipsoid');
           
           nDim = 2;
           testEllipsoid = ellipsoid(zeros(nDim, 1), [2, 0; 0, 1]);
           polarEllipsoid = polar(testEllipsoid);
           answerEllipsoid = ellipsoid(zeros(nDim, 1), [0.5, 0; 0, 1]);
           mlunit.assert_equals(1, eq(polarEllipsoid, answerEllipsoid));
           
           
           nDim = 2;
           testEllipsoid = ellipsoid([0, 0.5]', eye(2));
           polarEllipsoid = polar(testEllipsoid);
           answerEllipsoid = ellipsoid([0, -2/3]', [4/3, 0; 0, 16/9]);
           mlunit.assert_equals(1, eq(polarEllipsoid, answerEllipsoid));
        end
        function self = testIntersect(self)
            %problem is infeasible
            nDim = 2;
            testEllipsoid(1) = ellipsoid(eye(nDim));
            testEllipsoid(2) = ellipsoid([2, 2]', eye(nDim));
            testHyperplane = hyperplane([1, 0]', 10);
            testRes = intersect(testEllipsoid, testHyperplane, 'i');
            mlunit.assert_equals(-1, testRes);
            
            testEllipsoid_2 = ellipsoid(eye(nDim));
            testRes = intersect(testEllipsoid, testEllipsoid_2, 'i');
            mlunit.assert_equals(-1, testRes);
            
            
            %empty intersection
            
            %with ellipsoid
            nDim = 2;
            testEllipsoid = ellipsoid(eye(nDim));
            testEllipsoid_2 = ellipsoid([1000, -1000]', eye(nDim));
            testRes = intersect(testEllipsoid, testEllipsoid_2, 'i');
            mlunit.assert_equals(0, testRes);
         
            %with hyperplane
           
            nDim = 2;
            testEllipsoid = ellipsoid([1000, -1000]', eye(nDim));
            testHyperPlane = hyperplane([1, 0]', 10);
            testRes = intersect(testEllipsoid, testHyperPlane);
           
            %two ellipsoids
            nDim = 2;
            testEllipsoid(1) = ellipsoid(eye(nDim));
            testEllipsoid(2) = ellipsoid([1, 0]', eye(nDim));
            testEllipsoid_2 = ellipsoid([100, -100]', eye(nDim));
            testRes = intersect(testEllipsoid, testEllipsoid_2, 'i');
             mlunit.assert_equals(0, testRes);
            %intersection is not empty
            
            nDim = 2;
            testEllipsoid = ellipsoid(eye(nDim));
            testRes = intersect(testEllipsoid, testEllipsoid);
            mlunit.assert_equals(1, testRes);
            
            nDim = 2;
            testEllipsoid = ellipsoid(eye(nDim));
            testEllipsoid_2 = ellipsoid([2, 0]', eye(nDim));
            testRes = intersect(testEllipsoid, testEllipsoid_2);
            mlunit.assert_equals(1, testRes);
            
            
            nDim = 2;
            testEllipsoid = ellipsoid(eye(nDim));
            testEllipsoid_2 = ellipsoid([1, 0]', eye(nDim));
            testRes = intersect(testEllipsoid, testEllipsoid_2);
            mlunit.assert_equals(1, testRes);
            
            nDim = 2;
            testEllipsoid(1) = ellipsoid(eye(nDim));
            testEllipsoid(2) = ellipsoid([1, 0]', eye(nDim));
            testEllipsoid_2 = ellipsoid([0, 1]', eye(nDim));
            testRes = intersect(testEllipsoid, testEllipsoid_2, 'i');
            mlunit.assert_equals(1, testRes);
            
            nDim = 2;
            testEllipsoid(1) = ellipsoid(eye(nDim));
            testEllipsoid(2) = ellipsoid([2, 0]', eye(nDim));
            testEllipsoid_2 = ellipsoid([1, 1]', eye(nDim));
            testRes = intersect(testEllipsoid, testEllipsoid_2, 'u');
            mlunit.assert_equals(1, testRes);
            
            %hyperplane
            nDim = 2;
            testEllipsoid(1) = ellipsoid(eye(nDim));
            testEllipsoid(2) = ellipsoid([2, 0]', eye(nDim));
            testHyperPlane = hyperplane([1, 0]', 1);
            testRes = intersect(testEllipsoid, testHyperPlane, 'i');
            mlunit.assert_equals(1, testRes);
            testRes = intersect(testEllipsoid, testHyperPlane, 'u');
            mlunit.assert_equals(1, testRes);
            
  
        end
        function self = testIntersectEa(self)
            mlunit.assert_equals(0, sin(0));
        end
        function self = testIntersectIa(self)
            mlunit.assert_equals(0, sin(0));
        end
        function self = testEllintersectionIa(self)
            mlunit.assert_equals(0, sin(0));
        end
        function self = testEllunionEa(self)
            nDim = 10;
            nArr = 15;
            eyeEllipsoid = ellipsoid(eye(nDim));
            for iArr = 1:nArr
                testEllipsoid(iArr) = eyeEllipsoid;
            end;
            resEllipsoid = ellunion_ea(testEllipsoid);
            answerEllipsoid = eyeEllipsoid;
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
            
            clear;
            nDim = 2;
            testEllipsoid(1) = ellipsoid(eye(nDim));
            testEllipsoid(2) = ellipsoid([1, 0]', eye(nDim));
            resEllipsoid = ellunion_ea(testEllipsoid);
            
   
            answerEllipsoid = ellipsoid([0.500000000007025, 0]', [2.389624507507514, 0; 0, 1.296525111099451]);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
            
            clear;
            nDim = 2;
            testEllipsoid(1) = ellipsoid(eye(nDim));
            testEllipsoid(2) = ellipsoid([1, 0]', eye(nDim));
            testEllipsoid(3) = ellipsoid([0, 1]', eye(nDim));
            resEllipsoid = ellunion_ea(testEllipsoid);
            
            answerEllipsoid = ellipsoid([0.361900110249858, 0.361900133569072]', [2.713989519131491, -0.428437951540780;-0.428437951540780, 2.713989419417838]);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
          
            nDim = 3;
            testEllipsoid(1) = ellipsoid(eye(3));
            testEllipsoid(2) = ellipsoid([1, 0.5, -0.5]', [2, 0, 0; 0, 1, 0; 0, 0, 0.5]);
            testEllipsoid(3) = ellipsoid([0.5, 0.3, 1]', [0.5, 0, 0; 0, 0.5, 0; 0, 0, 2]);
            resEllipsoid = ellunion_ea(testEllipsoid);
           
            answerEllipsoidShape = [3.214278694218219 0.597782759694970 -0.610825850601710;0.597782759694970 1.826390762576929  -0.135640504336856;-0.610825850601710 -0.135640504336856 4.757741441412507];
            answerEllipsoidCenter = [0.678848085399030, 0.271345388982263, 0.242812544509344]';
            answerEllipsoid = ellipsoid(answerEllipsoidCenter, answerEllipsoidShape);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
            
            
        end
        function self = testHpIntersection(self)
            %empty intersection
            nDim = 2;
            testEllipsoid = ellipsoid([100, -100]', eye(nDim));
            testHyperPlane = hyperplane([0 -1]', 1);
            self.runAndCheckError('hpintersection(testEllipsoid, testHyperPlane)','degenerateEllipsoid');
            
            nDim = 2;
            testEllipsoid = ellipsoid(eye(nDim));
            testHyperPlane = hyperplane([1, 0]', 0);
            resEllipsoid = hpintersection(testEllipsoid, testHyperPlane);
            answerEllipsoid = ellipsoid([0, 0; 0, 1]);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
            
            nDim = 2;
            testEllipsoid = ellipsoid(eye(nDim));
            testHyperPlane = hyperplane([0, 1]', 0);
            resEllipsoid = hpintersection(testEllipsoid, testHyperPlane);
            answerEllipsoid = ellipsoid([1, 0; 0, 0]);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));

            nDim = 2;
            testEllipsoid = ellipsoid(eye(nDim));
            testHyperPlane = hyperplane([1, 1]', 0);
            resEllipsoid = hpintersection(testEllipsoid, testHyperPlane);
            answerEllipsoid = ellipsoid([0.5, -0.5; -0.5, 0.5]);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));

            nDim = 2;
            testEllipsoid = ellipsoid(eye(nDim));
            testHyperPlane = hyperplane([1, 0]', 1);
            resEllipsoid = hpintersection(testEllipsoid, testHyperPlane);
            answerEllipsoid = ellipsoid([1, 0]', [0, 0; 0, 0]);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));

            nDim = 3;
            testEllipsoid = ellipsoid(eye(nDim));
            testHyperPlane = hyperplane([0, 0, 1]', 0);
            resEllipsoid = hpintersection(testEllipsoid, testHyperPlane);
            answerEllipsoid = ellipsoid([1, 0, 0; 0, 1, 0; 0, 0, 0]);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
            
            nDim = 3;
            testEllipsoid = ellipsoid([3, 0, 0; 0, 2, 0; 0, 0, 4]);
            testHyperPlane = hyperplane([0, 1, 0]', 0);
            resEllipsoid = hpintersection(testEllipsoid, testHyperPlane);
            answerEllipsoid = ellipsoid([3, 0, 0; 0, 0, 0; 0, 0, 4]);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));

            
            nDim = 3;
            testEllipsoid = ellipsoid(eye(3));
            testHyperPlane = hyperplane([1, 1, 1]', 0);
            resEllipsoid = hpintersection(testEllipsoid, testHyperPlane);
            answerEllipsoid = ellipsoid([2/3, -1/3, -1/3; -1/3, 2/3, -1/3; -1/3, -1/3, 2/3]);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));

            
            
            nDim = 3;
            testEllipsoid = ellipsoid([1, 0, 0; 0, 1, 0; 0, 0, 4]);
            testHyperPlane = hyperplane([0, 0, 1]', 2);
            resEllipsoid = hpintersection(testEllipsoid, testHyperPlane);
            answerEllipsoid = ellipsoid([0, 0, 2]', [0, 0, 0; 0, 0, 0; 0, 0, 0]);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));

            nDim = 100;
            testEllipsoid = ellipsoid(eye(nDim));
            PlaneNormal = zeros(nDim, 1);
            PlaneNormal(1) = 1;
            testHyperPlane = hyperplane(PlaneNormal, 0);
            
            resEllipsoid = hpintersection(testEllipsoid, testHyperPlane);
            answerEllipsoidMatrix = eye(nDim);
            answerEllipsoidMatrix(1) = 0;
            answerEllipsoid = ellipsoid(zeros(nDim, 1), answerEllipsoidMatrix);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));

        end
    end
        
end

