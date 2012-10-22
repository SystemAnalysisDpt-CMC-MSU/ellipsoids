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
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-06-02 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
outStrList=cellfun(@(x,y)[x,sepStr],inpStrList,'UniformOutput',false);
outStr=[outStrList{:}];
nSepSymb=length(sepStr);
outStr=outStr(1:(end-nSepSymb));