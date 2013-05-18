function varargout=applyTupleGetFunc(self,varargin)
% APPLYTUPLEGETFUNC - applies a function to the specified fields 
%                     separately to each tuple 
%
% Input:
%   regular:
%       hFunc: function_handle[1,1] - function to apply to the specified
%          fields
%   optional:
%       toFieldNameList: char/cell[1,] of char - a list of fields to which
%          the function specified by hFunc is to be applied
%
%   properties:
%       uniformOutput: logical[1,1] - if true, output is expected to be
%           uniform as in cellfun with 'UniformOutput'=true, default 
%			value is true
%
% Output:
%   funcOut1Arr: <type1>[] - array corresponding to the first output of the
%       applied function
%           ....
%   funcOutNArr: <typeN>[] - array corresponding to the last output of the
%       applied function
%
%
% Notes: this function currently has a lots of limitations:
%   1) the function is applies to SData part of field value
%   2) no additional arguments can be passed
%   All this limitations will eventually go away though so stay tuned...
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-11-28 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
if nargout==0
    self.applyTupleGetFuncInternal(varargin{:});
else
    varargout=cell(1,nargout);
        [varargout{:}]=self.applyTupleGetFuncInternal(varargin{:});
end