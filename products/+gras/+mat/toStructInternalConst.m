function [SDataArr, SFieldNiceNames, SFieldDescr] = ...
    toStructInternalConst(matrix, isPropIncluded)

if (nargin < 2)
    isPropIncluded = false;
end

SEll = struct('matrix', matrix);
if (isPropIncluded)
        SEll.absTol = gras.mat.AMatrixFunctionComparable.getAbsTol();
        SEll.relTol = gras.mat.AMatrixFunctionComparable.getRelTol();
end

SDataArr = SEll;
SFieldNiceNames = struct('matrix','M');
SFieldDescr = struct('matrix','Matrix');

if (isPropIncluded)
    SFieldNiceNames.absTol = 'absTol';
    SFieldNiceNames.relTol = 'relTol';  
    
    SFieldDescr.absTol = 'Absolute tolerance.';
    SFieldDescr.relTol = 'Relative tolerance.';
end

end
