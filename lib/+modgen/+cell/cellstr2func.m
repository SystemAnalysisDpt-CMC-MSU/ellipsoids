function fHandle = cellstr2func(inpCMat,inpArgNameList)
% CELLSTR2EXPRESSION creates Matlab expression based on cell matrix of
% expressions corresponding to the individual elements of the matrix
%
% Input:
%   regular:
%       inpCMat: cell[nRows,nCols] of char[1,] - input matrix of
%           expressiosn
%       inpArgNameList: cell[1,nArgs] of char[1,]/char[1,] - names of input
%           arguments for the resulting function
% Output:
%   fHandle: function_handle[1,1] - resulting expression for the matrix
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-12-20 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
import modgen.cell.cellstr2expression;
import modgen.common.type.simple.checkcellofstr;
import modgen.string.catwithsep;
inpArgNameList=checkcellofstr(inpArgNameList);
funcPrefix=['@(',catwithsep(inpArgNameList,','),')'];
expStr=cellstr2expression(inpCMat);
fHandle=str2func([funcPrefix,'(',expStr,')']);