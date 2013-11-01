classdef MatrixNNDefTriuCubicSpline<gras.interp.MatrixColTriuSymmCubicSpline
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-08$
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %
    properties (Access=private)
        zeroEigTol
    end
    methods 
        function resArray=evaluate(self,timeVec)
            absTol=self.zeroEigTol;
            resArray=evaluate@...
                gras.interp.MatrixColTriuSymmCubicSpline(self,timeVec);
            nTimes=size(resArray,3);
            for iTime=1:nTimes
                [oMat,dMat]=eig(resArray(:,:,iTime));
                dVec=diag(dMat);
                isLessVec=dVec<=absTol;
                if any(isLessVec)
                    dVec(isLessVec)=absTol;
                    dMat=diag(dVec);
                    resArray(:,:,iTime)=oMat*dMat*oMat.';
                end
            end
        end
    end
    methods
        function self=MatrixNNDefTriuCubicSpline(varargin)
            % MatrixNNDefTriuCubicSpline represents a cubic interpolant of
            % matrix-value function
            %
            % Input:
            %   regular:
            %       dataArray: double[nCols,nRows,nTimePoints]
            %               /double[nRows,nTimes] - data array
            %       timeVec: double[1,nTimePoints] -
            %
            %   properties:
            %       zeroEigTol: double[1,1] - if minimal eigen value of
            %           input matrix at some time moment is less than this
            %           value it is considered to be equal to zero
            %
            ZERO_EIG_TOL=0;            
            import modgen.common.parseparext;
            [reg,~,absTol]=parseparext(varargin,{'zeroEigTol';ZERO_EIG_TOL;...
                'isscalar(x)&&isnumeric(x)&&(x>=0)'});
            self=self@gras.interp.MatrixColTriuSymmCubicSpline(reg{:});
            self.zeroEigTol=absTol;
        end
    end
end