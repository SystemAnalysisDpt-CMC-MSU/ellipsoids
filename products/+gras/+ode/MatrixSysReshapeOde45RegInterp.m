classdef MatrixSysReshapeOde45RegInterp
    properties(Access=public)
        VecOde45RegInterpObj
        sizeEqList
        nFuncs
    end
    methods
        function interpObj = MatrixSysReshapeOde45RegInterp(...
                VecOde45RegInterpObj,sizeEqList,nFuncs)
            
                % don't forget parse parameters 
            interpObj.VecOde45RegInterpObj = VecOde45RegInterpObj;
            interpObj.sizeEqList = sizeEqList;
            interpObj.nFuncs = nFuncs;
        end
        
        function [timeVec,varargout] = evaluate(self,timeVec)
            resList = cell(1,self.nFuncs);
            [timeVec,resList{:}] = ...
                self.VecOde45RegInterpObj.evaluate(timeVec);
            nTimePoints = length(timeVec);
            nEquations = length(self.sizeEqList);
            nElemVec=cellfun(@prod,self.sizeEqList);
            nElemCumVec=cumsum(nElemVec);
            indEqList=cellfun(@(x,y)x:y,...
                num2cell(ones(1,nEquations)+[0,nElemCumVec(1:end-1)]),...
                num2cell(nElemCumVec),'UniformOutput',false);
            for iFunc = 1:self.nFuncs
                indShift=(iFunc-1)*nEquations;
                for iEq=1:nEquations
                    varargout{indShift+iEq}=reshape(...
                        transpose(resList{iFunc}(:,indEqList{iEq})),...
                        [self.sizeEqList{iEq} nTimePoints]);
                end
            end
            
        end
        
    end
end