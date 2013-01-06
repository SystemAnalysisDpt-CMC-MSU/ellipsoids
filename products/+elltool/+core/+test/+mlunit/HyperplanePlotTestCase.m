classdef HyperplanePlotTestCase < elltool.plot.test.AGeomBodyPlotTestCase
    %
    properties (Access=private)
        testDataRootDir
        
    end
    %
    methods(Access=protected)
        function self = getInstance(varargin)
            if numel(varargin)==2
                temp = varargin{2};
                self = hyperplane(temp(:,1));
            else
                temp = varargin{3};
                self = hyperplane(temp(:,1),sum(varargin{2}));
            end
        end
    end
    methods
        function self = HyperplanePlotTestCase(varargin)
            self = self@elltool.plot.test.AGeomBodyPlotTestCase(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,'TestData',...
                filesep,shortClassName];
        end
        function self = tear_down(self,varargin)
            close all;
        end
    end
end