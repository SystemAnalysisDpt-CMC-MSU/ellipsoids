classdef ConfRepoMgr<modgen.configuration.AdaptiveConfRepoManager&...
        gras.ellapx.uncertmixcalc.conf.IConfRepoMgr
    methods
        function self=ConfRepoMgr(varargin)
            self=self@modgen.configuration.AdaptiveConfRepoManager(...
                varargin{:});
            confPatchRepo=gras.ellapx.uncertmixcalc.conf.ConfPatchRepo();
            self.setConfPatchRepo(confPatchRepo);
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
