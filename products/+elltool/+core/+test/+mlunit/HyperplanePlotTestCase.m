classdef HyperplanePlotTestCase < elltool.core.test.mlunit.BGeomBodyTC
    %
    %$Author: Ilya Lyubich <lubi4ig@gmail.com> $
    %$Date: 2013-05-7 $
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2013 $
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
            self = self@elltool.core.test.mlunit.BGeomBodyTC(varargin{:});
            self.fTest = @hyperplane;
            self.fCheckBoundary = @checkBoundary;
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),...
                filesep,'TestData',...
                filesep,shortClassName];
            function isBoundVec = checkBoundary(cellPoints,testHypVec)
                nHyp = numel(testHypVec);
                isBoundVec = 0;
                for iHyp = 1:nHyp
                    isBoundHypVec =...
                        checkNorm(testHypVec(iHyp), cellPoints);
                    isBoundVec = isBoundVec | isBoundHypVec;
                end
                function isBoundHypVec = checkNorm(testHyp, cellPoints)
                    absTol = elltool.conf.Properties.getAbsTol();
                    [normVec, hypScal] = testHyp.double();
                    isBoundHypVec =...
                        cellfun(@(x) abs(x.'*normVec-hypScal)< ...
                        absTol, cellPoints);
                    
                end
            end
        end
        function self = tear_down(self,varargin)
            close all;
        end
        function self = testPlot2d(self)
            nDims = 2;
            inpNormCList = {[1;1],[2;1],[0;0]};
            inpScalCList = {1,3,0};
            self = plotND(self,nDims,inpNormCList,inpScalCList);
        end
        function self = testPlot3d(self)
            nDims = 3;
            inpNormCList = {[1;1;1],[2;1;3],[0;0;0],[1;0;0]};
            inpScalCList = {1,3,0,0};
            self = plotND(self,nDims,inpNormCList,inpScalCList);
        end
        function testWrongCenterSize(self)
            testFirstHyp = hyperplane([2;1],-1);
            testSecondHyp = hyperplane([3;1],1);
            self.runAndCheckError...
                ('plot(testFirstHyp,''size'',-5)', ...
                'wrongSizeVec');
            self.runAndCheckError...
                ('plot(testFirstHyp,''size'',''a'')', ...
                'wrongInput');
            plot(testFirstHyp,testSecondHyp,'center',[1 -1;1 -2]);
            plot(testFirstHyp,'center',[1 3]);
            plot(testFirstHyp,testSecondHyp,'size',100);
            plot(testFirstHyp,testSecondHyp,'size',[100;2]);
        end
        
    end
end
