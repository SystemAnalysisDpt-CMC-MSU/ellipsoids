function codeVec = getColorTable(colorChar)
%
% colorTable - returns the code of the color
%              defined by single letter.
%
if ~(ischar(colorChar))
    codeVec = [0 0 0];
    return;
end

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
