function [isPositive,reportStr]=isEqual(self,obj,isCubeStructCompared,...
    cubeStructCompareParamList)
% ISEQUAL compares a given object with a specified one
if nargin<4
    cubeStructCompareParamList={};
end
if nargin<3
    isCubeStructCompared=false;
end
isEqSize=isequal(size(self),size(obj));
reportStr='';
if isEqSize
    if isempty(self)
        isPositive=true;
        return;
    else
        isPositive=isequal(self.getNameList,obj.getNameList)&&...
            isequal(self.getDescriptionList,obj.getDescriptionList);
        if ~isPositive
            if nargout>1
                reportStr='Names and/or descriptions are different)';
            end
            return;            
        end
    end
else
    isPositive=false;
    if nargout>1
        reportStr='Number of fields is different';
    end
    return;
end
%
isPositiveVec=cellfun(@isequal,self.getTypeList,obj.getTypeList);
isPositive=all(isPositiveVec(:));
%
if ~isPositive
    if nargout>1,
        reportStr='Types are different';
    end
    return;
end
%
if isCubeStructCompared
    leftCubeStructList=self.getCubeStructRefList();
    rightCubeStructList=obj.getCubeStructRefList();
    %
    if numel(leftCubeStructList)>1,
        isLeftCubeStructEqual=isequal(leftCubeStructList{:},...
            'compareMetadataBackwardRef',false);
    else
        isLeftCubeStructEqual=true(size(leftCubeStructList));
    end
    if numel(rightCubeStructList)>1,
        isRightCubeStructEqual=isequal(rightCubeStructList{:},...
            'compareMetadataBackwardRef',false);
    else
        isRightCubeStructEqual=true(size(rightCubeStructList));
    end
    %
    if xor(isLeftCubeStructEqual,isRightCubeStructEqual)
        isPositive=false;
        return;
    end
    nLefts=numel(leftCubeStructList);
    if isLeftCubeStructEqual&&isRightCubeStructEqual
        if nLefts>1
            isPositive=eq(leftCubeStructList{1},...
                leftCubeStructList{2},cubeStructCompareParamList{:});
        else
            isPositive=true;
        end
    else
        isPositiveVec=cellfun(@(x,y)eq(x,y,...
            cubeStructCompareParamList{:}),...
            self.getCubeStructRefList(),...
            obj.getCubeStructRefList());
        isPositive=all(isPositiveVec(:));
    end
    %
    if nargout>1,
        if ~isPositive,
            reportStr='CubeStruct reference lists are different';
        end
    end
end