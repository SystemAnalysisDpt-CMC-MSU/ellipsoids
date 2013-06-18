classdef ADispStructTC < mlunitext.test_case
    %
    %$Author: Alexander Karev <Alexander.Karev.30@gmail.com> $
    %$Date: 2013-06$
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2013 $
    methods (Abstract, Static, Access = public)
        getToStructObj(iTest)
        getToStructStruct(iTest)
        getToStructIsPropIncluded(iTest)
        getToStructResult(iTest)
        getFromStructObj(iTest)
        getFromStructStruct(iTest)
        getFromStructResult(iTest)
        getDisplayObj(iTest)
        getDisplayStrings(iTest)
        getDisplayResult(iTest)
        getEqFstObj(iTest)
        getEqSndObj(iTest)
        getEqResult(iTest)
    end
    methods (Access = public)
        function self = ADispStructTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function self = auxToStructTest(self, ObjArr, StructArr,...
                isPropsIncluded, result)
            SObtainedArr = ObjArr.toStruct(isPropsIncluded);
            isOk = isequal(StructArr, SObtainedArr);
            mlunitext.assert_equals(isOk, result);
        end
        
        function self = auxDisplayTest(self, ObjArr,...
                displayStringCVec, result)
            obtainedStr = evalc('ObjArr.display()');
            isOk = all(cellfun(@(Str1, Str2)~isempty(strfind(Str1, Str2)), ...
                repmat({obtainedStr}, size(displayStringCVec)),...
                displayStringCVec));
            mlunitext.assert_equals(isOk, result);
        end
        
        function self = auxFromStructTest(self, StructArr, ObjArr, result)
            obtainedObjArr = ObjArr.fromStruct(StructArr);
            isOk = isequal(ObjArr, obtainedObjArr);
            mlunitext.assert_equals(isOk, result);
        end
        
        function self = auxEqTest(self, ObjArr1, ObjArr2, result)
            isOk = isequal(ObjArr1, ObjArr2);
            mlunitext.assert_equals(isOk, result);
        end
        
        function self = testToStuct(self)
            for iTest = 1 : 7
                auxToStructTest(self, self.getToStructObj(iTest),...
                    self.getToStructStruct(iTest),...
                    self.getToStructIsPropIncluded(iTest),...
                    self.getToStructResult(iTest));
            end
        end
        
        function self = testFromStruct(self)
            for iTest = 1 : 6
                auxFromStructTest(self, self.getFromStructStruct(iTest),...
                    self.getFromStructObj(iTest),...
                    self.getFromStructResult(iTest));
            end
        end
        
        function self = testDisplay(self)
            for iTest = 1 : 6
                auxDisplayTest(self, self.getDisplayObj(iTest),...
                    self.getDisplayStrings(iTest),...
                    self.getDisplayResult(iTest));
            end
        end
        
        function self = testEq(self)
            for iTest = 1 : 6
                auxEqTest(self, self.getEqFstObj(iTest),...
                    self.getEqSndObj(iTest),...
                    self.getEqResult(iTest));
            end
        end
    end
end