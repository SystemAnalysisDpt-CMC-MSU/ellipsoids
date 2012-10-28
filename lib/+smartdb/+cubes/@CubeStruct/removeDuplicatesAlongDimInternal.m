function varargout=removeDuplicatesAlongDimInternal(self,varargin)
% REMOVEDUPLICATESALONGDIM removes duplicates in CubeStruct object 
% along a specified dimension 
%
% Usage: [indForwardVec,indBackwardVec]=...
%            removeDuplicatesAlongDimInternal(self,catDim,varargin)
%
% Input:
%   regular:
%     self:
%     catDim: double[1,1] - dimension number along which uniqueness is
%        checked
%
%   properties:
%       replaceNull: logical[1,1] if true, null values are replaced with 
%           certain default values uniformly across all CubeStruct cells
%               default value is false
%
% Output:
%   optional:
%     indForwardVec: double[nUniqueSlices,1] - indices of unique entries in
%        the original CubeStruct data set
%
%     indBackwardVec: double[nSlices,1] - indices that map the unique data set
%        set back to the original data set
%       
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%

[reg,prop]=modgen.common.parseparams(varargin,{'replaceNull'},1);
nProp=length(prop);
for iProp=1:2:nProp-1,
    switch lower(prop{iProp})
        case 'replacenull',
            if ~(islogical(prop{iProp+1})&&numel(prop{iProp+1})==1)
                error([upper(mfilename),':wrongInput'],...
                    'replaceNull is expected to have a scalar logical value');
            end
        otherwise
            error([upper(mfilename),':wrongInput'],...
                'unknown property %s',prop{iProp});
    end
end
nStructNames=numel(self.completeStructNameList);
outCell=cell(1,nStructNames+nargout);
[outCell{:}]=self.getUniqueDataAlongDimInternal(reg{:},prop{:},...
    'fieldNameList',self.getFieldNameList(),...
    'structNameList',self.completeStructNameList,...
    'checkInputs',false);
varargout=cell(1,nargout);
varargout(1:end)=outCell(nStructNames+1:end);
[self.SData self.SIsNull self.SIsValueNull]=deal(outCell{1:nStructNames});