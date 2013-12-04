classdef ObjectApproxControlParams
    properties (Constant=true)
        nAddTopElems=32;
        errorCheckMode=1.e-3;
        approxPrec=1;
        freeMemoryMode=0;
        discardIneqMode=1;
        incDim=0;
        faceDist=.9e-5;
        inApproxDist=1.e-4;
        ApproxDist=1.e-5;
        precTest=1.e-4;
        relPrec=1.e-5;
        inftyDef=1.e6;
        isVerbose=0;
    end
    methods
        function defaultValMat=getValues(self)
            defaultValMat=[self.nAddTopElems self.errorCheckMode ...
                self.approxPrec self.freeMemoryMode self.discardIneqMode...
                self.incDim self.faceDist self.inApproxDist...
                self.ApproxDist self.precTest self.relPrec...
                self.inftyDef self.isVerbose];
        end
    end
end