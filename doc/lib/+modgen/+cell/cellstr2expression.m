function resStr = cellstr2expression(inpCMat)
% CELLSTR2EXPRESSION creates Matlab expression based on cell matrix of
% expressions corresponding to the individual elements of the matrix
%
% Input:
%   regular:
%       inpCMat: cell[nRows,nCols] of char[1,] - input matrix of
%           expressiosn
% Output:
%   resStr: char[1,] - resulting expression for the matrix
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-04-03 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
if ~ismatrix(inpCMat)
    modgen.common.throwerror('wrongInput',...
        'only 2 dimensional arrays are supported');
end
%
lineList=strcat(modgen.string.catcellstrwithsep(inpCMat,','),';');
resStr=[lineList{:}];
resStr=['[',resStr(1:end-1),']'];