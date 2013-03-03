function [pathSpecList,valueList]=getleavelist(SInp)
% GETLEAVELIST generates a list of structure leave paths
%
% Input:
%   regular:
%       SInp: struct[] - input structure array
%
% Output:
%   pathSpecList: cell[nPaths,1] of cell[1,] of char[1,]/cell[1,] of double[1,]
%
%       - list of path specifications in the following form:
%           {{ind11,ind12,...,ind1n1},field1,...
%               {ind21,ind22,...,ind2n2},field2,...
%               {ind31,ind32,...,ind3n3},field3}
%               which corresponds to
%           S(ind11,ind12,...,ind1n1).field1(...
%               ind21,ind22,...,ind2n2).field2(...
%               ind31,ind32,...,ind3n3).field3
%
%  valueList: cell[nPaths,1] of any[] - list of leave  values
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-06-05 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
pathSpecList=getleavelistint(SInp);
if nargout>1
    nLeaves=length(pathSpecList);
    valueList=cell(nLeaves,1);
    for iLeave=1:nLeaves
        valueList{iLeave}=getfield(SInp,pathSpecList{iLeave}{:});
    end
end
end
function pathList=getleavelistint(SInp)
import modgen.common.throwerror;
if ~isstruct(SInp)
    throwerror('wrongInput',...
        'SInp is expected to be a structure array');
end
%
fieldNameList=fieldnames(SInp);
nFields=numel(fieldNameList);
%
if nFields>0
    nElems=numel(SInp);
    indVec=nElems:-1:1;
    indCMat=num2cell(modgen.common.ind2submat(size(SInp),indVec));
    pathSpecCell=cell(nElems,nFields);
    for iElem=indVec
        for iField=1:nFields
            SCur=SInp(iElem).(fieldNameList{iField});
            if isstruct(SCur)
                pathSpecCell{iElem,iField}=...
                    getleavelistint(SCur);
                %
                pathSpecCell{iElem,iField}=cellfun(...
                    @(x)[{indCMat(iElem,:)},fieldNameList(iField), x],...
                    pathSpecCell{iElem,iField},...
                    'UniformOutput',false);
                %
            else
                pathSpecCell{iElem,iField}=...
                    {{indCMat(iElem,:),fieldNameList{iField}}};
            end
        end
    end
    pathList=vertcat(pathSpecCell{:});
else
    pathList=cell(0,0);
end
end
