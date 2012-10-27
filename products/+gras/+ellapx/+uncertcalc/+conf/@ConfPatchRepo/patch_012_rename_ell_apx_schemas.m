function SInput = patch_012_rename_ell_apx_schemas(~,SInput)
SsqrtQ=SInput.ellipsoidalApxProps.internalApx.schemas.sqrtQ;
SjustQ=SInput.ellipsoidalApxProps.internalApx.schemas.justQ;
%
SInput.ellipsoidalApxProps.internalApx.schemas=rmfield(...
    SInput.ellipsoidalApxProps.internalApx.schemas,{'justQ','sqrtQ'});
%
SInput.ellipsoidalApxProps.internalApx.schemas.noUncertSqrtQ=SsqrtQ;
SInput.ellipsoidalApxProps.internalApx.schemas.noUncertJustQ=SjustQ;
SInput.ellipsoidalApxProps.internalApx.schemas.uncert=SjustQ;
%