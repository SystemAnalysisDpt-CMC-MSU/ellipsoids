function ellArr = fromStruct(SEllArr)

% fromStruct -- converts structure array into ellipsoid array.
%
% Input:
%   regular:
%       SEllArr: struct [nDim1, nDim2, ...] - array
%           of structures with the following fields:
%         
%       q: double[1, nEllDim] - the center of ellipsoid
%       Q: double[nEllDim, nEllDim] - the shape matrix of ellipsoid  
% Output:
%       ellArr: ellipsoid [nDim1, nDim2, ...] - ellipsoid array with size of 
%           SEllArr.
%
% Example:
% s = struct('Q', eye(2), 'a', [0 0]);
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
%     'a'    'double'    'Center'
% 
% Data: 
%    |    
%    |-- a : [0 0]
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
    if (isfield(SEll, 'absTol'))
        ell = ellipsoid(SEll.a.', SEll.Q, 'absTol', SEll.absTol, ...
                        'relTol', SEll.relTol, ...
                        'nPlot2dPoints', SEll.nPlot2dPoints, ...
                        'nPlot3dPoints', SEll.nPlot3dPoints);
    else
        ell = ellipsoid(SEll.a.', SEll.Q);
    end
end