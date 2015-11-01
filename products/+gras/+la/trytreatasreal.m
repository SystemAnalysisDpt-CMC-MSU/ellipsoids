function resMat = trytreatasreal( inpMat, tolVal )
%trytreatasreal check if inpMat is real - if positive - resMat = inpMat,
%else - calculate an imaginary part of inpMat and compare its norm(x,Inf)
%with tolVal.
%If our norm < tolVal then we thrown away imaginary part of inpMat.
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2015 $

import modgen.common.throwerror;
if nargin < 2
    tolVal = eps;
end
%
if (isreal(inpMat))
    resMat = inpMat;
else
    imagInpMat=imag (inpMat);
    normValue = norm (imagInpMat, Inf);
    if (normValue < tolVal)
        resMat = real(inpMat);
    else
        throwerror('wrongInput:inpMat',...
        'Sourse object can not have large imaginary part');
    end
end
end

