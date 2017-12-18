function resCMat=varreplace(mCMat,fromVarName,toVarName)
% VARREPLACE allows to change an independent variable to some 
% expression in a cell matrix mCMat containing a bunch of expressions
% by replacing of variable fromVarName to toVarName
%
% Input:
% 	regular:
% 		mCMat: cell[nDims1,nDims2] -
%          cell matrix of expressions; each cell may be either a number,
%          a char string or a symbolic expression (the latter in the case
%          when Symbolic Toolbox is installed); it should be noted that 
%          numbers are transformed into strings using 20 signs after 
%          the decimal point to preserve accuracy, so the result may look
%          a bit confused
%       fromVarName: variable that we want to be replaced
%       toVarName: expression that we get instead of variable fromVarName
%
% Output:
% 	resCMat: char cell[nDims1,nDims2] -
% 		cell matrix of expressions after the made changes
% Example:
%   resCMat = varreplace({'3.2',   't + 3.2';...
%                          9.8,     -34;...
%                         'sin(t)', 1.9},'t','(0.81-t)')
%
% resCMat = {'3.2',                   '(0.81-t)+3.2';...
%            '9.8000000000000007105', '-34';...
%            'sin((0.81-t))',         '1.8999999999999999112'}
%
%
% $Author: Nikolay Trusov  <trunick.10.96@gmail.com>$	$Date: 2017-12-18$
% $Copyright: Moscow State University,
% 			Faculty of Computational Mathematics and Computer Science,
% 			System Analysis Department 2017$
%
%

if(nargin ~= 3)
    modgen.common.throwerror('wrongInput',...
        'Not Enough Arguments to call the function varreplace');
end

modgen.common.checkvar(mCMat,'~isempty(x)&&iscell(x)',...
    'errorTag','wrongInput','errorMessage','mCMat must not be empty');
modgen.common.checkvar(fromVarName,'ischar(x)',...
    'errorTag','wrongInput','errorMessage',...
    'fromVarName is expected to be a string');
modgen.common.checkvar(toVarName,'ischar(x)',...
    'errorTag','wrongInput','errorMessage',...
    'toVarName is expected to be a string');


isSymMat = cellfun(@(x)isa(x,'sym'),mCMat);
mCMat(isSymMat) = cellfun(@char,mCMat(isSymMat),'UniformOutput',false);
isnCharMat = ~cellfun('isclass',mCMat,'char');
mCMat(isnCharMat)=cellfun(@(x)num2str(x,20),mCMat(isnCharMat),... 
    'UniformOutput',false);
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

resCMat = cellfun(@(X) regexprep(X,regExpression,repStr),...
    mCMat,'UniformOutput',false);



