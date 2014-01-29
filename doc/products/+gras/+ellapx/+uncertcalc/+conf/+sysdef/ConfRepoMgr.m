classdef ConfRepoMgr<modgen.configuration.ConfRepoManagerUpd&...
        gras.ellapx.uncertcalc.conf.sysdef.AConfRepoMgr
    methods
        function self=ConfRepoMgr(varargin)
            import gras.ellapx.uncertcalc.conf.sysdef.AConfRepoMgr;
            import gras.ellapx.uncertcalc.conf.sysdef.ConfPatchRepo;
            confPatchRepo=ConfPatchRepo();            
            self=self@modgen.configuration.ConfRepoManagerUpd(varargin{:},...
                'getStorageHook',@AConfRepoMgr.getStorageHook,...
                'putStorageHook',@AConfRepoMgr.putStorageHook,...
                'confPatchRepo',confPatchRepo);
        end
    end
end
