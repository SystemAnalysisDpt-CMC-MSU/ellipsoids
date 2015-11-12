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
        function self = testGetScalarPolar(self)
            N_DIMS = 11;
            shMat = hilb(N_DIMS);
            expShMat = invhilb(N_DIMS);
            ell1 = ellipsoid(shMat);
            [sh1Mat, sh2Mat] = auxGetTestPolars(ell1);
            mlunitext.assert(norm(expShMat - sh1Mat) <= norm(expShMat - sh2Mat));
        end 
        function self = testGetScalarPolarMethodsDifference(self)
            K_TOL = 1e-2;
            check(5, true);
            check(11, false);   
            %
            function check(N_DIMS,expVal)                
                ell1 = ellipsoid(0.01 * ones(N_DIMS,1),hilb(N_DIMS));
                [sh1Mat, sh2Mat] = auxGetTestPolars(ell1);
                mlunitext.assert((norm(sh1Mat - sh2Mat) < K_TOL) == expVal);
            end
        end
       
        function [sh1Mat, sh2Mat] = auxGetTestPolars(ell)
            polar1Obj = self.getScalarPolarTest(ell,true);
            [~, sh1Mat] = double(polar1Obj);
            polar2Obj = self.getScalarPolarTest(ell,false);
            [~, sh2Mat] = double(polar2Obj);
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