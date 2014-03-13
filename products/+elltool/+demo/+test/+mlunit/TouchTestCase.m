classdef TouchTestCase < mlunitext.test_case
    properties
    end
    
    methods
        function self = TouchTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function testControl(~)
            import modgen.io.TmpDataManager;
            import elltool.demo.test.control.*
            testFileName = modgen.common.getcallername(1);
            [pathstrVec, ~, ~] = fileparts(which(testFileName));
            pathstrVec = [modgen.path.rmlastnpathparts(pathstrVec, 1),filesep,'+control'];
            TmpDataManager.setRootDir(pathstrVec);
            tempDirName = TmpDataManager.getDirByCallerKey('test', 1);
            oldPath = cd(tempDirName);
            SFileNameArray = dir(pathstrVec);
            SFileNameArray = SFileNameArray(3:end);
            for iName = 1 : size(SFileNameArray,1)
                testName = modgen.string.splitpart...
                    (SFileNameArray(iName).name, '.', 'first');
                disp(sprintf('Test %s started',testName));
                time0 = now;
                eval(testName);
                disp(sprintf('Passed %s test: %.1f s',testName,(now-time0)*86400));
            end
            close all;
            cd(oldPath);
            rmdir(tempDirName);
            mlunitext.assert(true);
        end
        
    end
end