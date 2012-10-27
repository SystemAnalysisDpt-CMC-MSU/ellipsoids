function STypeInfo = updatetypeinfostruct(SOldTypeInfo)
if  ~isfield(SOldTypeInfo,'itemTypeInfo')
    %nothing to update
    STypeInfo=SOldTypeInfo;
else
    
    maxDepth=nan;
    bottomType='';
    %
    if isfield(SOldTypeInfo,'isNested')
        getbottomtype_v1(SOldTypeInfo,0);
    elseif isfield(SOldTypeInfo,'isCell')
        getbottomtype_v2(SOldTypeInfo,0);
    else
        error([upper(mfilename),':wrongInput'],...
            'unknown format of STypeInfo');
    end
    %
    STypeInfo=struct('type',bottomType,'depth',maxDepth);
end
%
    function getbottomtype_v1(STypeInfo,level)
        if STypeInfo.isNested
            getbottomtype_v1(STypeInfo.itemTypeInfo,level+1)
        else
            maxDepth=level;
            bottomType=STypeInfo.type;
        end
    end
    function getbottomtype_v2(STypeInfo,level)
        if STypeInfo.isCell
            getbottomtype_v2(STypeInfo.itemTypeInfo,level+1)
        else
            maxDepth=level;
            bottomType=STypeInfo.type;
        end
    end
end