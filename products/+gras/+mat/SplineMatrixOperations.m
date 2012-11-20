classdef SplineMatrixOperations<gras.mat.IMatrixOperations
    properties (Access=protected)
        timeVec
    end
    methods(Access=protected)
        function obj = interpolateUnary(self, mMatFunc, fHandle)
            dataArray = mMatFunc.evaluate(self.timeVec);
            resDataArray = fHandle(dataArray);
            obj = gras.interp.MatrixInterpolantFactory.createInstance(...
                'column',resDataArray,self.timeVec);
        end
        function obj = interpolateBinary(self, lMatFunc, rMatFunc, fHandle)
            lDataArray = lMatFunc.evaluate(self.timeVec);
            rDataArray = rMatFunc.evaluate(self.timeVec);
            resDataArray = fHandle(lDataArray, rDataArray);
            obj = gras.interp.MatrixInterpolantFactory.createInstance(...
                'column',resDataArray,self.timeVec);
        end
        function obj = interpolateBinaryParam(self, lMatFunc, rMatFunc, param, fHandle)
            lDataArray = lMatFunc.evaluate(self.timeVec);
            rDataArray = rMatFunc.evaluate(self.timeVec);
            resDataArray = fHandle(lDataArray, rDataArray, param);
            obj = gras.interp.MatrixInterpolantFactory.createInstance(...
                'column',resDataArray,self.timeVec);
        end
        function obj = interpolateTernary(self, lMatFunc, mMatFunc, rMatFunc, fHandle)
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
            obj = self.interpolateUnary(mMatFunc,...
                @gras.gen.MatVector.triu);
        end
        function obj=makeSymmetric(self,mMatFunc)
            obj = self.interpolateUnary(mMatFunc,...
                @gras.gen.MatVector.makeSymmetric);
        end
        function obj=pinv(self,mMatFunc)
            obj = self.interpolateUnary(mMatFunc,...
                @gras.gen.MatVector.pinv);
        end
        function obj=transpose(self,mMatFunc)
            obj = self.interpolateUnary(mMatFunc,...
                @gras.gen.MatVector.transpose);
        end
        function obj=inv(self,mMatFunc)
            obj = self.interpolateUnary(mMatFunc,...
                @gras.gen.SquareMatVector.inv);
        end
        function obj=sqrtm(self,mMatFunc)
            obj = self.interpolateUnary(mMatFunc,...
                @gras.gen.SquareMatVector.sqrtm);
        end
        function obj=rMultiplyByVec(self,lMatFunc,rColFunc)
            obj = self.interpolateBinary(lMatFunc,rColFunc,...
                @gras.gen.SquareMatVector.rMultiplyByVec);
        end
        function obj=rMultiply(self,lMatFunc,mMatFunc,rMatFunc)
            if nargin < 3
                obj = self.interpolateBinary(lMatFunc,mMatFunc,...
                    @gras.gen.SquareMatVector.rMultiply);
            else
                obj = self.interpolateTernary(lMatFunc,mMatFunc,rMatFunc,...
                    @gras.gen.SquareMatVector.rMultiply);
            end
        end
        function obj=lrMultiply(self,mMatFunc,lrMatFunc,flag)
            obj = self.interpolateBinaryParam(mMatFunc,lrMatFunc,flag,...
                @gras.gen.SquareMatVector.rMultiplyByVec);
        end
        function obj=lrMultiplyByVec(self,mMatFunc,lrColFunc)
            obj = self.interpolateBinary(mMatFunc,lrColFunc,...
                @gras.gen.SquareMatVector.lrMultiplyByVec);
        end
        function self=SplineMatrixOperations(timeVec)
            modgen.common.type.simple.checkgen(timeVec,...
                'isnumeric(x)&&isrow(x)&&~isempty(x)');
            self.timeVec = timeVec;
        end
    end
end