classdef NestedArrayTypeFactory<modgen.common.type.NestedArrayType
    methods (Access=private)
        function self=NestedArrayTypeFactory()
        end
    end
    methods (Static,Access=private)
        function resCArray=unknownTypeCellArray(typeKindName,sizeVec)
                if strcmpi(typeKindName,'any')
                    resCArray=repmat({modgen.common.type.NestedArrayAnyType()},sizeVec);
                elseif strcmpi(typeKindName,'no')
                    resCArray=repmat({modgen.common.type.NestedArrayNoType()},...
                        sizeVec);
                else
                    error([upper(mfilename),':wrongInput'],...
                        '%s is unsupported unknownTypeKindName',...
                        typeKindName);
                end
        end
        function res=unknownType(typeKindName)
                if strcmpi(typeKindName,'any')
                    res=modgen.common.type.NestedArrayAnyType();
                elseif strcmpi(typeKindName,'no')
                    res=modgen.common.type.NestedArrayNoType();
                else
                    error([upper(mfilename),':wrongInput'],...
                        '%s is unsupported unknownTypeKindName',...
                        typeKindName);
                end
        end        
    end
    methods (Static)
        function resCArray=fromClassNameArray(classNameListCArray,unknownTypeKindName)
            resCArray=cell(size(classNameListCArray));
            nElem=numel(resCArray);
            for iElem=1:nElem
                resCArray(iElem)={...
                    modgen.common.type.NestedArrayTypeFactory.fromClassName(...
                    classNameListCArray{iElem},unknownTypeKindName)};
            end
        end
        function resObj=fromValue(value)
                resObj=modgen.common.type.NestedArrayType.fromValue(value);
        end
        function resObj=fromClassName(classNameList,unknownTypeKindName)
            if ~iscellstr(classNameList)
                error([upper(mfilename),':wrongInput'],...
                    'classNameList is expected to be a cell array of strings');
            end
            %
            if isempty(classNameList)||...
                    numel(classNameList)==1&&...
                    ischar(classNameList{1})&&...
                    isempty(classNameList{1})
                resObj=modgen.common.type.NestedArrayTypeFactory.unknownType(...
                    unknownTypeKindName);
            else
                resObj=modgen.common.type.NestedArrayType.fromClassName(classNameList);
            end
        end
    end
end
