classdef TouchTestCase < mlunitext.test_case
    properties
    end
    
    methods
        function self = TouchTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function testControl(~)
            import modgen.io.TmpDataManager;
            testFileName = modgen.common.getcallername(1);
            [pathstrVec, ~, ~] = fileparts(which(testFileName));
            pathstrVec = [modgen.path.rmlastnpathparts(pathstrVec, 1),filesep,'control'];
            TmpDataManager.setRootDir(pathstrVec);
            fileNameSArray = dir(pathstrVec);
            fileNameSArray = fileNameSArray(3:end);
            for nameIterator = 1 : size(fileNameSArray,1)
                testName = modgen.string.splitpart...
                    (fileNameSArray(nameIterator).name, '.', 'first');
                fTest = str2func(testName);
                fTest();
            end
            close all;
            mlunitext.assert(true);
        end
        
    end
end