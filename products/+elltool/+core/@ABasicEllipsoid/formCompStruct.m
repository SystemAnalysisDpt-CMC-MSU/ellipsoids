function SComp=formCompStruct(SEll,SFieldNiceNames)
fieldNameList=fieldnames(SFieldNiceNames);
%
nFields=numel(fieldNameList);
%
for iField=1:nFields
    fieldName=fieldNameList{iField};
    if isempty(SFieldNiceNames.(fieldName))
        SComp.(fieldName)=[];
    else
        SComp.(fieldName)=SEll.(fieldName);
    end
end
end