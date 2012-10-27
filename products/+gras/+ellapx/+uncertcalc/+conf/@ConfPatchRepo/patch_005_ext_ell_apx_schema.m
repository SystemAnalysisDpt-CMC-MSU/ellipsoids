function SInput = patch_005_ext_ell_apx_schema(~,SInput)
STmp=SInput.ellipsoidalApxProps.internalApx;
STmp.schemas=rmfield(STmp.schemas,'sqrtQ');
STmp.schemas.justQ=rmfield(STmp.schemas.justQ,'props');
SInput.ellipsoidalApxProps.externalApx=STmp;



