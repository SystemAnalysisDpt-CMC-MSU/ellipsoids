classdef ConfRepoMgr<modgen.configuration.AdaptiveConfRepoManager&...
        gras.ellapx.uncertmixcalc.conf.sysdef.AConfRepoMgr
    methods
        function self=ConfRepoMgr(varargin)
            import gras.ellapx.uncertmixcalc.conf.sysdef.AConfRepoMgr;
            import gras.ellapx.uncertmixcalc.conf.sysdef.ConfPatchRepo;
            confPatchRepo=ConfPatchRepo();            
            self=self@modgen.configuration.AdaptiveConfRepoManager(...
                varargin{:},...
                'getStorageHook',@AConfRepoMgr.getStorageHook,...
                'putStorageHook',@AConfRepoMgr.putStorageHook,...
                'confPatchRepo',confPatchRepo);
        end
        function selectConf(self,confName,varargin)
            % SELECTCONF - selects the specified plain configuration. If
            % the one does not exist it is created from the template
            % configuration. If the latter does not exist an exception is
            % thrown
            %
            [reg,~,reloadIfSelected,isReloadIfSelected]=...
                modgen.common.parseparext(varargin,...
                {'reloadIfSelected';true;'islogical(x)&&numel(x)==1'},...
                'propRetMode','separate');
            if reloadIfSelected||~self.isConfSelected(confName)
                self.deployConfTemplate(confName,'overwrite',true,...
                    'forceUpdate',true);
            end
            if isReloadIfSelected,
                reg=[reg,{'reloadIfSelected',reloadIfSelected}];
            end
            selectConf@modgen.configuration.AdaptiveConfRepoManager(self,...
                confName,reg{:});
        end          
    end
end
