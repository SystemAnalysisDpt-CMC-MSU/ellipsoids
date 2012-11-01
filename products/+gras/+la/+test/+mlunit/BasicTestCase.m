classdef BasicTestCase < mlunitext.test_case
% $Author: Vadim Kaushanskiy, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 1-November-2012, <vkaushanskiy@gmail.com>$
    properties (Access=private)
        testDataRootDir
    end

    methods
        function self = BasicTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,'TestData',...
                filesep,shortClassName];
    
        end

        function self = testSqrtM(self)
            import gras.la.sqrtm;
            Eps = 1e-6;
            nDim = 1000;
            testMat = eye(nDim);
            SqrtMat = sqrtm(testMat);
            mlunit.assert_equals(testMat, SqrtMat);
            
            nDim = 1000;
            testMat = diag(1:nDim);
            SqrtMat = sqrtm(testMat);
            mlunit.assert_equals(sqrt(testMat), SqrtMat);
            
            nDim = 2;
            testMat = [2, 1; 1, 2];
            VMat = [-1/sqrt(2), 1/sqrt(2); 1/sqrt(2), 1/sqrt(2)];
            DMat = diag([1, sqrt(3)]);
            sqrtTestMat = VMat*DMat*VMat';
            SqrtMat = sqrtm(testMat);
            mlunit.assert_equals(sqrtTestMat, SqrtMat);

            nDim = 3;
            testMat = [5, -4, 1; -4, 6, -4; 1, -4, 5];
            sqrtTestMat = [2, -1, 0; -1, 2, -1; 0, -1, 2];
            SqrtMat = sqrtm(testMat);
            mlunit.assert_equals(1, norm(sqrtTestMat-SqrtMat) < Eps);
            
            nDim = 15;
            load(strcat(self.testDataRootDir, strcat(filesep, 'testSqrtm1_inp.mat')), 'testMat');
            SqrtMat = sqrtm(testMat);
            mlunit.assert_equals(1, norm(testMat-SqrtMat*SqrtMat')<Eps);
            
            nDim = 15;
            load(strcat(self.testDataRootDir, strcat(filesep, 'testSqrtm2_inp.mat')), 'testMat');
            SqrtMat = sqrtm(testMat);
            mlunit.assert_equals(1, norm(testMat-SqrtMat*SqrtMat') < Eps);

        end
    end
    
end

