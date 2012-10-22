function res=structcheckpath(structB,path)
% STRUCTCHECKPATH for given a path '.a.b.c.d.' and a structB
% returns true, if this path exists in the structure
%
% Usage: res=structcheckpath(structB,path)
%
% input:
%   regular:
%       structB - a struct
%       path: string, 'a.b.c.d', in this case 'a' is ignored, and the value
%           is stored in structB.b.c.d, the correct path begins from dot.
% output:
%   res: logical, true if the path exists in structure
%
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%

if ~isempty(path)
    if path(1)=='.'
        path=['tmp' path];
    end
    pathParts=regexp(path,'([^\.]*)','match');
    nParts=length(pathParts);
    for iPart=2:nParts
        smallPath=pathParts{iPart};
        if ~isstruct(structB)
            res=0;
            return;
        end
        if isfield(structB,smallPath)
            structB=structB.(smallPath);
        else
            res=0;
            return;
        end
    end
end
res=1;