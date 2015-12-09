classdef IEllApxBuilder<handle
    methods (Abstract)
        ellTubeRel=getEllTubes(self)
        absTol=getAbsTol(self)
        relTol=getRelTol(self)
    end
end
