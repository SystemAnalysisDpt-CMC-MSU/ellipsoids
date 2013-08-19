classdef PosDefMatCholCubicSpline<gras.interp.MatrixColTriuCubicSpline
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-08$
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    methods
        function self=PosDefMatCholCubicSpline(varargin)
            self=self@gras.interp.MatrixColTriuCubicSpline(varargin{:});
        end
    end
    methods (Access=protected,Static)
        function ppFormList=buildSplineCoeffs(dataArray,timeVec)
            import modgen.common.type.simple.checkgen;
            import modgen.common.type.simple.checkgenext;
            import modgen.common.throwerror;
            import gras.interp.MatrixColTriuCubicSpline;
            %
            [mSizeVec,nDims]=MatrixColTriuCubicSpline.getSizeProps(dataArray);
            checkgen(nDims,'x==2');
            checkgen(mSizeVec,'x(1)==x(2)');
            %
            sizeVec=size(dataArray);
            triuDataArray=zeros(sizeVec);
            nTimePoints=length(timeVec);
            try
                for iTime=1:nTimePoints
                    triuDataArray(:,:,iTime)=chol(dataArray(:,:,iTime));
                end
            catch meObj
                if strcmp(meObj.identifier,'MATLAB:posdef')
                    newMeObj=throwerror('wrongInput:posDef',...
                        ['Input array is expected to be composed of ',...
                        'positively defined matrices']);
                    newMeObj=addCause(newMeObj,meObj);
                    throw(newMeObj);
                else
                    rethrow(meObj);
                end
            end
            ppFormList=...
                MatrixColTriuCubicSpline.buildSplineCoeffs(...
                triuDataArray,timeVec);
        end
    end
    methods (Access=public)
        function dataArray=evaluate(self,timeVec,varargin)
            % EVALUATE
            %
            % Input:
            %   self:
            %
            %   timeVec: double[1,nObs] - vector of timeVec moments
            %
            % Output:
            %   dataArray: double[nRows,nCols,nObs] - resulting array
            %
            %
            dataArray=...
                evaluate@gras.interp.MatrixColTriuCubicSpline(...
                self,timeVec);
            %
            for iTime=1:size(dataArray,3)
                dataArray(:,:,iTime)=transpose(dataArray(:,:,iTime))*...
                    dataArray(:,:,iTime);
            end
        end
    end
end