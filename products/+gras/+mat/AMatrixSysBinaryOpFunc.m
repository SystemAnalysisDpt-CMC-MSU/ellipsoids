classdef AMatrixSysBinaryOpFunc<gras.mat.AMatrixOpFunc
    properties (Access=protected)
        lMatFunc
        rMatFunc
        opFuncHandle
    end
    methods
        function varargout=evaluate(self,timeVec)
            nTimePoints = numel(timeVec);
            %
            nEqs = self.lMatFunc.getNEquations();
            lArrayList = cell(1,nEqs);
            rArrayList = cell(1,nEqs);
            resArrayList = cell(1,nEqs);
            [lArrayList{:}] = self.lMatFunc.evaluate(timeVec);
            [rArrayList{:}] = self.rMatFunc.evaluate(timeVec);
            %
            for iEqs = 1:nEqs
                if nTimePoints == 1
                    resArrayList{iEqs} = self.opFuncHandle(lArrayList{iEqs},rArrayList{iEqs});
                else
                    resArrayList{iEqs} = zeros( [self.nRows, self.nCols, nTimePoints] );
                    for iTimePoint = 1:nTimePoints
                        resArrayList{iEqs}(:,:,iTimePoint) = self.opFuncHandle(...
                            lArrayList{iEqs}(:,:,iTimePoint), rArrayList{iEqs}(:,:,iTimePoint));
                    end
                end
            end
            varargout = resArrayList;
        end
        function nEqs = getNEquations(self)
            nEqs = self.lMatFunc.getNEquations();
        end
    end
    methods
        function self=AMatrixSysBinaryOpFunc(lMatFunc, rMatFunc, opFuncHandle)
            %
%             modgen.common.type.simple.checkgen(lMatFunc,...
%                 @(x)isa(x,'gras.mat.IMatrixSysFunction'));
%             modgen.common.type.simple.checkgen(rMatFunc,...
%                 @(x)isa(x,'gras.mat.IMatrixSysFunction'));
%             modgen.common.type.simple.checkgen(opFuncHandle,...
%                 @(x)isa(x,'function_handle'));
            %
            self=self@gras.mat.AMatrixOpFunc;
            %
            self.lMatFunc = lMatFunc;
            self.rMatFunc = rMatFunc;
            self.opFuncHandle = opFuncHandle;
        end
    end
end