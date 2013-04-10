classdef ETManualTC < mlunitext.test_case
     methods
        function self=ETManualTC(varargin)
            self=self@mlunitext.test_case(varargin{:});
        end
        function self = set_up_param(self,varargin)

        end
        function self = DISABLED_testBasic(self)
            currentDir = fileparts(which(mfilename('class')));
            rootDir = modgen.path.rmlastnpathparts(currentDir, 5);
            snippetsDir = [rootDir, filesep, 'doc', filesep, 'mcodesnippets'];
            snippetsPattern = [snippetsDir, filesep, '*.m'];
            fileList =  dir(snippetsPattern);
            nFiles = length(fileList);
            oldFolder = cd(snippetsDir);
            for iFile = 1:nFiles
               [~,fileName] = fileparts(fileList(iFile).name);
               eval(fileName); 
            end
            cd(oldFolder);  
        end
    end
end
