function outStr = catwithsep(inpStrList,sepStr)
% CATWITHSEP concatenates input cell array of strings inserting a specified
% separator between the strings 
%
% Input:
%   regular:
%       inpStrList: cell[] of char[1,] - cell array of strings
%       sepStr: char[1,] - separator
%
% Output:
%   outStr: char[1,] - resulting string
%
% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$
%
outStrList=cellfun(@(x,y)[x,sepStr],inpStrList,'UniformOutput',false);
outStr=[outStrList{:}];
nSepSymb=length(sepStr);
outStr=outStr(1:(end-nSepSymb));
