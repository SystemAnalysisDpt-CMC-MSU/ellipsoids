function varargout=auxdfeval(processorFunc,varargin)
% AUXDFEVAL executes specified function in parallel
%
% Input: 
%   regular:
%       processorFunc: functionHandle/str - function to calculate across
%           multiple workes
%
%   optional:
%       arg1List: cell[1,nWorkes], list of the first arguments
%       ...
%       argNList: cell[1,nWorkes], list of the N-th arguments
%
%       In case processorFunc takes no arguments, pass an empty cell
%       argList: cell[0,nWorkes]
%       
%   properties:
%       startupFilePath: char[1,] - path to the taskStartup.m file executed
%          at each worker startup
%
%       configuraiton: char[1,] - name of parallel computing configuration
%
%       sharedPathMap: cell[nMapElems,nSynonyms] - contains a list of
%          shared code base synonyms; each row contains a set of path
%          synonyms (like {'/mnt/p_drive/','P:\'}). This list is used to
%          replicate set of paths extracted via 'path' command before
%          sending to workers on other machines. Morever, if a synonym
%          containing '/' file separate is changed to a synonym with an
%          opposite separate '\' the separators in the rest of the path are
%          inverted as well.
%
%       alwaysFork: logical[1,1] - if FALSE (default) and nWorkers=1, 
%         processorFunc will be executed within the current process, so
%         that no new processes will be spawned. If TRUE, at least one
%         process will be spawned in any event, and nothing will be
%         executed within the current process.
%
%       clusterSize: numeric[1,1] - specifies a maximum number of workers
%          that can run in parallel on the system, if not specified, a
%          maximum number of workers is defined by configuration specified
%          via 'configuraion' property
%
% Output:
%   varargout: whatever processorFunc function returns
%
% Example: [a,b]=auxdfeval(@deal,{1,2},{3,4})
% a =
%     [1]
%     [2]
% b =
%     [3]
%     [4]
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-04-26 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import modgen.pcalc.dfevalasync;
%
isStartupFileUsed=false;
isSharedPathMapSpec=false;
isConfSpec=false;
isFork = false;
%
[reg,prop]=modgen.common.parseparams(varargin);
%
if isempty(reg)
    error([upper(mfilename),':wrongInput'],...
        'The argument list must have at least one element');
end
%
dfevalArgList={};
nProp=length(prop);
clusterSize=Inf;
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'startupfilepath',
            startupFilePath=prop{k+1};
            if ~ischar(startupFilePath)
                error([upper(mfilename),':wrongInput'],...
                    'startup file path is expected to be a string');
            end
            isStartupFileUsed=true;
        case 'configuration',
            isConfSpec=true;
            confName=prop{k+1};
        case 'sharedpathmap',
            isSharedPathMapSpec=true;
            sharedPathMapCMat=prop{k+1};
        case 'alwaysfork',
            isFork = prop{k+1};
            if ~isscalar(isFork) || ~islogical(isFork)
                error([upper(mfilename),':wrongInput'],...
                    'invalid side or type of %s', prop{k});
            end
        case 'clustersize',
            clusterSize=prop{k+1};
            dfevalArgList=[dfevalArgList,prop([k,k+1])]; %#ok<AGROW>
        otherwise,
            error([upper(mfilename),':wrongInput'],...
                'property %s is not supported', prop{k});
    end
end
%
if isSharedPathMapSpec
    if ~(ismatrix(sharedPathMapCMat)&&iscellstr(sharedPathMapCMat))
        error([upper(mfilename),':wrongInput'],...
            'sharedPathMap is expected to be a 2-D cell array of strings');
    end
    %
end
%
if isStartupFileUsed
    if ~isempty(startupFilePath)
        startupFilePath=removeendfilesep(startupFilePath);
        if length(startupFilePath)>=1
            startupFilePath=removeendfilesep(startupFilePath);
        end
    else
        error([upper(mfilename),'wrongInput'],...
            'startupFilePath cannot be empty');
    end
    startupFileName=[startupFilePath,filesep,'taskStartup.m'];
end
if ~isConfSpec
    confName=defaultParallelConfig;
end
dfevalArgList=[dfevalArgList,{'configuration',confName}];
nOut=nargout;
nTasks=size(reg{1},2);
if (nTasks>1&&clusterSize>1) || isFork
    pathList=regexp(path,pathsep,'split');
    if isSharedPathMapSpec
        newPathList={};
        nSynonyms=size(sharedPathMapCMat,2);
        nMapElems=size(sharedPathMapCMat,1);
        for iElem=1:nMapElems
            for iSynFrom=1:nSynonyms
                for iSynTo=1:nSynonyms
                    if iSynTo==iSynFrom
                        continue;
                    end
                    %
                    pathFrom=sharedPathMapCMat{iElem,iSynFrom};
                    pathTo=sharedPathMapCMat{iElem,iSynTo};
                    curNewPathList=strrep(pathList,pathFrom,pathTo);
                    if any(strcmpi(pathTo,'/'))&&any(strcmpi(pathFrom,'\'))
                        curNewPathList=strrep(curNewPathList,...
                            '\','/');
                    elseif any(strcmpi(pathTo,'\'))&&any(strcmpi(pathFrom,'/'))
                        curNewPathList=strrep(curNewPathList,...
                            '/','\');
                    end      
                    newPathList=[newPathList,curNewPathList]; %#ok<AGROW>
                end
            end
        end
        pathList=newPathList;
    end
    %
    dfevalArgList=[dfevalArgList,{'PathDependencies',pathList}];
    if isStartupFileUsed
            dfevalArgList=[dfevalArgList,{'FileDependencies',{startupFileName}}];
    end    
    job=dfevalasync(processorFunc,nOut,reg{:},dfevalArgList{:});
    %
    try
        waitForState(job,'finished');
        resState=get(job,'State');
        if ~strcmp(resState,'finished')
            jobName=get(job,'Name');
            error([upper(mfilename),':jobBadFinish'],...
                'Job %s has finished with state %s',jobName,resState);
        end
        %
        STasks=get(job,'Tasks');
        ErrorCell=cell(1,nTasks);
        for iTask=1:nTasks
            ErrorCell{iTask}=get(STasks(iTask),'Error');
        end
        isErrorVec=~cellfun(@(x)isempty(x)||~isempty(x)&&isempty(x.message),ErrorCell);
        %
        resultCell=getAllOutputArguments(job);
        if any(isErrorVec)
            indError=find(isErrorVec);
            parentException=MException([mfilename,':derivedTaskFailed'],'the following tasks failed: %s',mat2str(indError));
            nErrors=length(indError);
            for iError=1:nErrors
                indCurError=indError(iError);
                % Note: the following block of code is excluded because it
                % is impossible to establish where error occured in child
                % code, replace of '\' to '/' is moved to errst2str
                % function
                %
                % identifierStr=ErrorCell{indCurError}.identifier;
                % messageStr=ErrorCell{indCurError}.message;
                % %the following string is only for fixing a bug on PC platform where file
                % %separator is recognized as escape symbol
                % messageStr=strrep(messageStr,'\','/');
                %
                % childException=MException(identifierStr,messageStr);
                parentException=addCause(parentException,ErrorCell{indCurError});
            end
            throw(parentException);
        end
        varargout=mat2cell(resultCell,nTasks,ones(1,nOut));
    catch ME
        cancel(job);
        rethrow(ME);
    end
else
    resultCell=cell(nTasks,nOut);
    isInp=size(reg{1},1)>0;
    inpCell={};
    for iTask=1:nTasks,
        if isInp,
            inpCell=cellfun(@(x)x{iTask},reg,'UniformOutput',false);
        end
        if nOut>0,
            [resultCell{iTask,:}]=feval(processorFunc,inpCell{:});
        else
            feval(processorFunc,inpCell{:});
        end
    end
    varargout=mat2cell(resultCell,nTasks,ones(1,nOut));
end
end
function inpStr=removeendfilesep(inpStr)
if ismember(inpStr(end),{'/','\'})
    inpStr(end)=[];
end
end