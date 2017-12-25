classdef DiscrReachTestNTimeGridPoints < mlunitext.test_case
    properties (Access=private)
        originalNTimeGridPoints
        testDataRootDir
        linSys
        tIntervalVec
        x0Ell
        l0Mat
        testReachObjFactory
    end
    %
    methods
        function reachObj = reachDiscrete(self, varargin)
            reachObj = self.testReachObjFactory.createInstance(...
                'reachDiscrete', varargin{:});            
        end
    end
    %
    methods
        function self = DiscrReachTestNTimeGridPoints(varargin)
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
            self.testReachObjFactory = ...
                    elltool.reach.test.mlunit.TReachObjFactory();
            %
            self.linSys = reachFactObj.getLinSys();
            self.tIntervalVec = reachFactObj.getTVec();
            self.x0Ell = reachFactObj.getX0Ell();
            self.l0Mat = reachFactObj.getL0Mat();
        end
        %
        function self = testIsIgnoredNTimeGridPoints(self)
            import elltool.conf.Properties;
            N_TIME_POINTS = 50;
            Properties.setNTimeGridPoints(N_TIME_POINTS);
            k0 = self.tIntervalVec(1);
            k1 = self.tIntervalVec(2);
            isBack = k0 > k1;
            if isBack
                tVec = k0:-1:k1;
            else
                tVec = k0:k1;
            end
            reachSetObj = self.reachDiscrete(self.linSys,...
                self.x0Ell, self.l0Mat, self.tIntervalVec);
            [~, timeVec] = reachSetObj.get_goodcurves();
            mlunitext.assert_equals(numel(tVec), numel(timeVec));
        end
    end
end