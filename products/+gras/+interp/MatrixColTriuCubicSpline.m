classdef MatrixColTriuCubicSpline<gras.interp.AMatrixCubicSpline
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-08$
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %    
    methods (Access=protected,Static)
        function ppFormList=buildSplineCoeffs(dataArray,timeVec)
            import modgen.common.throwerror;
            import gras.interp.AMatrixCubicSpline;
            [mSizeVec,nDims,nRows,nCols]=AMatrixCubicSpline.getSizeProps(dataArray);
            switch nDims
                case 1
                    if mSizeVec~=1
                        throwerror('wrongInput',...
                            ['in two-dimensional mode the ',...
                            'values should be scalar in column_triu mode']);
                    end
                    ppFormList=cell(1,1);
                    ppFormList{1}=csapi(timeVec,dataArray);
                case 2
                    if nCols~=nRows
                        throwerror('wrongInput',...
                            ['column_triu is only supported ',...
                            'for symmetrical matrices']);
                    end
                    ppFormList=cell(1,nCols);
                    for k=1:1:nCols
                        ppFormList{k}=csapi(timeVec,dataArray(1:k,k,:));
                    end
            end
        end
    end
    methods (Access=public)
        function resArray=evaluate(self,timeVec)
            nRows=self.mSizeVec(1);
            nDims=self.nDims;
            nCols=self.nCols;
            nTimePoints=length(timeVec);
            switch nDims
                case 1
                    resArray=fnval(self.ppFormList{1},timeVec);
                case 2,
                    resArray=zeros(nRows,nCols,nTimePoints);                    
                    for k=1:1:nCols
                        resArray(1:k,k,:)=fnval(self.ppFormList{k},timeVec);
                    end
            end
        end
    end
    methods
        function self=MatrixColTriuCubicSpline(varargin)
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
            import gras.interp.MatrixColTriuCubicSpline
            import modgen.common.throwerror;
            self=self@gras.interp.AMatrixCubicSpline(varargin{:});
        end
    end
end