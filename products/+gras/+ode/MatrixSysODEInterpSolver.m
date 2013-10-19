classdef MatrixSysODEInterpSolver < gras.ode.MatrixSysODESolver
    methods
        function self=MatrixSysODEInterpSolver(varargin)
            self = self@gras.ode.MatrixSysODESolver(varargin{:});
        end
        function [timeVec,varargout]=solve(self,fDerivFuncList,timeVec,...
                varargin)
            resList = cell(1,length(self.sizeEqList)*...
                    length(fDerivFuncList) + 2);
            [timeVec,resList{:}] = solve@gras.ode.MatrixSysODESolver(self,fDerivFuncList,...
                timeVec,varargin{:});
            varargout = resList;
            objMatrixSysReshapeOde45RegInterp = ...
                gras.ode.MatrixSysReshapeOde45RegInterp(...
                varargout(end-1),self.sizeEqList,varargout(end));
            varargout = varargout(1:(end-2));
            varargout = [varargout {objMatrixSysReshapeOde45RegInterp}];
        end
    end
end