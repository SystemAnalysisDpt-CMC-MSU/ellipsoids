function SComp=formCompStruct(SEll,SFieldNiceNames,SFieldTransformFunc)
fieldNameList=fieldnames(SFieldNiceNames);
%
nFields=numel(fieldNameList);
%
for iField=1:nFields
    fieldName=fieldNameList{iField};
    if isempty(SEll.(fieldName))
        SComp.(SFieldNiceNames.(fieldName))=[];
    else
        fTransform=SFieldTransformFunc.(fieldName);
        SComp.(SFieldNiceNames.(fieldName))=fTransform(SEll.(fieldName));
    end
end
end