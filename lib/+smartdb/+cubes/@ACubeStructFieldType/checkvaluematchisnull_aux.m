function isOk=checkvaluematchisnull_aux(value,valueIsNull)
isOk=iscell(valueIsNull)||islogical(valueIsNull);
isOk=isOk&&isequal(size(value),size(valueIsNull));
%
if ~isOk
    return;
end
if iscell(value)
    if isempty(value)
        isOk=true;
    elseif ~iscellstr(value)
        isOk=isa(valueIsNull,'cell');
        if ~isOk
            return;
        end
        %
        isLogicalVec=cellfun('islogical',valueIsNull);        
        %
        isNullVec=(cellfun('length',valueIsNull)==1)&isLogicalVec;
        isNullVec(isNullVec)=[valueIsNull{isNullVec}];
        isOk=modgen.common.isequalcellelemsize(value(~isNullVec),valueIsNull(~isNullVec));
        %
        if ~isOk
            return;
        end
        %
        isOkVec=isLogicalVec;
        %
        isOkVec(~isLogicalVec)=cellfun(@smartdb.cubes.ACubeStructFieldType.checkvaluematchisnull_aux,....
            value(~isLogicalVec),valueIsNull(~isLogicalVec));
        %
        isOk=all(isOkVec(:));
        if ~isOk
            return;
        end
        %
    else
        isOk=islogical(valueIsNull);
    end
else
    isOk=islogical(valueIsNull);
end