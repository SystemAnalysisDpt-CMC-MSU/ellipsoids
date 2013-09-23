function rgbVec = colorcode2rgb(colorCode)
%     COLORCODE2RGB - translates to RGB color codes.
% Input:
%     regular:
%         colorCode: char[1,1] - color code.  
%
% Output:
%     rgbVec: double[1,3] - RGB color code.
%
%
% $Author: <Sergei Drozhzhin>  <SeregaDrozh@gmail.com> $    $Date: <21 September 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $


    
    if ~(ischar(colorCode))
        rgbVec = [0 0 0];
        return;
    end
    
    if (numel(colorCode) >= 2 || numel(colorCode)==0)
        rgbVec = [0 0 0];
        return
    end
    
    if (  ~((colorCode == 'r') || (colorCode == 'g') || (colorCode == 'b')...
            || (colorCode == 'y') || (colorCode == 'c') || (colorCode == 'm') || (colorCode == 'w')) )
        rgbVec = [0 0 0];
        return
    end

    rgbVec = rem(floor((strfind('kbgcrmyw', colorCode) - 1) * [0.25 0.5 1]),2);
   

 end

