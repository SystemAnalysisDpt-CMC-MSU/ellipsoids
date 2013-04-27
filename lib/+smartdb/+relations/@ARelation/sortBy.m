function sortBy(self,sortFieldNameList,varargin)
% SORTBY - sorts all tuples of given relation with respect to some of its
%          fields
%
% Usage: sortBy(self,sortFieldNameList,varargin)
%
% input:
%   regular:
%     self: ARelation [1,1] - class object
%     sortFieldNameList: char or char cell [1,nFields] - list of field
%         names with respect to which tuples are sorted
%   properties:
%     direction: char or char cell [1,nFields] - direction of sorting for
%         all fields (if one value is given) or for each field separately;
%         each value may be 'asc' or 'desc'
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
self.sortByAlongDimInternal(sortFieldNameList,1,varargin{:});