function ellArr = fromStruct(SEllArr)

% fromStruct -- converts structure array into ellipsoid array.
%
% Input:
%   Case 1:
%       regular:
%           SEllArr: struct [nDim1, nDim2, ...] - array
%               of structures with the following fields:
%
%           centerVec: double[1, nEllDim] - the center of ellipsoid
%           shapeMat: double[nEllDim, nEllDim] - the shape matrix of
%               ellipsoid
%
%   Case 2:
%       regular:
%           SEllArr: struct [nDim1, nDim2, ...] - array
%               of structures with the following fields:
%
%           centerVec: double[1, nEllDim] - the center of ellipsoid
%           diagMat: double[nEllDim, nEllDim] - the diagonal matrix of
%               eigenvalues
%           eigvMat: double[nEllDum, nEllDim] - the matrix of eigenvectors
%          
%
%   
%
% Output:
%       ellArr: ellipsoid [nDim1, nDim2, ...] - ellipsoid array with size of
%           SEllArr.
%
% Example:
% s = struct('Q', eye(2), 'q', [0 0]);
% ellipsoid.fromStruct(s)
%
% -------ellipsoid object-------
% Properties:
%    |
%    |-- actualClass : 'ellipsoid'
%    |--------- size : [1, 1]
%
% Fields (name, type, description):
%     'Q'    'double'    'Configuration matrix'
%     'q'    'double'    'Center'
%
% Data:
%    |
%    |-- q : [0 0]
%    |       -----
%    |-- Q : |1|0|
%    |       |0|1|
%    |       -----
%
% $Author: Alexander Karev <Alexander.Karev.30@gmail.com>
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2013 $

for iEll = numel(SEllArr) : -1 : 1
    ellArr(iEll) = struct2Ell(SEllArr(iEll));
end
ellArr = reshape(ellArr, size(SEllArr));
end

function ell = struct2Ell(SEll)
if isfield(SEll, 'shapeMat')
    [eigvMat, diagMat] = eig(SEll.shapeMat);
else
    diagMat = SEll.diagMat;
    eigvMat = SEll.eigvMat;
end
if (isfield(SEll, 'absTol'))
    SProp = rmfield(SEll, {'diagMat', 'eigvMat', 'centerVec'});
    propNameValueCMat = [fieldnames(SProp), struct2cell(SProp)].';
    ell = elltool.core.GenEllipsoid(SEll.centerVec.', diagMat, eigvMat, propNameValueCMat{:});
else
    ell = elltool.core.GenEllipsoid(SEll.centerVec.', diagMat, eigvMat);
end
end