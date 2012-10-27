classdef ConfRepoMgrInMemory<modgen.configuration.ConfRepoManagerAnyStorage
    methods
        function self=ConfRepoMgrInMemory(varargin)
            % CONFREPOMGRINMEMORY is the class constructor with the following
            % parameters
            %   
            % Input:
            %
            % Output:
            %   self: the constructed object
            % 
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-05-17 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2012 $
            %
            %
            import modgen.*;
            %
            %%
            storage=containers.ondisk.HashMapXMLMetaData(...
                'storageFormat','none');
            self=self@modgen.configuration.ConfRepoManagerAnyStorage(storage);
            %
        end
        function copyConfFile(self,destFolderName,varargin)
            % COPYCONFFILE copies a configuration file to a specified file
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
            if isDestFile
                [destPathStr,destConfName,destExt]=fileparts(destFolderName);
                modgen.common.type.simple.checkgen(destExt,'strcmp(x,''.xml'')');
            else
                destPathStr=destFolderName;
                destConfName=confName;
            end
            storage=modgen.containers.ondisk.HashMapXMLMetaData(...
                'storageFormat','verxml',...
                'storageLocationRoot',destPathStr,...
                'skipStorageBranchKey',true,...
                'checkStorageContent',false);
            storage.put(destConfName,self.getConfInternal(confName));
       end            
       function selectConf(self,confName,varargin)
            % SELECTCONF selects the configuration specified by name
            % Only one configuration can be selected at any time. A selected 
            % configuration is used for parameters reading/storing.
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
            [reg,~]=modgen.common.parseparams(varargin,{'reloadIfSelected'});
            selectConf@modgen.configuration.ConfRepoManagerAnyStorage(...
                self,confName,...
                'reloadifSelected',false,reg{:});
       end
        function resVal=getParam(self,paramName,varargin)
            % GETPARAM extracts a value for a parameter specified by name
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
            [reg,~]=modgen.common.parseparams(varargin,{'skipCache'});
            resVal=getParam@modgen.configuration.ConfRepoManagerAnyStorage(...
                self,paramName,reg{:},'skipCache',false);
        end
        function flushCache(self)
        end        
    end
    methods(Access=protected)
        function confNameList=getConfNameListInternal(self)
            % GETCONFNAMELISTINTERNAL is an internal implementation of
            % getConfNameList
            %
            confNameList=self.getCachedConfNames();
        end        
    end
end