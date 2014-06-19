function SInput = patch_020_remove_is_static_prog_flag(~, SInput)
SInput.projectionProps=rmfield(SInput.projectionProps,'isStaticProjEnabled');