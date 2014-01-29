function SInput = patch_004_multiple_int_ell_apx_schemas(~,SInput)
STmp=SInput.ellipsoidalApxProps;
SInput=rmfield(SInput,'ellipsoidalApxProps');
SInput.ellipsoidalApxProps.internalApx.isEnabled=STmp.isInternalApxEnabled;
SInput.ellipsoidalApxProps.internalApx.schemas.sqrtQ.isEnabled=STmp.isInternalApxEnabled;
SInput.ellipsoidalApxProps.internalApx.schemas.sqrtQ.props=STmp.internalApxProps;
SInput.ellipsoidalApxProps.internalApx.schemas.justQ=...
    SInput.ellipsoidalApxProps.internalApx.schemas.sqrtQ;
SInput.ellipsoidalApxProps.internalApx.schemas.justQ.isEnabled=false;



