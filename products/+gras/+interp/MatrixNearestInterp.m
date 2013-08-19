classdef MatrixNearestInterp<gras.mat.IMatrixFunction
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-08$
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %
    properties (Access=protected)
        dataArray
        timeVec
    end
    methods
        function self=MatrixNearestInterp(dataArray,timeVec)
            import modgen.common.checkmultvar;
            if nargin>0
                checkmultvar(['size(x1,3)==numel(x2)&&isrow(x2)',...
                    '&&isnumeric(x1)&&isnumeric(x2)&&',...
                    'all(diff(x2)>0)'],2,dataArray,timeVec);
                %
                self.dataArray=dataArray;
                self.timeVec=timeVec;
            end
        end
        
        function sizeVec=getMatrixSize(self)
            sizeVec=size(self.dataArray(:,:,1));
        end
        function resArray=evaluate(self,newTimeVec)
            dataArray=self.dataArray;
            timeVec=self.timeVec;
            if isempty(timeVec)
                resArray=dataArray;
            else
                indInterpVec=interp1(timeVec,1:numel(timeVec),newTimeVec,...
                    'nearest','extrap');
                resArray=dataArray(:,:,indInterpVec);
            end
        end
        function nDims=getDimensionality(self)
            nDims=2;
        end
        function nCols=getNCols(self)
            nCols=size(self.dataArray,2);
        end
        function nRows=getNRows(self)
            nRows=size(self.dataArray,1);
        end
        function [dataArray,timeVec]=getKnotDataArray(self)
            timeVec=self.timeVec;
            dataArray=self.evaluate(timeVec);
        end
    end
end