classdef TouchTestCase < mlunitext.test_case
    properties (Access=private)
        nDirs
    end
    
    methods
        function self = TouchTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function self = testControl(self)
            import modgen.io.TmpDataManager;
%             import elltool.demo.test.control.*;
            
            testFileName = modgen.common.getcallername(1);
            [pathstrVec, ~, ~] = fileparts(which(testFileName));
            pathstrVec = modgen.path.rmlastnpathparts(pathstrVec, 1);
            TmpDataManager.setRootDir(pathstrVec);
            tempDirName = TmpDataManager.getDirByCallerKey('test', 1);
            oldPath = cd(tempDirName);
            pathstrVec = [pathstrVec,filesep,'+control'];
            SFileNameArray = dir(pathstrVec);
            SFileNameArray = SFileNameArray(3:end);
            for iName = 20 : size(SFileNameArray,1)
                testName = modgen.string.splitpart...
                    (SFileNameArray(iName).name, '.', 'first');
                testName = strcat('elltool.demo.test.control.',testName);
                disp(sprintf('Test %s started',testName));
                fTest = str2func(testName);
                time0 = now;
                fTest(self.nDirs);
                disp(sprintf('Passed %s test: %.1f s',testName,(now-time0)*86400));
            end
            close all;
            cd(oldPath);
            rmdir(tempDirName,'s');
        end
        
        function self = set_up_param(self, nDirs)
            self.nDirs = nDirs;
        end
        
    end
end