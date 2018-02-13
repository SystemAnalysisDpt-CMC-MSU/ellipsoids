classdef ETManualTC < mlunitext.test_case
    properties (Access=private)
        originalNTimeGridPoints
        originalNPlot2dPoints
        originalNPlot3dPoints
    end
    methods
        function self=ETManualTC(varargin)
            self=self@mlunitext.test_case(varargin{:});
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
        function self = testBasic(self)
            currentDir = fileparts(which(mfilename('class')));
            rootDir = modgen.path.rmlastnpathparts(currentDir, 5);
            snippetsDir = [rootDir, filesep, 'products', filesep,...
                '+elltool', filesep, '+doc', filesep, '+snip'];
            snippetsPattern = [snippetsDir, filesep, '*.m'];
            fileList = dir(snippetsPattern);
            nFiles = length(fileList);
            BAD_SNIPPET_NAMES = {};
            oldFolder = cd([rootDir, filesep, 'products']);
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
                    eval(['elltool.doc.snip.' fileName]);
                end
            end
            cd(oldFolder);
        end
    end
end
