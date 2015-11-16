classdef PolarIllCondTC < mlunitext.test_case
    %$Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $
    %$Date: 2015-11-09 $
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2015 $

    methods (Access=private)
        function testEllObj = getTest(self)
            testEllObj = elltool.core.test.mlunit.aux.TestPolarEllipsoid();
        end
    end
    methods
        function self = PolarIllCondTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function self = testGetScalarPolar(self)
            check(6, true);
            check(8, false);
            
            function check(N_DIMS, expRobustBetter)
                shMat = hilb(N_DIMS);
                expShMat = invhilb(N_DIMS);
                ell1 = ellipsoid(shMat);
                [sh1Mat, sh2Mat] = self.auxGetTestPolars(ell1);
                isRobustBetter = ...
                    (norm(expShMat-sh1Mat)<=norm(expShMat-sh2Mat));
                mlunitext.assert(isRobustBetter == expRobustBetter);
            end
        end     
        function self = testGetScalarPolarMethodsDifference(self)
            K_TOL = 1e-2;
            check(5, true);
            check(11, false);   
            %
            function check(N_DIMS,expVal)                
                ell1 = ellipsoid(0.01 * ones(N_DIMS,1),hilb(N_DIMS));
                [sh1Mat, sh2Mat] = self.auxGetTestPolars(ell1);
                mlunitext.assert((norm(sh1Mat-sh2Mat) < K_TOL) == expVal);
            end
        end
       
        function [sh1Mat, sh2Mat] = auxGetTestPolars(self,ell)
            testEllObj = self.getTest();
            polar1Obj = testEllObj.getScalarPolarTest(ell,true);
            [~, sh1Mat] = double(polar1Obj);
            polar2Obj = testEllObj.getScalarPolarTest(ell,false);
            [~, sh2Mat] = double(polar2Obj);
        end

        function self = testNegative(self)
            self.runAndCheckError(@run,'degenerateEllipsoid');
            %
            function run()
                ell1 = ellipsoid(ones(2,1),eye(2));
                testEllObj = self.getTest();
                testEllObj.getScalarPolarTest(ell1,false);
            end
        end
    end
end