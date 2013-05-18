classdef mlunit_test_structchangetracker < mlunitext.test_case
    properties
        tracker
    end
    methods
        function self = set_up_param(self,varargin)
            self.tracker=modgen.struct.changetracking.test.StructChangeTrackerTest();
        end
        function self = mlunit_test_structchangetracker(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function self = test_simple_patch(self)
            SRes=self.tracker.applyPatches(struct(),0,1);
            mlunitext.assert_equals(SRes.alpha,1);
            %
            SRes=self.tracker.applyPatches(struct(),0,2);
            mlunitext.assert_equals(SRes.beta,3);
            mlunitext.assert_equals(SRes.alpha,1);
            %
            SRes=self.tracker.applyPatches(struct(),0,103);
            mlunitext.assert_equals(SRes.beta,2);
            SResInf=self.tracker.applyPatches(struct(),-inf,inf);
            mlunitext.assert_equals(true,isequal(SRes,SResInf));
        end        
    end
end
