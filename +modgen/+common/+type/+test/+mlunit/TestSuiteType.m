classdef TestSuiteType < mlunitext.test_case
    properties
    end
    
    methods
        function self = TestSuiteType(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function self = set_up_param(self,varargin)
            
        end
        function self=test_isIncludedInto(self)
           %1
           anyCellObj=modgen.common.type.NestedArrayType.fromClassName({'cell',''});
           %2
           cellOfCharObj=modgen.common.type.NestedArrayType.fromClassName({'cell','cell','char'});
           %3
           charObj=modgen.common.type.NestedArrayType.fromClassName({'char'});
           %4
           anyObj=modgen.common.type.NestedArrayAnyType(); 
           %5
           noObj=modgen.common.type.NestedArrayNoType(); 
           %6 
           anyCellOfCellsObj=modgen.common.type.NestedArrayType.fromClassName({'cell','cell',''});
           %
           objList={anyCellObj,cellOfCharObj,charObj,anyObj,noObj,anyCellOfCellsObj};
           nObj=numel(objList);
           combAndIsIncludedExpCMat={[1     1],true;
                                     [1     2],false;
                                     [1     3],false;
                                     [1     4],true;
                                     [1     5],false;
                                     [1     6],false;
                                     [2     1],true;
                                     [2     2],true;
                                     [2     3],false;
                                     [2     4],true;
                                     [2     5],false;
                                     [2     6],true;
                                     [3     1],false;
                                     [3     2],false;
                                     [3     3],true;
                                     [3     4],true;
                                     [3     5],false;
                                     [3     6],false;
                                     [4     1],false;
                                     [4     2],false;
                                     [4     3],false;
                                     [4     4],true;
                                     [4     5],false;
                                     [4     6],false;
                                     [5     1],true;
                                     [5     2],true;
                                     [5     3],true;
                                     [5     4],true;
                                     [5     5],true
                                     [5     6],true};
            objPairList=cellfun(@(x)objList(x),...
                combAndIsIncludedExpCMat(:,1),'UniformOutput',false);
            %
            nPairs=size(objPairList,1);
            isIncludedVec=true(nPairs,1);
            for iPair=1:nPairs
                isIncludedVec(iPair)=objPairList{iPair}{1}.isIncludedInto(...
                    objPairList{iPair}{2});
            end
            mlunitext.assert_equals(vertcat(combAndIsIncludedExpCMat{:,2}),...
                isIncludedVec);
            %
           isIncludedExpVec=[true;true;false;false;true;true];
           %
           isIncludedVec=isIncludedExpVec;
           for iObj=1:nObj
                isIncludedVec(iObj)=objList{iObj}.isContainedInCellType();
           end
           %
           mlunitext.assert_equals(true,isequal(isIncludedVec,isIncludedExpVec));
        end
        function self=test_toStruct(self)
           obj1=modgen.common.type.NestedArrayType.fromClassName({'cell','char'});
           obj2=modgen.common.type.NestedArrayType.fromClassName({'char'});            
           res1=struct(obj1);
           res2=struct(obj2);
        end
        function self=test_nestedArrayFactory_fromClassName(self)
            %
            classSpecNamePairMat={...
                {{'char'},'no'},'modgen.common.type.NestedArrayType';
                {{'char'},'any'},'modgen.common.type.NestedArrayType';
                {{'cell'},'no'},'modgen.common.type.NestedArrayType';
                {{'cell','cell'},'any'},'modgen.common.type.NestedArrayType';
                {{'cell','cell'},'no'},'modgen.common.type.NestedArrayType';
                {{'cell'},'any'},'modgen.common.type.NestedArrayType';
                {{''},'no'},'modgen.common.type.NestedArrayNoType';
                {{},'any'},'modgen.common.type.NestedArrayAnyType';
                {{''},'any'},'modgen.common.type.NestedArrayAnyType';
                {{},'no'},'modgen.common.type.NestedArrayNoType'...
                };
            nPairs=size(classSpecNamePairMat,1);
            for iPair=1:nPairs
                type=modgen.common.type.NestedArrayTypeFactory.fromClassName(...
                    classSpecNamePairMat{iPair,1}{:});
                mlunitext.assert_equals(true,...
                    isa(type,classSpecNamePairMat{iPair,2}),...
                    sprintf('failed for pair %d',iPair));
            end
        end
    end
end