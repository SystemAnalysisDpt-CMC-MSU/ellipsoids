function sortByAlongDimInternal(self,sortFieldNameList,sortDim,varargin)
% SORTBY sorts data of given CubeStruct object along the specified
% dimension using the specified fields
%
% Usage: sortByInternal(self,sortFieldNameList,varargin)
%
% input:
%   regular:
%     self: CubeStruct [1,1] - class object
%     sortFieldNameList: char or char cell [1,nFields] - list of field
%         names with respect to which field content is sorted
%     sortDim: numeric[1,1] - dimension number along which the sorting is
%        to be performed
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
sortInd=self.getSortIndexInternal(sortFieldNameList,sortDim,varargin{:});
self.reorderDataInternal({sortInd},sortDim);