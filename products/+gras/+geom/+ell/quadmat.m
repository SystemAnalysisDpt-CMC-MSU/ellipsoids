function res = quadmat(varargin)
% QUADMAT - calculates quadratic functions
%            (x-c,Q^{-1}(x-c)),(x-c,Q(x-c)),(x,Q^{-1}x),(x,Qx)
%
% Input:
%   regular:
%       qMat: double[nDim, nDim] - the square matrix itself
%       xVec: double[1, nDim] - x vector
%   optional:
%           cVec: double[1, nDim] - center vector,  if not specified - zero
%               is assumed
%           mode: char[1,] - regime specifier, can take the following values
%                   plain - use Q
%                   invadv - use Q^{-1} and calculate it using 
%                       gras.geom.ell.invmat function
%                   inv - use Q^{-1} but instead of calculating Q^{-1} 
%                       use the algorithm from getPolar
%
%   Output:
%           res: double[1,1] - result of calculation
%
[reg, ~] = modgen.common.parseparext(varargin, {},...
    [2 4], 'regDefList', {0, 0, 0, 'plain'},...
    'regCheckList', {'isnumeric(x)', 'isnumeric(x)', 'isnumeric(x)',...
    'any(ismember(lower(x), {''plain'', ''inv'', ''invadv''}))'});
qMat = reg{1};
xVec = reg{2};
cVec = reg{3};
calcMode = reg{4};
[qMatmElems, qMatnElems] = size(qMat);
[xVecmElems, xVecnElems] = size(xVec);
if cVec == 0
    cVec = zeros(xVecmElems, xVecnElems);
end
[cVecmElems, cVecnElems] = size(cVec);
if qMatmElems ~= qMatnElems
    modgen.common.throwerror('wrongInput', 'qMat must be square');
end
if (xVecmElems > 1) && (xVecnElems > 1)
    modgen.common.throwerror('wrongInput', 'xVec must be vector');
else
    if xVecmElems > 1
        xVec = xVec.';
        [~, xVecnElems] = size(xVec);
    end
end
if xVecnElems ~= qMatnElems
    modgen.common.throwerror('wrongInput',...
        'Dimensions of qMat and xVec must be coordinated');
end
if (cVecmElems > 1) && (cVecnElems > 1)
    modgen.common.throwerror('wrongInput', 'xVec must be vector');
else
    if cVecmElems > 1
        cVec = cVec.';
        [~, cVecnElems] = size(cVec);
    end
end
if cVecnElems ~= qMatnElems
    modgen.common.throwerror('wrongInput',...
        'Dimensions of qMat and cVec must be coordinated');
end
switch lower(calcMode)
    case 'plain'
        res = dot(xVec - cVec, qMat*(xVec - cVec).');
    case 'invadv'
        res = dot(xVec - cVec, gras.geom.ell.invmat(qMat)*(xVec - cVec).');
    case 'inv'
        res = (xVec - cVec) * (qMat\(xVec - cVec)');  
end
end