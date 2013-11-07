classdef MatrixODE45InterpFunc
    properties(Access=private)
        objMatrixSysReshapeOde45RegInterp
    end
    methods
        function self = MatrixODE45InterpFunc(interpObj)
            self.objMatrixSysReshapeOde45RegInterp = interpObj;
        end
        function [timeVec,varargout] = evaluate(self,timeVec)
            resList = cell(1,nargout-1);
            [timeVec,resList{:}] = ...
             self.objMatrixSysReshapeOde45RegInterp.evaluate(timeVec);
         varargout = resList;
        end
    end
    
end

