classdef DiscreteReachFirstTestCase < mlunitext.test_case
    properties (Access = private, Constant)
        COMP_PRECISION = 5e-5;
    end
    properties (Access=private)
        testDataRootDir
    end
    methods
        function self = DiscreteReachFirstTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir = [fileparts(which(className)),...
                filesep, 'TestData', filesep, shortClassName];
        end
        %
        function self = testFirstBasicTest(self)
            loadFileStr = strcat(self.testDataRootDir,...
                '/demo3DiscreteTest.mat');
            load(loadFileStr, 'aMat', 'bMat', 'ControlBounds',...
                'x0Ell', 'l0Mat', 'timeVec');
            linSysObj = elltool.linsys.LinSysFactory.create(aMat, bMat,...
                ControlBounds,[],[], 'd');
            %timeVec = [0, 3];
            reachSetObj = elltool.reach.ReachDiscrete(linSysObj,...
                x0Ell, l0Mat, timeVec);
            evalc('reachSetObj.display();');
            firstCutReachObj =...
                reachSetObj.cut([timeVec(1)+1 timeVec(end)-1]);
            [~] = reachSetObj.cut(timeVec(1)+2);
            [~, ~] = reachSetObj.dimension();
            [~, ~] = reachSetObj.get_center();
            [~, ~] = reachSetObj.get_directions();
            [~, ~] = reachSetObj.get_ea();
            [~, ~] = reachSetObj.get_ia();
            [~, ~] = reachSetObj.get_goodcurves();
            [~] = reachSetObj.get_system();
            projBasMat = [0 0 0 0 1 0; 0 0 0 0 0 1].';
            projReachSetObj = reachSetObj.projection(projBasMat);
            fig = figure();
            hold on;
            projReachSetObj.plotEa();
            projReachSetObj.plotIa();
            hold off;
            close(fig);
            newReachObj = reachSetObj.evolve(timeVec(2) + 1);
            projReachSetObj.isprojection();
            firstCutReachObj.iscut();
            newReachObj.isEmpty();
        end
        %
        function self = testSecondBasicTest(self)
            loadFileStr = strcat(self.testDataRootDir,...
                '/distorbDiscreteTest.mat');
            load(loadFileStr, 'aMat', 'bMat', 'ControlBounds',...
                'gMat', 'DistorbBounds', 'x0Ell', 'l0Mat', 'timeVec');
            linSysObj = elltool.linsys.LinSysFactory.create(aMat, bMat,...
                ControlBounds, gMat, DistorbBounds,'d');
            reachSetObj = elltool.reach.ReachDiscrete(linSysObj,...
                x0Ell, l0Mat, timeVec);
            evalc('reachSetObj.display();');
            firstCutReachObj =...
                reachSetObj.cut([timeVec(1)+1 timeVec(end)-1]);
            [~] = reachSetObj.cut(timeVec(1)+2);
            [~,~] = reachSetObj.dimension();
            [~,~] = reachSetObj.get_center();
            [~,~] = reachSetObj.get_directions();
            [~,~] = reachSetObj.get_ea();
            [~,~] = reachSetObj.get_ia();
            [~,~] = reachSetObj.get_goodcurves();
            [~] = reachSetObj.get_system();
            projBasMat = [1 0 0; 0 0 1]';
            projReachSetObj = reachSetObj.projection(projBasMat);
            fig = figure();
            hold on;
            projReachSetObj.plotEa();
            projReachSetObj.plotIa();
            hold off;
            close(fig);
            newReachObj = reachSetObj.evolve(2 * timeVec(2));
            projReachSetObj.isprojection();
            firstCutReachObj.iscut();
            newReachObj.isEmpty();
        end
    end
end