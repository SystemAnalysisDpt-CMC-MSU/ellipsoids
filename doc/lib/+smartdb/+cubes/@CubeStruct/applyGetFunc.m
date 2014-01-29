function resVec=applyGetFunc(self,varargin)
% APPLYGETFUNC - applies a function to the specified fields as columns, i.e.
%                the function is applied to each field as whole, not to 
%                each cell separately
%
% Input:
%   regular:
%       hFunc: function_handle[1,1] - function to apply to each of the
%          field values
%   optional:
%       toFieldNameList: char/cell[1,] of char - a list of fields to which
%          the function specified by hFunc is to be applied
%   
%     Note: hFunc can optionally be specified after toFieldNameList 
%           parameter
%
% Notes: this function currently has a lots of limitations:
%   1) it assumes that the output is uniform
%   2) the function is applies to SData part of field value
%   3) no additional arguments can be passed
%   All this limitations will eventually go away though so stay tuned...
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
self.prohibitProperty('SData',varargin);
resVec=self.applyGetFuncInternal(varargin{:});