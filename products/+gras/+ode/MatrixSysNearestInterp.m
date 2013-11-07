classdef MatrixSysNearestInterp < gras.ode.IMatrixSysInterp
    properties(Access=private)
        interpArray
        timeVec
    end
    
    methods
        function self = MatrixSysNearestInterp(sourceArray,timeVec)
            self.interpArray = sourceArray;
            self.timeVec = timeVec;
        end
        function interpArray = evaluate(self,newTimeVec)
            import gras.ellapx.smartdb.F;
            import gras.ellapx.smartdb.rels.EllTubeBasic;
            nDims=size(self.interpArray,1);
            nPoints=size(self.interpArray,3);
            interpArray = simpleInterp(self.interpArray);
            
            function interpArray=simpleInterp(inpArray,isVector)
                import gras.interp.MatrixInterpolantFactory;
                if nargin<2
                    isVector=false;
                end
                if isVector
                    nDims=size(inpArray,1);
                    nPoints=size(inpArray,2);
                    inpArray=reshape(inpArray,[nDims,1,nPoints]);
                end
                splineObj=MatrixInterpolantFactory.createInstance(...
                    'nearest',inpArray,self.timeVec);
                interpArray=splineObj.evaluate(newTimeVec);
                if isVector
                    interpArray=permute(interpArray,[1 3 2]);
                end
            end
        end
    end    
end

