function sortInd=getSortIndexInternal(self,sortFieldNameList,sortDim,varargin)
% GETSORTINDEXINTERNAL gets sort index for all cells along the specified 
% dimensions for a given CubeStruct with respect to some of its fields
%
% Usage: sortInd=getSortIndexInternal(self,sortFieldNameList,varargin)
%
% Input:
%   regular:
%     self: CubeStruct [1,1] - class object
%     sortFieldNameList: char or char cell [1,nFields] - list of field
%         names with respect to which field content is sorted
%     sortDim: numeric[1,1] - dimension number along which the sorting is
%        to be performed
%
%   properties:
%     direction: char or char cell [1,nFields] - direction of sorting for
%         all fields (if one value is given) or for each field separately;
%         each value may be 'asc' or 'desc'
% Output:
%   regular:
%    sortIndex: double [minDimSizeAcrossSpecDim,1] - array of indices of field
%       value slices in the sorted order
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
%
%% Get properties
Direction={'asc'};
[~,prop]=modgen.common.parseparams(varargin,[],0);
nProp=length(prop);
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'direction'
            Direction=prop{k+1};
        otherwise,
            error([upper(mfilename),':wrongInput'],...
                'Unidentified property name: %s ',prop{k});
    end
end
%% Initial actions
if nargin<3,
    error([upper(mfilename),':wrongInput'],...
        'sortDim must be given for grouping');
end
if ischar(sortFieldNameList),
    sortFieldNameList={sortFieldNameList};
end
sortFieldNameList=sortFieldNameList(:).';
if ~iscellstr(sortFieldNameList),
    error([upper(mfilename),':wrongInput'],...
        'sortFieldNameList must be array of strings');
end
[isField indField]=ismember(sortFieldNameList,self.fieldNameList);
if ~all(isField),
    error([upper(mfilename),':wrongInput'],...
        'sortFieldNameList must contain names of given object fields');
end
if any(diff(sort(indField))==0),
    error([upper(mfilename),':wrongInput'],...
        'sortFieldNameList must contain unique names');
end
nSortFields=length(indField);
if ischar(Direction),
    Direction={Direction};
end
if ~iscellstr(Direction),
    error([upper(mfilename),':wrongInput'],...
        'Direction must be array of strings');
end
[isDir indDir]=ismember(lower(Direction),{'asc','desc'});
if ~all(isDir),
    error([upper(mfilename),':wrongInput'],...
        'Direction must be ''asc'' or ''desc'' for each field');
end
if numel(indDir)==1,
    indDir=repmat(indDir,1,nSortFields);
elseif numel(indDir)~=nSortFields,
    error([upper(mfilename),':wrongInput'],...
        'sortFieldNameList and Direction must be consistent');
end
minDimensionality=self.getMinDimensionality();
if sortDim>minDimensionality||sortDim<1
    error([upper(mfilename),':wrongInput'],...
        'sortDim is expected to be in range [1,minDimensionality]=[1,%d]',...
        minDimensionality);
end
%    
%% Get sort index
sortDimSize=self.getMinDimensionSizeInternal(sortDim);
if sortDimSize==0,
    sortInd=nan(0,1);
    return;
end
indSlices=nan(sortDimSize,nSortFields);
sortValSize=nan(1,nSortFields);
[curSData,curSIsNull]=self.getDataInternal(...
    'structNameList',{'SData','SIsNull'},...
    'replaceNull',true,'fieldNameList',sortFieldNameList);
%
isSorted=true(1,nSortFields);
for iSortField=1:nSortFields,
    curFieldName=sortFieldNameList{iSortField};
    %
    [sortVal , ~, indSlices(:,iSortField),isSorted(iSortField)]=uniquejoint(...
        {curSIsNull.(curFieldName);curSData.(curFieldName)},sortDim);
    sortValSize(iSortField)=size(sortVal{1},1);
    %
end
isDesc=indDir==2;
if any(isDesc),
    indSlices(:,isDesc)=repmat(sortValSize(isDesc),sortDimSize,1)-indSlices(:,isDesc)+1;
end
if ~all(isSorted),
    indSlices=[indSlices(:,isSorted) indSlices(:,~isSorted)];
    sortValSize=[sortValSize(isSorted) sortValSize(~isSorted)];
end
if nSortFields>1,
    linIndSlices=num2cell(fliplr(indSlices),1);
    linIndSlices=sub2ind(fliplr(sortValSize),linIndSlices{:});
else
    linIndSlices=indSlices;
end
[~, sortInd]=sort(linIndSlices);