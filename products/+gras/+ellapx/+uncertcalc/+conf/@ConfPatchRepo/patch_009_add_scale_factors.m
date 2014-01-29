function SInput = patch_009_add_scale_factors(~,SInput)
SInput.ellipsoidalApxProps.internalApx.scaleFactor=0.98;
SInput.ellipsoidalApxProps.externalApx.scaleFactor=1.02;