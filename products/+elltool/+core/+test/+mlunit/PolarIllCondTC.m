classdef PolarIllCondTC < mlunitext.test_case &...
        elltool.core.test.mlunit.TestEllipsoid
    %$Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $
    %$Date: 2015-11-09 $
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2015 $

    methods
        function self = PolarIllCondTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
            self =...
               self@elltool.core.test.mlunit.TestEllipsoid(varargin{:});
        end
        function self = testGetScalatPolar(self)
            
        end
        function self = testGetScalarPolarMethodsDifference(self)
            K_TOL = 1e-2;
            check(5, true);
            check(11, false);   
            %
            function check(N_DIMS,expVal)                
                ell1 = ellipsoid(0.01 * ones(N_DIMS,1),hilb(N_DIMS));
                polarObj1 = self.getScalarPolarTest(ell1,true);
                polarObj2 = self.getScalarPolarTest(ell1,false);
                [~,shMat1] = double(polarObj1);
                [~,shMat2] = double(polarObj2);
                mlunitext.assert((norm(shMat1 - shMat2) < K_TOL) == expVal);
            end
        end
       
            function self = testNegative(self)
            self.runAndCheckError(@run,'degenerateEllipsoid');
            function run()
                ell1 = ellipsoid(ones(2,1),eye(2));
                self.getScalarPolarTest(ell1,true);
            end
        end
    end
end