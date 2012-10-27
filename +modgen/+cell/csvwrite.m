function csvwrite(fileName,dataCMat)
% CSVWRITE writes a specified cell array into a comma-separated file
% specified by name
%
% Input:
%   regular:
%       fileName: char[1,] - name of the destination file 
%       dataCMat: cell[nRows,nCols] - cell array containing numberic and
%          character data
%   
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
modgen.cell.cell2csv(fileName,dataCMat,';',2007);