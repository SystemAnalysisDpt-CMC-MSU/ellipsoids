function resArr = sqrtpos(inpArr, absTol)
% SQRTPOS calculates the square root of positive value assuming that the
% input value is specified with certain precision
% Input:
%     regular:
%         inpVal: double[nElemsDim1,nElemsDim2,...,nElemsDimk]
%         absTol: double[1, 1] - tolerance for eigenvalues
%
% Output:
%   resArr: double[nElemsDim1,nElemsDim2,...,nElemsDimk] - square root
%       values
%
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2013-04-17$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
import modgen.common.throwerror;
%
if nargin<2
    absTol = 0;
elseif absTol<0
    throwerror('wrongInput:absTolNegative',...
        'absTol is expected to be not-negative');
end
%
if isscalar(inpArr)
    if inpArr<-absTol
        throwerror('wrongInput:negativeInput',...
            'input value is under -absTol');
    elseif inpArr<0
        inpArr=0;
    end
    resArr=realsqrt(inpArr);
else
    if any(inpArr(:) < -absTol)
        throwerror('wrongInput:negativeInput',...
            'input array contains values under -absTol');
    end
    inpArr(inpArr<0)=0;
    resArr = realsqrt(inpArr);
end
