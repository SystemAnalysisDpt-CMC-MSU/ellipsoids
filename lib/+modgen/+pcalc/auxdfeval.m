function varargout=auxdfeval(processorFunc,varargin)
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
%       engSelectMode: char[1,] - specifies an engine to use, can take the
%           following values:
%               'auto' - if the toolbox alternative to the Parallel
%                   Computing Toolbox by Mathworks is found on Matlab
%                   path - it i used, otherwise the Parallel Computing
%                   Toolbox is used.
%               'pcalc' - official Parallel Computing Toolbox is used.
%               'pcalcalt' - the alternative toolbox is used
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
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2014-02-28 $
%
%
import modgen.common.throwerror;
import modgen.common.parseparext;
import modgen.common.parseparams;
%
[restArgList,~,engSelectMode]=parseparext(varargin,...
    {'engSelectMode';...
    'auto';...
    'isstring(x)&&any(strcmpi(x,{''auto'',''pcalc'',''pcalcalt''}))'});
%
[isPCalcInstalled,isPCalcAltInstalled]=...
    modgen.pcalc.isparttbxinst();
switch lower(engSelectMode)
    case 'auto',
        isPCalcAltUsed=isPCalcAltInstalled;
    case 'pcalc',
        if ~isPCalcInstalled
            throwerror('wrongInput:noParToolbox',...
                'the Parallel Computing Toolbox by Mathworks is not installed');
        end
        %
        isPCalcAltUsed=false;
    case 'pcalcalt',
        if ~isPCalcAltInstalled
            throwerror('wrongInput:noParToolbox',...
                ['the toolbox alternative to the Parallel Computing ',...
                'Toolbox by Mathworks is not installed']);
        end
        isPCalcAltUsed=true;
end
%
if isPCalcAltUsed
    [reg,prop]=parseparams(restArgList);
    if ~isempty(prop),
        isIgnoredPropVec=ismember(lower(prop(1:2:end-1)),...
            lower({'sharedPathMap','configuration'}));
        if any(isIgnoredPropVec),
            isIgnoredPropVec=reshape(repmat(...
                reshape(isIgnoredPropVec,1,[]),2,1),1,[]);
            prop(isIgnoredPropVec)=[];
        end
    end
    if nargout==0
        modgen.pcalcalt.auxdfeval(processorFunc,reg{:},prop{:});
    else
        varargout=cell(1,nargout);
        [varargout{:}]=modgen.pcalcalt.auxdfeval(processorFunc,reg{:},...
            prop{:});
    end
elseif isPCalcInstalled
    %
    if nargout==0
        modgen.pcalc.auxdfevalpcomp(processorFunc,restArgList{:});
    else
        varargout=cell(1,nargout);
        [varargout{:}]=modgen.pcalc.auxdfevalpcomp(processorFunc,...
            restArgList{:});
    end
end
end