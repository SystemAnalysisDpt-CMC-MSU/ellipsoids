function SInput = patch_001_split_calc_precision_into_absreltol(~,SInput)
SInput.genericProps.absTol=SInput.genericProps.calcPrecision*0.01;
SInput.genericProps.relTol=SInput.genericProps.calcPrecision;
SInput.genericProps=rmfield(SInput.genericProps,'calcPrecision');