classdef AMatrixSysTernaryOpFunc<gras.mat.AMatrixOpFunc
    properties (Access=protected)
        lMatFunc
        mMatFunc
        rMatFunc
        opFuncHandle
    end
    methods
        function varargout=evaluate(self,timeVec)
            nTimePoints = numel(timeVec);
            %
            nEqs = self.mMatFunc.getNEquations();
            resHelpArrayList = cell(1,nEqs);
            resArrayList = cell(1,nEqs);
            lArray = self.lMatFunc.evaluate(timeVec);
            [resHelpArrayList{:}] = self.mMatFunc.evaluate(timeVec);
            rArray = self.rMatFunc.evaluate(timeVec);
            %
            for iEqs = 1:nEqs
                if nTimePoints == 1
                    resArrayList{iEqs} = self.opFuncHandle(lArray,...
                        resHelpArrayList{iEqs},rArray);
                else
                    resArrayList{iEqs} = zeros( [self.nRows, self.nCols, nTimePoints] );
                    for iTimePoint = 1:nTimePoints
                        resArrayList{iEqs}(:,:,iTimePoint) = self.opFuncHandle(...
                            lArray(:,:,iTimePoint), resHelpArrayList{iEqs}(:,:,iTimePoint),...
                            rArray(:,:,iTimePoint));
                    end
                end
            end
            varargout = resArrayList;
        end
        function nEqs = getNEquations(self)
            nEqs = self.mMatFunc.getNEquations();
        end
    end
    methods
        function self=AMatrixSysTernaryOpFunc(lMatFunc, mMatFunc,...
                rMatFunc, opFuncHandle)
            %
%             modgen.common.type.simple.checkgen(lMatFunc,...
%                 @(x)isa(x,'gras.mat.IMatrixFunction'));
%             modgen.common.type.simple.checkgen(mMatFunc,...
%                 @(x)isa(x,'gras.mat.IMatrixFunction'));
%             modgen.common.type.simple.checkgen(rMatFunc,...
%                 @(x)isa(x,'gras.mat.IMatrixFunction'));
%             modgen.common.type.simple.checkgen(opFuncHandle,...
%                 @(x)isa(x,'function_handle'));
            %
            self=self@gras.mat.AMatrixOpFunc;
            %
            self.lMatFunc = lMatFunc;
            self.mMatFunc = mMatFunc;
            self.rMatFunc = rMatFunc;
            self.opFuncHandle = opFuncHandle;
        end
    end
end
