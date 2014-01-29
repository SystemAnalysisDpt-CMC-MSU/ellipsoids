function xmlsave( file, S, varargin)
% XMLSAVE saves structure or variable(s) to a file using XML format
%
% Input:
%   regular:
%       filename: char[1,] -     filename
%       S: struct[..], -   Matlab variable or structure to store in file.
%
%   optional:
%       att_switch: char[1,]   optional, 'on' stores XML type attributes (default),
%                'off' doesn't store XML type attributes
%       metaData    structure containing a meta information to be stored in the
%               resulting xml file, empty by default
%   properties:
%
%       insertTimestamp: logical[1,1] when false, timestamp is not recorded
%          into resulting xml file, true by default
%
% Output:
%   void
%
% See Also:
%   xmlload, xmlformat, xmlparse, (xmlread, xmlwrite)
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
[reg,prop]=modgen.common.parseparams(varargin,{'insertTimestamp'},[0 2]);
nReg=length(reg);
if (nargin<2) || ~ischar(file)
    disp([mfilename, ' requires 2 or 3 parameters: filename and' ...
        ' variable, optionally att_switch.']);
    return
end
%
if ~isempty(prop)
    isTsInserted=prop{2};
    if ~(islogical(isTsInserted)&&numel(isTsInserted)==1)
        error([upper(mfilename),':wrongInput'],...
            'insertTimestamp property is expected to be a logical scalar');
    end
    %
else
    isTsInserted=true;
end
if nReg==0
    att_switch='on'; 
else
    att_switch=reg{1};
end
%
if ~ischar(att_switch)
    error([upper(mfilename),':wrongInput'],...
        'att_switch is expected to be a string');
end
%
if ~strcmpi(att_switch, 'off'); 
    att_switch = 'on'; 
end
%
if nReg<2
    metaData=struct();
else
    metaData=reg{2};
    if ~isstruct(metaData)
    error([upper(mfilename),':wrongInput'],...
        'metaData is expected to be a structure');
    end
end
if ~all(structfun(@ischar,metaData))
    error([upper(mfilename),':wrongInput'],...
        'all fields of metaData structure are expected to be strings');
end
    
%-----------------------------------------------
if isempty(findstr(lower(file),'.xml'))
    file = strcat(file, '.xml');
end
%
fid = fopen(file, 'w');
if fid==-1
    error(['Error while writing file ', file]);
end

% write file header
fprintf(fid, '<?xml version="1.0"?>\n');
if isTsInserted
    fprintf(fid, sprintf('<!-- written on %s -->\n', datestr(now)));
end
try
    % write XML string
    fprintf(fid, '%s', xmlformat(S, att_switch,'root',0,metaData));
    % close file
    fclose(fid);
catch meObj
    fclose(fid);
    rethrow(meObj);
end