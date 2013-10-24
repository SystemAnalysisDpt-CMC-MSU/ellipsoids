classdef MatrixSysODERegInterpSolver < gras.ode.MatrixSysODESolver
    methods
        function self=MatrixSysODERegInterpSolver(varargin)
            % MATRIXSYSODEREGINTERPSOLVER - MatrixSysODERegInterpSolver
            %   class constructor. This class inherits from 
            %   gras.ode.MatrixSysODESolver. Differences of class 
            %   gras.ode.MatrixSysODESolver and 
            %   gras.ode.MatrixSysODERegInterpSolver lie in the fact that
            %   the method gras.ode.MatrixSysODERegInterpSolver.solve()
            %   further returns an object of class
            %   gras.ode.MatrixSysReshapeOde45RegInterp.
            %
            % $Author: Vadim Danilov <vadimdanilov93@gmail.com> $  
            % $Date: 24-10-2013$
            % $Copyright: Moscow State University,
            %  Faculty of Computational Mathematics and Cybernetics,
            %  Science, System Analysis Department 2013 $
            self = self@gras.ode.MatrixSysODESolver(varargin{:});
        end
        function [timeVec,varargout]=solve(self,fDerivFuncList,timeVec,...
                varargin)
            % SOLVE - solver of the system of matrix equations
            % Input:
            %   regular:
            %       self: gras.ode.MatrixSysODERegInterpSolver[1,1] -
            %           all the data nessecary to solve the system of
            %           matrix equations  is stored in this object;
            %       fDerivFuncList: cell[1,nEquations] of function handle -
            %           list of derivatives functions;
            %       timeVec: double[1,nPoints] - time range, same meaning 
            %           as in ode45;
            %       varargin: cell[1,nKnots] - list of different parameters
            %           solver (see ode45 op ode45reg);
            % Output:
            %   timeVec: double[nPoints,1] - time grid, same meaning
            %       as in ode45
            %   varargout: cell[1,nargout-1]
            %       varargout(1:(end-1)): cell[1,nargout-2] of double
            %           array - cell vector, which contains
            %           nEquations*nFuncs arrays of dobule (nEquations
            %           for each function), each of which is a solution of
            %           the corresponding equation for the corresponding
            %           function.
            %       varargout(end):
            %           gras.ode.MatrixSysReshapeOde45RegInterp[1,1] - 
            %           all the data nessecary for calculation on an
            %           arbitrary time grid is stored in this object,
            %           including the dimensionality of the system and the 
            %           number of functions; in fact it is shell of 
            %           gras.ode.VecOde45RegInterp for system of matrix
            %           equations. 
            % $Author: Vadim Danilov <vadimdanilov93@gmail.com> $  
            % $Date: 24-10-2013$
            % $Copyright: Moscow State University,
            %  Faculty of Computational Mathematics and Cybernetics,
            %  Science, System Analysis Department 2013 $
            
            nFuncs = length(fDerivFuncList);
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