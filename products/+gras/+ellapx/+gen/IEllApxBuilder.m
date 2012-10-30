classdef IEllApxBuilder<handle
    methods (Abstract)
        ellTubeRel=getEllTubes(self)
        calcPrecision=getCalcPrecision(self)
    end
end
