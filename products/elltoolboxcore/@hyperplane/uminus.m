function outHypArr = uminus(inpHypArr)
%
% UMINUS - switch signs of normal vector and the shift scalar
%          to the opposite.
%
% Input:
%   regular:
%       inpHypArr: hyperplane [nDims1, nDims2, ...] - array
%           of hyperplanes.
%
% Output:
%   outHypArr: hyperplane [nDims1, nDims2, ...] - array
%       of the same hyperplanes as in inpHypArr whose
%       normals and scalars are multiplied by -1.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Aushkap Nikolay <n.aushkap@gmail.com> $  $Date: 30-11-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $

modgen.common.checkvar(inpHypArr, 'isa(x,''hyperplane'')',...
    'errorTag', 'wrongInput',...
    'errorMessage', 'UMINUS: input argument must be hyperplanes.');

sizeVec = size(inpHypArr);
hypCellArr = arrayfun(@(x) hyperplane(-x.normal, -x.shift), inpHypArr,...
    'UniformOutput',false);

outHypArr = reshape([hypCellArr{:}], sizeVec);
