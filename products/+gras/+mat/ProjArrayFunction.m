classdef ProjArrayFunction<gras.mat.AMatrixFunctionComparable
    properties (Access=protected)
        fProjFunction
        % parameters for fProjFunction
        projMat
        sTime
        dim
        indSTime
        %
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
        function fProjFunction = getfProjFunction(self)
            fProjFunction = func2str(self.fProjFunction);
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
    end
    methods (Access=protected)
        function [SData, SFieldNiceNames, SFieldDescr] = ...
                toStructInternal(self, varargin)
            [SData,SFieldNiceNames,SFieldDescr]=toStructInternal@gras.mat.AMatrixComparable(varargin{:});

            SData.fProjFunction = func2str(self.fProjFunction);
            SData.projMat = self.getprojMat();
            SData.sTime = self.getSTime();
            SData.dim =  self.getDim();
            SData.indsTime = self.getIndsTime();

            SFieldNiceNames.fProjFunction = 'fProjFunc';
            SFieldNiceNames.projMat = 'pMat';
            SFieldNiceNames.sTime = 'sTime';
            SFieldNiceNames.dim = 'dim';
            SFieldNiceNames.indsTime = 'iTime';
            
            SFieldDescr.fProjFunction = 'Function';
            SFieldDescr.projMat = 'Matrix of projection';
            SFieldDescr.sTime = 'Time s';
            SFieldDescr.dim = 'Dimensionality';
            SFieldDescr.indsTime = 'Index of sTime within timeVec';
    
        end
    end
end