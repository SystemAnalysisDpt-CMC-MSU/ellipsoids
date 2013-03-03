function SInput = patch_018_remove_uncert_int_apx_schema(~,SInput)
if isfield(SInput.ellipsoidalApxProps.internalApx.schemas,'uncert')
    SInput.ellipsoidalApxProps.internalApx.schemas=rmfield(...
        SInput.ellipsoidalApxProps.internalApx.schemas,'uncert');
end