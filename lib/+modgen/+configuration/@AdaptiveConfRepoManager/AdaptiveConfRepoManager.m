classdef AdaptiveConfRepoManager<modgen.configuration.ConfRepoManager
    % UDAPTIVECONFREPOMANAGER is an extension of the plain ConfRepoManager
    % that introduces a separation between template configurations and
    % plain configurations. Template configuration is like default
    % configurations that is used in place of a plain configurations
    % when the plain configuration is not found for a given name. If
    % template configuration for the same name is not found as well, the
    % class throws an exception. Such a behavior is useful when the
    % application runs on a new environemnt/computer as it leads to an
    % automatic deployment of application configuration
    %
    %
    %
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-08-17 $
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %
    %
    properties (Constant,Access=protected)
        DEFAULT_TEMPLATE_STORAGE_BRANCH_KEY='_templates';
    end
    properties (Access=private)
        templateRepoMgr
    end
    properties (Access=protected)
        templateStorageBranchKey
    end
    %
    methods
        function storageDir=getTemplateBranchKey(self)
            storageDir=self.templateStorageBranchKey;
        end        
        function setConfPatchRepo(self,confPatchRepo)
            % SET
            setConfPatchRepo@modgen.configuration.ConfRepoManager(self,confPatchRepo);
            self.templateRepoMgr.setConfPatchRepo(confPatchRepo);
        end
        function self=AdaptiveConfRepoManager(varargin)
            %
            import modgen.common.parseparext;
            import modgen.configuration.AdaptiveConfRepoManager;
            import modgen.common.throwerror;
            %
            %% parse input params
            [~,hostName]=modgen.system.getuserhost();
            %
            [restArgList,~,templateStorageBranchKey,confPatchRepo,...
                currentStorageBranchKey,...
                ~,isConfPatchRepoSpec]=parseparext(varargin,...
                {'templateBranchKey',...
                'confPatchRepo','currentBranchKey';...
                AdaptiveConfRepoManager.DEFAULT_TEMPLATE_STORAGE_BRANCH_KEY,...
                [],hostName;...
                'ischarstring(x)',...
                @(x)isa(x,'modgen.struct.changetracking.StructChangeTracker'),...
                'ischarstring(x)'});
            %%
            self=self@modgen.configuration.ConfRepoManager(...
                'storageBranchKey',currentStorageBranchKey,restArgList{:});
            %
            self.templateStorageBranchKey=templateStorageBranchKey;
            %
            [restArgList,~,repoLocation]=parseparext(restArgList,...
                {'repoLocation';self.getStorageLocationRoot()});
            self.templateRepoMgr=modgen.configuration.ConfRepoManager(...
                'storageBranchKey',self.templateStorageBranchKey,...
                'repoLocation',repoLocation,restArgList{:});
            %
            if isConfPatchRepoSpec
                self.setConfPatchRepo(confPatchRepo);
            end
            %
        end
        function selectConf(self,confName,varargin)
            % SELECTCONF - selects the specified plain configuration. If
            %              the one does not exist it is created from the
            %              template configuration. If the latter does not
            %              exist an exception is thrown
            %
            %
            % Input:
            %   regular:
            %       self: the object itself
            %       confName: char[1,] - configuration name
            %
            %   properties:
            %       reloadIfSelected: logical[1,1] - if false,
            %           configuration is loaded from disk only if it
            %           wasn't selected previously.
            %
            %
            
            [reg,~,reloadIfSelected,isReloadIfSelected]=...
                modgen.common.parseparext(varargin,...
                {'reloadIfSelected';true;'islogical(x)&&numel(x)==1'},...
                'propRetMode','separate');
            if reloadIfSelected,
                self.deployConfTemplate(confName,'forceUpdate',true);
            end
            if isReloadIfSelected,
                reg=[reg,{'reloadIfSelected',reloadIfSelected}];
            end
            selectConf@modgen.configuration.ConfRepoManager(self,...
                confName,reg{:});
        end
        function updateAll(self,areAllBranchesUpdated)
            % UPDATEALL - updates both templates and plain configurations
            %
            % Input:
            %   regular:
            %       self: modgen.configuration.AdaptiveConfRepoManager[1,1]
            %       areAllBranchesUpdated: logical[1,1] - if true, all
            %           branches are updated, not just a branch that
            %           corresponds to a current host. (false by default)
            %
            if nargin<2
                areAllBranchesUpdated=false;
            end
            %
            confNameList=self.templateRepoMgr.getConfNameList;
            cellfun(@(x)updateConf(self.templateRepoMgr,x),confNameList);
            %
            confNameList=self.getConfNameList;
            cellfun(@(x)updateConf(self,x),confNameList);
            %
            if areAllBranchesUpdated
                branchKeyList=self.getBranchKeyList(false);
                curBranchKey=self.getStorageBranchKey();
                restBranchKeyList=setdiff(branchKeyList,curBranchKey);
                %
                storageRootDir=self.getStorageLocationRoot();                
                %
                nRestBranches=numel(restBranchKeyList);
                for iBranch=1:nRestBranches
                    branchName=restBranchKeyList{iBranch};
                    branchConfRepoMgr=self.templateRepoMgr.createInstance(...
                        'storageBranchKey',branchName,...
                        'repoLocation',storageRootDir,'confPatchRepo',...
                        self.confPatchRepo);
                    confNameList=branchConfRepoMgr.getConfNameList;
                    cellfun(@(x)updateConf(branchConfRepoMgr,x),...
                        confNameList);
                end
            end
        end
        function branchKeyList=getBranchKeyList(self,...
                isTemplateBranchIncluded)
            NOT_BRANCH_FOLDER_LIST={'.','..'};
            if nargin<2
                isTemplateBranchIncluded=false;
            end
            storageRootDir=self.getStorageLocationRoot();
            SFileVec=dir([storageRootDir,filesep,'*']);
            %
            if isTemplateBranchIncluded
                excludeBranchList=NOT_BRANCH_FOLDER_LIST;
            else
                excludeBranchList=[NOT_BRANCH_FOLDER_LIST,...
                    self.templateStorageBranchKey];
            end
            %
            branchKeyList=setdiff({SFileVec.name},excludeBranchList);
        end
        function updateConfTemplate(self,confName)
            % UPDATECONFTEMPLATE - updates template configuration
            %
            %
            self.templateRepoMgr.updateConf(confName);
        end
        %
        function [SConf,confVersion,metaData]=getConf(self,confName)
            % GETCONF - returns a configuration by its name. In case the
            %           specified configuration is not found , the class
            %           tries to create one from a template
            %
            %
            self.deployConfTemplate(confName);
            [SConf,confVersion,metaData]=getConfInternal(self,confName);
            
        end
        function editConfTemplate(self,confName)
            % EDITCONFTEMPLATE - opens the specified template configuration
            %                    for editing using a default editor
            %
            %
            self.templateRepoMgr.editConf(confName);
        end
        %
        function confNameList=deployConfTemplate(self,inpConfName,varargin)
            % DEPLOYCONFTEMPLATE - deploys (i.e. transforms templates to
            %                      plain configurations) the specified
            %                      onfiguration(s))
            %
            % Input:
            %   regular:
            %       self: the object itself
            %       inpConfName: char[1,] configuration name, can be '*'
            %          which means "all configurations"
            %
            %   properties:
            %       overwrite: logical[1,1] - if true, the template(s)
            %          is(are) copied over the plain configurations if the
            %          latter exist(s)
            %               (false by default)
            %       forceUpdate: logical[1,1] - if true, the configuration
            %          is updated even if it is already exists for the
            %          local computer,
            %               (false by default)
            %
            %
            import modgen.common.parseparext;
            import modgen.common.throwerror;
            [~,~,isOverwrite,isUpdateForced]=parseparext(varargin,...
                {'overwrite','forceUpdate';false,false;...
                'islogscalar(x)','islogscalar(x)'},0);
            %
            if strcmp(inpConfName,'*')
                confNameList=self.templateRepoMgr.getConfNameList();
            else
                confNameList={inpConfName};
            end
            nConf=length(confNameList);
            for iConf=1:nConf
                confName=confNameList{iConf};
                try
                    if isOverwrite||~self.isConf(confName)
                        [SConf,confVersion,metaData]=...
                            self.templateRepoMgr.getConfInternal(...
                            confName);
                        [SConf,confVersion,metaData]=...
                            self.updateConfStructInternal(SConf,...
                            confVersion,metaData);
                        self.putConfInternal(confName,SConf,confVersion,...
                            metaData);
                    elseif isUpdateForced
                        [SConf,confVersion,metaData]=...
                            self.getConfInternal(confName);
                        lastVersion=self.getLastConfVersion();
                        if (confVersion<lastVersion)||isnan(confVersion)
                            [SConf,confVersion,metaData]=...
                                self.updateConfStructInternal(SConf,...
                                confVersion,metaData);
                            self.putConfInternal(confName,SConf,...
                                confVersion,metaData);
                        end
                    end
                catch meObj
                    newMeObj=throwerror('wrongInput',...
                        'deployment of configuration %s has failed',...
                        confName);
                    newMeObj=addCause(newMeObj,meObj);
                    throw(newMeObj);
                end
            end
        end
    end
    methods (Hidden)
        function repoObj=getTemplateRepo(self)
            repoObj=self.templateRepoMgr;
        end
    end
end