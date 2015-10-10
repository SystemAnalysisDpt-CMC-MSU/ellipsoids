function [isPositive,reportStr,signOfDiff]=isEqualScalarInternal(self,...
    obj,varargin)
% ISEQUAL compares a given object with a specified one
import modgen.common.throwerror;
if ~(isscalar(self)&&isscalar(obj))
    throwerror('wrongInput','not implemented for non-scalar inputs');
end
if nargout>1,
    [isPositive,reportStr]=...
        isEqualScalarInternal@smartdb.cubes.CubeStructFieldInfo(...
        self,obj,varargin{:});
    if nargout>2
        signOfDiff=nan;
    end
else
    isPositive=isEqualScalarInternal@smartdb.cubes.CubeStructFieldInfo(...
        self,obj,varargin{:});
end
if ~(isPositive&&isempty(self)||~isPositive)
    isPositive=isequaln(self.sizePatternVec,obj.sizePatternVec)&&...
        isequal(self.isSizeAlongAddDimsEqualOne,...
        obj.isSizeAlongAddDimsEqualOne)&&...
        isequal(self.isUniqueValues,obj.isUniqueValues);
    if nargout>1,
        if ~isPositive,
            reportStr=['size patterns, sizes along additional dimensions '...
                'and/or uniqueness of values flags are different'];
        end
    end
end