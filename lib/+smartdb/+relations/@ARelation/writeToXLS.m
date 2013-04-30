function fileName=writeToXLS(self,filePath)
% WRITETOXLS - writes a content of relation into Excel spreadsheet file
% Input:
%   regular:
%       self:
%       filePath: char[1,] - file path 
%   
% Output:
%   fileName: char[1,] - resulting file name, may not match with filePath
%       when Excel is not available and csv format is used instead
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-05-18 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import modgen.common.throwerror;
if ~(modgen.common.isrow(filePath)&&ischar(filePath))
    throwerror('wrongInput',...
        'filePath is expected to be a character string');
end
%
dataCell=[self.getFieldNameList;self.toDispCell()];
%
% Excel hangs on empty cell elements that has a size for certain dimensions
% more that 1, {ones(0,3)} would cause xlswrite to hang for instance
isEmptyMat=cellfun(@(x)isempty(x)&&isnumeric(x),dataCell);
dataCell(isEmptyMat)={[]};
[isSuccess,message,fileName]=modgen.microsoft.office.xlswrite(filePath,dataCell);
if ~isSuccess
    throw(message.exceptionObject);
end
    