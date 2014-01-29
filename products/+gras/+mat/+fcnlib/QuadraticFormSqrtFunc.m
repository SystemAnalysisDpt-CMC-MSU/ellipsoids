classdef QuadraticFormSqrtFunc<gras.mat.AMatrixOpFunc
    properties (Access=protected)
        mMatFunc
        xColFunc
    end
    methods
        function resVec=evaluate(self,timeVec)
            nTimePoints = numel(timeVec);
            %
            mArray = self.mMatFunc.evaluate(timeVec);
            xArray = self.xColFunc.evaluate(timeVec);
            %
            if nTimePoints == 1
                resVec = realsqrt((xArray.')*mArray*xArray);
            else
                tmpArray = zeros(size(xArray));
                for iTimePoint = 1:nTimePoints
                    tmpArray(:,:,iTimePoint) = ...
                        mArray(:,:,iTimePoint)*xArray(:,:,iTimePoint);
                end
                resVec = realsqrt(sum(tmpArray.*xArray,1));
            end
        end
    end
    methods
        function self=QuadraticFormSqrtFunc(mMatFunc, xColFunc)
            %
            modgen.common.type.simple.checkgen(mMatFunc,...
                @(x)isa(x,'gras.mat.IMatrixFunction'));
            modgen.common.type.simple.checkgen(xColFunc,...
                @(x)isa(x,'gras.mat.IMatrixFunction'));
            %
            modgen.common.type.simple.checkgenext(...
                'x1(1)==x1(2)&&x1(2)==x2(1)&&x2(2)==1', 2,...
                mMatFunc.getMatrixSize(), xColFunc.getMatrixSize());
            %
            self=self@gras.mat.AMatrixOpFunc;
            %
            self.mMatFunc = mMatFunc;
            self.xColFunc = xColFunc;
            self.nRows = 1;
            self.nCols = 1;
            self.nDims = 1;
        end
    end
end
