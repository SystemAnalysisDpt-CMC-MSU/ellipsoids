function resArray=buildArrayByProp(self,varargin)
% BUILDARRAYBYPROP is a helper method for filling an object array with
% the specified properties
% 
% Input:
%   regular:
%       self: CubeStructFieldExtendedInfo[1,1]
%       cubeStructRefList: cell[n1,n2,...,n_k] of CubeStruct objects
%   properties:
%       regular:
%          nameList: cell[n1,n2,...,n_k] of char[1,] - field name
%       optional:
%          descriptionList: cell[n1,n2,...,n_k] of char[1,] - field description
%          typeSpecList: cell[n1,n2,...,n_k] of cell[1,] of char - field type 
%              specification , 
%                  Example:  {'cell','char'}
%          typeList: cell[n1,n2,...,n_k] of modgen.common.type.ANestedArrayType
%          sizePatternVecList: cell[n1,n2,...,n_k] of double[1,nDims_i]
%          isSizeAlongAddDimsEqualOneMat: logical[n1,n2,...,n_k]
%          isUniqueValuesMat: logical[n1,n2,...,n_k]
% 
% Output:
%   resArray[n1,n2,...,n_k] - constructed array of CubeStructFieldExtendedInfo
%      objects
%
%
% $Author: Ilya Roubelv  <iroublev@gmail.com> $	$Date: 2014-07-11 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2014 $
%
%
%
import modgen.common.throwerror;
[reg,~,sizePatternVecList,isSizeAlongAddDimsEqualOneMat,isUniqueValuesMat,...
    isSizePatternVecListPassed,isSizeAlongAddDimsEqualOneMatPassed,...
    isUniqueValuesMatPassed]=modgen.common.parseparext(varargin,{...
    'sizePatternVecList','isSizeAlongAddDimsEqualOneMat','isUniqueValuesMat'},...
    'propRetMode','separate');
resArray=buildArrayByProp@smartdb.cubes.CubeStructFieldInfo(self,reg{:});
if isempty(resArray),
    return;
end
expSizeVec=size(resArray);
%
if isSizePatternVecListPassed,
    if ~isequal(size(sizePatternVecList),expSizeVec)
        throwerror('wrongInput',...
            'sizePatternVecList is expected to have size %s',mat2str(expSizeVec));
    end
    if ~iscell(sizePatternVecList),
        throwerror('wrongInput',[...
            'sizePatternVecList is expected to be a cell array of numeric '...
            'row vectors']);
    end
    [resArray.sizePatternVec]=deal(sizePatternVecList{:});
end
if isSizeAlongAddDimsEqualOneMatPassed,
   if ~isequal(size(isSizeAlongAddDimsEqualOneMat),expSizeVec)
        throwerror('wrongInput',...
            'isSizeAlongAddDimsEqualOneMat is expected to have size %s',mat2str(expSizeVec));
   end
   if ~islogical(isSizeAlongAddDimsEqualOneMat),
       throwerror('wrongInput',...
           'isSizeAlongAddDimsEqualOneMat is expected to be logical matrix');
   end
   isSizeAlongAddDimsEqualOneMat=num2cell(isSizeAlongAddDimsEqualOneMat);
   [resArray.isSizeAlongAddDimsEqualOne]=deal(isSizeAlongAddDimsEqualOneMat{:});
end
if isUniqueValuesMatPassed,
   if ~isequal(size(isUniqueValuesMat),expSizeVec)
        throwerror('wrongInput',...
            'isUniqueValuesMat is expected to have size %s',mat2str(expSizeVec));
   end
   if ~islogical(isUniqueValuesMat),
       throwerror('wrongInput',...
           'isUniqueValuesMat is expected to be logical matrix');
   end
   isUniqueValuesMat=num2cell(isUniqueValuesMat);
   [resArray.isUniqueValues]=deal(isUniqueValuesMat{:});
end