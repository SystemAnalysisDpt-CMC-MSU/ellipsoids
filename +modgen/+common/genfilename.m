function fileName = genfilename(inpStr)
%GENFILENAME generates a valid file name based on a given string
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-12-31 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
ILLEGAL_CHARACTER_LIST = { '/', '\n', '\r', '\t', '\f', '`', '?', '*', '\\', '<', '>', '|', '\"', ':' };
illegalCharList=cellfun(@sprintf,ILLEGAL_CHARACTER_LIST,'UniformOutput',false);
isBadCVec=cellfun(@(x)(inpStr==x),illegalCharList,'UniformOutput',false);
isBadMat=vertcat(isBadCVec{:});
isBadVec=any(isBadMat,1);
fileName=inpStr;
fileName(isBadVec)='_';