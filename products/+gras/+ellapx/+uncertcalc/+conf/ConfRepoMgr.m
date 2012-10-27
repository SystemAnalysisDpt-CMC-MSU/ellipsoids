classdef ConfRepoMgr<modgen.configuration.ConfRepoManagerUpd&...
        gras.ellapx.uncertcalc.conf.IConfRepoMgr
    methods
        function self=ConfRepoMgr(varargin)
            self=self@modgen.configuration.ConfRepoManagerUpd(varargin{:});
            confPatchRepo=gras.ellapx.uncertcalc.conf.ConfPatchRepo();
            self.setConfPatchRepo(confPatchRepo);
        end
    end
end
