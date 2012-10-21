classdef HashMapMatXML<modgen.containers.ondisk.AHashMap
    %DISKBASEDHASHMAP represents a hash map for the arbitrary objects on disk
    % with a high level of persistency when the object state can be
    % restored based only on a storage location
    
    properties (Constant,GetAccess=protected)
        MAT_EXTENSION='mat';
        XML_EXTENSION='xml';
        IGNORE_EXTENSIONS={'asv','xml~'};
        ALLOWED_EXTENSIONS={'mat','xml'};
    end
    methods
        function self=HashMapMatXML(varargin)
            % DISKBASEDHASHMAP creates a hash map object
            %
            % Usage: self=DiskBasedHashMap() or
            %        self=DynamicRelation(varargin)
            %
            % Input:
            %   properties:
            %       optional:
            %            storageLocationRoot: char[1,nChars1] - storage location 
            %
            %            storageBranchKey: char[1,nChars2] - a key used for
            %               generating a final storageLocation
            %
            %            ignorePutErrors: logical[1,1] - if true all put
            %               errors are ignored (default is false)
            %                   
            %            ignoreBrokenStoredValues: logical [1,1] - if true
            %               all broken stored values are considered to be
            %               absent (default is false)
            %
            %            storageFormat: char[1,] - can have the following
            %               values
            %                   'mat' (default) - use mat files for storing
            %                       the values
            %                   'xml' - use xml files 
            %
            %                   'none' - do not store files at all i.e.
            %                      skip all put operations
            %
            %            useHashedPath: logical[1,1] - if true (default), branch
            %               paths are hashed to limit their length
            %
            %            useHashedKeys: logical[1,1] -if true (default),
            %               file names are based on not-hashed keys to
            %                  improve a file name readability
            %
            % Output:
            %   regular:
            %     self: DiskBasedHashMap [1,1] - constructed class object
            %
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-02-18 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2012 $
            %
            %
            import modgen.*;
            import modgen.containers.DiskBasedHashMap;
            import modgen.system.ExistanceChecker;

            %
            self=self@modgen.containers.ondisk.AHashMap(varargin{:});
            [~,prop]=parseparams(varargin);     
            nProp=length(prop);
            for k=1:2:nProp-1
                switch lower(prop{k})
                    case 'storageformat'
                        self.storageFormat=prop{k+1};
                end
            end
            %
            switch lower(self.storageFormat)
                case 'mat',
                    self.saveFunc=@save;
                    self.loadKeyFunc=@(x)load(x,'keyStr');
                    self.loadValueFunc=@(x)load(x,'valueObj');
                    self.fileExtension=self.MAT_EXTENSION;
                    self.isMissingKeyBlamed=true;
                case 'xml',
                    self.saveFunc=@(x,y,z)xmlsave(x,...
                        struct(...
                        'valueObj',{evalin('caller',y)},...
                        'keyStr',{evalin('caller',z)}),...
                        'on');
                    self.loadKeyFunc=@xmlload;
                    self.loadValueFunc=@xmlload;
                    self.fileExtension=self.XML_EXTENSION;
                    self.isMissingKeyBlamed=true;
                case 'none',
                otherwise,
                    error([upper(mfilename),':wrongInput'],...
                        'unknown storage format');
            end
        end
        %
    end
    methods (Access=protected)
        function valueObj=getOne(self,keyStr)
            import modgen.common.throwerror;
            WARN_TO_CATCH='badMatFile:wrongState';            
            lastwarn('');
            valueObj=getOne@modgen.containers.ondisk.AHashMap(self,keyStr);
            [lastWarnMsg,lastWarnId]=lastwarn();
            nChars=length(WARN_TO_CATCH);
            nWarnChars=length(lastWarnId);
            indStart=max(1,nWarnChars-nChars)+1;
            if strcmp(lastWarnId(indStart:end),WARN_TO_CATCH)
                throwerror('wrongState',lastWarnMsg);
            end            
        end          
        function [isPositive,keyStr]=checkKey(self,fileName)
            import modgen.system.ExistanceChecker;
            isPositive=ExistanceChecker.isFile(fileName);
            if (strcmp(self.fileExtension,self.XML_EXTENSION))&&(nargout<2)
                return;
            end
            if isPositive
               [isPositive,keyStr]=...
                   checkKey@modgen.containers.ondisk.AHashMap(...
                   self,fileName);
            end
        end
    end
end