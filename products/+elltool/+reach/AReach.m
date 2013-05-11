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
    methods (Access = private)
        function isArr = fApplyArrMethod(self,propertyName,addFunc)
            if nargin < 3
                isArr = arrayfun(@(x) x.(propertyName), self); 
            else
                fApplyToProperty = str2func(addFunc);
                isArr = arrayfun(@(x) fApplyToProperty(x.(propertyName)), self);
            end    
            %in case of empty input array make output logical
            isArr = logical(isArr);  
        end    
    end    
    %
    methods
        function resArr=repMat(self,varargin)
            sizeVec=horzcat(varargin{:});
            resArr=repmat(self,sizeVec);
            resArr=resArr.getCopy();    
        end
        %
        function isNEmp = isNotEmpty(self)
            isNEmp = ~isempty(self.isempty());
        end    
        %
        function isProjArr = isprojection(self)
            isProjArr = fApplyArrMethod(self,'isProj');  
        end
        %
        function isCutArr = iscut(self)
            isCutArr = fApplyArrMethod(self,'isCut');  
        end
        %
        function isEmptyArr = isempty(self)   
            isEmptyArr = fApplyArrMethod(self,'x0Ellipsoid','isempty');
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