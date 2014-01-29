function sortInd=getSortIndex(self,sortFieldNameList,varargin)
% GETSORTINDEX - gets sort index for all tuples of given relation with
%                respect to some of its fields
%
% Usage: sortInd=getSortIndex(self,sortFieldNameList,varargin)
%
% input:
%   regular:
%     self: ARelation [1,1] - class object
%     sortFieldNameList: char or char cell [1,nFields] - list of field   
%        names with respect to which tuples are sorted
%
%   properties:
%     Direction: char or char cell [1,nFields] - direction of sorting for
%         all fields (if one value is given) or for each field separately;
%         each value may be 'asc' or 'desc'
% output:
%   regular:
%    sortIndex: double [nTuples,1] - sort index for all tuples such that if
%        fieldValueVec is a vector of values for some field of given
%        relation, then fieldValueVec(sortIndex) is a vector of values for
%        this field when tuples of the relation are sorted
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
%% Get properties
sortInd=self.getSortIndexInternal(sortFieldNameList,1,varargin{:});