classdef NNDefMatCholMultCubicSpline<gras.interp.PosDefMatCholCubicSpline
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-10$
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $    
    properties
        multInterpObj
    end
    methods
        function self=NNDefMatCholMultCubicSpline(varargin)
            % NNDefMatCholMultCubicSpline imlements an interpolation for
            % matrices represented as a product B*P*B' where P>0 and B is
            % arbitrary
            %
            % Input:
            %   Case#1:
            %       regular:
            %           multArray: [nCols,nRows,nTimePoints] - B matrix
            %               sequence
            %           posArray: double[nRows,nRows,nTimePoints]
            %               /double[nRows,nTimes] - P matrix sequence 
            %           timeVec: double[1,nTimePoints] -
            %   Case#2
            %       no arguments
            %
            %
            import modgen.common.throwerror;
            if nargin==0
                posArgList={};
                multArgList={};
            elseif nargin==3
                if (size(varargin{1},2)~=size(varargin{2},1))||...
                        (size(varargin{1},3)~=size(varargin{2},3))
                    throwerror('wrongInput',...
                        ['size of multArray is not compatible ',...
                        'with posArray''s size']);
                end
                posArgList=varargin([2,3]);
                multArgList=varargin([1 3]);
            else
                throwerror('wrongInput',...
                    'unsupported number of input parameters');
            end
            self=self@gras.interp.PosDefMatCholCubicSpline(posArgList{:});
            self.multInterpObj=gras.interp.MatrixColCubicSpline(multArgList{:});
        end
    end
    methods 
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
            posDataArray=...
                evaluate@gras.interp.PosDefMatCholCubicSpline(...
                self,timeVec);
            multDataArray=self.multInterpObj.evaluate(timeVec);
            %
            dataArray=gras.gen.SquareMatVector.lrMultiply(posDataArray,...
                multDataArray,'L');
        end        
    end
end