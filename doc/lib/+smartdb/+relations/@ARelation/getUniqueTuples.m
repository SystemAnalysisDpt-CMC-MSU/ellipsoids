function varargout=getUniqueTuples(self,varargin)
% GETUNIQUETUPLES - returns a relation containing the unique tuples from 
%                   the original relation
%
% Usage: [resRel,indForwardVec,indBackwardVec]=getUniqueTuples(self,varargin)
%
% Input:
%   regular:
%     self: ARelation [1,1] - class object
%   properties
%       fieldNameList: list of field names used for finding the unique
%          tuples
%       structNameList: list of internal structures to return (by default it
%           is {SData, SIsNull, SIsValueNull}
%       replaceNull: logical[1,1] if true, null values are replaced with 
%           certain default values uniformly across all the tuples
%               default value is false
%
% Output:
%   regular:
%
%     resRel: ARelation[1,1] - resulting relation
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
    [~,~,~,indForwardVec,indBackwardVec]=...
        self.getUniqueDataAlongDimInternal(1,varargin{:});
    resRel=self.getTuples(indForwardVec);
    varargout{1}=resRel;
    if nargout>1
        varargout{2}=indForwardVec;
        if nargout>2
            varargout{3}=indBackwardVec;
        end
    end
else
    self.getUniqueDataAlongDimInternal(1,varargin{:});
end