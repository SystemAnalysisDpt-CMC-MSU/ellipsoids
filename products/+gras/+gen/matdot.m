function resArr = matdot(inpArr1, inpArr2)
% MATDOT calculates the dot product of two square matrices, which have
% the same size.
%
% Input:
%     regular:
%         inpArr1: double[nMatDim,nMatDim,nElemsDim1...,nElemsDimK]
%         inpArr2: double[nMatDim,nMatDim,nElemsDim1...,nElemsDimK]
%
% Output:
%         resArr: double[1,1,nElemsDim1,...,nElemsDimk] - dot production values
%
%
%
% $Authors: Yuri Admiralsky  <swige.ide@gmail.com> $	$Date: 2013-05$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
    import modgen.common.throwerror;
    %
    sizeVec = size(inpArr1);
    if any(sizeVec ~= size(inpArr2))
        throwerror('wrongInput:differentSize', ...
            'input matrices have the different size');
    end
    if sizeVec(1) ~= sizeVec(2)
        throwerror('wrongInput:notSquare', ...
            'input matrices aren''t square matrices or square matrix arrays');
    end
    nMatDim = sizeVec(1);
    resArr = sum(dot(inpArr1, inpArr2, 2), 1);
    resArr = resArr / nMatDim;
end

