function inpArray=checkcelloffunc(inpArray,isEmptyAllowed,varargin)
% CHECKCELLOFFUNC checks that input variable is either a function_handle 
% of cell of function_handle (char is converted to a cell), 
% in case validation fails an exception is thrown
%
% Input:
%   regular:
%       inpArray: anyType[]
%   optional:
%       isEmptyAllowed: logical[1,1] - if true, {} passes the check and
%           causes an exception otherwise, false by default
%   properties:
%       nCallerStackStepsUp: numeric[1,1] - number of steps up in the call
%           stacks for the caller, by which name the full message tag is to
%           be generated, =1 by default
% Output:
%   inpArray: cell[1,] of char[1,]
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-07-30 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
import modgen.common.throwerror;
[~,~,nCallerStackStepsUp]=modgen.common.parseparext(...
        varargin,...
        {'nCallerStackStepsUp';1;...
        'isscalar(x)&&isnumeric(x)&&isreal(x)'},0,...
        'propRetMode','separate');
if nargin==1
    isEmptyAllowed=false;
end
% 
if ~(modgen.common.isrow(inpArray)||isEmptyAllowed&&isempty(inpArray))
    if ~isEmptyAllowed
        throwerror('wrongInput',...
            '%s is char is expected to be a row',inputname(1),...
            'nCallerStackStepsUp',1+nCallerStackStepsUp);
    else
        throwerror('wrongInput',...
            '%s is char is expected to be a row or empty cell',...
            inputname(1),'nCallerStackStepsUp',1+nCallerStackStepsUp);
    end        
end
if isa(inpArray,'function_handle')
    inpArray={inpArray};
elseif ~iscell(inpArray)
    throwerror('wrongInput',...
        'input array should be either function_handle or cell',...
        'nCallerStackStepsUp',1+nCallerStackStepsUp);
else
    if ~all(cellfun('isclass',inpArray,'function_handle'))
        throwerror('wrongInput',...
            '%s is expected to be a cell array of function_handles',...
            inputname(1),'nCallerStackStepsUp',1+nCallerStackStepsUp);
    end
end