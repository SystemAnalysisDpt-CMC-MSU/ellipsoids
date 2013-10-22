classdef MatrixSysODERegInterpSolver < gras.ode.MatrixSysODESolver
    methods
        function self=MatrixSysODERegInterpSolver(varargin)
            self = self@gras.ode.MatrixSysODESolver(varargin{:});
        end
        function [timeVec,varargout]=solve(self,fDerivFuncList,timeVec,...
                varargin)
            nFuncs = length(fDerivFuncList);
            % if nFuncs = 1, then objVecOde45RegInterp not return
            nOuts = length(self.sizeEqList)*nFuncs;
            resList = cell(1,nOuts);
            resAdvList = cell(1,nFuncs-1);
            [timeVec,resList{:},resAdvList{:}] = solve@gras.ode.MatrixSysODESolver(...
                self,fDerivFuncList,timeVec,varargin{:});
            varargout = [resList ...
                {gras.ode.MatrixSysReshapeOde45RegInterp(...
                resAdvList{:},self.sizeEqList,nFuncs)}];               
        end
    end
end