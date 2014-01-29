function varargout=removeDuplicateTuples(self,varargin)
% REMOVEDUPLICATETUPLES - removes all duplicate tuples from the relation
%
% Usage: [indForwardVec,indBackwardVec]=...
%            removeDuplicateTuples(self,varargin)
%
% Input:
%   regular:
%     self: ARelation [1,1] - class object
%
%   properties:
%       replaceNull: logical[1,1] if true, null values are replaced with 
%           certain default values for all fields uniformly across all
%           relation tuples
%               default value is false
%
% Output:
%   optional:
%     indForwardVec: double[nUniqueSlices,1] - indices of unique tuples in
%        the original relation
%
%     indBackwardVec: double[nSlices,1] - indices that map the unique
%        tuples back to the original tuples
%       
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%

varargout=cell(1,nargout);
[varargout{:}]=self.removeDuplicatesAlongDimInternal(1,varargin{:});