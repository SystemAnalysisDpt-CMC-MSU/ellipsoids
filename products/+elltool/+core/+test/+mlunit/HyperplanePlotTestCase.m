classdef HyperplanePlotTestCase < elltool.plot.test.AGeomBodyPlotTestCase
    %
    properties (Access=private)
        testDataRootDir
        
    end
    %
    methods(Access=protected)
        function [plObj,numObj] = getInstance(varargin)
            if numel(varargin)==2
                temp = varargin{2};
                plObj = hyperplane(temp(:,1));
                if size(varargin{2},1) == 2
                    numObj = 1;
                else
                    numObj = 4;
                end
            else
                temp = varargin{3};
                plObj = hyperplane(temp(:,1),sum(varargin{2}));
                if size(varargin{3},1) == 2
                    numObj = 1;
                else
                    numObj = 4;
                end
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