function SInput = patch_001_make_proj_spec_logical(~,SInput)
SInput=update(SInput,'op_iap');
end
function SInput=update(SInput,apxTypeField)
SInput.(apxTypeField).op_proj.op_uset.op_gen.data_p=cellfun(@logical,...
    SInput.(apxTypeField).op_proj.op_uset.op_gen.data_p,'UniformOutput',false);
SInput.(apxTypeField).op_proj.op_set.op_gen.data_p=cellfun(@logical,...
    SInput.(apxTypeField).op_proj.op_set.op_gen.data_p,'UniformOutput',false);
SInput.(apxTypeField).op_par.pvec=logical(SInput.(apxTypeField).op_par.pvec);
end
