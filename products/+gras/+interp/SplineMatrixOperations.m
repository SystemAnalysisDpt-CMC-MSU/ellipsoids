classdef SplineMatrixOperations<gras.mat.fcnlib.AMatrixOperations
    properties (Access=protected)
        timeVec
    end
    methods(Access=protected)
        function obj = interpolateUnary(self, fHandle, mMatFunc)
            dataArray = mMatFunc.evaluate(self.timeVec);
            resDataArray = fHandle(dataArray);
            obj = gras.interp.MatrixInterpolantFactory.createInstance(...
                'column',resDataArray,self.timeVec);
        end
        function obj = interpolateBinary(self, fHandle, lMatFunc,...
                rMatFunc, varargin)
            lDataArray = lMatFunc.evaluate(self.timeVec);
            rDataArray = rMatFunc.evaluate(self.timeVec);
            resDataArray = fHandle(lDataArray, rDataArray, varargin{:});
            obj = gras.interp.MatrixInterpolantFactory.createInstance(...
                'column',resDataArray,self.timeVec);
        end
        function obj = interpolateBinarySqueezed(self, fHandle,...
                lMatFunc, rMatFunc)
            lDataArray = lMatFunc.evaluate(self.timeVec);
            rDataArray = squeeze(rMatFunc.evaluate(self.timeVec));
            resDataArray = fHandle(lDataArray, rDataArray);
            obj = gras.interp.MatrixInterpolantFactory.createInstance(...
                'column',resDataArray,self.timeVec);
        end
        function obj = interpolateTernary(self, fHandle, lMatFunc,...
                mMatFunc, rMatFunc)
            lDataArray = lMatFunc.evaluate(self.timeVec);
            mDataArray = mMatFunc.evaluate(self.timeVec);
            rDataArray = rMatFunc.evaluate(self.timeVec);
            resDataArray = fHandle(lDataArray, mDataArray, rDataArray);
            obj = gras.interp.MatrixInterpolantFactory.createInstance(...
                'column',resDataArray,self.timeVec);
        end
    end
    methods
        function obj=triu(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constTriu(mMatFunc);
            else
                obj = self.interpolateUnary(...
                    @gras.gen.MatVector.triu,...
                    mMatFunc);
            end
        end
        function obj=makeSymmetric(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constMakeSymmetric(mMatFunc);
            else
                obj = self.interpolateUnary(...
                    @gras.gen.MatVector.makeSymmetric,...
                    mMatFunc);
            end
        end
        function obj=pinv(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constPinv(mMatFunc);
            else
                obj = self.interpolateUnary(...
                    @gras.gen.MatVector.pinv,...
                    mMatFunc);
            end
        end
        function obj=transpose(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constTranspose(mMatFunc);
            else
                obj = self.interpolateUnary(...
                    @gras.gen.MatVector.transpose,...
                    mMatFunc);
            end
        end
        function obj=inv(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constInv(mMatFunc);
            else
                obj = self.interpolateUnary(...
                    @gras.gen.SquareMatVector.inv,...
                    mMatFunc);
            end
        end
        function obj=sqrtm(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constSqrtm(mMatFunc);
            else
                obj = self.interpolateUnary(...
                    @gras.gen.SquareMatVector.sqrtm,...
                    mMatFunc);
            end
        end
        function obj=expm(self,mMatFunc)
            if self.isMatFuncConst(mMatFunc)
                obj = self.constExpm(mMatFunc);
            else
                nTimePoints = numel(self.timeVec);
                mArray = mMatFunc.evaluate(self.timeVec);
                for iTimePoint = 1:nTimePoints
                    mArray(:,:,iTimePoint) = expm(mArray(:,:,iTimePoint));
                end
                obj = gras.interp.MatrixInterpolantFactory.createInstance(...
                    'column',mArray,self.timeVec);
            end
        end
        function obj=expmt(self,mMatFunc,t0)
            nTimePoints = numel(self.timeVec);
            %
            mArray = mMatFunc.evaluate(self.timeVec);
            %
            for iTimePoint = 1:nTimePoints
                mArray(:,:,iTimePoint) = expm(mArray(:,:,iTimePoint)*...
                    (self.timeVec(iTimePoint)-t0));
            end
            %
            obj = gras.interp.MatrixInterpolantFactory.createInstance(...
                'column',mArray,self.timeVec);
        end
        function obj=rMultiplyByVec(self,lMatFunc,rColFunc)
            if self.isMatFuncConst(lMatFunc,rColFunc)
                obj = self.constRMultiplyByVec(lMatFunc,rColFunc);
            else
                obj = self.interpolateBinarySqueezed(...
                    @gras.gen.MatVector.rMultiplyByVec,...
                    lMatFunc,rColFunc);
            end
        end
        function obj=rMultiply(self,lMatFunc,mMatFunc,rMatFunc)
            if nargin < 4
                if self.isMatFuncConst(lMatFunc,mMatFunc)
                    obj = self.constRMultiply(lMatFunc,mMatFunc);
                else
                    obj = self.interpolateBinary(...
                        @gras.gen.MatVector.rMultiply,...
                        lMatFunc,mMatFunc);
                end
            else
                if self.isMatFuncConst(lMatFunc,mMatFunc,rMatFunc)
                    obj = self.constRMultiply(lMatFunc,mMatFunc,rMatFunc);
                else
                    obj = self.interpolateTernary(...
                        @gras.gen.MatVector.rMultiply,...
                        lMatFunc,mMatFunc,rMatFunc);
                end
            end
        end
        function obj=lrMultiply(self,mMatFunc,lrMatFunc,flag)
            if self.isMatFuncConst(mMatFunc,lrMatFunc)
                obj = self.constLrMultiply(mMatFunc,lrMatFunc,flag);
            else
                obj = self.interpolateBinary(...
                    @gras.gen.SquareMatVector.lrMultiply,...
                    mMatFunc,lrMatFunc,flag);
            end
        end
        function obj=lrMultiplyByVec(self,mMatFunc,lrColFunc)
            if self.isMatFuncConst(mMatFunc,lrColFunc)
                obj = self.constLrMultiplyByVec(mMatFunc,lrColFunc);
            else
                obj = self.interpolateBinarySqueezed(...
                    @gras.gen.SquareMatVector.lrMultiplyByVec,...
                    mMatFunc,lrColFunc);
            end
        end
        function obj=lrDivideVec(self,mMatFunc,lrColFunc)
            if self.isMatFuncConst(mMatFunc,lrColFunc)
                obj = self.constLrDivideVec(mMatFunc,lrColFunc);
            else
                obj = self.interpolateBinarySqueezed(...
                    @gras.gen.SquareMatVector.lrDivideVec,...
                    mMatFunc,lrColFunc);
            end
        end
        function obj=quadraticFormSqrt(self,mMatFunc,xColFunc)
            nTimePoints = numel(self.timeVec);
            %
            mArray = mMatFunc.evaluate(self.timeVec);
            xArray = xColFunc.evaluate(self.timeVec);
            tmpArray = zeros(size(xArray));
            for iTimePoint = 1:nTimePoints
                tmpArray(:,:,iTimePoint) = ...
                    mArray(:,:,iTimePoint)*xArray(:,:,iTimePoint);
            end
            resVec = shiftdim(sqrt(sum(tmpArray.*xArray,1)),1);
            %
            obj = gras.interp.MatrixInterpolantFactory.createInstance(...
                'column',resVec,self.timeVec);
        end
        function self=SplineMatrixOperations(timeVec)
            modgen.common.type.simple.checkgen(timeVec,...
                'isnumeric(x)&&isrow(x)&&~isempty(x)');
            self.timeVec = timeVec;
        end
    end
end