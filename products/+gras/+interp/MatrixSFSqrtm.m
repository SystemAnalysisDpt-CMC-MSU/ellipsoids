classdef MatrixSFSqrtm<gras.interp.IMatrixInterpolant
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-01-17$
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2012 $
    %    
    properties (Access=private)
        interpObj
    end
    methods
        function nDims=getDimensionality(self)
            nDims=self.interpObj.nDims;
        end
        function nCols=getNCols(self)
            nCols=self.interpObj.nCols;
        end
        function nRows=getNRows(self)
            nRows=self.interpObj.nRows;
        end        
        function self=MatrixSFSqrtm(interpObj)
            % MATRIXSFSQRTM represents a square root calculated based on
            % the input interpolant
            %
            % Input:
            %   regular:
            %       interpObj: gras.interp.IMatrixInterpolant[1,1]
            %           
            %
            self.interpObj=interpObj;
        end
        function mSize=getMatrixSize(self)
            mSize=size(self.interpObj.mSizeVec);
        end
        function resArray=evaluate(self,timeVec)
            import gras.gen.MatVector;
            resArray=self.interpObj.evaluate(timeVec);
            if numel(timeVec)>1
                resArray=gras.gen.SquareMatVector.evalMFunc(@sqrtm,...
                    resArray,'keepSize',true);
            else
                resArray=sqrtm(resArray);
            end
        end
    end
end