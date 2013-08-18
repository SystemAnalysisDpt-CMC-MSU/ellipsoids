classdef AMatrixCubicSpline<gras.mat.IMatrixFunction
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-08$
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2011 $
    %
    properties (Access=protected)
        ppFormList
        mSizeVec
        nTimePoints
        timeVec
        nDims
        nRows
        nCols
    end
    methods (Access=public,Abstract)
        resArray=evaluate(self,timeVec)
    end
    methods (Access=protected,Static)
        ppFormList=buildSplineCoeffs(dataArray,timeVec)
    end
    methods
        function timeVec=getKnotVec(self)
            timeVec=self.timeVec;
        end
        function timeVec=getNKnots(self)
            timeVec=self.nTimePoints;
        end
        function [dataArray,timeVec]=getKnotDataArray(self)
            timeVec=self.timeVec;
            dataArray=self.evaluate(timeVec);
        end
        function mSize=getMatrixSize(self)
            mSize=self.mSizeVec;
        end
        function nDims=getDimensionality(self)
            nDims=self.nDims;
        end
        function nCols=getNCols(self)
            nCols=self.nCols;
        end
        function nRows=getNRows(self)
            nRows=self.nRows;
        end
        
        function self=AMatrixCubicSpline(dataArray,timeVec)
            % AMATRIXCUBESPLINE represents a cubic interpolant of
            % matrix-value function
            %
            % Input:
            %   Case#1:
            %       regular:
            %           dataArray: double[nCols,nRows,nTimePoints]
            %               /double[nRows,nTimes] - data array
            %           timeVec: double[1,nTimePoints] -
            %   Case#2
            %       no arguments
            %
            import modgen.common.throwerror;
            import modgen.common.checkvar;
            import modgen.common.checkmultvar;
            %
            if nargin==0
                %do nothing
                self.ppFormList=cell(0,0);
                self.mSizeVec=[0 0];
                self.nTimePoints=0;
                self.timeVec=[];
                self.nDims=2;
                self.nRows=0;
                self.nCols=0;
            elseif nargin==2
                [mSizeVec,nDims]=self.getSizeProps(dataArray);
                %
                checkvar(nDims,'x==1||x==2');
                checkvar(timeVec,'isrow(x)');
                nTimePoints=length(timeVec);
                dSizeVec=size(dataArray);
                checkmultvar('x1(end)==x2',2,dSizeVec(end),nTimePoints);
                %
                ppFormList=self.buildSplineCoeffs(dataArray,timeVec);
                self.initialize(ppFormList,mSizeVec,timeVec);
            else
                throwerror('wrongInput',...
                    'number of input arguments can be either 0 or 2');
            end
        end
    end
    methods (Access=protected, Static)
        function [mSizeVec,nDims,nRows,nCols]=getSizeProps(dataArray)
            dSizeVec=size(dataArray);
            mSizeVec=dSizeVec(1:end-1);
            mSizeLen=length(mSizeVec);
            nDims=2-(any(mSizeVec == 1) || (mSizeLen < 2));
            nRows=mSizeVec(1);
            if mSizeLen == 2
                nCols=mSizeVec(2);
            else
                nCols=1;
                mSizeVec = cat(2, mSizeVec, 1);
            end
        end
    end
    methods (Access=protected)
        function initialize(self,ppFormList,mSizeVec,timeVec)
            mSizeLen=length(mSizeVec);
            nDims=2-(any(mSizeVec == 1) || (mSizeLen < 2));
            nRows=mSizeVec(1);
            nTimePoints=length(timeVec);
            %
            if mSizeLen == 2
                nCols=mSizeVec(2);
            else
                nCols=1;
                mSizeVec = cat(2, mSizeVec, 1);
            end
            self.nRows=nRows;
            self.nCols=nCols;
            self.mSizeVec=mSizeVec;
            self.nDims=nDims;
            self.timeVec=timeVec;
            self.nTimePoints=nTimePoints;
            self.ppFormList=ppFormList;
        end
    end
end