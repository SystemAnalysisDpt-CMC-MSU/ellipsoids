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
% $Author: Nikolay Trusov  <trunick.10.96@gmail.com>$	$Date: 2017-12-16$
% $Copyright: Moscow State University,
% 			Faculty of Computational Mathematics and Computer Science,
% 			System Analysis Department 2017$
%
%

if(nargin ~= 3)
    modgen.common.throwerror('wrongInput',...
        'Not Enough Arguments to call the function varreplace');
elseif (isempty(mCMat))
    modgen.common.throwerror('wrongInput',...
        'mCMat must not be empty');
elseif (~ischar(fromVarName))
    modgen.common.throwerror('wrongInput',...
        'fromVarName is expected to be a string');
elseif (~ischar(toVarName))
    modgen.common.throwerror('wrongInput',...
        'toVarName is expected to be a string');
else
    isSymMat = cellfun(@(x)isa(x,'sym'),mCMat);
    mCMat(isSymMat) = cellfun(@char,mCMat(isSymMat),'UniformOutput',false);
    isnCharMat = ~cellfun('isclass',mCMat,'char');
    mCMat(isnCharMat)=cellfun(@(x)num2str(x),mCMat(isnCharMat),'UniformOutput',false);
    mCMat = strrep(mCMat,' ','');
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
end



