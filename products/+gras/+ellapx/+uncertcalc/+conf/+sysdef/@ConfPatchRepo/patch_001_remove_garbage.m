function SInput = patch_001_remove_garbage(~,SInput)
if isfield(SInput,'dim_max')
    SInput=rmfield(SInput,'dim_max');
end
if isfield(SInput,'cdim_max')
    SInput=rmfield(SInput,'cdim_max');
end
if isfield(SInput,'cdim')
    SInput=rmfield(SInput,'cdim');
end