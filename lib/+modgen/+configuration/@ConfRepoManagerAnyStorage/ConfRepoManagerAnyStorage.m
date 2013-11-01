classdef ConfRepoManagerAnyStorage<handle
    % CONFREPOMANAGER provides a functionality for storing, reading,
    % copying and very simplistic version tracking of application
    % configurations represented by structures
    %
    %
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-10-24 $ 
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %
    %
    properties (Access=private)
        storage
        cache
        curConfName='';
        confPatchRepo
        getStorageHook
        putStorageHook
    end
    %
    methods (Access=private)
        function [SConfData,metaData]=getConfFromStorage(self,confName)
            [SConfData,metaData]=self.storage.get(confName);
            SConfData=...
                modgen.struct.updateleaves(SConfData,self.getStorageHook);
        end
        %
        function putConfToStorage(self,confName,SConfData,metaData)
            SConfData=...
                modgen.struct.updateleaves(SConfData,...
                self.putStorageHook);
            self.storage.put(confName,SConfData,metaData);
        end
    end
    %
    methods (Access=protected,Static)
        function confVersion=getConfVersionFromMetaData(metaData)
            if ~isfield(metaData,'version')
                confVersion=-Inf;
            else
                confVersion=str2double(metaData.version);
            end            
        end
        function metaData=putConfVersionToMetaData(metaData,confVersion)
            confVersion=num2str(confVersion);
            metaData.version=confVersion;
        end
    end    
    methods
        function isPos=isConfSelected(self,confName)
            %ISCONFSELECTED - checks if the specified configuration
            %                 selected
            isPos=self.isCachedConf(confName);
        end
        function storeCachedConf(self,confName)
            [SConfData,metaData]=getCachedConf(self,confName);
            self.putConfToStorage(confName,SConfData,metaData)
        end
        function flushCache(self)
            %FLUSHCACHE - flushes all the cached information
            self.initCache();
        end
        function lastRevision=getLastConfVersion(self)
            lastRevision=self.confPatchRepo.getLastRevision();
        end
        function self=ConfRepoManagerAnyStorage(storage,varargin)
            % CONFREPOMANAGER is the class constructor with the following
            % parameters
            %   
            % Input:
            %   regular:
            %       storage: modgen.containers.ondisk.AHashMap[1,1] -
            %          object reposible for maintaining a configuration
            %          storage
            %
            %   optional:
            %       patchRepoObj:
            %           modgen.struct.changetracking.AStructChangeTracker[1,1]
            %           object mantaining configuration patches
            %
            %   properties:
            %       putStorageHook: function_handle[1,1] - function that is
            %           applied to each leave of a structure before it is
            %           transferred into the storage. The function is
            %           expected to have the following format:
            %               resVal=putStorageHook(inpVal,subFieldNameList)
            %                   where subFieldNameList defines a path in
            %                   the structure to which inpVal is referred
            %                   to
            %               Example:
            %                   in structure
            %                   
            %                       S.alpha.beta=2;
            %                       S.alpha2=3;
            %                   with hook defined as 
            %                       putStorageHook=@(x,y)x+1;
            %           
            %                   the hook is called twice:
            %                   
            %                   resVal=putStorageHook(2,{'alpha','beta'})
            %                   resVal=putStorageHook(3,{'alpha2')
            %                   
            %                   and produces the following structure
            %                   
            %                   S.alpha.beta=3;
            %                   S.alpha2=4;
            %                   
            %               
            %       getStorageHook: function_handle[1,1] - function that is
            %           called upon loading of the structure from the 
            %           storage, the function format is the same as for
            %           putStorageHook.
            %           
            %           In example above if 
            %               putStorageHook=@(x,y)x+1;
            %               getStorageHook=@(x,y)x-1
            %           then the structures would be saved in a changed
            %           form but upon loading they would be reverted to
            %           their original stage
            %                           
            %
            % Output:
            %   self: the constructed object
            % 
            %
            import modgen.*;
            import modgen.common.parseparext;
   
            self.initCache();
            %
            [reg,isRegSpec,self.putStorageHook,...
                self.getStorageHook]=parseparext(...
                varargin,{...
                'putStorageHook','getStorageHook';...
                @(x,y)x,@(x,y)x;...
                @(x)isa(x,'function_handle'),@(x)isa(x,'function_handle')},...
                'regCheckList',...
                {@(x)isa(x,'modgen.struct.changetracking.AStructChangeTracker')});
            
            if isRegSpec
                self.confPatchRepo=reg{1};
            else
                self.confPatchRepo=...
                    struct.changetracking.StructChangeTrackerEmptyPlug();
            end
            %
            self.storage=storage;
            %
        end
        %
        function editConf(self,confName)
            % EDITCONF - opens the default system editor for the
            %            configuration specified by name
            % 
            % Input:
            %   confName: char[1,] - configuration name
            % 
            %
            fileName=self.storage.getFileNameByKey(confName);
            edit(fileName);
        end
        %
        function selectConf(self,confName,varargin)
            % SELECTCONF - selects the configuration specified by name
            %              Only one configuration can be selected at any 
            %              time. A selected configuration is used for 
            %              parameters reading/storing.
            %
            % Input:
            %   regular:
            %       self: the object itself
            %       confName: char[1,] - configuration name
            %
            %   properties:
            %       reloadIfSelected: logical[1,1] - if false,
            %           configuration is loaded from disk only if it wasn't
            %           selected previously, true by default
            %   
            %
            [~,prop]=modgen.common.parseparams(varargin,{'reloadIfSelected'},0);
            if ~isempty(prop)
                isReloadedIfSelected=prop{2};
                if ~(islogical(isReloadedIfSelected)&&numel(isReloadedIfSelected)==1)
                    error([upper(mfilename),':wrongInput'],...
                        'reloadedIfSelected is expected to be a logical scalar');
                end
            else
                isReloadedIfSelected=true;
            end
            %
            if isReloadedIfSelected||~(isReloadedIfSelected||self.isCachedConf(confName))
                if ~self.storage.isKey(confName)
                    error([upper(mfilename),':unknownConfig'],...
                        'configuration %s does not exist in the repository',...
                        confName);
                end
                %
                [SConf,metaData]=self.getConfFromStorage(confName);
                self.cacheConf(confName,SConf,metaData);
            else
                self.curConfName=confName;
            end
        end
        %
        function isPositive=isParam(self,paramName)
            % ISPARAM - checks if the specified parameter name corresponds 
            %           to the existing parameter for the currently 
            %           selected configuration
            % 
            % Input:
            %   regular:
            %       self: the object itself
            %       paramName: char[1,] - parameter name to check
            %
            %
            if paramName(1)~='.'
                paramName=['.',paramName];
            end
            isPositive=structcheckpath(self.getCurConf(),paramName);
        end
        %    
        function resVal=getParam(self,paramName,varargin)
            % GETPARAM - extracts a value for a parameter specified by name
            %
            % Input:
            %   regular:
            %       self: the object itself
            %       paramName: char[1,] - parameter name
            %       
            %   properties:
            %       skipCache: logical[1,1] - if true, the parameter is
            %          extracted from the disk directly without checking
            %          the cache
            %
            %
            isCacheSkipped=false;
            [~,prop]=parseparams(varargin);     
            nProp=length(prop);
            for k=1:2:nProp-1
                switch lower(prop{k})
                    case 'skipcache'
                        isCacheSkipped=prop{k+1};
                end
            end
            if isCacheSkipped
                self.reCacheCurConf();
            end
            try
                resVal=structgetpath(self.getCurConf(),paramName);
            catch meObj
                newMeObj=MException([upper(mfilename),':invalidParam'],...
                    'the requested parameter does not exist');
                newMeObj=newMeObj.addCause(meObj);
                throw(newMeObj);
            end
        end
        %
        function setParam(self,paramName,paramValue,varargin)
            % SETPARAM - assigns the specified value to a parameter 
            %            specified by its name
            % 
            %
            % Input:
            %   regular:
            %       self: the object itself
            %       paramName: char[1,] - parameter name
            %       paramValue: any[ ] - parameter value
            %
            %   properties:
            %       writeDepth: char[1,] - can have the following values:
            %           'disk'  - the specified  value is written 
            %               to both disk and cache, 
            %           'cache' - value is written to cache only, no write
            %               on disk is performed
            % 
            %
            [~,prop]=modgen.common.parseparams(varargin,{'writedepth'},0);
            isWriteToDisk=true;
            if ~isempty(prop)
                isWriteToDisk=strcmpi(prop{2},'disk');
            end
            %
            if paramName(1)~='.'
                paramName=['.',paramName];
            end
            %
            curConfName=self.getCurConfName();
            [curConf,metaData]=self.getCurConf();
            SConf=structapplypath(curConf,paramName,paramValue);
            self.cacheConf(curConfName,SConf,metaData);
            if isWriteToDisk
                self.putConfToStorage(curConfName,SConf,metaData);
            end
        end
        %
        function putConf(self,confName,SConf,varargin)
           % PUTCONF - puts the configuration structure into the storage
           %
           % Input:
           %    regular:
           %        self: the object itself
           %        confName: char[1,] configuration name
           %        SConf: struct[1,1] - configuration structure
           %    
           %    optional:
           %        confVersion: numeric[1,1] - configuration version 
           %            number
           %        metaData: struct[1,1] - meta data to store along with
           %            the configuration structure
           %
           %
           self.putConfInternal(confName,SConf,varargin{:}); 
        end
        %
        function [SConf,confVersion,metaData]=getConf(self,confName)
           % GETCONF - extracts the configuration structure and its meta  
           %           data by name, the returned configuration is 
           %           automatically updated up to the latest version
           % 
           %
           % Input:
           %    regular: 
           %        self: the object itself
           %        confName: char[1,] - configuration name
           %
           % Output:
           %    SConf: struct[1,1] - configuration structure
           %    confVersion: double[1,1] - configuration version
           %    metaData: struct[1,1] - configuration meta-data
           %
           %
           [SConf,confVersion,metaData]=self.getConfInternal(confName);
        end
        %
        function copyConf(self,fromConfName,toConfName)
            % COPYCONF - copies a configuration to another configuration
            % 
            %
            % Input:
            %   regular:
            %       self: the object itself
            %       fromConfName: char[1,] - source configuration name
            %       toConfName: char[1,] - target configuration name
            %   
            %
            [SConf,metaData]=self.getConfInternal(fromConfName);
            self.putConf(toConfName,SConf,metaData);
        end
        %
        function copyConfFile(self,destFolderName,varargin)
            % COPYCONFFILE - copies a configuration file to a specified
            %                file
            % 
            % Input:
            %   regular:
            %       destFolderName/destFileName: char[1,] - destination 
            %           folder/file name            
            %   optional:
            %       confName: char[1,] - configuration name
            %   properties:
            %       destIsFile: logical[1,1] - if true, destFolderName is
            %           interpreted as a file name and as a folder name
            %           otherwise, false by default
            %       
            %
            [reg,~,isDestFile]=modgen.common.parseparext(varargin,...
                {'destIsFile';false;'isscalar(x)&&islogical(x)'},...
                'regCheckList',{'isstring(x)'},...
                'regDefList',{self.getCurConfName()});
            confName=reg{1};
                
            fullFileName=self.storage.getFileNameByKey(confName);
            %make sure that "/" at the end of folder path doesn't matter
            if isDestFile
                destFileName=destFolderName;
            else
                [~,fileName,ext]=fileparts(fullFileName);                
                if strcmp(destFolderName(end),filesep)
                    destFolderName=destFolderName(1:end-1);
                end
                if ~modgen.system.ExistanceChecker.isDir(destFolderName)
                    mkdir(destFolderName);
                end
                destFileName=[destFolderName,filesep,fileName,ext];
            end
            copyfile(fullFileName,destFileName);
        end        
        %
        function removeAll(self)
            % REMOVEALL - removes all the configurations from the storage
            % 
            % Input:
            %   regular:
            %       self: the object itself
            %
            self.initCache();
            self.storage.removeAll();
        end
        function confNameList=getConfNameList(self)
            % GETCONFNAMELIST - returns a name list of all configurations
            %                   residing in the storage
            %
            % Input:
            %   regular:
            %       self: the object itself
            % 
            % Output:
            %   confNameList: cell[1,] - configuration name list
            % 
            %
            confNameList=self.getConfNameListInternal();
        end
        function confName=getCurConfName(self)
            % GETCURCONFNAME - returns a name of currently selected
            %                  configuration
            % 
            % Input:
            %   regular:
            %       self: the object itself
            %   
            % Output:
            %   confName: char[1,] - name of the currently selected
            %      configuration
            %
            %
            if isempty(self.curConfName)
                error([upper(mfilename),':wrongActionSequence'],...
                    'Current configuration is not selected');
            end
            %
            confName=self.curConfName;
        end        
        %
        function [SConf,metaData]=getCurConf(self)
            % GETCURCONF - returns the currently selected configuration
            % 
            % Input:
            %   regular:
            %       self: the object itself
            %
            % Output:
            %   SConf: struct[1,1] - configuration structure
            %   metaData: struct[1,1] - configuration meta-data
            %
            %
            curConfName=self.getCurConfName();
            [SConf,metaData]=self.getCachedConf(curConfName);
        end
        %
        function isPositive=isConf(self,confName)
            % ISCONF - checks if the specified name corresponds to existing
            %          configuration from the storage
            %
            % Input:
            %   regular:
            %       self: the object itself
            %       confName: char[1,] - configuration name
            %   
            % Output:
            %   isPositive: logical[1,1] - if true, a configuration with
            %      the given name exists in the storage
            % 
            %
            isPositive=self.storage.isKey(confName);
        end
        function removeConf(self,confName)
            % REMOVECONF - removes the specified configuartion from the
            %              storage by name
            %
            % Input:
            %   regular:
            %      self: the object itself
            %      confName: char[1,] - configuration name
            %
            %
            if self.cache.isKey(confName)
                self.cache.remove(confName);
            end
            %
            self.storage.remove(confName);
        end
        function setConfPatchRepo(self,confPatchRepo)
            % SETCONFPATCHREPO - sets the configuration version tracker
            % 
            % Input:
            %   regular:
            %       self: the object itself
            %       confPatchRepo:   
            %         modgen.struct.changetracking.AStructChangeTracker[1,1]
            %         configuration version tracker
            %
            %
            self.confPatchRepo=confPatchRepo;
        end
        function updateConf(self,confName)
            % UPDATECONF - updates the specified configuration up to the
            %              latest version
            %
            % Input: 
            %   regular:
            %       self: the object itself
            %       confName: char[1,] - configuration name
            %   
            %
            self.updateConfInternal(confName);
        end
        function updateAll(self)
            % UPDATEALL - updates all the configurations in the repository
            %             up to the latest version
            %
            % Input:
            %   regular:
            %       self: the object itself
            %   
            %
            self.updateAllInternal();
        end
    end
    methods (Access=protected)
        function confNameList=getCachedConfNames(self)
            confNameList=self.cache.keys();
        end
        function updateAllInternal(self)
            confNameList=self.getConfNameListInternal();
            nConfs=length(confNameList);
            for iConf=1:nConfs
                confName=confNameList{iConf};
                self.updateConfInternal(confName);
            end
        end        function confNameList=getConfNameListInternal(self)
            % GETCONFNAMELISTINTERNAL - an internal implementation of
            %                           getConfNameList
            %
            try
                confNameList=self.storage.getKeyList();
            catch meObj
                if ~isempty(strfind(meObj.identifier,':badKeyValuePair'))
                    newMeObj=MException([upper(mfilename),':badConfRepo'],...
                        ['configuration repository contains the ',...
                        'inconsistent configurations']);
                    newMeObj=addCause(newMeObj,meObj);
                    throw(newMeObj);
                else
                    rethrow(meObj);
                end
            end
        end
        function updateConfInternal(self,confName)
            % UPDATECONFINTERNAL - an internal implementation of
            %                      updateConf
            %
            [SConf,oldConfVersion,metaData]=self.getConfInternal(confName);
            [SConf,confVersion,metaData]=self.updateConfStructInternal(...
                SConf,oldConfVersion,metaData);
            if (confVersion>oldConfVersion)||isnan(oldConfVersion)
                self.putConfInternal(confName,SConf,confVersion,metaData);
            end
        end
        function [SConf,confVersion,metaData]=updateConfStructInternal(self,SConf,confVersion,metaData)
            % UPDATESCONFSTRUCTINTERNAL - updates configuration structure
            %                             up to the latest version
            %
            [SConf,confVersion]=self.confPatchRepo.applyAllLaterPatches(SConf,confVersion);
            metaData=self.putConfVersionToMetaData(metaData,confVersion);
            
        end

        function [SConf,confVersion,metaData]=getConfInternal(self,confName)
            % GETCONFINTERNAL - an internal imlpementation of getConf that
            %                   is used within the class to separate 
            %                   interface from its internal implementation
            % 
            % 
            if self.isCachedConf(confName)
                [SConf,metaData]=self.getCachedConf(confName);
            else
                try
                    [SConf,metaData]=self.getConfFromStorage(confName);
                catch meObj
                    if ~isempty(strfind(meObj.identifier,':noRecord'))
                        newMeObj=MException([upper(mfilename),':noConfiguration'],...
                            'configuration %s does not exist',confName);
                        newMeObj=addCause(newMeObj,meObj);
                        throw(newMeObj);
                    else
                        rethrow(meObj);
                    end
                end
            end
            confVersion=self.getConfVersionFromMetaData(metaData);
        end
        function putConfInternal(self,confName,SConf,confVersion,metaData)
            % PUTCONFINTERNAL - an internal implementation of putConf
            %
            if nargin<5
                metaData=struct();
            end
            %
            if nargin<4
                confVersion=self.confPatchRepo.getLastRevision();
            end
            %    
            metaData=self.putConfVersionToMetaData(metaData,confVersion);
            %
            self.cacheConf(confName,SConf,metaData);
            self.putConfToStorage(confName,SConf,metaData); 
        end          
    end
    methods (Access=private)
        function cacheConf(self,confName,SConf,metaData)
            % CACHECONF - chaches the specified configuration and makes it
            %             current
            %
            self.cache(confName)={SConf,metaData};
            self.curConfName=confName;
        end
        function [SConf,metaData]=getCachedConf(self,confName)
            % GETCACHEDCONF - returns a cached configuration by its name; 
            %                 exception is thrown if the requested 
            %                 configuration is not found
            % 
            %
            isCached=self.isCachedConf(confName);
            if isCached
                res=self.cache(confName);
                SConf=res{1};
                metaData=res{2};
            else
                error([upper(mfilename),':noKey'],...
                    'configuration %s is not cached',confName);
            end
        end
        function isPositive=isCachedConf(self,confName)
            % ISCACHEDCONF checks if the configuration with a given name is
            % cached
            %
            isPositive=self.cache.isKey(confName);
        end
        function reCacheCurConf(self)
            % RECACHECURCONF rehaches the current configuration
            %
            curConfName=self.getCurConfName();
            [conf,metaData]=self.getConfFromStorage(curConfName);
            self.cacheConf(curConfName,conf,metaData);
        end        
        function initCache(self)
            % INITCACHE initializes the cache
            %
            self.cache=containers.Map;
        end
    end
end