function reorderDataInternal(self,varargin)
% REORDERDATA - reorders cells of CubeStruct object along the specified
%               dimensions according to the specified index vectors
%
% Input:
%   regular:
%       self: CubeStruct [1,1] - the object
%       subIndCVec: numeric[1,]/cell[1,nDims] of double [nSubElem_i,1] 
%           for i=1,...,nDims array of indices of field value slices that  
%           are selected to be returned; 
%           if not given (default), no indexation is performed
%       
%   optional:
%       dimVec: numeric[1,nDims] - vector of dimension numbers
%           corresponding to subIndCVec
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
[reg,prop]=modgen.common.parseparams(varargin);
if ~isempty(prop)
    error([upper(mfilename),':wrongInput'],...
        'no properties is expected');
end
%
if numel(reg)==0
    error([upper(mfilename),':wrongInput'],...
        'at least one regular parameter is expected');
end
%
[self.SData self.SIsNull self.SIsValueNull]=self.getDataInternal(reg{:});