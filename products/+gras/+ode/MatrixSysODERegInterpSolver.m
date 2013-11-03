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
            % $Date: 24-oct-2013$
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
            %       initValList: cell[1,nEquations] - initial state
            % Output:
            %   regular:
            %       timeVec: double[nPoints,1] - time grid, same meaning
            %           as in ode45
            %   optional:
            %       outArg1Array: double[sizeEqList{1}]
            %           ...
            %       outArgNArray: double[sizeEqList{nEquations*nFuncs}] -
            %           these variables contains nEquations*nFuncs arrays
            %           of dobule (nEquations for each function), each of
            %           which is a solution of the corresponding equation 
            %           for the corresponding function. (here N in the
            %           name outArgN equal nEquations*nFuncs)
            %       interpObj: 
            %           gras.ode.MatrixSysReshapeOde45RegInterp[1,1] - 
            %           all the data nessecary for calculation on an
            %           arbitrary time grid is stored in this object,
            %           including the dimensionality of the system and the 
            %           number of functions; in fact it is shell of 
            %           gras.ode.VecOde45RegInterp for system of matrix
            %           equations (here N in the name outArgN equal 
            %           nEquations*nFuncs+1)
            % Example:
            %   % Example corresponds to four equations and two derivatives
            %   % functions
            %   
            %   solveObj=gras.ode.MatrixSysODERegInterpSolver(...
            %       sizeVecList,@(varargin)fSolver(varargin{:},...
            %       odeset(odePropList{:})),varargin{:});
            %   % make interpObj
            %   [resInterpTimeVec,resSolveSimpleFunc1Array,...
            %       resSolveSimpleFunc2Array,resSolveSimpleFunc3Array,...
            %       resSolveSimpleFunc4Array,resSolveRegFunc5Array,...
            %       resSolveRegFunc6Array,resSolveRegFunc7Array,...
            %       resSolveRegFunc8Array,...
            %       objMatrixSysReshapeOde45RegInterp]=solveObj.solve(...
            %       fDerivFuncList,timeVec,initValList{:});
            %
            % $Author: Vadim Danilov <vadimdanilov93@gmail.com> $  
            % $Date: 24-oct-2013$
            % $Copyright: Moscow State University,
            %  Faculty of Computational Mathematics and Cybernetics,
            %  Science, System Analysis Department 2013 $
            
            nFuncs = length(fDerivFuncList);
            nOuts = length(self.sizeEqList)*nFuncs;
            resList = cell(1,nOuts);
            resAdvList = cell(1,nFuncs-1);
            [timeVec,resList{:},resAdvList{:}] = ...
                solve@gras.ode.MatrixSysODESolver(self,fDerivFuncList,...
                timeVec,varargin{:});
            varargout = [resList ...
                {gras.ode.MatrixSysReshapeOde45RegInterp(...
                resAdvList{:},self.sizeEqList,nFuncs)}];               
        end
    end
end