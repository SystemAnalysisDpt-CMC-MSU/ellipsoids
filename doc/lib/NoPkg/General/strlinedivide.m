function res=strlinedivide(str)
% STRLINEDIVIDE - divide string to cell array of strings by line-feed
% character (code 10)
%
% Usage: res=strlinedivide(str)
%
% Input:
%   regular:
%     str: char - input string
% Output:
%   regular:
%     res: char cell array - output cell of strings
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
if (isempty(str)),
    res={''};
else
    res={};
    while ~isempty(str),
        [curStr,str]=strtok(str,10);
        res=[res;{curStr}];
    end
end