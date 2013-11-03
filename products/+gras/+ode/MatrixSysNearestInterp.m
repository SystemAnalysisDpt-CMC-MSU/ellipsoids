classdef MatrixSysNearestInterp < gras.ode.IMatrixSysInterp
    properties(Access=private)
        QArray
        MArray
        timeVec
    end
    
    methods
        function self = MatrixSysNearestInterp(QArray,MArray,timeVec)
            self.QArray = QArray;
            self.MArray = MArray;
            self.timeVec = timeVec;
        end
        function [QArray MArray] = evaluate(self,newTimeVec)
            import gras.ellapx.smartdb.F;
            import gras.ellapx.smartdb.rels.EllTubeBasic;
            nDims=size(self.QArray,1);
            nPoints=size(self.QArray,3);
            QArray = simpleInterp(self.QArray);
            MArray = simpleInterp(self.MArray);
            
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

