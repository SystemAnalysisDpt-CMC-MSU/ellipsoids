classdef SuiteBasic < mlunitext.test_case
    properties
    end
    %
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up_param(self,varargin)
        %
        end
        %
        function testSpherePart(self)
            CALC_PRECISION = 1e-14;
            %
            numPointsVec = [1,2,3,20,21,22,41,42,43,100];
            arrayfun(@testForNPoints, numPointsVec);
            %
            function testForNPoints(nPoints)
                pMat = gras.geom.spherepart(nPoints);
                normVec = realsqrt(sum(pMat.*pMat,2));
                %
                mlunitext.assert(size(pMat,1)==nPoints);
                mlunitext.assert(size(pMat,2)==3);
                mlunitext.assert(all(abs(normVec-1)<CALC_PRECISION));
            end
        end
    end
end