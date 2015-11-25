function isDependent=isdependent(mCMat,isDiscrete)
% ISDEPENDENT allows to check system set by cell 
% matrix mCMat which can be discrete or conitinious
% (depends on value of parameter isDiscrete) on
% dependency from variables 'k' in discrete
% case and 't' in continious one
%
% Input:
% 	regular:
% 		mCMat: cell[nDims1,nDims2] - 
% 		cell matrix of system
%
% 	optional:
% 		isDiscrete: logical[1,1] - logical variable
% 			which equals 1 in case of discrete system
% 			and equals 0 in case of continious system
%
% Output:
% 	isOk: logical[nDims1,nDims2] - logical variable
% 			which equals 1 in case of dependency of system
% 			from variable 't or 'k' and equals 0 in case of 
% 			undependency
%
%
% $Author: Nikita Lukianenko  <old_pioneer_1@mail.ru> $	$Date: 2015-11-10 $
% $Copyright: Moscow State University,
% 			Faculty of Computational Mathematics and Computer Science,
% 			System Analysis Department 2015 $
%
%
if nargin < 2
	isDiscrete = false;
end
%
if isDiscrete
	regExpression='(^k\>|\<k\>|^k$|\<k$)';
else
	regExpression='(^t\>|\<t\>|^t$|\<t$)';
end
%
isDependent=isempty(cell2mat(regexp(mCMat,regExpression,'once')));