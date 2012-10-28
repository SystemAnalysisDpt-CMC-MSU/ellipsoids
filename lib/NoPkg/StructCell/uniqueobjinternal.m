function [uniqObjCell,indUniq,indInUniq]=uniqueobjinternal(objCell,funHandle)
% UNIQUEOBJINTERNAL unique for cellarrays of objects of any kind
%
%Usage: [uniqObjCell,indUniq,indInUniq]=uniqueobjinternal(...
%           objCell,funHandle);
%
% input:
%   regular:
%      objCell: cell[nObjects,1] of objects
%   optional:
%       funHandle: compare function, defualt isequalwithequalnans
%           funHandle:
%           @(objectLeft,objectRight)compare(objectLeft,objectRight)
% output:
%   uniqObjCell: cell[nUniqObjects,1]
%   indUniq: double[nUniqObjects] : all
%       funHandle(objCell(indUniq)==uniqObjCell)==true
%   indInUniq: double[nObjects,1] : all
%       all(funHandle(uniqObjCell(indInUniq)==objCell))
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%% TODO: make it faster
%
%
if nargin<2
    funHandle=@isequalwithequalnans;
end
objCell=reshape(objCell,[],1);
algo=2;
if algo==1
    % memory hungry
    % this appears to be faster
    [isIn,indInUniq]=ismemberobjinternal(objCell,objCell,funHandle); %#ok<ASGLU>
    isInUniq=ismember(1:length(indInUniq),indInUniq);
    indUniq=find(isInUniq);
    [isIn,indInUniq]=ismember(indInUniq,indUniq); %#ok<ASGLU>
    uniqObjCell=objCell(isInUniq);
else
    % more memory preserving
    uniqObjCell=[];
    indUniq=[];
    indInUniq=nan(length(objCell),1);
    for iObj=1:length(objCell)
        [isIn,indIn]=ismemberobjinternal(objCell(iObj),uniqObjCell,funHandle);
        if ~isIn
            uniqObjCell=[uniqObjCell; objCell(iObj)]; %#ok<AGROW>
            indUniq=[indUniq; iObj]; %#ok<AGROW>
            indInUniq(iObj)=length(uniqObjCell);
        else
            indInUniq(iObj)=indIn;
        end
    end
end