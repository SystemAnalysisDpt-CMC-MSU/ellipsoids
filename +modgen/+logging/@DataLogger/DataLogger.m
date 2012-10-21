classdef DataLogger<modgen.common.obj.StaticPropStorage
    % DATALOGGER allows to log performance of functions and also save
    % contents of their local variables into MAT-files

    methods (Static)
        function configure(varargin)
            % CONFIGURE determines configuration parameters for data logger
            %
            % Usage: configure(varargin)
            %
            % input:
            %   properties:
            %     isEnabled: logical [1,1] - if true, then logging is
            %         switched on, otherwise it is switched off
            %     functionNameList: cell [1,nFunc] - list with names of
            %         functions for which logging is enabled
            %     storageLocationRoot: char [1,] - storage location 
            %     nMaxDatesOnDisk: double [1,1] - maximal number of dates
            %         for which data logs may be on disk, data logs that
            %         are more than this number of dates on disk are
            %         deleted from the storage automatically; by default it
            %         equals to 5 days
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            %
            
            import org.apache.log4j.Logger;
            className=mfilename('class');
            feval([className '.flush']);
            %% default values for properties
            storageLocation=[fileparts(which(className)) filesep 'DataLogs'];
            isEnabled=false;
            functionNameList=cell(1,0);
            nMaxDatesOnDisk=5;
            %% parse properties
            [~,prop]=modgen.common.parseparams(varargin,[],0);
            nProp=length(prop);
            for iProp=1:2:nProp-1,
                switch lower(prop{iProp})
                    case 'isenabled',
                        isEnabled=prop{iProp+1};
                    case 'functionnamelist',
                        functionNameList=prop{iProp+1};
                    case 'storagelocationroot',
                        storageLocation=prop{iProp+1};
                    case 'nmaxdatesondisk',
                        nMaxDatesOnDisk=prop{iProp+1};
                    otherwise
                        error([upper(mfilename),':wrongInput'],...
                            'Unknown property: %s',prop{iProp});
                end
            end
            %% check inputs
            % check isEnabled
            if ~(islogical(isEnabled)&&numel(isEnabled)==1),
                error([upper(mfilename),':wrongInput'],...
                    'isEnabled must be scalar logical');
            end
            % check functionNameList
            if ischar(functionNameList),
                if isempty(functionNameList)||size(functionNameList,2)~=...
                        numel(functionNameList),
                    error([upper(mfilename),':wrongInput'],...
                        'functionNameList must be nonempty string');
                end
                functionNameList={functionNameList};
            else
                isnWrong=iscell(functionNameList);
                if isnWrong,
                    functionNameList=reshape(functionNameList,1,[]);
                    isnWrong=all(...
                        cellfun('isclass',functionNameList,'char')&...
                        cellfun('size',functionNameList,2)==...
                        cellfun('prodofsize',functionNameList)&...
                        ~cellfun('isempty',functionNameList));
                end
                if ~isnWrong,
                    error([upper(mfilename),':wrongInput'],...
                        'functionNameList must be cell array with nonempty strings');
                end
                functionNameList=unique(functionNameList);
            end
            % check storageLocation
            if isempty(storageLocation)||~(ischar(storageLocation)&&...
                    size(storageLocation,2)==numel(storageLocation)),
                error([upper(mfilename),':wrongInput'],...
                    'storageLocation must be nonempty string');
            end
            % check nMaxDatesOnDisk
            isnWrong=isnumeric(nMaxDatesOnDisk)&&numel(nMaxDatesOnDisk)==1;
            if isnWrong,
                nMaxDatesOnDisk=double(nMaxDatesOnDisk);
                isnWrong=~isnan(nMaxDatesOnDisk)&&nMaxDatesOnDisk>=0&&...
                    floor(nMaxDatesOnDisk)==nMaxDatesOnDisk;
            end
            if ~isnWrong,
                error([upper(mfilename),':wrongInput'],...
                    'nMaxDatesOnDisk must be scalar nonnegative integer');
            end
            %% preprocess data storage
            if ~modgen.system.ExistanceChecker.isDir(storageLocation),
                mkdir(storageLocation);
            end
            if isfinite(nMaxDatesOnDisk)&&isEnabled,
                % delete files that are more than nMaxDatesOnDisk dates on
                % disk
                SFileList=dir(storageLocation);
                SFileList([SFileList.isdir])=[];
                fileNameList={SFileList.name};
                if ~isempty(fileNameList),
                    [~,fileNameList,extNameList]=cellfun(@fileparts,...
                        fileNameList,'UniformOutput',false);
                    isFileVec=strcmp(extNameList,'.mat');
                    if any(isFileVec),
                        fileNameList=fileNameList(isFileVec);
                        fileNameList=fileNameList(...
                            [SFileList(isFileVec).datenum]<=...
                            addtodate(floor(now),-nMaxDatesOnDisk,'day'));
                        nFiles=numel(fileNameList);
                        if nFiles,
                            fileNameList=strcat(storageLocation,filesep,fileNameList,'.mat');
                            for iFile=1:nFiles,
                                delete(fileNameList{iFile});
                            end
                        end
                    end
                end
            end
            %% set properties
            setMethodName=[className '.setPropInternal'];
            feval(setMethodName,'isEnabled',isEnabled);
            feval(setMethodName,'functionNameList',functionNameList);
            feval(setMethodName,'prefixList',cell(1,0));
            feval(setMethodName,'loggerObj',Logger.getLogger(className));
            feval(setMethodName,'storageLocation',storageLocation);
            feval(setMethodName,'filePostfix',modgen.system.getpidhost());
        end
        %
        function addPrefixToList(prefixStr)
            % ADDPREFIXTOLIST adds prefix to the end of the list with
            % prefixes
            %
            % Usage: addPrefixToList(prefixStr)
            %
            % input:
            %   regular:
            %     prefixStr: char [1,] - prefix to be added
            %
            %
            
            %% initial actions
            className=mfilename('class');
            if ~feval([className '.getIsEnabled']),
                return;
            end
            if isempty(prefixStr)||~(...
                    ischar(prefixStr)&&size(prefixStr,2)==numel(prefixStr)),
                error([upper(mfilename),':wrongInput'],...
                    'prefixStr must be nonemtpy string');
            end
            %% add prefix
            prefixList=feval([className '.getPropInternal'],'prefixList');
            feval([className '.setPropInternal'],'prefixList',horzcat(prefixList,{prefixStr}));
        end
        %
        function removePrefixFromList()
            % REMOVEPREFIXFROMLIST removes prefix from the end of the list
            % with prefixes
            %
            % Usage: removePrefixFromList()
            %
            %
            
            %% initial actions
            className=mfilename('class');
            if ~feval([className '.getIsEnabled']),
                return;
            end
            %% remove prefix
            prefixList=feval([className '.getPropInternal'],'prefixList');
            if isempty(prefixList),
                error([upper(mfilename),':wrongObjState'],...
                    'addPrefixToList must be called before calling this method');
            end
            feval([className '.setPropInternal'],'prefixList',prefixList(1:end-1));
        end
        %
        function log()
            % LOG logs info on function only as text into special log-file
            %
            % Usage: log()
            %
            %
            
            className=mfilename('class');
            if ~feval([className '.getIsEnabled']),
                return;
            end
            [~,fullFuncName,isLogged]=feval([className '.getFunctionProps'],2);
            if ~isLogged,
                return;
            end
            getMethodName=[className '.getPropInternal'];
            loggerObj=feval(getMethodName,'loggerObj');
            loggerObj.info([fullFuncName ' is performed']);
        end
        %
        function logData()
            % LOG logs both info on function executed and data of local
            % variables
            %
            % Usage: logData()
            %
            %
            
            className=mfilename('class');
            if ~feval([className '.getIsEnabled']),
                return;
            end
            [shortFuncName,fullFuncName,isLogged]=feval([className '.getFunctionProps'],2);
            if ~isLogged,
                return;
            end
            loggerObj=feval([className '.getPropInternal'],'loggerObj');
            fileName=feval([className '.getDataFileName'],shortFuncName,fullFuncName);
            [~,shortFileName]=fileparts(fileName);
            loggerObj.info([fullFuncName ' is performed, data with local variables are in ' shortFileName]);
            evalin('caller',['save(' fileName ')']);
        end
        %
        function flush()
            % FLUSH clears info set by configure within storage
            %
            % Usage: flush()
            %
            %
            
            className=mfilename('class');
            feval([className '.flushInternal'],className);
        end         
    end
    
    methods (Access=protected,Static)
        function isEnabled=getIsEnabled()
            % GETISENABLED determines whether logging is enabled or not
            %
            % Usage: isEnabled=getIsEnabled(className)
            %
            % output:
            %   regular:
            %     isEnabled: logical [1,1] - if true, then logging is
            %         enabled, otherwise falsr
            %
            %
            
            className=mfilename('class');
            [isEnabled,isConfigured]=feval([className '.getPropInternal'],...
                'isEnabled',true,className);
            isEnabled=isConfigured&&~isempty(isEnabled)&&isEnabled;
        end
        %
        function fileName=getDataFileName(shortFuncName,fullFuncName)
            % GETDATAFILENAME generates name for file with logged data
            %
            % Usage: fileName=getDataFileName(shortFuncName,fullFuncName)
            %
            % input:
            %   regular:
            %     shortFuncName: char [1,] - short function name (see
            %         getFunctionProps method below for details)
            %     fullFuncName: char [1,] - full function name (see
            %         getFunctionProps method below for details)
            % output:
            %   regular:
            %     fileName: char [1,] - full name of file with logged data
            %
            %
            
            className=mfilename('class');
            getMethodName=[className '.getPropInternal'];
            fileName=[feval(getMethodName,'storageLocation') filesep ...
                shortFuncName '_' feval(getMethodName,'filePostfix') '_'...
                datestr(now,30) '_' hash(fullFuncName) '.mat'];
        end
        %
        function [shortFuncName,fullFuncName,isLogged]=getFunctionProps(indStack)
            % GETFUNCTIONPROPS returns short name of function as well
            % as its full name including all necessary prefixes and
            % information whether it is to be logged or not
            %
            % Usage: [shortFuncName,fullFuncName,isLogged]=...
            %            getFunctionProps()
            %
            % input:
            %   optional:
            %     indStack: double [1,1] - index of function in stack
            %         (relative to this method, 1 corresponds to the
            %         immediate caller of this method); if not given,
            %         we take the first function in the stack that is not
            %         method (or subfunction of method) of some descendant
            %         of this class
            % output:
            %   regular:
            %     shortFuncName: char [1,] - short name of function to be
            %         logged (i.e. without name of class, prefixes, etc.)
            %     fullFuncName: char [1,] - full name of function with all
            %         necessary prefixes
            %     isLogged: logical [1,1] - if true, then given function is
            %         to be logged, otherwise false
            %
            %
            
            curClassName=mfilename('class');
            %% find function names (short and full one, but without
            %% prefixes)
            StFunc=dbstack('-completenames');
            nFuncs=numel(StFunc);
            isFound=false;
            isCheck=nargin==0;
            if isCheck,
                indStack=3;
            else
                indStack=indStack+1;
            end
            for iFunc=indStack:nFuncs,
                % determine name of class (if any) and name of
                % method (function or script)
                StFuncCur=StFunc(iFunc);
                [pathStr,fileName]=fileparts(StFuncCur.file);
                pathStr=strrep(pathStr,[filesep '+'],'.');
                indClass=strfind(pathStr,[filesep '@']);
                isClass=~isempty(indClass);
                if isClass,
                    pathStr(indClass)='.';
                    pathStr(indClass+1)=[];
                end
                curInd=find(pathStr==filesep,1,'last');
                if ~isempty(curInd),
                    pathStr=pathStr(curInd+1:end);
                end
                curInd=find(pathStr=='.',1,'first');
                if isempty(curInd),
                    isPath=false;
                else
                    pathStr=pathStr(curInd+1:end);
                    isPath=~isempty(pathStr);
                end
                methodName=StFuncCur.name;
                curInd=find(methodName=='.',1,'first');
                if ~isempty(curInd),
                    methodName=methodName(curInd+1:end);
                    if ~isClass,
                        pathStr=[pathStr '.' fileName]; %#ok<AGROW>
                        isClass=true;
                    end
                end
                shortFuncName=methodName(find(['/' methodName]=='/',1,'last'):end);
                className='';
                if isPath,
                    if isClass,
                        className=pathStr;
                    else
                        methodName=[pathStr '.' methodName]; %#ok<AGROW>
                    end
                end
                if isCheck,
                    isFound=isempty(className);
                    if ~isFound,
                        isFound=~any(strcmp(superclasses(className),curClassName));
                    end
                else
                    isFound=true;
                end
                if isFound,
                    fullFuncName=methodName;
                    if ~isempty(className),
                        fullFuncName=[className '.' fullFuncName]; %#ok<AGROW>
                    end
                    break;
                end
            end
            if ~isFound,
                error([upper(mfilename),':wrongCall'],[...
                    'This method must be called from function, script or '...
                    'method of some class different from descendants of %s'],...
                    mfilename('class'));
            end
            %% process fullFuncName and isLogged
            if nargout>1,
                getMethodName=[curClassName '.getPropInternal'];
                prefixList=feval(getMethodName,'prefixList');
                fullFuncName=cell2sepstr([],[prefixList {fullFuncName}],'.');
                if nargout>2,
                    isLogged=any(strcmp(fullFuncName,...
                        feval(getMethodName,'functionNameList')));
                end
            end
        end
        %
        function [propVal,isThere]=getPropInternal(propName,isPresenceChecked,className)
            % GETPROPINTERNAL gets corresponding property from storage
            %
            % Usage: [propVal,isThere]=...
            %            getPropInternal(propName,isPresenceChecked)
            %
            % input:
            %   regular:
            %     propName: char [1,] - property name
            %     isPresenceChecked: logical [1,1] - if true, then presence
            %         of given property is checked before its value is
            %         retrieved from the storage, otherwise value is
            %         retrieved without any check (that may lead to error
            %         if property is not yet logged into the storage)
            %   optional:
            %     className: char [1,] - name of class, if not given,
            %         name of current class is used
            % output:
            %   regular:
            %     propVal: empty or matrix of some type - value of given
            %         property in the storage (if it is absent, empty is
            %         returned)
            %   optional:
            %     isThere: logical [1,1] - if true, then property is in the
            %         storage, otherwise false
            %
            %
            
            if nargin>=3,
                branchName=className;
            else
                branchName=mfilename('class');
            end
            if nargin<2,
                isPresenceChecked=false;
            end
            [propVal,isThere]=modgen.common.obj.StaticPropStorage.getPropInternal(...
                branchName,propName,isPresenceChecked);
        end
        %
        function setPropInternal(propName,propVal,className)
            % SETPROPINTERNAL sets value for corresponding property within
            % storage
            %
            % Usage: setPropInternal(propName,propVal)
            %
            % input:
            %   regular:
            %     propName: char - property name
            %     propVal: matrix of some type - value of given property to
            %         be set in the storage
            %   optional:
            %     className: char [1,] - name of class, if not given,
            %         name of current class is used
            %
            %
            
            if nargin>=3,
                branchName=className;
            else
                branchName=mfilename('class');
            end
            modgen.common.obj.StaticPropStorage.setPropInternal(...
                branchName,propName,propVal);
        end
    end
end