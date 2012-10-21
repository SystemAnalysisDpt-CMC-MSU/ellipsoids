function  activeBrowser = profview(varargin)
% PROFVIEW enhances a functionality of Matlab built-in function profview by
% allowing to display several profiler windows simultaneously and specify a
% title for each window. Having multiple profiler windows is useful for
% performance comparison.
%
% Input:
%   optional:
%       functionName char[1,]/numeric[1,1] - a name or an index number into
%          the profile (see built-in profview's help for more details)
%
%       profileInfo struct[1,1] - structure returned by profile('info')
%
%   properties:
%       titlePrefix: char[1,] - title for profiler report
%       keepCache: logical[1,1] - if true, cache profiling reports are kept
%          intact and overriden for the same cacheKey otherwise, false by default
%       cacheKey: char[1,] - key used to extract profile info structure and
%           activeBrowser window from the cache
%
% Output:
%   activeBrowser: com.mathworks.mde.webbrowser.WebBrowser[1,1] - browser
%       in which the report is displayed.
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-19 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
persistent profInfoMap browserMap
[reg,prop]=modgen.common.parseparams(varargin,{'titlePrefix','keepCache','cacheKey'});
nRegs=length(reg);
nProps=length(prop);
%
isTitlePrefixSpec=false;
isCacheKept=false;
isCacheKeySpec=false;
for k=1:2:nProps-1
    switch lower(prop{k})
        case 'titleprefix',
            titlePrefix=prop{k+1};
            if ~(ischar(titlePrefix)&&modgen.common.isrow(titlePrefix))
                error([upper(mfilename),':wrongInput'],...
                    'titlePrefix property is expected to be a string');
            end
            isTitlePrefixSpec=true;
        case 'keepcache',
            isCacheKept=prop{k+1};
            if ~(islogical(isCacheKept)&&numel(isCacheKept)==1)
                error([upper(mfilename),':wrongInput'],...
                    'cacheKept property is expected to be a logical scalar');
            end
        case 'cachekey',
            cacheKey=prop{k+1};
            if ~(ischar(cacheKey)&&modgen.common.isrow(cacheKey))
                error([upper(mfilename),':wrongInput'],...
                    'cacheKey property is expected to be a string');
            end
            isCacheKeySpec=true;
    end
end
%
if isempty(browserMap)
    browserMap=containers.Map();
end
if isCacheKeySpec
    if browserMap.isKey(cacheKey)
        activeBrowser=browserMap(cacheKey);
    else
        error([upper(mfilename),':wrongInput'],...
            'Oops, we shouldn''t be here');
    end
else
    activeBrowser=createBrowser();
    cacheKey=num2str(activeBrowser.hashCode());
    browserMap(cacheKey)=activeBrowser();
end
%
if ~isTitlePrefixSpec
    titlePrefix='';
end
%
if isempty(profInfoMap)
    profInfoMap=containers.Map();
end
%
if (profInfoMap.isKey(cacheKey)&&~isCacheKept)||~profInfoMap.isKey(cacheKey)
    profInfo=profile('info');
    profInfoMap(cacheKey)=profInfo;
else
    profInfo=profInfoMap(cacheKey);
end
%
if nRegs==0
    reg={0,profInfo};
elseif nRegs==1
    reg=[reg,{profInfo}];
end
%
htmlOut=profview(reg{:});
funcRepStr='modgen.profiling.profview';
funcRepArgStr=['''keepCache'',true,''cacheKey'',''',cacheKey,''','];
if isTitlePrefixSpec
    htmlOut=strrep(htmlOut,'<title>',['<title>',titlePrefix,', ']);
    funcRepArgStr=[funcRepArgStr,'''titlePrefix'',''',titlePrefix,''','];
end
%
htmlOut=strrep(htmlOut,'profview(',['profview(',funcRepArgStr]);
%
htmlOut=strrep(htmlOut,'profview',funcRepStr);
%
if nargout==0
    activeBrowser.setHtmlText(htmlOut);
end
profile off;
end
function activeBrowser=createBrowser()
activeBrowser = com.mathworks.mde.webbrowser.WebBrowser.createBrowser(true,true);
if isempty(activeBrowser),
    error([upper(mfilename),':wrongCall'],...
        'Browser window for profiler can not be created');
end
end