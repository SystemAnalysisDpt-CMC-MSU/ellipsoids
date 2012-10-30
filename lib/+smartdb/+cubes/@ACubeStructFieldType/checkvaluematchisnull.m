function [isOk,SValueTypeInfo]=checkvaluematchisnull(minDimensionality,isSpecified,value,isNull,isValueNull)
% CHECKVALUEMATCHISNULL checks that the types and sizes of the value,isNull and
% isValueNull matrices are consistent
%
% Input: 
%   regular
%       minDimensionality: numeric[1,1] - minimum dimensionality allowed
%           for input values
%           value: any matrix
%       isSpecified: logical[1,1]/logical[1,3] - determines which of three
%           SData, SIsNull and SIsValueNull data elements are on input
%       
%   optional:
%       isNull: vector of is-null indicators for content of elements 
%           from value matrix
%       isValueNull: vector of is-null indicators for elements of value
%          matrix
%       minDimensionality: numeric[1,1] - number of the first dimensions
%          for which the value sizes should be check
%
% Output:
%   isPosivite: logical[1,1] true means that the types and sizes of inputs
%      are consistent
%
%   STypeInfo struct[1,1] containing type information for input value
%      array, contains the following fields
%   
%      type: char[1,] - type of value at the bottom of the cell array
%      depth: double[1,1] - depth of cell array
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
import modgen.common.*;
if ~(islogical(isSpecified)&&modgen.common.isrow(isSpecified))
    if isempty(isSpecified)
        isSpecified=false(1,3);
        isSpecified(1:(nargin-2))=true;
    else
        error([upper(mfilename),':wrongInput'],...
            'isSpecified parameter is expected to be a logical row-vector');
    end
end
if numel(isSpecified)~=3
    error([upper(mfilename),':wrongInput'],...
        'isSpecified is expected to contain exactly 3 elements');
end
%
if ~isSpecified(1)
    error([upper(mfilename),':wrongInput'],...
        'value element of data is obligatory');
end
if any(isSpecified((nargin-1):end))
    error([upper(mfilename),':wrongInput'],...
        'isSpecified is inconsistent with the rest of input arguments');
end
%
if isSpecified(3)
    minDimensionSizeVec=getfirstdimsize(value,minDimensionality);
    isOk=islogical(isValueNull)&&auxchecksize(isValueNull,minDimensionSizeVec);
    %
    if ~isOk
        return;
    end
end
%
[isOk,SValueTypeInfo]=modgen.common.type.NestedArrayType.generatetypeinfostruct(value);
%
if ~isOk
    return;
end
%
if isSpecified(2)
    isOk=smartdb.cubes.ACubeStructFieldType.checkvaluematchisnull_aux(value,isNull);
end

    
  