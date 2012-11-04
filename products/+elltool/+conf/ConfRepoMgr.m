classdef ConfRepoMgr<modgen.configuration.AdaptiveConfRepoManager
    methods
        function self=ConfRepoMgr(varargin)
            self=self@modgen.configuration.AdaptiveConfRepoManager(varargin{:});
            confPatchRepo=elltool.test.configuration.ConfPatchRepo();
            self.setConfPatchRepo(confPatchRepo);
        end
    end
end