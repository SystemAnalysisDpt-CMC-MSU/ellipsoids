function checkgenext(typeSpec,nPlaceHolders,varargin)
% CHECKGENEXT checks a generic condition provided by typeSpec string in the
% following format: 'isnumeric(x1)&&isa(x2,'int32')||isscalar(x2)' etc
% In case validation fails an exception is thrown
%
% Input:
%   regular:
%       typeSpec: char[1,]/function_handle - check string in
%           the folowing format: 'isnumeric(x)&&ischar(x)'
%                       OR
%           function_handle[1,1]
%       nPlaceHolders: numberic[1,1] - number of place holders/arguments in
%           typeSpec
%       
%       x1: anyType[]
%       x2: anyType[]
%       x3: anyType[]
%       
%   optional:
%       x1VarName: char[1,] - variable name - used optionally instead of
%           variable name determined auotmatically via inputname
%       x2VarName: char[1,] - same but for x2
%
% Example:
%
%   modgen.common.type.simple.checkgenext('numel(x1)==numel(x2)',2,a,b,'Alpha')
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-07-23 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
nArgs=nargin;
nVarNames=nArgs-2-nPlaceHolders;
nExtVars=nPlaceHolders-nVarNames;
varNameList=[varargin(nPlaceHolders+1:end),cell(1,nExtVars)];
for iVar=nVarNames+1:nPlaceHolders
    varNameList{iVar}=inputname(2+iVar);
end
modgen.common.checkmultvar(typeSpec,nPlaceHolders,...
    varargin{1:min(nPlaceHolders,nArgs)},...
    'varNameList',varNameList);
