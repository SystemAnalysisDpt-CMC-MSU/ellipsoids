classdef MatrixScalarCubicSpline<gras.interp.AMatrixCubicSpline
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-08$
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %
    methods (Access=protected,Static)
        function ppFormList=buildSplineCoeffs(dataArray,timeVec)
            import gras.interp.AMatrixCubicSpline
            ppFormList=cell(1,1);
            ppFormList{1}=csapi(timeVec,dataArray);
        end
    end
    methods (Access=public)
        function resArray=evaluate(self,timeVec)
            nTimePoints=length(timeVec);
            resArray=zeros(1,1,nTimePoints);
            resArray(:,:,:)=ppval(self.ppFormList{1},timeVec);
        end
    end
    methods
        function objList=getColSplines(self)
            objList=cell(1,1);
            objList{1}=gras.interp.MatrixColCubicSpline();
            objList{1}.initialize(self.ppFormList(1),...
                1,self.timeVec);
        end
        function self=MatrixScalarCubicSpline(varargin)
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