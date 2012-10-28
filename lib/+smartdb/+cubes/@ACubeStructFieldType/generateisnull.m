function isNullOutCArray=generateisnull(typeName,depth,inpValueCArray,isNull)
% GENERATEDEFAULTISNULL transforms value vector to isNull vector
% assuming that all the elements are no
%
% Usage: isNullCArray=generatedefaultisnull(typeName,depth,valueCArray)
%        isNullCArray=generatedefaultisnull(typeName,depth,valueCArray,isNull)
% Input:
%   regular:
%       typeName: char[1,] - type of value at the bottom of cell array
%       depth: double[1,1] - depth of cell array
%       valueCArray: array of any size
%
%   optional:
%       isNull - value of is-null indicators   
%
% Output
%   isNullCArray: logical/cell - array of the same size as value consisting of
%       is-null indicators for valueCArray
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-02-20 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
if nargin<4
    isNull=false;
end
isNullOutCArray=geninternal(inpValueCArray,0);
    function isNullCArray=geninternal(valueCArray,level)
        import modgen.common.throwerror;
        if iscell(valueCArray)
            if ~isempty(valueCArray)
                if iscellstr(valueCArray)
                    if isNull
                        isNullCArray=true(size(valueCArray));
                    else
                        isNullCArray=false(size(valueCArray));
                    end
                else
                    isNullCArray=cellfun(@(x)geninternal(x,level+1),...
                        valueCArray,'UniformOutput',false);
                end
            else
                if depth<level+1
                    throwerror('wrongInput',...
                        'depth is not consistent with valueCArray');
                elseif depth==level+1&&strcmp(typeName,'char')
                    if isNull
                        isNullCArray=true(size(valueCArray));
                    else
                        isNullCArray=false(size(valueCArray));
                    end
                else
                    isNullCArray=cell(size(valueCArray));
                end
            end
        else
            if isNull
                isNullCArray=true(size(valueCArray));
            else
                isNullCArray=false(size(valueCArray));
            end
        end
    end
end