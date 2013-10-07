function SInput = patch_005_parallel(~, SInput)
 SInput.parallelCompProps = struct;
 SInput.parallelCompProps.nMaxParProcess=1;
end