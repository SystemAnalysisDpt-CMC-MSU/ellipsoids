classdef IEllApxBuilder<handle
    methods (Abstract)
        ellTubeRel=getEllTubes(self)
        calcPrecision=getCalcPrecision(self)
        relTol=getRelTol(self)
    end
end
