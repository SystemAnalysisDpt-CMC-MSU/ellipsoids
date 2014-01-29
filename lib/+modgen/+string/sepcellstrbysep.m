function outCMat = sepcellstrbysep(inpCVec,sepStr)
% SEPCELLSTRBYSEP splits elements of input cell column vector of strings
% using a specified separator and returns result as a cell matrix of
% strings, it is assumes that each element is splitted to an equal number
% of parts
%
% Input:
%   regular:
%       inpCMat: cell[nRows,1] of char[1,] - cell vector of strings
%       sepStr: char[1,] - separator
%
% Output:
%   outCMat: cell[nRows,nCols] of char[1,] - cell matrix of strings
%       
% Note: this function is an inversion of catcellstrwithsep
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-06-05 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
outCVec=cellfun(@(x)strsplit(x,sepStr),inpCVec,'UniformOutput',false);
outCMat=vertcat(outCVec{:});
