classdef MatrixSysReshapeOde45RegInterp
    properties(Access=private)
        objVecOde45RegInterp
        sizeEqList
        nFuncs
    end
    methods
        function interpObj = MatrixSysReshapeOde45RegInterp(...
                objVecOde45RegInterp,sizeEqList,nFuncs)
            % MATRIXSYSRESHAPEODE45REGINTERP - 
            %       MatrixSysReshapeOde45RegInterp class constructor
            % Input:
            %   regular:
            %       objVecOde45RegInterp: gras.ode.VecOde45RegInterp[1,1] -
            %           all the data nessecary for calculation on an
            %           arbitrary time grid is stored in this object;
            %       sizeEqList: cell[1,nEquations] of double array - sizes 
            %           of all equations in system of matrix equations
            %           stored in this list;
            %       nFuncs: double[1,1] - the number of functions to
            %           compute the result; if nFuncs equal 1, then result 
            %           compute only for derivative function; if nFuncs 
            %           equal 2, then result compute for derivative 
            %           function and regularization function;
            % Output:
            %   interpObj: gras.ode.MatrixSysReshapeOde45RegInterp[1,1] - 
            %       all the data nessecary for calculation on an
            %       arbitrary time grid is stored in this object,
            %       including the dimensionality of the system and the 
            %       number of functions; in fact it is shell of 
            %       gras.ode.VecOde45RegInterp for system of matrix
            %       equations.
            % $Author: Vadim Danilov <vadimdanilov93@gmail.com> $  
            % $Date: 24-oct-2013$
            % $Copyright: Moscow State University,
            %  Faculty of Computational Mathematics and Cybernetics,
            %  Science, System Analysis Department 2013 $
            
          	import modgen.common.throwerror;
            import modgen.common.checkvar;
            modgen.common.checkvar(objVecOde45RegInterp,@(x)isa(x,...
                'gras.ode.VecOde45RegInterp'),'interpObj',...
                'errorTag','wrongInput:badType','errorMessage',...
                ['First argument should be gras.ode.VecOde45RegInterp ',...
                'class object']);
            interpObj.objVecOde45RegInterp = objVecOde45RegInterp;
            interpObj.sizeEqList = sizeEqList;
            interpObj.nFuncs = nFuncs;
        end
        
        function [timeVec,varargout] = evaluate(self,timeVec)
            % EVALUATE - this method duplicates the function's 
            %   gras.ode.MatrixSysODESolver.solve() work on an arbitrary
            %   time grid timeVec
            % Input:
            %   regular:
            %       self: gras.ode.MatrixSysReshapeOde45RegInterp[1,1] - 
            %           all the data nessecary for calculation on an
            %           arbitrary time grid is stored in this object,
            %           including the dimensionality of the system and the 
            %           number of functions; in fact it is shell of 
            %           gras.ode.VecOde45RegInterp for system of matrix
            %           equations.
            %       timeVec: double[1,nPoints] - time range, same meaning 
            %           as in ode45
            % Output:
            %    regular:
            %       timeVec: double[nPoints,1] - time grid, same meaning
            %           as in ode45
            %    optional:
            %        outArg1: double[sizeEqList{1}]
            %            ...
            %        outArgN: double[sizeEqList{nEquations*nFuncs}] -
            %            these variables contains nEquations*nFuncs arrays
            %            of dobule (nEquations for each function), each of
            %            which is a solution of the corresponding equation 
            %            for the corresponding function. (here N in the
            %            name outArgN equal nEquations*nFuncs)
            % Example:
            %   % Example corresponds to four equations and two derivatives
            %   % functions
            %
            %   solveObj=gras.ode.MatrixSysODERegInterpSolver(...
            %       sizeVecList,@(varargin)fSolver(varargin{:},...
            %       odeset(odePropList{:})),varargin{:});
            %   % make interpObj
            %   [resTimeVec,~,~,~,~,~,~,~,~,...
            %       objMatrixSysReshapeOde45RegInterp]=solveObj.solve(...
            %       fDerivFuncList,timeVec,initValList{:});
            %   % use interpObj
            %   [resInterpTimeVec,resSolveSimpleFuncArray1,...
            %       resSolveSimpleFuncArray2,resSolveSimpleFuncArray3,...
            %       resSolveSimpleFuncArray4,resSolveRegFuncArray5,...
            %       resSolveRegFuncArray6,resSolveRegFuncArray7,...
            %       resSolveRegFuncArray8] = ...
            %       objMatrixSysReshapeOde45RegInterp.evaluate(timeVec);
            %
            %
            % $Author: Vadim Danilov  <vadimdanilov93@gmail.com>
            % $	$Date: 24-oct-2013$
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer
            %            Science, System Analysis Department 2013 $
            
            resList = cell(1,self.nFuncs);
            [timeVec,resList{:}] = ...
                self.objVecOde45RegInterp.evaluate(timeVec);
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