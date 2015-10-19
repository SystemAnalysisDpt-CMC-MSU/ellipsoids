function varargout=auxdfevalpcomp(fCalc,varargin)
% AUXDFEVAL executes specified function in parallel
%
% Input:
%   regular:
%       processorFunc: function_handle[1,1]/char[1,] - function to 
%           calculate across multiple workes
%
%   optional:
%       arg1List: cell[nInpArg1Group,nWorkes], list of the first arguments
%           ...
%       argNList: cell[nInpArgNGroup,nWorkes], list of the N-th arguments
%
%     Note:  The total number of input arguments =...
%           nInpArg1Group+...+nInpArgNGroup 
%
%     Note: In case processorFunc takes no arguments, pass an empty cell
%           argList: cell[0,nWorkes]
%
%   properties:
%       startupFilePath: char[1,] - path to the taskStartup.m file executed
%           at each worker startup
%
%       configuraiton: char[1,] - name of parallel computing configuration
%
%       sharedPathMap: cell[nMapElems,nSynonyms] - contains a list of
%           shared code base synonyms; each row contains a set of path
%           synonyms (like {'/mnt/p_drive/','P:\'}). This list is used to
%           replicate set of paths extracted via 'path' command before
%           sending to workers on other machines. Morever, if a synonym
%           containing '/' file separate is changed to a synonym with an
%           opposite separate '\' the separators in the rest of the path are
%           inverted as well.
%
%       alwaysFork: logical[1,1] - if FALSE (default) and nWorkers=1,
%           processorFunc will be executed within the current process, so
%           that no new processes will be spawned. If TRUE, at least one
%           process will be spawned in any event, and nothing will be
%           executed within the current process.
%
%       clusterSize: numeric[1,1] - specifies a maximum number of workers
%           that can run in parallel on the system, if not specified, a
%           maximum number of workers is defined by configuration specified
%           via 'configuraion' property
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
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2015-10-19 $
%
%
import modgen.common.throwerror;
import modgen.common.parseparams;
%
isParToolboxInstalled=modgen.pcalc.isparttbxinst();
[reg,prop]=parseparams(varargin);
%
isStartupFileUsed=false;
isSharedPathMapSpec=false;
isConfSpec=false;
isFork = false;
%
if isempty(reg)
    throwerror('wrongInput',...
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
                throwerror('wrongInput',...
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
                throwerror('wrongInput',...
                    'invalid side or type of %s', prop{k});
            end
        case 'clustersize',
            clusterSize=prop{k+1};
            dfevalArgList=[dfevalArgList,prop([k,k+1])]; %#ok<AGROW>
        otherwise,
            throwerror('wrongInput',...
                'property %s is not supported', prop{k});
    end
end
%
if isSharedPathMapSpec
    if ~(ismatrix(sharedPathMapCMat)&&iscellstr(sharedPathMapCMat))
        throwerror('wrongInput',...
            ['sharedPathMap is expected to be a 2-D cell ',...
            'array of strings']);
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
        throwerror('wrongInput',...
            'startupFilePath cannot be empty');
    end
    startupFileName=[startupFilePath,filesep,'taskStartup.m'];
end
if (~isConfSpec)&&isParToolboxInstalled
    confName=parallel.defaultClusterProfile;
end
if ~isParToolboxInstalled
    if isFork
        modgen.common.throwwarn('wrongInput',...
            ['isFork=true is ignored when Parallel Toolbox ',...
            'is not installed']);
        isFork=false;
    end
    if clusterSize>1
        modgen.common.throwwarn('wrongInput',...
            ['clusterSize>1 is ignored when Parallel Toolbox ',...
            'is not installed']);
    end
    clusterSize=1;
end
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
                    if any(strcmpi(pathTo,'/'))&&...
                            any(strcmpi(pathFrom,'\'))
                        curNewPathList=strrep(curNewPathList,...
                            '\','/');
                    elseif any(strcmpi(pathTo,'\'))&&...
                            any(strcmpi(pathFrom,'/'))
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
    dfevalArgList=[dfevalArgList,{'AdditionalPaths',pathList}];
    if isStartupFileUsed
        dfevalArgList=[dfevalArgList,{'AttachedFiles',{startupFileName}}];
    end
    parClustObj=parcluster(confName);
    jobObj=createJob(parClustObj,dfevalArgList{:});
    %
    inpArgCMat = transpose(vertcat(reg{:}));
    %
    taskList=cell(1,nTasks);
    try
        for iTask=1:nTasks
            taskList{iTask}=createTask(jobObj,fCalc,nOut,...
                inpArgCMat(iTask,:));
        end
        submit(jobObj);
    catch meObj
        cancel(jobObj);
        destroy(jobObj);
        rethrow(meObj);
    end
    %
    try
        wait(jobObj,'finished');
        isErrorVec=false(1,nTasks);
        errorList=cell(1,nTasks);
        for iTask=1:nTasks
            %
            isErrorVec(iTask)=strcmpi(get(taskList{iTask},'State'),...
                'failed');
            errObj=get(taskList{iTask},'Error');
            isErrorVec(iTask)=isErrorVec(iTask)||~isempty(errObj);
            if isempty(errObj)
                errObj=modgen.common.throwerror('unknownTaskError',...
                    'task failed for unknown reason');
            end
            errorList{iTask}=errObj;
        end
        %
        resultCell=getAllOutputArguments(jobObj);
        if any(isErrorVec)
            indErrorVec=find(isErrorVec);
            parentException=throwerror('derivedTaskFailed',...
                'the following tasks failed: %s',mat2str(indErrorVec));
            nErrors=length(indErrorVec);
            for iError=1:nErrors
                indCurError=indErrorVec(iError);
                parentException=addCause(parentException,...
                    errorList{indCurError});
            end
            throw(parentException);
        end
        varargout=mat2cell(resultCell,nTasks,ones(1,nOut));
    catch meObj
        cancel(jobObj);
        rethrow(meObj);
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
            [resultCell{iTask,:}]=feval(fCalc,inpCell{:});
        else
            feval(fCalc,inpCell{:});
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