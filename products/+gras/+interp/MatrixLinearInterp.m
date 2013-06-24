classdef MatrixLinearInterp<gras.mat.IMatrixFunction
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
        function self=MatrixLinearInterp(dataArray,timeVec)
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
            sizeVec=self.getMatrixSize();
            dataArray=self.dataArray;
            nTimes=numel(newTimeVec);
            resArray=zeros([sizeVec,nTimes]);
            timeVec=self.timeVec;
            if isempty(timeVec)
                resArray=dataArray;
            else
                startTime=timeVec(1);
                endTime=timeVec(end);
                isLeftVec=newTimeVec<=startTime;
                resArray(:,:,isLeftVec)=repmat(dataArray(:,:,1),[1,1,sum(isLeftVec)]);
                isRightVec=newTimeVec>=endTime;
                resArray(:,:,isRightVec)=repmat(dataArray(:,:,end),[1,1,sum(isRightVec)]);
                isInsideVec=~(isLeftVec|isRightVec);
                indInsideVec=find(isInsideVec);
                newInsideTimeVec=newTimeVec(isInsideVec);
                indInterpVec=interp1(timeVec,1:numel(timeVec),newInsideTimeVec,...
                    'linear');
                %
                indLeftVec=fix(indInterpVec);
                indRightVec=ceil(indInterpVec);
                isSameVec=indLeftVec==indRightVec;
                resArray(:,:,indInsideVec(isSameVec))=...
                    dataArray(:,:,indLeftVec(isSameVec));
                isnSameVec=~isSameVec;
                if any(isnSameVec)                
                    %
                    indInsideVec=indInsideVec(isnSameVec);                
                    indLeftVec=indLeftVec(isnSameVec);
                    indRightVec=indRightVec(isnSameVec);
                    %
                    timeRightVec=timeVec(indRightVec);
                    timeLeftVec=timeVec(indLeftVec);
                    newInsideTimeVec=newInsideTimeVec(isnSameVec);
                    %
                    timeInvDistVec=1./(timeRightVec-timeLeftVec);
                    weightLeftArr=repmat(shiftdim((timeRightVec-newInsideTimeVec).*timeInvDistVec,-1),sizeVec);
                    weightRightArr=repmat(shiftdim((newInsideTimeVec-timeLeftVec).*timeInvDistVec,-1),sizeVec);
                    %
                    resArray(:,:,indInsideVec)=dataArray(:,:,indLeftVec).*...
                        weightLeftArr+...
                        dataArray(:,:,indRightVec).*weightRightArr;
                end
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