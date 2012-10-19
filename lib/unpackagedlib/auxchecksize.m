function isValid=auxchecksize(varargin)
%
% AUXCHECKSIZE checks sizes of arrays;
%
% Usage isValid=auxchecksize(arr1,arr2,arr3,siz);
% input:
%   regular:
%       arr1: array
%       ......
%       arrN: array
%       size: double[1,nDims] - mask for check of size;
%
% output:
%   regular:
%       isValid: logical[1] - true if all arrays is proper with
%                   mask;
%
% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 12-October-2012, <pgagarinov@gmail.com>$

isValid=isvalidsize(varargin{:});
isValid=all(isValid(:));
