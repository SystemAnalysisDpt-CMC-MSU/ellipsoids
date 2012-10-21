function resCell = num2cell(inpArray,varargin)
% MODGEN.COMMON.NUM2CELL is an extension of Matlab built-in function
% num2cell designed to work correctly with empty arrays (such as
% zero(10,0)) for instance
%
% Input and Output arguments are the same as for built-in num2cell function
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-09-09 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
import modgen.common.throwerror;
if ~isempty(inpArray)
    resCell=num2cell(inpArray,varargin{:});
elseif nargin==1
    resCell=cell(size(inpArray));
elseif nargin==2
    dimVec=varargin{1};
    sizeVec=[size(inpArray),ones(1,max(dimVec)-ndims(inpArray))];
    inpArg=num2cell(sizeVec);
    isBreak=true(size(sizeVec));
    isBreak(dimVec)=false;
    inpArg(isBreak)=cellfun(@(x)ones(1,x),inpArg(isBreak),'UniformOutput',false);
    resCell=mat2cell(inpArray,inpArg{:});
else
    throwerror('wrongInput','number of input arguments should not exceed 2');
end
    