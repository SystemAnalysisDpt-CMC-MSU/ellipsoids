classdef MatrixSysNearestInterp < gras.ode.IMatrixSysInterp
    properties(Access=private)
        QArray
        QMArray
    end
    
    methods
        function self = MatrixSysNearestInterp(QArray,QMArray,timeVec)
            self.QArray = MatrixNearestInterp(QArray,timeVec);
            self.QMArray = MatrixNearestInterp(QMArray,timeVec);
        end
        function [QArray QMArray] = evaluate(self,newTimeVec)
            QArray = self.QArray.evaluate(newTimeVec);
            QMArray = self.QMArray.evaluate(newTimeVec);
        end
    end
end

