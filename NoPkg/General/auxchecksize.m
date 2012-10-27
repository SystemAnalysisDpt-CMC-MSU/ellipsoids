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
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%

isValid=isvalidsize(varargin{:});
isValid=all(isValid(:));