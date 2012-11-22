classdef SplineMatrixOperations<gras.mat.fcnlib.IMatrixOperations
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
        function obj = interpolateBinary(self, fHandle, lMatFunc, rMatFunc, varargin)
            lDataArray = lMatFunc.evaluate(self.timeVec);
            rDataArray = rMatFunc.evaluate(self.timeVec);
            resDataArray = fHandle(lDataArray, rDataArray, varargin{:});
            obj = gras.interp.MatrixInterpolantFactory.createInstance(...
                'column',resDataArray,self.timeVec);
        end
        function obj = interpolateBinarySqueezed(self, fHandle, lMatFunc, rMatFunc)
            lDataArray = lMatFunc.evaluate(self.timeVec);
            rDataArray = squeeze(rMatFunc.evaluate(self.timeVec));
            resDataArray = fHandle(lDataArray, rDataArray);
            obj = gras.interp.MatrixInterpolantFactory.createInstance(...
                'column',resDataArray,self.timeVec);
        end
        function obj = interpolateTernary(self, fHandle, lMatFunc, mMatFunc, rMatFunc)
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
            obj = self.interpolateUnary(...
                @gras.gen.MatVector.triu,...
                mMatFunc);
        end
        function obj=makeSymmetric(self,mMatFunc)
            obj = self.interpolateUnary(...
                @gras.gen.MatVector.makeSymmetric,...
                mMatFunc);
        end
        function obj=pinv(self,mMatFunc)
            obj = self.interpolateUnary(...
                @gras.gen.MatVector.pinv,...
                mMatFunc);
        end
        function obj=transpose(self,mMatFunc)
            obj = self.interpolateUnary(...
                @gras.gen.MatVector.transpose,...
                mMatFunc);
        end
        function obj=inv(self,mMatFunc)
            obj = self.interpolateUnary(...
                @gras.gen.SquareMatVector.inv,...
                mMatFunc);
        end
        function obj=sqrtm(self,mMatFunc)
            obj = self.interpolateUnary(...
                @gras.gen.SquareMatVector.sqrtm,...
                mMatFunc);
        end
        function obj=rMultiplyByVec(self,lMatFunc,rColFunc)
            obj = self.interpolateBinarySqueezed(...
                @gras.gen.MatVector.rMultiplyByVec,...
                lMatFunc,rColFunc);
        end
        function obj=rMultiply(self,lMatFunc,mMatFunc,rMatFunc)
            if nargin < 4
                obj = self.interpolateBinary(...
                    @gras.gen.MatVector.rMultiply,...
                    lMatFunc,mMatFunc);
            else
                obj = self.interpolateTernary(...
                    @gras.gen.MatVector.rMultiply,...
                    lMatFunc,mMatFunc,rMatFunc);
            end
        end
        function obj=lrMultiply(self,mMatFunc,lrMatFunc,flag)
            obj = self.interpolateBinary(...
                @gras.gen.SquareMatVector.lrMultiply,...
                mMatFunc,lrMatFunc,flag);
        end
        function obj=lrMultiplyByVec(self,mMatFunc,lrColFunc)
            obj = self.interpolateBinarySqueezed(...
                @gras.gen.SquareMatVector.lrMultiplyByVec,...
                mMatFunc,lrColFunc);
        end
        function obj=lrDivideVec(self,mMatFunc,lrColFunc)
            obj = self.interpolateBinarySqueezed(...
                @gras.gen.SquareMatVector.lrDivideVec,...
                mMatFunc,lrColFunc);
        end
        function obj=quadraticFormSqrt(self,mMatFunc,xColFunc)
            nTimePoints = numel(self.timeVec);
            %
            mArray = mMatFunc.evaluate(self.timeVec);
            xArray = xColFunc.evaluate(self.timeVec);
            tmpArray = zeros(size(xArray));
            for iTimePoint = 1:nTimePoints
                tmpArray(:,:,iTimePoint) = mArray(:,:,iTimePoint)*xArray(:,:,iTimePoint);
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