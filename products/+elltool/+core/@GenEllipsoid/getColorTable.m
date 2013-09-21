function codeVec = getColorTable(colorChar)
%
% colorTable - returns the code of the color
%              defined by single letter.
% 
% $Author: Vadim Kaushanskiy <vkaushanskiy@gmail.com> $	$Date: 2012-12-24 $ 
% $Copyright: Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
codeVec = elltool.plot.colorcode2rgb(colorChar);
