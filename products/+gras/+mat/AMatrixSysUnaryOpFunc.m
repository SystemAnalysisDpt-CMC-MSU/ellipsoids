classdef AMatrixSysUnaryOpFunc<gras.mat.AMatrixOpFunc
    properties (Access=protected)
        lMatFunc
        opFuncHandle
    end
    methods
        function varargout=evaluate(self,timeVec)
            nTimePoints = numel(timeVec);
            %
            nEqs = self.lMatFunc.getNEquations();
            lArrayList = cell(1,nEqs);
            resArrayList = cell(1,nEqs);
            [lArrayList{:}] = self.lMatFunc.evaluate(timeVec);
            %
            for iEqs = 1:nEqs
                if nTimePoints == 1
                    resArrayList{iEqs} = self.opFuncHandle(lArrayList{iEqs});
                else
                    resArrayList{iEqs} = zeros( [self.nRows, self.nCols, nTimePoints] );
                    for iTimePoint = 1:nTimePoints
                        resArrayList{iEqs}(:,:,iTimePoint) = self.opFuncHandle(...
                            lArrayList{iEqs}(:,:,iTimePoint));
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
        function self=AMatrixSysUnaryOpFunc(lMatFunc, opFuncHandle)
            %
%             modgen.common.type.simple.checkgen(lMatFunc,...
%                 @(x)isa(x,'gras.mat.IMatrixSysFunction'));
%             modgen.common.type.simple.checkgen(opFuncHandle,...
%                 @(x)isa(x,'function_handle'));
            %
            self=self@gras.mat.AMatrixOpFunc;
            %
            self.lMatFunc = lMatFunc;
            self.opFuncHandle = opFuncHandle;
        end
    end
end
