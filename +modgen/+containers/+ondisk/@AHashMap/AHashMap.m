classdef AHashMap<modgen.containers.ondisk.IOnDiskBranchedStorage
    %DISKBASEDHASHMAP represents a hash map for the arbitrary objects on disk
    % with a high level of persistency when the object state can be
    % restored based only on a storage location
    
    properties (Constant,Abstract,GetAccess=protected)
        IGNORE_EXTENSIONS
        ALLOWED_EXTENSIONS
        
    end
    properties (Access=protected,Hidden)
        storageLocation
        storageLocationRoot
        isPutErrorIgnored=false
        isBrokenStoredValuesIgnored=false
        fileExtension
        isHashedPath=true
        isHashedKeys=false
        saveFunc=@(x,y,z)1
        loadKeyFunc=@(x)1
        loadValueFunc=@(x)1
        storageFormat='none'
        isMissingKeyBlamed=false
        isStorageContentChecked=true;
        storageBranchKey
    end
    methods
        function isHashedPath=getIsHashedPath(self)
            isHashedPath=self.isHashedPath;
        end
        function isHashedKeys=getIsHashedKeys(self)
            isHashedKeys=self.isHashedKeys;
        end
        function self=AHashMap(varargin)
            % ADISKBASEDHASHMAP
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-05-23 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2012 $
            %
            %
            import modgen.common.parseparext;
            import modgen.containers.DiskBasedHashMap;
            import modgen.system.ExistanceChecker;
            %
            [~,~,isStorageBranchKeySkipped,storageLocationRoot,...
                storageBranchKey,self.isPutErrorIgnored,...
                self.isBrokenStoredValuesIgnored,self.storageFormat,...
                self.isHashedPath,self.isHashedKeys,...
                self.isStorageContentChecked,...
                ~,isStorageLocSpec,isStorageBranchKeySpec]=...
                modgen.common.parseparext(varargin,...
                {'skipStorageBranchKey','storageLocationRoot',...
                'storagebranchkey','ignoreputerrors',...
                'ignorebrokenstoredvalues','storageformat',...
                'usehashedpath','usehashedkeys',...
                'checkstoragecontent';...
                false,char(1,0),'default',self.isPutErrorIgnored,...
                self.isBrokenStoredValuesIgnored,self.storageFormat,...
                self.isHashedPath,self.isHashedKeys,...
                self.isStorageContentChecked;...
                'islogscalar(x)','isstring(x)',...
                'isstring(x)','islogscalar(x)',...
                'islogscalar(x)','isstring(x)',...
                'islogscalar(x)','islogscalar(x)',...
                'islogscalar(x)'},[0 1]);
            %
            if ~isStorageBranchKeySpec
                storageBranchKey='default';
            end
            %
            if self.isHashedPath
                storageBranchKey=hash(storageBranchKey);
            end
            %
            if ~isStorageLocSpec
                metaClass=metaclass(self);
                storageLocationRoot=fileparts(which(metaClass.Name));
            end
            %
            %
            if isStorageBranchKeySkipped
                self.storageLocation=storageLocationRoot;
                storageBranchKey='';
            else
                self.storageLocation=[storageLocationRoot,filesep,...
                    storageBranchKey];
            end
            %
            self.storageLocationRoot=storageLocationRoot;
            %
            self.storageBranchKey=storageBranchKey;
            %
            if ~strcmpi(self.storageFormat,'none')
                if ~ExistanceChecker.isDir(self.storageLocation)
                    %check that a directory if exists, containts only mat files
                    modgen.io.mkdir(self.storageLocation);
                else
                    self.checkStorageDir(self.storageLocation);
                end
            end
            %
        end
        %
        function fullFileName=getFileNameByKey(self,keyStr,varargin)
            % GETFILENAMEBYKEY returns a full file name by key
            %
            % Usage: self.getFileNameByKey(keyList)
            %
            % Input:
            %   regular:
            %       keyStr: char[1,] - key
            %   properties:
            %       checkForPresence: logical[1,1] - if true (default), the
            %           presence of the specified key is checked. If the
            %           key is not present an exception is thrown
            %
            % Output:
            %   fullFileName: char[1,] - full file name
            %       corresponding to a specified key
            %
            %
            import modgen.common.throwerror;
            import modgen.common.parseparext;
            [~,~,isPresenceChecked]=parseparext(varargin,...
                {'checkForPresence';true;'islogical(x)&&isscalar(x)'},0);
            fullFileName=self.genfullfilename(keyStr);
            if isPresenceChecked&&...
                    (~self.isKey(keyStr)&&self.isMissingKeyBlamed)
                throwerror('noRecord',...
                    ['The specified key %s is not present ',...
                    'in this container, dirName: %s'],keyStr,...
                    fileparts(fullFileName));
            end
        end
        %
        function [isKeyVec,fullFileNameCVec]=isKey(self,keyList)
            % ISKEY checks if the specified keys are registered
            %
            % Usage: self.isKey(keyList)
            %
            % Input:
            %   regular:
            %       keyList: cell[1,nKeys] - cell array of character key
            %          values
            %
            % Output:
            %   regular:
            %       isKeyVec: logical[1,nKeys] - 'is key' indicator array
            %       fullFileNameCVec: cell[1,nKeys] - a list of full file
            %          names where the values for each key are stored
            %
            %
            import modgen.system.ExistanceChecker;
            if isa(keyList,'char')
                keyList={keyList};
            end
            fullFileNameCVec=cellfun(@self.genfullfilename,keyList,'UniformOutput',false);
            isKeyVec=false(1,length(fullFileNameCVec));
            nKeys=length(isKeyVec);
            for iKey=1:nKeys
                try
                    isKeyVec(iKey)=self.checkKey(fullFileNameCVec{iKey});
                catch meObj
                    if self.isBrokenStoredValuesIgnored
                        warning([upper(mfilename),':brokenKeyValue'],...
                            'a value stored for a specified is broken: %s',...
                            meObj.message);
                    else
                        rethrow(meObj);
                    end
                end
            end
            
        end
        %
        function branchKey=getStorageBranchKey(self)
            % GETSTORAGEBRANCHKEY
            % Input:
            %   regular:
            %       self:
            % Output:
            %   branchKey: char[1,] - current branch key
            %
            branchKey=self.storageBranchKey;
        end
        %
        function storageLocationRoot=getStorageLocationRoot(self)
            % GETSTORAGELOCATION returns a storage location root
            %  for the object in question
            %
            % Usage: self.getStorageLocation()
            %
            % Input:
            %   regular:
            %       self: DiskBasedHashMap[1,1] - the object itself
            % Output:
            %   regular:
            %       storageLocationRoot: char[1,nChars] - storage location
            %           directory on a disk (includes a branch key)
            %
            
            storageLocationRoot=self.storageLocationRoot;
        end        
        %
        function storageLocation=getStorageLocation(self)
            % GETSTORAGELOCATION returns a storage location for the object
            % in question
            %
            % Usage: self.getStorageLocation()
            %
            % Input:
            %   regular:
            %       self: DiskBasedHashMap[1,1] - the object itself
            % Output:
            %   regular:
            %       storageLocation: char[1,nChars] - storage location
            %           directory on a disk (includes a branch key)
            %
            
            storageLocation=self.storageLocation;
        end
        function put(self,keyList,valueObjList,varargin)
            % PUT inserts a set of values into the map
            %
            % Usage: self.put(keyList,valueObjList)
            %
            % Input:
            %   regular:
            %       self: DiskBasedHashMap[1,1] - the object itself
            %       keyList: cell[1,nKeys] - cell array of character key
            %          values
            %       valueObjList: any[1,nKeys] - cell array of objects of
            %          any type
            %
            % Output:
            %   
            %
            
            if ~iscell(valueObjList)
                valueObjList={valueObjList};
            end
            if ~iscell(keyList)
                keyList={keyList};
            end
            %
            isnCellVec=~cellfun(@iscell,varargin);
            varargin(isnCellVec)=cellfun(@(x){x},varargin(isnCellVec),...
                'UniformOutput',false);
            %
            if ~auxchecksize(keyList,size(valueObjList))
                error([upper(mfilename),':wrongInput'],...
                    'keyList and valueObjList should be of the same size');
            end
            %
            cellfun(@self.putOne,keyList,valueObjList,varargin{:});
        end
        function [valueList,varargout]=get(self,keyList,varargin)
            % GET extracts a set of values from the map
            %
            % Usage: valueObjVec=self.get(keyList)
            %        [valueObjList,metaDataList]=self.get(keyList,'UniformOutput',false)
            %
            % Input:
            %   regular:
            %       self: DiskBasedHashMap[1,1] - the object itself
            %       keyList: cell[1,nKeys] - cell array of character key
            %          values
            %
            %   properties:
            %       uniformOutput: logical[1,1]
            %          true means that the
            %             result for multiple key values is returned in an array
            %              of objects. If the returned objects do not support
            %              concatenation in arrays, an exception is thrown.
            %          false enables place each of the objects in a
            %             separate cell
            %
            % Output:
            %   regular:
            %       valueObjList: any[1,nKeys] - cell array/array of objects of
            %          any type
            %   optional:
            %       arg1: any[1,nKeys] any additional output arguments returned
            %           by an overriden getOne method
            %           ...
            %       argN: any[1,nKeys] any additional output arguments
            %          returned by an overriden getOne method
            %
            %
            isUniformOutput=true;
            [~,prop]=parseparams(varargin);
            nProp=length(prop);
            for k=1:2:nProp-1
                switch lower(prop{k})
                    case 'uniformoutput'
                        isUniformOutput=prop{k+1};
                end
            end
            %
            if ~iscell(keyList)
                keyList={keyList};
            end
            %
            varargout=cell(1,nargout-1);
            %
            if isUniformOutput&&length(keyList)==1
                [valueList,varargout{:}]=self.getOne(keyList{1});
            else
                [valueList,varargout{:}]=cellfun(...
                    @self.getOne,keyList,...
                    'UniformOutput',isUniformOutput);
            end
        end
        function keyList=getKeyList(self)
            % GETKEYLIST returns a list of key values in the given map
            %
            % Usage: keyList=self.getKeyList()
            %
            % Input:
            %   regular:
            %       self: DiskBasedHashMap[1,1] - the object itself
            % Output:
            %   keyList: cell[1,nKeys] - cell array of character key
            %       values
            %
            %
            SFileProp=dir([self.storageLocation,filesep,['*.',self.fileExtension]]);
            isDirVec=[SFileProp.isdir];
            fileNameList={SFileProp(~isDirVec).name};
            fileNameList=cellfun(@(x)([self.storageLocation,filesep,x]),fileNameList,'UniformOutput',false);
            nFiles=length(fileNameList);
            keyList={};
            for iFile=1:nFiles
                curFileName=fileNameList{iFile};
                [~,keyStr]=self.checkKey(curFileName);
                keyList=[keyList,{keyStr}];
            end
        end
        function remove(self,keyList)
            % REMOVE removes the key-value pairs from the map for a
            % specified set of keys, method is silent if no such key exist
            %
            % Usage: valueObjList=self.remove(keyList)
            %
            % Input:
            %   regular:
            %       self: DiskBasedHashMap[1,1] - the object itself
            %       keyList: cell[1,nKeys] - cell array of character key
            %          values
            %
            %
            if ~iscell(keyList)
                keyList={keyList};
            end
            cellfun(@self.removeOne,keyList,'UniformOutput',false);
        end
        function removeAll(self)
            % REMOVEALL removes all key-value pairs from the map
            %
            % Usage: self.removeAll()
            %
            % Input:
            %   regular:
            %       self: DiskBasedHashMap[1,1] - the object itself
            %
            %
            storageLocation=self.getStorageLocation();
            delete([storageLocation,filesep,['*.',self.fileExtension]]);
        end
        %
    end
    methods (Access=protected)
        function [isPositive,keyStr]=checkKey(self,fileName)
            import modgen.system.ExistanceChecker;
            isPositive=ExistanceChecker.isFile(fileName);
            if isPositive
                warnState=warning('off','MATLAB:load:variableNotFound');
                try
                    S=self.loadKeyFunc(fileName);
                catch meObj
                    meObj=meObj.addCause(MException('AHashMap:unknownFailure',...
                        'failed to load file %s',fileName));
                    rethrow(meObj);
                end
                warning(warnState.state,'MATLAB:load:variableNotFound');
                isPositive=isfield(S,'keyStr');
                if isPositive
                    keyStr=S.keyStr;
                else
                    keyStr='';
                    warning([upper(mfilename),':incorrectKeyValueFile'],...
                        'key value file is invalid and will be updated');
                end
                supposedFileName=self.genfilename(keyStr);
                [~,actualFileName]=fileparts(fileName);
                if ~strcmp(supposedFileName,actualFileName)
                    error([upper(mfilename),':badKeyValuePair'],...
                        ['key %s assumes the key value file name to be %s ',...
                        'while the actual file name is %s'],...
                        keyStr,supposedFileName,actualFileName);
                end
            end
        end
        function removeOne(self,keyStr)
            fullFileName=self.genfullfilename(keyStr);
            import modgen.system.ExistanceChecker;
            if ExistanceChecker.isFile(fullFileName)
                delete(fullFileName);
            end
        end
        function fullFileName=genfullfilename(self,keyStr)
            import modgen.*;
            if ~modgen.common.isrow(keyStr)
                error([upper(mfilename),':wrongInput'],...
                    'keyStr is expected to be a row-string');
            end
            fullFileName=[self.storageLocation,filesep,...
                self.genfilename(keyStr),['.',self.fileExtension]];
        end
        function putOne(self,keyStr,valueObj)
            import modgen.system.ExistanceChecker;
            fullFileName=self.genfullfilename(keyStr);
            try
                self.saveFunc(fullFileName,'valueObj','keyStr');
            catch meObj
                if ExistanceChecker.isFile(fullFileName)
                    delete(fullFileName);
                end
                %
                if self.isPutErrorIgnored
                    warning([upper(mfilename),':saveFailure'],...
                        'cannot save the key value: %s',...
                        meObj.message);
                    return;
                else
                    rethrow(meObj);
                end
            end
        end
        %
        function valueObj=getOne(self,keyStr)
            import modgen.common.throwerror;
            [isKey,fullFileNameCVec]=self.isKey(keyStr);
            if ~isKey
                throwerror('noRecord',...
                    'The specified key is not present in this container');
            end
            valueObj=getfield(self.loadValueFunc(fullFileNameCVec{1}),...
                'valueObj');
        end
        function isPositive=isStorageDir(self,dirName)
            SFileList=dir(dirName);
            isDirVec=[SFileList.isdir];
            isIgnoredOrAllowedExtVec=self.isFileExt({SFileList.name},...
                [self.IGNORE_EXTENSIONS,self.ALLOWED_EXTENSIONS]);
            isPositive=all(isDirVec|isIgnoredOrAllowedExtVec|...
                ~self.isStorageContentChecked);
        end
        function checkStorageDir(self,dirName)
            import modgen.containers.DiskBasedHashMap;
            if ~self.isStorageDir(dirName)
                error([mfilename,':wrongLocation'],...
                    ['cannot create a storage at the specified location %s ',...
                    'as it contains some foreign files'],dirName);
            end
        end
    end
    methods (Access=protected,Static)
        function isPositiveVec=isFileExt(fileNameList,extList)
            regExpStr=strcat(extList,'|');
            regExpStr=[regExpStr{:}];
            regExpStr=['\.(',regExpStr(1:end-1),')$'];
            isPositiveVec=cellfun(@(x)~isempty(x),regexp(fileNameList,regExpStr));
        end
    end
    methods (Access=protected)
        function fileName=genfilename(self,inpStr)
            %
            if self.isHashedKeys
                inpStr=hash(inpStr);
            end
            
            if ~isempty(inpStr)
                nChars=length(inpStr);
                nBlocks=fix(nChars/namelengthmax);
                blockSizeVec=[repmat(namelengthmax,1,nBlocks),rem(nChars,namelengthmax)];
                inpCutStrCVec=mat2cell(inpStr,1,blockSizeVec);
                %
                inpCutStrCVec=cellfun(@genvarname,inpCutStrCVec,'UniformOutput',false);
                fileName=[inpCutStrCVec{:}];
            else
                fileName=inpStr;
            end
            %
        end
    end
    
end