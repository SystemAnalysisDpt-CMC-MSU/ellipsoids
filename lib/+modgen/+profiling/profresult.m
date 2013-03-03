function resTime=profresult(varargin)
% PROFRESULT takes info obtaining during profiling and displays a profiling
% report using the specified name as a marker
%
% Usage: resTime=profresult(profileMode,profileInfoObject,profCaseName)
%
% input:
%   regular:
%       profileMode: char [1,] - profiling mode, the following modes
%          are supported:
%            'none'/'off' - no profiling
%            'viewer' - profiling reports are just displayed
%            'file' - profiling reports are displayed and saved to the
%              file
%       profileInfoObject: ProfileInfo [1,1] - object containing info on
%           profiling
%   optional:
%       profCaseName: char[1,] - name of profiling case
%   properties:
%       callerName: char [1,] - name of caller whose name may be used for
%           generation of total name of profiling case; if it is not given,
%           the name of immediate caller of this function is used
%       profileDir: char [1,] - name of directory in which profiling
%           reports are to be saved
% output:
%   regular:
%     resTime: double [1,1] - total time of profiling in seconds
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%

%% initial actions
[reg,prop]=modgen.common.parseparams(varargin,[],[2 3]);
profileMode=reg{1};
profileInfoObject=reg{2};
if ~(ischar(profileMode)&&numel(profileMode)==size(profileMode,2)&&...
        ~isempty(profileMode)),
    error([upper(mfilename),':wrongInput'],...
        'profileMode must be nonempty string');
end
if ~(isa(profileInfoObject,'modgen.profiling.ProfileInfo')&&numel(profileInfoObject)==1),
    error([upper(mfilename),':wrongInput'],...
        'profileInfoObject must be scalar object of modgen.profiling.ProfileInfo class');
end
if numel(reg)>=3,
    profCaseName=reg{3};
else
    profCaseName='default';
end
%% parse properties
nProp=length(prop);
callerName=modgen.common.getcallername(2);
profileDir=pwd;
for iProp=1:2:nProp-1,
    switch lower(prop{iProp})
        case 'callername',
            callerName=prop{iProp+1};
        case 'profiledir',
            profileDir=prop{iProp+1};
        otherwise
            error([upper(mfilename),':wrongInput'],...
                'Unknown property: %s',prop{iProp});
    end
end
%% process profiling results
resTime=profileInfoObject.toc();
%
if ~any(strcmpi(profileMode,{'no','off'})),
    if ~isa(profileInfoObject,'modgen.profiling.ProfileInfoDetailed'),
        error([upper(mfilename),':wrongInput'],[...
            'profileInfoObject must be scalar object of '...
            'modgen.profiling.ProfileInfoDetailed class '...
            'for values of profileMode other than ''no'' and ''off''']);
    end
    StProfileInfo=profileInfoObject.getProfileInfo();
    switch lower(profileMode)
        case 'viewer',
            profCaseName=[callerName,'.',profCaseName];
            modgen.profiling.profview(0,StProfileInfo,'titlePrefix',profCaseName);
        case 'file',
            %
            profName=[callerName,...
                filesep,profCaseName,...
                filesep,datestr(now(),'dd-mmm-yyyy_HH_MM_SS_FFF')];
            profDir=[profileDir,filesep,'profiling',filesep,profName];
            modgen.profiling.profsave(StProfileInfo,profDir);
        otherwise,
            error([upper(mfilename),':wrongInput'],...
                'profMode %s is not supported',profileMode);
    end
end