function SInput = patch_019_add_reg_props(~, SInput)
SInput.regularizationProps.isEnabled = false;
SInput.regularizationProps.regTol = 1e-8;