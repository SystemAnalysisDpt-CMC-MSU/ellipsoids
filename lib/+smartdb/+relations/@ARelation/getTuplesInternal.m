function varargout=getTuplesInternal(self,varargin)
% GETTUPLESINTERNAL returns internal representation of tuples for given
% relation
%
% Input:
%   regular:
%       self: ARelation [1,1] - class object
%   optional:
%       subIndVec: double [nSubTuples,1] - array of indices for
%         tuples that are selected to be returned; if not given
%         (default), all tuples are to be returned
%   properties:
%       fieldNameList: list of field names to return
%       structNameList: list of internal structures to return (by default it
%           is {SData, SIsNull, SIsValueNull}
%       replaceNull: logical[1,1] if true, null values are replaced with 
%           certain default values uniformly across all the tuples
%               default value is false
%
% Output:
%   regular:
%     SData: struct [1,1] - structure containing values of
%         fields in selected tuples, each field is an array
%         containing values of the corresponding type
%
%     SIsNull: struct [1,1] - structure containing a nested
%         array with is-null indicators for each relation cell content
%
%     SIsValueNull: struct [1,1] - structure containing a
%        logical array [nTuples,1] for each of the fields (true
%        means that a corresponding cell doesn't not contain
%           any value
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
%
[reg,prop]=parseparams(varargin);
nReg=length(reg);
if nReg>=1
    reg{1}={reg{1}};
end
if nargout>0
    varargout=cell(1,nargout);
    [varargout{:}]=self.getDataInternal(reg{:},prop{:});
else
    self.getDataInternal(reg{:},prop{:});
end