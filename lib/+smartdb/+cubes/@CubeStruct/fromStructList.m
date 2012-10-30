function relDataObj=fromStructList(catDim,className,structList)
% FROMSTRUCTLIST creates an object of specified type
% from a list of structures interpreting each structure
% as the data for several CubeStruct data slices
%
% Input:
%   regular:
%       catDim: double[1,1] - dimension along which the input structures
%          are to be concatenated
%       className: name of object class which will be created,
%           the class constructor should accept 2 properties:
%           'fieldNameList' and 'fieldTypeSpecList'
%       structList: cell[] of struct[1,1] - list of structures
%
% Output:
%   relDataObj: className[1,1] -  constructed object
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-02 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%

%% Check which fields are specified by each of the structures
N_UNIQUE_BLOCK_SIZE=1000;
nStructs=numel(structList);
if nStructs>0
    fieldNameList=fieldnames(structList{1});
    indStart=2;
    while indStart<=nStructs
        indVec=indStart:1:min(N_UNIQUE_BLOCK_SIZE+indStart-1,nStructs);
        fieldNameCVec=cellfun(@fieldnames,structList(indVec),'UniformOutput',false);
        fieldNameList=unique([fieldNameList;vertcat(fieldNameCVec{:})]);
        indStart=indStart+N_UNIQUE_BLOCK_SIZE;
    end
    fieldNameList=transpose(fieldNameList);    
else
    fieldNameList={};
end
nFields=numel(fieldNameList);
if nFields>0
    isTypeIdentifiedVec=false(1,nFields);
    fieldTypeSpecList=cell(1,nFields);
    %
    isFieldSpecMat=false(nStructs,nFields);
    for iField=1:nFields
        fieldName=fieldNameList{iField};
        isFieldSpecMat(:,iField)=reshape(...
            cellfun(@(x)isfield(x,fieldName),structList),[],1);
    end
    %% Find unique combinations specified field lists
    isFieldSpecCVec=mat2cell(isFieldSpecMat,ones(1,nStructs),nFields);
    [isFieldUniqueCombCVec,indForwardVec,indBackwardVec]=uniqueobj(isFieldSpecCVec);
    isAnyFieldsVec=cellfun(@any,isFieldUniqueCombCVec);
    nUniqueFieldCombs=length(indForwardVec);
    grStructList=cell(1,nUniqueFieldCombs);
    %% Accumulate struct field sizes along catDim
    catDimSizeCVec=repmat({nan(nStructs,1)},1,nFields);
    for iField=1:nFields
        fieldName=fieldNameList{iField};
        isCurFieldSpecVec=isFieldSpecMat(:,iField);
        catDimSizeCVec{iField}(isCurFieldSpecVec)=...
            cellfun(@(x)size(x.(fieldName),catDim),...
            structList(isCurFieldSpecVec));
        nFilled=sum(isCurFieldSpecVec);
        if nFilled==nStructs
            continue;
        end
        %fill sizes along catDim from other fields
        for iOtherField=1:nFields
            if iOtherField==iField
                continue;
            end
            otherFieldName=fieldNameList{iOtherField};
            isOtherCompVec=~isCurFieldSpecVec&isFieldSpecMat(:,iOtherField);
            nOtherComb=sum(isOtherCompVec);
            if nOtherComb>0
                catDimSizeCVec{iField}(isOtherCompVec)=...
                    cellfun(@(x)size(x.(otherFieldName),catDim),...
                    structList(isOtherCompVec));                
            end
            nFilled=nFilled+nOtherComb;
            if nFilled==nStructs
                break
            end
        end
    end
    %
    if nFields>1&&~isequalwithequalnans(catDimSizeCVec{:})
        error([upper(mfilename),':wrongInput'],...
            ['cannot concatenate along the specified dimension ',...
            'as different fields have different sizes']);
    end
    %% Define a vector of data slice sizes
    catDimSizeVec=transpose(catDimSizeCVec{1});
    %if no fields present, set size to 0
    catDimSizeVec(isnan(catDimSizeVec))=0;
    %% Group structures by the field lists they specify
    indGroupedOrderCVec=cell(1,nUniqueFieldCombs);
    for iFieldComb=1:nUniqueFieldCombs
        if isAnyFieldsVec(iFieldComb)
            %
            isCurFieldComb=indBackwardVec==iFieldComb;
            indCurFieldComb=find(isCurFieldComb);
            nCurCombs=sum(isCurFieldComb);
            %
            grStructList{iFieldComb}=structList{indCurFieldComb(1)};
            indGroupedOrderCVec{iFieldComb}=indCurFieldComb;
            %identify field types along the way
            if ~all(isTypeIdentifiedVec)
                indFieldToTypeVec=....
                    find(isFieldUniqueCombCVec{iFieldComb}&~isTypeIdentifiedVec);
                %
                nFieldsToType=numel(indFieldToTypeVec);
                for iFieldToType=1:nFieldsToType
                    indFieldToType=indFieldToTypeVec(iFieldToType);
                    fieldTypeSpecList{indFieldToType}=...
                        modgen.common.type.NestedArrayType.fromValue(...
                        grStructList{iFieldComb}.(...
                        fieldNameList{indFieldToType})).toClassName;
                end
                isTypeIdentifiedVec=isTypeIdentifiedVec|...
                    isFieldUniqueCombCVec{iFieldComb};
            end
            %group structures by concatenating their fields along catDim
            if nCurCombs>1
                curCombFieldNames=fieldnames(grStructList{iFieldComb});
                nCurCombFields=numel(curCombFieldNames);
                for iCurComb=2:nCurCombs
                    for iCurCombField=1:nCurCombFields
                        curCombFieldName=curCombFieldNames{iCurCombField};
                        grStructList{iFieldComb}.(curCombFieldName)=...
                            cat(catDim,...
                            grStructList{iFieldComb}.(curCombFieldName),...
                            structList{indCurFieldComb(iCurComb)}.(curCombFieldName));
                    end
                end
            end
        else
            grStructList{iFieldComb}=struct();
        end
    end
    %% Initialize CubeStruct object
    relDataObj=feval(className,...
        'fieldNameList',fieldNameList,...
        'fieldTypeSpecList',fieldTypeSpecList);
    %% Concatenate the grouped structures
    for iStruct=1:nUniqueFieldCombs
        relDataObj.addDataAlongDimInternal(catDim,grStructList{iStruct});
    end
    %% Calculate an order of data slices that would correspond to the structure
    %% order
    indGroupedOrderVec=vertcat(indGroupedOrderCVec{:});
    indGrLeftVec=cumsum([0,catDimSizeVec(1:end-1)]);
    indGrRightVec=cumsum(catDimSizeVec);
    indRangeCVec=cellfun(@(x,y)(x+1:y),num2cell(indGrLeftVec),...
        num2cell(indGrRightVec),'UniformOutput',false);
    indRangeCVec=indRangeCVec(indGroupedOrderVec);
    indGroupedOrderVec=horzcat(indRangeCVec{:});
    %
    [~,indRestoreOrderVec]=sort(indGroupedOrderVec);
    
    %% Restore the correct order of data slices
    relDataObj.reorderDataInternal({indRestoreOrderVec},catDim);
else
    relDataObj=feval(className);
end
%