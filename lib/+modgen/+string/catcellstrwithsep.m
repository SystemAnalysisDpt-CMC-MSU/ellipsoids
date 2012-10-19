function outCVec = catcellstrwithsep(inpCMat,sepStr)
% CATCELLSTRWITHSEP contatenates columns of input cell matrix of strings
% using a specified separator and returns result as a column cell vector of
% strings
%
% Input:
%   regular:
%       inpCMat: cell[nRows,nCols] of char[1,] - cell matrix of strings
%       sepStr: char[1,] - separator
%
% Output:
%   outCVec: cell[nRows,1] of char[1,] - cell vector of strings
%       
% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$
%
import modgen.string.catwithsep;
nRows=size(inpCMat,1);
nCols=size(inpCMat,2);
outCVec=cellfun(@(x)catwithsep(x,sepStr),...
    mat2cell(inpCMat,ones(nRows,1),nCols),'UniformOutput',false);

