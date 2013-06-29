classdef MatrixRowCubicSpline<gras.interp.AMatrixCubicSpline
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-08$
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %    
    methods (Access=protected,Static)
        function ppFormList=buildSplineCoeffs(dataArray,timeVec)
            import gras.interp.AMatrixCubicSpline;
            [~,nDims,nRows]=AMatrixCubicSpline.getSizeProps(dataArray);
            ppFormList=cell(1,nRows);
            switch nDims
                case 1
                    for k=1:1:nRows
                        ppFormList{k}=csapi(timeVec,dataArray(k,:));
                    end
                case 2
                    for k=1:1:nRows
                        ppFormList{k}=csapi(timeVec,dataArray(k,:,:));
                    end
            end
        end
    end
    methods (Access=public)
        function resArray=evaluate(self,timeVec)
            mSizeVec=self.mSizeVec;
            mSizeLen=length(mSizeVec);
            nDims=2-(any(mSizeVec == 1) || (mSizeLen < 2));
            nRows=self.nRows;
            nCols=self.nCols;
            nTimePoints=length(timeVec);
            switch nDims
                case 1
                    resArray=zeros(nRows,nTimePoints);
                    for k=1:1:nRows
                        resArray(k,:)=fnval(self.ppFormList{k},timeVec);
                    end
                case 2
                    resArray=zeros(nRows,nCols,nTimePoints);
                    for k=1:1:nRows
                        resArray(k,:,:)=fnval(self.ppFormList{k},timeVec);
                    end
            end
        end
    end
    methods
        function self=MatrixRowCubicSpline(varargin)
            % MATRIXCUBESPLINE represents a cubic interpolant of
            % matrix-value function
            %
            % Input:
            %   regular:
            %       dataArray: double[nCols,nRows,nTimePoints]
            %               /double[nRows,nTimes] - data array
            %       timeVec: double[1,nTimePoints] -
            %           
            %
            self=self@gras.interp.AMatrixCubicSpline(varargin{:});
        end
    end
end