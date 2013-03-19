classdef DiscreteReachTestCase < mlunit.test_case
    properties (Constant, GetAccess = private)
        REL_TOL = 1e-5;
        ABS_TOL = 1e-6;
    end
    %
    properties (Access = private)
       testDataRootDir
    end
    %
    methods
        function self = DiscreteReachTestCase(varargin)
            self = self@mlunit.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir =...
                [fileparts(which(className)), filesep,...
                'TestData', filesep, shortClassName];
        end
        %
        function self = testFirstBasicTest(self)
            loadFileStr = strcat(self.testDataRootDir,...
                '/demo3DiscreteTest.mat');
            load(loadFileStr, 'aMat', 'bMat', 'ControlBounds',...
                'x0Ell', 'l0Mat', 'timeVec');
            linSysObj = elltool.linsys.LinSys(aMat, bMat,...
                ControlBounds, [], [], [], [], 'd');
            reachSetObj = elltool.reach.ReachDiscrete(linSysObj,...
                x0Ell, l0Mat, timeVec);
            reachSetObj.display();
            firstCutReachObj =...
                reachSetObj.cut([timeVec(1)+1 timeVec(end)-1]);
            secondCutReachObj = reachSetObj.cut(timeVec(1)+2);
            [rSdim sSdim] = reachSetObj.dimension();
            [trCenterMat tVec] = reachSetObj.get_center();
            [directionsCVec tVec] = reachSetObj.get_directions();
            [eaEllMat tVec] = reachSetObj.get_ea();
            [iaEllMat tVec] = reachSetObj.get_ia();
            [goodCurvesCVec tVec] = reachSetObj.get_goodcurves();
            [muMat tVec] = reachSetObj.get_mu();
            linSys = reachSetObj.get_system();
            projBasMat = [0 0 0 0 1 0; 0 0 0 0 0 1]';
            projReachSetObj = reachSetObj.projection(projBasMat);
            fig = figure();
            hold on;
            projReachSetObj.plot_ea();
            projReachSetObj.plot_ia();
            hold off;
            close(fig);
            newReachObj = reachSetObj.evolve(2 * timeVec(2));
            projReachSetObj.isprojection();
            firstCutReachObj.iscut();
            newReachObj.isempty();
            mlunit.assert_equals(true, true);
        end
        %
        function self = testSecondBasicTest(self)
            loadFileStr = strcat(self.testDataRootDir,...
                '/distorbDiscreteTest.mat');
            load(loadFileStr, 'aMat', 'bMat', 'ControlBounds',...
                'gMat', 'DistorbBounds', 'x0Ell', 'l0Mat', 'timeVec');
            linSysObj = elltool.linsys.LinSys(aMat, bMat,...
                ControlBounds, gMat, DistorbBounds, [], [], 'd');
            reachSetObj = elltool.reach.ReachDiscrete(linSysObj,...
                x0Ell, l0Mat, timeVec);
            reachSetObj.display();
            firstCutReachObj =...
                reachSetObj.cut([timeVec(1)+1 timeVec(end)-1]);
            secondCutReachObj = reachSetObj.cut(timeVec(1)+2);
            [rSdim sSdim] = reachSetObj.dimension();
            [trCenterMat tVec] = reachSetObj.get_center();
            [directionsCVec tVec] = reachSetObj.get_directions();
            [eaEllMat tVec] = reachSetObj.get_ea();
            [iaEllMat tVec] = reachSetObj.get_ia();
            [goodCurvesCVec tVec] = reachSetObj.get_goodcurves();
            [muMat tVec] = reachSetObj.get_mu();
            linSys = reachSetObj.get_system();
            projBasMat = [1 0 0; 0 0 1]';
            projReachSetObj = reachSetObj.projection(projBasMat);
            fig = figure();
            hold on;
            projReachSetObj.plot_ea();
            projReachSetObj.plot_ia();
            hold off;
            close(fig);
            newReachObj = reachSetObj.evolve(2 * timeVec(2));
            projReachSetObj.isprojection();
            firstCutReachObj.iscut();
            newReachObj.isempty();
            mlunit.assert_equals(true, true);
        end
        %
    end
    
end