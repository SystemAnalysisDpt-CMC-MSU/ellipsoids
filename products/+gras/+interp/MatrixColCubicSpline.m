classdef MatrixColCubicSpline<gras.interp.AMatrixCubicSpline
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-08$
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %
    methods (Access=protected,Static)
        function ppFormList=buildSplineCoeffs(dataArray,timeVec)
            import gras.interp.AMatrixCubicSpline
            [~,nDims,~,nCols]=AMatrixCubicSpline.getSizeProps(dataArray);
            ppFormList=cell(1,nCols);
            switch nDims
                case 1
                    ppFormList=cell(1,1);
                    ppFormList{1}=csapi(timeVec,dataArray);
                case 2
                    ppFormList=cell(1,nCols);
                    for k=1:1:nCols
                        ppFormList{k}=csapi(timeVec,dataArray(:,k,:));
                    end
            end
        end
    end
    methods (Access=public)
        function resArray = evaluate(self, timeVec)
            nDims = self.nDims;
            nRows = self.nRows;
            nCols = self.nCols;
            nTimePoints = length(timeVec);            
            if nTimePoints == 1
                if timeVec >= self.timeVec(end)
                    iPiece = self.nTimePoints - 1;
                elseif timeVec <= self.timeVec(1)
                    iPiece = 1;
                else
                    iPiece = find(self.timeVec > timeVec, 1, 'first') - 1;
                end
                %
                tPoint = timeVec - self.timeVec(iPiece);
                tVec = [tPoint^3;tPoint^2;tPoint;1];
                iPieces = (1:nRows) + (iPiece-1)*nRows;
                %
                resArray = zeros(nRows, nCols);
                for k = 1:nCols
                    resArray(:,k) = self.ppFormList{k}.coefs(iPieces,:)*tVec;
                end
            else
                switch nDims
                    case 1
                        resArray = ppval(self.ppFormList{1}, timeVec);
                    case 2
                        resArray = zeros(nRows, nCols, nTimePoints);
                        for k=1:1:nCols
                            resArray(:,k,:) = ppval(self.ppFormList{k},timeVec);
                        end
                end                
            end
        end
    end
    methods
        function objList=getColSplines(self)
            nCols=self.nCols;
            nRows=self.nRows;
            objList=cell(1,nCols);
            for iCol=1:nCols
                objList{iCol}=gras.interp.MatrixColCubicSpline();
                objList{iCol}.initialize(self.ppFormList(iCol),...
                    nRows,self.timeVec);
            end
        end
        function self=MatrixColCubicSpline(varargin)
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