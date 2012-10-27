classdef EllipsoidTestCase < mlunitext.test_case

% $Author: Vadim Kaushanskiy, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 15-October-2012, <vkaushanskiy@gmail.com>$
    properties (Access=private)
        testDataRootDir
    end
 
    methods
        function self = EllipsoidTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,'TestData',...
                filesep,shortClassName];
    
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
            testPoint = [0.3, -0.8, 0].';
            testRes = isinternal(testEllipsoid, testPoint);
            mlunit.assert_equals(1, testRes);
            
            testPoint = [0.3, -0.8, 1e-3].';
            testRes = isinternal(testEllipsoid, testPoint);
            mlunit.assert_equals(0, testRes);
            
            nDim = 2;
        
            testEllipsoid(1) = ellipsoid(zeros(nDim, 1), eye(nDim));
            testEllipsoid(2) = ellipsoid([2, 0].', eye(nDim));
            testPoint = [1, 0; 2, 0].';
            testRes = isinternal(testEllipsoid, testPoint, 'u');
            mlunit.assert_equals([1, 1], testRes);
            testRes = isinternal(testEllipsoid, testPoint, 'i');
            mlunit.assert_equals([1, 0], testRes);
            
            for iNum = 1:1000
                testEllipsoid(iNum) = ellipsoid(eye(2));
            end;
            testPoint = [0, 0].';
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
           testEllipsoid = ellipsoid([0, 0.5].', eye(2));
           polarEllipsoid = polar(testEllipsoid);
           answerEllipsoid = ellipsoid([0, -2/3].', [4/3, 0; 0, 16/9]);
           mlunit.assert_equals(1, eq(polarEllipsoid, answerEllipsoid));
        end
        function self = testIntersect(self)
            %problem is infeasible
            nDim = 2;
            testEllipsoid(1) = ellipsoid(eye(nDim));
            testEllipsoid(2) = ellipsoid([2, 2].', eye(nDim));
            testHyperplane = hyperplane([1, 0].', 10);
            testRes = intersect(testEllipsoid, testHyperplane, 'i');
            mlunit.assert_equals(-1, testRes);
            
            testEllipsoid_2 = ellipsoid(eye(nDim));
            testRes = intersect(testEllipsoid, testEllipsoid_2, 'i');
            mlunit.assert_equals(-1, testRes);
            
            
            %empty intersection
            
            %with ellipsoid
            nDim = 2;
            testEllipsoid = ellipsoid(eye(nDim));
            testEllipsoid_2 = ellipsoid([1000, -1000].', eye(nDim));
            testRes = intersect(testEllipsoid, testEllipsoid_2, 'i');
            mlunit.assert_equals(0, testRes);
         
            %with hyperplane
           
            nDim = 2;
            testEllipsoid = ellipsoid([1000, -1000].', eye(nDim));
            testHyperPlane = hyperplane([1, 0].', 10);
            testRes = intersect(testEllipsoid, testHyperPlane);
           
            %two ellipsoids
            nDim = 2;
            testEllipsoid(1) = ellipsoid(eye(nDim));
            testEllipsoid(2) = ellipsoid([1, 0].', eye(nDim));
            testEllipsoid_2 = ellipsoid([100, -100].', eye(nDim));
            testRes = intersect(testEllipsoid, testEllipsoid_2, 'i');
            mlunit.assert_equals(0, testRes);
            %intersection is not empty
            
            nDim = 2;
            testEllipsoid = ellipsoid(eye(nDim));
            testRes = intersect(testEllipsoid, testEllipsoid);
            mlunit.assert_equals(1, testRes);
            
            nDim = 2;
            testEllipsoid = ellipsoid(eye(nDim));
            testEllipsoid_2 = ellipsoid([2, 0].', eye(nDim));
            testRes = intersect(testEllipsoid, testEllipsoid_2);
            mlunit.assert_equals(1, testRes);
            
            
            nDim = 2;
            testEllipsoid = ellipsoid(eye(nDim));
            testEllipsoid_2 = ellipsoid([1, 0].', eye(nDim));
            testRes = intersect(testEllipsoid, testEllipsoid_2);
            mlunit.assert_equals(1, testRes);
            
            nDim = 2;
            testEllipsoid(1) = ellipsoid(eye(nDim));
            testEllipsoid(2) = ellipsoid([1, 0].', eye(nDim));
            testEllipsoid_2 = ellipsoid([0, 1].', eye(nDim));
            testRes = intersect(testEllipsoid, testEllipsoid_2, 'i');
            mlunit.assert_equals(1, testRes);
            
            nDim = 2;
            testEllipsoid(1) = ellipsoid(eye(nDim));
            testEllipsoid(2) = ellipsoid([2, 0].', eye(nDim));
            testEllipsoid_2 = ellipsoid([1, 1].', eye(nDim));
            testRes = intersect(testEllipsoid, testEllipsoid_2, 'u');
            mlunit.assert_equals(1, testRes);
            
            %hyperplane
            nDim = 2;
            testEllipsoid(1) = ellipsoid(eye(nDim));
            testEllipsoid(2) = ellipsoid([2, 0].', eye(nDim));
            testHyperPlane = hyperplane([1, 0].', 1);
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
            nDim = 10;
            nArr = 15;
            eyeEllipsoid = ellipsoid(eye(nDim));
            for iArr = 1:nArr
                testEllipsoid(iArr) = eyeEllipsoid;
            end;
            resEllipsoid = ellintersection_ia(testEllipsoid);
            answerEllipsoid = eyeEllipsoid;
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
            
            clear testEllipsoid;
            
            nDim = 2;
            testEllipsoid(1) = ellipsoid(eye(nDim));
            testEllipsoid(2) = ellipsoid([1, 0].', eye(nDim));
            resEllipsoid = ellintersection_ia(testEllipsoid);

            answerEllipsoid = ellipsoid([0.5, 0]', [0.235394505823186, 0; 0, 0.578464829541428]);
        %    mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
            mlunit.assert_equals(1, contains(testEllipsoid(1), resEllipsoid));
            mlunit.assert_equals(1, contains(testEllipsoid(2), resEllipsoid));

            clear testEllipsoid;
            nDim = 2;
            testEllipsoid(1) = ellipsoid(eye(nDim));
            testEllipsoid(2) = ellipsoid([1, 0].', eye(nDim));
            testEllipsoid(3) = ellipsoid([0, 1].', eye(nDim));
            resEllipsoid = ellintersection_ia(testEllipsoid);
            answerEllipsoidCenter = [0.407334088244713, 0.407334086547540].';
            answerEllipsoidMatrix = [0.125814751017434, 0.053912585874054; 0.053912585874054, 0.125814748979735];
            answerEllipsoid = ellipsoid(answerEllipsoidCenter, answerEllipsoidMatrix);
       %     mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
       %     mlunit.assert_equals(1, contains(testEllipsoid(1), resEllipsoid));
       %     mlunit.assert_equals(1, contains(testEllipsoid(2), resEllipsoid));
       %     mlunit.assert_equals(1, contains(testEllipsoid(3), resEllipsoid));
            
            
            clear testEllipsoid;
            nDim = 3;
            testEllipsoid(1) = ellipsoid(eye(nDim));
            testEllipsoid(2) = ellipsoid([1, 0.5, -0.5].', [2, 0, 0; 0, 1, 0; 0, 0, 0.5]);
            testEllipsoid(3) = ellipsoid([0.5, 0.3, 1].', [0.5, 0, 0; 0, 0.5, 0; 0, 0, 2]);
            resEllipsoid = ellintersection_ia(testEllipsoid);
            
            answerEllipsoidCenter = [0.513846517075189, 0.321868721330990, -0.100393450228106].';
            answerEllipsoidMatrix = [0.156739727326948, -0.005159338786834, 0.011041318375176; -0.005159338786834, 0.161491682085078, 0.014052111019755; 0.011041318375176, 0.014052111019755, 0.062235791525665];
            answerEllipsoid = ellipsoid(answerEllipsoidCenter, answerEllipsoidMatrix);
        %    mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
            mlunit.assert_equals(1, contains(testEllipsoid(1), resEllipsoid));
            mlunit.assert_equals(1, contains(testEllipsoid(2), resEllipsoid));
            mlunit.assert_equals(1, contains(testEllipsoid(3), resEllipsoid));

            clear testEllipsoid;
            load(strcat(self.testDataRootDir, '/testEllintersection_inpSimple.mat'), 'testEllipsoidCenter', 'testEllipsoidMatrix', 'testEllipsoidCenter2', 'testEllipsoidMatrix2');
            testEllipsoid(1) = ellipsoid(testEllipsoidCenter, testEllipsoidMatrix);
            testEllipsoid(2) = ellipsoid(testEllipsoidCenter2, testEllipsoidMatrix2);
            resEllipsoid = ellintersection_ia(testEllipsoid);
            load(strcat(self.testDataRootDir, '/testEllintersection_outSimple.mat'), 'answerEllipsoidCenter', 'answerEllipsoidMatrix');
            answerEllipsoid = ellipsoid(answerEllipsoidCenter, answerEllipsoidMatrix);
         %   mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
         %   mlunit.assert_equals(1, contains(testEllipsoid(1), resEllipsoid));
         %   mlunit.assert_equals(1, contains(testEllipsoid(2), resEllipsoid));

            clear testEllipsoid;
            load(strcat(self.testDataRootDir, '/testEllintersectionIa_inp.mat'), 'testEllipsoidCenter', 'testEllipsoidMatrix', 'testEllipsoidCenter2', 'testEllipsoidMatrix2');
            testEllipsoid(1) = ellipsoid(testEllipsoidCenter, testEllipsoidMatrix);
            testEllipsoid(2) = ellipsoid(testEllipsoidCenter2, testEllipsoidMatrix2);
            resEllipsoid = ellintersection_ia(testEllipsoid);
            load(strcat(self.testDataRootDir, '/testEllintersectionIa_out.mat'), 'answerEllipsoidCenter', 'answerEllipsoidMatrix');
            answerEllipsoid = ellipsoid(answerEllipsoidCenter, answerEllipsoidMatrix);
         %   mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
         %   mlunit.assert_equals(1, contains(testEllipsoid(1), resEllipsoid));
         %   mlunit.assert_equals(1, contains(testEllipsoid(2), resEllipsoid));
            
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
            %mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
            
            clear testEllipsoid;
            nDim = 2;
            testEllipsoid(1) = ellipsoid(eye(nDim));
            testEllipsoid(2) = ellipsoid([1, 0].', eye(nDim));
            resEllipsoid = ellunion_ea(testEllipsoid);
              
            answerEllipsoid = ellipsoid([0.5, 0].', [2.389605510164642, 0; 0, 1.296535157845836]);
           % mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
           % mlunit.assert_equals(1, contains(resEllipsoid, testEllipsoid(1)));
           % mlunit.assert_equals(1, contains(resEllipsoid, testEllipsoid(2)));
            
            clear testEllipsoid;
            nDim = 2;
            testEllipsoid(1) = ellipsoid(eye(nDim));
            testEllipsoid(2) = ellipsoid([1, 0].', eye(nDim));
            testEllipsoid(3) = ellipsoid([0, 1].', eye(nDim));
            resEllipsoid = ellunion_ea(testEllipsoid);
            answerEllipsoid = ellipsoid([0.361900110249858, 0.361900133569072].', [2.713989398757731, -0.428437874833322;-0.428437874833322, 2.713989515632939]);
         %   mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
         %   mlunit.assert_equals(1, contains(resEllipsoid, testEllipsoid(1)));
         %   mlunit.assert_equals(1, contains(resEllipsoid, testEllipsoid(2)));
         %   mlunit.assert_equals(1, contains(resEllipsoid, testEllipsoid(3)));
            
            
            nDim = 3;
            testEllipsoid(1) = ellipsoid(eye(nDim));
            testEllipsoid(2) = ellipsoid([1, 0.5, -0.5].', [2, 0, 0; 0, 1, 0; 0, 0, 0.5]);
            testEllipsoid(3) = ellipsoid([0.5, 0.3, 1].', [0.5, 0, 0; 0, 0.5, 0; 0, 0, 2]);
            resEllipsoid = ellunion_ea(testEllipsoid);

            answerEllipsoidShape = [3.214279075152898 0.597782711155458 -0.610826375241159; 0.597782711155458 1.826390617268878  -0.135640717373030;-0.610826375241159  -0.135640717373030 4.757741393980497];
            answerEllipsoidCenter = [0.678847905650305, 0.271345357930677, 0.242812593977658].';
            answerEllipsoid = ellipsoid(answerEllipsoidCenter, answerEllipsoidShape);
         %   mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
            mlunit.assert_equals(1, contains(resEllipsoid, testEllipsoid(1)));
            mlunit.assert_equals(1, contains(resEllipsoid, testEllipsoid(2)));
            mlunit.assert_equals(1, contains(resEllipsoid, testEllipsoid(3)));
            
            clear testEllipsoid;
            nDim = 15;
            load(strcat(self.testDataRootDir, '/testEllunion_inpSimple.mat'), 'testEllipsoidCenter', 'testEllipsoidMatrix', 'testEllipsoidCenter2', 'testEllipsoidMatrix2');
            testEllipsoid(1) = ellipsoid(testEllipsoidCenter, testEllipsoidMatrix);
            testEllipsoid(2) = ellipsoid(testEllipsoidCenter2, testEllipsoidMatrix2);
            resEllipsoid = ellunion_ea(testEllipsoid);
            load(strcat(self.testDataRootDir, '/testEllunion_outSimple.mat'), 'answerEllipsoidCenter', 'answerEllipsoidMatrix');
            answerEllipsoid = ellipsoid(answerEllipsoidCenter, answerEllipsoidMatrix);
          %  mlunit.assert_equals(1, contains(resEllipsoid, testEllipsoid(1)));
          %  mlunit.assert_equals(1, contains(resEllipsoid, testEllipsoid(2)));
          %  mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
            clear testEllipsoid;
            nDim = 15;
            load(strcat(self.testDataRootDir, '/testEllunionEa_inp.mat'), 'testEllipsoidCenter', 'testEllipsoidMatrix', 'testEllipsoidCenter2', 'testEllipsoidMatrix2');
            testEllipsoid(1) = ellipsoid(testEllipsoidCenter, testEllipsoidMatrix);
            testEllipsoid(2) = ellipsoid(testEllipsoidCenter2, testEllipsoidMatrix2);
            resEllipsoid = ellunion_ea(testEllipsoid);
            load(strcat(self.testDataRootDir, '/testEllunionEa_out.mat'), 'answerEllipsoidCenter', 'answerEllipsoidMatrix');
            answerEllipsoid = ellipsoid(answerEllipsoidCenter, answerEllipsoidMatrix);
          %  mlunit.assert_equals(1, contains(resEllipsoid, testEllipsoid(1)));
          %  mlunit.assert_equals(1, contains(resEllipsoid, testEllipsoid(2)));
          %  mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
        end
        function self = testHpIntersection(self)
            %empty intersection
            nDim = 2;
            testEllipsoid = ellipsoid([100, -100]', eye(nDim));
            testHyperPlane = hyperplane([0 -1]', 1);
            self.runAndCheckError('resEllipsoid = hpintersection(testEllipsoid, testHyperPlane)','degenerateEllipsoid');
            
            nDim = 2;
            testEllipsoid = ellipsoid(eye(nDim));
            testHyperPlane = hyperplane([1, 0].', 0);
            resEllipsoid = hpintersection(testEllipsoid, testHyperPlane);
            answerEllipsoid = ellipsoid([0, 0; 0, 1]);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
            
            nDim = 2;
            testEllipsoid = ellipsoid(eye(nDim));
            testHyperPlane = hyperplane([0, 1].', 0);
            resEllipsoid = hpintersection(testEllipsoid, testHyperPlane);
            answerEllipsoid = ellipsoid([1, 0; 0, 0]);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));

            nDim = 2;
            testEllipsoid = ellipsoid(eye(nDim));
            testHyperPlane = hyperplane([1, 1].', 0);
            resEllipsoid = hpintersection(testEllipsoid, testHyperPlane);
            answerEllipsoid = ellipsoid([0.5, -0.5; -0.5, 0.5]);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));

            nDim = 2;
            testEllipsoid = ellipsoid(eye(nDim));
            testHyperPlane = hyperplane([1, 0].', 1);
            resEllipsoid = hpintersection(testEllipsoid, testHyperPlane);
            answerEllipsoid = ellipsoid([1, 0].', [0, 0; 0, 0]);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));

            nDim = 3;
            testEllipsoid = ellipsoid(eye(nDim));
            testHyperPlane = hyperplane([0, 0, 1].', 0);
            resEllipsoid = hpintersection(testEllipsoid, testHyperPlane);
            answerEllipsoid = ellipsoid([1, 0, 0; 0, 1, 0; 0, 0, 0]);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
            
            nDim = 3;
            testEllipsoid = ellipsoid([3, 0, 0; 0, 2, 0; 0, 0, 4]);
            testHyperPlane = hyperplane([0, 1, 0].', 0);
            resEllipsoid = hpintersection(testEllipsoid, testHyperPlane);
            answerEllipsoid = ellipsoid([3, 0, 0; 0, 0, 0; 0, 0, 4]);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));

            
            nDim = 3;
            testEllipsoid = ellipsoid(eye(3));
            testHyperPlane = hyperplane([1, 1, 1].', 0);
            resEllipsoid = hpintersection(testEllipsoid, testHyperPlane);
            answerEllipsoid = ellipsoid([2/3, -1/3, -1/3; -1/3, 2/3, -1/3; -1/3, -1/3, 2/3]);
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));

            
            
            nDim = 3;
            testEllipsoid = ellipsoid([1, 0, 0; 0, 1, 0; 0, 0, 4]);
            testHyperPlane = hyperplane([0, 0, 1].', 2);
            resEllipsoid = hpintersection(testEllipsoid, testHyperPlane);
            answerEllipsoid = ellipsoid([0, 0, 2].', [0, 0, 0; 0, 0, 0; 0, 0, 0]);
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
            
            
            %two output arguments
            nDim = 2;
            testEllipsoid = ellipsoid([100, -100].', eye(nDim));
            testHyperPlane = hyperplane([0 -1].', 1);
            [resEllipsoid, isnIntersected] = hpintersection(testEllipsoid, testHyperPlane);
            answerEllipsoid = ellipsoid;
            mlunit.assert_equals(1, eq(resEllipsoid, answerEllipsoid));
            mlunit.assert_equals(true, isnIntersected);
            
            nDim = 2;
            testEllipsoid(1, 1) = ellipsoid([100, -100].', eye(nDim));
            testHyperPlane(1, 1) = hyperplane([0 -1].', 1);
            testEllipsoid(2, 2) = ellipsoid([100, -100].', eye(nDim));
            testHyperPlane(2, 2) = hyperplane([0 -1].', 1);
            testEllipsoid(1, 2) = ellipsoid(eye(nDim));
            testHyperPlane(1, 2) = hyperplane([0, 1].', 0);
            testEllipsoid(2, 1) = ellipsoid(eye(nDim));
            testHyperPlane(2, 1) = hyperplane([0, 1].', 0);
            [resEllipsoid, isnIntersected] = hpintersection(testEllipsoid, testHyperPlane);
            
            answerEllipsoid(1, 1) = ellipsoid;
            answerEllipsoid(2, 2) = ellipsoid;
            answerEllipsoid(1, 2) = ellipsoid([1, 0; 0, 0]);
            answerEllipsoid(2, 1) = ellipsoid([1, 0; 0, 0]);
            answerIsnIntersectedMatrix = [true, false; false, true];
            mlunit.assert_equals([1, 1; 1, 1], eq(resEllipsoid, answerEllipsoid));
            mlunit.assert_equals(answerIsnIntersectedMatrix, isnIntersected);
            
            %wrong dimension
            for iDim = 1:2
                for jDim = 1:2
                    for kDim = 1:2
                        testEllipsoidArray(iDim, jDim, kDim) = ellipsoid(eye(3));
                    end;
                end;
            end;
            
            testHyperPlane = hyperplane([0, 0, 1].', 2);
            self.runAndCheckError('resEllipsoid = hpintersection(testEllipsoidArray, testHyperPlane)','wrongInput:wrongDim');
            
            for iDim = 1:2
                for jDim = 1:2
                    for kDim = 1:2
                        testHyperPlaneArray(iDim, jDim, kDim) = hyperplane([0, 0, 1].', 2);
                    end;
                end;
            end;
            
            testEllipsoid = ellipsoid(eye(3));
            self.runAndCheckError('resEllipsoid = hpintersection(testEllipsoidArray, testHyperPlane)','wrongInput:wrongDim');
            
        end
 
    end
        
end

