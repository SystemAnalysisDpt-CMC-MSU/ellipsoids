classdef ProjArrayFunction<gras.mat.AMatrixFunctionComparable
    properties (Access=protected)
        fProjFunction
        % parameters for fProjFunction
        projMat
        sTime
        dim
        indSTime
        %
        mArray
        mSizeVec
        nDims
        nRows
        nCols
    end
    methods
        function mSizeVec = getMatrixSize(self)
            mSizeVec = self.mSizeVec;
        end
        function projArray = evaluate(self,timeVec)
            [projArray,~] = self.fProjFunction(self.projMat,timeVec,...
                self.sTime,self.dim,self.indSTime);
            sizeArray = size(projArray);
            self.mArray = projArray;
            self.mSizeVec = sizeArray(1:2);
            self.nRows = self.mSizeVec(1);
            self.nCols = self.mSizeVec(2);
        end
        function nDims=getDimensionality(self)
            nDims = self.nDims;
        end
        function nCols=getNCols(self)
            nCols = self.nCols;
        end
        function nRows=getNRows(self)
            nRows = self.nRows;
        end
        function mArray = getmArray(self)
            mArray = self.mArray;
        end
    end
    methods
        function self=ProjArrayFunction(projMat,timeVec,sTime,dim,...
                indSTime,fProjFunction)
            %
            modgen.common.type.simple.checkgen(projMat,...
                'isnumeric(x)&&~isempty(x)');
            %
            self.projMat = projMat;
            self.sTime = sTime;
            self.dim = dim;
            self.indSTime = indSTime;
            self.fProjFunction = fProjFunction;
            self.evaluate(timeVec);
        end
        function SData = toStructInternal(self,isPropIncluded)
            SData = toStructInternalProjArray(self,isPropIncluded);
        end
    end
    methods
        function [SDataArr, SFieldNiceNames, SFieldDescr] = ...
                toStructInternalProjArray(matObj, isPropIncluded)
            
            if (nargin < 2)
                isPropIncluded = false;
            end
            
            SEll = struct('mArray',matObj.getmArray(),'projMat', matObj.getprojMat(),...
                'sTime',matObj.getSTime(),'dim', matObj.getDim(),...
                'indsTime', matObj.getIndsTime());
            
            if (isPropIncluded)
                SEll.absTol = matObj.getAbsTol();
                SEll.relTol = matObj.getRelTol();
            end
            
            SDataArr = SEll;
            SFieldNiceNames = struct('mArray','mA','projMat','pM', 'sTime',...
                'sT', 'dim', 'd', 'indsTime', 'iT');
            SFieldDescr = struct('projMat','Matrix of projection',...
                'sTime', 'Time s', 'dim', 'Dimensionality',...
                'indsTime', 'Index of sTime within timeVec');
            
            if (isPropIncluded)
                SFieldNiceNames.absTol = 'absTol';
                SFieldNiceNames.relTol = 'relTol';
                
                SFieldDescr.absTol = 'Absolute tolerance.';
                SFieldDescr.relTol = 'Relative tolerance.';
            end     
        end
    end
end