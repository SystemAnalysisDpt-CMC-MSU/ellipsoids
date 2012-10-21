function resStr=splitpart(inpStr,delimStr,fieldNum)
% SPLITPART splits string on delimiter and 
% return the given field (counting from one) 
%
% Input:
%   regular:
%       inpStr: char[1,] - string to be splitted
%       delimStr: char[1,] - delimiter
%       fieldNum: numeric[1,1]/char[1,] - number of field to return, if
%          char, can have one of the following values:
%               'first' - take the first field
%               'last' - take the last field
%
% Output:
%   resStr: char[1,]
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-04-03 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
%
if ~(ischar(fieldNum)||isnumeric(fieldNum))
    error([upper(mfilename),':wrongInput'],...
        'fieldNum parameter is expected to be either string or a value of a numeric type');
end
    
strSplitList=strsplit(inpStr,delimStr);
nFound=length(strSplitList);
if nFound==0
    error([upper(mfilename),':wrongInput'],...
        'Opps, we shouldn''t be here - the number of splitted strings is zero');
end
%
if ischar(fieldNum)
    switch lower(fieldNum)
        case 'first',
            fieldNum=1;
        case 'last',
            fieldNum=nFound;
    end
end
%
if nFound<fieldNum
    error([upper(mfilename),':wrongInput'],...
        'a number of splitted strings (%d) is too small for a specified position (%d)',...
        nFound,fieldNum);
end
%
resStr=strSplitList{fieldNum};