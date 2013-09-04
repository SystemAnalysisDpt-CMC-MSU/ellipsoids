classdef ETManualTC < mlunitext.test_case
    methods
        function self=ETManualTC(varargin)
            self=self@mlunitext.test_case(varargin{:});
        end
        function self = set_up_param(self,varargin)
            
        end
        function self = testBasic(self)
            currentDir = fileparts(which(mfilename('class')));
            rootDir = modgen.path.rmlastnpathparts(currentDir, 5);
            snippetsDir = [rootDir, filesep, 'doc', filesep,...
                'mcodesnippets'];
            snippetsPattern = [snippetsDir, filesep, '*.m'];
            fileList = dir(snippetsPattern);
            nFiles = length(fileList);
            BAD_SNIPPET_NAMES = {};
            oldFolder = cd(snippetsDir);
            for iFile = 1 : nFiles
                isBad = false;
                nameStr = fileList(iFile).name;
                for iBad = 1 : numel(BAD_SNIPPET_NAMES)
                    if strcmp(nameStr, BAD_SNIPPET_NAMES{iBad})
                        isBad = true;
                    end
                end
                if ~isBad
                    [~, fileName] = fileparts(nameStr);
                    eval(fileName);
                end
            end
            cd(oldFolder);
        end
    end
end
