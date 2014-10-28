function inpArray=checkcellofstr(inpArray,flagVec,varargin)
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
%   properties:
%       nCallerStackStepsUp: numeric[1,1] - number of steps up in the call
%           stacks for the caller, by which name the full message tag is to
%           be generated, =1 by default
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
import modgen.common.throwerror;
DEFAULT_IS_EMPTY_ALLOWED=false;
DEFAULT_IS_CHECKED_FOR_ROW=true;
%
[~,~,nCallerStackStepsUp]=modgen.common.parseparext(...
        varargin,...
        {'nCallerStackStepsUp';1;...
        'isscalar(x)&&isnumeric(x)&&isreal(x)'},0,...
        'propRetMode','separate');
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
            throwerror('wrongInput',...
                '%s is expected to be a row',inputname(1),...
                'nCallerStackStepsUp',1+nCallerStackStepsUp);
        else
            throwerror('wrongInput',...
                '%s is expected to be a row or empty cell',inputname(1),...
                'nCallerStackStepsUp',1+nCallerStackStepsUp);
        end        
    end
end
if ischar(inpArray)
    inpArray={inpArray};
else
    if ~iscellstr(inpArray)
        throwerror('wrongInput',...
            '%s is expected to be a cell array of strings',...
            inputname(1),'nCallerStackStepsUp',1+nCallerStackStepsUp);
    end
    is2DVec=cellfun('ndims',inpArray)<=2;
    if ~all(is2DVec)
        throwerror('wrongInput',...
            ['%s does have elements on positions %s with ',...
            'dimensionality >2'],mat2str(find(~is2DVec)),...
            'nCallerStackStepsUp',1+nCallerStackStepsUp);
    end
    isRowVec=cellfun('size',inpArray,1)==1;
    if ~all(isRowVec)
        throwerror('wrongInput',...
            ['%s does have elements on positions %s that are ',...
            ' matrices instead of rows'],mat2str(find(~isRowVec)),...
            'nCallerStackStepsUp',1+nCallerStackStepsUp);
    end
end