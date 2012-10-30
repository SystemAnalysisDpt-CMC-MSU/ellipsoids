function SInput = patch_002_add_description(~,SInput)
SInput.description=' ';
dim=SInput.dim;
%
SInput.disturbance_restriction.Q=cellfun(@num2str,...
    num2cell(eye(dim)),'UniformOutput',false);
SInput.disturbance_restriction.a=repmat({'0'},[dim 1]);
%
SInput.Ct=cellfun(@num2str,num2cell(zeros(dim)),'UniformOutput',false);