classdef ADispStruct < mlunitext.test_case
    %
    %$Author: Alexander Karev <Alexander.Karev.30@gmail.com> $
    %$Date: 2013-06$
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2013 $
    methods
        function self = ADispStruct(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function self = toStructTest(self, ObjArr, StructArr,...
                                     isPropsIncluded, result)
            SObtainedArr = ObjArr.toStruct(isPropsIncluded);
            isOk = isequal(StructArr, SObtainedArr);
            mlunitext.assert_equals(isOk, result);
        end
        
        function self = displayTest(self, ObjArr, displayString, result)
            obtainedStr = evalc('ObjArr.display()');
            isOk = isequal(displayString, obtainedStr);
            mlunitext.assert_equals(isOk, result);
        end
        
        function self = fromStructTest(self, StructArr, ObjArr, sampleObj, result)
            obtainedObjArr = sampleObj.fromStruct(StructArr);
            isOk = isequal(ObjArr, obtainedObjArr);
            mlunitext.assert_equals(isOk, result);
        end
    end
end