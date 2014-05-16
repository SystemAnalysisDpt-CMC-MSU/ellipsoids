% This function returns the values of arguments, that specify the type of
% approximation that will be used to create an ellipsoid tube object. It
% will be a random type of approximation (Internal or External). These
% arguments can be used while creating an ellipsoid tube object containing
% one ellipsoid tube or several ellipsoid tubes with the same type of
% approximation.
%
function [approxSchemaDescr, approxSchemaName, approxType] = getSameApprox()
    type = randi(2,1);
    if type == 1
        approxSchemaDescr='Internal';
        approxSchemaName='Internal';
        approxType=gras.ellapx.enums.EApproxType.Internal;
    else
        approxSchemaDescr='External';
        approxSchemaName='External';
        approxType=gras.ellapx.enums.EApproxType.External;
    end
end