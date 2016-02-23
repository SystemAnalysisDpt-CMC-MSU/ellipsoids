classdef ContReachTestNTimeGridPoints < mlunitext.test_case
    properties (Access=private)
        originalNTimeGridPoints
        testDataRootDir
        linSys
        tVec
        x0Ell
        l0Mat
    end
    methods
        function self = ContReachTestNTimeGridPoints(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir = [fileparts(which(className)),...
                filesep, 'TestData', filesep, shortClassName];
        end
        %
        function set_up(self)
            import elltool.conf.Properties;
            self.originalNTimeGridPoints = Properties.getNTimeGridPoints();
        end
        %
        function tear_down(self)
            import elltool.conf.Properties;
            Properties.setNTimeGridPoints(self.originalNTimeGridPoints);
        end
        %
        function self = set_up_param(self, reachFactObj)
            self.linSys = reachFactObj.getLinSys();
            self.tVec = reachFactObj.getTVec();
            self.x0Ell = reachFactObj.getX0Ell();
            self.l0Mat = reachFactObj.getL0Mat();
        end
        %
        function self = testNTimeGridPoints(self)
            import elltool.conf.Properties;
            N_TIME_POINTS = 135;
            Properties.setNTimeGridPoints(N_TIME_POINTS);
            reachObj = elltool.reach.ReachContinuous(self.linSys,...
                self.x0Ell, self.l0Mat, self.tVec);
            [~, timeVec] = reachObj.get_goodcurves();
            mlunitext.assert_equals(N_TIME_POINTS, numel(timeVec));
        end
        %
        function self = testSetMatchesGetNTimeGridPoints(self)
            import elltool.conf.Properties;
            reachObj = elltool.reach.ReachContinuous(self.linSys,...
                self.x0Ell, self.l0Mat, self.tVec);
            [~, timeVec] = reachObj.get_goodcurves();
            currentNTimeGridPoints = Properties.getNTimeGridPoints();
            mlunitext.assert_equals(currentNTimeGridPoints, numel(timeVec));
        end
        %
        function self = testPassedIntoConstNTimeGridPoints(self)
            import elltool.conf.Properties;
            N_TIME_POINTS = 155;
            reachObj = elltool.reach.ReachContinuous(self.linSys,...
                self.x0Ell, self.l0Mat, self.tVec, 'nTimeGridPoints',...
                N_TIME_POINTS);
            [~, timeVec] = reachObj.get_goodcurves();
            mlunitext.assert_equals(N_TIME_POINTS, numel(timeVec));
        end
    end
end