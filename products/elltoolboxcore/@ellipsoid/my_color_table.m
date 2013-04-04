function codeVec = my_color_table(colorChar)
%
% MY_COLOR_TABLE - returns the code of the color
%                  defined by single letter.
%
% Input:
%   regular:
%       colorChar: char[1, 1] - letter defining color.
%
% Output:
%   codeVec: double [1, 3] - code of the color.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California
%              2004-2008 $

if ~(ischar(colorChar))
    codeVec = [0 0 0];
else    
    switch colorChar
        case 'r',
            codeVec = [1 0 0];
            
        case 'g',
            codeVec = [0 1 0];
            
        case 'b',
            codeVec = [0 0 1];
            
        case 'y',
            codeVec = [1 1 0];
            
        case 'c',
            codeVec = [0 1 1];
            
        case 'm',
            codeVec = [1 0 1];
            
        case 'w',
            codeVec = [1 1 1];
            
        otherwise,
            codeVec = [0 0 0];
    end
end