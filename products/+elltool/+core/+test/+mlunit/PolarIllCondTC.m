classdef PolarIllCondTC < mlunitext.test_case
    %$Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $
    %$Date: 2015-11-09 $
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2015 $

    methods (Access=private)
        function testEllObj = getTest(~)
            testEllObj = elltool.core.test.mlunit.aux.TestPolarEllipsoid();
        end
    end
    methods
        function self = PolarIllCondTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function self = testGetScalarPolar(self)
            K_TOL = 1e-2;
            DIM_VEC=2:11;
            isnOverflowVec=arrayfun(@(x)min(eig(inv(hilb(x)))),DIM_VEC)>0;
            dimVec=DIM_VEC(isnOverflowVec);
            [~, N_TESTS] = size(dimVec);
            %
            isRobustBetterVec=zeros(N_TESTS, 1);
            isMethodsSimVec=zeros(N_TESTS, 1);
            %
            for iElem = 1:N_TESTS
                N_DIMS = dimVec(iElem);
                shMat = hilb(N_DIMS);
                expShMat = invhilb(N_DIMS);
                ell1 = ellipsoid(shMat);
                [sh1Mat, sh2Mat] = self.auxGetTestPolars(ell1);
                isRobustBetterVec(iElem)=...
                    norm(expShMat-sh1Mat)<=norm(expShMat-sh2Mat);
                
                isMethodsSimVec(iElem)=...
                    norm(sh1Mat-sh2Mat) < K_TOL;
            end
            %
            mlunitext.assert(any(isMethodsSimVec));
            mlunitext.assert(any(~isMethodsSimVec));
            %
            mlunitext.assert(any(isRobustBetterVec));
            mlunitext.assert(any(~isRobustBetterVec));
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