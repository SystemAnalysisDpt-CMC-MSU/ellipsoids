function SInput = patch_006_calc_precision(~,SInput)
STmp=SInput.ellipsoidalApxProps.internalApx;
STmp.schemas=rmfield(STmp.schemas,'sqrtQ');
STmp.schemas.justQ=rmfield(STmp.schemas.justQ,'props');
SInput.genericProps.calcPrecision=1e-4;



