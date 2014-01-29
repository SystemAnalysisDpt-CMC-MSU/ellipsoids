function SRes=structgetpath(SInp,pathStr)
% STRUCTGETPATH for given a path '.a.b.c.d.'
% and a structB, returns value, so that
% value==structB.a.b.c.d;

% Usage:SRes=structgetpath(SInp,pathStr)
%
% input:
%   regular:
%       SInp: struct[multydimensional] - struct array
%       pathStr: string - path in the structure;
%
% output:
%   regular:
%       SRes: struct[multydimensional] - struct array same size as SInp;
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
if isempty(pathStr)
    SRes=SInp;
    return;
end
if numel(SInp)==1
    dot='.';
    if (pathStr(1)=='.')
        dot='';
    end
    %% dirty hack here, old versions of structgetpath,
    % were handling pathString differently, for compatibility, here is a
    % temporary plug, that would allow them to work, while issuing a
    % warning.
    indFirstDot=find(pathStr=='.',1,'first');
    %
    if (~isempty(indFirstDot)&&(indFirstDot>1))&&(~isfield(SInp,pathStr(1:indFirstDot-1)))
        %%
        pathStr=pathStr(indFirstDot+1:end);
        warning('STRUCT:compatibilityMode',' structgetpath called with an old pathStr format (first word - name of structure)');
    end
    %
    SRes=eval(['SInp' dot pathStr ';']);
    return;
end
if ischar(pathStr)
    pathParts=regexp(pathStr,'([^\.]*)','match');
else
    pathParts=pathStr;
end
firstField=pathParts{1};
SRes=reshape([SInp.(firstField)],size(SInp));
if length(pathParts)>1
SRes=structgetpath(SRes,...
    pathParts(2:end));
end