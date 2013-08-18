classdef SplineMatrixOperations<gras.mat.AMatrixOperations
    properties (Access=protected)
        timeVec
    end
    methods(Access=private)
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
        function obj = interpolateBinaryScalar(self, fHandle, lMatFunc,...
                rScalFunc, varargin)
            lDataArray = lMatFunc.evaluate(self.timeVec);
            lsizeVec = size(lDataArray);
            rDataVec = zeros(1,1,numel(self.timeVec));
            rDataVec(1,1,:) = rScalFunc.evaluate(self.timeVec);
            rDataArray = repmat(rDataVec, [lsizeVec(1:2), 1]);
            resDataArray = fHandle(lDataArray, rDataArray, varargin{:});
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
            obj=triu@gras.mat.AMatrixOperations(self,mMatFunc);
            if isempty(obj)
                obj = self.interpolateUnary(...
                    @gras.gen.MatVector.triu,...
                    mMatFunc);
            end
        end
        function obj=makeSymmetric(self,mMatFunc)
            obj=makeSymmetric@gras.mat.AMatrixOperations(self,mMatFunc);
            if isempty(obj)
                obj = self.interpolateUnary(...
                    @gras.gen.MatVector.makeSymmetric,...
                    mMatFunc);
            end
        end
        function obj=pinv(self,mMatFunc)
            obj=pinv@gras.mat.AMatrixOperations(self,mMatFunc);
            if isempty(obj)
                obj = self.interpolateUnary(...
                    @gras.gen.MatVector.pinv,...
                    mMatFunc);
            end
        end
        function obj=uminus(self,mMatFunc)
            obj=uminus@gras.mat.AMatrixOperations(self,mMatFunc);
            if isempty(obj)
                obj = self.interpolateUnary(@uminus,mMatFunc);
            end
        end
        function obj=realsqrt(self,mMatFunc)
            obj=realsqrt@gras.mat.AMatrixOperations(self,mMatFunc);
            if isempty(obj)
                obj = self.interpolateUnary(@realsqrt,mMatFunc);
            end
        end
        function obj=transpose(self,mMatFunc)
            obj=transpose@gras.mat.AMatrixOperations(self,mMatFunc);
            if isempty(obj)
                obj = self.interpolateUnary(...
                    @gras.gen.MatVector.transpose,...
                    mMatFunc);
            end
        end
        function obj=inv(self,mMatFunc)
            obj=inv@gras.mat.AMatrixOperations(self,mMatFunc);
            if isempty(obj)
                obj = self.interpolateUnary(...
                    @gras.gen.SquareMatVector.inv,...
                    mMatFunc); 
            end
        end
        function obj=sqrtmpos(self,mMatFunc)
            obj=sqrtmpos@gras.mat.AMatrixOperations(self,mMatFunc);
            if isempty(obj)
                obj = self.interpolateUnary(...
                    @gras.gen.SquareMatVector.sqrtmpos,...
                    mMatFunc);
            end
        end
        function obj=expm(self,mMatFunc)
            obj=expm@gras.mat.AMatrixOperations(self,mMatFunc);
            if isempty(obj)
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
            obj=expmt@gras.mat.AMatrixOperations(self,mMatFunc,t0);
            if isempty(obj)
                nTimePoints = numel(self.timeVec);
                mArray = mMatFunc.evaluate(self.timeVec);
                for iTimePoint = 1:nTimePoints
                    mArray(:,:,iTimePoint) = expm(mArray(:,:,iTimePoint)*...
                        (self.timeVec(iTimePoint)-t0));
                end
                obj = gras.interp.MatrixInterpolantFactory.createInstance(...
                    'column',mArray,self.timeVec);
            end
        end
        function obj=matdot(self,lMatFunc,rMatFunc)
            import gras.gen.matdot;
            %
            obj=matdot@gras.mat.AMatrixOperations(...
                self,lMatFunc,rMatFunc);
            if isempty(obj)
                obj = self.interpolateBinary(@matdot,lMatFunc,rMatFunc);
            end
        end
        function obj=rMultiplyByScalar(self,lMatFunc,rScalFunc)
            obj=rMultiplyByScalar@gras.mat.AMatrixOperations(...
                self,lMatFunc,rScalFunc);
            if isempty(obj)
                obj = self.interpolateBinaryScalar(@times,lMatFunc, ...
                    rScalFunc);
            end
        end
        function obj=rDivideByScalar(self,lMatFunc,rScalFunc)
            obj=rDivideByScalar@gras.mat.AMatrixOperations(...
                self,lMatFunc,rScalFunc);
            if isempty(obj)
                obj = self.interpolateBinaryScalar(@rdivide,lMatFunc, ...
                    rScalFunc);
            end
        end
        function obj=rMultiplyByVec(self,lMatFunc,rColFunc)
            obj=rMultiplyByVec@gras.mat.AMatrixOperations(...
                self,lMatFunc,rColFunc);
            if isempty(obj)
                obj = self.interpolateBinarySqueezed(...
                    @gras.gen.MatVector.rMultiplyByVec,...
                    lMatFunc,rColFunc);
            end
        end
        function obj=rMultiply(self,lMatFunc,mMatFunc,rMatFunc)
            if nargin < 4
                obj=rMultiply@gras.mat.AMatrixOperations(...
                    self,lMatFunc,mMatFunc);
                if isempty(obj)
                    obj = self.interpolateBinary(...
                        @gras.gen.MatVector.rMultiply,...
                        lMatFunc,mMatFunc);
                end
            else
                obj=rMultiply@gras.mat.AMatrixOperations(...
                    self,lMatFunc,mMatFunc,rMatFunc);
                if isempty(obj)
                    obj = self.interpolateTernary(...
                        @gras.gen.MatVector.rMultiply,...
                        lMatFunc,mMatFunc,rMatFunc);
                end
            end
        end
        function obj=lrMultiply(self,mMatFunc,lrMatFunc,flag)
            obj=lrMultiply@gras.mat.AMatrixOperations(...
                self,mMatFunc,lrMatFunc,flag);
            if isempty(obj)
                obj = self.interpolateBinary(...
                    @gras.gen.SquareMatVector.lrMultiply,...
                    mMatFunc,lrMatFunc,flag);
            end
        end
        function obj=lrMultiplyByVec(self,mMatFunc,lrColFunc)
            obj=lrMultiplyByVec@gras.mat.AMatrixOperations(...
                self,mMatFunc,lrColFunc);
            if isempty(obj)
                obj = self.interpolateBinarySqueezed(...
                    @gras.gen.SquareMatVector.lrMultiplyByVec,...
                    mMatFunc,lrColFunc);
            end
        end
        function obj=lrDivideVec(self,mMatFunc,lrColFunc)
            obj=lrDivideVec@gras.mat.AMatrixOperations(...
                self,mMatFunc,lrColFunc);
            if isempty(obj)
                obj = self.interpolateBinarySqueezed(...
                    @gras.gen.SquareMatVector.lrDivideVec,...
                    mMatFunc,lrColFunc);
            end
        end
        function obj=quadraticFormSqrt(self,mMatFunc,xColFunc)
            obj=quadraticFormSqrt@gras.mat.AMatrixOperations(...
                self,mMatFunc,xColFunc);
            if isempty(obj)
                nTimePoints = numel(self.timeVec);
                mArray = mMatFunc.evaluate(self.timeVec);
                xArray = xColFunc.evaluate(self.timeVec);
                tmpArray = zeros(size(xArray));
                for iTimePoint = 1:nTimePoints
                    tmpArray(:,:,iTimePoint) = ...
                        mArray(:,:,iTimePoint)*xArray(:,:,iTimePoint);
                end
                resVec = shiftdim(realsqrt(sum(tmpArray.*xArray,1)),1);
                obj = gras.interp.MatrixInterpolantFactory.createInstance(...
                    'column',resVec,self.timeVec);
            end
        end
        %
        function self=SplineMatrixOperations(timeVec)
            modgen.common.type.simple.checkgen(timeVec,...
                'isnumeric(x)&&isrow(x)&&~isempty(x)');
            self.timeVec = timeVec;
        end
    end
end