classdef MatrixSysReshapeOde45RegInterp
    properties(Access=private)
        VecOde45RegInterpObj
        sizeEqList
        fSolveFunc
        nEquations
        indEqList
        indOutArgStartVec
        nFuncs
    end
    methods
        function interpObj = MatrixSysReshapeOde45RegInterp(...
                VecOde45RegInterpObj,sizeEqList,fSolveFunc,nEquations,...
                indEqList,indOutArgStartVec,nFuncs)
            
                % don't forget parse parameters 
            interpObj.VecOde45RegInterpObj = VecOde45RegInterpObj;
            interpObj.sizeEqList = sizeEqList;
            interpObj.fSolveFunc = fSolveFunc;
            interpObj.nEquations = nEquations;
            interpObj.indEqList = indEqList;
            interpObj.indOutArgStartVec = indOutArgStartVec;
            interpObj.nFuncs = nFuncs;
        end
        
        function [timeVec,varargout] = evaluate(self,timeVec)
            resList = cell(1,self.nFuncs);
            [timeVec,resList{:}] = ...
                self.VecOde45RegInterpObj.evaluate(timeVec);
            nTimePoints = length(timeVec);
            for iFunc = 1:self.nFuncs
                indShift=(iFunc-1)*self.nEquations;
                for iEq=1:self.nEquations
                    varargout{indShift+iEq}=reshape(...
                        transpose(resList{iFunc}(:,self.indEqList{iEq})),...
                        [self.sizeEqList{iEq} nTimePoints]);
                end
            end
            
        end
        
    end
end