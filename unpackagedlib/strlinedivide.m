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
% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 12-October-2012, <pgagarinov@gmail.com>$
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