function structB=structapplypath(structB,path,value)
% STRUCTAPPLYPATH for given a path '.a.b.c.d.' and a value
% and a structB, returns modified structB, so that
% structB.a.b.c.d==value; 
%
% Usage: structB=structapplypath(structB,path,value) 
%
% input:
%   regular:
%       structB - a struct
%       path: string, 'a.b.c.d', in this case 'a' is ignored, and the value
%           is stored in structB.b.c.d, the correct path begins from dot.
%       value: value to be stored
%
% output:
%   regular:
%       structB - a struct
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%

if ~isempty(path)
    if path(1)=='.'
        path=['tmp' path];
    end
    pathParts=regexp(path,'([^\.]*)','match');
    pathParts=pathParts(2:end);
%     nParts=length(pathParts);
%     smallPath='';
%     for iPart=2:nParts
%         smallPath=[smallPath '.' pathParts{iPart}];
%     end
%     eval(['structB' smallPath '=value;']);
    structB=setfield(structB, pathParts{:},value);
end