function inpArray=checkcellofstr(inpArray,flagVec)
% CHECKCELLOFSTR checks that input variable is either a char or cell of
% strings (char is converted to a cell), in case validation fails an
% exception is thrown
%
% Input:
%   regular:
%       inpArray: anyType[]
%   optional:
%       flagVec: logical[1,2] - contains the following flags
%           isEmptyAllowed: logical[1,1] - if true, {} passes the check and
%               causes an exception otherwise, false by default
%           isCheckedForBeingARow: logical[1,1] - if true, in 
%               case inpArray is cell, it is expected to be a row
%
% Output:
%   inpArray: cell[1,] of char[1,]
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-10-14 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
DEFAULT_IS_EMPTY_ALLOWED=false;
DEFAULT_IS_CHECKED_FOR_ROW=true;
%
if nargin==1
    flagVec=[DEFAULT_IS_EMPTY_ALLOWED,DEFAULT_IS_CHECKED_FOR_ROW];
elseif numel(flagVec)==1
    flagVec=[flagVec,DEFAULT_IS_CHECKED_FOR_ROW];
end
isEmptyAllowed=flagVec(1);
isCheckedForBeingARow=flagVec(2);
% 
if isCheckedForBeingARow
    if ~(modgen.common.isrow(inpArray)||isEmptyAllowed&&isempty(inpArray))
        if ~isEmptyAllowed
            error([upper(mfilename),':wrongInput'],...
                '%s is expected to be a row',inputname(1));
        else
            error([upper(mfilename),':wrongInput'],...
                '%s is expected to be a row or empty cell',...
                inputname(1));
        end        
    end
end
if ischar(inpArray)
    inpArray={inpArray};
else
    if ~iscellstr(inpArray)
        error([upper(mfilename),':wrongInput'],...
            '%s is expected to be a cell array of strings',inputname(1));
    end
    is2DVec=cellfun('ndims',inpArray)<=2;
    if ~all(is2DVec)
        error([upper(mfilename),':wrongInput'],...
            ['%s does have elements on positions %s with ',...
            'dimensionality >2'],mat2str(find(~is2DVec)));
    end
    isRowVec=cellfun('size',inpArray,1)==1;
    if ~all(isRowVec)
        error([upper(mfilename),':wrongInput'],...
            ['%s does have elements on positions %s that are ',...
            ' matrices instead of rows'],mat2str(find(~isRowVec)));
    end
end