classdef ConfRepoManager<modgen.configuration.ConfRepoManagerAnyStorage&...
        modgen.reflection.ReflectionHelper
    properties (Constant)
        DEFAULT_STORAGE_BRANCH_KEY='_default';
    end
    methods
        function self=ConfRepoManager(varargin)
            % CONFREPOMANAGER is the class constructor with the following
            % parameters
            %
            % Input:
            %   properties:
            %       repoLocation: char[1,] - configuration repository location
            %
            %       storageBranchKey: char[1,] - repository branch
            %          location, ='_default' by default. A single
            %          repository can have multiple branches which increase
            %          the class flexibility greatly
            %
            %       confPatchRepo: modgen.struct.changetracking.AStructChangeTracker[1,1] -
            %          configuration version tracker
            %
            %       repoSubfolderName: char[1,] - if not specified
            %           'confrepo' name is used, otherwise, when specified
            %           along with repoLocation, it should be the same as the
            %           deepest subfolder in repoLocation. Finally, when
            %           repoSubfolderName is specified and repoLocation is not
            %           the location is chosen automatically with the deepest subfolder
            %           name equal to repoSubfolderName
            %
            % Output:
            %   self: the constructed object
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-08-05 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            %
            import modgen.common.throwerror;
            import modgen.common.parseparext;
            import modgen.configuration.ConfRepoManager;
            %
            %% parse input params
            [reg,~,...
                storageBranchKey,repoLocation,confPatchRepo,...
                repoSubfolderName,...
                isStorageBranchKeySpec,isRepoLocationSpec,...
                isConfPathRepoSpec,isRepoSubfolderSpecified]=...
                modgen.common.parseparext(varargin,...
                {'storagebranchkey','repolocation','confpatchrepo',...
                'reposubfoldername';...
                'ConfRepoManager.DEFAULT_STORAGE_BRANCH_KEY',[],...
                [],'confrepo';...
                'ischarstring(x)','ischarstring(x)',...
                @(x)isa(x,'modgen.struct.changetracking.StructChangeTracker'),...
                'ischarstring(x)'});
            %
            if ~isStorageBranchKeySpec
                storageBranchKey=...
                    modgen.configuration.ConfRepoManager.DEFAULT_STORAGE_BRANCH_KEY;
            end
            %
            addArgList=reg;
            if isConfPathRepoSpec
                addArgList=[{confPatchRepo},reg];
            end
            %
            metaClassBoxedObj=modgen.containers.ValueBox();
            self=self@modgen.reflection.ReflectionHelper(metaClassBoxedObj);
            metaClass=metaClassBoxedObj.getValue();
            if ~isRepoLocationSpec
                repoLocation=[fileparts(which(metaClass.Name)),filesep,...
                    repoSubfolderName];
            elseif isRepoSubfolderSpecified
                [~,subFolderName]=fileparts(repoLocation);
                if ~strcmp(subFolderName,repoSubfolderName)
                    throwerror('wrongInput',...
                        ['repoSubfolderName is not the same as the ',...
                        'subfolder specified as part of repoLocation']);
                end
            end
            %
            %%
            storage=modgen.containers.ondisk.HashMapXMLMetaData(...
                'storageLocationRoot',repoLocation,...
                'storageBranchKey',storageBranchKey,...
                'storageFormat','verxml',...
                'useHashedPath',false);
            self=self@modgen.configuration.ConfRepoManagerAnyStorage(storage,...
                addArgList{:});
            %
        end
        function resObj=createInstance(self,varargin)
            % CREATEINSTANCE - returns an object of the same class by
            %                  calling a default constructor (with no
            %                  arameters)
            %
            %
            % Usage: resObj=getInstance(self)
            %
            % input:
            %   regular:
            %     self: any [] - current object
            %   optional
            %     any parameters applicable for relation constructor
            %
            %
            p=metaclass(self);
            resObj=feval(p.Name,varargin{:});
        end
    end
end