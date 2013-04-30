function varargout=getUniqueData(self,varargin)
% GETUNIQUEDATA - returns internal representation for a set of unique 
%                 tuples for given relation
%
% Usage: [SData,SIsNull,SIsValueNull]=getUniqueData(self,varargin)
%
% Input:
%   regular:
%     self: ARelation [1,1] - class object
%   properties
%       fieldNameList: list of field names used for finding the unique
%           elements; only the specified fields are returned in SData,
%           SIsNull,SIsValueNull structures
%       structNameList: list of internal structures to return (by default it
%           is {SData, SIsNull, SIsValueNull}
%       replaceNull: logical[1,1] if true, null values are replaced with 
%           certain default values uniformly across all the tuples
%               default value is false
%
% Output:
%   regular:
%
%     SData: struct [1,1] - structure containing values of fields in
%         selected tuples, each field is an array containing values of the
%         corresponding type
%
%     SIsNull: struct [1,1] - structure containing info whether each value
%         in selected tuples is null or not, each field is either logical
%         array or cell array containing logical arrays
%
%     SIsValueNull: struct [1,1] - structure containing a
%        logical array [nTuples,1] for each of the fields (true
%        means that a corresponding cell doesn't not contain
%           any value
%
%     indForward: double[1,nUniqueTuples] - indices of unique entries in
%        the original tuple set
%
%     indBackward: double[1,nTuples] - indices that map the unique tuple
%        set back to the original tuple set
%       
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-08-17 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
if nargout>0
    varargout=cell(1,nargout);
    [varargout{:}]=self.getUniqueDataAlongDimInternal(1,varargin{:});
else
    self.getUniqueDataAlongDimInternal(1,varargin{:});
end