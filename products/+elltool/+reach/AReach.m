classdef AReach < elltool.reach.IReach
%$Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $
%$Date: March-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2012 $
%
    properties (Access = protected)
        switchSysTimeVec
        x0Ellipsoid
        linSysCVec
        isCut
        isProj
        isBackward
        projectionBasisMat
    end
    %
    properties (Constant, Access = private)
        EXTERNAL = 'e'
        INTERNAL = 'i'
        UNION = 'u'
    end
    %
    methods
        function isProj = isprojection(self)
            isProj = self.isProj;
        end
        %
        function isCut = iscut(self)
            isCut = self.isCut;
        end
        %
        function isEmpty = isempty(self)
            isEmpty = isempty(self.x0Ellipsoid);
        end
        %
        function isEmptyIntersect =...
                intersect(self, intersectObj, approxTypeChar)
            if ~(isa(intersectObj, 'ellipsoid')) &&...
                    ~(isa(intersectObj, 'hyperplane')) &&...
                    ~(isa(intersectObj, 'polytope'))
                throwerror(['INTERSECT: first input argument must be ',...
                    'ellipsoid, hyperplane or polytope.']);
            end
            if (nargin < 3) || ~(ischar(approxTypeChar))
                approxTypeChar = self.EXTERNAL;
            elseif approxTypeChar ~= self.INTERNAL
                approxTypeChar = self.EXTERNAL;
            end
            if approxTypeChar == self.INTERNAL
                approxCVec = self.get_ia();
                isEmptyIntersect =...
                    intersect(approxCVec, intersectObj, self.UNION);
            else
                approxCVec = self.get_ea();
                approxNum = size(approxCVec, 2);
                isEmptyIntersect =...
                    intersect(approxCVec(:, 1),...
                    intersectObj, self.INTERNAL);
                for iApprox = 2 : approxNum
                    isEmptyIntersect =...
                        isEmptyIntersect |...
                        intersect(approxCVec(:, iApprox),...
                        intersectObj, self.INTERNAL);
                end
            end
        end
    end
end