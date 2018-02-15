classdef TouchTestCase < mlunitext.test_case
    properties (Access=private)
        nDirs
        funcName
        originalNTimeGridPoints
        originalNPlot2dPoints
        originalNPlot3dPoints
    end
    methods
        function self = TouchTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function set_up(self)
            import elltool.conf.Properties;
            self.originalNTimeGridPoints = Properties.getNTimeGridPoints();
            self.originalNPlot2dPoints = Properties.getNPlot2dPoints();
            self.originalNPlot3dPoints = Properties.getNPlot3dPoints();
        end
        %
        function tear_down(self)
            import elltool.conf.Properties;
            Properties.setNTimeGridPoints(self.originalNTimeGridPoints);
            Properties.setNPlot2dPoints(self.originalNPlot2dPoints);
            Properties.setNPlot3dPoints(self.originalNPlot3dPoints);
        end
        %
        function self = testControl(self)
            import modgen.io.TmpDataManager;
            testFileName = modgen.common.getcallername(1);
            [testDir, ~, ~] = fileparts(which(testFileName));
            testDir = modgen.path.rmlastnpathparts(testDir, 1);
            TmpDataManager.setRootDir(testDir);
            tempDirName=TmpDataManager.getDirByCallerKey('test', 1);
            oldPath = cd(tempDirName);
            cleanupObj=onCleanup(@()myClear(tempDirName,oldPath));
            %
            fTest = str2func(self.funcName);
            fTest(self.nDirs);
            %
            function myClear(tmpDir,oldDir)
                close all;
                cd(oldDir);
                rmdir(tmpDir,'s');
            end
        end
        %
        function self = set_up_param(self, nDirs,funcName)
            self.nDirs = nDirs;
            self.funcName=funcName;
            close all;
        end
    end
end
