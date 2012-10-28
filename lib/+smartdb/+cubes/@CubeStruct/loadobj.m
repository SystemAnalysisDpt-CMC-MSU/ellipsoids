function inpObj=loadobj(inpObj)
if isstruct(inpObj)
    error([upper(mfilename),':wrongInput'],...
        'cannot reconstruct an object from a structure');
else
    %empty enum values are not loaded correctly in 2011a so we use a simple
    %workround (it only works for enum fields, not cells of enums)
    %
    if inpObj.getNTuples()==0
        fieldTypeList=inpObj.getFieldTypeSpecList();
        isSimpleTypeVec=cellfun('length',fieldTypeList)==1;
        if any(isSimpleTypeVec)
            isEnumSubVec=cellfun(@(x)~isempty(enumeration(x{1})),...
                fieldTypeList(isSimpleTypeVec));
            if any(isEnumSubVec)
                indSimpleTypeVec=find(isSimpleTypeVec);
                indEnumVec=indSimpleTypeVec(isEnumSubVec);
                fieldNameList=inpObj.getFieldNameList();
                typeList=inpObj.getFieldTypeList();
                sizeMat=inpObj.getFieldValueSizeMat();
                for iField=indEnumVec
                    fieldName=fieldNameList{iField};
                    inpObj.setField(fieldName,...
                        typeList{iField}.createDefaultValueArray(...
                        sizeMat(iField,:)));
                end
            end
        end
    end
end
inpObj.defineFieldsAsProps();