function [isPositive,reportStr]=isEqual(self,obj,varargin)
% ISEQUAL compares a given object with a specified one
if nargout>1,
    [isPositive,reportStr]=isEqual@smartdb.cubes.CubeStructFieldInfo(self,obj,varargin{:});
else
    isPositive=isEqual@smartdb.cubes.CubeStructFieldInfo(self,obj,varargin{:});
end
if isPositive&&isempty(self)||~isPositive
    return;
end
isPositive=isequaln(self.getSizePatternVecList,obj.getSizePatternVecList)&&...
    isequal(self.getIsSizeAlongAddDimsEqualOneMat,obj.getIsSizeAlongAddDimsEqualOneMat)&&...
    isequal(self.getIsUniqueValuesMat,obj.getIsUniqueValuesMat);
if nargout>1,
    if ~isPositive,
        reportStr=['size patterns, sizes along additional dimensions '...
            'and/or uniqueness of values flags are different'];
    end
end