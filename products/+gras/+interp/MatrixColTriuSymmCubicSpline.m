classdef MatrixColTriuSymmCubicSpline<gras.interp.MatrixColTriuCubicSpline
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-08$
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %    
    properties (Constant,GetAccess=private)
        CHECK_MATRIX_SYMMETRY_TOL=1e-14
    end
    methods (Access=public)
        function resArray=evaluate(self,timeVec)
            resArray=evaluate@...
                gras.interp.MatrixColTriuCubicSpline(self,timeVec);
            nCols=self.nCols;
            for k=1:1:nCols-1
                resArray((k+1):end,k,:)=resArray(k,(k+1):end,:);
            end
        end
    end
    methods
        function self=MatrixColTriuSymmCubicSpline(varargin)
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
            import gras.interp.MatrixColTriuSymmCubicSpline
            import modgen.common.throwerror;
            self=self@gras.interp.MatrixColTriuCubicSpline(varargin{:});
            if nargin>1
                dataArray=varargin{1};
                nTimePoints=size(dataArray,3);
                symmCheckTol=MatrixColTriuSymmCubicSpline.CHECK_MATRIX_SYMMETRY_TOL;
                for iTime=1:nTimePoints
                    if (max(max(abs(dataArray(:,:,iTime)-...
                            transpose(dataArray(:,:,iTime))...
                            ))))>symmCheckTol
                        throwerror('wrongInput',...
                            ['column_triu is only supported ',...
                            'for symmetrical matrices while ',...
                            'matrix at iTime=%d is not symmetrical'],...
                            iTime);
                    end
                end
            end            
        end
    end
end