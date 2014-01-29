classdef ConfRepoMgr<modgen.configuration.ConfRepoManagerUpd&...
        gras.ellapx.uncertmixcalc.conf.IConfRepoMgr
    methods
        function self=ConfRepoMgr(varargin)
            self=self@modgen.configuration.ConfRepoManagerUpd(varargin{:});
            confPatchRepo=gras.ellapx.uncertmixcalc.conf.ConfPatchRepo();
            self.setConfPatchRepo(confPatchRepo);
        end
    end
end
