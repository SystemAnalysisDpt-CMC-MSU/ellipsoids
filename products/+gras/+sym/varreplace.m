function reverseCMat=varreplace(mCMat,fromVarName,toVarName)
% VARREPLACE allows to solve the system set by
% cell matrix mCMat in the reverse time 
% by replacing of variable fromVarName to toVarName
%
% Input:
% 	regular:
% 		mCMat: cell[nDims1,nDims2] -
% 			cell matrix of system
%       fromVarName: variable that we want to be replaced
%       toVarName: expression that we get instead of variable fromVarName
%
% Output:
% 	reverseCMat: cell[nDims1,nDims2] -
% 		cell matrix of system reflected 
% 		about the expression toVarName
%
%
% $Author: Nikolay Trusov  <trunick.10.96@gmail.com> $	$Date: 2017-12-11 $
% $Copyright: Moscow State University,
% 			Faculty of Computational Mathematics and Computer Science,
% 			System Analysis Department 2017 $
%
%
regExpression = strcat('(^',fromVarName);
regExpression = strcat(regExpression,'\>|\<');
regExpression = strcat(regExpression,fromVarName);
regExpression = strcat(regExpression,'\>|^');
regExpression = strcat(regExpression,fromVarName);
regExpression = strcat(regExpression,'$|\<');
regExpression = strcat(regExpression,fromVarName);
regExpression = strcat(regExpression,'$)');
repStr = strcat('(',toVarName);
repStr = strcat(repStr,')');

reverseCMat = cellfun(@(X) regexprep(X,regExpression,repStr), mCMat,'UniformOutput',false);




