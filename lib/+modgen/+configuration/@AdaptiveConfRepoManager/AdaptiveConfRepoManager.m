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
    properties (Access=protected)
        templateStorageBranchKey='_templates';
    end
    properties (Access=private)
        templateRepoMgr
    end
    %
    methods 
        function setConfPatchRepo(self,confPatchRepo)
            % SET
            setConfPatchRepo@modgen.configuration.ConfRepoManager(self,confPatchRepo);
            self.templateRepoMgr.setConfPatchRepo(confPatchRepo);
        end
        function self=AdaptiveConfRepoManager(varargin)
            %
            import modgen.*;
            %
            %% parse input params
            [~,prop]=modgen.common.parseparams(varargin,[],0);
            nProp=length(prop);
            %
            isRepoSubfolderSpecified=false;
            isRepoLocationSpecified=false;
            %% continue parsing
            for k=1:2:nProp-1
                switch lower(prop{k})
                    case 'templatestoragebranchkey',
                        templateStorageBranchKey=prop{k+1};
                        varargin([k,k+1])=[];
                    case 'storagebranchkey',
                        error([upper(mfilename),':wrongProperty'],...
                            'property %s is not supported',prop{k});
                    case 'repolocation',
                        repoLocation=prop{k+1};
                        isRepoLocationSpecified=true;
                    case 'reposubfoldername',
                        isRepoSubfolderSpecified=true;
                        repoSubfolderName=prop{k+1};
                    case 'confpatchrepo',
                        confPatchRepo=prop{k+1};
                end;
            end;
            [~,hostName]=getuserhost();
            %ignoring user name for now
            %
			currentStorageBranchKey=hostName;
            %
            %%
            self=self@modgen.configuration.ConfRepoManager(...
                'storageBranchKey',currentStorageBranchKey,varargin{:});
            if system.ExistanceChecker.isVar('templateStorageBranchKey')
                self.templateStorageBranchKey=templateStorageBranchKey;
            end
            %
            inpArgList=varargin;
            %
            if ~isRepoLocationSpecified
                metaClass=metaclass(self);
                if ~isRepoSubfolderSpecified
                    repoSubfolderName='confrepo';
                end
                repoLocation=[fileparts(which(metaClass.Name)),filesep,...
                    repoSubfolderName];
                inpArgList=[inpArgList,{'repoLocation',repoLocation}];
                %
            elseif isRepoSubfolderSpecified
                %
                [~,subFolderName]=fileparts(repoLocation);
                %
                if ~strcmp(subFolderName,repoSubfolderName)
                    error([upper(mfilename),':wrongInput'],...
                        ['repoSubfolderName is not the same as the ',...
                        'subfolder specified as part of repoLocation']);
                end
            end
            %
            self.templateRepoMgr=configuration.ConfRepoManager(...
                'storageBranchKey',self.templateStorageBranchKey,inpArgList{:});
            %
            if system.ExistanceChecker.isVar('confPatchRepo')
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
        function updateAll(self)
            % UPDATEALL - updates both templates and plain configurations
            %
            %
            confNameList=self.templateRepoMgr.getConfNameList;
            cellfun(@(x)updateConf(self.templateRepoMgr,x),confNameList);
            %
            confNameList=self.getConfNameList;
            cellfun(@(x)updateConf(self,x),confNameList);
            %
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
            [reg,prop]=parseparams(varargin);
            nProp=length(prop);
            if ~isempty(reg)
                error([mfilename,':incorrectInput'],'badly formed property list');
            end
            %
            isOverwrite=false;
            isUpdateForced=false;
            %% continue parsing
            for k=1:2:nProp-1
                switch lower(prop{k})
                    case 'overwrite',
                        isOverwrite=prop{k+1};
                    case 'forceupdate',
                        isUpdateForced=prop{k+1};
                end
            end
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
                        [SConf,confVersion,metaData]=self.templateRepoMgr.getConfInternal(confName);
                        [SConf,confVersion,metaData]=self.updateConfStructInternal(SConf,confVersion,metaData);
                        self.putConfInternal(confName,SConf,confVersion,metaData);
                    elseif isUpdateForced
                        [SConf,confVersion,metaData]=self.getConfInternal(confName);
                        lastVersion=self.getLastConfVersion();
                        if (confVersion<lastVersion)||isnan(confVersion)
                            [SConf,confVersion,metaData]=self.updateConfStructInternal(SConf,confVersion,metaData);
                            self.putConfInternal(confName,SConf,confVersion,metaData);
                        end
                    end
                catch meObj
                    newMeObj=MException([upper(mfilename),':wrongInput'],...
                        'deployment of configuration %s has failed',confName);
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