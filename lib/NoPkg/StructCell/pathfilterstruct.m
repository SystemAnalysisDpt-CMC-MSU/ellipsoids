function ResStruct=pathfilterstruct(InpStruct,path2KeepList)
% PATHFILTERSTRUCT leaves in input structure array only specified paths
% 
% Usage: ResStruct=pathfilterstruct(InpStruct,field2KeepList)
%
% input: 
%   regular:
%       InpStruct: struct array
%       path2KeepList: cell[1,nPaths] - cell array of strings with paths in
%               structure;
% output:
%   regular:
%       ResStruct: struct array
%
% Example:  ResStruct=pathfilterstruct(InpStruct,{'a','a.b','cd.u','.m'})
%
%
% $Author: Peter Gagarinov <pgagarinov@gmail.com> $	$Date: 2012-10-09 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
if isempty(path2KeepList)
    ResStruct=InpStruct;
    return;
end
%
if ischar(path2KeepList)
    path2KeepList={path2KeepList};
end
%make sure that all the restrictions are applied i.e. if {'a','a.b'} is
%specified as path2KeepList 'a.b' is used
%
path2KeepList=sort(path2KeepList);

nPath=length(path2KeepList);
pathCell=cell(nPath,1);
for iPath=1:nPath
    pathCell{iPath}=regexp(path2KeepList{iPath},'([^\.]*)','match');
end
%
lengthVec=cellfun(@length,pathCell);
maxPathLength=max(lengthVec);
fieldSeqCell=cell(nPath,maxPathLength);
%
for iPath=1:nPath
    fieldSeqCell(iPath,1:lengthVec(iPath))=pathCell{iPath};
end

[field2KeepList,indShrink,indRep]=unique(fieldSeqCell(:,1));
%
ResStruct=auxfieldfilterstruct(InpStruct,field2KeepList);
%

indCell=accumarray(indRep,(1:nPath).',[],@(x){x});
nUniqueFields=length(indCell);
%
for iField=1:nUniqueFields
    fieldName=field2KeepList{iField};
    subFieldSeqCell=fieldSeqCell(indCell{iField},:);
    if size(subFieldSeqCell,2)>1
        subPath2KeepList=sepcell2pathlist(subFieldSeqCell(:,2:end));
        InpSubStruct=auxgetfieldstruct(ResStruct,fieldName);
        ResCell=num2cell(pathfilterstruct(InpSubStruct,subPath2KeepList));
        ResSubStruct=struct(fieldName,ResCell);
        %
        ResStruct=binaryunionstruct(ResStruct,ResSubStruct,@(x,y)y);
    end
end
end
%
function SRes=auxgetfieldstruct(SInp,fieldName)
SRes=reshape([SInp.(fieldName)],size(SInp));
end
%
function pathList=sepcell2pathlist(sepCell)
nPath=size(sepCell,1);
pathList={};
for iPath=1:nPath
    isnEmpty=~cellfun(@isempty,sepCell(iPath,:));
    indLastNotEmpty=find(isnEmpty,1,'last');
    if isempty(indLastNotEmpty)
        pathList={};
        return;
    end
    curPathCell=sepCell(iPath,1:indLastNotEmpty);
    curPathCell=[repmat({'.'},1,indLastNotEmpty);curPathCell];
    curPath=horzcat(curPathCell{:});
    pathList=[pathList,{curPath}];
end
%
end
