classdef HashMapXMLMetaData<modgen.containers.ondisk.AHashMap
    %DISKBASEDHASHMAP represents a hash map for the arbitrary objects on disk
    % with a high level of persistency when the object state can be
    % restored based only on a storage location
    
    properties (Constant,GetAccess=protected)
        XML_EXTENSION='xml';
        IGNORE_EXTENSIONS={'asv','xml~'};
        ALLOWED_EXTENSIONS={'xml'};
    end
    methods
        function self=HashMapXMLMetaData(varargin)
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-08-06 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            %
            import modgen.containers.DiskBasedHashMap;
            import modgen.system.ExistanceChecker;
            import modgen.common.throwerror;
            import modgen.common.checkvar;
            import modgen.common.parseparext;
            %
            [regArgList,~,storageFormat]=parseparext(varargin,...
                {'storageFormat';'verxml';...
                'ischarstring(x)&&ismember(x,{''verxml'',''none''})'});
            %
            if ~ismember(storageFormat,{'verxml','none'})
                throwerror('wrongInput','storage format %s unknown',...
                    storageFormat);
            end
            %
            self=self@modgen.containers.ondisk.AHashMap(regArgList{:},...
                'storageFormat',storageFormat);
            %
            switch lower(self.storageFormat)
                case 'verxml',
                    self.saveFunc=...
                        @modgen.containers.ondisk.HashMapXMLMetaData.saveFunc;
                    self.loadKeyFunc=@modgen.xml.xmlload;
                    self.loadValueFunc=@modgen.xml.xmlload;
                    self.fileExtension=self.XML_EXTENSION;
                    self.isMissingKeyBlamed=true;
                case 'none',
                    self.saveFunc=@(x,y,z,w)1;
                    self.loadKeyFunc=@(x)1;
                    self.loadValueFunc=@(x)1;
                    self.isMissingKeyBlamed=true;
                otherwise,
                    throwerror('wrongInput',...
                        'storage format %s is unknown',self.storageFormat);
            end
        end
        %
    end
    methods (Access=protected, Static)
        function saveFunc(fileName,valueObjName,keyObjName,varargin)
            modgen.xml.xmlsave(fileName,struct(...
                'valueObj',{evalin('caller',valueObjName)},...
                'keyStr',{evalin('caller',keyObjName)}),...
                'on',varargin{:},'insertTimestamp',false);
        end
    end
    methods (Access=protected)
        %we redefine this method just for optimization
        function [isPositive,keyStr]=checkKey(self,fileName)
            import modgen.system.ExistanceChecker;
            isPositive=ExistanceChecker.isFile(fileName);
            if (strcmp(self.fileExtension,self.XML_EXTENSION))&&(nargout<2)
                return;
            end
            if isPositive
                [isPositive,keyStr]=checkKey@modgen.containers.ondisk.AHashMap(...
                    self,fileName);
            end
        end
        function putOne(self,keyStr,valueObj,varargin)
            import modgen.system.ExistanceChecker;
            import modgen.common.throwwarn;
            fullFileName=self.genfullfilename(keyStr);
            try
                self.saveFunc(fullFileName,'valueObj','keyStr',varargin{:});
            catch meObj
                if ExistanceChecker.isFile(fullFileName)
                    delete(fullFileName);
                end
                %
                if self.isPutErrorIgnored
                    throwwarn('saveFailure',...
                        'cannot save the key value: %s',...
                        meObj.message);
                    return;
                else
                    rethrow(meObj);
                end
            end
        end
        %
        function [valueObj,metaData]=getOne(self,keyStr)
            fileName=self.getFileNameByKey(keyStr);
            [resObj,metaData]=self.loadValueFunc(fileName);
            valueObj=resObj.valueObj;
        end
    end
end