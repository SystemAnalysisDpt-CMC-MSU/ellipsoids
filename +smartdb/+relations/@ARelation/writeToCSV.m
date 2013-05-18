function writeToCSV(self,filePath)
% WRITETOCSV - writes a content of relation into Excel spreadsheet file
% Input:
%   regular:
%       self:
%       filePath: char[1,] - file path 
%   
% Output:
%   none
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-04-03 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
if ~(modgen.common.isrow(filePath)&&ischar(filePath))
    throwerror('wrongInput',...
        'filePath is expected to be a character string');
end
%
dataCell=[self.getFieldNameList;...
    self.toDispCell];
%
modgen.cell.csvwrite(filePath,dataCell);
    