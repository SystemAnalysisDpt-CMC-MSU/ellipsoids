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
            kTol = 1e-2;
            %
            nDims = 5;
            ell1 = ellipsoid(0.01 * ones(nDims, 1), hilb(nDims));
            polarObj1 = self.getScalarPolarTest(ell1, true);
            polarObj2 = self.getScalarPolarTest(ell1, false);
            [~, shMat1] = double(polarObj1);
            [~, shMat2] = double(polarObj2);
            mlunitext.assert(norm(shMat1 - shMat2) < kTol);
            %
            nDims = 11;
            ell1 = ellipsoid(0.01 * ones(nDims, 1), hilb(nDims));
            polarObj1 = self.getScalarPolarTest(ell1, true);
            polarObj2 = self.getScalarPolarTest(ell1, false);
            [~, shMat1] = double(polarObj1);
            [~, shMat2] = double(polarObj2);
            mlunitext.assert(norm(shMat1 - shMat2) > kTol);
        end
       
    end
end