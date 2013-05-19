classdef EllipsoidPlotTestCase < elltool.core.test.mlunit.BGeomBodyTC
    %%$Author: Ilya Lyubich <lubi4ig@gmail.com> $
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
                plObj = ellipsoid(varargin{2});
                if size(varargin{2},1) == 2
                    numObj = 2;
                else
                    numObj = 4;
                end
            else
                plObj = ellipsoid(varargin{2},varargin{3});
                if size(varargin{3},1) == 2
                    numObj = 2;
                else
                    numObj = 4;
                end
            end
        end
    end
    methods
        function self = EllipsoidPlotTestCase(varargin)
            self = self@elltool.core.test.mlunit.BGeomBodyTC(varargin{:});
            self.fTest = @ellipsoid;
            self.fCheckBoundary = @checkBoundary;
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),...
                filesep,'TestData',...
                filesep,shortClassName];
            function isBoundVec = checkBoundary(cellPoints,testEllVec)
                nEll = numel(testEllVec);
                isBoundVec = 0;
                nDims = size(double(testEllVec(1)),2);
                for iEll = 1:nEll
                    [~,qMat] = testEllVec(iEll).double();
                    [~,dMat] = eig(qMat);
                    if nDims == 1
                        isBoundEllVec = check1d(testEllVec(iEll),...
                            cellPoints);
                    elseif nDims == 2
                        if dMat(1,1) == 0
                            isBoundEllVec = check2dDimZero(...
                                testEllVec(iEll), cellPoints, 1);
                        elseif dMat(2,2) == 0
                            isBoundEllVec = check2dDimZero(...
                                testEllVec(iEll), cellPoints, 2);
                        else
                            isBoundEllVec = checkNorm(testEllVec(iEll),...
                                cellPoints);
                        end
                    elseif nDims == 3
                        if dMat(1,1) == 0
                            isBoundEllVec = check3dDimZero(...
                                testEllVec(iEll), cellPoints, 1);
                        elseif dMat(2,2) == 0
                            isBoundEllVec = check3dDimZero(...
                                testEllVec(iEll), cellPoints, 2);
                        elseif dMat(3,3) == 0
                            isBoundEllVec = check3dDimZero(...
                                testEllVec(iEll), cellPoints, 3);
                        else
                            isBoundEllVec = checkNorm(testEllVec(iEll),...
                                cellPoints);
                        end
                    end
                    isBoundVec = isBoundVec | isBoundEllVec;
                end
            end
            function isBoundEllVec = check2dDimZero(testEll,...
                    cellPoints, dim)
                absTol = elltool.conf.Properties.getAbsTol();
                [qCenVec,qMat] = testEll.double();
                [eigMat,dMat] = eig(qMat);
                secDim = @(x) x(3-dim);
                eigPoint = @(x) secDim(eigMat*(x-qCenVec)+qCenVec);
                qCenVec = qCenVec(3-dim);
                isBoundEllVec = cellfun(@(x) abs(((eigPoint(x) -...
                    qCenVec).'/dMat(3-dim, 3-dim))*...
                    (eigPoint(x) - qCenVec)) < 1 +  absTol, cellPoints);
                
            end
            
            function isBoundEllVec = check3dDimZero(testEll,...
                    cellPoints, dim)
                absTol = elltool.conf.Properties.getAbsTol();
                [qCenVec,qMat] = testEll.double();
                [eigMat,dMat] = eig(qMat);
                if dim == 1
                    secDim = @(x) [x(2), x(3)].';
                    invMat = diag([1/dMat(2,2), 1/dMat(3,3)]);
                elseif dim == 2
                    secDim = @(x) [x(1), x(3)].';
                    invMat = diag([1/dMat(1,1), 1/dMat(3,3)]);
                else
                    secDim = @(x) [x(1), x(2)].';
                    invMat = diag([1/dMat(1,1), 1/dMat(2,2)]);
                end
                eigPoint = @(x) secDim(eigMat*(x-qCenVec)+qCenVec);
                qCenVec = secDim(qCenVec);
                isBoundEllVec = cellfun(@(x) abs(((eigPoint(x)...
                    - qCenVec).'*invMat)*...
                    (eigPoint(x) - qCenVec)) < 1 +  absTol, cellPoints);
                
            end
            function isBoundEllVec = checkNorm(testEll, cellPoints)
                absTol = elltool.conf.Properties.getAbsTol();
                [qCenVec,qMat] = testEll.double();
                isBoundEllVec = cellfun(@(x)...
                    abs(((x - qCenVec).'/qMat)*(x-qCenVec)-1)< ...
                    absTol, cellPoints);
                isBoundEllVec = isBoundEllVec | ...
                    cellfun(@(x) norm(x - qCenVec) < ...
                    absTol, cellPoints);
                
            end
            function isBoundEllVec = check1d(testEll, cellPoints)
                absTol = elltool.conf.Properties.getAbsTol();
                [qCenVec,qMat] = testEll.double();
                isBoundEllVec = cellfun(@(x)...
                    abs((x-qCenVec)*(x-qCenVec).')...
                    <= qMat*(1 + absTol), ...
                    cellPoints);
            end
        end
        function self = tear_down(self,varargin)
            close all;
        end
        function self = testPlot2d(self)
            nDims = 2;
            inpArgCList = {[cos(pi/4), sin(pi/4); -sin(pi/4),...
                cos(pi/4)]* ...
                [1, 0; 0, 4]*[cos(pi/4), sin(pi/4); -sin(pi/4),...
                cos(pi/4)].', ...
                [1, 2; 2, 5], diag([10000, 1e-5]), diag([3, 0.1]), ...
                diag([10000, 10000]), diag([1e-5, 4]),[1 0; 0 0]};
            inpCenCList = {[0, 0].', [100, 100].', [0, 0].', [4, 5].', ...
                [0, 0].', [-10, -10].',[0 0]'};
            self = plotND(self,nDims,inpCenCList,inpArgCList);
        end
        function self = testPlot3d(self)
            nDims = 3;
            inpCenCList = {[0, 0, 0].', [1, 10, -1].', [0, 0, 0].', ...
                [1, 1, 0].', [10, -10, 10].'};
            inpQMatCList = {eye(3),[2 0 0;...
                0 0.325 -0.3897;0 -0.3897 0.775],...
                [1.5 0 -0.866;0 1 0; -0.866 0 2.5],...
                diag([1, 100, 0.1]), [1 0 0;0 1 0; 0 0 0]};
            self = plotND(self,nDims,inpCenCList,inpQMatCList);
        end
    end
    
end