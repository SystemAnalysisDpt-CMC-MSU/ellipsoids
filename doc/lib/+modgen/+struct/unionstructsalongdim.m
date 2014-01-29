function NewStruct = unionstructsalongdim(catDimension, varargin)
% UNIONSTRUCTS unites structures with the same fields by concatenating the
% corresponding fields along the specified dimension
%
% Input:
%   regular:
%       catDimension: numeric[1,1] - dimension number along which the
%          concatenation is to be performed
%
%   optional:
%       struct1: struct[n1,n2,...,n_k]
%       ...
%       structN: struct[n1,n2,...,n_k]
%
%
% Output:
%   SRes: struct[n1,n2,...,n_k] - resulting structure
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%

isEmp=cellfun('isempty',varargin);
varargin=varargin(~isEmp);
nArg=numel(varargin);
switch nArg
    case 0
        NewStruct=struct;
    case 1
        NewStruct=varargin{1};
    otherwise
        NewStruct=varargin{1};
        for iArg=2:nArg
            NewStruct=binaryunionstruct(NewStruct,varargin{iArg},...
                @(x,y)cat(catDimension,x,y),@(x) x,@(x)x);
        end
end




