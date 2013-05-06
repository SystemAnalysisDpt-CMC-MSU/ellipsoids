classdef AReach < elltool.reach.IReach
% Kirill Mayantsev
% <kirill.mayantsev@gmail.com>$  
% $Date: March-2013 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics 
%             and Computer Science, 
%             System Analysis Department 2013$
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
        function isProjArr = isprojection(self)
            import modgen.common.throwerror;
            if sum(size(self)<=0)
                throwerror('wrongInput:badDimensionality',...
                        'each dimension of an object array should be a positive number');
            end    
            isProjArr = arrayfun(@(x) x.isProj, self);   
        end
        %
        function isCutArr = iscut(self)
            import modgen.common.throwerror;
            if sum(size(self)<=0)
                throwerror('wrongInput:badDimensionality',...
                        'each dimension of an object array should be a positive number');
            end  
            isCutArr = arrayfun(@(x) x.isCut, self);
        end
        %
        function isEmptyArr = isempty(self)
            import modgen.common.throwerror;
            if sum(size(self)<=0)
                throwerror('wrongInput:badDimensionality',...
                        'each dimension of an object array should be a positive number');
            end  
            isEmptyArr = arrayfun(@(x) isEmp(x), self);
            function isEmpty = isEmp(reachObj)
                isEmpty = isempty(reachObj.x0Ellipsoid);
            end    
        end
        %
        function absTolArr = getAbsTol(self)
            import modgen.common.throwerror;
            if sum(size(self)<=0)
                throwerror('wrongInput:badDimensionality',...
                        'each dimension of an object array should be a positive number');
            end  
            absTolArr = arrayfun(@(x) x.linSysCVec{end}.getAbsTol(), self);
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