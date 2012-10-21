classdef AdpConfRepoMgrNegative<modgen.configuration.AdaptiveConfRepoManager
    methods
        function self=AdpConfRepoMgrNegative(varargin)
            confPatchRepo=...
                modgen.configuration.test.StructChangeTrackerNegative();
            self.setConfPatchRepo(confPatchRepo);
        end
    end
end
