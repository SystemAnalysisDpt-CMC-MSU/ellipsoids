classdef ContinuousIsEqualTestCase < mlunitext.test_case
    properties (Access=private, Constant)
        FIELDS_NOT_TO_COMPARE={'LT_GOOD_DIR_MAT';'LT_GOOD_DIR_NORM_VEC';...
            'LS_GOOD_DIR_NORM';'LS_GOOD_DIR_VEC'};
        COMP_PRECISION = 5e-5;
    end
    properties (Access=private)
        linSys
        reachObj
        timeVec
        x0Ell
        l0Mat
        reachFactObj
    end
    %
    methods (Access = private, Static)
        function doubleCMat = getDoubleCMatrix(inpCMat)
            zeroInpSizeCMat = arrayfun(@num2str, zeros(size(inpCMat)),...
                'UniformOutput', false);
            doubleCMat = [inpCMat zeroInpSizeCMat; zeroInpSizeCMat inpCMat];
        end
    end
    %
    methods
        function self = ContinuousIsEqualTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up_param(self, reachFactObj)
            self.reachFactObj = reachFactObj;
            self.reachObj = reachFactObj.createInstance();
            self.linSys = reachFactObj.getLinSys();
            self.timeVec = reachFactObj.getTVec();
            self.l0Mat = reachFactObj.getL0Mat();
            self.x0Ell = reachFactObj.getX0Ell();
        end        
        %
        function self = testIsEqual(self)
            % Equality of the identical reaches
            sameReachObj = self.reachFactObj.createInstance();
            [isEqual, reportStr] = self.reachObj.isEqual(sameReachObj);
            mlunit.assert(isEqual, reportStr);
            % Inequality of reaches with different time
            %
            % finish time differs
            newTimeVec = self.timeVec;
            newTimeVec(2) = newTimeVec(2) + 1;
            longerReachObj = elltool.reach.ReachContinuous(self.linSys,...
                self.x0Ell, self.l0Mat, newTimeVec);
            [isEqual, reportStr] = self.reachObj.isEqual(longerReachObj);
            mlunit.assert(~isEqual, reportStr);
            % start time differs
            newTimeVec = self.timeVec;
            newTimeVec(1) = newTimeVec(1) - 1;
            longerReachObj = elltool.reach.ReachContinuous(self.linSys,...
                self.x0Ell, self.l0Mat, newTimeVec);
            [isEqual, reportStr] = self.reachObj.isEqual(longerReachObj);
            mlunit.assert(~isEqual, reportStr);
            % Equality of enclosedly-grided reaches
            %
            
            
        end
    end
end