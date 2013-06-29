classdef ADispStructTC < mlunitext.test_case
    %
    %$Author: Alexander Karev <Alexander.Karev.30@gmail.com> $
    %$Date: 2013-06$
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2013 $
    methods (Abstract, Static, Access = protected)
        getToStructObj()
        getToStructStruct()
        getToStructIsPropIncluded()
        getToStructResult()
        getToStructTestNumber()
        getFromStructObj()
        getFromStructStruct()
        getFromStructResult()
        getFromStructTestNumber()
        getDisplayObj()
        getDisplayStrings()
        getDisplayResult()
        getDisplayTestNumber()
        getEqFstObj()
        getEqSndObj()
        getEqResult()
        getEqTestNumber()
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
            objArrCVec = self.getToStructObj();
            SArrCVec = self.getToStructStruct();
            isPropCVec = self.getToStructIsPropIncluded();
            isResultCVec = self.getToStructResult();
            for iTest = 1 : self.getToStructTestNumber()
                auxToStructTest(self, objArrCVec{iTest},...
                    SArrCVec{iTest},...
                    isPropCVec{iTest},...
                    isResultCVec{iTest});
            end
        end
        
        function self = testFromStruct(self)
            SArrCVec = self.getFromStructStruct();
            objArrCVec = self.getFromStructObj();
            isResultCVec = self.getFromStructResult();
            for iTest = 1 : self.getFromStructTestNumber()
                auxFromStructTest(self, SArrCVec{iTest},...
                    objArrCVec{iTest},...
                    isResultCVec{iTest});
            end
        end
        
        function self = testDisplay(self)
            objArrCVec = self.getDisplayObj();
            stringsCVec = self.getDisplayStrings();
            isResultCVec = self.getDisplayResult();
            for iTest = 1 : self.getDisplayTestNumber();
                auxDisplayTest(self, objArrCVec{iTest},...
                    stringsCVec{iTest},...
                    isResultCVec{iTest});
            end
        end
        
        function self = testEq(self)
            fstObjArrCVec = self.getEqFstObj();
            sndObjArrCVec = self.getEqSndObj();
            isResultCVec = self.getEqResult();
            for iTest = 1 : self.getEqTestNumber();
                auxEqTest(self, fstObjArrCVec{iTest},...
                    sndObjArrCVec{iTest},...
                    isResultCVec{iTest});
            end
        end
    end
end