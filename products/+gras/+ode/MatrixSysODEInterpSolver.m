classdef MatrixSysODEInterpSolver < gras.ode.MatrixSysODESolver
    methods
        function self=MatrixSysODEInterpSolver(varargin)
            self = self@gras.ode.MatrixSysODESolver(varargin{:});
        end
        function [timeVec,varargout]=solve(self,fDerivFuncList,timeVec,...
                varargin)
            lengthRes = length(self.sizeEqList)*...
                    length(fDerivFuncList) + 2;
            resList = cell(1,lengthRes);
            [timeVec,resList{:}] = solve@gras.ode.MatrixSysODESolver(...
                self,fDerivFuncList,timeVec,varargin{:});
            objMatrixSysReshapeOde45RegInterp = ...
                gras.ode.MatrixSysReshapeOde45RegInterp(...
                resList{lengthRes - 1},self.sizeEqList,resList{lengthRes});
            varargout = resList(1:(lengthRes-2));
            varargout = [varargout {objMatrixSysReshapeOde45RegInterp}];
        end
    end
end