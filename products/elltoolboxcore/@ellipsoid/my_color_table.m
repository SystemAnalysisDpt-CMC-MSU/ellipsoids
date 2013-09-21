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

codeVec = elltool.plot.colorcode2rgb(colorChar);