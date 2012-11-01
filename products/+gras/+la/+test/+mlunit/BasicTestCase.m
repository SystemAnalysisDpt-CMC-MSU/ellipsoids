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
            MAX_TOL = 1e-6;
            nDim = 1000;
            testMat = eye(nDim);
            sqrtMat = sqrtm(testMat);
            mlunit.assert_equals(testMat, sqrtMat);
            
            nDim = 1000;
            testMat = diag(1:nDim);
            sqrtMat = sqrtm(testMat);
            mlunit.assert_equals(sqrt(testMat), sqrtMat);
            
            nDim = 2;
            testMat = [2, 1; 1, 2];
            vMat = [-1/sqrt(2), 1/sqrt(2); 1/sqrt(2), 1/sqrt(2)];
            dMat = diag([1, sqrt(3)]);
            sqrtTestMat = vMat*dMat*vMat';
            sqrtMat = sqrtm(testMat);
            mlunit.assert_equals(sqrtTestMat, sqrtMat);

            nDim = 3;
            testMat = [5, -4, 1; -4, 6, -4; 1, -4, 5];
            sqrtTestMat = [2, -1, 0; -1, 2, -1; 0, -1, 2];
            sqrtMat = sqrtm(testMat);
            mlunit.assert(norm(sqrtTestMat-sqrtMat) < MAX_TOL);
            
            nDim = 15;
            load(strcat(self.testDataRootDir, strcat(filesep, 'testSqrtm1_inp.mat')), 'testMat');
            sqrtMat = sqrtm(testMat);
            mlunit.assert(norm(testMat-sqrtMat*sqrtMat')<MAX_TOL);
            
            nDim = 15;
            load(strcat(self.testDataRootDir, strcat(filesep, 'testSqrtm2_inp.mat')), 'testMat');
            sqrtMat = sqrtm(testMat);
            mlunit.assert(norm(testMat-sqrtMat*sqrtMat') < MAX_TOL);

        end
    end
    
end

