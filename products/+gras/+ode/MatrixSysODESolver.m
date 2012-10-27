classdef MatrixSysODESolver
    properties
        sizeEqList
        fSolveFunc
        nEquations
        indEqList
        indOutArgStartVec
    end
    methods
        function self=MatrixSysODESolver(sizeVecList,fSolveFunc,varargin)
            import modgen.common.throwerror;
            import modgen.common.parseparext;
            if ~all(cellfun('length',sizeVecList)>=2);
                throwerror('wrongInput',['each element of size vector',...
                    'list should contain at least 2 elements']);
            end
            self.sizeEqList=sizeVecList;
            nEqs=length(sizeVecList);
            nElemVec=cellfun(@prod,sizeVecList);
            nElemCumVec=cumsum(nElemVec);
            self.indEqList=cellfun(@(x,y)x:y,...
                num2cell(ones(1,nEqs)+[0,nElemCumVec(1:end-1)]),...
                num2cell(nElemCumVec),'UniformOutput',false);
            %
            [~,~,self.indOutArgStartVec]=parseparext(varargin,...
                {'outArgStartIndVec';ones(1:nEqs);...
                'isnumeric(x)&&isrow(x)&&all(fix(x)==x)'},0);
            self.fSolveFunc=fSolveFunc;
            self.nEquations=nEqs;
        end
        function [timeVec,varargout]=solve(self,fDerivFuncList,...
                timeVec,varargin)
            import modgen.common.throwerror;
            %
            if ~all(cellfun(@auxchecksize,varargin,self.sizeEqList))
                throwerror('wrongInput',['initial values should be ',...
                    'consistent with list of size vectors ',...
                    'specified in constructor']);
            end
            fDerivFuncList=modgen.common.type.simple.checkcelloffunc(...
                fDerivFuncList);
            nFuncs=length(fDerivFuncList);
            fMatrixDerivFuncList=cell(1,nFuncs);
            indOutArgStartVec=self.indOutArgStartVec;
            for iFunc=1:nFuncs
                fMatrixDerivFuncList{iFunc}=@(t,y)reshapeInOut(self,t,y,...
                    fDerivFuncList{iFunc},indOutArgStartVec(iFunc));
            end
            varargin=cellfun(@(x)x(:),varargin,'UniformOutput',false);
            initValVec=vertcat(varargin{:});
            resList=cell(1,nFuncs);
            [timeVec,resList{:}]=self.fSolveFunc(fMatrixDerivFuncList{:},...
                timeVec,initValVec(:));
            timeVec=timeVec.';
            nTimePoints=length(timeVec);
            nEqs=self.nEquations;
            indEqList=self.indEqList;
            sizeEqList=self.sizeEqList;
            for iFunc=1:nFuncs
                indShift=(iFunc-1)*nEqs;
                for iEq=1:nEqs
                    varargout{indShift+iEq}=reshape(...
                        transpose(resList{iFunc}(:,indEqList{iEq})),...
                        [sizeEqList{iEq} nTimePoints]);
                end
            end
        end
    end
    methods (Access=private)
        function varargout=reshapeInOut(self,t,y,fDerivFunc,indStart)
            nEqs=self.nEquations;
            nOutArgs=indStart-1+nEqs;
            indOutArgVec=indStart:nOutArgs;
            outList=cell(1,nOutArgs);
            inList=cell(1,nEqs);
            sizeEqList=self.sizeEqList;
            indEqList=self.indEqList;
            for iEq=1:nEqs
                inList{iEq}=reshape(y(indEqList{iEq}),sizeEqList{iEq});
            end
            [outList{:}]=fDerivFunc(t,inList{:});
            outList(indOutArgVec)=cellfun(@(x)x(:),outList(indOutArgVec),'UniformOutput',false);
            varargout(1:indStart-1)=outList(1:indStart-1);
            varargout{indStart}=vertcat(outList{indOutArgVec});
        end
    end
end