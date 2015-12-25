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
        fTransfomr=SFieldTransformFunc.(fieldName);
        SComp.(SFieldNiceNames.(fieldName))=fTransfomr(SEll.(fieldName));
    end
end
end