function resStr=obj2plainstr(meObj)
%OBJ2PLAINSTR does the same as OBJ2STR but without using the
%hyper-references and via a legacy function errst2str
%
% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Applied Mathematics and Cybernetics, System Analysis
% Department, 12-October-2012, <pgagarinov@gmail.com>$
%
resCStr=cellfun(@(x)sprintf('%s\n',x),...
    errst2str(meObj),'UniformOutput',false);
resStr=[resCStr{:}];
