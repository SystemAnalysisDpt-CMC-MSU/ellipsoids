function reverseCMat=varreplace(mCMat,tSum)
% VARREPLACE allows to solve the system set by
% cell matrix mCMat in the reverse time 
% by replacing of variable 't' for '(tSum - t)'
%
% Input:
% 	regular:
% 		mCMat: cell[nDims1,nDims2] -
%			cell matrix of system
%		tSum: double[1,1] - double variable
%			means the final moment of time
%
% Output:
%	reverseCMat: cell[nDims1,nDims2] -
%		cell matrix of system reflected 
%		about the value of tSum% 
$
$ $Author: Nikita Lukianenko  <old_pioneer_1@mail.ru> $	$Date: 2015-11-09 $
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
repStr=sprintf('(%d-t)',tSum);
regExpression='(^t\>|\<t\>|^t$|\<t$)';
reverseCMat=cellfun(@(X) regexprep(X,regExpression,repStr),...
	mCMat,'UniformOutput',false);