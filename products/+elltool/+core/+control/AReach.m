classdef AReach < IReach
    properties (Access = protected)
        linSys
        isCut
        projectionBasisMat
    end
    %
    methods
        function isProj = isprojection(self)
            isProj = ~isempty(self.projectionBasisMat);
        end
        %
        function isCut = iscut(self)
            isCut = self.isCut;
        end
        %
        function [RSdim SSdim] = dimension(self)
            RSdim = self.linSys.dimension();
            if isempty(self.projectionBasisMat)
                SSdim = RSdim;
            else
                SSdim = size(self.projectionBasisMat, 2);
            end
        end
        %
        function linSys = get_system(self)
            linSys = self.linSys;
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
                approxTypeChar = 'e';
            elseif approxTypeChar ~= 'i'
                approxTypeChar = 'e';
            end
            if approxTypeChar == 'i'
                approx = self.get_ia();
                isEmptyIntersect = intersect(approx, intersectObj, 'u');
            else
                approx = self.get_ea();
                n = size(approx, 2);
                isEmptyIntersect = intersect(approx(:, 1), intersectObj, 'i');
                for i = 2 : n
                    isEmptyIntersect =...
                        isEmptyIntersect |...
                        intersect(approx(:, i), intersectObj, 'i');
                end
            end
        end
    end
end