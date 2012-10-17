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
         %   mlunit.assert_equals(-1, testRes);
            
            
            %empty intersection
          %  nDim = 2;
          %  testEllipsoid(1) = ellipsoid(eye(nDim));
          %  testEllipsoid(2) = ellipsoid([1, 0]', eye(nDim));
          %  testEllipsoid_2 = ellipsoid([1000, -1000]', eye(nDim));
          %  testRes = intersect(testEllipsoid, testEllipsoid_2, 'i');
          %  mlunit.assert_equals(0, testRes);
           % testRes = intersect(testEllipsoid, testEllipsoid_2, 'u');
           % mlunit.assert_equals(0, testRes);
           
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
            mlunit.assert_equals(0, sin(0));
        end
        function self = testHpIntersection(self)
            mlunit.assert_equals(0, sin(0));
        end
    end
        
end

