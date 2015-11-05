function resMat = trytreatasreal( inpMat, tolVal )
%TRYTREATASREAL check if inpMat is real thnen resMat = inpMat
%else calculate an imaginary part of inpMat and compare its norm(x,Inf)
%with tolVal.
%If our norm < tolVal then we thrown away imaginary part of inpMat else
%we throw exeption with identifier = 'wrongInput:inpMat'.
%
%Input:
%   regular:
%       inpMat: double [nElems, mElems] - real matrix or matrix with small
%           imaginaty part.
%
%   optional:
%       tolVal: double [1,1] - tolerance with default value eps.
%
%Output:
%   regular: 
%       resMat: double [nElems, mElems] - real matrix.
%
% $Author: Ilia Shirokikh <shirokikh.ilia@gmail.com>$ $Date: 2015-11-05$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2015 $
import modgen.common.throwerror;
if nargin < 2
    tolVal = eps;
elseif ~(isnumeric(tolVal)&&isscalar(tolVal)&&(tolVal > 0))
    throwerror('wrongInput:tolVal', ...
        'tolVal must be a positive numeric scalar');
end
%
if isreal(inpMat)
    resMat = inpMat;
else
    imagInpMat=imag (inpMat);
    normValue = norm (imagInpMat,Inf);
    if (normValue < tolVal)
        resMat = real(inpMat);
    else
        outVec = ['Norm of imaginary part of sourse object = ' ...
            num2str(normValue) '. It can not be more than tolVal = ' ...
            num2str(tolVal)];
        throwerror('wrongInput:inpMat',outVec);
    end
end
end

