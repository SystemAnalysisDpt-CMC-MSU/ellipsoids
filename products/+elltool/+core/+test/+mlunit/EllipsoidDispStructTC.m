classdef EllipsoidDispStructTC < ...
    elltool.core.test.mlunit.ADispStructTC & ...
    elltool.core.test.mlunit.EllFactoryTC
    %
    %$Author: Alexander Karev <Alexander.Karev.30@gmail.com> $
    %$Date: 2013-06$
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2013 $
    
    methods (Access = protected)
        function objArrCVec = getToStructObj(self)
            objArrCVec = {self.createEll([1, 1]', eye(2)),...
                self.createEll(),...
                self.createEll([1, 1]', eye(2)),...
                self.createEll([1, 1]', eye(2)),...
                self.createEll([1, 1]', eye(2)),...
                self.createEll.fromRepMat(1, 1, [5 5 5]),...
                self.createEll.fromRepMat(1, 1, [5 5 5])};
            objArrCVec{7}(1) = self.createEll();
        end
        
        function SArrCVec = getToStructStruct(self)
            import elltool.conf.Properties;
            SArrCVec = {struct('shapeMat', eye(2), 'centerVec', [1, 1]'),...
                struct('shapeMat', [], 'centerVec', []),...
                struct('shapeMat', [], 'centerVec', []),...
                struct('shapeMat', eye(2), 'centerVec', [1, 1]',...
                'absTol', Properties.getAbsTol, 'relTol',Properties.getRelTol,...
                'nPlot2dPoints', Properties.getNPlot2dPoints,...
                'nPlot3dPoints', Properties.getNPlot3dPoints),...
                struct('shapeMat', eye(2), 'centerVec', [2, 1]'),...
                struct('shapeMat', num2cell(ones(5, 5, 5)), ...
                'centerVec', num2cell(ones(5, 5, 5))),...
                struct('shapeMat', num2cell(ones(5, 5, 5)), ...
                'centerVec', num2cell(ones(5, 5, 5)))};
        end
        
        function isPropCVec = getToStructIsPropIncluded(self)
            isPropCVec = {false, false, false, true, false, false, false};
        end
        
        function isResultCVec = getToStructResult(self)
            isResultCVec = {true, true, false, true, false, true, false};
        end
        
        function testNumber = getToStructTestNumber(self)
            testNumber = 7;
        end
        
        function objArrCVec = getFromStructObj(self)
            objArrCVec = {self.createEll([1, 1]', eye(2)),...
                self.createEll([1, 1]', eye(2), 'absTol', 1e-8,...
                'relTol', 1e-4, 'nPlot2dPoints', 300, ...
                'nPlot3dPoints', 100),...
                self.createEll(),...
                self.createEll([1, 1]', eye(2)),...
                self.createEll.fromRepMat(1, 1, [5 5 5]),...
                self.createEll.fromRepMat(1, 1, [5 5 5])};
            objArrCVec{6}(1) = self.createEll();
        end
        
        function SArrCVec = getFromStructStruct(self)
            SArrCVec = {struct('shapeMat', eye(2), 'centerVec', [1, 1]),...
                struct('shapeMat', eye(2), 'centerVec', [1, 1],...
                'absTol', 1e-8, 'relTol', 1e-4,...
                'nPlot2dPoints', 300, 'nPlot3dPoints', 100),...
                struct('shapeMat', eye(2), 'centerVec', [1, 1],...
                'absTol', 1e-8, 'relTol', 1e-4,...
                'nPlot2dPoints', 300, 'nPlot3dPoints', 100),...
                struct('shapeMat', eye(2), 'centerVec', [1, 1],...
                'absTol', 1e-8, 'relTol', 1e-4,...
                'nPlot2dPoints', 300, 'nPlot3dPoints', 100),...
                struct('shapeMat', num2cell(ones(5, 5, 5)),...
                'centerVec', num2cell(ones(5, 5, 5))),...
                struct('shapeMat', num2cell(ones(5, 5, 5)),...
                'centerVec', num2cell(ones(5, 5, 5)))};
        end
        
        function isResultCVec = getFromStructResult(self)
            isResultCVec = {true, true, false, false, true, false};
        end
        
        function testNumber = getFromStructTestNumber(self)
            testNumber = 6;
        end
        
        function objArrCVec = getDisplayObj(self)
            objArrCVec = {self.createEll([1, 1]', eye(2)),...
                self.createEll(),...
                self.createEll([1, 2]', eye(2)),...
                self.createEll.fromStruct(struct('shapeMat',...
                num2cell(ones(5, 5, 5)), ...
                'centerVec', num2cell(ones(5, 5, 5)))),...
                self.createEll.fromStruct(struct('shapeMat', ...
                num2cell(ones(5, 5, 5)), ...
                'centerVec', num2cell(ones(5, 5, 5)))),...
                hyperplane()};
            objArrCVec{5} = [objArrCVec{5} objArrCVec{5}];
        end
        
        function stringsCVec = getDisplayStrings(self)
            stringsCVec = {'Ellipsoid shape matrix.', ...
                'ellipsoid object',...
                'centerVec',...
                'shapeMat'};
            stringsCVec = repmat({stringsCVec}, 1, 6);
            stringsCVec{5} = horzcat(stringsCVec{5}, 'objArr(1, 1, 1)');
        end
        
        function isResultCVec = getDisplayResult(self)
            isResultCVec = {true, true, true, true, true, false};
        end
        
        function testNumber = getDisplayTestNumber(self)
            testNumber = 6;
        end
        
        function objArrCVec = getEqFstObj(self)
            objArrCVec = {self.createEll([1, 1]', eye(2)),...
                self.createEll(),...
                self.createEll([1, 2]', eye(2)),...
                self.createEll(),...
                self.createEll(),...
                self.createEll.fromStruct(struct('shapeMat',...
                num2cell(ones(5, 5, 5)), ...
                'centerVec', num2cell(ones(5, 5, 5)))),...
                self.createEll.fromStruct(struct('shapeMat',...
                num2cell(ones(5, 5, 5)), ...
                'centerVec', num2cell(ones(5, 5, 5)))),...
                self.createEll.fromRepMat([1, 1]', eye(2), [1 2])};
        end
        
        function objArrCVec = getEqSndObj(self)
            objArrCVec = {self.createEll([1, 1]', eye(2)),...
                self.createEll(),...
                self.createEll([1, 2]', eye(2)),...
                self.createEll([1, 2]', eye(2)),...
                self.createEll([1, 1]', eye(2)),...
                self.createEll.fromStruct(struct('shapeMat',...
                num2cell(ones(5, 5, 5)), ...
                'centerVec', num2cell(ones(5, 5, 5)))),...
                self.createEll.fromStruct(struct('shapeMat',...
                num2cell(ones(5, 5, 5)), ...
                'centerVec', num2cell(ones(5, 5, 5)))),...
                self.createEll.fromRepMat([1, 1]', eye(2), [1 2])};
            objArrCVec{7}(1, 1, 1) = self.createEll();
        end
        
        function isResultCVec = getEqResult(self)
            isResultCVec = {true, true, true, false,...
                false, true, false, true};
        end
        
        function testNumber = getEqTestNumber(self)
            testNumber = 8;
        end
    end
    
    methods (Access = public)
        function self = EllipsoidDispStructTC(varargin)
            self = self@elltool.core.test.mlunit.ADispStructTC(varargin{:});
        end
    end
end