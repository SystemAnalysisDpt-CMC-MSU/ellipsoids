function resCVec=toFieldListInternal(self,fieldNameList,structNameList,isGroupByStruct)
if nargin<4
    isGroupByStruct=true;
end
resCVec=cell(size(structNameList));
[fieldUniqueNameList,indForward,indBackward]=unique(fieldNameList);
if ~isequal(length(fieldUniqueNameList),length(fieldNameList))
    [resCVec{:}]=self.getData('structNameList',structNameList,'fieldNameList',fieldUniqueNameList);
    resCVec=cellfun(@(x)transpose(struct2cell(x)),resCVec,'UniformOutput',false);
    resCVec=cellfun(@(x)x(indBackward),resCVec,'UniformOutput',false);
else
    [resCVec{:}]=self.getData('structNameList',structNameList,'fieldNameList',fieldNameList);
    resCVec=cellfun(@(x)transpose(struct2cell(x)),resCVec,'UniformOutput',false);
end
if ~isGroupByStruct
    resCVec=[resCVec{:}];
end
end