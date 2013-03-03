function SInput = patch_007_make_space_list_a_vector(~,SInput)
projSetListName=fieldnames(SInput.projectionProps.projSpaceSets);
nFields=length(projSetListName);
for iField=1:nFields
    fieldName=projSetListName{iField};
    SInput.projectionProps.projSpaceSets.(fieldName)=reshape(...
        SInput.projectionProps.projSpaceSets.(fieldName),1,[]);
end
%
SInput.goodDirSelection.methodProps.manual.lsGoodDirSetName='set1';
SInput.goodDirSelection.methodProps.manual.lsGoodDirSets.set1=...
    reshape(SInput.goodDirSelection.methodProps.manual.lsGoodDirList,1,[]);
%
SInput.goodDirSelection.methodProps.manual=rmfield(...
    SInput.goodDirSelection.methodProps.manual,'lsGoodDirList');