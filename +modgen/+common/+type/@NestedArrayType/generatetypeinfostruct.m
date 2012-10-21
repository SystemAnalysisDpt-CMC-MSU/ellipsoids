function [isUniform,STypeInfo]=generatetypeinfostruct(value)
% GENERATETYPEINFOSTRUCT constructs a meta structure containing a
% complete (recursive for cells)
% information about type of input array
%
% Input: value - array of any type
%
% Output:
%   isUniform: logical[1,1]
%
%   STypeInfo struct[1,1] containing type information for input
%      array, contains the following fields
%
%      type: char[1,] type of value at the bottom of cell array
%      depth: numeric[1,1] - depth of cell array
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
bottomType='';
bottomLevel=0;
isUniform=true;
generateinternal(value,0);
if ~isUniform
    bottomType='';
    bottomLevel=nan;
end
STypeInfo.type=bottomType;
STypeInfo.depth=bottomLevel;
%
    function updateinternal(level,className)
        if isempty(bottomType)
            if bottomLevel<=level
                bottomLevel=level;
                bottomType=className;
            else
                isUniform=false;
            end
        elseif strcmp(bottomType,className)
            if bottomLevel~=level
                isUniform=false;
            end
        elseif ~isempty(className)
            isUniform=false;
        elseif bottomLevel<level
                isUniform=false;
        end
    end
    function generateinternal(value,level)
        if isUniform
            if iscell(value)
                if ~isempty(value)
                    % try to guess structure of value
                    if iscellstr(value)||modgen.common.iscelllogical(value)||...
                            modgen.common.iscellnumeric(value)
                        %
                        updateinternal(level+1,class(value{1}));
                    else
                        cellfun(@(x)generateinternal(x,level+1),value);
                    end
                else
                    updateinternal(level+1,'');
                end
            else
                updateinternal(level,class(value));
            end
        end
    end
end