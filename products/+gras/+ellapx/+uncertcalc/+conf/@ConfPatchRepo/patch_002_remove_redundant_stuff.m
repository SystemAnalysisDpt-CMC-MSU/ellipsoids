function SInput = patch_002_remove_redundant_stuff(~,SInput)
if isfield(SInput.op_iap.op_par,'pvec');
    SInput.op_iap.op_par.goodDirSpace=SInput.op_iap.op_par.pvec;
    SInput.op_iap.op_par=rmfield(SInput.op_iap.op_par,'pvec');
    SInput.op_iap.op_proj.op_set.op_gen=rmfield(...
        SInput.op_iap.op_proj.op_set.op_gen,'ftype');
end
SInput.op_iap.op_proj.op_dset.op_gen =SInput.op_iap.op_proj.op_set.op_gen;

